scope CreepSystemModule
    globals
        private constant real TEXT_DURATION = 7.5
    endglobals

    //! textmacro IMPLEMENT_CONFIG_MODULE takes CONFIG_IDENTIFIER
    module $CONFIG_IDENTIFIER$
        static method OnRoundStartingTick takes nothing returns nothing
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0.0 ,0.0 ,TEXT_DURATION , "Round " + I2S(actualRound) +"  ending! New round in: " + R2S(nextRoundTime))
        endmethod
        
        static method OnRoundStart takes nothing returns nothing
            local integer i
			local integer max
            local Wave w = 0
			
			//Gibt es Spieler auf der Forsakenseite, dann werden nur dort Creeps laufen!
			if (Game.getForsakenPlayers() > 0) then
				set i = 0
				set max = 5
			else // Gibt es nur Spieler auf der Coalitionseite, dann lass die Creeps nur von dort laufen!
				set i = 6
				set max = 11
			endif
            
            loop
                exitwhen i > max
                if Game.isPlayerInGame(i) then
                    set w = Wave.create(Player(bj_PLAYER_NEUTRAL_VICTIM), i, actualRound)
                    call SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_FOOD_USED, actualRound )
                endif
                set i = i + 1
            endloop
            
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0.0 ,0.0 ,TEXT_DURATION , "|cffffcc00Round " + I2S(actualRound) +"|r\n" + "*** |cff679bf2" + RoundText.getTextOfRound(actualRound) + "|r ***")
        endmethod
        
        static method OnRoundFinishingTick takes nothing returns nothing
            call ClearTextMessages()
            if R2I(actualRoundTime) == 1.00 then
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "Round |cffffcc00"+I2S(actualRound)+"|r finishes in |cffffff001|r second.")
            else
				call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "Round |cffffcc00"+I2S(actualRound)+"|r finishes in |cffffff00" + I2S(R2I(actualRoundTime)) + "|r seconds.")
            endif
			call Sound.runSound(GLOBAL_SOUND_2)
        endmethod
        
        static method OnRoundFinished takes nothing returns nothing
            local integer i = 0
            
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0.0 ,0.0 ,TEXT_DURATION , "*** Round |cffffcc00"+I2S(actualRound)+"|r finished! ***")
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) and GetPlayerRace(Player(i)) == RACE_UNDEAD then
                    call Game.playerAddLumber(i, Evaluation.getLumber(actualRound))
                    call DisplayTimedTextToPlayer(Player(i),0.0 ,0.0 ,TEXT_DURATION , "You received " + "|cffffcc00" + I2S(Evaluation.getLumber(actualRound)) +"|r Lumber.")
                endif
                set i = i + 1
            endloop
            
            //Update Forsaken Teleporter Places
            call ForsakenTeleport.update()
			//Update Coalition Teleporter Places
            call CoalitionTeleport.update()
            //Create Wardens
            call SpawnWarden.create()
            //Remove the rest of the creeps?
            if ForsakenUnits.removeCreeps then
                call ForsakenUnits.removeAll()
            endif
            
            //Wenn akt. Runde groesser 5 und 13 ist, dann wechsel den Acolyt
            if actualRound == 6 then
                call TowerSystem.changeBuilder()
            endif
            if actualRound == 13 then
                call TowerSystem.changeBuilder()
            endif
            
        endmethod
        
        // Example. Put your own conditions when to start a new round here (e.g. unit count)
        static method StartNextRound takes nothing returns boolean
            return creepCount == RoundType.getStartNextRound() 
        endmethod
    endmodule
    //! endtextmacro

endscope
