scope DreadLordAI
    globals
        private constant integer HERO_ID = 'U01X'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Vampire Blood */
		private constant integer VB_SPELL_ID = 'A06V'
		private constant string VB_ORDER = "summonfactory"
		private integer array VB_Chance
		private real array VB_Cooldown
		private integer array VB_Max_Random_Loc
		private integer array VB_Min_Enemies
		private timer VB_Timer
		private real VB_RADIUS = 900
		private real VB_AOE = 250

		/* Purify */
		private constant integer P_SPELL_ID = 'A0B2'
		private constant string P_ORDER = "ambush"
		private integer array P_Chance
		private real array P_Cooldown
		private timer P_Timer
		private real P_AOE = 800
		private real array P_Ally_Heal
		private real array P_Enemy_Dmg
		private integer P_Ally_Chance = 80
		private integer P_Enemy_Chance = 20
		
		/* Sleepy Dust */
		private constant integer SD_SPELL_ID = 'A06T'
		private constant string SD_ORDER = "ward"
		private integer array SD_Chance
		private real array SD_Cooldown
		private timer SD_Timer
		private real SD_RANGE = 500		

		/* Night Dome */
		private constant integer ND_SPELL_ID = 'A06Z'
		private constant string ND_ORDER = "deathanddecay"
		private constant real ND_RADIUS = 780
		private integer array ND_Chance
		private real array ND_Cooldown
		private timer ND_Timer
		private real array ND_Min_Percent_Mana
		private integer array ND_Min_Allies
    endglobals
    
    private struct AI extends array
	
		private static method VB_Filter takes nothing returns boolean
			return SpellHelper.isValidAlly(GetFilterUnit(), tempthis.hero)
		endmethod
	
        private method doVampireBlood takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, VB_SPELL_ID) - 1
			local integer i = 0
			local real x
			local real y
			local location l
			
			call GroupClear(enumGroup)
			
			loop
				exitwhen i >= VB_Max_Random_Loc[.aiLevel]
				set l = RandomPointCircle(GetUnitX(.hero), GetUnitY(.hero), VB_RADIUS) 
				set x = GetLocationX(l)
				set y = GetLocationY(l)
				call GroupEnumUnitsInRange(enumGroup, x, y, VB_AOE, Filter(function thistype.VB_Filter))
			
				if (CountUnitsInGroup(enumGroup) >= VB_Min_Enemies[level]) then
					set abilityCasted = IssuePointOrder(.hero, VB_ORDER, x, y)
					set i = VB_Max_Random_Loc[.aiLevel]
				endif
				call GroupClear(enumGroup)
				set i = i + 1
			endloop
			
			call RemoveLocation(l)
			set l = null
			
			if (abilityCasted) then
				call TimerStart(VB_Timer, VB_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private static method Purify_Filter takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidEnemy(u, tempthis.hero) or /*
			*/	SpellHelper.isValidAlly(u, tempthis.hero)) then
				set b = true
			endif
			
			set u = null
			
			return b
		endmethod
		
		private method doPurify takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, P_SPELL_ID) - 1
			local unit u
			local real maxLife
			local real life
			local real diff
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, P_AOE, Filter(function thistype.Purify_Filter))
			
			loop
				set u = GetRandomUnitFromGroup(enumGroup)
				exitwhen (u == null)
				set maxLife = GetUnitState(u, UNIT_STATE_MAX_LIFE)
				set life = GetUnitState(u, UNIT_STATE_LIFE)
				set diff = maxLife - life
				
				// is ally?
				if (IsUnitAlly(u, tempthis.owner)) then
					if ((GetRandomInt(0,100) <= P_Ally_Chance) and /*
					*/	(IsUnitType(u, UNIT_TYPE_HERO)) and /*
					*/	(diff >= P_Ally_Heal[level])) then
						set abilityCasted = IssueTargetOrder(.hero, P_ORDER, u)
					endif
				else
					if ((GetRandomInt(0,100) <= P_Enemy_Chance) and /*
					*/	(IsUnitType(u, UNIT_TYPE_HERO)) and /*
					*/	(life < P_Enemy_Dmg[level])) then
						set abilityCasted = IssueTargetOrder(.hero, P_ORDER, u)
					endif
				endif
				
				// clear group if purify casted
				if (abilityCasted) then
					call GroupClear(enumGroup)
					call TimerStart(P_Timer, P_Cooldown[level], false, null)
				else
					call GroupRemoveUnit(enumGroup, u)
				endif
			endloop
			
			set u = null
			
			return abilityCasted
		endmethod
		
		private method doSleepyDust takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, SD_SPELL_ID) - 1

			if ((.closestEnemyHero != null) and /*
			*/	(Distance(.hx, .hy, GetUnitX(.closestEnemyHero), GetUnitY(.closestEnemyHero)) <= SD_RANGE)) then
				set abilityCasted = IssuePointOrder(.hero, SD_ORDER, GetUnitX(.closestEnemyHero), GetUnitY(.closestEnemyHero))
			endif
			
			if (abilityCasted) then
				call TimerStart(SD_Timer, SD_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private static method ND_Filter takes nothing returns boolean
			local unit u = GetFilterUnit()
			local integer level = GetUnitAbilityLevel(tempthis.hero, ND_SPELL_ID) - 1
			local boolean b = false
			
			if ((SpellHelper.isValidAlly(u, tempthis.hero)) and /*
			*/	(GetUnitManaPercent(u) <= ND_Min_Percent_Mana[level])) then
				set b = true
			endif
			
			set u = null
			
			return b
		endmethod
		
		private method doNightDome takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, ND_SPELL_ID) - 1
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, ND_RADIUS, Filter(function thistype.ND_Filter))
			
			if (CountUnitsInGroup(enumGroup) >= ND_Min_Allies[.aiLevel]) then
				set abilityCasted = IssuePointOrder(.hero, ND_ORDER, .hx, .hy)
			endif
			
			if (abilityCasted) then
				call TimerStart(ND_Timer, ND_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Vampire Blood */
				if 	((GetRandomInt(0,100) <= VB_Chance[.aiLevel]) and /*
				*/	(TimerGetRemaining(VB_Timer) == 0.0)) then
					set abilityCasted = doVampireBlood()
				endif
				
				/* Purify */
				if ((GetRandomInt(0,100) <= P_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(P_Timer) == 0.0)) then
					set abilityCasted = doPurify()
				endif
				
				/* Sleepy Dust */
				if ((GetRandomInt(0,100) <= SD_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(SD_Timer) == 0.0)) then
					set abilityCasted = doSleepyDust()
				endif
				
				/* Night Dome */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= ND_Chance[.aiLevel]) and /*
				*/  (TimerGetRemaining(ND_Timer) == 0.0) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doNightDome()					
				endif
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Vampire Blood
			call RegisterHeroAISkill(HERO_ID, 3, 'A06V')
			call RegisterHeroAISkill(HERO_ID, 5, 'A06V') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A06V') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A06V') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A06V') 
			// Purify
			call RegisterHeroAISkill(HERO_ID, 2, 'A0B2') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A0B2') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A0B2') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A0B2') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A0B2') 
			// Sleepy Dust
			call RegisterHeroAISkill(HERO_ID, 1, 'A06T') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A06T') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A06T') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A06T') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A06T') 
			// Night Dome
			call RegisterHeroAISkill(HERO_ID, 6, 'A06Z')
			call RegisterHeroAISkill(HERO_ID, 12, 'A06Z')
			call RegisterHeroAISkill(HERO_ID, 18, 'A06Z')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', DARK_PLATES, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', DARK_PLATES, 1)
				call Itemsets[1].addItem('u001', BLOOD_BLADE, 1)
				call Itemsets[1].addItem('u003', DEMONIC_AMULET, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', DARK_PLATES, 1)
				call Itemsets[2].addItem('u001', BLOOD_BLADE, 1)
				call Itemsets[2].addItem('u003', DEMONIC_AMULET, 1)
				call Itemsets[2].addItem('u003', NECROMANCERS_ROBE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Vampire Blood
			set VB_Chance[0] = 20
			set VB_Chance[1] = 25
			set VB_Chance[2] = 30
			
			set VB_Max_Random_Loc[0] = 5
			set VB_Max_Random_Loc[1] = 7
			set VB_Max_Random_Loc[2] = 9
			
			// Drop Count (check : NUM_DROPS --> VampireBlood.j)
			set VB_Min_Enemies[0] = 3
			set VB_Min_Enemies[1] = 4
			set VB_Min_Enemies[2] = 5
			set VB_Min_Enemies[3] = 6
			set VB_Min_Enemies[4] = 7
			
			set VB_Timer = NewTimer()
			set VB_Cooldown[0] = 10.0
			set VB_Cooldown[1] = 9.0
			set VB_Cooldown[2] = 8.0
			set VB_Cooldown[3] = 7.0
			set VB_Cooldown[4] = 6.0
			
			// Purify
			set P_Chance[0] = 10
			set P_Chance[1] = 25
			set P_Chance[2] = 40
			
			// Check Purify.j
			set P_Ally_Heal[0] = 140
			set P_Ally_Heal[1] = 280
			set P_Ally_Heal[2] = 420
			set P_Ally_Heal[3] = 560
			set P_Ally_Heal[4] = 700
			
			// Check Purify.j
			set P_Enemy_Dmg[0] = 50
			set P_Enemy_Dmg[1] = 100
			set P_Enemy_Dmg[2] = 150
			set P_Enemy_Dmg[3] = 200
			set P_Enemy_Dmg[4] = 250
			
			set P_Timer = NewTimer()
			set P_Cooldown[0] = 5.0
			set P_Cooldown[1] = 5.0
			set P_Cooldown[2] = 5.0
			set P_Cooldown[3] = 5.0
			set P_Cooldown[4] = 5.0
			
			// Sleepy Dust
			set SD_Chance[0] = 10
			set SD_Chance[1] = 10
			set SD_Chance[2] = 10
			
			set SD_Timer = NewTimer()
			set SD_Cooldown[0] = 7.0
			set SD_Cooldown[1] = 7.0
			set SD_Cooldown[2] = 7.0
			set SD_Cooldown[3] = 7.0
			set SD_Cooldown[4] = 7.0
			
			// Night Dome
			set ND_Chance[0] = 20
			set ND_Chance[1] = 20
			set ND_Chance[2] = 20
			
			set ND_Min_Percent_Mana[0] = 50.0
			set ND_Min_Percent_Mana[1] = 60.0
			set ND_Min_Percent_Mana[2] = 70.0
			
			set ND_Min_Allies[0] = 4 
			set ND_Min_Allies[1] = 6
			set ND_Min_Allies[2] = 8
			
			set ND_Timer = NewTimer()
			set ND_Cooldown[0] = 120.0
			set ND_Cooldown[1] = 110.0
			set ND_Cooldown[2] = 100.0
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope