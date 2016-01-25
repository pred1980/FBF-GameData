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
		private boolean CA_isCasted = false
		
		/* Cannibalize */
		private constant string C_ORDER = "cannibalize"
		private constant integer C_ORDER_ID = 852188 // cannibalize
		private constant integer C_RADIUS = 500 
		// Chance to cast ability
		private integer array C_Chance
		private integer array C_Enemies
    endglobals
    
    private struct AI extends array
	
		method runActions takes nothing returns nothing
			local unit u
			local boolean abilityCasted = false
			
			// Cannibalize
			local unit corpse
			local boolean canCannibalize = false
			local group g = CreateGroup()
			
			/* Claws Attack */
			// Deactivate Claws Attack because the Ghoul is running away!
			if (CA_isCasted) then
				call IssueImmediateOrder(.hero, CA_ORDER_2)
				set CA_isCasted = false
			endif
			
			/* Cannibalize */
			if ((GetRandomInt(0,100) <= C_Chance[.aiLevel]) and (.orderId != C_ORDER_ID)) then
				call GroupClear(ENUM_GROUP)
				call GroupAddGroup(.units, ENUM_GROUP)
				
				loop
					set corpse = FirstOfGroup(ENUM_GROUP) 
					exitwhen corpse == null 
					if (SpellHelper.isUnitDead(corpse)) then
						call GroupEnumUnitsInRange(g, GetUnitX(corpse), GetUnitY(corpse), C_RADIUS, null)
						
						loop
							set u = FirstOfGroup(g)
							exitwhen u == null
							if (SpellHelper.isValidEnemy(u, .hero)) then
								set canCannibalize = true
							endif
							call GroupRemoveUnit(g, u)
						endloop
						
						set u = null
					endif
					call GroupRemoveUnit(ENUM_GROUP, corpse)
				endloop
				
				set corpse = null
				
				// cast tornado only if enough enemies around and in the distance to the Ice Avatar
				if (canCannibalize) then
					call IssueImmediateOrder(.hero, C_ORDER)
					set abilityCasted = true
				endif
			endif

			if not (abilityCasted) then
				call .run()
			endif
		endmethod
       
        method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			// Claws Attack
			local real CA_distance
			
			if (.enemyNum > 0) then
				/* Claws Attack */
				set CA_distance = Distance(.hx, .hy, GetUnitX(.closestEnemyHero), GetUnitY(.closestEnemyHero))
				
				if (CA_isCasted) then
					// is enemy hero out of range (radius)??
					if (CA_distance >= CA_RADIUS or .closestEnemyHero == null) then
						call IssueImmediateOrder(.hero, CA_ORDER_2)
						set abilityCasted = false
						set CA_isCasted = false
					else
						call IssueTargetOrder(.hero, "attack", .closestEnemyHero)
					endif
				else
					if (GetRandomInt(0,100) <= CA_Chance[.aiLevel]) then
						// Cast only if closest enemy hero in distance to the ghoul and
						// the enemy hero has low hp
						if ((CA_distance <= CA_RADIUS) and /*
						*/	(GetUnitLifePercent(.closestEnemyHero) <= CA_HeroHP[.aiLevel]))then
							call IssueImmediateOrder(.hero, CA_ORDER_1)
							set abilityCasted = true
							set CA_isCasted = true
						endif
					endif
				endif
				
				
			endif
			
            if (not abilityCasted and not CA_isCasted) then
				call .defaultAssaultEnemy()
			endif
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
			call RegisterHeroAISkill(HERO_ID, 2, 'A04R') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A04R') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A04R') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A04R') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A04R') 
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
			set CA_Chance[1] = 25
			set CA_Chance[2] = 30
			
			set CA_HeroHP[0] = 50
			set CA_HeroHP[1] = 45
			set CA_HeroHP[2] = 40
			
			// Cannibalize
			set C_Chance[0] = 20
			set C_Chance[1] = 25
			set C_Chance[2] = 30
			
			set C_Enemies[0] = 4
			set C_Enemies[1] = 3
			set C_Enemies[2] = 2
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope