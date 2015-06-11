scope GameStart

	globals
		private constant real PRESENTATION_TEXT_DURATION = 4.00
		private constant real RESULT_TEXT_DURATION = 10.00
        private constant real OPTIONS_RESULT_DELAY = 13.00
	    
		//MAP SETTINGS
        public constant string NAME = "Forsaken Bastion's Fall"
        public constant string VERSION = "0.3.5"
        public constant string RELEASE_DATE = "11.06.2015"
		
		private string SOUND_1 = "Sound\\Interface\\Rescue.wav"
        private string SOUND_2 = "Sound\\Interface\\ItemReceived.wav"
        private string SOUND_3 = "Sound\\Interface\\ClanInvitation.wav"
	
	endglobals
	
	struct GameStart
    		
		private static method onEnd takes nothing returns nothing
			call Sound.runSound(SOUND_1)
			
			call TimerStart(GetExpiredTimer(), OPTIONS_RESULT_DELAY, false, function Game.initialize)
            
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "The game will be started with the following Options:")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "\n|cffffcc00Game Mode:|r " + GameMode.name[GameMode.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "    " + GameMode.desc[GameMode.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "    " + "Repick: " + GameMode.repick[GameMode.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "|cffffcc00Game Type:|r " + GameType.name[GameType.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "    " + GameType.desc[GameType.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "|cffffcc00Defense Mode:|r " + DefenseMode.name[DefenseMode.current])
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "    " + DefenseMode.desc[DefenseMode.current])
            
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "\n|cffffcc00Starting Gold for Forsakens:|r " + I2S(BaseGoldSystem.START_GOLD_FORSAKEN))
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "|cffffcc00Starting Lumber for Forsakens:|r " + I2S(BaseGoldSystem.START_LUMBER_FORSAKEN))
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "|cffffcc00Gold-Income for Forsakens:|r " + GoldIncome.getIncomeGoldPerTime(0))
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "|cffffcc00Starting Gold for Coalitions:|r " + I2S(BaseGoldSystem.START_GOLD_COALITION))
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, RESULT_TEXT_DURATION, "|cffffcc00Gold-Income for Coalitions:|r " + GoldIncome.getIncomeGoldPerTime(1))
        endmethod
		
		private static method onStart takes nothing returns nothing
			call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, PRESENTATION_TEXT_DURATION, "The FBF Team proudly present...")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, PRESENTATION_TEXT_DURATION, "\n|cffffcc00" + NAME + "|r")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, PRESENTATION_TEXT_DURATION, "|cffffcc00Release Date: |r" + RELEASE_DATE)
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, PRESENTATION_TEXT_DURATION, "|cffffcc00Version: |r" + VERSION)
            call TimerStart(NewTimer(), PRESENTATION_TEXT_DURATION + 3.0, false, function thistype.onEnd)
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