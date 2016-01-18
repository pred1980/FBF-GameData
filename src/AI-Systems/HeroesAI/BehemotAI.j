scope BehemotAI
    globals
        private constant integer HERO_ID = 'U01N'
		
		private HeroAI_Itemset array Itemsets
		
		/* Explosiv Tantrum */
		// Chance to cast ability
		private integer array ET_Chance
		
		/* Beast Stomper */
		// This constant must be the same like in the BeastStomper.j
		private constant integer BS_RADIUS = 250
		// How many units have to be in radius to cast Beast Stomper
		private integer array BS_Enemies
		// Chance to cast ability
		private integer array BS_Chance
		
		/* Roar */
		// This constant must be the same like in the Raor (OE)
		private constant integer R_RADIUS = 500
		// How many units have to be in radius to cast Roar
		private integer array R_Allies
		// Chance to cast ability
		private integer array R_Chance
		
		/* Adrenalin Rush */
		// Let's use a value that represents natural human field of view: ~135°  (2*67.5)
		private constant real VISION_FIELD = 10  
		// This Radius is just for the AI
		private constant integer AR_RADIUS = 750
		// How many units have to be in radius to cast Adrenalin Rush
		private integer array AR_Enemies
		// Chance to cast ability
		private integer array AR_Chance
    endglobals
    
    private struct AI extends array
        
        method assaultEnemy takes nothing returns nothing
			// Ability Chance value
			local integer random = GetRandomInt(0,100)
			
			// Beast Stomper and Roar
            local integer amountOfNearEnemies = 0
			// Roar
			local integer amountOfNearAllies = 0
			// Adrenalin Rush
			local unit furthestUnit
			// current distance of group unit 
			local real dist = 0.0
			// maximum distance of group unit
			local real maxDist = 0.0
			
			local boolean abilityCasted = false
			local unit u
			
			if (.enemyNum > 0) then
				/* Explosiv Tantrum */
				if ((.orderId == 0) and (random <= ET_Chance[.aiLevel])) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					call PruneGroup(ENUM_GROUP, FitnessFunc_LowLife, 1, NO_FITNESS_LIMIT)
					call IssueTargetOrder(.hero, "taunt", FirstOfGroup(ENUM_GROUP))
					set abilityCasted = true
				endif
				
				/* Beast Stomper */
				if ((.orderId == 0) and (random <= BS_Chance[.aiLevel]) and not abilityCasted) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					loop
						set u = FirstOfGroup(ENUM_GROUP) 
						exitwhen u == null 
						if (Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= BS_RADIUS) then
							set amountOfNearEnemies = amountOfNearEnemies + 1
						endif
						call GroupRemoveUnit(ENUM_GROUP, u)
					endloop
					// stomp only if enough enemies around and in the distance to behemot
					if (amountOfNearEnemies >= BS_Enemies[.aiLevel]) then
						call IssueImmediateOrder(.hero, "stomp")
						set abilityCasted = true
					endif
				endif
				
				/* Roar */
				if ((.orderId == 0) and (random <= R_Chance[.aiLevel]) and not abilityCasted) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.allies, ENUM_GROUP)
					loop
						set u = FirstOfGroup(ENUM_GROUP) 
						exitwhen u == null 
						if (Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= R_RADIUS) then
							set amountOfNearAllies = amountOfNearAllies + 1
						endif
						call GroupRemoveUnit(ENUM_GROUP, u)
					endloop
					// stomp only if enough enemies around and in the distance to behemot
					if (amountOfNearAllies >= R_Allies[.aiLevel]) then
						call IssueImmediateOrder(.hero, "thunderclap")
						set abilityCasted = true
					endif
				endif
				
				/* Adrenalin Rush */
				if ((.heroLevel >= 6) and (.orderId == 0) and (random <= AR_Chance[.aiLevel]) and not abilityCasted) then
					set amountOfNearEnemies = 0
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					loop
						set u = FirstOfGroup(ENUM_GROUP) 
						exitwhen u == null 
						// 1. Check if enemy is in range of Behemot
						// 2. Check if enemy is in the path of Behemot
						if ((Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= AR_RADIUS) and /*
						*/	(IsUnitInSightOfUnit(.hero, u, VISION_FIELD))) then
							set amountOfNearEnemies = amountOfNearEnemies + 1
							set dist = Distance(.hx, .hy, GetUnitX(u), GetUnitY(u))
							
							// 3. Check which unit is the furthest of Behemot and attack it!
							if (dist > maxDist) then
								set furthestUnit = u
								set maxDist = dist
							endif
						endif
						call GroupRemoveUnit(ENUM_GROUP, u)
					endloop

					// Cast Adrenalin Rush when enough units in his way
					if (amountOfNearEnemies >= AR_Enemies[.aiLevel]) then
						call IssueTargetOrder(.hero, "avatar", furthestUnit)
						set abilityCasted = true
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
			// Explosive Tantrum
			call RegisterHeroAISkill(HERO_ID, 1, 'A05J')
			call RegisterHeroAISkill(HERO_ID, 5, 'A05J') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A05J') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A05J') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A05J') 
			// Beast Stomp
			call RegisterHeroAISkill(HERO_ID, 2, 'A00D') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A00D') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A00D') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A00D') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A00D') 
			// Roar
			call RegisterHeroAISkill(HERO_ID, 3, 'A07B') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A07B') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A07B') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A07B') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A07B') 
			// Adrenaline Rush
			call RegisterHeroAISkill(HERO_ID, 6, 'A02L')
			call RegisterHeroAISkill(HERO_ID, 12, 'A02L')
			call RegisterHeroAISkill(HERO_ID, 18, 'A02L')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', BELT_OF_GIANT_STRENGTH, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', BELT_OF_GIANT_STRENGTH, 1)
				call Itemsets[1].addItem('u001', TWIN_AXE, 1)
				call Itemsets[1].addItem('u003', BLOOD_PLATE_ARMOR, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', BELT_OF_GIANT_STRENGTH, 1)
				call Itemsets[2].addItem('u001', TWIN_AXE, 1)
				call Itemsets[2].addItem('u003', BLOOD_PLATE_ARMOR, 1)
				call Itemsets[2].addItem('u003', SPEAR_OF_VENGEANCE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy | 1 == Computer normal | 2 == Computer insane
			// Explosiv Tantrum
			set ET_Chance[0] = 35
			set ET_Chance[1] = 30
			set ET_Chance[2] = 25
			
			// Beast Stomper
			set BS_Enemies[0] = 2
			set BS_Enemies[1] = 4
			set BS_Enemies[2] = 6
			
			set BS_Chance[0] = 20
			set BS_Chance[1] = 30
			set BS_Chance[2] = 40
			
			// Roar
			set R_Allies[0] = 3
			set R_Allies[1] = 5
			set R_Allies[2] = 7
			
			set R_Chance[0] = 25
			set R_Chance[1] = 35
			set R_Chance[2] = 45
			
			// Adrenalin Rush
			set AR_Enemies[0] = 6
			set AR_Enemies[1] = 8
			set AR_Enemies[2] =	10
			
			set AR_Chance[0] = 30
			set AR_Chance[1] = 40
			set AR_Chance[2] = 50
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope