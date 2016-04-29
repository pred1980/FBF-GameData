scope DarkRangerAI
    globals
        private constant integer HERO_ID = 'N00J'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Crippling Arrow */
		private constant integer CA_SPELL_ID = 'A0AJ'
		private constant integer CA_BUFF_ID = 'B013'
		private constant string CA_ORDER = "deathanddecay"
		private integer array CA_Chance
		private real array CA_Cooldown
		private timer CA_Timer
		private real CA_RADIUS = 700
		private integer CA_Hero_Chance = 85
		private integer CA_Normal_Chance = 15
		
		/* Snipe */
		private constant integer S_SPELL_ID = 'A06X'
		private constant integer S_BUFF_ID = 'B00N'
		private constant string S_ORDER = "ambush"
		private integer array S_Chance
		private real array S_Cooldown
		private timer S_Timer		

		/* Coup de Grace */
		private constant integer CDG_SPELL_ID = 'A0B4'
		private constant string CDG_ORDER = "acidbomb"
		// Spell Radius
		private constant real CDG_RADIUS_1 = 600
		// Radius for enemies to damage (Check CoupDeGrace.j)
		private constant real CDG_RADIUS_2 = 400
		private integer array CDG_Chance
		private real array CDG_Cooldown
		private real array CDG_Min_Percent_HP
		private integer array CDG_Min_Enemies
		private timer CDG_Timer
    endglobals
    
    private struct AI extends array
	
		private static method CA_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
	
		private method doCripplingArrow takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, CA_SPELL_ID) - 1
			local unit u
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, CA_RADIUS, Filter(function thistype.CA_Filter))
			
			loop
				set u = GetRandomUnitFromGroup(enumGroup)
				exitwhen (u == null)
				// deals bonus damage if the target is already affected by an arrow.
				if (GetUnitAbilityLevel(u, CA_BUFF_ID) > 0) then
					set abilityCasted = IssuePointOrder(.hero, CA_ORDER, GetUnitX(u), GetUnitY(u))
				else
					if ((GetRandomInt(0,100) <= CA_Hero_Chance) and /*
					*/	(IsUnitType(u, UNIT_TYPE_HERO))) then
						set abilityCasted = IssuePointOrder(.hero, CA_ORDER, GetUnitX(u), GetUnitY(u))
					else
						if (GetRandomInt(0,100) <= CA_Normal_Chance) then
							set abilityCasted = IssuePointOrder(.hero, CA_ORDER, GetUnitX(u), GetUnitY(u))
						endif
					endif
				endif
				
				if (abilityCasted) then
					call TimerStart(CA_Timer, CA_Cooldown[level], false, null)
					call GroupClear(enumGroup)
				else
					call GroupRemoveUnit(enumGroup, u)
				endif
			endloop
			
			set u = null
			
			return abilityCasted
		endmethod
		
		private method doSnipe takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, S_SPELL_ID) - 1
			
			if (.closestEnemyHero != null) then
				call AIDummyMissile.create(.hero, .closestEnemyHero)
				
				if (GetUnitAbilityLevel(.closestEnemyHero, S_BUFF_ID) > 0) then
					set abilityCasted = IssueTargetOrder(.hero, S_ORDER, .closestEnemyHero)
				endif
			endif
			
			if (abilityCasted) then
				call TimerStart(S_Timer, S_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private static method CDG_Filter_2 takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
		
		private static method CDG_Filter_1 takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			local integer level = GetUnitAbilityLevel(tempthis.hero, CDG_SPELL_ID) - 1
			
			if ((SpellHelper.isValidAlly(u, tempthis.hero)) and /*
			*/	(IsUnitType(u, UNIT_TYPE_HERO)) and /*
			*/	(GetUnitLifePercent(u) <= CDG_Min_Percent_HP[level]) and not /*
			*/	(UnitHasItemOfTypeBJ(u, 'I00O'))) then
				
				// Now check if enough enemies are around
				call GroupClear(ENUM_GROUP)
				call GroupEnumUnitsInRange(ENUM_GROUP, tempthis.hx, tempthis.hy, CDG_RADIUS_2, Filter(function thistype.CDG_Filter_2))
				
				if (CountUnitsInGroup(ENUM_GROUP) >= CDG_Min_Enemies[level]) then
					set b = true
				endif
			endif
			
			set u = null
			
			return b
		endmethod
		
		private method doCoupDeGrace takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, CDG_SPELL_ID) - 1
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, CDG_RADIUS_1, Filter(function thistype.CDG_Filter_1))
			
			if (CountUnitsInGroup(enumGroup) > 0) then
				set abilityCasted = IssueTargetOrder(.hero, CDG_ORDER, GetRandomUnitFromGroup(enumGroup))
			endif
			
			if (abilityCasted) then
				call TimerStart(CDG_Timer, CDG_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Crippling Arrow */
				if ((GetRandomInt(0,100) <= CA_Chance[.aiLevel]) and /*
				*/ (TimerGetRemaining(CA_Timer) == 0.0)) then
					set abilityCasted = doCripplingArrow()
				endif
				
				/* Snipe */
				if ((GetRandomInt(0,100) <= S_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(S_Timer) == 0.0)) then
					set abilityCasted = doSnipe()
				endif
				
				/* Coup de Grace */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= CDG_Chance[.aiLevel]) and /*
				*/  (TimerGetRemaining(CDG_Timer) == 0.0) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doCoupDeGrace()					
				endif
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Ghost Form
			call RegisterHeroAISkill(HERO_ID, 3, 'A071')
			call RegisterHeroAISkill(HERO_ID, 7, 'A071') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A071') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A071') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A071') 
			// Crippling Arrow
			call RegisterHeroAISkill(HERO_ID, 1, 'A0AJ') 
			call RegisterHeroAISkill(HERO_ID, 4, 'A0AJ') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A0AJ') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A0AJ') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A0AJ') 
			// Snipe
			call RegisterHeroAISkill(HERO_ID, 2, 'A06X') 
			call RegisterHeroAISkill(HERO_ID, 5, 'A06X') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A06X') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A06X') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A06X') 
			// Coup de Grace
			call RegisterHeroAISkill(HERO_ID, 6, 'A0B4')
			call RegisterHeroAISkill(HERO_ID, 12, 'A0B4')
			call RegisterHeroAISkill(HERO_ID, 18, 'A0B4')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', UNHOLY_ICON, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', UNHOLY_ICON, 1)
				call Itemsets[1].addItem('u001', DARK_PLATES, 1)
				call Itemsets[1].addItem('u003', NECROMANCERS_ROBE, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', UNHOLY_ICON, 1)
				call Itemsets[2].addItem('u001', DARK_PLATES, 1)
				call Itemsets[2].addItem('u003', NECROMANCERS_ROBE, 1)
				call Itemsets[2].addItem('u003', ARCANE_FLARE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Crippling Arrow
			set CA_Chance[0] = 25
			set CA_Chance[1] = 35
			set CA_Chance[2] = 45
			
			set CA_Timer = NewTimer()
			set CA_Cooldown[0] = 8.0
			set CA_Cooldown[1] = 8.0
			set CA_Cooldown[2] = 8.0
			set CA_Cooldown[3] = 8.0
			set CA_Cooldown[4] = 8.0
			
			// Snipe
			set S_Chance[0] = 25
			set S_Chance[1] = 35
			set S_Chance[2] = 45
			
			set S_Timer = NewTimer()
			set S_Cooldown[0] = 5.0
			set S_Cooldown[1] = 5.0
			set S_Cooldown[2] = 5.0
			set S_Cooldown[3] = 5.0
			set S_Cooldown[4] = 5.0
			
			// Coup de Grace
			set CDG_Chance[0] = 10
			set CDG_Chance[1] = 10
			set CDG_Chance[2] = 100
			
			set CDG_Min_Percent_HP[0] = 20.0
			set CDG_Min_Percent_HP[1] = 15.0
			set CDG_Min_Percent_HP[2] = 10.0
			
			set CDG_Min_Enemies[0] = 3
			set CDG_Min_Enemies[1] = 4
			set CDG_Min_Enemies[2] = 5
			
			set CDG_Timer = NewTimer()
			set CDG_Cooldown[0] = 180.0
			set CDG_Cooldown[1] = 150.0
			set CDG_Cooldown[2] = 120.0
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope