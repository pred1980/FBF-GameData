//==============================================================================
//==============================================================================
//
//  IWS - INDIVIDUAL WEATHER SYSTEM BY FURBY - v1.01
//
//  MORE INFO ON THE THEHELPER.NET AND CLANMAPZ.COM
//
//==============================================================================
//==============================================================================
//
//  LIST OF WEATHER EFFECTS
//
//==============================================================================
//==============================================================================
//
//  Ashenvale Rain (Heavy) - 'RAhr'
//  Ashenvale Rain (Light) - 'RAlr'
//  Dalaran Shield - 'MEds'
//  Dungeon Blue Fog (Heavy) - 'FDbh'
//  Dungeon Blue Fog (Light) - 'FDbl'
//  Dungeon Green Fog (Heavy) - 'FDgh'
//  Dungeon Green Fog (Light) - 'FDgl'
//  Dungeon Red Fog (Heavy) - 'FDrh'
//  Dungeon Red Fog (Light) - 'FDrl'
//  Dungeon White Fog (Heavy) - 'FDwh'
//  Dungeon White Fog (Light) - 'FDwl'
//  Lordaeron Rain (Heavy) - 'RLhr'
//  Lordaeron Rain (Light) - 'RLlr'
//  Northrend Blizzard - 'SNbs'
//  Northrend Snow (Heavy) - 'SNhs'
//  Northrend Snow (Light) - 'SNls'
//  Outland Wind (Heavy) - 'WOcw'
//  Outland Wind (Light) - 'WOlw'
//  Rays Of Light - 'LRaa'
//  Rays Of Moonlight - 'LRma'
//  Wind (Heavy) - 'WNcw'
//
//==============================================================================
//==============================================================================
scope WeatherSystem

    globals
        private weathereffect array WeatherEffect
        private integer array WeatherEffectType
        private string array WeatherEffectString

        //  Set true if you want set system to debug mode, otherwise leave it false
        private boolean DEBUGMODE = false
        
        //  How many weather effects system allowing
        private constant integer NUMBER_WEATHEREFFECTS = 4 
        
        //  What player should write to change weather
        private constant string TYPE_WEATHER = "-weather " 
        
        //  What player should write to turn weather off
        private constant string TYPE_TURNINGOFF = "off" 
        
    endglobals
    
    private function MainSetup takes nothing returns nothing
    
        //  Rawcodes of weather effects
        //  Be sure if you changed count of weather effects in globals, variable: CountWeatherEffects - base 4
        set WeatherEffectType[1] = 'RAhr'
        set WeatherEffectType[2] = 'SNhs'
        set WeatherEffectType[3] = 'FDrh'
        set WeatherEffectType[4] = 'LRma'
      //set WeatherEffectType[5] = ...
        
        //  What player should write to change weather to these ones
        //  Be sure if you changed count of weather effects in globals, variable: CountWeatherEffects - base 4
        set WeatherEffectString[1] = "rain"
        set WeatherEffectString[2] = "snow"
        set WeatherEffectString[3] = "redfog"
        set WeatherEffectString[4] = "moonlight"
      //set WeatherEffectString[5] = ...
        
    endfunction
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//  END OF EDITABLE ZONE - END OF EDITABLE ZONE - END OF EDITABLE ZONE
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
    private function IndividualWeatherDebug takes string s returns nothing
        if DEBUGMODE then
            debug call BJDebugMsg(s)
        endif
    endfunction
    
    private function Act takes nothing returns nothing
        local string s = SubString(GetEventPlayerChatString(), StringLength(TYPE_WEATHER), StringLength(GetEventPlayerChatString()))
        local integer i = 1
        local integer j
        
        call IndividualWeatherDebug("Detected '" + TYPE_WEATHER + "', with '" + s + "' suffix.")
        loop
            exitwhen(i > NUMBER_WEATHEREFFECTS)
            if s == WeatherEffectString[i] then
                call IndividualWeatherDebug("Found equivalent for '" + TYPE_WEATHER + "', it is '" + I2S(i) + "'.")
                set j = 1
                loop
                    exitwhen(j > NUMBER_WEATHEREFFECTS)
                    if j != i then
                        if GetLocalPlayer()==GetTriggerPlayer() then
                            call EnableWeatherEffect(WeatherEffect[j],false)
                        endif
                    endif
                    set j = j + 1
                endloop
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call IndividualWeatherDebug("Enabling weather effect number '" + I2S(i) + "' of type '" + I2S(WeatherEffectType[i]) + "'.")
                    call EnableWeatherEffect(WeatherEffect[i],true)
                endif
                return
            endif
            set i = i + 1
        endloop
        if s == TYPE_TURNINGOFF then
            call IndividualWeatherDebug("Turning all weather effects off.")
            set i = 1
            loop
                exitwhen(i > NUMBER_WEATHEREFFECTS)
                if GetLocalPlayer()==GetTriggerPlayer() then
                    call EnableWeatherEffect(WeatherEffect[i],false)
                endif
                set i = i + 1
            endloop
            return
        endif
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 5, "|c00ff8000Unknown weather.|r")
    endfunction
    
    private function Cond takes nothing returns boolean
        return(SubString(GetEventPlayerChatString(), 0, StringLength(TYPE_WEATHER))==TYPE_WEATHER) and (StringLength(GetEventPlayerChatString())>StringLength(TYPE_WEATHER))
    endfunction
    
    private function Actions takes nothing returns nothing
        local trigger t = CreateTrigger() 
        local integer i = 1
        
        call MainSetup()
        
        loop
            exitwhen(i > NUMBER_WEATHEREFFECTS)
            if WeatherEffectType[i] == 0 or WeatherEffectString[i] == "" then
                call IndividualWeatherDebug("|cFFFF0000ERROR: Missing type of weather or entering string for " + I2S(i) + " - did not set.|r")
            else
                set WeatherEffect[i] = AddWeatherEffect(bj_mapInitialPlayableArea, WeatherEffectType[i])
                call IndividualWeatherDebug("Weather effect number '" + I2S(i) + "' of type '" + I2S(WeatherEffectType[i]) + "' with entering string '" + WeatherEffectString[i] + "' created.")
            endif
            set i = i + 1
        endloop
        
        set i = 0
        
        loop
            exitwhen i >= bj_MAX_PLAYERS
            if Game.isPlayerInGame(i) then
                if GameStart.getHost() == Player(i) then
                    call TriggerRegisterPlayerChatEvent( t, Player(i), TYPE_WEATHER, false )
                endif
            endif
            set i = i + 1
        endloop
        call TriggerAddCondition(t, Filter(function Cond))
        call TriggerAddAction(t, function Act)
    endfunction
	
	struct IWS
	
		static method initialize takes nothing returns nothing
			call Actions()
		endmethod
	
	endstruct
    
endscope