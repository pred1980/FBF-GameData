scope GameStart

	globals
		private constant real GAME_START_DELAY = 0.1
		private constant real GAME_START_DELAY_HOSTBOT = 10.0
		private constant real TEXT_DURATION = 10.00
		private constant real TIMER_INTERVAL = 0.25
		private constant real GAME_MODE_OPTIONS_TIME = 45.00
        private constant real OPTIONS_RESULT_DELAY = 15.00
		
		private constant integer GAME_MODE_COUNT = 2
        private constant integer GAME_TYPE_COUNT = 1
        private constant integer GAME_DEFENSE_COUNT = 1
        
		//MAP SETTINGS
        public constant string NAME = "Forsaken Bastion's Fall"
        public constant string VERSION = "0.3.0"
        public constant string RELEASE_DATE = "xx.xx.2014"
		
		/* Test Mode Config*/
        private constant boolean MAP_HOSTED_BY_BOT = true
		
		private string SOUND_1 = "Sound\\Interface\\Rescue.wav"
        private string SOUND_2 = "Sound\\Interface\\ItemReceived.wav"
        private string SOUND_3 = "Sound\\Interface\\ClanInvitation.wav"
	
	endglobals
	
	struct GameStart
    
        static real timeLeft = GAME_MODE_OPTIONS_TIME
        static integer currentOptionType = 0
        static trigger onChat = null
        static timer ticker
		static player host = null
		
		static method getHost takes nothing returns player
			return .host
		endmethod
		
		private static method onChatEvent takes nothing returns nothing
            local string s = GetEventPlayerChatString()
            local integer l = StringLength(s)
            local integer v
            local real rv
            local integer i = 0
            local boolean match = false
            
            if s == "-start" then
                call onEnd()
                return
            endif
            
            if .currentOptionType == 0 then
                loop
                    exitwhen i >= GAME_MODE_COUNT
                    if s == GameMode.command[i] then
                        set match = true
                        exitwhen match
                    endif
                    set i = i + 1
                endloop
                if match then
                    set GameMode.current = i
                    set .currentOptionType = 5//Wert 1 sobald es mehrere Optionen bei den nachfolgenden Auswahlen gibt, wieder auf 1 stellen
                    call Sound.runSoundForPlayer(SOUND_2, .host)
                    call onEnd() //Wieder entfernen, wenn es bei den nachfolgenden Optionen mehrere zur Auswahl gibt
                endif
            elseif .currentOptionType == 1 then
                loop
                    exitwhen i >= GAME_TYPE_COUNT
                    if s == GameType.command[i] then
                        set match = true
                        exitwhen match
                    endif
                    set i = i + 1
                endloop
                if match then
                    set GameType.current = i
                    set .currentOptionType = 2
                    call Sound.runSoundForPlayer(SOUND_1, .host)
                endif
            elseif .currentOptionType == 2 then
                loop
                    exitwhen i >= GAME_DEFENSE_COUNT
                    if s == DefenseMode.command[i] then
                        set match = true
                        exitwhen match
                    endif
                    set i = i + 1
                endloop
                if match then
                    set DefenseMode.current = i
                    set .currentOptionType = 3
                    call Sound.runSoundForPlayer(SOUND_2, .host)
                endif
            endif
        endmethod
        
        private static method onEnd takes nothing returns nothing
            local timer t = NewTimer()
			
			if not MAP_HOSTED_BY_BOT then
                call ReleaseTimer(.ticker)
				call DisableTrigger(.onChat)
            endif
			
            call Sound.runSound(SOUND_1)
			
			static if TEST_MODE then
                call TimerStart(t, 2.0, false, function Game.initialize)
            else
                call TimerStart(t, OPTIONS_RESULT_DELAY, false, function Game.initialize)
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
        
        private static method periodic takes nothing returns nothing
            local integer i = 0
            //Update Time
            set .timeLeft = .timeLeft - TIMER_INTERVAL
            if .timeLeft <= 0.00 then
                call onEnd()
                return
            elseif .timeLeft > 0. and R2I(.timeLeft + 0.5) <= 5 then
                if ModuloReal(.timeLeft, 1) == 0 then
                    call Sound.runSound(GLOBAL_SOUND_2)
                endif
            endif
			call ClearTextMessages()
            //Host Setting Messages
            if .currentOptionType == 0 then //GAME MODE SETTINGS
                call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 10.00, "Please select the |cffffcc00Game Mode|r by entering the |cffffcc00Selection Command|r explained below.")
                loop
                    exitwhen i >= GAME_MODE_COUNT
                    if i == GameMode.current then 
                        call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "\n|cffffcc00Game Mode: |r" + GameMode.name[i] + " (|cff00ff00active|r)")
                    else
                        call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "\n|cffffcc00Game Mode: |r" + GameMode.name[i])
                    endif
                    call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "|cffffcc00Game Mode Description: |r" + GameMode.desc[i])
                    call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "|cffffcc00Selection Command: |r" + GameMode.command[i])
                    call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "|cffffcc00Repick: |r" + GameMode.repick[i])
                    set i = i + 1
                endloop
            elseif .currentOptionType == 1 then //GAME TYPE SETTINGS
                call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "Please select the |cffffcc00Game Type|r by entering the |cffffcc00Selection Command|r explained below.")
                loop
                    exitwhen i >= GAME_TYPE_COUNT
                    if i == GameType.current then
                        call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "\n|cffffcc00Game Type: |r" + GameType.name[i] + " (|cff00ff00active|r)")
                    else
                        call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "\n|cffffcc00Game Type: |r" + GameType.name[i])
                    endif
                    call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "|cffffcc00Game Type Description: |r" + GameType.desc[i])
                    call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "|cffffcc00Selection Command: |r" + GameType.command[i])
                    set i = i + 1
                endloop
            elseif .currentOptionType == 2 then //DEFENSE MODE SETTINGS
                call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "Please select the |cffffcc00Defense Mode|r by entering the |cffffcc00Selection Command|r explained below.")
                loop
                    exitwhen i >= GAME_DEFENSE_COUNT
                    if i == DefenseMode.current then
                        call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "\n|cffffcc00Defense Mode: |r" + DefenseMode.name[i] + " (|cff00ff00active|r)")
                    else
                        call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "\n|cffffcc00Defense Mode: |r" + DefenseMode.name[i])
                    endif
                    call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "|cffffcc00Defense Mode Description: |r" + DefenseMode.desc[i])
                    call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "|cffffcc00Selection Command: |r" + DefenseMode.command[i])
                    set i = i + 1
                endloop
                //Wenn es die letzte Optionsmöglichkeit ist dann setzte den Countdown-Timer auf 0.5s, damit
                //das Spiel los gehen kann :) 
                set .timeLeft = 0.5
            endif
            set i = 0
            loop
                exitwhen i >= Game.playerCount         
                if Game.players[i] != .host then
                    call DisplayTimedTextToPlayer(Game.players[i], 0.00, 0.00, 1.0, "\n Please wait, while " + GetPlayerNameColored(.host, false) + " is configurating the game settings.")
                endif 
                set i = i + 1
            endloop
            if R2I(.timeLeft + 0.5) == 1.00 then
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 1.00, "\nThe game will start automatically in |cffffcc001|r second.")
            else
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, 1.00, "\nThe game will start automatically in |cffffcc00" + I2S(R2I(.timeLeft + 0.5)) + "|r seconds.")
            endif
            call DisplayTimedTextToPlayer(.host, 0.00, 0.00, 1.00, "You can also directly start the game by typing |cffffcc00-start|r in the chat, using the |cffffcc00current settings.|r")
        endmethod
        
        private static method onStart takes nothing returns nothing
            call ReleaseTimer(GetExpiredTimer())
			
			if MAP_HOSTED_BY_BOT then
                call onEnd()
            else
				//enable user control for Host
				call SetUserControlForceOn(GetForceOfPlayer(.host))
				set .onChat = CreateTrigger()
				call TriggerRegisterPlayerChatEvent(.onChat, .host, "", false)
                call TriggerAddAction(.onChat, function thistype.onChatEvent)
                set .ticker = NewTimer()
                call TimerStart(.ticker, TIMER_INTERVAL, true, function thistype.periodic)
            endif
		endmethod
		
		private static method onShowWelcomeMessage takes nothing returns nothing
			//Show Welcome Message
			if MAP_HOSTED_BY_BOT then
				call Sound.runSound(GLOBAL_SOUND_1)
			endif
			call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "The FBF Team proudly present...")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "\n|cffffcc00" + NAME + "|r")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "|cffffcc00Release Date: |r" + RELEASE_DATE)
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "|cffffcc00Version: |r" + VERSION)
            call TimerStart(GetExpiredTimer(), TEXT_DURATION + 3.0, false, function thistype.onStart)
		endmethod
        
        static method initialize takes nothing returns nothing
            local timer t = NewTimer()
			
			set .host = udg_Host
			
			//Preload Sound
			call Sound.preload(SOUND_1)
			call Sound.preload(SOUND_2)
			call Sound.preload(SOUND_3)
	
			//deactivate user control for all players
            call SetUserControlForceOff(GetPlayersAll())
			
			call CinematicFadeBJ( bj_CINEFADETYPE_FADEOUT, 0.00, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0 )
            call Sound.runSound(SOUND_3)
			
			if TEST_MODE and not MAP_HOSTED_BY_BOT then
				//Ermittelt den Host und setzt ihn auf die globale Variable "Host"
				call TimerStart(t, GAME_START_DELAY, false, function thistype.onShowWelcomeMessage)
			else
				call TimerStart(t, GAME_START_DELAY_HOSTBOT, false, function thistype.onShowWelcomeMessage)
			endif
        endmethod
    
    endstruct
endscope