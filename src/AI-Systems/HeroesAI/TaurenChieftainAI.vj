scope TaurenChieftainAI
    globals
        private constant integer HERO_ID = 'O00K'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Fire Totem */
		private constant integer FT_SPELL_ID = 'A078'
		private constant string FT_ORDER = "deathanddecay"
		private constant real FT_RADIUS = 600
		private integer array FT_Chance
		private real array FT_Cooldown
		private timer FT_Timer
		private integer array FT_Min_Enemies

		/* Stomp Blaster */
		private constant integer SB_SPELL_ID = 'A079'
		private constant string SB_ORDER = "stomp"
		private constant integer SB_RADIUS = 300
		private integer array SB_Chance
		private real array SB_Cooldown
		private timer SB_Timer
		private integer array SB_Min_Enemies
		
		/* Fervor */
		private constant integer F_SPELL_ID = 'A08M'
		private constant string F_ORDER = "roar"
		private constant real F_RADIUS = 800
		private integer array F_Chance
		private real array F_Cooldown
		private timer F_Timer
		private integer array F_Min_Allies

		/* Shockwave */
		private constant integer S_SPELL_ID = 'A07C'
		private constant string S_ORDER = "blizzard"
		private constant real S_VISION_FIELD = 12
		private constant real S_DISTANCE = 800		
		private integer array S_Chance
		private real array S_Cooldown
		private timer S_Timer
		private integer array S_Min_Enemies
    endglobals
    
    private struct AI extends array
	
		private static method Tauren_Chief_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
		
		private static method Fervor_Filter takes nothing returns boolean
			return SpellHelper.isValidAlly(GetFilterUnit(), tempthis.hero)
		endmethod
        
		private method doFireTotem takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, FT_SPELL_ID) - 1
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, FT_RADIUS, Filter(function thistype.Tauren_Chief_Filter))
			
			if (CountUnitsInGroup(enumGroup) >= FT_Min_Enemies[.aiLevel]) then
				set abilityCasted = IssuePointOrder(.hero, FT_ORDER, .hx, .hy)
			endif
			
			if (abilityCasted) then
				call TimerStart(FT_Timer, FT_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doStompBlaster takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, SB_SPELL_ID) - 1
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, SB_RADIUS, Filter(function thistype.Tauren_Chief_Filter))
			
			if (CountUnitsInGroup(enumGroup) >= SB_Min_Enemies[.aiLevel]) then
				set abilityCasted = IssueImmediateOrder(.hero, SB_ORDER)
			endif
			
			if (abilityCasted) then
				call TimerStart(SB_Timer, SB_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doFervor takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, F_SPELL_ID) - 1
			
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, F_RADIUS, Filter(function thistype.Fervor_Filter))
			
			if (CountUnitsInGroup(enumGroup) >= F_Min_Allies[level]) then
				set abilityCasted = IssueImmediateOrder(.hero, F_ORDER)
			endif
			
			if (abilityCasted) then
				call TimerStart(F_Timer, F_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doShockwave takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, S_SPELL_ID) - 1
			local integer enemiesInSight = 0
			local unit u
			
			call GroupClear(enumGroup)
			call GroupAddGroup(.enemies, enumGroup)
			set .furthestEnemy = null
			loop
				set u = FirstOfGroup(enumGroup) 
				exitwhen u == null 
				if ((Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= S_DISTANCE) and /*
				*/	(IsUnitInSightOfUnit(.hero, u, S_VISION_FIELD))) then
					set enemiesInSight = enemiesInSight + 1
					
					if (.furthestEnemy == null) then
						set .furthestEnemy = u
					endif
					
					if (Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) > Distance(.hx, .hy, GetUnitX(.furthestEnemy), GetUnitY(.furthestEnemy))) then
						set .furthestEnemy = u
					endif
				endif
				call GroupRemoveUnit(enumGroup, u)
			endloop

			if (enemiesInSight >= S_Min_Enemies[.aiLevel]) then
				set abilityCasted = IssueTargetOrder(.hero, S_ORDER, .furthestEnemy)
			endif

			if (abilityCasted) then
				call TimerStart(S_Timer, S_Cooldown[level], false, null)
			endif
			
			set u = null
			
			return abilityCasted
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Fire Totem */
				if 	((GetRandomInt(0,100) <= FT_Chance[.aiLevel]) and /*
				*/	(TimerGetRemaining(FT_Timer) == 0.0)) then
					set abilityCasted = doFireTotem()
				endif
				
				/* Stomp Blaster */
				if ((GetRandomInt(0,100) <= SB_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(SB_Timer) == 0.0)) then
					set abilityCasted = doStompBlaster()
				endif
				
				/* Fervor */
				if ((GetRandomInt(0,100) <= F_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(F_Timer) == 0.0)) then
					set abilityCasted = doFervor()
				endif
				
				/* XZ */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= S_Chance[.aiLevel]) and /*
				*/  (TimerGetRemaining(S_Timer) == 0.0) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doShockwave()					
				endif
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Fire Totem
			call RegisterHeroAISkill(HERO_ID, 1, 'A078')
			call RegisterHeroAISkill(HERO_ID, 5, 'A078') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A078') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A078') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A078') 
			// Stomp Blaster
			call RegisterHeroAISkill(HERO_ID, 2, 'A079') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A079') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A079') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A079') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A079') 
			// Fervor
			call RegisterHeroAISkill(HERO_ID, 3, 'A08M') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A08M') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A08M') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A08M') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A08M') 
			// Shockwave
			call RegisterHeroAISkill(HERO_ID, 6, 'A07C')
			call RegisterHeroAISkill(HERO_ID, 12, 'A07C')
			call RegisterHeroAISkill(HERO_ID, 18, 'A07C')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
			// This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u00N', HEALING_POTION, 2)
				call Itemsets[0].addItem('u00N', MANA_POTION, 1)
				call Itemsets[0].addItem('u00O', OGRIMMAR_SHIELD, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u00N', HEALING_POTION, 4)
				call Itemsets[1].addItem('u00N', MANA_POTION, 2)
				call Itemsets[1].addItem('u00O', OGRIMMAR_SHIELD, 1)
				call Itemsets[1].addItem('u00O', MACE, 1)
				call Itemsets[1].addItem('u00P', BROAD_AXE, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u00N', HEALING_POTION, 5)
				call Itemsets[2].addItem('u00N', MANA_POTION, 3)
				call Itemsets[2].addItem('u00O', OGRIMMAR_SHIELD, 1)
				call Itemsets[2].addItem('u00O', MACE, 1)
				call Itemsets[2].addItem('u00P', BROAD_AXE, 1)
				call Itemsets[2].addItem('u00P', KODO_BOOTS, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// XW
			set FT_Chance[0] = 15
			set FT_Chance[1] = 20
			set FT_Chance[2] = 25
			
			set FT_Min_Enemies[0] = 4
			set FT_Min_Enemies[1] = 5
			set FT_Min_Enemies[2] = 6
			
			set FT_Timer = NewTimer()
			set FT_Cooldown[0] = 10.0
			set FT_Cooldown[1] = 10.0
			set FT_Cooldown[2] = 10.0
			set FT_Cooldown[3] = 10.0
			set FT_Cooldown[4] = 10.0
			
			// Stomp Blaster
			set SB_Chance[0] = 15
			set SB_Chance[1] = 20
			set SB_Chance[2] = 25
			
			set SB_Min_Enemies[0] = 3
			set SB_Min_Enemies[1] = 4
			set SB_Min_Enemies[2] = 5
			
			set SB_Timer = NewTimer()
			set SB_Cooldown[0] = 7.0
			set SB_Cooldown[1] = 7.0
			set SB_Cooldown[2] = 7.0
			set SB_Cooldown[3] = 7.0
			set SB_Cooldown[4] = 7.0
			
			// Fervor
			set F_Chance[0] = 15
			set F_Chance[1] = 20
			set F_Chance[2] = 25
			
			set F_Min_Allies[0] = 3
			set F_Min_Allies[1] = 5
			set F_Min_Allies[2] = 7
			set F_Min_Allies[3] = 9
			set F_Min_Allies[4] = 11
			
			set F_Timer = NewTimer()
			set F_Cooldown[0] = 15.0
			set F_Cooldown[1] = 15.0
			set F_Cooldown[2] = 15.0
			set F_Cooldown[3] = 15.0
			set F_Cooldown[4] = 15.0
			
			// Shockwave
			set S_Chance[0] = 15
			set S_Chance[1] = 20
			set S_Chance[2] = 25
			
			set S_Min_Enemies[0] = 2
			set S_Min_Enemies[1] = 4
			set S_Min_Enemies[2] = 6

			set S_Timer = NewTimer()
			set S_Cooldown[0] = 150.0
			set S_Cooldown[1] = 150.0
			set S_Cooldown[2] = 150.0
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope