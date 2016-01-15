scope BehemotAI
    globals
        private constant integer HERO_ID = 'U01N'
		
		private HeroAI_Itemset array Itemsets
        private group enumGroup = CreateGroup()
		
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
		private constant real VISION_FIELD = 7.5  
		// This Radius is just for the AI
		private constant integer AR_RADIUS = 500
		// How many units have to be in radius to cast Adrenalin Rush
		private integer array AR_Enemies
		// Chance to cast ability
		private integer array AR_Chance
    endglobals
    
    private struct AI extends array
        // The following two methods will print out debug messages only when the events
        // are enabled
        method onAttacked takes unit attacker returns nothing
            //debug call BJDebugMsg("Abomination attacked by " + GetUnitName(attacker))
        endmethod
        
        method onAcquire takes unit target returns nothing
            //debug call BJDebugMsg("Abomination acquires " + GetUnitName(target))
        endmethod
		
		method assistAlly takes nothing returns boolean
			call GroupClear(enumGroup)
            call GroupAddGroup(.allies, enumGroup)
			
			return false
		endmethod
        
        method assaultEnemy takes nothing returns nothing 
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
			local string order = OrderId2String(GetUnitCurrentOrder(.hero))
			local unit u
			
			if (.enemyNum > 0) then
				/* Explosiv Tantrum */
				if ((order != "taunt") and (GetRandomInt(0,100) <= ET_Chance[.aiLevel])) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					call PruneGroup(ENUM_GROUP, FitnessFunc_LowLife, 1, NO_FITNESS_LIMIT)
					call IssueTargetOrder(.hero, "taunt", FirstOfGroup(ENUM_GROUP))
					set abilityCasted = true
				endif
				
				/* Beast Stomper */
				if ((order != "stomp") and (GetRandomInt(0,100) <= BS_Chance[.aiLevel])) then
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
				if ((order != "thunderclap") and (GetRandomInt(0,100) <= R_Chance[.aiLevel])) then
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
				if ((order != "avatar") and (GetRandomInt(0,100) <= AR_Chance[.aiLevel])) then
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
							if ((dist) > maxDist)
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
			
			if not (abilityCasted) then
				call .defaultAssaultEnemy()
			endif
		endmethod
        
        // Cast wind walk if there's an enemy nearby
        method loopActions takes nothing returns nothing
            call .defaultLoopActions()
        endmethod
        
        // A custom periodic method is defined for this hero as the AI constantly
        // searches for units that have their backs to her in order to use Backstab.
        static method onLoop takes nothing returns nothing
        
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
			call BJDebugMsg("Registered Itemset[" + I2S(.aiLevel) + "] for Behemot.")
			
			/* Ability Setup */
			// Note: 0 == Computer easy | 1 == Computer normal | 2 == Computer insane
			// Explosiv Tantrum
			set ET_Chance[0] = 70
			set ET_Chance[1] = 80
			set ET_Chance[2] = 90
			
			// Beast Stomper
			set BS_Enemies[0] = 2
			set BS_Enemies[1] = 4
			set BS_Enemies[2] = 6
			
			set BS_Chance[0] = 50
			set BS_Chance[1] = 60
			set BS_Chance[2] = 70
			
			// Roar
			set R_Allies[0] = 3
			set R_Allies[1] = 5
			set R_Allies[2] = 7
			
			set R_Chance[0] = 35
			set R_Chance[1] = 45
			set R_Chance[2] = 55
			
			// Adrenalin Rush
			set AR_Enemies[0] = 6
			set AR_Enemies[1] = 8
			set AR_Enemies[2] =	10
			
			set AR_Chance[0] = 75
			set AR_Chance[1] = 85
			set AR_Chance[2] = 95
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope