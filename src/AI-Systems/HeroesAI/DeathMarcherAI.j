scope DeathMarcherAI
    globals
        private constant integer HERO_ID = 'U019'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()
		
		/* Death Pact */
		private constant string DP_ORDER = "deathpact"
		// DP_RADIUS must be the same value like in DeathPact.j (RADIUS)
		private constant real DP_RADIUS = 800
		// Chance to cast ability
		private integer array DP_Chance
		private integer array DP_Allies
		private real array DP_Min_HP
    endglobals
    
    private struct AI extends array
		
		private method doDeathPact takes nothing returns boolean
			// Death Pact
			local integer amountOfNearAllies = 0
			local unit ally
			local unit allyLowHP
			local boolean abilityCasted = false
			
			call GroupClear(ENUM_GROUP)
			call GroupAddGroup(.allies, ENUM_GROUP)
			
			loop
				set ally = FirstOfGroup(ENUM_GROUP)
				exitwhen ((ally == null) or (amountOfNearAllies >= DP_Allies[.aiLevel]))
				set amountOfNearAllies = 0
				// Has the ally full hp?
				if (GetUnitLifePercent(ally) == 100.) then
					call GroupEnumUnitsInRange(enumGroup, GetUnitX(ally), GetUnitY(ally), DP_RADIUS, null)
					call GroupRemoveUnit(enumGroup, .hero)
					// loop and check ho
					loop
						set allyLowHP = FirstOfGroup(enumGroup)
						exitwhen (allyLowHP == null)
						if ((SpellHelper.isValidAlly(allyLowHP, .hero)) and /*
						*/	(GetUnitLifePercent(allyLowHP) <= DP_Min_HP[.aiLevel])) then
							set amountOfNearAllies = amountOfNearAllies + 1
							// if reached amount of near Allies, stop and cast ability!
							if (amountOfNearAllies >= DP_Allies[.aiLevel]) then
								call GroupClear(ENUM_GROUP)
								call GroupClear(enumGroup)
								set abilityCasted = IssueTargetOrder(.hero, DP_ORDER, ally)
							endif
						endif
						call GroupRemoveUnit(enumGroup, allyLowHP)
					endloop
				endif
				call GroupRemoveUnit(ENUM_GROUP, ally)
			endloop

			call GroupClear(ENUM_GROUP)
			call GroupClear(enumGroup)
			set ally = null
			set allyLowHP = null
			
			return abilityCasted
		endmethod
		
        method assaultEnemy takes nothing returns nothing  
			local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Death Pact */
				if (GetRandomInt(0,100) <= DP_Chance[.aiLevel]) then
					set abilityCasted = doDeathPact()
				endif
			endif	

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Death Pact
			call RegisterHeroAISkill(HERO_ID, 1, 'A04Z') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A04Z') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A04Z') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A04Z') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A04Z') 
			// Soul Trap
			call RegisterHeroAISkill(HERO_ID, 2, 'A00I')
			call RegisterHeroAISkill(HERO_ID, 5, 'A00I') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A00I') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A00I') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A00I') 
			// Mana Concentration
			call RegisterHeroAISkill(HERO_ID, 3, 'A052') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A052') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A052') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A052') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A052') 
			// Boiling Blood
			call RegisterHeroAISkill(HERO_ID, 6, 'A053')
			call RegisterHeroAISkill(HERO_ID, 12, 'A053')
			call RegisterHeroAISkill(HERO_ID, 18, 'A053')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', PLATE_GLOVE, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', PLATE_GLOVE, 1)
				call Itemsets[1].addItem('u001', TWIN_AXE, 1)
				call Itemsets[1].addItem('u003', MAGIC_AXE, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', PLATE_GLOVE, 1)
				call Itemsets[2].addItem('u001', TWIN_AXE, 1)
				call Itemsets[2].addItem('u003', MAGIC_AXE, 1)
				call Itemsets[2].addItem('u003', BONE_CHARM, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Death Pact
			set DP_Chance[0] = 10
			set DP_Chance[1] = 20
			set DP_Chance[2] = 30
			
			set DP_Allies[0] = 3
			set DP_Allies[1] = 5
			set DP_Allies[2] = 7
			
			// percent value
			set DP_Min_HP[0] = 20.
			set DP_Min_HP[1] = 25.
			set DP_Min_HP[2] = 30.
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope