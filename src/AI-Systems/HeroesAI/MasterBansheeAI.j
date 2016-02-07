scope MasterBansheeAI
    globals
        private constant integer HERO_ID = 'U01S'
		
		private HeroAI_Itemset array Itemsets
		
		/* Dark Obedience */
		private constant string DO_ORDER = "curse"
		// Chance to cast ability
		private integer array DO_Chance
		
		/* Spirit Burn */
		private constant string SB_ORDER = "acidbomb"
		// Chance to cast ability
		private integer array SB_Chance
		
		/* Cursed Soul */
		private constant string CS_ORDER = "darksummoning"
		private constant real CS_RADIUS = 600
		// Chance to cast ability
		private integer array CS_Chance
		
		/* Barrage */
		private constant string B_ORDER = "blizzard"
		private constant real B_RADIUS = 600
		// Chance to cast ability
		private integer array B_Chance
    endglobals
    
    private struct AI extends array
	
		private method doCursedSoul takes nothing returns boolean
			local unit corpse
			local unit u
			local group g
			local boolean abilityCasted = false
			
			set g = CreateGroup()
			call GroupClear(ENUM_GROUP)
			call GroupAddGroup(.units, ENUM_GROUP)
			
			loop
				set corpse = FirstOfGroup(ENUM_GROUP)
				exitwhen corpse == null 
				if ((SpellHelper.isUnitDead(corpse)) and /*
				*/	(Distance(.hx, .hy, GetUnitX(corpse), GetUnitY(corpse)) < CS_RADIUS)) then
					set abilityCasted = IssueImmediateOrder(.hero, CS_ORDER)
					call GroupClear(ENUM_GROUP)
				endif
				call GroupRemoveUnit(ENUM_GROUP, corpse)
			endloop
			
			call DestroyGroup(g)
			set g = null
			set corpse = null	
			set u = null
			
			return abilityCasted
		endmethod
	
        method assaultEnemy takes nothing returns nothing  
			local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Dark Obedience */
				if (GetRandomInt(0,100) <= DO_Chance[.aiLevel]) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					call PruneGroup(ENUM_GROUP, FitnessFunc_LowLife, 1, NO_FITNESS_LIMIT)
					set abilityCasted = IssueTargetOrder(.hero, DO_ORDER, FirstOfGroup(ENUM_GROUP))
				endif
				
				/* Spirit Burn */
				if ((GetRandomInt(0,100) <= SB_Chance[.aiLevel]) and (not abilityCasted)) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					call PruneGroup(ENUM_GROUP, FitnessFunc_LowLife, 1, NO_FITNESS_LIMIT)
					set abilityCasted = IssueTargetOrder(.hero, SB_ORDER, FirstOfGroup(ENUM_GROUP))
				endif
				
				/* Cursed Soul */
				if ((GetRandomInt(0,100) <= CS_Chance[.aiLevel]) and (not abilityCasted)) then
					set abilityCasted = doCursedSoul()
				endif
				
				/* Barrage */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= B_Chance[.aiLevel]) and (not abilityCasted)) then
					call GroupClear(ENUM_GROUP)
					call GroupAddGroup(.enemies, ENUM_GROUP)
					call PruneGroup(ENUM_GROUP, FitnessFunc_LowLife, 1, NO_FITNESS_LIMIT)
					set abilityCasted = IssueTargetOrder(.hero, B_ORDER, FirstOfGroup(ENUM_GROUP))
				endif
			endif
			
			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Dark Obedience
			call RegisterHeroAISkill(HERO_ID, 1, 'A04V')
			call RegisterHeroAISkill(HERO_ID, 5, 'A04V') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A04V') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A04V') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A04V') 
			// Spirit Burn
			call RegisterHeroAISkill(HERO_ID, 3, 'A04W') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A04W') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A04W') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A04W') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A04W') 
			// Cursed Soul
			call RegisterHeroAISkill(HERO_ID, 2, 'A04S') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A04S') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A04S') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A04S') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A04S') 
			// Barrage
			call RegisterHeroAISkill(HERO_ID, 6, 'A04Y')
			call RegisterHeroAISkill(HERO_ID, 12, 'A04Y')
			call RegisterHeroAISkill(HERO_ID, 18, 'A04Y')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', DARK_PLATES, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', DARK_PLATES, 1)
				call Itemsets[1].addItem('u001', BLOOD_BLADE, 1)
				call Itemsets[1].addItem('u003', CORRUPTED_ICON, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', DARK_PLATES, 1)
				call Itemsets[2].addItem('u001', BLOOD_BLADE, 1)
				call Itemsets[2].addItem('u003', DEMONIC_AMULET, 1)
				call Itemsets[2].addItem('u003', NECROMANCERS_ROBE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Dark Obedience
			set DO_Chance[0] = 10
			set DO_Chance[1] = 20
			set DO_Chance[2] = 30
			
			// Spirit Burn
			set SB_Chance[0] = 15
			set SB_Chance[1] = 20
			set SB_Chance[2] = 20
			
			// Cursed Soul
			set CS_Chance[0] = 15
			set CS_Chance[1] = 20
			set CS_Chance[2] = 20
			
			// Barrage
			set B_Chance[0] = 20
			set B_Chance[1] = 20
			set B_Chance[2] = 30
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope