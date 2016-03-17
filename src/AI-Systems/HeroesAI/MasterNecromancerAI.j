scope MasterNecromancerAI
    globals
        private constant integer HERO_ID = 'U01Q'
		
		private HeroAI_Itemset array Itemsets	
        private group enumGroup = CreateGroup()
		
		/* Necromancy */
		private constant integer N_SPELL_ID = 'A05D'
		private constant string N_ORDER = "summonfactory"
		private constant real N_AOE = 600
		private constant real N_RADIUS = 250
		private timer N_Timer
		private real array N_Cooldown
		private integer array N_Chance
		private integer array N_Max_Corpse
		private integer array N_Max_Random_Loc

		/* Malicious Curse */
		private constant integer MC_SPELL_ID = 'A09N'
		private constant string MC_ORDER = "ambush"
		private constant string MC_SWITCH_ORDER_1 = "immolation"
		private constant string MC_SWITCH_ORDER_2 = "unimmolation"
		private constant real MC_RADIUS = 350
		// Chance to cast ability
		private integer array MC_Chance
		private integer array MC_Random_Enemies
		private boolean MC_isHP = true
		private real array MC_Cooldown
		private timer MC_Timer
		
		/* Despair */
		private constant integer D_SPELL_ID = 'A068'
		private constant string D_ORDER = "spiritlink"
		private constant real D_RADIUS = 350
		// Chance to cast ability
		private integer array D_Chance
		private integer array D_Min_Targets
		private integer array D_Max_Random_Units
		private real array D_Cooldown
		private timer D_Timer
		
		/* Dead Souls */
		private constant integer DS_SPELL_ID = 'A08Z'
		private constant string DS_ORDER = "acidbomb"
		private constant real DS_RADIUS = 750
		// Chance to cast ability
		private integer array DS_Chance
		private integer array DS_Min_Targets
		private real array DS_Cooldown
		private timer DS_Timer
    endglobals
	
    private struct AI extends array
	
		private static method onCooldownEnd takes nothing returns nothing
			call ReleaseTimer(GetExpiredTimer())
		endmethod
	
		private static method corpseFilter takes nothing returns boolean
			return SpellHelper.isUnitDead(GetFilterUnit())
		endmethod
	
		private method doNecromancy takes nothing returns boolean
			local boolean abilityCasted = false
			local integer i = 0
			local integer amount = 0
			local integer level = GetUnitAbilityLevel(.hero, N_SPELL_ID) - 1
			local real x
			local real y
			local location l
			
			call GroupClear(enumGroup)
			
			if (CountUnitsInGroup(.deads) > 0) then
				loop
					exitwhen i >= N_Max_Random_Loc[.aiLevel]
					set l = RandomPointCircle(GetUnitX(.hero), GetUnitY(.hero), N_AOE) 
					set x = GetLocationX(l)
					set y = GetLocationY(l)
					call GroupEnumUnitsInRange(enumGroup, x, y, N_RADIUS, Filter(function thistype.corpseFilter))
					
					set amount = CountUnitsInGroup(enumGroup)
					if 	((amount <= N_Max_Corpse[.aiLevel]) and /*
					*/	(amount > 0)) then
						set abilityCasted = IssuePointOrder(.hero, N_ORDER, x, y)
						set i = N_Max_Random_Loc[.aiLevel]
					endif
					call GroupClear(enumGroup)
					set i = i + 1
				endloop
			endif
			
			call RemoveLocation(l)
			set l = null
			
			if (abilityCasted) then
				call TimerStart(N_Timer, N_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private static method MN_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
		
		private method doMaliciousCurse takes nothing returns boolean
			local boolean abilityCasted = false
			local integer amountOfEnemiesWithMana = 0
			local integer amountOfEnemiesWithoutMana = 0
			local integer level = GetUnitAbilityLevel(.hero, MC_SPELL_ID) - 1
			local unit enemy
			local unit target
			
			call GroupClear(enumGroup)
			call GroupClear(ENUM_GROUP)
			call GroupAddGroup(.enemies, ENUM_GROUP)
			
			loop
				set enemy = FirstOfGroup(ENUM_GROUP)
				exitwhen ((enemy == null) or ((amountOfEnemiesWithMana + amountOfEnemiesWithoutMana) >= MC_Random_Enemies[.aiLevel]))
				set amountOfEnemiesWithMana = 0
				set amountOfEnemiesWithoutMana = 0
				
				call GroupEnumUnitsInRange(enumGroup, GetUnitX(enemy), GetUnitY(enemy), MC_RADIUS, Filter(function thistype.MN_Filter))
				loop
					set target = FirstOfGroup(enumGroup)
					exitwhen (target == null)
					if (GetUnitManaPercent(target) > 0.00) then
						set amountOfEnemiesWithMana = amountOfEnemiesWithMana + 1
					else
						set amountOfEnemiesWithoutMana = amountOfEnemiesWithoutMana + 1
					endif

					if ((amountOfEnemiesWithMana + amountOfEnemiesWithoutMana) >= MC_Random_Enemies[.aiLevel]) then
						call GroupClear(ENUM_GROUP)
						call GroupClear(enumGroup)
						
						// check how many units with and without mana are currently around the hero
						if (amountOfEnemiesWithMana > amountOfEnemiesWithoutMana) then
							// switch to Mana							
							if (MC_isHP) then
								set MC_isHP = false
								call IssueImmediateOrder( .hero, MC_SWITCH_ORDER_1 )
							endif
						else
							// switch to HP
							if (not MC_isHP) then
								set MC_isHP = true
								call IssueImmediateOrder( .hero, MC_SWITCH_ORDER_2 )
							endif
						endif
						set abilityCasted = IssueTargetOrder(.hero, MC_ORDER, target)
					endif
					call GroupRemoveUnit(enumGroup, target)
				endloop
				call GroupRemoveUnit(ENUM_GROUP, enemy)
			endloop
			
			call GroupClear(ENUM_GROUP)
			set enemy = null
			set target = null
			
			if (abilityCasted) then
				call TimerStart(MC_Timer, MC_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doDespair takes nothing returns boolean
			local boolean abilityCasted = false
			local integer i = 0
			local integer level = GetUnitAbilityLevel(.hero, D_SPELL_ID) - 1
			local unit enemy
			
			call GroupClear(enumGroup)
			call GroupClear(ENUM_GROUP)
			call GroupAddGroup(.enemies, ENUM_GROUP)
			
			loop
				set enemy = GetRandomUnitFromGroup(ENUM_GROUP)
				exitwhen ((enemy == null) or (i >= D_Max_Random_Units[.aiLevel]))
				call GroupEnumUnitsInRange(enumGroup, GetUnitX(enemy), GetUnitY(enemy), D_RADIUS, Filter(function thistype.MN_Filter))
				
				if (CountUnitsInGroup(enumGroup) >= D_Min_Targets[.aiLevel]) then
					set abilityCasted = IssueTargetOrder(.hero, D_ORDER, enemy)
					call GroupClear(ENUM_GROUP)
				endif
				
				call GroupClear(enumGroup)
				call GroupRemoveUnit(ENUM_GROUP, enemy)
				set i = i + 1
			endloop

			set enemy = null
			
			if (abilityCasted) then
				call TimerStart(D_Timer, D_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doDeadSouls takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, DS_SPELL_ID) - 1
			
			if (CountUnitsInGroup(.enemies) >= DS_Min_Targets[.aiLevel]) then
				set abilityCasted = IssueImmediateOrder(.hero, DS_ORDER)
			endif
			
			if (abilityCasted) then
				call TimerStart(DS_Timer, DS_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
        
        method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			/* Necromancy */
			if 	((GetRandomInt(0,100) <= N_Chance[.aiLevel]) and /*
			*/	(TimerGetRemaining(N_Timer) == 0.0)) then
				set abilityCasted = doNecromancy()
			endif
			
			/* Malicious Curse */
			if ((GetRandomInt(0,100) <= MC_Chance[.aiLevel]) and /*
			*/ (not abilityCasted) and /*
			*/ (TimerGetRemaining(MC_Timer) == 0.0)) then
				set abilityCasted = doMaliciousCurse()
			endif
			
			/* Despair */
			if ((GetRandomInt(0,100) <= D_Chance[.aiLevel]) and /*
			*/ (not abilityCasted) and /*
			*/ (TimerGetRemaining(D_Timer) == 0.0)) then
				set abilityCasted = doDespair()
			endif
			
			/* Dead Souls */
			if ((.heroLevel >= 6) and /*
			*/	(GetRandomInt(0,100) <= DS_Chance[.aiLevel]) and /*
			*/  (TimerGetRemaining(DS_Timer) == 0.0) and /*
			*/	(not abilityCasted)) then
				set abilityCasted = doDeadSouls()					
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Necromancy
			call RegisterHeroAISkill(HERO_ID, 1, 'A05D')
			call RegisterHeroAISkill(HERO_ID, 5, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A05D') 
			// Malicious Curse
			call RegisterHeroAISkill(HERO_ID, 2, 'A09N') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A09N') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A09N') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A09N') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A09N') 
			// Despair
			call RegisterHeroAISkill(HERO_ID, 3, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A068') 
			// Dead Souls
			call RegisterHeroAISkill(HERO_ID, 6, 'A08Z')
			call RegisterHeroAISkill(HERO_ID, 12, 'A08Z')
			call RegisterHeroAISkill(HERO_ID, 18, 'A08Z')
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
				call Itemsets[1].addItem('u001', BONE_HELMET, 1)
				call Itemsets[1].addItem('u003', DEMONIC_AMULET, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', DARK_PLATES, 1)
				call Itemsets[2].addItem('u001', BONE_HELMET, 1)
				call Itemsets[2].addItem('u003', ARCANE_FLARE, 1)
				call Itemsets[2].addItem('u003', NECROMANCERS_ROBE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Necromancy
			set N_Chance[0] = 20
			set N_Chance[1] = 30
			set N_Chance[2] = 40
			
			set N_Timer = NewTimer()
			set N_Cooldown[0] = 25.0
			set N_Cooldown[1] = 25.0
			set N_Cooldown[2] = 25.0
			set N_Cooldown[3] = 25.0
			set N_Cooldown[4] = 25.0
			
			// Necromancy.j -> MAX_SKELETON = 3
			set N_Max_Corpse[0] = 3
			set N_Max_Corpse[1] = 2
			set N_Max_Corpse[2] = 1
			
			set N_Max_Random_Loc[0] = 2
			set N_Max_Random_Loc[1] = 4
			set N_Max_Random_Loc[2] = 6
			
			// Malicious Curse
			set MC_Chance[0] = 20
			set MC_Chance[1] = 20
			set MC_Chance[2] = 20
			
			// check up to ...
			set MC_Random_Enemies[0] = 3
			set MC_Random_Enemies[1] = 6
			set MC_Random_Enemies[2] = 9
			
			set MC_Timer = NewTimer()
			set MC_Cooldown[0] = 18.0
			set MC_Cooldown[1] = 18.0
			set MC_Cooldown[2] = 18.0
			set MC_Cooldown[3] = 18.0
			set MC_Cooldown[4] = 18.0
			
			// Despair
			set D_Chance[0] = 5
			set D_Chance[1] = 10
			set D_Chance[2] = 15
			
			// check max random units...
			set D_Max_Random_Units[0] = 2
			set D_Max_Random_Units[1] = 4
			set D_Max_Random_Units[2] = 6
			
			// cast only if reached min targets
			set D_Min_Targets[0] = 3
			set D_Min_Targets[1] = 5
			set D_Min_Targets[2] = 7
			
			set D_Timer = NewTimer()
			set D_Cooldown[0] = 15.0
			set D_Cooldown[1] = 15.0
			set D_Cooldown[2] = 15.0
			set D_Cooldown[3] = 15.0
			set D_Cooldown[4] = 15.0
			
			// Dead Souls
			set DS_Chance[0] = 15
			set DS_Chance[1] = 20
			set DS_Chance[2] = 25
			
			// cast only if reached min targets
			set DS_Min_Targets[0] = 5
			set DS_Min_Targets[1] = 8
			set DS_Min_Targets[2] = 11
			
			set DS_Timer = NewTimer()
			set DS_Cooldown[0] = 150.0
			set DS_Cooldown[1] = 150.0
			set DS_Cooldown[2] = 150.0
			set DS_Cooldown[3] = 150.0
			set DS_Cooldown[4] = 150.0
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope