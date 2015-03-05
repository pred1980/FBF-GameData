scope CoalitionTeleportSystem initializer init

    globals
        private constant integer ID = 'n00M'
		private constant rect array BASE_TELEPORTS_RECTS
		private constant rect array AOS_TELEPORT_RECTS
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

    struct CoalitionTeleport
		static fogmodifier visibibleArea
		static unit teleporter
		
		/* Nach kurzem Delay zur Basis zurueck teleportieren */
        static method onReturnToBaseDelay takes nothing returns nothing
            local TeleportData data = GetTimerData(GetExpiredTimer())
            
            if IsUnitInRegion(data.reg, data.target) and not IsUnitDead(data.target) then
                if data.counter > 1 then
                    call SetUnitPosition(data.target, data.x, data.y)
            
					if (GetLocalPlayer() == data.p) then
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
        
		static method onReturnToBaseConditions takes nothing returns boolean
			local unit u = GetTriggerUnit()
			local boolean b = false
			
			if IsUnitInRegion(GetTriggeringRegion(), teleporter) then
				if IsUnitType(u, UNIT_TYPE_HERO) and /*
				*/ (IsUnitAlly(u, ConvertedPlayer(IMaxBJ(7, 8))) or /*
				*/ IsUnitAlly(u, ConvertedPlayer(IMaxBJ(9, 10))) or /*
				*/ IsUnitAlly(u, ConvertedPlayer(IMaxBJ(11, 12)))) and /*
				*/ XE_Dummy_Conditions(u) then
					set b = true
				endif
			endif
			
			set u = null
			return b
		endmethod
		
        /* vom Schlachtfeld zur Base zurueck */
        static method onReturnToBase takes nothing returns nothing
            local region reg = GetTriggeringRegion()
            local unit u = GetTriggerUnit()
            local player p = GetOwningPlayer(u)
			local race r = GetPlayerRace(p)
            local real x = 0.00
            local real y = 0.00
            local timer t = NewTimer()
            local TeleportData data = TeleportData.create()
            
			if r == RACE_ORC then
                set x = GetRectCenterX(BASE_TELEPORTS_RECTS[1])
                set y = GetRectCenterY(BASE_TELEPORTS_RECTS[1])
            elseif r == RACE_NIGHTELF then
                set x = GetRectCenterX(BASE_TELEPORTS_RECTS[3])
                set y = GetRectCenterY(BASE_TELEPORTS_RECTS[3])
            else
                set x = GetRectCenterX(BASE_TELEPORTS_RECTS[5])
                set y = GetRectCenterY(BASE_TELEPORTS_RECTS[5])  
            endif
			
            set data.target = u
            set data.reg = reg
            set data.x = x
            set data.y = y
            set data.p = p
            
            call SetTimerData(t, data)
            call TimerStart(t, TELEPORT_DELAY, true, function thistype.onReturnToBaseDelay)
            
            set u = null
        endmethod
		
		static method onLeaveBaseConditions takes nothing returns boolean
			local unit u = GetTriggerUnit()
			local boolean b = false
			
			if GetUnitRace(u) == RACE_OTHER or /*
			*/ GetUnitRace(u) == RACE_ORC or /*
			*/ GetUnitRace(u) == RACE_NIGHTELF or /*
			*/ GetUnitRace(u) == RACE_HUMAN then
				if IsUnitType(u, UNIT_TYPE_HERO) or /*
				*/ IsUnitAlly(u, ConvertedPlayer(IMaxBJ(7, 12))) and /*
				*/ XE_Dummy_Conditions(u) then
					set b = true
				endif
			
			endif
			
			set u = null
			return b
		endmethod
        
        /* von der Base zum Schlachtfeld zurueck */
        static method onLeaveBase takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local player p = GetOwningPlayer(u)
            local real x = GetRectCenterX(AOS_TELEPORT_RECTS[PLACE_BY_ROUND[0][1]])
            local real y = GetRectCenterY(AOS_TELEPORT_RECTS[PLACE_BY_ROUND[0][1]])
            
			call DestroyEffect(AddSpecialEffect(EFFECT,x,y))
            call SetUnitPosition(u, x, y)
            
            if (GetLocalPlayer() == p) then
                call PanCameraToTimed(x, y, 0.00)
            endif
            call Sound.runSoundForPlayer(GLOBAL_SOUND_3, p)
            
			if GetPlayerRace(p) != RACE_UNDEAD and not CoalitionUnitShopTutorial.showTutorial[GetPlayerId(p)] then
				call CoalitionUnitShopTutorial.create(p, u)
			endif
					
            set u = null
        endmethod
		
		static method initialize takes nothing returns nothing
            local trigger t = CreateTrigger()
            local real x = 0.00
            local real y = 0.00
			local integer l = 0
            
            set x = GetRectCenterX(AOS_TELEPORT_RECTS[0])
            set y = GetRectCenterY(AOS_TELEPORT_RECTS[0])
			set teleporter = CreateUnit(Player(bj_PLAYER_NEUTRAL_VICTIM), ID, x, y, 0.00)
            
			//Sichtbarkeitsradius für die Spieler 6-12 erstellen, damit sie den Teleporter sehen
			loop
				exitwhen l >= bj_MAX_PLAYERS
				if Game.isPlayerInGame(l) then
					if GetPlayerRace(Player(l)) != RACE_UNDEAD then
						set .visibibleArea = CreateFogModifierRectBJ(true, Player(l), FOG_OF_WAR_VISIBLE, AOS_TELEPORT_RECTS[0])	
					endif
				endif
				
				set l = l + 1
			endloop
			
			call SetAltMinimapIcon("war3mapImported\\Minimap-Teleporter.blp")
			call UnitSetUsesAltIcon(teleporter, true)
            
            call TriggerRegisterEnterRectSimple(t, AOS_TELEPORT_RECTS[0])
            call TriggerAddCondition(t, Condition(function thistype.onReturnToBaseConditions))
            call TriggerAddAction(t, function thistype.onReturnToBase)
            
            set t = null
        endmethod
        
    endstruct
    
    private function init takes nothing returns nothing
        local trigger orcTeleport = CreateTrigger()
        local trigger nightelfTeleport = CreateTrigger()
        local trigger humanTeleport = CreateTrigger()
		local real x = 0.00
        local real y = 0.00
		
		set BASE_TELEPORTS_RECTS[0] = gg_rct_OrcTeleport0
        set BASE_TELEPORTS_RECTS[1] = gg_rct_OrcTeleport1
		set BASE_TELEPORTS_RECTS[2] = gg_rct_NightelfTeleport0
        set BASE_TELEPORTS_RECTS[3] = gg_rct_NightelfTeleport1
        set BASE_TELEPORTS_RECTS[4] = gg_rct_HumanTeleport0
        set BASE_TELEPORTS_RECTS[5] = gg_rct_HumanTeleport1
		
        set PLACE_BY_ROUND[0][0] = 0 // AOS_TELEPORT_RECTS[0]
        set PLACE_BY_ROUND[0][1] = 1 // AOS_TELEPORT_RECTS[1]
        
        set AOS_TELEPORT_RECTS[0] = gg_rct_CoalitionTeleport1x0
        set AOS_TELEPORT_RECTS[1] = gg_rct_CoalitionTeleport1x1
        
        call CreateUnit(Player(bj_PLAYER_NEUTRAL_VICTIM), ID, GetRectCenterX(BASE_TELEPORTS_RECTS[0]), GetRectCenterY(BASE_TELEPORTS_RECTS[0]), 0.00)
        call CreateUnit(Player(bj_PLAYER_NEUTRAL_VICTIM), ID, GetRectCenterX(BASE_TELEPORTS_RECTS[2]), GetRectCenterY(BASE_TELEPORTS_RECTS[2]), 0.00)
        call CreateUnit(Player(bj_PLAYER_NEUTRAL_VICTIM), ID, GetRectCenterX(BASE_TELEPORTS_RECTS[4]), GetRectCenterY(BASE_TELEPORTS_RECTS[4]), 0.00)
        
		//Orc Base
        call TriggerRegisterEnterRectSimple( orcTeleport, BASE_TELEPORTS_RECTS[0] )
        call TriggerAddCondition(orcTeleport, Condition(function CoalitionTeleport.onLeaveBaseConditions))
        call TriggerAddAction( orcTeleport, function CoalitionTeleport.onLeaveBase )
        
        //Nightelf Base
        call TriggerRegisterEnterRectSimple( nightelfTeleport, BASE_TELEPORTS_RECTS[2] )
        call TriggerAddCondition(nightelfTeleport, Condition(function CoalitionTeleport.onLeaveBaseConditions))
        call TriggerAddAction( nightelfTeleport, function CoalitionTeleport.onLeaveBase )
        
        //Human Base
        call TriggerRegisterEnterRectSimple( humanTeleport, BASE_TELEPORTS_RECTS[4] )
        call TriggerAddCondition(humanTeleport, Condition(function CoalitionTeleport.onLeaveBaseConditions))
        call TriggerAddAction( humanTeleport, function CoalitionTeleport.onLeaveBase )
		
        set orcTeleport = null
        set nightelfTeleport = null
        set humanTeleport = null
	endfunction
    
endscope