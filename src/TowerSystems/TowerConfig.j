scope TowerConfig

	struct TowerConfig
		private static TowerBuildConfig array buildConfig[3][6]
		
		static method setBuildConfigCommonTowers takes integer pid, integer aiLevel returns nothing
			local integer index = GetRandomInt(0,2)

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
			
			call TowerAIEventListener.getTowerBuildAI(pid).setConfig(buildConfig[aiLevel][index])
		endmethod
		
		static method setBuildConfigRareTowers takes nothing returns nothing
		
		endmethod
		
		static method setBuildConfigUniqueTowers takes nothing returns nothing
		
		endmethod
	
	endstruct

endscope