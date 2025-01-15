scope NerubianWidowAI
    globals
        private constant integer HERO_ID = 'U01O'
		
		private HeroAI_Itemset array Itemsets	
		
		/* Adolescence */
		// Chance to cast ability
		private integer array A_Chance
		// Minimum Distance between enemy and the Nerubian Widow to lay an egg
		private constant real A_MIN_DISTANCE = 500
		private constant string A_ORDER = "ambush"
		
		/* Spider Web */
		// Chance to cast ability
		private integer array SW_Chance
		private constant string SW_ORDER = "web"
		
		/* Sprint */
		// Chance to cast ability
		private constant string S_ORDER_1 = "immolation"
        private constant string S_ORDER_2 = "unimmolation"
		private integer array S_Chance
		private boolean S_isCasted = false
		
		/* Widow Bite */
		private integer array WB_Chance
		private constant string WB_ORDER = "creepheal"
    endglobals
	
	private struct AI extends array
	
		method runActions takes nothing returns nothing
            local boolean abilityCasted = false
			
			/* Spider Web */
			if (GetRandomInt(0,100) <= SW_Chance[.aiLevel]) then
				set abilityCasted = IssueImmediateOrder(.hero, SW_ORDER)
			endif
			
			/* Sprint */
			if (GetRandomInt(0,100) <= S_Chance[.aiLevel] and not S_isCasted) then
				set abilityCasted = IssueImmediateOrder(.hero, S_ORDER_1)
				set S_isCasted = IssueImmediateOrder(.hero, S_ORDER_1)
			endif
			
			// if hero is in base stop "Sprint"
			if ((.safeUnit != null) and (S_isCasted))then
				call IssueImmediateOrder(.hero, S_ORDER_2)
				set S_isCasted = false
			endif
			
			if not (abilityCasted) then
				call .run()
			endif
		endmethod
		
		method assaultEnemy takes nothing returns nothing
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Adolescence */
				if ((GetRandomInt(0,100) <= A_Chance[.aiLevel])) then
					if (Distance(.hx, .hy, GetUnitX(.closestEnemy), GetUnitY(.closestEnemy)) > A_MIN_DISTANCE) then
						set abilityCasted = IssuePointOrder(.hero, A_ORDER, GetUnitX(.hero), GetUnitY(.hero))
					endif
				endif
				
				/* Widow Bite */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= WB_Chance[.aiLevel]) and /*
				*/	(.closestEnemyHero != null)	and not /*
				*/	(abilityCasted)) then
					set abilityCasted = IssueTargetOrder(.hero, WB_ORDER, .closestEnemyHero)
				endif
			endif
			
			if not (abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
                
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Adolescence
			call RegisterHeroAISkill(HERO_ID, 1, 'A004')
			call RegisterHeroAISkill(HERO_ID, 5, 'A004') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A004') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A004') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A004') 
			// Spider Web
			call RegisterHeroAISkill(HERO_ID, 2, 'A005') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A005') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A005') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A005') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A005') 
			// Sprint
			call RegisterHeroAISkill(HERO_ID, 3, 'A024') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A024') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A024') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A024') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A024') 
			// Widow Bite
			call RegisterHeroAISkill(HERO_ID, 6, 'A003')
			call RegisterHeroAISkill(HERO_ID, 12, 'A003')
			call RegisterHeroAISkill(HERO_ID, 18, 'A003')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 2)
				call Itemsets[0].addItem('u001', SPIDER_BRACELET, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 3)
				call Itemsets[1].addItem('u000', MANA_POTION, 3)
				call Itemsets[1].addItem('u001', SPIDER_BRACELET, 1)
				call Itemsets[1].addItem('u001', TWIN_AXE, 1)
				call Itemsets[1].addItem('u003', RAVING_SWORD, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 4)
				call Itemsets[2].addItem('u000', MANA_POTION, 4)
				call Itemsets[2].addItem('u001', SPIDER_BRACELET, 1)
				call Itemsets[2].addItem('u001', TWIN_AXE, 1)
				call Itemsets[2].addItem('u003', RAVING_SWORD, 1)
				call Itemsets[2].addItem('u003', SPEAR_OF_VENGEANCE, 1)
			endif
			
			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Adolescence
			set A_Chance[0] = 20
			set A_Chance[1] = 25
			set A_Chance[2] = 30
			
			// Spider Web
			set SW_Chance[0] = 10
			set SW_Chance[1] = 15
			set SW_Chance[2] = 20
			
			// Sprint
			set S_Chance[0] = 10
			set S_Chance[1] = 15
			set S_Chance[2] = 20
			
			// Widow Bite
			set WB_Chance[0] = 20
			set WB_Chance[1] = 25
			set WB_Chance[2] = 30
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope