scope GameStart

	globals
		private constant real TEXT_DURATION = 7.00
        private constant real OPTIONS_RESULT_DELAY = 12.00
	    
		//MAP SETTINGS
        public constant string NAME = "Forsaken Bastion's Fall"
        public constant string VERSION = "0.3.0"
        public constant string RELEASE_DATE = "xx.xx.2015"
		
		private string SOUND_1 = "Sound\\Interface\\Rescue.wav"
        private string SOUND_2 = "Sound\\Interface\\ItemReceived.wav"
        private string SOUND_3 = "Sound\\Interface\\ClanInvitation.wav"
	
	endglobals
	
	struct GameStart
    		
		private static method onEnd takes nothing returns nothing
			call Sound.runSound(SOUND_1)
			
			static if TEST_MODE then
                call TimerStart(GetExpiredTimer(), 2.0, false, function Game.initialize)
            else
                call TimerStart(GetExpiredTimer(), OPTIONS_RESULT_DELAY, false, function Game.initialize)
            endif
            
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "The game will be started with the following Options:")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "\n|cffffcc00Game Mode:|r " + GameMode.name[GameMode.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "    " + GameMode.desc[GameMode.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "    " + "Repick: " + GameMode.repick[GameMode.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "|cffffcc00Game Type:|r " + GameType.name[GameType.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "    " + GameType.desc[GameType.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "|cffffcc00Defense Mode:|r " + DefenseMode.name[DefenseMode.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "    " + DefenseMode.desc[DefenseMode.current])
            
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "\n|cffffcc00Starting Gold for Forsakens:|r " + I2S(BaseGoldSystem.START_GOLD_FORSAKEN))
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "|cffffcc00Starting Lumber for Forsakens:|r " + I2S(BaseGoldSystem.START_LUMBER_FORSAKEN))
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "|cffffcc00Gold-Income for Forsakens:|r " + GoldIncome.getIncomeGoldPerTime(0))
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "|cffffcc00Starting Gold for Coalitions:|r " + I2S(BaseGoldSystem.START_GOLD_COALITION))
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 1000.00, "|cffffcc00Gold-Income for Coalitions:|r " + GoldIncome.getIncomeGoldPerTime(1))
        endmethod
		
		private static method onStart takes nothing returns nothing
			call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "The FBF Team proudly present...")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "\n|cffffcc00" + NAME + "|r")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "|cffffcc00Release Date: |r" + RELEASE_DATE)
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "|cffffcc00Version: |r" + VERSION)
            call TimerStart(NewTimer(), TEXT_DURATION + 3.0, false, function thistype.onEnd)
		endmethod
        
        static method initialize takes nothing returns nothing
            //Preload Sound
			call Sound.preload(SOUND_1)
			call Sound.preload(SOUND_2)
			call Sound.preload(SOUND_3)
	
			//deactivate user control for all players
            call SetUserControlForceOff(GetPlayersAll())
			
			call CinematicFadeBJ( bj_CINEFADETYPE_FADEOUT, 0.00, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0 )
            call Sound.runSound(SOUND_3)
			call onStart()
        endmethod
    
    endstruct
endscope