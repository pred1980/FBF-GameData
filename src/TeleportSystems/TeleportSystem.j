scope TeleportSystem initializer init
	/* Teleporter in the Forsaken Area */
	
	globals
        private constant integer TELEPORTER_ID = 'n007' //Teleporter
		private constant integer MAX_TELEPORTER_PLACES = 4
        private rect array TELEPORT_RECTS[MAX_TELEPORTER_PLACES][3]
		private constant string EFFECT = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl"
        private constant real TELEPORT_DELAY = 1.0
		
		private Table table
		private integer index = 0
    endglobals
	
	private struct TeleportData
        unit target
        region reg
        real x
        real y
        player p
        
        method onDestroy takes nothing returns nothing
            set .target = null
            set .reg = null
        endmethod
    endstruct
	
	struct TeleportSystem
		private trigger t
		private region reg
		
		private static method onTeleport takes nothing returns nothing
            local TeleportData data = GetTimerData(GetExpiredTimer())
			
			if IsUnitInRegion(data.reg, data.target) and not IsUnitDead(data.target) then
				call SetUnitPosition(data.target, data.x, data.y)
				
				if (GetLocalPlayer() == data.p) then
					call PanCameraToTimed(data.x, data.y, 0.00)
				endif
				
				call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(data.target), GetUnitY(data.target)))
				call IssueImmediateOrder(data.target, "holdposition")
				call ReleaseTimer(GetExpiredTimer())
				call data.destroy()
			endif
        endmethod
		
		private static method onTeleporting takes nothing returns nothing
			local region reg = GetTriggeringRegion()
			local rect rec = GetTriggeringRect()
            local unit u = GetTriggerUnit()
            local player p = GetOwningPlayer(u)
            local real x = 0.00
            local real y = 0.00
            local timer t = NewTimer()
            local TeleportData data = TeleportData.create()
			local integer i = 0
			local integer k = 0
			
			loop
				exitwhen i > MAX_TELEPORTER_PLACES
				loop
					exitwhen k == 3
					if (TELEPORT_RECTS[i][k] == rec) then
						set x = GetRectCenterX(TELEPORT_RECTS[i][1]) //Ziel
						set y = GetRectCenterY(TELEPORT_RECTS[i][1]) //Ziel
					endif
					set k = k + 1
				endloop
				set k = 0
				set i = i + 1
			endloop
            
            set data.target = u
            set data.reg = reg
            set data.x = x
            set data.y = y
            set data.p = p
            
            call SetTimerData(t, data)
            call TimerStart(t, TELEPORT_DELAY, false, function thistype.onTeleport)
            
            set u = null
		endmethod
	
		private static method onTeleportConditions takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local boolean b = false
			
			if IsUnitType(u, UNIT_TYPE_HERO) and /* 
				*/ XE_Dummy_Conditions(u) then
					set b = true
			endif
			
            set u = null
            
			return b
        endmethod
	
		static method create takes nothing returns thistype
			local thistype this = thistype.allocate()
			local real x = 0.00
            local real y = 0.00
			local unit teleporter = null
			
			set .t = CreateTrigger()
			set .reg = CreateRegion()
			set table[GetHandleId(.t)] = this
			
			/*
			 * Teleporter forward
			 */
			call SaveRect(TELEPORT_RECTS[index][0], this)
			call RegionAddRectSaved(.reg, TELEPORT_RECTS[index][0])
			set x = GetRectCenterX(TELEPORT_RECTS[index][0])
            set y = GetRectCenterY(TELEPORT_RECTS[index][0])
            set teleporter = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), TELEPORTER_ID, x, y, 0.00)
			call PingMinimap(x, y, 1.0)
			
			call SetAltMinimapIcon("war3mapImported\\Minimap-Teleporter.blp")
			call UnitSetUsesAltIcon(teleporter, true)
			
			call TriggerRegisterEnterRegion(.t, .reg, null)
			call TriggerAddCondition(.t, Condition(function thistype.onTeleportConditions))
            call TriggerAddAction(.t, function thistype.onTeleporting)
			
			set index = index + 1
			
			/*
			 * Teleporter backward
			 */
			set .t = CreateTrigger()
			set .reg = CreateRegion()
			set table[GetHandleId(.t)] = this
			
			call SaveRect(TELEPORT_RECTS[index][0], this)
			call RegionAddRectSaved(.reg, TELEPORT_RECTS[index][0])
            set x = GetRectCenterX(TELEPORT_RECTS[index][0])
            set y = GetRectCenterY(TELEPORT_RECTS[index][0])
            set teleporter = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), TELEPORTER_ID, x, y, 0.00)
			call PingMinimap(x, y, 1.0)
			
			call SetAltMinimapIcon("war3mapImported\\Minimap-Teleporter.blp")
			call UnitSetUsesAltIcon(teleporter, true)
			
			call TriggerRegisterEnterRegion(.t, .reg, null)
			call TriggerAddCondition(.t, Condition(function thistype.onTeleportConditions))
            call TriggerAddAction(.t, function thistype.onTeleporting)
			
			set index = index + 1

			set .t = null
			set teleporter = null
			
			return this
		endmethod
	endstruct

	private function init takes nothing returns nothing
		set table = Table.create()
		
		set TELEPORT_RECTS[0][0] = gg_rct_Portal0x0 //Start Teleporter
        set TELEPORT_RECTS[0][1] = gg_rct_Portal1x1 //Ziel Teleporter
				
		set TELEPORT_RECTS[1][0] = gg_rct_Portal1x0 //Start Teleporter
        set TELEPORT_RECTS[1][1] = gg_rct_Portal0x1 //Ziel Teleporter
		
		set TELEPORT_RECTS[2][0] = gg_rct_Portal2x0 //Start Teleporter
        set TELEPORT_RECTS[2][1] = gg_rct_Portal3x1 //Ziel Teleporter
				
		set TELEPORT_RECTS[3][0] = gg_rct_Portal3x0 //Start Teleporter
        set TELEPORT_RECTS[3][1] = gg_rct_Portal2x1 //Ziel Teleporter
	endfunction
endscope