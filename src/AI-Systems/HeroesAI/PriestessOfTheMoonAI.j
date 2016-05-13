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

		/* Moonlight */
		private constant integer M_SPELL_ID = 'A07E'
		private constant string M_ORDER = "blizzard"
		private integer array M_Chance
		private real array M_Cooldown
		private timer M_Timer		
		private real M_RADIUS = 600
		private integer array M_Min_Allies
		private integer array M_Min_Enemies

		/* Revenge Owl */
		private constant integer RO_SPELL_ID = 'A07F'
		private constant string RO_ORDER = "dispel"
		private constant real RO_VISION_FIELD = 15
		private constant real RO_DISTANCE = 700
		private integer array RO_Chance
		private real array RO_Cooldown
		private timer RO_Timer
		private integer array RO_Min_Enemies
    endglobals
    
    private struct AI extends array
	
		private static method PotM_Filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
		
		private static method Moonlight_Filter takes nothing returns boolean
			return SpellHelper.isValidAlly(GetFilterUnit(), tempthis.hero)
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
		
		private method doMoonlight takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, M_SPELL_ID) - 1
			
			// Allies
			call GroupClear(enumGroup)
			call GroupEnumUnitsInRange(enumGroup, .hx, .hy, M_RADIUS, Filter(function thistype.Moonlight_Filter))
			// Enemies
			call GroupClear(ENUM_GROUP)
			call GroupEnumUnitsInRange(ENUM_GROUP, .hx, .hy, M_RADIUS, Filter(function thistype.PotM_Filter))
			
			if ((CountUnitsInGroup(enumGroup) >= M_Min_Allies[.aiLevel]) and /*
			*/	(CountUnitsInGroup(ENUM_GROUP) >= M_Min_Enemies[.aiLevel])) then
				set abilityCasted = IssuePointOrder(.hero, M_ORDER, .hx, .hy)
			endif
			
			if (abilityCasted) then
				call TimerStart(M_Timer, M_Cooldown[level], false, null)
			endif
			
			return abilityCasted
		endmethod
		
		private method doRevengeOwl takes nothing returns boolean
			local boolean abilityCasted = false
			local integer level = GetUnitAbilityLevel(.hero, RO_SPELL_ID) - 1
			local integer enemiesInSight = 0
			local unit u
			
			call GroupClear(enumGroup)
			call GroupAddGroup(.enemies, enumGroup)
			set .furthestEnemy = null
			loop
				set u = FirstOfGroup(enumGroup) 
				exitwhen u == null 
				if ((Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= RO_DISTANCE) and /*
				*/	(IsUnitInSightOfUnit(.hero, u, RO_VISION_FIELD))) then
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

			if (enemiesInSight >= RO_Min_Enemies[.aiLevel]) then
				set abilityCasted = IssuePointOrder(.hero, RO_ORDER, GetUnitX(.furthestEnemy), GetUnitY(.furthestEnemy))
			endif

			if (abilityCasted) then
				call TimerStart(RO_Timer, RO_Cooldown[level], false, null)
			endif
			
			set u = null
			
			return abilityCasted
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Life Vortex */
				if 	((GetRandomInt(0,100) <= LV_Chance[.aiLevel]) and /*
				*/	(TimerGetRemaining(LV_Timer) == 0.0)) then
					set abilityCasted = doLifeVortex()
				endif
				
				/* Moonlight */
				if ((GetRandomInt(0,100) <= M_Chance[.aiLevel]) and /*
				*/ (not abilityCasted) and /*
				*/ (TimerGetRemaining(M_Timer) == 0.0)) then
					set abilityCasted = doMoonlight()
				endif
				
				/* Revenge Owl */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= RO_Chance[.aiLevel]) and /*
				*/  (TimerGetRemaining(RO_Timer) == 0.0) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doRevengeOwl()					
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
			call RegisterHeroAISkill(HERO_ID, 2, 'A07E') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A07E') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A07E') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A07E') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A07E') 
			// Night Aura
			call RegisterHeroAISkill(HERO_ID, 3, 'A07G') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A07G') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A07G') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A07G') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A07G') 
			// Revenge Owl
			call RegisterHeroAISkill(HERO_ID, 6, 'A07F')
			call RegisterHeroAISkill(HERO_ID, 12, 'A07F')
			call RegisterHeroAISkill(HERO_ID, 18, 'A07F')
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
			// Life Vortex
			set LV_Chance[0] = 15
			set LV_Chance[1] = 20
			set LV_Chance[2] = 25
			
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
			
			// Moonlight
			set M_Chance[0] = 25
			set M_Chance[1] = 30
			set M_Chance[2] = 40
			
			set M_Min_Allies[0] = 5
			set M_Min_Allies[1] = 7
			set M_Min_Allies[2] = 9
			
			set M_Min_Enemies[0] = 4
			set M_Min_Enemies[1] = 6
			set M_Min_Enemies[2] = 8
			
			set M_Timer = NewTimer()
			set M_Cooldown[0] = 30.0
			set M_Cooldown[1] = 30.0
			set M_Cooldown[2] = 30.0
			set M_Cooldown[3] = 30.0
			set M_Cooldown[4] = 30.0
			
			// Revenge Owl
			set RO_Chance[0] = 20
			set RO_Chance[1] = 30
			set RO_Chance[2] = 35
			
			set RO_Min_Enemies[0] = 3
			set RO_Min_Enemies[1] = 5
			set RO_Min_Enemies[2] = 7
			
			set RO_Timer = NewTimer()
			set RO_Cooldown[0] = 135.0
			set RO_Cooldown[1] = 145.0
			set RO_Cooldown[2] = 155.0
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope