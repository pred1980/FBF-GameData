scope SkeletonMageAI
    globals
        private constant integer HERO_ID = 'U01P'
		
		private HeroAI_Itemset array Itemsets
		private group enumGroup = CreateGroup()

		/* Plague Infection */
		private constant string PI_ORDER = "banish"
		private constant real PI_RADIUS = 100
		// Chance to cast ability
		private integer array PI_Chance
		private real array PI_Min_HP
		private integer array PI_Enemies
		
		/* Spawn Zombies */
		private constant string SZ_ORDER = "raisedead"
		// Chance to cast ability
		private integer array SZ_Chance
		private integer array SZ_Enemies		

		/* Call of the Damned */
		private constant integer SPELL_ID = 'A05B'
		private constant string COTD_ORDER = "blizzard"
		// Chance to cast ability
		private integer array COTD_Chance
		// Radius must be the same like in the OE for each level
		private real array COTD_Radius
		private real array COTD_RandomCorpse
		private integer array COTD_Min_Corpse
		private integer array COTD_Min_Enemies
		private integer array COTD_Min_Enemies_Sum
    endglobals
    
    private struct AI extends array
	
		private static method corpseFilter takes nothing returns boolean
			return SpellHelper.isUnitDead(GetFilterUnit())
		endmethod
		
		private static method enemiesFilter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), tempthis.hero) and GetUnitLifePercent(GetFilterUnit()) >= 70
		endmethod
	
		private method doCallOfTheDamned takes nothing returns boolean
			local boolean abilityCasted = false
			local unit randomCorpse
			local unit nearbyCorpse
			local unit nearbyEnemy
			local integer level = GetUnitAbilityLevel(.hero, SPELL_ID)
			local integer randomCorpseIndex = 0
			local integer randomEnemiesIndex = 0
			
			call GroupClear(ENUM_GROUP)
			loop
				set randomCorpse = GetRandomUnitFromGroup(.deads) 
				exitwhen (randomCorpse == null or abilityCasted or randomCorpseIndex > COTD_RandomCorpse[.aiLevel])
				call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(randomCorpse), GetUnitY(randomCorpse), COTD_Radius[level], Filter(function thistype.corpseFilter))
				set randomEnemiesIndex = 0
				
				loop
					set nearbyCorpse = FirstOfGroup(ENUM_GROUP)
					exitwhen (nearbyCorpse == null or abilityCasted)
					call GroupEnumUnitsInRange(enumGroup, GetUnitX(nearbyCorpse), GetUnitY(nearbyCorpse), 100, Filter(function thistype.enemiesFilter))
					
					loop
						set nearbyEnemy = FirstOfGroup(enumGroup)
						exitwhen (nearbyEnemy == null or abilityCasted)
						set randomEnemiesIndex = randomEnemiesIndex + 1
						
						if (randomEnemiesIndex >= COTD_Min_Enemies_Sum[.aiLevel]) then
							set abilityCasted = IssuePointOrder(.hero, COTD_ORDER, GetUnitX(nearbyCorpse), GetUnitY(nearbyCorpse))
						endif
						
						call GroupRemoveUnit(enumGroup, nearbyEnemy)
					endloop
					
					call GroupRemoveUnit(ENUM_GROUP, nearbyCorpse)
				endloop
				
				call GroupRemoveUnit(.deads, randomCorpse)
				set randomCorpseIndex = randomCorpseIndex + 1
			endloop

			// clean up
			call GroupClear(enumGroup)
			call GroupClear(ENUM_GROUP)
			set randomCorpse = null
			set nearbyCorpse = null
			set nearbyEnemy = null
			
			return abilityCasted
		endmethod
	
		private method doPlagueInfection takes nothing returns boolean
			local integer amountOfPossibleEnemies = 0
			local boolean abilityCasted = false
			local unit u
			local unit u2
			
			call GroupClear(ENUM_GROUP)
			call GroupAddGroup(.enemies, ENUM_GROUP)
			
			loop
				set u = FirstOfGroup(ENUM_GROUP)
				exitwhen (u == null or abilityCasted)
				if (GetUnitLifePercent(u) <= PI_Min_HP[.aiLevel]) then
					set amountOfPossibleEnemies = 0
					call GroupEnumUnitsInRange(enumGroup, GetUnitX(u), GetUnitY(u), PI_RADIUS, null)
					
					loop
						set u2 = FirstOfGroup(enumGroup)
						exitwhen (u2 == null or abilityCasted)
						if ((SpellHelper.isValidEnemy(u2, .hero)) and /*
						*/	(Distance(GetUnitX(u), GetUnitY(u), GetUnitX(u2), GetUnitY(u2)) <= PI_RADIUS)) then
							set amountOfPossibleEnemies = amountOfPossibleEnemies + 1
							if (amountOfPossibleEnemies >= PI_Enemies[.aiLevel]) then
								set abilityCasted = IssueTargetOrder(.hero, PI_ORDER, u)
							endif
						endif
						call GroupRemoveUnit(enumGroup, u2)
					endloop
				endif
				call GroupRemoveUnit(ENUM_GROUP, u)
			endloop
			
			call GroupClear(ENUM_GROUP)
			call GroupClear(enumGroup)
			set u = null
			set u2 = null
		
			return abilityCasted
		endmethod
        
		method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			if (.enemyNum > 0) then
				/* Spawn Zombies */
				if ((GetRandomInt(0,100) <= SZ_Chance[.aiLevel]) and /*
				*/ (.enemyNum >= SZ_Enemies[.aiLevel])) then
					set abilityCasted = IssueTargetOrder(.hero, SZ_ORDER, .closestEnemy)
				endif
				
				/* Plague Infection */
				if ((GetRandomInt(0,100) <= PI_Chance[.aiLevel]) and /*
				*/ (not abilityCasted)) then
					set abilityCasted = doPlagueInfection()
				endif
				
				/* Call of the Damned */
				if ((.heroLevel >= 6) and /*
				*/  (GetRandomInt(0,100) <= COTD_Chance[.aiLevel]) and /*
				*/ (not abilityCasted)) then
					set abilityCasted = doCallOfTheDamned()
				endif
			endif	

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Plague Infection
			call RegisterHeroAISkill(HERO_ID, 3, 'A054') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A054') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A054') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A054') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A054')
			
			// Spawn Zombies
			call RegisterHeroAISkill(HERO_ID, 1, 'A058')
			call RegisterHeroAISkill(HERO_ID, 5, 'A058') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A058') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A058') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A058')
			
			// Soul Extraction
			call RegisterHeroAISkill(HERO_ID, 2, 'A056') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A056') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A056') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A056') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A056') 
			 
			// Call of the Damned
			call RegisterHeroAISkill(HERO_ID, 6, 'A05B')
			call RegisterHeroAISkill(HERO_ID, 12, 'A05B')
			call RegisterHeroAISkill(HERO_ID, 18, 'A05B')
			
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', UNHOLY_ICON, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', UNHOLY_ICON, 1)
				call Itemsets[1].addItem('u001', DARK_PLATES, 1)
				call Itemsets[1].addItem('u003', NECROMANCERS_ROBE, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', UNHOLY_ICON, 1)
				call Itemsets[2].addItem('u001', DARK_PLATES, 1)
				call Itemsets[2].addItem('u003', NECROMANCERS_ROBE, 1)
				call Itemsets[2].addItem('u003', ARCANE_FLARE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Plague Infection
			set PI_Chance[0] = 20
			set PI_Chance[1] = 10
			set PI_Chance[2] = 25
			
			set PI_Min_HP[0] = 25.
			set PI_Min_HP[1] = 20.
			set PI_Min_HP[2] = 15.
			
			set PI_Enemies[0] = 1
			set PI_Enemies[1] = 1
			set PI_Enemies[2] = 1
			
			// Spawn Zombies
			set SZ_Chance[0] = 20
			set SZ_Chance[1] = 40
			set SZ_Chance[2] = 40
			
			set SZ_Enemies[0] = 5
			set SZ_Enemies[1] = 6
			set SZ_Enemies[2] = 7
			
			// Call of the Damned
			set COTD_Chance[0] = 20
			set COTD_Chance[1] = 30
			set COTD_Chance[2] = 35
			
			set COTD_Radius[0] = 300
			set COTD_Radius[1] = 350
			set COTD_Radius[2] = 400
			
			set COTD_RandomCorpse[0] = 2
			set COTD_RandomCorpse[1] = 4
			set COTD_RandomCorpse[2] = 6

			set COTD_Min_Corpse[0] = 4
			set COTD_Min_Corpse[1] = 5
			set COTD_Min_Corpse[2] = 6
			
			set COTD_Min_Enemies[0] = 1
			set COTD_Min_Enemies[1] = 2
			set COTD_Min_Enemies[2] = 3
			
			set COTD_Min_Enemies_Sum[0] = 4
			set COTD_Min_Enemies_Sum[1] = 6
			set COTD_Min_Enemies_Sum[2] = 8
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope