scope ArchmageAI
    globals
        private constant integer HERO_ID = 'H00Y'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Holy Chains */
		private constant integer HC_SPELL_ID = 'A076'
		private constant string HC_ORDER = "deathanddecay"
		private integer array HC_Chance
		private real array HC_Cooldown
		private timer HC_Timer
		private integer array HC_Max_Random_Loc
		private integer array HC_Min_Enemies
		private real HC_RADIUS = 900
		private real HC_AOE = 250

		/* Trappy Swap */
		private constant integer TS_SPELL_ID = 'A07N'
		private constant string TS_ORDER = "ambush"
		private integer array TS_Chance
		private real array TS_Cooldown
		private timer TS_Timer
		private real array TS_Min_HP		
		
		/* Fireworks */
		private constant integer F_SPELL_ID = 'A07K'
		private constant string F_ORDER = "roar"
		// Check Fireworks.j -> RAIN_AOE
		private constant real F_RADIUS = 700 
		private integer array F_Chance
		private real array F_Cooldown
		private timer F_Timer
		private integer array F_Min_Enemies
    endglobals
    
    private struct AI extends array
	
		private static method Archmage_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
        
		private method doHolyChains takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, HC_SPELL_ID) - 1
			local integer i = 0
			local real x
			local real y
			local location l
			
			call GroupClear(enumGroup)
			
			loop
				exitwhen i >= HC_Max_Random_Loc[.aiLevel]
				set l = RandomPointCircle(GetUnitX(.hero), GetUnitY(.hero), HC_RADIUS) 
				set x = GetLocationX(l)
				set y = GetLocationY(l)
				call GroupEnumUnitsInRange(enumGroup, x, y, HC_AOE, Filter(function thistype.Archmage_Filter))
			
				if (CountUnitsInGroup(enumGroup) >= HC_Min_Enemies[.aiLevel]) then
					set abilityCasted = IssuePointOrder(.hero, HC_ORDER, x, y)
					set i = HC_Max_Random_Loc[.aiLevel]
				endif
				call GroupClear(enumGroup)
				set i = i + 1
			endloop
			
			call RemoveLocation(l)
			set l = null
			
			if (abilityCasted) then
				call TimerStart(HC_Timer, HC_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doTrappySwap takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, TS_SPELL_ID) - 1
			
			if ((.closestEnemy != null) and /*
			*/	(GetUnitLifePercent(.closestEnemy) >= TS_Min_HP[.aiLevel])) then
				set abilityCasted = IssueTargetOrder(.hero, TS_ORDER, closestEnemy)
			endif
			
			if (abilityCasted) then
				call TimerStart(TS_Timer, TS_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doFireworks takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, F_SPELL_ID) - 1
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, F_RADIUS, Filter(function thistype.Archmage_Filter))
			
			if (CountUnitsInGroup(enumGroup) >= F_Min_Enemies[.aiLevel]) then
				set abilityCasted = IssueImmediateOrder(.hero, F_ORDER)
			endif
			
			if (abilityCasted) then
				call TimerStart(F_Timer, F_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Holy Chains */
				if 	((GetRandomInt(0,100) <= HC_Chance[.aiLevel]) and /*
				*/	(TimerGetRemaining(HC_Timer) == 0.0)) then
					set abilityCasted = doHolyChains()
				endif
				
				/* Trappy Swap */
				if ((GetRandomInt(0,100) <= TS_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(TS_Timer) == 0.0)) then
					set abilityCasted = doTrappySwap()
				endif
				
				/* Fireworks */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= F_Chance[.aiLevel]) and /*
				*/  (TimerGetRemaining(F_Timer) == 0.0) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doFireworks()					
				endif
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Holy Chain
			call RegisterHeroAISkill(HERO_ID, 1, 'A076')
			call RegisterHeroAISkill(HERO_ID, 5, 'A076') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A076') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A076') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A076') 
			// Trappy Swap
			call RegisterHeroAISkill(HERO_ID, 2, 'A07N') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A07N') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A07N') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A07N') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A07N') 
			// Refreshing Aura
			call RegisterHeroAISkill(HERO_ID, 3, 'A07M') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A07M') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A07M') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A07M') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A07M') 
			// Fireworks
			call RegisterHeroAISkill(HERO_ID, 6, 'A07K')
			call RegisterHeroAISkill(HERO_ID, 12, 'A07K')
			call RegisterHeroAISkill(HERO_ID, 18, 'A07K')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
			// This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u00K', HEALING_POTION, 2)
				call Itemsets[0].addItem('u00K', MANA_POTION, 1)
				call Itemsets[0].addItem('u00L', TIME_AMULET, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u00K', HEALING_POTION, 4)
				call Itemsets[1].addItem('u00K', MANA_POTION, 2)
				call Itemsets[1].addItem('u00L', TIME_AMULET, 1)
				call Itemsets[1].addItem('u00L', CHAINMAIL, 1)
				call Itemsets[1].addItem('u00M', CROWBAR, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u00K', HEALING_POTION, 5) 
				call Itemsets[2].addItem('u00K', MANA_POTION, 3)
				call Itemsets[2].addItem('u00L', TIME_AMULET, 1)
				call Itemsets[2].addItem('u00L', CHAINMAIL, 1)
				call Itemsets[2].addItem('u00M', CROWBAR, 1)
				call Itemsets[2].addItem('u00M', GRYPHONS_EYE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Holy Chains
			set HC_Chance[0] = 20
			set HC_Chance[1] = 30
			set HC_Chance[2] = 40
			
			set HC_Max_Random_Loc[0] = 5
			set HC_Max_Random_Loc[1] = 7
			set HC_Max_Random_Loc[2] = 9
			
			set HC_Min_Enemies[0] = 2
			set HC_Min_Enemies[1] = 3
			set HC_Min_Enemies[2] = 4
			
			set HC_Timer = NewTimer()
			set HC_Cooldown[0] = 10.0
			set HC_Cooldown[1] = 10.0
			set HC_Cooldown[2] = 10.0
			set HC_Cooldown[3] = 10.0
			set HC_Cooldown[4] = 10.0
			
			// Trappy Swap
			set TS_Chance[0] = 20
			set TS_Chance[1] = 25
			set TS_Chance[2] = 30
			
			// Percent Value
			set TS_Min_HP[0] = 80.
			set TS_Min_HP[1] = 90.
			set TS_Min_HP[2] = 100.
			
			set TS_Timer = NewTimer()
			set TS_Cooldown[0] = 15.0
			set TS_Cooldown[1] = 15.0
			set TS_Cooldown[2] = 15.0
			set TS_Cooldown[3] = 15.0
			set TS_Cooldown[4] = 15.0
			
			// Fireworks
			set F_Chance[0] = 20
			set F_Chance[1] = 25
			set F_Chance[2] = 30
			
			set F_Min_Enemies[0] = 5
			set F_Min_Enemies[1] = 7
			set F_Min_Enemies[2] = 9
			
			set F_Timer = NewTimer()
			set F_Cooldown[0] = 105.0
			set F_Cooldown[1] = 105.0
			set F_Cooldown[2] = 105.0
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope