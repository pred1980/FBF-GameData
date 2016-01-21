scope IceAvatarAI
    globals
        private constant integer HERO_ID = 'U004'
		
		private HeroAI_Itemset array Itemsets
		
		/* Ice Tornado */
		private constant string IT_ORDER = "spellshield"
		// This constant must be the sum of AOE_RANGE + CRCL_RADIUS in the IceTornado.j
		private constant integer IT_RADIUS = 308
		// How many units have to be in radius to cast Ice Tornado?
		private integer array IT_Enemies
		// Chance to cast ability
		private integer array IT_Chance
		
		/* Freezing Breath */
		private constant string FB_ORDER = "spellshield"
    endglobals
    
    private struct AI extends array
		
		method assaultEnemy takes nothing returns nothing  
			local boolean abilityCasted = false
			local unit u
			
			// Ice Tornado
			local integer amountOfNearEnemies = 0
			
			
			
			if (.enemyNum > 0) then
				/* Ice Tornado */
				if ((GetRandomInt(0,100) <= IT_Chance[.aiLevel])) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					loop
						set u = FirstOfGroup(ENUM_GROUP) 
						exitwhen u == null 
						if (Distance(.hx, .hy, GetUnitX(u), GetUnitY(u)) <= IT_RADIUS) then
							set amountOfNearEnemies = amountOfNearEnemies + 1
						endif
						call GroupRemoveUnit(ENUM_GROUP, u)
					endloop
					// stomp only if enough enemies around and in the distance to behemot
					if (amountOfNearEnemies >= IT_Enemies[.aiLevel]) then
						call IssueImmediateOrder(.hero, IT_ORDER)
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
			// Ice Tornado
			call RegisterHeroAISkill(HERO_ID, 1, 'A04J')
			call RegisterHeroAISkill(HERO_ID, 5, 'A04J') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A04J') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A04J') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A04J') 
			// Freezing Breath
			call RegisterHeroAISkill(HERO_ID, 2, 'A04K') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A04K') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A04K') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A04K') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A04K') 
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
			set IT_Chance[2] = 20
			
			set IT_Enemies[0] = 2
			set IT_Enemies[1] = 4
			set IT_Enemies[2] = 6
			
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope