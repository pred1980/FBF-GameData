scope MiscTutorials

    globals
        private constant string EFFECT = "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl"
        private constant string EFFECT_ATT_POINT = "overhead" 
    endglobals
    
    struct CoalitionUnitShopTutorial
        player p
        unit hero
        unit shop
        static boolean array showTutorial[12]
        
        method onDestroy takes nothing returns nothing
            set .hero = null
            set .shop = null
        endmethod
        
        static method onFinishTutorial takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype this = GetTimerData(t)
            
			call SetUserControlForceOn(GetForceOfPlayer(this.p))
            call SetUnitInvulnerable(this.hero, false)
            if (GetLocalPlayer() == this.p) then
				call SelectUnit(this.shop, true)
			endif
			call SetUnitPathing(this.shop, false)
            call cinematicOff(this.p)
            call ReleaseTimer(t)
            set t = null
            call this.destroy()
        endmethod
    
        static method create takes player p, unit hero returns thistype
            local thistype this = thistype.allocate()
            local timer t = NewTimer()
            local real x = 0.00
            local real y = 0.00
            
            set .p = p
            set .shop = UnitShopSystem.getShop(.p)
            set .hero = hero
            set .showTutorial[GetPlayerId(.p)] = true
            set x = GetUnitX(.shop)
            set y = GetUnitY(.shop)
            call SetUserControlForceOff(GetForceOfPlayer(p))
			call StopUnitsOfPlayer(p)
			
            call cinematicOn(.p)
            call SetUnitInvulnerable(.hero, true)
            call SelectUnit(.hero, false)
            call SetUnitPathing(.shop, true)
            call IssuePointOrder(.hero, "move", x, y)
            call PanCameraToTimedForPlayer(.p, x, y, 1.0)

            //Show Note Text Message
            call Usability.getTextMessage(0, 5, true, .p, true, 2.0)
            //
            call SetTimerData(t, this)
            call TimerStart(t, 8.0 , false, function thistype.onFinishTutorial)
            
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            local integer i = 0
            
            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                if Game.isPlayerInGame(i) and GetPlayerRace(Player(i)) != RACE_UNDEAD then
                    set thistype.showTutorial[i] = false
                endif
                set i = i + 1
            endloop
        endmethod
            
    endstruct
    
endscope