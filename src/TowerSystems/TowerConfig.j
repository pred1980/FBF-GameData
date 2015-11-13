scope TowerConfig

	struct TowerConfig
		private static TowerBuildConfig array buildConfig[6]
		
		static method setBuildConfigCommonTowers takes integer pid returns nothing
			local integer index = GetRandomInt(0,5)

			/*
			 * Config 1
			 */
			set buildConfig[0] = TowerBuildConfig.create()
			// 80% Black Spire
			call buildConfig[0].addBuilding('u00T')
			call buildConfig[0].addBuilding('u00T')
			call buildConfig[0].addBuilding('u00T')
			call buildConfig[0].addBuilding('u00T')
			// 20% Glacial Obelisk
			call buildConfig[0].addBuilding('u00W')
			
			/*
			 * Config 2
			 */
			set buildConfig[1] = TowerBuildConfig.create()
			// 80% Black Spire
			call buildConfig[1].addBuilding('u00T')
			call buildConfig[1].addBuilding('u00T')
			call buildConfig[1].addBuilding('u00T')
			call buildConfig[1].addBuilding('u00T')
			// 20% Glacial Obelisk
			call buildConfig[1].addBuilding('u00W')
			
			/*
			 * Config 3
			 */
			set buildConfig[2] = TowerBuildConfig.create()
			// 80% Black Spire
			call buildConfig[2].addBuilding('u00T')
			call buildConfig[2].addBuilding('u00T')
			call buildConfig[2].addBuilding('u00T')
			call buildConfig[2].addBuilding('u00T')
			// 20% Glacial Obelisk
			call buildConfig[2].addBuilding('u00W')
			
			/*
			 * Config 4
			 */
			set buildConfig[3] = TowerBuildConfig.create()
			// 80% Black Spire
			call buildConfig[3].addBuilding('u00T')
			call buildConfig[3].addBuilding('u00T')
			call buildConfig[3].addBuilding('u00T')
			call buildConfig[3].addBuilding('u00T')
			// 20% Glacial Obelisk
			call buildConfig[3].addBuilding('u00W')
			
			/*
			 * Config 5
			 */
			set buildConfig[4] = TowerBuildConfig.create()
			// 80% Black Spire
			call buildConfig[4].addBuilding('u00T')
			call buildConfig[4].addBuilding('u00T')
			call buildConfig[4].addBuilding('u00T')
			call buildConfig[4].addBuilding('u00T')
			// 20% Glacial Obelisk
			call buildConfig[4].addBuilding('u00W')
			
			/*
			 * Config 6
			 */
			set buildConfig[5] = TowerBuildConfig.create()
			// 80% Black Spire
			call buildConfig[5].addBuilding('u00T')
			call buildConfig[5].addBuilding('u00T')
			call buildConfig[5].addBuilding('u00T')
			call buildConfig[5].addBuilding('u00T')
			// 20% Glacial Obelisk
			call buildConfig[5].addBuilding('u00W')
			
			call TowerAIEventListener.getTowerBuildAI(pid).setConfig(buildConfig[index])
		endmethod
		
		static method setBuildConfigRareTowers takes nothing returns nothing
		
		endmethod
		
		static method setBuildConfigUniqueTowers takes nothing returns nothing
		
		endmethod
	
	endstruct

endscope