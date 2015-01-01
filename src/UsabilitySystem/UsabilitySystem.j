scope UsabilitySystem
    /*
     * In diesem System werden alle Textausgaben hinterlegt, die dann von den anderen Systemen aufgerufen
     * werden können.
     */
     
    globals
		private string array NOTE_MESSAGES
        private string array WARN_MESSAGES
        private string array ERROR_MESSAGES
        private string array TYPE
        private constant real TEXT_DURATION = 12.0
        
        private string NOTE_SOUND = "Sound\\Interface\\Hint.wav"
        private string WARN_SOUND = "Sound\\Interface\\Warning.wav"
        private string ERROR_SOUND = "Sound\\Interface\\Error.wav"
	endglobals
    
    private function MainSetup takes nothing returns nothing
        set TYPE[0] = "|cff00c400NOTE|r\n"
        set TYPE[1] = "|cffff8000WARNING: |r"
        set TYPE[2] = "|cffff0000ERROR: |r"
    
		set NOTE_MESSAGES[0] = TYPE[0] + "Click on a hero to see their stats and abilities."
        set NOTE_MESSAGES[1] = "Walk into the selection circle in front of a hero to pick them. You can also walk in the random circle to get a random hero and recieve |cffffcc00" + I2S(BaseGoldSystem.RANDOM_GOLD) + "|r extra gold."
		set NOTE_MESSAGES[2] = TYPE[0] + "The units in your spawn zone offer equipment and consumables."
        set NOTE_MESSAGES[3] = TYPE[0] + "Walk through the teleporter to be transported to the front. Return between rounds to be healed by the fountain."
	    set NOTE_MESSAGES[4] = TYPE[0] + "Build a Tower Defense on both sides of your lane with your Acolyte to hamper the Coalition's progress."
		set NOTE_MESSAGES[5] = TYPE[0] + "You can buy units from your casters at the edge of the dome."
        set NOTE_MESSAGES[6] = TYPE[0] + "The hero statistics are not avaiable for your faction. Please select a hero of your faction or a neutral."
        set NOTE_MESSAGES[7] = TYPE[0] + "You can only pick heroes that belong to your faction or are neutral."
        set NOTE_MESSAGES[8] = TYPE[0] + "Four new Towers are activated."
		set NOTE_MESSAGES[9] = "The teleporter has been relocated."
		set NOTE_MESSAGES[10] = TYPE[0] + "The repick time is over. You can't pick another hero anymore."
		
        set WARN_MESSAGES[0] = "" // Kann neu verwendet werden
		set WARN_MESSAGES[1] = TYPE[1] + "Warning: The teleporter moves in a few seconds to a new point!"
        
        set ERROR_MESSAGES[0] = TYPE[2] + "No gold value set for killed Unit."
        
        /* Preload Sounds */
		call Sound.preload(NOTE_SOUND)
		call Sound.preload(WARN_SOUND)
		call Sound.preload(ERROR_SOUND)
    endfunction
    
    private struct Data
        integer index
        boolean playSound
        player pl
        boolean clearMessages
        timer t
        integer textType = 0
    endstruct

    struct Usability
    
        static method onShowMessage takes nothing returns nothing
            local Data d = GetTimerData(GetExpiredTimer())
            
			call ReleaseTimer(GetExpiredTimer())
			
			if GetLocalPlayer() == d.pl and d.clearMessages then
			   call ClearTextMessages()
			endif
            
			if d.textType == 0 then
                call DisplayTimedTextToPlayer(d.pl, 0.0, 0.0, TEXT_DURATION, NOTE_MESSAGES[d.index])
                if d.playSound then
					call Sound.runSoundForPlayer(NOTE_SOUND, d.pl)
				endif
            elseif d.textType == 1 then
                call DisplayTimedTextToPlayer(d.pl, 0.0, 0.0, TEXT_DURATION, WARN_MESSAGES[d.index])
                if d.playSound then
                    call Sound.runSoundForPlayer(WARN_SOUND, d.pl)
                endif
            else
                call DisplayTimedTextToPlayer(d.pl, 0.0, 0.0, TEXT_DURATION, ERROR_MESSAGES[d.index])
                if d.playSound then
                    call Sound.runSoundForPlayer(ERROR_SOUND, d.pl)
                endif
            endif
            
            call d.destroy()
        endmethod
        
        /* 
         * textType: Welcher der drei Texttypen soll ausgespielt werden?
         * index: Welche der Text soll ausgespielt werden?
         * playSound: Soll ein entsprechender Sound ausgespielt werden?
         * p: Welcher Spieler?
         * clearMessages: Sollen alle bisher angezeigten Messages gelöscht werden?
         * delay: In wie viel Sekunden soll der Sound abgspielt werden?
        */
		
		static method getTextMessage takes integer textType, integer index, boolean playSound, player p, boolean clearMessages, real delay returns nothing
			local Data d = Data.create()
            
            set d.index = index
            set d.playSound = playSound
            set d.pl = p
            set d.clearMessages = clearMessages
            set d.textType = textType
            set d.t = NewTimer()
            
            call SetTimerData(d.t, d)
            call TimerStart(d.t, delay, false, function thistype.onShowMessage )
		endmethod
		
		static method initialize takes nothing returns nothing
			call MainSetup()
		endmethod
    endstruct

endscope