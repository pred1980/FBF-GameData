scope TowerConfig

	struct TowerConfig
		private static TowerBuildConfig array buildConfig[6]
		
		static method setBuildConfigCommonTowers takes nothing returns nothing
			/*
			 * Player 1
			 */
			set buildConfig[0] = TowerBuildConfig.create()
			// 80% Black Spire
			call buildConfig[0].addBuilding('u00T')
			call buildConfig[0].addBuilding('u00T')
			call buildConfig[0].addBuilding('u00T')
			call buildConfig[0].addBuilding('u00T')
			// 20% Glacial Obelisk
			call buildConfig[0].addBuilding('u00W')
			call TowerAIEventListener.getTowerBuildAI(0).setConfig(buildConfig[0])
			
			
		endmethod
		
		static method setBuildConfigRareTowers takes nothing returns nothing
		
		endmethod
		
		static method setBuildConfigUniqueTowers takes nothing returns nothing
		
		endmethod
	
	endstruct

endscope