scope AbominationAI
    globals
        private constant integer HERO_ID = 'H00G'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Cleave */
		private constant integer C_SPELL_ID = 'A064'
		private constant string C_ORDER = "roar"
		private integer array C_Chance
		private real array C_Cooldown
		private timer C_Timer

		/* Consume Himself */
		private constant integer CH_SPELL_ID = 'A06M'
		private constant integer CH_BUFF_ID = 'B00V'
		private constant string CH_ORDER = "taunt"
		private integer array CH_Chance
		private real array CH_Cooldown
		private timer CH_Timer
		private real CH_Radius = 600
		private boolean CH_isActive
		
		/* Snack */
		private constant integer S_SPELL_ID = 'A06L'
		private constant integer S_BUFF_ID = 'B00D'
		private constant string S_ORDER = "ambush"
		private constant real S_RADIUS = 200
		private integer array S_Max_Enemies
		private integer array S_Chance
		private real array S_Cooldown
		private real S_time = 0.00
		private timer S_Timer
		private boolean S_isActive
    endglobals
    
    private struct AI extends array
	
		private static method Abo_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
	
        private method doCleave takes nothing returns boolean
			local boolean abilityCasted = IssueImmediateOrder(.hero, C_ORDER)
			local integer level = GetUnitAbilityLevel(.hero, C_SPELL_ID) - 1
			
			if (abilityCasted) then
				call TimerStart(C_Timer, C_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod

		private method doConsumeHimself takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, CH_SPELL_ID) - 1
				
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, GetUnitX(.hero), GetUnitY(.hero), CH_Radius, Filter(function thistype.Abo_Filter))
			
			if (CountUnitsInGroup(enumGroup) == 0) then
				set abilityCasted = IssueImmediateOrder(.hero, CH_ORDER)
			endif
			
			if (abilityCasted) then
				call TimerStart(CH_Timer, CH_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private static method onCheckSnackIsAvtive takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local integer level = GetUnitAbilityLevel(tempthis.hero, S_SPELL_ID) - 1
			
			// Check if "Snack" is active
			set S_isActive = GetUnitAbilityLevel(tempthis.hero, S_BUFF_ID) > 0
			set S_time = S_time + .1
			if (S_time <= DEFAULT_PERIOD) then
				if (S_isActive) then
					call TimerStart(S_Timer, S_Cooldown[level], false, null)
					set S_time = .0
					call ReleaseTimer(t)
				endif
			else
				call ReleaseTimer(t)
			endif
		endmethod
		
		private method doSnack takes nothing returns boolean
			local boolean abilityCasted = false
			local timer t
			
			if (Distance(.hx, .hy, GetUnitX(.closestEnemyHero), GetUnitY(.closestEnemyHero)) <= S_RADIUS) then
				if (CountUnitsInGroup(enumGroup) <= S_Max_Enemies[.aiLevel]) then
					set abilityCasted = IssueTargetOrder(.hero, S_ORDER, .closestEnemyHero)
					set t = NewTimer()
					call TimerStart(t, .1, true, function thistype.onCheckSnackIsAvtive)
					set abilityCasted = true
				endif
			endif

			return abilityCasted
		endmethod
		
		method runActions takes nothing returns nothing
			local boolean abilityCasted = false
			
			// Check if "Consume Himself" is active
			set CH_isActive = GetUnitAbilityLevel(.hero, CH_BUFF_ID) > 0
			
			/* Consume Himself */
			if ((GetRandomInt(0,100) <= CH_Chance[.aiLevel]) and /*
			*/ (TimerGetRemaining(CH_Timer) == 0.0)) then
				set abilityCasted = doConsumeHimself()
			endif
			
			if ((not abilityCasted) and /*
			*/	(not CH_isActive))	then
				call .run()
			endif
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			local string order = OrderId2String(.orderId)
			
			// Check if "Snack" is active
			set S_isActive = GetUnitAbilityLevel(.hero, S_BUFF_ID) > 0
				
			if (.enemyNum > 0) then
				/* Cleave */
				if 	((GetRandomInt(0,100) <= C_Chance[.aiLevel]) and /*
				*/	(TimerGetRemaining(C_Timer) == 0.0)) then
					set abilityCasted = doCleave()
				endif
				
				/* Snack */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= S_Chance[.aiLevel]) and /*
				*/  (TimerGetRemaining(S_Timer) == 0.0) and /*
				*/  (.goodCondition) and /*
				*/	(not abilityCasted) and /*
				*/	(not S_isActive)) then
					set abilityCasted = doSnack()					
				endif
			endif
			
			if ((not abilityCasted) and /*
			*/	(not S_isActive))then
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
			set C_Chance[0] = 20
			set C_Chance[1] = 30
			set C_Chance[2] = 40
			
			set C_Timer = NewTimer()
			set C_Cooldown[0] = 15.0
			set C_Cooldown[1] = 15.0
			set C_Cooldown[2] = 15.0
			set C_Cooldown[3] = 15.0
			set C_Cooldown[4] = 15.0
			
			// Consume Himself
			set CH_Chance[0] = 20
			set CH_Chance[1] = 30
			set CH_Chance[2] = 40
			
			set CH_Timer = NewTimer()
			set CH_Cooldown[0] = 150.0
			set CH_Cooldown[1] = 150.0
			set CH_Cooldown[2] = 150.0
			set CH_Cooldown[3] = 150.0
			set CH_Cooldown[4] = 150.0
			
			// Snack
			set S_Chance[0] = 20
			set S_Chance[1] = 20
			set S_Chance[2] = 20
			
			set S_Max_Enemies[0] = 6
			set S_Max_Enemies[1] = 5
			set S_Max_Enemies[2] = 4
			
			set S_Timer = NewTimer()
			set S_Cooldown[0] = 60.0
			set S_Cooldown[1] = 60.0
			set S_Cooldown[2] = 60.0
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope