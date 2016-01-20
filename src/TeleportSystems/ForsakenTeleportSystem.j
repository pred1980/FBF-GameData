scope ForsakenTeleportSystem initializer init

    globals
        private constant integer ID = 'n00M'
        private constant rect array TELEPORT_RECTS
        private constant integer MAX_TELEPORTER_PLACES = 1
		private constant string EFFECT = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl"
		private constant real MOVE_TELEPORTER_ANNOUNCMENT = 15.0
        
        private integer array PLACE_BY_ROUND[MAX_TELEPORTER_PLACES][2]
        private constant real TELEPORT_DELAY = 1.0
    endglobals
    
    private struct TeleportData
        unit target
        integer counter = 0
        region reg
        real x
        real y
        player p
        
        method onDestroy takes nothing returns nothing
            set .target = null
            set .reg = null
        endmethod
    endstruct

    struct ForsakenTeleport
		static fogmodifier visibibleArea
		static unit teleporter = null
    
        static method onReturnToBaseConditions takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local boolean b = false
            
            if IsUnitInRegion(GetTriggeringRegion(), teleporter) then
                if GetUnitRace(u) == RACE_UNDEAD then
                    if IsUnitType(u, UNIT_TYPE_HERO) or /*
                    */ IsUnitAlly(u, ConvertedPlayer(IMaxBJ(1, 6))) and /*
                    */ XE_Dummy_Conditions(u) then
                        set b = true
                    endif
                endif
            endif
            
            set u = null
            return b
        endmethod
        
        /* Nach kurzem Delay zur Basis zurueck teleportieren */
        static method onReturnToBaseDelay takes nothing returns nothing
            local TeleportData data = GetTimerData(GetExpiredTimer())
			
            if IsUnitInRegion(data.reg, data.target) and not IsUnitDead(data.target) then
                if data.counter > 1 then
                    call SetUnitPosition(data.target, data.x, data.y)
            
                    if ((GetLocalPlayer() == data.p) and IsUnitType(data.target, UNIT_TYPE_HERO)) then
                        call PanCameraToTimed(data.x, data.y, 0.00)
                    endif
					call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(data.target), GetUnitY(data.target)))
                    call IssueImmediateOrder(data.target, "holdposition")
					
                    return
                endif
                call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(data.target), GetUnitY(data.target)))
				call IssueImmediateOrder(data.target, "holdposition")
                set data.counter = data.counter + 1
            else
                call ReleaseTimer(GetExpiredTimer())
                call data.destroy()
            endif
        endmethod
        
        /* vom Schlachtfeld zur Base zurueck */
        static method onReturnToBase takes nothing returns nothing
            local region r = GetTriggeringRegion()
            local unit u = GetTriggerUnit()
            local player p = GetOwningPlayer(u)
            local real x = GetRectCenterX(TELEPORT_RECTS[1])
            local real y = GetRectCenterY(TELEPORT_RECTS[1])
            local timer t = NewTimer()
            local TeleportData data = TeleportData.create()
            
            set data.target = u
            set data.reg = r
            set data.x = x
            set data.y = y
            set data.p = p
			
			// Stop hero for computer to get a clean teleport back to base
			if (Game.isBot[GetPlayerId(p)]) then
				call IssueImmediateOrder(u, "holdposition")
			endif
            
            call SetTimerData(t, data)
            call TimerStart(t, TELEPORT_DELAY, true, function thistype.onReturnToBaseDelay)
            
            set u = null
        endmethod
        
        /* von der Base zum Schlachtfeld zurück */
        static method onLeaveBase takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local player p = GetOwningPlayer(u)
            local real x = GetRectCenterX(TELEPORT_RECTS[PLACE_BY_ROUND[0][1]])
            local real y = GetRectCenterY(TELEPORT_RECTS[PLACE_BY_ROUND[0][1]])
            
            call SetUnitPosition(u, x, y)
            
			if ((GetLocalPlayer() == p) and IsUnitType(u, UNIT_TYPE_HERO)) then
                call PanCameraToTimed(x, y, 0.00)
            endif
            call Sound.runSoundForPlayer(GLOBAL_SOUND_3, p)
            
            set u = null
        endmethod
		
		static method initialize takes nothing returns nothing
            local trigger t = CreateTrigger()
            local real x = 0.00
            local real y = 0.00
            
            set x = GetRectCenterX(TELEPORT_RECTS[PLACE_BY_ROUND[0][0]])
            set y = GetRectCenterY(TELEPORT_RECTS[PLACE_BY_ROUND[0][0]])
            set teleporter = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), ID, x, y, 0.00)
            
			call SetAltMinimapIcon("war3mapImported\\Minimap-Teleporter.blp")
			call UnitSetUsesAltIcon(teleporter, true)
			
			call TriggerRegisterEnterRectSimple(t, TELEPORT_RECTS[PLACE_BY_ROUND[0][0]])
            call TriggerAddCondition(t, Condition(function thistype.onReturnToBaseConditions))
            call TriggerAddAction(t, function thistype.onReturnToBase)

            set t = null
        endmethod
        
    endstruct
    
    private function onLeaveBaseConditions takes nothing returns boolean
		local unit u = GetTriggerUnit()
        local boolean b = false
        
        if GetUnitRace(u) == RACE_UNDEAD then
            if IsUnitType(u, UNIT_TYPE_HERO) or /*
            */ IsUnitAlly(u, ConvertedPlayer(IMaxBJ(1, 6))) and /*
            */ XE_Dummy_Conditions(u) then
                set b = true
            endif
        endif
        
        set u = null
        return b
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local real x = 0.00
        local real y = 0.00
        
        set PLACE_BY_ROUND[0][0] = 2 // TELEPORT_RECTS[2]
        set PLACE_BY_ROUND[0][1] = 3 // TELEPORT_RECTS[3]
        
        set TELEPORT_RECTS[0] = gg_rct_ForsakenTeleport0 //von Undead Base zum Undead Place nach akt. Runde
        set TELEPORT_RECTS[1] = gg_rct_ForsakenTeleport1 //vom Undead Place der akt. Runde zur Undead Base
        
        set TELEPORT_RECTS[2] = gg_rct_ForsakenTeleport1x0 //vom Undead Place 1 zur Undead Base
        set TELEPORT_RECTS[3] = gg_rct_ForsakenTeleport1x1 //von Undead Base zu Undead Place
        
		//create Undead-Base Teleporter
        set x = GetRectCenterX(TELEPORT_RECTS[0])
        set y = GetRectCenterY(TELEPORT_RECTS[0])
        call CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), ID, x, y, 0.00)
        
        call TriggerRegisterEnterRectSimple(t, TELEPORT_RECTS[0])
        call TriggerAddCondition(t, Condition(function onLeaveBaseConditions))
        call TriggerAddAction(t, function ForsakenTeleport.onLeaveBase)
        
        set t = null
    endfunction
    
endscope