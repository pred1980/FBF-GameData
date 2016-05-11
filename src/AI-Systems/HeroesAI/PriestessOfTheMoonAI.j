scope PriestessOfTheMoonAI
    globals
        private constant integer HERO_ID = 'E00P'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Life Vortex */
		private constant integer LV_SPELL_ID = 'A0B5'
		private constant string LV_ORDER = "deathanddecay"
		private integer array LV_Chance
		private real array LV_Cooldown
		private timer LV_Timer
		private integer array LV_Max_Random_Loc
		private integer array LV_Min_Enemies
		private real LV_RADIUS = 700
		private real LV_AOE = 300

		/* XX */
		private constant integer XX_SPELL_ID = 'XXXX'
		private constant string XX_ORDER = "xxx"
		private integer array XX_Chance
		private real array XX_Cooldown
		private timer XX_Timer		
		
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
	
		private static method PotM_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
        
		private method doLifeVortex takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, LV_SPELL_ID) - 1
			local integer i = 0
			local real x
			local real y
			local location l
			
			call GroupClear(enumGroup)
			
			loop
				exitwhen i >= LV_Max_Random_Loc[.aiLevel]
				set l = RandomPointCircle(GetUnitX(.hero), GetUnitY(.hero), LV_RADIUS) 
				set x = GetLocationX(l)
				set y = GetLocationY(l)
				call GroupEnumUnitsInRange(enumGroup, x, y, LV_AOE, Filter(function thistype.PotM_Filter))
			
				if (CountUnitsInGroup(enumGroup) >= LV_Min_Enemies[.aiLevel]) then
					set abilityCasted = IssuePointOrder(.hero, LV_ORDER, x, y)
					set i = LV_Max_Random_Loc[.aiLevel]
				endif
				call GroupClear(enumGroup)
				set i = i + 1
			endloop
			
			call RemoveLocation(l)
			set l = null
			
			if (abilityCasted) then
				call TimerStart(LV_Timer, LV_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doXX takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, XX_SPELL_ID) - 1
			
			if (abilityCasted) then
				call TimerStart(XX_Timer, XX_Cooldown[level], false, null)
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
				/* XW */
				if 	((GetRandomInt(0,100) <= LV_Chance[.aiLevel]) and /*
				*/	(TimerGetRemaining(LV_Timer) == 0.0)) then
					set abilityCasted = doLifeVortex()
				endif
				
				/* XX */
				if ((GetRandomInt(0,100) <= XX_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(XX_Timer) == 0.0)) then
					set abilityCasted = doXX()
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
			// Life Vortex
			call RegisterHeroAISkill(HERO_ID, 1, 'A0B5')
			call RegisterHeroAISkill(HERO_ID, 5, 'A0B5') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A0B5') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A0B5') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A0B5') 
			// Moon Light
			call RegisterHeroAISkill(HERO_ID, 2, 'A07F') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A07F') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A07F') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A07F') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A07F') 
			// Night Aura
			call RegisterHeroAISkill(HERO_ID, 3, 'A07G') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A07G') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A07G') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A07G') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A07G') 
			// Revenge Owl
			call RegisterHeroAISkill(HERO_ID, 6, 'A07H')
			call RegisterHeroAISkill(HERO_ID, 12, 'A07H')
			call RegisterHeroAISkill(HERO_ID, 18, 'A07H')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
			// This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u00H', HEALING_POTION, 2)
				call Itemsets[0].addItem('u00H', MANA_POTION, 1)
				call Itemsets[0].addItem('u00I', SUN_BOW, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u00H', HEALING_POTION, 4)
				call Itemsets[1].addItem('u00H', MANA_POTION, 2)
				call Itemsets[1].addItem('u00I', SUN_BOW, 1)
				call Itemsets[1].addItem('u00I', ANCIENT_SHIELD, 1)
				call Itemsets[1].addItem('u00J', DAWN_BOW, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u00H', HEALING_POTION, 5)
				call Itemsets[2].addItem('u00H', MANA_POTION, 3)
				call Itemsets[2].addItem('u00I', SUN_BOW, 1)
				call Itemsets[2].addItem('u00I', ANCIENT_SHIELD, 1)
				call Itemsets[2].addItem('u00J', DAWN_BOW, 1)
				call Itemsets[2].addItem('u00J', EMERALD_SWORD, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// XW
			set LV_Chance[0] = 10
			set LV_Chance[1] = 20
			set LV_Chance[2] = 30
			
			set LV_Max_Random_Loc[0] = 5
			set LV_Max_Random_Loc[1] = 7
			set LV_Max_Random_Loc[2] = 9
			
			set LV_Min_Enemies[0] = 3
			set LV_Min_Enemies[1] = 5
			set LV_Min_Enemies[2] = 7
			
			set LV_Timer = NewTimer()
			set LV_Cooldown[0] = 12.0
			set LV_Cooldown[1] = 12.0
			set LV_Cooldown[2] = 12.0
			set LV_Cooldown[3] = 12.0
			set LV_Cooldown[4] = 12.0
			
			// XX
			set XX_Chance[0] = 10
			set XX_Chance[1] = 20
			set XX_Chance[2] = 20
			
			set XX_Timer = NewTimer()
			set XX_Cooldown[0] = 150.0
			set XX_Cooldown[1] = 150.0
			set XX_Cooldown[2] = 150.0
			set XX_Cooldown[3] = 150.0
			set XX_Cooldown[4] = 150.0
			
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
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope