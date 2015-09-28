scope HeroRepickSystem

    //****************************\\
    //****** CONFIGURATION *******\\
    //****************************\\
    globals
        //constants
        private constant string EFFECT = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
        private constant string REPICK_STRING = "-repick"
        private constant real REPICK_DURATION = 180.00
        private constant integer REPICK_AMOUNT = 1
        
        private boolean ENABLE_REPICK = true
    endglobals
    
    private function learnAbiltiyForHero takes unit hero, integer index returns nothing
        local integer i = 0
        
        loop
            exitwhen i > 4
                call SelectHeroSkill( hero, GET_HERO_ABILITY(index, i) )
                if ( i < 3) then
                    call SetUnitAbilityLevel( hero, GET_HERO_ABILITY(index, i), 5 )
                else
                    call SetUnitAbilityLevel( hero, GET_HERO_ABILITY(index, i), 3 )
                endif
            set i = i + 1
        endloop
    endfunction
    
    struct Repick
        
        //required triggers
        static trigger onChat = null
        
        //Required for the timer
        static timer repickTicker = null
        
        static boolean enable = ENABLE_REPICK
        
        //Repick
        private static method onChatEvent takes nothing returns boolean
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            local unit u = BaseMode.pickedHero[id]
            local unit h
            local integer i
            local integer index = BaseMode.regionIndex[id]
            
            if enable then
                //Not picked a hero
                if not BaseMode.hasPicked[id] then
                    call SimError(p, "You cannot repick unless you have chosen an hero first.")
                else
                    //Repicked more than allowed
                    if BaseMode.repickCount[id] >= REPICK_AMOUNT then
                        if REPICK_AMOUNT == 1 then
                            call SimError(p, "You cannot repick more than once.")
                        else
                            call SimError(p, "You cannot repick more than " + I2S(REPICK_AMOUNT) + " times.")
                        endif
                    else
                        //Succesful repick
                        set BaseMode.hasPicked[id] = false
                        set BaseMode.available[index] = true
                        set Game.playerCount = Game.playerCount + 1
                        set BaseMode.repickCount[id] = BaseMode.repickCount[id] + 1
                        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0., 0., 5., GetPlayerNameColored(p, false) + " is repicking...")
                        
                        //Hat der Spieler Items gekauft?
                        if PlayerStats.getPlayerBuyedItems(p) > 0 then
                            //Ist/sind die/das Item noch im Inventar?
                            if CountItemInInventar(u) > 0 then 
                                call Game.playerRemoveGold(id, Game.getPlayerStartGold(p))
                            else
                            //Spieler will bescheissen, indem er das Item auf den Boden gelegt hat und nun sich einen
                            //neuen Held waehlen will
                                if BaseMode.gotRandomGold[id] then
                                    call Game.playerRemoveGold(id, BaseGoldSystem.RANDOM_GOLD)
                                endif
                            endif
                        endif

						//Was it a random hero?
						if (BaseMode.gotRandomGold[id]) then
							set BaseMode.gotRandomGold[id] = false
							set BaseMode.isRandom[id] = false
							//Remove Random Gold
							call Game.playerRemoveGold(id, BaseGoldSystem.RANDOM_GOLD)
						endif
                        
                        //reset Player Name
                        call SetPlayerName(p, BaseMode.origPlayerName[id])
						
                        //Visuell Effect to the Hero
                        call eh(BaseMode.pickedHero[id], EFFECT)
                        call KillUnit(BaseMode.pickedHero[id])
                        call RemoveUnit(BaseMode.pickedHero[id])
                        set BaseMode.pickedHero[id] = null
                        //create hero ( repick )
                        set h = CreateUnit( Player(PLAYER_NEUTRAL_PASSIVE), GET_HERO(index), GET_HERO_REPICK_RECT_X(index), GET_HERO_REPICK_RECT_Y(index), GET_HERO_PICK_FACING(index) )
                        //add the hero as new selectable Hero
                        set BaseMode.selectableHero[index] = GetUnitTypeId(h)
                        //set max level
                        call SetHeroLevel(h, 30, false)
                        //learn all abilities
                        call learnAbiltiyForHero(h, index)
                        //create hero pick unit for the player
                        call CREATE_HERO_PICK_UNIT(id)
                        //disable all abilities for the recreated Hero
                        call DISABLE_ABILITIES_FOR_HERO(h)
                        
                        //Update Multiboard
                        call PlayerStats.resetPlayerDeath(Player(id))
                        call FBFMultiboard.onUpdateRepick(id)
                    endif
                endif
            else
                call SimError(p, "                Repick is not possible anymore!")
            endif
           
            set p = null
            set u = null
            set h = null
            
            return true
        endmethod
        
        static method onRepickEnd takes nothing returns nothing
            local integer i = 0
            call ReleaseTimer(GetExpiredTimer())
            set .repickTicker = null
            //deactivate Repick
            call setRepick(false)
            //show Information that repick is not more aviable
            call ClearTextMessages()
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) then
					call Usability.getTextMessage(0, 10, true, Player(i), true, 0.1)
                endif
                set i = i + 1
            endloop
        endmethod
        
        static method initialize takes nothing returns nothing
            local integer i = 0
            
            set .onChat = CreateTrigger()
            
            //Activate Repick+Event + Create Hero Pick Units for all Players
            call setRepick(true)
            loop
                exitwhen i >= bj_MAX_PLAYERS
                    if ( Game.isPlayerInGame(i) ) then
                        call TriggerRegisterPlayerChatEvent( .onChat, Player(i), REPICK_STRING, true )
                    endif
                set i = i + 1
            endloop
            call TriggerAddCondition(.onChat, Condition(function thistype.onChatEvent))
            
            //Starte Repick Timer nur f?r den All-Pick-Mode
            if GameMode.getCurrentMode() == 0 then
                set .repickTicker = NewTimer()
                call TimerStart(.repickTicker, REPICK_DURATION, false, function thistype.onRepickEnd)
            endif
            
        endmethod
        
        //set Repick
        static method setRepick takes boolean b returns nothing
            set .enable = b
        endmethod
        
    endstruct

endscope