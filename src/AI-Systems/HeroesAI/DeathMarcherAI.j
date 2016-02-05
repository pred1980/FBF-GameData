scope DeathMarcherAI
    globals
        private constant integer HERO_ID = 'U019'
		
		private HeroAI_Itemset array Itemsets	
    endglobals
    
    private struct AI extends array
        method assaultEnemy takes nothing returns nothing  

			call .defaultAssaultEnemy()
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Soul Trap
			call RegisterHeroAISkill(HERO_ID, 1, 'A050')
			call RegisterHeroAISkill(HERO_ID, 5, 'A050') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A050') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A050') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A050') 
			// Death Pact
			call RegisterHeroAISkill(HERO_ID, 2, 'A04Z') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A04Z') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A04Z') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A04Z') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A04Z') 
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
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope