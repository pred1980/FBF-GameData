scope IceAvatarAI
    globals
        private constant integer HERO_ID = 'U004'
		
		private HeroAI_Itemset array Itemsets
		
		/* Ice Tornado */
		private constant string IT_ORDER = "spellshield"
		// This constant must be the sum of AOE_RANGE + CRCL_RADIUS in the IceTornado.j
		private constant integer IT_RADIUS = 200
		// How many units have to be in radius to cast Ice Tornado?
		private integer array IT_Enemies
		// Chance to cast ability
		private integer array IT_Chance
		// min percent hp to cast ability
		private real array IT_MIN_HP
		
		/* Freezing Breath */
		private constant string FB_ORDER = "chemicalrage"
		// Chance to cast ability
		private integer array FB_Chance
		private integer array FB_Random
		private integer array FB_Enemies
		// Radius for each random unit (have to be the same like in the FreezingBreath.j)
		private constant integer FB_RADIUS = 350
		
		/* Fog of Death */
		private constant string FOD_ORDER = "cloudoffog"
		// This constant have to be the same like in the FogOfDeath.j
		private constant integer FOD_RADIUS = 700
		// Chance to cast ability
		private integer array FOD_Chance
		private integer array FOD_Enemies
    endglobals
	
	private struct AI extends array
		
		method assaultEnemy takes nothing returns nothing  
			local boolean abilityCasted = false
			local unit u
			
			// Ice Tornado
			local integer amountOfNearEnemies = 0
			
			// Freezing Breath
			local group FB_groupRandomUnits = CreateGroup()
			local unit FB_randomUnit
			local integer FB_index = 0
			
			if (.enemyNum > 0) then
				/* Ice Tornado */
				if ((GetRandomInt(0,100) <= IT_Chance[.aiLevel]) and /*
				*/	(.percentLife >= IT_MIN_HP[.aiLevel])) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					
					loop
						set u = FirstOfGroup(ENUM_GROUP) 
						exitwhen u == null 
						if ((Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= IT_RADIUS) and /*
						*/	(IsUnitType(u, UNIT_TYPE_GROUND))) then
							set amountOfNearEnemies = amountOfNearEnemies + 1
						endif
						call GroupRemoveUnit(ENUM_GROUP, u)
					endloop
					
					// cast tornado only if enough enemies around and in the distance to the Ice Avatar
					if (amountOfNearEnemies >= IT_Enemies[.aiLevel]) then
						set abilityCasted = IssueImmediateOrder(.hero, IT_ORDER)
					endif
				endif
				
				/* Freezing Breath */
				// Pick x Random Units and check how many enemies are around it, if enough... cast spell!
				if ((GetRandomInt(0,100) <= FB_Chance[.aiLevel]) and not abilityCasted) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					
					loop
						exitwhen ((FB_index == FB_Random[.aiLevel]) or (amountOfNearEnemies >= FB_Enemies[.aiLevel]))
						set amountOfNearEnemies = 0
						set u = GetRandomUnitFromGroup(ENUM_GROUP) 
						call GroupEnumUnitsInRange(FB_groupRandomUnits, GetUnitX(u), GetUnitY(u), FB_RADIUS, null)
						
						loop
							set FB_randomUnit = FirstOfGroup(FB_groupRandomUnits)
							exitwhen FB_randomUnit == null
							if (SpellHelper.isValidEnemy(FB_randomUnit, .hero)) then
								set amountOfNearEnemies = amountOfNearEnemies + 1
							endif
							call GroupRemoveUnit(FB_groupRandomUnits, FB_randomUnit)
						endloop
						
						set FB_index = FB_index + 1
					endloop
					
					call DestroyGroup(FB_groupRandomUnits)
					set FB_groupRandomUnits = null
					
					if (amountOfNearEnemies >= FB_Enemies[.aiLevel]) then
						set abilityCasted = IssueTargetOrder(.hero, FB_ORDER, u)
					endif
				endif
				
				/* Fog of Death */
				// Pick x Random Units and check how many enemies are around it, if enough... cast spell!
				if ((GetRandomInt(0,100) <= FOD_Chance[.aiLevel]) and not abilityCasted) then
					set amountOfNearEnemies = 0
					
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					
					loop
						set u = FirstOfGroup(ENUM_GROUP) 
						exitwhen u == null 
						if (Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= FOD_RADIUS) then
							set amountOfNearEnemies = amountOfNearEnemies + 1
						endif
						call GroupRemoveUnit(ENUM_GROUP, u)
					endloop
					
					// cast tornado only if enough enemies around and in the distance to the Ice Avatar
					if (amountOfNearEnemies >= FOD_Enemies[.aiLevel]) then
						set abilityCasted = IssueImmediateOrder(.hero, FOD_ORDER)
					endif
				endif
			endif
			
			set u = null
			
			if not (abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Ice Tornado
			call RegisterHeroAISkill(HERO_ID, 1, 'A04J')
			call RegisterHeroAISkill(HERO_ID, 5, 'A04J') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A04J') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A04J') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A04J') 
			// Freezing Breath
			call RegisterHeroAISkill(HERO_ID, 2, 'A0AF') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A0AF') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A0AF') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A0AF') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A0AF') 
			// Frost Aura
			call RegisterHeroAISkill(HERO_ID, 3, 'A04Q') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A04Q') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A04Q') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A04Q') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A04Q') 
			// Fog of Death
			call RegisterHeroAISkill(HERO_ID, 6, 'A04M')
			call RegisterHeroAISkill(HERO_ID, 12, 'A04M')
			call RegisterHeroAISkill(HERO_ID, 18, 'A04M')
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
				call Itemsets[1].addItem('u001', CURSED_ROBE, 1)
				call Itemsets[1].addItem('u003', ARCANE_FLARE, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', BLOOD_BLADE, 1)
				call Itemsets[2].addItem('u001', CURSED_ROBE, 1)
				call Itemsets[2].addItem('u003', MAGIC_AXE, 1)
				call Itemsets[2].addItem('u003', DEMONIC_AMULET, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Ice Tornado
			set IT_Chance[0] = 20
			set IT_Chance[1] = 25
			set IT_Chance[2] = 30
			
			set IT_Enemies[0] = 4
			set IT_Enemies[1] = 6
			set IT_Enemies[2] = 8
			
			// percent value
			set IT_MIN_HP[0] = .25
			set IT_MIN_HP[1] = .30
			set IT_MIN_HP[2] = .35
			
			// Freezing Breath
			set FB_Chance[0] = 20
			set FB_Chance[1] = 25
			set FB_Chance[2] = 30
			
			set FB_Random[0] = 2
			set FB_Random[1] = 4
			set FB_Random[2] = 6
			
			set FB_Enemies[0] = 3
			set FB_Enemies[1] = 5
			set FB_Enemies[2] = 7
			
			// Fog of Death
			set FOD_Chance[0] = 20
			set FOD_Chance[1] = 30
			set FOD_Chance[2] = 40
			
			set FOD_Enemies[0] = 8
			set FOD_Enemies[1] = 10
			set FOD_Enemies[2] = 12
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope