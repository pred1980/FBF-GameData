scope TowerConfig

	struct TowerConfig
		private static TowerBuildConfig array buildConfig[3][6]

		static method setBuildConfigCommonTowers takes integer pid, integer aiLevel returns nothing
			local integer index = GetRandomInt(0,4)
			
			//call BJDebugMsg("AI Level: " + I2S(aiLevel))
			//call BJDebugMsg("AI Index: " + I2S(index))

			call TowerAIEventListener.getTowerBuildAI(pid).setConfig(buildConfig[aiLevel][index])
		endmethod

		static method setBuildConfigLowTowers takes nothing returns nothing
			/*****************************/
			/*	AI LEVEL 0 (N E W B I E) */
			/*****************************/

			/*
			 * AI Level 0 (Newbie)
			 * Config 0
			 */
			set buildConfig[0][0] = TowerBuildConfig.create()
			// 80% Shady Spire
			call buildConfig[0][0].addBuilding('u00R', 80)
			// 20% Cold Obelisk
			call buildConfig[0][0].addBuilding('u00U', 20)

			/*
			 * AI Level 0 (Newbie)
			 * Config 1
			 */
			set buildConfig[0][1] = TowerBuildConfig.create()
			// 80% Flaming Rock
			call buildConfig[0][1].addBuilding('u00Y', 80)
			// 20% Cold Obelisk
			call buildConfig[0][1].addBuilding('u00U', 20)

			/*
			 * AI Level 0 (Newbie)
			 * Config 2
			 */
			set buildConfig[0][2] = TowerBuildConfig.create()
			// 80% Cursed Gravestone
			call buildConfig[0][2].addBuilding('u00X', 80)
			// 20% Cold Obelisk
			call buildConfig[0][2].addBuilding('u00U', 20)

			/*
			 * AI Level 0 (Newbie)
			 * Config 3
			 */
			set buildConfig[0][3] = TowerBuildConfig.create()
			// 57% Shady Spire
			call buildConfig[0][3].addBuilding('u00R', 57)
			// 14% Cold Obelisk
			call buildConfig[0][3].addBuilding('u00U', 14)
			// 29% Flaming Rock
			call buildConfig[0][3].addBuilding('u00Y', 29)

			/*
			 * AI Level 0 (Newbie)
			 * Config 4
			 */
			set buildConfig[0][4] = TowerBuildConfig.create()
			// 57% Shady Spire
			call buildConfig[0][4].addBuilding('u00R', 57)
			// 14% Cold Obelisk
			call buildConfig[0][4].addBuilding('u00U', 14)
			// 29% Cursed Gravestone
			call buildConfig[0][4].addBuilding('u00X', 29)

			/*****************************/
			/*	AI LEVEL 1 (N O R M A L) */
			/*****************************/

			/*
			 * AI Level 1 (Normal)
			 * Config 0
			 */
			set buildConfig[1][0] = TowerBuildConfig.create()
			// 80% Dark Spire
			call buildConfig[1][0].addBuilding('u00S', 80)
			// 20% Frosty Obelisk
			call buildConfig[1][0].addBuilding('u00V', 20)

			/*
			 * AI Level 1 (Normal)
			 * Config 1
			 */
			set buildConfig[1][1] = TowerBuildConfig.create()
			// 80% Blazing Rock
			call buildConfig[1][1].addBuilding('u00Z', 80)
			// 20% Frosty Obelisk
			call buildConfig[1][1].addBuilding('u00V', 20)

			/*
			 * AI Level 1 (Normal)
			 * Config 2
			 */
			set buildConfig[1][2] = TowerBuildConfig.create()
			// 80% Cursed Tombstone
			call buildConfig[1][2].addBuilding('u011', 80)
			// 20% Frosty Obelisk
			call buildConfig[1][2].addBuilding('u00V', 20)

			/*
			 * AI Level 1 (Normal)
			 * Config 3
			 */
			set buildConfig[1][3] = TowerBuildConfig.create()
			// 57% Dark Spire
			call buildConfig[1][3].addBuilding('u00S', 57)
			// 14% Frosty Obelisk
			call buildConfig[1][3].addBuilding('u00V', 14)
			// 29% Blazing Rock
			call buildConfig[1][3].addBuilding('u00Z', 29)

			/*
			 * AI Level 1 (Normal)
			 * Config 4
			 */
			set buildConfig[1][4] = TowerBuildConfig.create()
			// 57% Dark Spire
			call buildConfig[1][4].addBuilding('u00S', 57)
			// 14% Frosty Obelisk
			call buildConfig[1][4].addBuilding('u00V', 14)
			// 29% Cursed Tombstone
			call buildConfig[1][4].addBuilding('u011', 29)

			/*****************************/
			/*	AI LEVEL 2 (I N S A N E) */
			/*****************************/

			/*
			 * AI Level 2 (Insane)
			 * Config 0
			 */
			set buildConfig[2][0] = TowerBuildConfig.create()
			// 80% Black Spire
			call buildConfig[2][0].addBuilding('u00T', 80)
			// 20% Glacial Obelisk
			call buildConfig[2][0].addBuilding('u00W', 20)

			/*
			 * AI Level 2 (Insane)
			 * Config 1
			 */
			set buildConfig[2][1] = TowerBuildConfig.create()
			// 80% Magma Rock
			call buildConfig[2][1].addBuilding('u010', 80)
			// 20% Glacial Obelisk
			call buildConfig[2][1].addBuilding('u00W', 20)

			/*
			 * AI Level 2 (Insane)
			 * Config 2
			 */
			set buildConfig[2][2] = TowerBuildConfig.create()
			// 80% Cursed Memento
			call buildConfig[2][2].addBuilding('u012', 80)
			// 20% Glacial Obelisk
			call buildConfig[2][2].addBuilding('u00W', 20)

			/*
			 * AI Level 2 (Insane)
			 * Config 3
			 */
			set buildConfig[2][3] = TowerBuildConfig.create()
			// 57% Black Spire
			call buildConfig[2][3].addBuilding('u00T', 57)
			// 14% Glacial Obelisk
			call buildConfig[2][3].addBuilding('u00W', 14)
			// 29% Magma Rock
			call buildConfig[2][3].addBuilding('u010', 29)

			/*
			 * AI Level 2 (Insane)
			 * Config 4
			 */
			set buildConfig[2][4] = TowerBuildConfig.create()
			// 57% Black Spire
			call buildConfig[2][4].addBuilding('u00T', 57)
			// 14% Glacial Obelisk
			call buildConfig[2][4].addBuilding('u00W', 14)
			// 29% Cursed Memento
			call buildConfig[2][4].addBuilding('u012', 29)
		endmethod
		
		static method setBuildConfigRareTowers takes nothing returns nothing
			/*****************************/
			/*	AI LEVEL 0 (N E W B I E) */
			/*****************************/

			/*
			 * AI Level 0 (Newbie)
			 * Config 0
			 */
			call buildConfig[0][0].resetBuildings()
			// 82% Decayed Earth Tower
			call buildConfig[0][0].addBuilding('u013', 82)
			// 18% Ice Frenzy
			call buildConfig[0][0].addBuilding('u016', 18)

			/*
			 * AI Level 0 (Newbie)
			 * Config 1
			 */
			call buildConfig[0][1].resetBuildings()
			// 72% Putrid Pot
			call buildConfig[0][1].addBuilding('u01A', 82)
			// 18% Ice Frenzy
			call buildConfig[0][1].addBuilding('u016', 18)

			/*
			 * AI Level 0 (Newbie)
			 * Config 2
			 */
			call buildConfig[0][2].resetBuildings()
			// 82% Gloom Orb
			call buildConfig[0][2].addBuilding('u01D', 82)
			// 18% Ice Frenzy
			call buildConfig[0][2].addBuilding('u016', 18)

			/*
			 * AI Level 0 (Newbie)
			 * Config 3
			 */
			call buildConfig[0][3].resetBuildings()
			// 60% Decayed Earth Tower
			call buildConfig[0][3].addBuilding('u013', 60)
			// 10% Ice Frenzy
			call buildConfig[0][3].addBuilding('u016', 10)
			// 30% Putrid Pot
			call buildConfig[0][3].addBuilding('u01A', 30)

			/*
			 * AI Level 0 (Newbie)
			 * Config 4
			 */
			call buildConfig[0][4].resetBuildings()
			// 60% Decayed Earth Tower
			call buildConfig[0][4].addBuilding('u013', 60)
			// 10% Ice Frenzy
			call buildConfig[0][4].addBuilding('u016', 10)
			// 30% Gloom Orb
			call buildConfig[0][4].addBuilding('u01D', 30)

			/*****************************/
			/*	AI LEVEL 1 (N O R M A L) */
			/*****************************/

			/*
			 * AI Level 1 (Normal)
			 * Config 0
			 */
			call buildConfig[1][0].resetBuildings()
			// 82% Plagued Earth Tower
			call buildConfig[1][0].addBuilding('u014', 82)
			// 18% Ice Fury
			call buildConfig[1][0].addBuilding('u017', 18)

			/*
			 * AI Level 1 (Normal)
			 * Config 1
			 */
			call buildConfig[1][1].resetBuildings()
			// 82% Putrid Vat
			call buildConfig[1][1].addBuilding('u01B', 82)
			// 18 Ice Fury
			call buildConfig[1][1].addBuilding('u017', 18)

			/*
			 * AI Level 1 (Normal)
			 * Config 2
			 */
			call buildConfig[1][2].resetBuildings()
			// 82% Ruin Orb
			call buildConfig[1][2].addBuilding('u01E', 82)
			// 18% Ice Fury
			call buildConfig[1][2].addBuilding('u017', 18)

			/*
			 * AI Level 1 (Normal)
			 * Config 3
			 */
			call buildConfig[1][3].resetBuildings()
			// 60% Plagued Earth Tower
			call buildConfig[1][3].addBuilding('u014', 60)
			// 10% Ice Fury
			call buildConfig[1][3].addBuilding('u017', 10)
			// 30 Putrid Vat
			call buildConfig[1][3].addBuilding('u01B', 30)

			/*
			 * AI Level 1 (Normal)
			 * Config 4
			 */
			call buildConfig[1][4].resetBuildings()
			// 60% Plagued Earth Tower
			call buildConfig[1][4].addBuilding('u014', 60)
			// 10% Ice Fury
			call buildConfig[1][4].addBuilding('u017', 10)
			// 30% Ruin Orb
			call buildConfig[1][4].addBuilding('u01E', 30)

			/*****************************/
			/*	AI LEVEL 2 (I N S A N E) */
			/*****************************/

			/*
			 * AI Level 2 (Insane)
			 * Config 0
			 */
			call buildConfig[2][0].resetBuildings()
			// 82% Blighted Earth Tower
			call buildConfig[2][0].addBuilding('u015', 82)
			// 18% Icy Rage
			call buildConfig[2][0].addBuilding('u018', 18)

			/*
			 * AI Level 2 (Insane)
			 * Config 1
			 */
			call buildConfig[2][1].resetBuildings()
			// 82% Putrid Cauldron
			call buildConfig[2][1].addBuilding('u01C', 82)
			// 18% Icy Rage
			call buildConfig[2][1].addBuilding('u018', 20)

			/*
			 * AI Level 2 (Insane)
			 * Config 2
			 */
			call buildConfig[2][2].resetBuildings()
			// 82% Doom Orb
			call buildConfig[2][2].addBuilding('u01F', 82)
			// 18% Icy Rage
			call buildConfig[2][2].addBuilding('u018', 18)

			/*
			 * AI Level 2 (Insane)
			 * Config 3
			 */
			call buildConfig[2][3].resetBuildings()
			// 60% Blighted Earth Tower
			call buildConfig[2][3].addBuilding('u015', 60)
			// 10% Icy Rage
			call buildConfig[2][3].addBuilding('u018', 10)
			// 30% Putrid Cauldron
			call buildConfig[2][3].addBuilding('u01C', 30)

			/*
			 * AI Level 2 (Insane)
			 * Config 4
			 */
			call buildConfig[2][4].resetBuildings()
			// 60% Blighted Earth Tower
			call buildConfig[2][4].addBuilding('u015', 60)
			// 10% Icy Rage
			call buildConfig[2][4].addBuilding('u018', 10)
			// 30% Doom Orb
			call buildConfig[2][4].addBuilding('u01F', 30)
		endmethod
		
		static method setBuildConfigUniqueTowers takes nothing returns nothing
			/*****************************/
			/*	AI LEVEL 0 (N E W B I E) */
			/*****************************/

			/*
			 * AI Level 0 (Newbie)
			 * Config 0
			 */
			call buildConfig[0][0].resetBuildings()
			// 85% Monolith of Hatred
			call buildConfig[0][0].addBuilding('u01G', 85)
			// 15% Glacier of Sorrow
			call buildConfig[0][0].addBuilding('u01J', 15)

			/*
			 * AI Level 0 (Newbie)
			 * Config 1
			 */
			call buildConfig[0][1].resetBuildings()
			// 85% Totem of Infamy
			call buildConfig[0][1].addBuilding('u01M', 85)
			// 15% Glacier of Sorrow
			call buildConfig[0][1].addBuilding('u01J', 15)

			/*
			 * AI Level 0 (Newbie)
			 * Config 2
			 */
			call buildConfig[0][2].resetBuildings()
			// 45% Monolith of Hatred
			call buildConfig[0][1].addBuilding('u01G', 45)
			// 35% Totem of Infamy
			call buildConfig[0][1].addBuilding('u01M', 35)
			// 20% Glacier of Sorrow
			call buildConfig[0][2].addBuilding('u01J', 20)

			/*
			 * AI Level 0 (Newbie)
			 * Config 3
			 */
			call buildConfig[0][3].resetBuildings()
			// 65% Monolith of Hatred
			call buildConfig[0][3].addBuilding('u01G', 65)
			// 10% Glacier of Sorrow
			call buildConfig[0][3].addBuilding('u01J', 10)
			// 25% Totem of Infamy
			call buildConfig[0][3].addBuilding('u01M', 25)

			/*
			 * AI Level 0 (Newbie)
			 * Config 4
			 */
			call buildConfig[0][4].resetBuildings()
			// 70% Monolith of Hatred
			call buildConfig[0][4].addBuilding('u01G', 70)
			// 15% Glacier of Sorrow
			call buildConfig[0][4].addBuilding('u01J', 15)
			// 15% Totem of Infamy
			call buildConfig[0][4].addBuilding('u01M', 15)

			/*****************************/
			/*	AI LEVEL 1 (N O R M A L) */
			/*****************************/

			/*
			 * AI Level 1 (Normal)
			 * Config 0
			 */
			call buildConfig[1][0].resetBuildings()
			// 85% Monolith of Terror
			call buildConfig[1][0].addBuilding('u01H', 85)
			// 15% Glacier of Misery
			call buildConfig[1][0].addBuilding('u01K', 15)

			/*
			 * AI Level 1 (Normal)
			 * Config 1
			 */
			call buildConfig[1][1].resetBuildings()
			// 85% Totem of Malice
			call buildConfig[1][1].addBuilding('u01R', 85)
			// 15% Glacier of Misery
			call buildConfig[1][1].addBuilding('u01K', 15)

			/*
			 * AI Level 1 (Normal)
			 * Config 2
			 */
			call buildConfig[1][2].resetBuildings()
			// 50% Monolith of Terror
			call buildConfig[1][2].addBuilding('u01H', 50)
			// 30% Totem of Malice
			call buildConfig[1][2].addBuilding('u01R', 30)
			// 20% Glacier of Misery
			call buildConfig[1][2].addBuilding('u01K', 20)

			/*
			 * AI Level 1 (Normal)
			 * Config 3
			 */
			call buildConfig[1][3].resetBuildings()
			// 60% Monolith of Terror
			call buildConfig[1][3].addBuilding('u01H', 65)
			// 10% Glacier of Misery
			call buildConfig[1][3].addBuilding('u01K', 10)
			// 25% Totem of Malice
			call buildConfig[1][3].addBuilding('u01R', 25)

			/*
			 * AI Level 1 (Normal)
			 * Config 4
			 */
			call buildConfig[1][4].resetBuildings()
			// 70% Monolith of Terror
			call buildConfig[1][4].addBuilding('u01H', 70)
			// 15% Glacier of Misery
			call buildConfig[1][4].addBuilding('u01K', 15)
			// 15% Totem of Malice
			call buildConfig[1][2].addBuilding('u01R', 15)

			/*****************************/
			/*	AI LEVEL 2 (I N S A N E) */
			/*****************************/

			/*
			 * AI Level 2 (Insane)
			 * Config 0
			 */
			call buildConfig[2][0].resetBuildings()
			// 85% Monolith of Destruction
			call buildConfig[2][0].addBuilding('u01I', 85)
			// 15% Glacier of Despair
			call buildConfig[2][0].addBuilding('u01L', 15)

			/*
			 * AI Level 2 (Insane)
			 * Config 1
			 */
			call buildConfig[2][1].resetBuildings()
			// 85% Totem of Corruption
			call buildConfig[2][1].addBuilding('u01T', 85)
			// 15% Glacier of Despair
			call buildConfig[2][1].addBuilding('u01L', 15)

			/*
			 * AI Level 2 (Insane)
			 * Config 2
			 */
			call buildConfig[2][2].resetBuildings()
			// 50% Monolith of Destruction
			call buildConfig[2][2].addBuilding('u01I', 50)
			// 30% Totem of Corruption
			call buildConfig[2][2].addBuilding('u01T', 30)
			// 20% Glacier of Despair
			call buildConfig[2][2].addBuilding('u01L', 20)

			/*
			 * AI Level 2 (Insane)
			 * Config 3
			 */
			call buildConfig[2][3].resetBuildings()
			// 65% Monolith of Destruction
			call buildConfig[2][3].addBuilding('u01I', 65)
			// 10% Glacier of Despair
			call buildConfig[2][3].addBuilding('u01L', 10)
			// 25% Totem of Corruption
			call buildConfig[2][3].addBuilding('u01T', 25)

			/*
			 * AI Level 2 (Insane)
			 * Config 4
			 */
			call buildConfig[2][4].resetBuildings()
			// 70% Monolith of Destruction
			call buildConfig[2][4].addBuilding('u01I', 70)
			// 15% Glacier of Despair
			call buildConfig[2][4].addBuilding('u01L', 15)
			// 15% Doom Orb
			call buildConfig[2][4].addBuilding('u01T', 15)
		endmethod
	endstruct
endscope