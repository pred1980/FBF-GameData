scope HeroTutorials initializer init

    globals
        private constant string EFFECT = "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl"
        private constant string EFFECT_ATT_POINT = "overhead"
    endglobals
	
	struct TowerBuilderTutorial
        player p
        
        static method onFinishTutorial takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype data = GetTimerData(t)
            
            call cinematicOff(data.p)
            call ReleaseTimer(t)
			call SetUserControlForceOn(GetForceOfPlayer(data.p))
            set t = null
            call data.destroy()
        endmethod
    
        static method create takes player p, real x, real y returns thistype
            local thistype this = thistype.allocate()
            local timer t = NewTimer()
            
            set .p = p
            call SetUserControlForceOff(GetForceOfPlayer(p))
			call StopUnitsOfPlayer(p)
			
            call cinematicOn(.p)
            call PanCameraToTimedForPlayer(.p, x, y, .5)
            //Show Note Text Message
            call Usability.getTextMessage(0, 4, true, .p, true, 3.0)
            //
            call SetTimerData(t, this)
            call TimerStart(t, 10.0 , false, function thistype.onFinishTutorial)
            
            return this
        endmethod
            
    endstruct
    
    /*
     * Dieses Tutorial soll kurz zeigen, wie man seinen Helden waehlt und wie man den Shop+Teleporter verwendet
     */
    struct HeroPickTutorial
        player p
        real x
        real y
        timerdialog tiDialog = null
        
        static method onFinishTutorial takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype data = GetTimerData(t)
            
            //Choooose your Destination :)
            call Sound.runSoundForPlayer(HeroPickSystem.sound_1, data.p)
            
            if data.tiDialog != null then
                call TimerDialogDisplayForPlayer(data.p, data.tiDialog, true)
            endif
			call SetUserControlForceOn(GetForceOfPlayer(data.p))
            call PanCameraToTimedForPlayer(data.p, data.x, data.y, .5)
            call cinematicOff(data.p)
            call ReleaseTimer(t)
            set t = null
            call data.destroy()
        endmethod
    
        static method create takes player p, timerdialog tm returns thistype
            local thistype this = thistype.allocate()
            local timer t = NewTimer()
            
            set .p = p
			call SetUserControlForceOff(GetForceOfPlayer(p))
			call StopUnitsOfPlayer(p)
			
            if tm != null then
                set .tiDialog = tm
                call TimerDialogDisplayForPlayer(.p, .tiDialog, false)
            endif
            
            if GetPlayerRace(.p) == RACE_UNDEAD then
                set .x = GetRectCenterX(gg_rct_UDHeroPickStart)
                set .y = GetRectCenterY(gg_rct_UDHeroPickStart)
            else
                set .x = GetRectCenterX(gg_rct_INFHeroPickStart)
                set .y = GetRectCenterY(gg_rct_INFHeroPickStart)
            endif
            
            call cinematicOn(.p)
            call PanCameraToTimedForPlayer( .p, .x, .y, .5 )
            //Show Note Text Message
            call Usability.getTextMessage(0, 0, true, .p, true, 5.0)
            call Usability.getTextMessage(0, 1, true, .p, true, 12.0)
            call SetTimerData(t, this)
            call TimerStart(t, 25.0 , false, function thistype.onFinishTutorial)
            
            return this
        endmethod
    
    endstruct
    
    /*
     * Dieses Tutorial soll kurz zeigen, was man NACH der Heldenauswahl in der jeweiligen Basis
     * machen kann/soll
     */
    struct HeroBaseTutorial
        player p
        integer count
        integer raceType
        effect array effects[3]
        timerdialog tiDialog = null
        
        static method onFinishTutorial takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype data = GetTimerData(t)
            
            if data.tiDialog != null then
                call TimerDialogDisplayForPlayer(data.p, data.tiDialog, true)
            endif
			call SetUserControlForceOn(GetForceOfPlayer(data.p))
            call PanCameraToTimedForPlayer(data.p, GetUnitX(BaseMode.pickedHero[GetPlayerId(data.p)]), GetUnitY(BaseMode.pickedHero[GetPlayerId(data.p)]), .5)
            call cinematicOff(data.p)
            call ReleaseTimer(t)
            set t = null
            call data.destroy()
        endmethod
        
        static method onShowTeleporter takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype data = GetTimerData(t)
            local integer i = 0
            
            //Entferne nun die Ausrufezeichen von den Shops und schwenke die Kamera zum Teleporter
            loop
                exitwhen i > 2
                call DestroyEffect(data.effects[i])
                set i = i + 1
            endloop
            
            if GetPlayerRace(data.p) == RACE_UNDEAD then
                call PanCameraToTimedForPlayer(data.p, GetRectCenterX(gg_rct_ForsakenTeleport0), GetRectCenterY(gg_rct_ForsakenTeleport0), 1.5)
            elseif GetPlayerRace(data.p) == RACE_HUMAN then
                call PanCameraToTimedForPlayer(data.p, GetRectCenterX(gg_rct_HumanTeleport0), GetRectCenterY(gg_rct_HumanTeleport0), 1.5)
            elseif GetPlayerRace(data.p) == RACE_ORC then
                call PanCameraToTimedForPlayer(data.p, GetRectCenterX(gg_rct_OrcTeleport0), GetRectCenterY(gg_rct_OrcTeleport0), 1.5)
            else
                call PanCameraToTimedForPlayer(data.p, GetRectCenterX(gg_rct_NightelfTeleport0), GetRectCenterY(gg_rct_NightelfTeleport0), 1.5)
            endif
            
            //Show Note Text Message
            call Usability.getTextMessage(0, 3, true, data.p, true, 1.5)
            
            //Last Timer before kill data struct and turn off cinematic mode
            call SetTimerData(t, data)
            call TimerStart(t, 5.0, false, function thistype.onFinishTutorial)
        endmethod
        
        static method onShowShops takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local thistype data = GetTimerData(t)
            local unit shop = ItemShops.getShop(data.raceType, data.count)
            
			set data.effects[data.count] = addEffectToUnitForPlayer(data.p, shop, EFFECT, EFFECT_ATT_POINT)
            
            set data.count = data.count + 1
            set shop = null
            
            if data.count > 2 then
                call SetTimerData(t, data)
                call TimerStart(t, 3.0 , false, function thistype.onShowTeleporter)
            else
                call SetTimerData(t, data)
                call TimerStart(t, 1.5 , true, function thistype.onShowShops)
            endif
        endmethod
        
        static method create takes player p, real x, real y, timerdialog tm returns thistype
            local thistype this = thistype.allocate()
            local timer t = NewTimer()
            
            set .p = p
            set .count = 0
            call SetUserControlForceOff(GetForceOfPlayer(p))
			call StopUnitsOfPlayer(p)
			
            if GetPlayerRace(p) == RACE_UNDEAD then
                set .raceType = 0
            elseif GetPlayerRace(p) == RACE_HUMAN then
                set .raceType = 1
            elseif GetPlayerRace(p) == RACE_ORC then
                set .raceType = 2
            else
                set .raceType = 3
            endif
            
            if tm != null then
                set .tiDialog = tm
                call TimerDialogDisplayForPlayer(.p, .tiDialog, false)
            endif
            call cinematicOn(.p)
            call PanCameraToTimedForPlayer( .p, x, y, .5 )
            //Show Note Text Message
            call Usability.getTextMessage(0, 2, true, .p, true, 3.0)
            
			call SetTimerData(t, this)
            call TimerStart(t, 4.5 , false, function thistype.onShowShops)
            
            return this
        endmethod

    endstruct
	
	private function init takes nothing returns nothing
        call Preload(EFFECT)
    endfunction

endscope