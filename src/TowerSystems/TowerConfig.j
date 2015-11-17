scope TowerConfig

	struct TowerConfig
		private static TowerBuildConfig array buildConfig[3][6]
		
		static method setBuildConfigCommonTowers takes integer pid, integer aiLevel returns nothing
			local integer index = GetRandomInt(0,4)
			
			call BJDebugMsg("AI Level: " + I2S(aiLevel))
			call BJDebugMsg("AI Index: " + I2S(index))
			
			if (aiLevel == 0) then
				/*****************************/
				/*	AI LEVEL 0 (N E W B I E) */
				/*****************************/
				
				/*
				 * AI Level 0 (Newbie)
				 * Config 0
				 */
				set buildConfig[aiLevel][0] = TowerBuildConfig.create()
				// 80% Shady Spire
				call buildConfig[aiLevel][0].addBuilding('u00R')
				call buildConfig[aiLevel][0].addBuilding('u00R')
				call buildConfig[aiLevel][0].addBuilding('u00R')
				call buildConfig[aiLevel][0].addBuilding('u00R')
				// 20% Cold Obelisk
				call buildConfig[aiLevel][0].addBuilding('u00U')
				
				/*
				 * AI Level 0 (Newbie)
				 * Config 1
				 */
				set buildConfig[aiLevel][1] = TowerBuildConfig.create()
				// 80% Flaming Rock
				call buildConfig[aiLevel][1].addBuilding('u00Y')
				call buildConfig[aiLevel][1].addBuilding('u00Y')
				call buildConfig[aiLevel][1].addBuilding('u00Y')
				call buildConfig[aiLevel][1].addBuilding('u00Y')
				// 20% Cold Obelisk
				call buildConfig[aiLevel][1].addBuilding('u00U')
				
				/*
				 * AI Level 0 (Newbie)
				 * Config 2
				 */
				set buildConfig[aiLevel][2] = TowerBuildConfig.create()
				// 80% Cursed Gravestone
				call buildConfig[aiLevel][2].addBuilding('u00X')
				call buildConfig[aiLevel][2].addBuilding('u00X')
				call buildConfig[aiLevel][2].addBuilding('u00X')
				call buildConfig[aiLevel][2].addBuilding('u00X')
				// 20% Cold Obelisk
				call buildConfig[aiLevel][2].addBuilding('u00U')
				
				/*
				 * AI Level 0 (Newbie)
				 * Config 3
				 */
				set buildConfig[aiLevel][3] = TowerBuildConfig.create()
				// 57% Shady Spire
				call buildConfig[aiLevel][3].addBuilding('u00R')
				call buildConfig[aiLevel][3].addBuilding('u00R')
				call buildConfig[aiLevel][3].addBuilding('u00R')
				call buildConfig[aiLevel][3].addBuilding('u00R')
				// 14% Cold Obelisk
				call buildConfig[aiLevel][3].addBuilding('u00U')
				// 29% Flaming Rock
				call buildConfig[aiLevel][3].addBuilding('u00Y')
				call buildConfig[aiLevel][3].addBuilding('u00Y')
				
				/*
				 * AI Level 0 (Newbie)
				 * Config 4
				 */
				set buildConfig[aiLevel][4] = TowerBuildConfig.create()
				// 57% Shady Spire
				call buildConfig[aiLevel][4].addBuilding('u00R')
				call buildConfig[aiLevel][4].addBuilding('u00R')
				call buildConfig[aiLevel][4].addBuilding('u00R')
				call buildConfig[aiLevel][4].addBuilding('u00R')
				// 14% Cold Obelisk
				call buildConfig[aiLevel][4].addBuilding('u00U')
				// 29% Cursed Gravestone
				call buildConfig[aiLevel][4].addBuilding('u00X')
				call buildConfig[aiLevel][4].addBuilding('u00X')
			elseif (aiLevel == 1) then
				
				/*****************************/
				/*	AI LEVEL 1 (N O R M A L) */
				/*****************************/
				
				/*
				 * AI Level 1 (Normal)
				 * Config 0
				 */
				set buildConfig[aiLevel][0] = TowerBuildConfig.create()
				// 80% Dark Spire
				call buildConfig[aiLevel][0].addBuilding('u00S')
				call buildConfig[aiLevel][0].addBuilding('u00S')
				call buildConfig[aiLevel][0].addBuilding('u00S')
				call buildConfig[aiLevel][0].addBuilding('u00S')
				// 20% Frosty Obelisk
				call buildConfig[aiLevel][0].addBuilding('u00V')
				
				/*
				 * AI Level 1 (Normal)
				 * Config 1
				 */
				set buildConfig[aiLevel][1] = TowerBuildConfig.create()
				// 80% Blazing Rock
				call buildConfig[aiLevel][1].addBuilding('u00Z')
				call buildConfig[aiLevel][1].addBuilding('u00Z')
				call buildConfig[aiLevel][1].addBuilding('u00Z')
				call buildConfig[aiLevel][1].addBuilding('u00Z')
				// 20% Frosty Obelisk
				call buildConfig[aiLevel][1].addBuilding('u00V')
				
				/*
				 * AI Level 1 (Normal)
				 * Config 2
				 */
				set buildConfig[aiLevel][2] = TowerBuildConfig.create()
				// 80% Cursed Tombstone
				call buildConfig[aiLevel][2].addBuilding('u011')
				call buildConfig[aiLevel][2].addBuilding('u011')
				call buildConfig[aiLevel][2].addBuilding('u011')
				call buildConfig[aiLevel][2].addBuilding('u011')
				// 20% Frosty Obelisk
				call buildConfig[aiLevel][2].addBuilding('u00V')
				
				/*
				 * AI Level 1 (Normal)
				 * Config 3
				 */
				set buildConfig[aiLevel][3] = TowerBuildConfig.create()
				// 57% Dark Spire
				call buildConfig[aiLevel][3].addBuilding('u00S')
				call buildConfig[aiLevel][3].addBuilding('u00S')
				call buildConfig[aiLevel][3].addBuilding('u00S')
				call buildConfig[aiLevel][3].addBuilding('u00S')
				// 14% Frosty Obelisk
				call buildConfig[aiLevel][3].addBuilding('u00V')
				// 29% Blazing Rock
				call buildConfig[aiLevel][3].addBuilding('u00Z')
				call buildConfig[aiLevel][3].addBuilding('u00Z')
				
				/*
				 * AI Level 1 (Normal)
				 * Config 4
				 */
				set buildConfig[aiLevel][4] = TowerBuildConfig.create()
				// 57% Dark Spire
				call buildConfig[aiLevel][4].addBuilding('u00S')
				call buildConfig[aiLevel][4].addBuilding('u00S')
				call buildConfig[aiLevel][4].addBuilding('u00S')
				call buildConfig[aiLevel][4].addBuilding('u00S')
				// 14% Frosty Obelisk
				call buildConfig[aiLevel][4].addBuilding('u00V')
				// 29% Cursed Tombstone
				call buildConfig[aiLevel][4].addBuilding('u011')
				call buildConfig[aiLevel][4].addBuilding('u011')
			else
			
			endif
			
			call TowerAIEventListener.getTowerBuildAI(pid).setConfig(buildConfig[aiLevel][index])
		endmethod
		
		static method setBuildConfigRareTowers takes nothing returns nothing
		
		endmethod
		
		static method setBuildConfigUniqueTowers takes nothing returns nothing
		
		endmethod
	
	endstruct

endscope