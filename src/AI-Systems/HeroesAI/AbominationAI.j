scope AbominationAI
    globals
        private constant integer HERO_ID = 'H00G'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Cleave */
		private constant integer C_SPELL_ID = 'A064'
		private constant string C_ORDER = "roar"
		// Chance to cast ability
		private integer array C_Chance
		private real array C_Cooldown
		private timer C_Timer

		/* Consume Himself */
		private constant integer CH_SPELL_ID = 'A06M'
		private constant string CH_ORDER = "taunt"
		// Chance to cast ability
		private integer array CH_Chance
		private real array CH_Cooldown
		private timer CH_Timer
		private real CH_Radius = 750
		private integer array CH_HeroHP
		
		/* XY */
		private constant integer XY_SPELL_ID = 'XYXY'
		private constant string XY_ORDER = "xxx"
		// Chance to cast ability
		private integer array XY_Chance
		private real array XY_Cooldown
		private timer XY_Timer		

		/* XZ */
		private constant integer XZ_SPELL_ID = 'XZXZ'
		private constant string XZ_ORDER = "xxx"
		// Chance to cast ability
		private integer array XZ_Chance
		private real array XZ_Cooldown
		private timer XZ_Timer
    endglobals
    
    private struct AI extends array
	
        private method doCleave takes nothing returns boolean
			local boolean abilityCasted = IssueImmediateOrder(.hero, C_ORDER)
			local integer level = GetUnitAbilityLevel(.hero, C_SPELL_ID) - 1
			
			if (abilityCasted) then
				call TimerStart(C_Timer, C_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private static method CH_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
		
		private method doConsumeHimself takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, CH_SPELL_ID) - 1
				
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, GetUnitX(.hero), GetUnitY(.hero), CH_Radius, Filter(function thistype.CH_Filter))
			
			call BJDebugMsg("Anzahl: " + I2S(CountUnitsInGroup(enumGroup)))
			if ((CountUnitsInGroup(enumGroup) == 0) and /*
			*/	(GetUnitLifePercent(.hero) <= CH_HeroHP[.aiLevel])) then
				set abilityCasted = IssueImmediateOrder(.hero, CH_ORDER)
			endif
			
			if (abilityCasted) then
				call TimerStart(CH_Timer, CH_Cooldown[level], false, null)
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
		
		method runActions takes nothing returns nothing
			local boolean abilityCasted = false
			
			/* Consume Himself */
			if ((GetRandomInt(0,100) <= CH_Chance[.aiLevel]) and /*
			*/ (TimerGetRemaining(CH_Timer) == 0.0)) then
				set abilityCasted = doConsumeHimself()
			endif
			
			if (not abilityCasted) then
				call .run()
			endif
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			/* Cleave */
			if 	((GetRandomInt(0,100) <= C_Chance[.aiLevel]) and /*
			*/	(TimerGetRemaining(C_Timer) == 0.0)) then
				set abilityCasted = doCleave()
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

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Cleave
			call RegisterHeroAISkill(HERO_ID, 1, 'A064')
			call RegisterHeroAISkill(HERO_ID, 5, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A064') 
			// Consume Himself
			call RegisterHeroAISkill(HERO_ID, 2, 'A06M') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A06M') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A06M') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A06M') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A06M') 
			// Plague Cloud
			call RegisterHeroAISkill(HERO_ID, 3, 'A06G') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A06G') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A06G') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A06G') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A06G') 
			// Snack
			call RegisterHeroAISkill(HERO_ID, 6, 'A06L')
			call RegisterHeroAISkill(HERO_ID, 12, 'A06L')
			call RegisterHeroAISkill(HERO_ID, 18, 'A06L')
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
				call Itemsets[1].addItem('u001', TWIN_AXE, 1)
				call Itemsets[1].addItem('u003', RAVING_SWORD, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', DARK_PLATES, 1)
				call Itemsets[2].addItem('u001', TWIN_AXE, 1)
				call Itemsets[2].addItem('u003', MORNING_STAR, 1)
				call Itemsets[2].addItem('u003', BONE_CHARM, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Cleave
			set C_Chance[0] = 10
			set C_Chance[1] = 20
			set C_Chance[2] = 30
			
			set C_Timer = NewTimer()
			set C_Cooldown[0] = 15.0
			set C_Cooldown[1] = 15.0
			set C_Cooldown[2] = 15.0
			set C_Cooldown[3] = 15.0
			set C_Cooldown[4] = 15.0
			
			// Consume Himself
			set CH_Chance[0] = 10
			set CH_Chance[1] = 20
			set CH_Chance[2] = 30
			
			set CH_HeroHP[0] = 30
			set CH_HeroHP[1] = 35
			set CH_HeroHP[2] = 40
			
			set CH_Timer = NewTimer()
			set CH_Cooldown[0] = 150.0
			set CH_Cooldown[1] = 150.0
			set CH_Cooldown[2] = 150.0
			set CH_Cooldown[3] = 150.0
			set CH_Cooldown[4] = 150.0
			
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