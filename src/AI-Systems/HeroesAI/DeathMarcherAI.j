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
		
		/* Soul Trap */
		private constant string ST_ORDER = "cripple"
		// Chance to cast ability
		private integer array ST_Chance
		
		/* Mana Concentration */
		private constant string MC_ORDER = "magicleash"
		private constant integer MC_BUFF_ID = 'B00I'
		// Chance to cast ability
		private integer array MC_Chance
		private real array MC_Chance_Multiplier
		
		/* Boling Blood */
		private constant string BB_ORDER = "deathanddecay"
		// RADIUS must be the same like in the OE on the ability (AoE/Wirkungsbereich)
		private constant real BB_RADIUS = 400
		// Chance to cast ability
		private integer array BB_Chance
		private integer array BB_CancelChance
		private integer array BB_Random
		private integer array BB_Enemies
    endglobals
    
    private struct AI extends array
	
		private method doBoilingBlood takes nothing returns boolean
			local group BB_groupRandomUnits = CreateGroup()
			local unit BB_randomUnit
			local unit u
			local integer BB_index = 0
			local integer amountOfNearEnemies = 0
			local boolean abilityCasted = false
			
			call GroupClear(ENUM_GROUP)
			call GroupAddGroup(.enemies, ENUM_GROUP)
			
			loop
				exitwhen ((BB_index == BB_Random[.aiLevel]) or (amountOfNearEnemies >= BB_Enemies[.aiLevel]))
				set amountOfNearEnemies = 0
				set u = GetRandomUnitFromGroup(ENUM_GROUP) 
				call GroupEnumUnitsInRange(BB_groupRandomUnits, GetUnitX(u), GetUnitY(u), BB_RADIUS, null)
				
				loop
					set BB_randomUnit = FirstOfGroup(BB_groupRandomUnits)
					exitwhen BB_randomUnit == null
					if (SpellHelper.isValidEnemy(BB_randomUnit, .hero)) then
						set amountOfNearEnemies = amountOfNearEnemies + 1
					endif
					call GroupRemoveUnit(BB_groupRandomUnits, BB_randomUnit)
				endloop
				
				set BB_index = BB_index + 1
			endloop
			
			call DestroyGroup(BB_groupRandomUnits)
			set BB_groupRandomUnits = null
			
			if (amountOfNearEnemies >= BB_Enemies[.aiLevel]) then
				set abilityCasted = IssueTargetOrder(.hero, BB_ORDER, u)
			endif
			
			set u = null
			set BB_randomUnit = null
			
			return abilityCasted
		endmethod
		
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
		
		method runActions takes nothing returns nothing
			if (not .isChanneling) then
				call .run()
			else
				// X percent chance to stop casting Boiling Blood and run away
				if (GetRandomInt(0,100) <= BB_CancelChance[.aiLevel]) then
					call .run()
				endif
			endif
		endmethod
		
        method assaultEnemy takes nothing returns nothing  
			local boolean abilityCasted = false
			local real chanceMultiplier = 1.0 
			
			if (.enemyNum > 0) then
				// is Mana Concentration Buff active, increase the chance of all abilities to get cast
				if (GetUnitAbilityLevel(.hero, MC_BUFF_ID) > 0) then
					set chanceMultiplier = MC_Chance_Multiplier[.aiLevel]
				endif
				
				/* Mana Concentration */
				if ((GetRandomInt(0,100) <= MC_Chance[.aiLevel])  and /*
				*/	(GetUnitAbilityLevel(.hero, MC_BUFF_ID) == 0) and /*
				*/	(.closestEnemyHero != null)) then
					set abilityCasted = IssueImmediateOrder(.hero, MC_ORDER)
				endif
				
				/* Death Pact */
				if ((GetRandomInt(0,100) <= R2I((I2R(DP_Chance[.aiLevel]) * chanceMultiplier))) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doDeathPact()
				endif
				
				/* Soul Trap */
				if ((GetRandomInt(0,100) <= R2I((I2R(ST_Chance[.aiLevel]) * chanceMultiplier))) and /*
				*/	(.closestEnemyHero != null) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = IssueTargetOrder(.hero, ST_ORDER, .closestEnemyHero)
				endif
				
				/* Boiling Blood */
				if ((.heroLevel >= 6) and /*
				*/	(GetRandomInt(0,100) <= R2I((I2R(BB_Chance[.aiLevel]) * chanceMultiplier))) and /*
				*/	(not abilityCasted)) then
					set abilityCasted = doBoilingBlood()					
				endif
			endif	

			if (not abilityCasted) then
				call BJDebugMsg("defaultAssaultEnemy")
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
			call RegisterHeroAISkill(HERO_ID, 3, 'A04X') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A04X') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A04X') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A04X') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A04X') 
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
			set DP_Chance[2] = 20
			
			set DP_Allies[0] = 3
			set DP_Allies[1] = 5
			set DP_Allies[2] = 7
			
			set DP_Min_HP[0] = 20.
			set DP_Min_HP[1] = 25.
			set DP_Min_HP[2] = 30.
			
			// Soul Trap
			set ST_Chance[0] = 20
			set ST_Chance[1] = 20
			set ST_Chance[2] = 30
			
			// Mana Concentration
			set MC_Chance[0] = 10
			set MC_Chance[1] = 20
			set MC_Chance[2] = 30
			
			set MC_Chance_Multiplier[0] = 1.5
			set MC_Chance_Multiplier[1] = 2.0
			set MC_Chance_Multiplier[2] = 2.5
			
			// Boiling Blood
			set BB_Chance[0] = 20
			set BB_Chance[1] = 20
			set BB_Chance[2] = 20
			
			set BB_Random[0] = 2
			set BB_Random[1] = 4
			set BB_Random[2] = 6
			
			set BB_Enemies[0] = 3
			set BB_Enemies[1] = 5
			set BB_Enemies[2] = 7
			
			set BB_CancelChance[0] = 20
			set BB_CancelChance[0] = 40
			set BB_CancelChance[0] = 60
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope