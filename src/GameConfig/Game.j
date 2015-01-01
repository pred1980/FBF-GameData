scope Game

    globals
        private constant integer DEFAUlT_FOOD_CAP = 20
		private constant integer DAY_TIME = 3
        
        //GAME MODES
        constant integer NORMAL = 0
        
        //GAME TYPES
        constant integer TYPE_1 = 0
        constant integer TYPE_2 = 1
        
        //UNDEAD DEFENSE TYPES
        constant integer DEF_1 = 0
        
        private constant string SKY = "Environment\\Sky\\FelwoodSky\\FelwoodSky.mdl"
        
        //Forsaken Heart
        private constant integer HEART_ID = 'H014'
            
    endglobals
    
    struct Game
    
        //********************************\\
        // - Kameraeinstellungen werden hier initialisiert
        // - Gold und Holz werden fuer alle Spieler initialisiert
        // - Events:
        //     * onLeave - Spieler verl?sst das Spiel
        //     * onInit - Spieleranzahl ermitteln
        //********************************\\
        static boolean array isBot
        static integer playerCount = 0
        static player array players[12]
        static integer forsakenPlayers = 0
        static integer coalitionPlayers = 0
        static boolean started = false
        static string array playerName[12]
        static boolean forsakenHaveWon = false
        
        //*****************************************************\\
        //**************** PUBLIC METHODS *********************\\
        //*****************************************************\\
        
        static method getForsakenPlayers takes nothing returns integer
            return .forsakenPlayers
        endmethod
        
        static method getCoalitionPlayers takes nothing returns integer
            return .coalitionPlayers
        endmethod
        
        //***********************************\\
        //****** GLOBAL HELPER METHODS ******\\
        //***********************************\\
        
        //set  gold
        static method setPlayerGold takes integer pid, integer value returns nothing
            call SetPlayerState(.players[pid], PLAYER_STATE_RESOURCE_GOLD, value)
        endmethod
        
        //set start lumber 
        static method setPlayerLumber takes integer pid, integer value returns nothing
            call SetPlayerState(.players[pid], PLAYER_STATE_RESOURCE_LUMBER, value)
        endmethod
        
        /*
		 * NOTE: Wirft true zurück wenn:
		 *       1. der Game Slot von einem richtigen Spieler besetzt ist
		 *       2. ein Computer darauf plaziert wurde 
		 */ 
        static method isPlayerInGame takes integer i returns boolean
            return GetPlayerSlotState(Player(i)) != PLAYER_SLOT_STATE_EMPTY
        endmethod
		
		//Checkt ob es sich um einen menschlichen Spieler handelt und ob er noch im Spiel ist
		static method isRealPlayer takes integer i returns boolean
            return GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING
        endmethod
		
		//count players
		static method getPlayerCount takes nothing returns integer
			local integer i = 0
            local integer amount = 0
			
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if isPlayerInGame(i) and isRealPlayer(i) then
                    set amount = amount + 1
                endif
                set i = i + 1
            endloop
			
			return amount
		endmethod
        
        static method changePlayerName takes player p returns nothing
            //reset to default
            call SetPlayerName(p, BaseMode.origPlayerName[GetPlayerId(p)])
            //set new player name
            call SetPlayerName(p, GetPlayerName(p) + "(" + GetUnitName(BaseMode.pickedHero[GetPlayerId(p)]) + ")")
        endmethod
        
        //set player Count
        static method updatePlayerCount takes nothing returns nothing
            set .playerCount = .playerCount - 1
        endmethod
        
        //add Gold to a specific Player
        static method playerAddGold takes integer pid, integer goldAdd returns nothing
            if goldAdd > 0 then
                call SetPlayerState(.players[pid], PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(.players[pid], PLAYER_STATE_RESOURCE_GOLD) + goldAdd)
            endif
        endmethod
        
        //add Lumber to a specific Player
        static method playerAddLumber takes integer pid, integer lumberAdd returns nothing
            if lumberAdd > 0 then
                call SetPlayerState(.players[pid], PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(.players[pid], PLAYER_STATE_RESOURCE_LUMBER) + lumberAdd)
            endif
        endmethod
        
        //remove Gold to a specific Player
        static method playerRemoveGold takes integer pid, integer goldRemove returns nothing
            call SetPlayerState(.players[pid], PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(.players[pid], PLAYER_STATE_RESOURCE_GOLD) - goldRemove)
        endmethod
        
        static method getPlayerStartGold takes player p returns integer
            local integer gold = 0
            
            if ( GetPlayerRace(p) == RACE_UNDEAD ) then
                set gold = BaseGoldSystem.START_GOLD_FORSAKEN
            else
                set gold = BaseGoldSystem.START_GOLD_COALITION
            endif
            return gold
        endmethod
        
        static method getPlayerStartLumber takes player p returns integer
            if ( GetPlayerRace(p) == RACE_UNDEAD ) then
                return BaseGoldSystem.START_LUMBER_FORSAKEN
            endif
            return 0
        endmethod
        
        static method getPlayerRace takes player whichPlayer returns string
            local race r = GetPlayerRace(whichPlayer)

            if (r == RACE_HUMAN) then
                return "RACE_HUMAN"
            elseif (r == RACE_ORC) then
                return "RACE_ORC"
            elseif (r == RACE_NIGHTELF) then
                return "RACE_NIGHTELF"
            elseif (r == RACE_UNDEAD) then
                return "RACE_UNDEAD"
            else
                // Unrecognized Race
                return ""
            endif
        endmethod
        
        //Gibt das akt. Gesamt Hero Level aller Helden zur?ck
        static method getCoalitionHeroLevelSum takes nothing returns integer
            local integer i = 0
            local integer level = 0
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if isPlayerInGame(i) and GetPlayerRace(Player(i)) != RACE_UNDEAD then
                    set level = level + GetHeroLevel(BaseMode.pickedHero[i])
                endif
                set i = i + 1
            endloop
            
            return level
        endmethod
        
        //Gibt das akt. Gesamt Hero Level aller Helden zur?ck
        static method getForsakenHeroLevelSum takes nothing returns integer
            local integer i = 0
            local integer level = 0
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if isPlayerInGame(i) and GetPlayerRace(Player(i)) == RACE_UNDEAD then
                    set level = level + GetHeroLevel(BaseMode.pickedHero[i])
                endif
                set i = i + 1
            endloop
            
            return level
        endmethod
        
        //*****************************************************\\
        //*************** END OF CONFIGURATION*****************\\
        //*****************************************************\\
        
        /*
         * This function initializes misc Systems (ex.: Gold-Income)
         */
        static method initMiscSystem takes nothing returns nothing
            call RoundSystem.startSystem()
            call GoldIncome.create(true) //activate Forsaken Gold Income
            call GoldIncome.create(false) //activate Coalition Gold Income
        endmethod
        
		//init player state
        static method initPlayers takes integer pid returns nothing
            call SetPlayerState( .players[pid], PLAYER_STATE_RESOURCE_FOOD_USED, 0 )
            call SetPlayerState( .players[pid], PLAYER_STATE_RESOURCE_FOOD_CAP, DEFAUlT_FOOD_CAP )
            call SetPlayerState( .players[pid], PLAYER_STATE_RESOURCE_LUMBER, 0 )
            set .playerName[pid] = GetPlayerName(.players[pid])
        endmethod
        
        static method initPlayerCams takes integer pid returns nothing
            call BJDebugMsg("Trying to init Cam for Player " + I2S(pid))
			if (GetLocalPlayer() == .players[pid]) then
				call BJDebugMsg("Initilialized Cam for Player " + I2S(pid) + "!")
                call CameraSetupApplyForceDuration(gg_cam_MainCameraView, true, 0)
                call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, CameraSetupGetField(gg_cam_MainCameraView, CAMERA_FIELD_TARGET_DISTANCE), 0)
            endif
            call CameraSetSmoothingFactor(1000)
            call CinematicFadeBJ( bj_CINEFADETYPE_FADEIN, 2.00, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 0, 0, 0, 0 )
        endmethod
        
        static method initVisibleAreas takes integer pid returns nothing
            if GetPlayerRace(Player(pid)) == RACE_UNDEAD then
                call CreateFogModifierRectBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, gg_rct_UDVisibleArea5 )
            else
                call CreateFogModifierRectBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, gg_rct_INFVisibleArea1 )
                call CreateFogModifierRadiusLocBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, GetRectCenter(gg_rct_HumanHeroMainBase), 1200 )
                call CreateFogModifierRadiusLocBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, GetRectCenter(gg_rct_OrcHeroMainBase), 1200 )
                call CreateFogModifierRadiusLocBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, GetRectCenter(gg_rct_NightelfHeroMainBase), 1300 )
            endif
            call CreateFogModifierRectBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, gg_rct_UDVisibleArea1 )
            call CreateFogModifierRectBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, gg_rct_UDVisibleArea2 )
            call CreateFogModifierRectBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, gg_rct_UDVisibleArea3 )
            call CreateFogModifierRectBJ( true, .players[pid], FOG_OF_WAR_VISIBLE, gg_rct_UDVisibleArea4 )
        endmethod
		
        static method assignPlayerOptions takes nothing returns nothing
            local integer i = 0
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if isPlayerInGame(i) then
                    call initPlayers(i)
                    call initPlayerCams(i)
                    call initVisibleAreas(i)
                    if ( GetPlayerRace(Player(i)) == RACE_UNDEAD ) then
                        //start gold + lumber for Forsaken Players
                        call setPlayerGold(i, BaseGoldSystem.START_GOLD_FORSAKEN)
                        call setPlayerLumber(i, BaseGoldSystem.START_LUMBER_FORSAKEN)
                        static if not TEST_MODE then
                            set .forsakenPlayers = .forsakenPlayers + 1
                        endif
                    else
                        call setPlayerGold(i, BaseGoldSystem.START_GOLD_COALITION)
                        static if not TEST_MODE then
                            set .coalitionPlayers = .coalitionPlayers + 1
                        endif
                    endif
                endif
                set i = i + 1
            endloop
        endmethod
        
        
        
        static method initRegionalFog takes nothing returns nothing
            local fogData fd1
            local fogData fd2
            local fogData fd3
            local fog f
            
            set fd1 = fogData.create()
            set fd1.red = .10
            set fd1.blue = .15
            set fd1.green = .20
            set fd1.zStart = 1700
            set fd1.zEnd = 2700
            set f = fog.createCircular(fd1, GetRectCenterX(gg_rct_GravestoneRect0), GetRectCenterY(gg_rct_GravestoneRect0), 1200)
            set f.blendWidth = 600
            
            set fd2 = fogData.create()
            set fd2.red = .10
            set fd2.blue = .15
            set fd2.green = .20
            set fd2.zStart = 1700
            set fd2.zEnd = 2700
            set f = fog.createCircular(fd2, GetRectCenterX(gg_rct_GravestoneRect1), GetRectCenterY(gg_rct_GravestoneRect1), 1200)
            set f.blendWidth = 600
            
            set fd3 = fogData.create()
            set fd3.red = .10
            set fd3.blue = .15
            set fd3.green = .20
            set fd3.zStart = 1700
            set fd3.zEnd = 2700
            set f = fog.createCircular(fd3, GetRectCenterX(gg_rct_GravestoneRect2), GetRectCenterY(gg_rct_GravestoneRect2), 1200)
            set f.blendWidth = 600
            
        endmethod
    
        static method onLeave takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 10.00, GetPlayerNameColored(.players[id], false) + " has left the game.")
            
            //set new count of players
            if (GetPlayerRace(p) == RACE_UNDEAD) then
                set .forsakenPlayers = .forsakenPlayers - 1
            else
                set .coalitionPlayers = .coalitionPlayers - 1
            endif
            
            call updatePlayerCount()
            //Update Multiboard
            call FBFMultiboard.onPlayerLeftGame(id)
            //Update Brood Mother HP+Damage
            call BroodMother.onUpdate()
            //Update the Offspring the Brood Mother
            call Egg.onUpdate()
            //Update Titan Devourer HP+Damage
            call Titan.onUpdate()
            //Remove Hero from battlefield
            call BaseMode.removeHero(id)
            //if Forsaken Player? --> Remove all Towers and the acolyt of this player
            if (GetPlayerRace(p) == RACE_UNDEAD) then
                call TowerSystem.removeTowersAndBuilder(p)
            endif
        endmethod
        
		static method onHeroLevelUp takes nothing returns nothing
            local player p = GetTriggerPlayer()
			local integer id = GetPlayerId(p)
			
			if GetPlayerController(p) == MAP_CONTROL_USER then
				//Update Multiboard
				call FBFMultiboard.onUpdateHeroLevel(id, GetLevelingUnit())
			endif
        endmethod
        
        static method onUnitDeath takes nothing returns nothing
            local integer i = 0
            local unit killingUnit = GetKillingUnit()
            local player killingPlayer = GetOwningPlayer(killingUnit)
            local unit killedUnit = GetTriggerUnit()
            local player killedPlayer = GetTriggerPlayer()
            local integer pidKilled = GetPlayerId(killedPlayer)
			local integer pidKilling = GetPlayerId(killingPlayer)
            
            if IsUnitEnemy(killedUnit, killingPlayer) then
                if GetOwningPlayer(killedUnit) != Player(PLAYER_NEUTRAL_PASSIVE) then // Helden bei der Auswahl
                    call BonusGoldOnDeath.showDeathMessageAndUpdateGold(killedUnit, killingUnit)
					if GetPlayerController(GetOwningPlayer(killingUnit)) == MAP_CONTROL_USER then
						call FBFMultiboard.onUpdateUnitKills(pidKilling)
						call FBFMultiboard.onUpdateTowerKills(pidKilling)
					endif
                endif
            endif
			
			if GetPlayerController(GetOwningPlayer(killedUnit)) == MAP_CONTROL_USER then
				//Ist die getoetete Einheit ein Held und gehoert einem Spieler?
				if IsUnitType(killedUnit, UNIT_TYPE_HERO) then
					call PlayerStats.setPlayerDeath(killedPlayer)
					//Update Multiboard (Deaths)
					call FBFMultiboard.onUpdateDeaths(pidKilled)
					call FBFMultiboard.onUpdateStatus(pidKilled, killedUnit)
					
					//Revive the killed Hero
					call HeroRespawn.reviveHero(killedUnit, 0., true)
				endif
				//Ist der Killer ein Held und gehoert einem Spieler?
				if IsUnitType(killingUnit, UNIT_TYPE_HERO) then
					call FBFMultiboard.onUpdateHeroKills(pidKilling)
				endif
			endif
                
			//Ist die getoetete Einheit das Forsaken Heart, dann beende das Spiel
			if GetUnitTypeId(killedUnit) == HEART_ID then
				call onGameOver()
			endif
			
			//ist die getoetet Einheit eine Forsaken Defense Unit, dann entferne sie aus der Gruppe,
			//damit das MB die richtige Anzahl anzeigt
			if ForsakenUnits.isForsakenUnit(killedUnit) then
				call ForsakenUnits.remove(killedUnit)
			endif
            
        endmethod
        
        public static method onGameOver takes nothing returns nothing
            local timer t = NewTimer()
            
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call VolumeGroupSetVolumeBJ(SOUND_VOLUMEGROUP_AMBIENTSOUNDS, 0.00)
            call VolumeGroupSetVolumeBJ(SOUND_VOLUMEGROUP_SPELLS, 0.00)
            call VolumeGroupSetVolumeBJ(SOUND_VOLUMEGROUP_COMBAT, 0.00)
            call VolumeGroupSetVolumeBJ(SOUND_VOLUMEGROUP_FIRE, 0.00)
            call CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 5.00, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.00, 100.00, 100.00, 0)
            call PauseAllUnitsBJ(true)
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 5.00, "Thank you for playing Forsaken Bastion's Fall!")
            
            call TimerStart(t, 10.0, false, function thistype.onGameOverOutro )
        endmethod
        
        static method onGameOverOutro takes nothing returns nothing
            local integer i = 0
            
            call ReleaseTimer(GetExpiredTimer())
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if isPlayerInGame(i) then
                    if .forsakenHaveWon then
                        if ( GetPlayerRace(Player(i)) == RACE_UNDEAD ) then
                            call CustomVictoryBJ( Player(i), false, true )
                        else
                            call CustomDefeatBJ( Player(i), "You lost!" )
                        endif
                    else
                        if ( GetPlayerRace(Player(i)) == RACE_UNDEAD ) then
                            call CustomDefeatBJ( Player(i), "You lost!" )
                        else
                            call CustomVictoryBJ( Player(i), false, true )
                        endif
                    endif
                endif
                set i = i + 1
            endloop
        endmethod
        
        static method initialize takes nothing returns nothing
            local integer i = 0
			local trigger leaveTrig = CreateTrigger()
            
			call ReleaseTimer(GetExpiredTimer())
			
			//on Death Event
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onUnitDeath)
            
            //Setting Player Datas
            loop
                exitwhen i >= bj_MAX_PLAYERS
                set .isBot[i] = false
                //Checking for Players and Bots
                if isPlayerInGame(i) then
                    set .players[i] = Player(i)
                    
					//adding real Player leaves game Event
					if isRealPlayer(i) then
						call TriggerRegisterPlayerEventLeave(leaveTrig, .players[i])
						call TriggerAddAction(leaveTrig, function thistype.onLeave)
                    endif
					//Adding Hero LevelUp Event
					call RegisterPlayerUnitEventForPlayer(EVENT_PLAYER_HERO_LEVEL, function thistype.onHeroLevelUp, .players[i])
                    
                    if GetPlayerRace(Player(i)) == RACE_UNDEAD then
                        //Spieler Neutral-Extra ist Verbuendeter mit den Untoten
                        call SetPlayerAllianceStateBJ(Player(i), Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_ALLIED_VISION)
                        call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), Player(i), bj_ALLIANCE_ALLIED_VISION)
                        call SetPlayerAllianceStateBJ(Player(i), Player(bj_PLAYER_NEUTRAL_VICTIM), bj_ALLIANCE_UNALLIED)
                        call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_VICTIM), Player(i), bj_ALLIANCE_UNALLIED)
                    else
                        //Spieler Neutral-Opfer ist Verbuendeter mit der Alliance
                        call SetPlayerAllianceStateBJ(Player(i), Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_UNALLIED)
                        call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), Player(i), bj_ALLIANCE_UNALLIED)
                        call SetPlayerAllianceStateBJ(Player(i), Player(bj_PLAYER_NEUTRAL_VICTIM), bj_ALLIANCE_ALLIED_VISION)
                        call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_VICTIM), Player(i), bj_ALLIANCE_ALLIED_VISION)
                    endif
					
					//only count if it's a real player
                    if isRealPlayer(i) then
						set .playerCount = .playerCount + 1
					endif
                endif
                set i = i + 1
            endloop
            
            //die beiden Creep Spieler als Feinde setzen und als Bot markieren
            call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_VICTIM), Player(bj_PLAYER_NEUTRAL_EXTRA), bj_ALLIANCE_UNALLIED)
            call SetPlayerAllianceStateBJ(Player(bj_PLAYER_NEUTRAL_EXTRA), Player(bj_PLAYER_NEUTRAL_VICTIM), bj_ALLIANCE_UNALLIED)
            set .isBot[GetPlayerId(Player(bj_PLAYER_NEUTRAL_EXTRA))] = true
            set .isBot[GetPlayerId(Player(bj_PLAYER_NEUTRAL_VICTIM))] = true
			call SetPlayerName( Player(bj_PLAYER_NEUTRAL_VICTIM), "The Coalition" )
			call SetPlayerName( Player(bj_PLAYER_NEUTRAL_EXTRA), "The Forsaken" )
            
            call SetSkyModel(SKY)
			call SetFloatGameState(GAME_STATE_TIME_OF_DAY, DAY_TIME)
            call SuspendTimeOfDay( false )
            
            //Wechsel den Ownser der Forsaken Fountain, damit nur Undead dort sich heilen koennen
            call SetUnitOwner( gg_unit_n006_0025, Player(bj_PLAYER_NEUTRAL_EXTRA), true )
			
			//activate user control for all players
            call SetUserControlForceOn(GetPlayersAll())
			
			set .started = true
			
			//INIT GAME MODULES
			call assignPlayerOptions()
			call initRegionalFog()
			call GameModule.initialize()
		endmethod
        
    endstruct
	
endscope
