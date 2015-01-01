scope HeroPickMods

    //****************************\\
    //****** CONFIGURATION *******\\
    //****************************\\
    globals
        private constant string EFFECT = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
        private constant real ALL_PICK_HERO_PICK_END_DURATION = 15.00
        private constant real PICK_DURATION = 120.00
        private constant real TIMER_UPDATE = 1.00
    endglobals
    
    /*
     * GameMode: AllPick
     */
     
    struct AllPick extends array
    
        static integer heroCount = 0
        static boolean started = false
        
        //required triggers
        static trigger onChat = null
        static trigger onEnter = null
        static trigger onRandom = null
        
        //Required for the timer
        static timer ticker = null
        static timer ticker2 = null
        static timer array t
        static real timeGone = 0.00
        static timerdialog tiDialog
    
        //required variables again....
        static player array p
        static unit array heroPickUnit // Acolyte, Peon, Peasant and Wisp
        static real array startLocX
        static real array startLocY
        static race r
        
        static integer id
        
        static method step0 takes player p, unit u, region r, integer randomIndex returns nothing
            //Random Index if Random Mode active
            local integer rnd = randomIndex
            //Player ID
            set .id = GetPlayerId(p)
            //Hero Pick Unit of the Player ( ex. Acolyt, Peon... )
            set .heroPickUnit[.id] = u
            //Player
            set .p[.id] = p
            //Race
            set .r = GetPlayerRace(.p[.id])
            
            set BaseMode.regionIndex[.id] = getRegionIndex(r)
            set BaseMode.selectableHero[.id] = GET_HERO(BaseMode.regionIndex[.id])
            set BaseMode.pickedHeroIndex[.id] = getRegionIndex(r)
            
            //Start Position des Helden abh?ngig seiner Rasse
            set .startLocX[.id] = GetRectCenterX(GET_HERO_RACE_START_RECT(.r))
            set .startLocY[.id] = GetRectCenterY(GET_HERO_RACE_START_RECT(.r))
            set BaseMode.hasPicked[.id] = true
            set BaseMode.available[BaseMode.regionIndex[.id]] = false
            
            set .t[.id] = NewTimer()
            call SetTimerData( .t[.id], .id )
            call TimerStart( .t[.id], .1, false, function thistype.step1 )
        endmethod
        
        static method step1 takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit u = FirstOfGroup(GetUnitsOfPlayerAndTypeId(Player(PLAYER_NEUTRAL_PASSIVE), BaseMode.selectableHero[this]))
            
            call PanCameraToTimedForPlayer( .p[this], GetUnitX(.heroPickUnit[this]), GetUnitY(.heroPickUnit[this]), .5 )
            call eh( u, EFFECT )
            call KillUnit( u )
            call SetUnitExploded(.heroPickUnit[this], true)
            call KillUnit(.heroPickUnit[this])
            
            call SetTimerData( .t[this], this )
            call TimerStart( .t[this], 2.5, false, function thistype.step2 )
            
            set u = null
        endmethod
        
        static method step2 takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit u = FirstOfGroup(GetUnitsOfPlayerAndTypeId(Player(PLAYER_NEUTRAL_PASSIVE), BaseMode.selectableHero[this]))
            
            call RemoveUnit(u)
            set u = null
            set BaseMode.pickedHero[this] = CreateUnit(.p[this], BaseMode.selectableHero[this], .startLocX[this], .startLocY[this], 0)
            
            call PanCameraToTimedForPlayer( .p[this], .startLocX[this], .startLocY[this], 0.25 )
            if (GetLocalPlayer() == .p[this]) then
                call ClearTextMessages()
            endif
            
            call SelectUnitForPlayerSingle(BaseMode.pickedHero[this], .p[this])
            
            //Update Multiboard
            call BaseMode.onUpdateMultiboard(this)
            
            //change PlayerName to (PlayerName(HeroName))
            call Game.changePlayerName(.p[this])
            
            //starte einmal das Hero Base Tutorial
            if BaseMode.repickCount[this] == 0 then
                call HeroBaseTutorial.create(.p[this], .startLocX[this], .startLocY[this], .tiDialog)
            endif
            
            call cleanup(this)
        endmethod
        
        static method onPeriodic takes nothing returns nothing
            local integer i = 0
            local real left = 0
            local integer randomIndex = 0
            
            set .timeGone = .timeGone + TIMER_UPDATE
            set left = PICK_DURATION - .timeGone
            
			if (.timeGone >= PICK_DURATION) or (Game.playerCount == 0) then
                loop
                    exitwhen i >= bj_MAX_PLAYERS
                    if not BaseMode.hasPicked[i] and Game.isPlayerInGame(i) then
                        set randomIndex = BaseMode.getRandomHero()
                        loop
                            exitwhen BaseMode.onEnterFilter(GET_HERO_PICK_UNIT(i), randomIndex)
                            set randomIndex = BaseMode.getRandomHero()
                        endloop
                        call createRandomHero( Player(i), GET_HERO_PICK_UNIT(i), randomIndex )
                    endif
                    set i = i + 1
                endloop
                call onHeroPickEnd()
            elseif left > 0. and R2I(left + 0.5) <= 5 then
                if ModuloReal(left, 1) == 0 then
                    call Sound.runSound(GLOBAL_SOUND_2)
                endif
            endif
            
        endmethod
        
        static method createRandomHero takes player p, unit pickUnit, integer randomIndex returns nothing
            local unit u
            
            //Player ID
            set .id = GetPlayerId(p)
            //Hero Pick Unit of the Player ( ex. Acolyt, Peon... )
            set .heroPickUnit[.id] = pickUnit
            //Player
            set .p[.id] = p
            //Race
            set .r = GetPlayerRace(.p[.id])
            
            set BaseMode.regionIndex[.id] = randomIndex
            set BaseMode.selectableHero[.id] = GET_HERO(randomIndex)
            set BaseMode.pickedHeroIndex[.id] = randomIndex
            
            //Start Position des Helden abh?ngig seiner Rasse
            set .startLocX[.id] = GetRectCenterX(GET_HERO_RACE_START_RECT(.r))
            set .startLocY[.id] = GetRectCenterY(GET_HERO_RACE_START_RECT(.r))
            set BaseMode.hasPicked[.id] = true
            set BaseMode.available[BaseMode.regionIndex[.id]] = false
            set BaseMode.isRandom[.id] = true
            
            set u = FirstOfGroup(GetUnitsOfPlayerAndTypeId(Player(PLAYER_NEUTRAL_PASSIVE), BaseMode.selectableHero[.id]))
            
            call RemoveUnit(u)
            call RemoveUnit(.heroPickUnit[.id])
            set BaseMode.pickedHero[.id] = CreateUnit(.p[.id], BaseMode.selectableHero[.id], .startLocX[.id], .startLocY[.id], 0)
            
            if (GetLocalPlayer() == .p[.id]) then
                call ClearTextMessages()
            endif
            
            call PanCameraToTimedForPlayer( .p[.id], .startLocX[.id], .startLocY[.id], 0.0 )
            call SelectUnitForPlayerSingle(BaseMode.pickedHero[.id], .p[.id])
            
            call Game.playerAddGold(.id, BaseGoldSystem.RANDOM_GOLD)
            set BaseMode.gotRandomGold[.id] = true
            
            //Update Multiboard
            call BaseMode.onUpdateMultiboard(.id)
            
            //change PlayerName to (PlayerName(HeroName))
            call Game.changePlayerName(.p[.id])
            
            //starte einmal das Hero Base Tutorial
            if BaseMode.repickCount[.id] == 0 then
                call HeroBaseTutorial.create(.p[.id], .startLocX[.id], .startLocY[.id], .tiDialog)
            endif
            
            set u = null
        endmethod
        
        static method onGameInitMiscSystem takes nothing returns nothing
            call ReleaseTimer(GetExpiredTimer())
            call Repick.setRepick(true)
            call Game.initMiscSystem()
        endmethod
        
        static method onHeroPickEndCallback takes nothing returns nothing
            local integer i = 0
            local timer t = GetExpiredTimer()
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                //if it's undead player, than create 1x the Acolyts for the Tower Build
                if Game.isPlayerInGame(i) and GetPlayerRace(Player(i)) == RACE_UNDEAD and BaseMode.repickCount[i] == 0 then
                    //create Acolyts Builder
                    call TowerSystem.createBuilder(i)
                endif
				
			    set i = i + 1
            endloop
            
            call TimerStart(t, 11.0, false, function thistype.onGameInitMiscSystem )
        endmethod
        
        static method onHeroPickEnd takes nothing returns nothing
            local integer i = 0
            local timer t = NewTimer()
            
            //disable Repick for a short moment
            call Repick.setRepick(false)
            
            if (.ticker != null) and (.ticker2 != null) then
                call ReleaseTimer(.ticker)
                call ReleaseTimer(.ticker2)
                set .ticker = null
                set .ticker2 = null
                call DestroyTimerDialog(.tiDialog)
                set .tiDialog = null
            endif
            
            call ClearTextMessages()
            call Sound.runSound(GLOBAL_SOUND_1)
            //Random-Extra Gold Evaluation
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if ( Game.isPlayerInGame(i) ) then
                    call DisplayTimedTextToPlayer(Player(i), 0.00, 0.00, 7.00, "All Players selected a Hero. The Game starts in |cffffcc00" + I2S(R2I(ALL_PICK_HERO_PICK_END_DURATION)) + " seconds|r")
                    //150 extra gold for the random hero
                    if (BaseMode.isRandom[i] and not BaseMode.gotRandomGold[i]) then
                        call Game.playerAddGold(i, BaseGoldSystem.RANDOM_GOLD)
                        call DisplayTimedTextToPlayer(Player(i), 0.00, 0.00, 7.00, "You received |cffffcc00" + I2S(BaseGoldSystem.RANDOM_GOLD) + "|r extra gold for picking a random hero.")
                        set BaseMode.gotRandomGold[i] = true
                    endif
                endif
                set i = i + 1
            endloop
            
            call TimerStart(t, ALL_PICK_HERO_PICK_END_DURATION + 5.0, false, function thistype.onHeroPickEndCallback )
        endmethod
        
        private method cleanup takes integer i returns nothing
            call ReleaseTimer(.t[i])
            set .t[i] = null
        endmethod
        
        static method getHeroPickTimer takes nothing returns timerdialog
            return .tiDialog
        endmethod
        
        static method init takes nothing returns nothing
            set .ticker = NewTimer()
            set .ticker2 = NewTimer()
            set .tiDialog = CreateTimerDialog(.ticker2)
            
            //Hero Pick Timer
            call TimerDialogSetTitle(.tiDialog, "Hero Pick")
            call TimerDialogDisplay(.tiDialog, true)
            
            call TimerStart(.ticker, TIMER_UPDATE, true, function thistype.onPeriodic)
            call TimerStart(.ticker2, PICK_DURATION, false, null)
        endmethod
        
    endstruct
     
endscope