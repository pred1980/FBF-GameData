scope GhoulAI
    globals
        private constant integer HERO_ID = 'U00A'
		
		private HeroAI_Itemset array Itemsets	
		
		/* Claws Attack */
		// Chance to cast ability
		private constant string CA_ORDER_1 = "immolation"
        private constant string CA_ORDER_2 = "unimmolation"
		private constant real CA_RADIUS = 300
		// Chance to cast ability
		private integer array CA_Chance
		private integer array CA_HeroHP
		private boolean CA_casted = false
		
		/* Cannibalize */
		private constant string C_ORDER = "doom"
		private constant integer C_ORDER_ID = 852188 // cannibalize
		private constant integer C_RADIUS = 500
		private constant real C_RADIUS_MULTPLIER = 1.3
		// Chance to cast ability
		private integer array C_Chance
		private integer array C_Enemies
		
		/* Rage */
		private constant string R_ORDER = "berserk"
		private constant integer R_RADIUS = 250
		// Chance to cast ability
		private integer array R_Chance
		private integer array R_Enemies
    endglobals

    private struct AI extends array
	
		private static method corpseFilter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero)
		endmethod
	
		private method doCannibalize takes nothing returns nothing
			local unit corpse
			local unit u
			local group g
			
			if ((GetRandomInt(0,100) <= C_Chance[.aiLevel]) and (.orderId != C_ORDER_ID)) then
				set g = CreateGroup()
				call GroupClear(ENUM_GROUP)
				call GroupAddGroup(.units, ENUM_GROUP)
				
				loop
					set corpse = FirstOfGroup(ENUM_GROUP)
					exitwhen corpse == null 
					if ((SpellHelper.isUnitDead(corpse)) and /*
					*/	(Distance(.hx, .hy, GetUnitX(corpse), GetUnitY(corpse)) < (C_RADIUS/C_RADIUS_MULTPLIER))) then
						call GroupEnumUnitsInRange(g, GetUnitX(corpse), GetUnitY(corpse), C_RADIUS, Filter(function thistype.corpseFilter))
						
						if (CountUnitsInGroup(g) == 0) then
							call GroupClear(g)
							call GroupClear(ENUM_GROUP)
							call IssueImmediateOrder(.hero, C_ORDER)
						endif
					endif
					call GroupRemoveUnit(ENUM_GROUP, corpse)
				endloop
				
				call DestroyGroup(g)
				set g = null
				set corpse = null	
				set u = null
			endif
		endmethod
	
		method idleActions takes nothing returns  nothing
			/* Claws Attack */
			// Deactivate Claws Attack because the Ghoul is running away!
			if (CA_casted) then
				call IssueImmediateOrder(.hero, CA_ORDER_2)
				set CA_casted = false
			endif
			
			if ((not CA_casted) and (.orderId != C_ORDER_ID))then
				// just for development...
				set .moveX = -6535.1
				set .moveY = 2039.7
				call .move()
			endif
			
			/* Cannibalize */
			call doCannibalize()
		endmethod
	
		method runActions takes nothing returns nothing
			/* Claws Attack */
			// Deactivate Claws Attack because the Ghoul is running away!
			if (CA_casted) then
				call IssueImmediateOrder(.hero, CA_ORDER_2)
				set CA_casted = false
			endif
			
			if (.orderId != C_ORDER_ID) then
				call .run()
			endif
			
			/* Cannibalize */
			call doCannibalize()
		endmethod
       
        method assaultEnemy takes nothing returns nothing  
			local boolean abilityCasted = false
			
			// Claws Attack
			local real distance
			
			// Rage
			local unit u
			local integer amountOfNearEnemies = 0
			
			if (.enemyNum > 0) then
				/* Claws Attack */
				set distance = Distance(.hx, .hy, GetUnitX(.closestEnemyHero), GetUnitY(.closestEnemyHero))
				
				if (CA_casted) then
					// is enemy hero out of range (radius)??
					if (distance >= CA_RADIUS or .closestEnemyHero == null) then
						call IssueImmediateOrder(.hero, CA_ORDER_2)
						set CA_casted = false
					else
						call IssueTargetOrder(.hero, "attack", .closestEnemyHero)
					endif
				else
					if (GetRandomInt(0,100) <= CA_Chance[.aiLevel]) then
						// Cast only if closest enemy hero in distance to the ghoul and
						// the enemy hero has low hp
						if ((distance <= CA_RADIUS) and /*
						*/	(GetUnitLifePercent(.closestEnemyHero) <= CA_HeroHP[.aiLevel]))then
							call IssueImmediateOrder(.hero, CA_ORDER_1)
							set CA_casted = true
							set abilityCasted = true
						endif
					endif
				endif
				
				/* Rage */
				if (GetRandomInt(0,100) <= R_Chance[.aiLevel]) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					
					loop
						set u = FirstOfGroup(ENUM_GROUP) 
						exitwhen u == null 
						if (Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= R_RADIUS) then
							set amountOfNearEnemies = amountOfNearEnemies + 1
						endif
						call GroupRemoveUnit(ENUM_GROUP, u)
					endloop
					
					// cast Rage only if enough enemies around and in the distance to the Ghoul
					if (amountOfNearEnemies >= R_Enemies[.aiLevel]) then
						call IssueImmediateOrder(.hero, R_ORDER)
						set abilityCasted = true
					endif
					
					set u = null
				endif
			endif

			if ((not abilityCasted) and /*
			*/	(.orderId != C_ORDER_ID)) then
				call .defaultAssaultEnemy()
			endif
			
			/* Cannibalize */
			call doCannibalize()
        endmethod

        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Claws Attack
			call RegisterHeroAISkill(HERO_ID, 1, 'A04N')
			call RegisterHeroAISkill(HERO_ID, 5, 'A04N') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A04N') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A04N') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A04N') 
			// Cannibalize
			call RegisterHeroAISkill(HERO_ID, 2, 'A04K') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A04K') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A04K') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A04K') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A04K') 
			// Flesh Wound
			call RegisterHeroAISkill(HERO_ID, 3, 'A04T') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A04T') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A04T') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A04T') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A04T') 
			// Rage
			call RegisterHeroAISkill(HERO_ID, 6, 'A04U')
			call RegisterHeroAISkill(HERO_ID, 12, 'A04U')
			call RegisterHeroAISkill(HERO_ID, 18, 'A04U')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
			// This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', BONE_HELMET, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', BONE_HELMET, 1)
				call Itemsets[1].addItem('u001', TWIN_AXE, 1)
				call Itemsets[1].addItem('u003', MORNING_STAR, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', BONE_HELMET, 1)
				call Itemsets[2].addItem('u001', TWIN_AXE, 1)
				call Itemsets[2].addItem('u003', METAL_HAND, 1)
				call Itemsets[2].addItem('u003', MORNING_STAR, 1)
			endif
			
			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Claws Attack
			set CA_Chance[0] = 20
			set CA_Chance[1] = 30
			set CA_Chance[2] = 40
			
			set CA_HeroHP[0] = 50
			set CA_HeroHP[1] = 45
			set CA_HeroHP[2] = 40
			
			// Cannibalize
			set C_Chance[0] = 20
			set C_Chance[1] = 20
			set C_Chance[2] = 30
			
			set C_Enemies[0] = 4
			set C_Enemies[1] = 3
			set C_Enemies[2] = 2
			
			// Rage
			set R_Chance[0] = 20
			set R_Chance[1] = 30
			set R_Chance[2] = 30
			
			set R_Enemies[0] = 2
			set R_Enemies[1] = 3
			set R_Enemies[2] = 4
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope