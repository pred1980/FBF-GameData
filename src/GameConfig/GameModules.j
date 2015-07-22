scope GameModules

	struct GameModule
	
		static method initialize takes nothing returns nothing
			//Multiboard
            call FBFMultiboard.create()
			
			//Camera System
			call CameraSystem.initialize()
			
			//Hero Pick Systems
			call HeroPickInit.initialize()
			call HeroPickSystem.initialize()
			call HeroPickMode.initialize()
			
			//Hero Repick
			call Repick.initialize()
			
			//Hero Stats
			call HeroData.initialize()
			call HeroStats.initialize()
			
			//Tome Damage System System
			call TDS.initialize()
			
			//Item System
			call UnitInventory.initialize()
			call ItemShops.initialize()
			call Item.initialize()
			call Items.initialize()
			
			//Kill Streak System
			call KillStreakSystem.initialize()
			
			//Assist System
			call AssistSystem.initialize()
			
			//XP System
			call XPSystem.initialize()
			
			//Weather System
			//call IWS.initialize()
			
			//Tower System
			call TowerSystem.initialize()
			
			//Unit System
			call UnitSystem.initialize()
			
			//Gold System
			call BonusGoldOnStreak.initialize()
			
			//Evaluation System
			call Evaluation.initialize()
			
			//Web System
			call WebSystem.initialize()
			
			//Graveyard Systems
			call SpikeTrap.initialize()
			call SkeletonSystem.initialize()
			call GravestoneSystem.initialize()
			
			//Usability System
			call Usability.initialize()
			
			//KI Systems
			call KI.initialize()
			
			//create Brood Mother
            call BroodMother.create()
			
            //create EggSystem
            call EggSystem.create()
			
            //Create Titan Devourer
            call Titan.create()
			
            //Create Coalition Unit Shops
            call UnitShopSystem.initialize()
			
            //init Final Mode
            call FinalMode.initialize()
			
            //create first Coalition Teleporter in the AOS
            if (Game.getCoalitionPlayers() > 0) then
				call CoalitionTeleport.initialize()
			endif
			
            //create first Forsaken Teleporter in the AOS
			if (Game.getForsakenPlayers() > 0) then
				call ForsakenTeleport.initialize()
			endif
			
			//init Defense Mode
			call StandardDefenseInit.initialize()
			
			//Test: Send Unit System
			call CustomCreepSystem.initialize()
		endmethod
	
	endstruct

endscope