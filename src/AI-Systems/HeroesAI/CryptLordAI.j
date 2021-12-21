scope CryptLordAI
    globals
        private constant integer HERO_ID = 'U01U'
		
		private HeroAI_Itemset array Itemsets	
        private group enumGroup = CreateGroup()
		
		/* Burrow Strike */
		private constant integer BS_SPELL_ID = 'A06A'
		private constant string BS_ORDER = "ambush"
		private integer array BS_Max_Random_Loc
		private integer array BS_Min_Enemies
		private integer array BS_Chance
		private real array BS_RADIUS
		private real array BS_AOE
		private real array BS_Cooldown
		private timer BS_Timer
		
		/* Burrow Move */
		private constant integer BM_SPELL_ID = 'A06A'
		private constant string BM_ORDER = "summonfactory"
		private integer array BM_Chance
		private integer array BM_Min_Enemies
		private integer array BM_Max_Enemies
		private real array BM_Cooldown
		private real array BM_AOE[5][2]
		private timer BM_Timer		
		
		/* Metamorphosis */
		private constant string M_ORDER = "roar"
		private integer array M_Chance
    endglobals
    
    private struct AI extends array
	
		private static method CL_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
		
		private method doBurrowStrike takes nothing returns boolean
			local boolean abilityCasted = false
			local integer i = 0
			local integer amount = 0
			local integer level = GetUnitAbilityLevel(.hero, BS_SPELL_ID) - 1
			local real x
			local real y
			local location l
			local unit u
			
			call GroupClear(enumGroup)
			
			loop
				exitwhen i >= BS_Max_Random_Loc[.aiLevel]
				set l = RandomPointCircle(GetUnitX(.hero), GetUnitY(.hero), BS_RADIUS[level]) 
				set x = GetLocationX(l)
				set y = GetLocationY(l)
				call GroupEnumUnitsInRange(enumGroup, x, y, BS_AOE[level], Filter(function thistype.CL_Filter))

				if 	(CountUnitsInGroup(enumGroup) >= BS_Min_Enemies[.aiLevel]) then
					set u = GetRandomUnitFromGroup(enumGroup)
					set x = GetUnitX(u)
					set y = GetUnitY(u)
					set abilityCasted = IssuePointOrder(.hero, BS_ORDER, x, y)
					set i = BS_Max_Random_Loc[.aiLevel]
				endif
				call GroupClear(enumGroup)
				set i = i + 1
			endloop
			
			call RemoveLocation(l)
			set l = null
			set u = null
			
			if (abilityCasted) then
				call TimerStart(BS_Timer, BS_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doBurrowMove takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, BM_SPELL_ID) - 1
			local real x = GetUnitX(.hero)
			local real y = GetUnitY(.hero)
			local integer min = 0
			local integer max = 0
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, x, y, BM_AOE[level][0], Filter(function thistype.CL_Filter))
			set min = CountUnitsInGroup(enumGroup)
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, x, y, BM_AOE[level][1], Filter(function thistype.CL_Filter))
			set max = CountUnitsInGroup(enumGroup) - min
			
			if ((min >= BM_Min_Enemies[.aiLevel]) and /*
			*/  (max >= BM_Max_Enemies[.aiLevel]))then
				set abilityCasted = IssuePointOrder(.hero, BM_ORDER, x, y)
			endif
						
			if (abilityCasted) then
				call TimerStart(BS_Timer, BS_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private static method M_Filter takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			
			if ((GetUnitTypeId(u) == 'h013') or /*
			*/  (GetUnitTypeId(u) == 'h007') or /*
			*/  (GetUnitTypeId(u) == 'h00A') or /*
			*/  (GetUnitTypeId(u) == 'h00B') or /*
			*/  (GetUnitTypeId(u) == 'h00D')) then
				set b = true
			endif

			set u = null
			
			return b
		endmethod
		
		private method doMetamorphosis takes nothing returns boolean
			local boolean abilityCasted = false
			local unit u
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRect(enumGroup, bj_mapInitialPlayableArea, Filter(function thistype.M_Filter))
			
			if (CountUnitsInGroup(enumGroup) > 0) then
				loop
					set u = FirstOfGroup(enumGroup)
					exitwhen (u == null)
					call IssueImmediateOrder(u, M_ORDER)
					call GroupRemoveUnit(enumGroup, u)
				endloop
				
				set abilityCasted = true
			endif
			
			set u = null
			
			return abilityCasted
		endmethod
		
		//TO-DO: Implement Execution for the ability "doMetamorphosis"
		method idleActions takes nothing returns nothing 
			local boolean abilityCasted = false
			
			/* Metamorphosis */
			if ((.heroLevel >= 6) and /*
			*/	(GetRandomInt(0,100) <= M_Chance[.aiLevel])) then
				set abilityCasted = doMetamorphosis()					
			endif	

			if (not abilityCasted) then
				call .move()
			endif
			
		endmethod

        method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			/* Burrow Strike */
			if 	((GetRandomInt(0,100) <= BS_Chance[.aiLevel]) and /*
			*/	(TimerGetRemaining(BS_Timer) == 0.0)) then
				set abilityCasted = doBurrowStrike()
			endif
			
			/* Burrow Move */
			if 	((GetRandomInt(0,100) <= BM_Chance[.aiLevel]) and /*
			*/	(TimerGetRemaining(BM_Timer) == 0.0)) then
				set abilityCasted = doBurrowMove()
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
		
		method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			
			// Burrow Strike
			call RegisterHeroAISkill(HERO_ID, 2, 'A06A') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A06A') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A06A') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A06A') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A06A') 
			// Burrow Move
			call RegisterHeroAISkill(HERO_ID, 3, 'A06E') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A06E') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A06E') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A06E') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A06E')
			// Carrion Swarm
			call RegisterHeroAISkill(HERO_ID, 1, 'A06F')
			call RegisterHeroAISkill(HERO_ID, 5, 'A06F') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A06F') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A06F') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A06F') 
			// Metamorphosis
			call RegisterHeroAISkill(HERO_ID, 6, 'A06H')
			call RegisterHeroAISkill(HERO_ID, 12, 'A06H')
			call RegisterHeroAISkill(HERO_ID, 18, 'A06H')
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
				call Itemsets[1].addItem('u001', FRENZY_BOOTS, 1)
				call Itemsets[1].addItem('u003', METAL_HAND, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', BLOOD_BLADE, 1)
				call Itemsets[2].addItem('u001', FRENZY_BOOTS, 1)
				call Itemsets[2].addItem('u003', RAVING_SWORD, 1)
				call Itemsets[2].addItem('u003', BONE_CHARM, 1)
			endif
			
			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Burrow Strike
			set BS_Chance[0] = 20
			set BS_Chance[1] = 30
			set BS_Chance[2] = 40
			
			// OE: Burrow Strike -> AoE (Level)
			set BS_AOE[0] = 150
			set BS_AOE[1] = 175
			set BS_AOE[2] = 200
			set BS_AOE[3] = 225
			set BS_AOE[4] = 250
			
			// OE: Burrow Strike -> Range (Level)
			set BS_RADIUS[0] = 700
			set BS_RADIUS[1] = 750
			set BS_RADIUS[2] = 800
			set BS_RADIUS[3] = 850
			set BS_RADIUS[4] = 900
			
			set BS_Min_Enemies[0] = 1
			set BS_Min_Enemies[1] = 2
			set BS_Min_Enemies[2] = 3
			
			set BS_Max_Random_Loc[0] = 5
			set BS_Max_Random_Loc[1] = 7
			set BS_Max_Random_Loc[2] = 9
			
			set BS_Timer = NewTimer()
			set BS_Cooldown[0] = 11.0
			set BS_Cooldown[1] = 11.0
			set BS_Cooldown[2] = 11.0
			set BS_Cooldown[3] = 11.0
			set BS_Cooldown[4] = 11.0
			
			// Burrow Move
			set BM_Chance[0] = 10
			set BM_Chance[1] = 15
			set BM_Chance[2] = 20
			
			set BM_Min_Enemies[0] = 5
			set BM_Min_Enemies[1] = 4
			set BM_Min_Enemies[2] = 3
			
			set BM_Max_Enemies[0] = 6
			set BM_Max_Enemies[1] = 8
			set BM_Max_Enemies[2] = 10
			
			// [0][0] == Min
			// [0][1] == Max
			set BM_AOE[0][0] = 225
			set BM_AOE[0][1] = 425
			set BM_AOE[1][0] = 250
			set BM_AOE[1][1] = 450
			set BM_AOE[2][0] = 275
			set BM_AOE[2][1] = 475
			set BM_AOE[3][0] = 300
			set BM_AOE[3][1] = 500
			set BM_AOE[4][0] = 325
			set BM_AOE[4][1] = 525
			
			set BM_Timer = NewTimer()
			set BM_Cooldown[0] = 35.0
			set BM_Cooldown[1] = 30.0
			set BM_Cooldown[2] = 25.0
			set BM_Cooldown[3] = 20.0
			set BM_Cooldown[4] = 15.0
			
			// Metamorphosis
			set M_Chance[0] = 30
			set M_Chance[1] = 35
			set M_Chance[2] = 40
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope