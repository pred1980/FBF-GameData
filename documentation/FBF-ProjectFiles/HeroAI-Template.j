scope TemplateHeroAI
    globals
        private constant integer HERO_ID = 'U01P'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* XW */
		private constant integer XW_SPELL_ID = 'XWXW'
		private constant string XW_ORDER = "xxx"
		private integer array XW_Chance
		private real array XW_Cooldown
		private timer XW_Timer

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
	
		private method doXW takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, XW_SPELL_ID) - 1
			
			if (abilityCasted) then
				call TimerStart(XW_Timer, XW_Cooldown[level], false, null)
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
				if 	((GetRandomInt(0,100) <= XW_Chance[.aiLevel]) and /*
				*/	(TimerGetRemaining(XW_Timer) == 0.0)) then
					set abilityCasted = doXW()
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
			// Plague Infection
			call RegisterHeroAISkill(HERO_ID, 3, 'A054') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A054') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A054') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A054') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A054')
			
			// Spawn Zombies
			call RegisterHeroAISkill(HERO_ID, 1, 'A058')
			call RegisterHeroAISkill(HERO_ID, 5, 'A058') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A058') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A058') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A058')
			
			// Soul Extraction
			call RegisterHeroAISkill(HERO_ID, 2, 'A056') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A056') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A056') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A056') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A056') 
			 
			// Call of the Damned
			call RegisterHeroAISkill(HERO_ID, 6, 'A05B')
			call RegisterHeroAISkill(HERO_ID, 12, 'A05B')
			call RegisterHeroAISkill(HERO_ID, 18, 'A05B')
			
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('xxxx', HEALING_POTION, 2)
				call Itemsets[0].addItem('xxxx', MANA_POTION, 1)
				call Itemsets[0].addItem('yyyy', YYYY, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('xxxx', HEALING_POTION, 4)
				call Itemsets[1].addItem('xxxx', MANA_POTION, 2)
				call Itemsets[1].addItem('yyyy', YYYY, 1)
				call Itemsets[1].addItem('yyyy', YYYY, 1)
				call Itemsets[1].addItem('zzzz', ZZZZ, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('xxxx', HEALING_POTION, 5)
				call Itemsets[2].addItem('xxxx', MANA_POTION, 3)
				call Itemsets[2].addItem('yyyy', YYYY, 1)
				call Itemsets[2].addItem('yyyy', YYYY, 1)
				call Itemsets[2].addItem('zzzz', ZZZZ, 1)
				call Itemsets[2].addItem('zzzz', ZZZZ, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// XW
			set XW_Chance[0] = 10
			set XW_Chance[1] = 20
			set XW_Chance[2] = 20
			
			set XW_Timer = NewTimer()
			set XW_Cooldown[0] = 150.0
			set XW_Cooldown[1] = 150.0
			set XW_Cooldown[2] = 150.0
			set XW_Cooldown[3] = 150.0
			set XW_Cooldown[4] = 150.0
			
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