scope DestroyerAI
    globals
        private constant integer HERO_ID = 'H009'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Arcane Swap */
		private constant integer AS_SPELL_ID = 'A06N'
		private constant string AS_ORDER = "ambush"
		private integer array AS_Chance
		private real array AS_Cooldown
		private timer AS_Timer
		private integer array AS_Mana_Priority
		private real AS_Radius = 600

		/* Mind Burst */
		private constant integer MB_SPELL_ID = 'A06O'
		private constant string MB_ORDER = "rejuvination"
		private integer array MB_Chance
		private real array MB_Cooldown
		private timer MB_Timer
		private integer array MB_Mana_Priority
		private real MB_Radius = 700		

		/* Release Mana */
		private constant integer RM_SPELL_ID = 'A06Q'
		private constant string RM_ORDER = "roar"
		private integer array RM_Chance
		private integer array RM_Min_Enemies
		private real array RM_Min_Mana
		private timer RM_Timer
    endglobals
    
    private struct AI extends array
	
		private static method Destroyer_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
	
        private method doArcaneSwap takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, AS_SPELL_ID) - 1
			local integer rnd = 0
			local unit u
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, GetUnitX(.hero), GetUnitY(.hero), AS_Radius, Filter(function thistype.Destroyer_Filter))
			
			loop
				set u = FirstOfGroup(enumGroup)
				exitwhen (u == null)
				set rnd = GetRandomInt(0,100)
				
				if ((rnd <= AS_Mana_Priority[.aiLevel]) and /*
				*/	(GetUnitStateSwap(UNIT_STATE_MAX_MANA, u) > 0.00)) then
					set abilityCasted = IssueTargetOrder(.hero, AS_ORDER, u)
				else
					if (rnd <= (100 - AS_Mana_Priority[.aiLevel])) then
						set abilityCasted = IssueTargetOrder(.hero, AS_ORDER, u)
					endif
				endif
				call GroupRemoveUnit(enumGroup, u)
			endloop
			
			set u = null

			if (abilityCasted) then
				call TimerStart(AS_Timer, AS_Cooldown[level], false, null)
			endif

			return abilityCasted
		endmethod
		
		private method doMindBurst takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, MB_SPELL_ID) - 1
			local integer rnd = 0
			local unit u
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, GetUnitX(.hero), GetUnitY(.hero), MB_Radius, Filter(function thistype.Destroyer_Filter))
			
			loop
				set u = FirstOfGroup(enumGroup)
				exitwhen (u == null)
				set rnd = GetRandomInt(0,100)
				
				if ((rnd <= MB_Mana_Priority[.aiLevel]) and /*
				*/	(GetUnitStateSwap(UNIT_STATE_MAX_MANA, u) > 0.00)) then
					set abilityCasted = IssueTargetOrder(.hero, MB_ORDER, u)
				else
					if (rnd <= (100 - MB_Mana_Priority[.aiLevel])) then
						set abilityCasted = IssueTargetOrder(.hero, MB_ORDER, u)
					endif
				endif
				call GroupRemoveUnit(enumGroup, u)
			endloop
			
			set u = null
			
			if (abilityCasted) then
				call TimerStart(MB_Timer, MB_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doReleaseMana takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, RM_SPELL_ID) - 1
			local real radius = GetUnitState(.hero, UNIT_STATE_MANA)
			local unit u
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, GetUnitX(.hero), GetUnitY(.hero), radius, Filter(function thistype.Destroyer_Filter))
			
			// check for amount of enemies
			if (CountUnitsInGroup(enumGroup) >= RM_Min_Enemies[.aiLevel]) then
				// check for mana value
				if (GetUnitLifePercent(.hero) < RM_Min_Mana[.aiLevel]) then
					// Try use a mana potion to reach the min mana value
					call .useManaPotion()
				endif
				set abilityCasted = IssueImmediateOrder(.hero, RM_ORDER)
			endif
			
			return abilityCasted
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Arcane Swap */
				if 	((GetRandomInt(0,100) <= AS_Chance[.aiLevel]) and /*
				*/	(TimerGetRemaining(AS_Timer) == 0.0)) then
					set abilityCasted = doArcaneSwap()
				endif
				
				/* Mind Burst */
				if ((GetRandomInt(0,100) <= MB_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(MB_Timer) == 0.0)) then
					set abilityCasted = doMindBurst()
				endif
				
				/* Release Mana */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= RM_Chance[.aiLevel]) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doReleaseMana()					
				endif
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Arcane Swap
			call RegisterHeroAISkill(HERO_ID, 1, 'A06N')
			call RegisterHeroAISkill(HERO_ID, 5, 'A06N') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A06N') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A06N') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A06N') 
			// Mana Steal
			call RegisterHeroAISkill(HERO_ID, 2, 'A06R') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A06R') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A06R') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A06R') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A06R') 
			// Mind Burst
			call RegisterHeroAISkill(HERO_ID, 3, 'A06O') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A06O') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A06O') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A06O') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A06O') 
			// Release Mana
			call RegisterHeroAISkill(HERO_ID, 6, 'A06Q')
			call RegisterHeroAISkill(HERO_ID, 12, 'A06Q')
			call RegisterHeroAISkill(HERO_ID, 18, 'A06Q')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', BLOOD_BLADE, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', BLOOD_BLADE, 1)
				call Itemsets[1].addItem('u001', BONE_HELMET, 1)
				call Itemsets[1].addItem('u003', ARCANE_FLARE, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', BLOOD_BLADE, 1)
				call Itemsets[2].addItem('u001', BONE_HELMET, 1)
				call Itemsets[2].addItem('u003', TEMPEST_SKULL, 1)
				call Itemsets[2].addItem('u003', NECROMANCERS_ROBE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// AS
			set AS_Chance[0] = 20
			set AS_Chance[1] = 30
			set AS_Chance[2] = 40
			
			// priority to cast spell on a unit with mana!
			set AS_Mana_Priority[0] = 50
			set AS_Mana_Priority[1] = 60
			set AS_Mana_Priority[2] = 70
			
			set AS_Timer = NewTimer()
			set AS_Cooldown[0] = 21.0
			set AS_Cooldown[1] = 18.0
			set AS_Cooldown[2] = 15.0
			set AS_Cooldown[3] = 12.0
			set AS_Cooldown[4] = 9.0
			
			// Mind Burst
			set MB_Chance[0] = 20
			set MB_Chance[1] = 20
			set MB_Chance[2] = 30
			
			// priority to cast spell on a unit with mana!
			set MB_Mana_Priority[0] = 50
			set MB_Mana_Priority[1] = 60
			set MB_Mana_Priority[2] = 70
			
			set MB_Timer = NewTimer()
			set MB_Cooldown[0] = 9.0
			set MB_Cooldown[1] = 9.0
			set MB_Cooldown[2] = 9.0
			set MB_Cooldown[3] = 9.0
			set MB_Cooldown[4] = 9.0
			
			// XZ
			set RM_Chance[0] = 20
			set RM_Chance[1] = 30
			set RM_Chance[2] = 30
			
			// min. X perecent to cast ability
			set RM_Min_Mana[0] = 60.
			set RM_Min_Mana[1] = 70.
			set RM_Min_Mana[2] = 80.
			
			set RM_Min_Enemies[0] = 5
			set RM_Min_Enemies[1] = 6
			set RM_Min_Enemies[2] = 7
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope