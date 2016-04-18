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
		
		/* XY */
		private constant integer XY_SPELL_ID = 'XYXY'
		private constant string XY_ORDER = "xxx"
		private integer array XY_Chance
		private real array XY_Cooldown
		private timer XY_Timer		

		/* XZ */
		private constant integer XZ_SPELL_ID = 'XZXZ'
		private constant string XZ_ORDER = "xxx"
		private integer array XZ_Chance
		private real array XZ_Cooldown
		private timer XZ_Timer
    endglobals
    
    private struct AI extends array
	
		private static method VB_Filter takes nothing returns boolean
			return SpellHelper.isValidAlly(GetFilterUnit(), tempthis.hero)
		endmethod
	
        private method doVampireBlood takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, VB_SPELL_ID) - 1
			local integer i = 0
			local unit u
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
			
				if 	(CountUnitsInGroup(enumGroup) >= VB_Min_Enemies[level]) then
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
		
		private method doPurify takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, P_SPELL_ID) - 1
			
			
			
			
			if (abilityCasted) then
				call TimerStart(P_Timer, P_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doXY takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, XY_SPELL_ID) - 1
			
			if (abilityCasted) then
				call TimerStart(XY_Timer, XY_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doXZ takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, XZ_SPELL_ID) - 1
			
			if (abilityCasted) then
				call TimerStart(XZ_Timer, XZ_Cooldown[level], false, null)
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
				
				/* XY */
				if ((GetRandomInt(0,100) <= XY_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(XY_Timer) == 0.0)) then
					set abilityCasted = doXY()
				endif
				
				/* XZ */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= XZ_Chance[.aiLevel]) and /*
				*/  (TimerGetRemaining(XZ_Timer) == 0.0) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doXZ()					
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
			call RegisterHeroAISkill(HERO_ID, 1, 'A06V')
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
			call RegisterHeroAISkill(HERO_ID, 3, 'A06X') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A06X') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A06X') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A06X') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A06X') 
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
			set VB_Chance[0] = 25
			set VB_Chance[1] = 35
			set VB_Chance[2] = 45
			
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
			set P_Chance[1] = 20
			set P_Chance[2] = 20
			
			set P_Timer = NewTimer()
			set P_Cooldown[0] = 150.0
			set P_Cooldown[1] = 150.0
			set P_Cooldown[2] = 150.0
			set P_Cooldown[3] = 150.0
			set P_Cooldown[4] = 150.0
			
			// XY
			set XY_Chance[0] = 10
			set XY_Chance[1] = 20
			set XY_Chance[2] = 20
			
			set XY_Timer = NewTimer()
			set XY_Cooldown[0] = 150.0
			set XY_Cooldown[1] = 150.0
			set XY_Cooldown[2] = 150.0
			set XY_Cooldown[3] = 150.0
			set XY_Cooldown[4] = 150.0
			
			// XZ
			set XZ_Chance[0] = 10
			set XZ_Chance[1] = 20
			set XZ_Chance[2] = 20
			
			set XZ_Timer = NewTimer()
			set XZ_Cooldown[0] = 150.0
			set XZ_Cooldown[1] = 150.0
			set XZ_Cooldown[2] = 150.0
			set XZ_Cooldown[3] = 150.0
			set XZ_Cooldown[4] = 150.0

        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope