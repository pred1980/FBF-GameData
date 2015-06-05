scope RoundEndSystem

	globals
		private constant real TELEPORT_DELAY = 1.25
		private constant real TEXT_DURATION = 7.5
		private constant string EFFECT = "Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl"
	endglobals

	private struct TeleportBack
	
		readonly static real MIN_DISTANCE = 1000
	
		private static method filterCondition takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			
			if (not SpellHelper.isUnitDead(u) and not /*
					*/ IsUnitType(u, UNIT_TYPE_STRUCTURE) and not /*
					*/ IsUnitType(u, UNIT_TYPE_PEON)) and not /*
					*/ IsUnitType(u, UNIT_TYPE_MECHANICAL) then
					set b = true
			endif
			
			set u = null
			
			return b	
		endmethod
		
		private static method onPanCamera takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			local real x = GetRectCenterX(Homebase.get(this))
            local real y = GetRectCenterY(Homebase.get(this))
			
			if (GetLocalPlayer() == Player(this)) then
				call PanCameraToTimed(x, y, 0.00)
			endif
			
			call StopUnitsOfPlayer(Player(this))
			call ReleaseTimer(GetExpiredTimer())
		endmethod
		
		private static method prepareTeleport takes nothing returns nothing
			local unit u = GetEnumUnit()
			local player p
			local integer pid = 0
			local real x = 0.00
            local real y = 0.00
			local timer t
			
			if (Distance(GetUnitX(u), GetUnitY(u), x, y) > MIN_DISTANCE) then
				set p = GetOwningPlayer(u)
				set pid = GetPlayerId(p)
				set x = GetRectCenterX(Homebase.get(pid))
				set y = GetRectCenterY(Homebase.get(pid))
				set t = NewTimer()
				call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(u), GetUnitY(u)))
				call SetUnitPosition(u, x, y)
				call SetTimerData(t, pid)
				call TimerStart(t, TELEPORT_DELAY, false, function thistype.onPanCamera)
			endif
			
			set u = null
		endmethod

		static method initialize takes nothing returns nothing
			local integer i = 0
			
			loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) then
					call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(i), Condition(function thistype.filterCondition))
					call ForGroup(ENUM_GROUP, function thistype.prepareTeleport)
					call GroupRefresh(ENUM_GROUP)
				endif
                set i = i + 1
            endloop
		endmethod
	
	endstruct
	
	struct RoundEnd
	
		private static method teleportBack takes nothing returns nothing
			call TeleportBack.initialize()
		endmethod
		
		private static method addLumber takes nothing returns nothing
			local integer i = 0
            
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(GetLocalPlayer(),0.0 ,0.0 ,TEXT_DURATION , "*** Round |cffffcc00"+I2S(RoundSystem.actualRound)+"|r finished! ***")
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) and GetPlayerRace(Player(i)) == RACE_UNDEAD then
                    call Game.playerAddLumber(i, Evaluation.getLumber(RoundSystem.actualRound))
                    call DisplayTimedTextToPlayer(Player(i),0.0 ,0.0 ,TEXT_DURATION , "You received " + "|cffffcc00" + I2S(Evaluation.getLumber(RoundSystem.actualRound)) +"|r Lumber.")
                endif
                set i = i + 1
            endloop
		endmethod
		
		private static method createWardens takes nothing returns nothing
			call SpawnWarden.create()
		endmethod
		
		private static method removeForsakenDefense takes nothing returns nothing
			if (ForsakenUnits.removeCreeps) then
                call ForsakenUnits.removeAll()
            endif
		endmethod
		
		private static method changeTowerBuilder takes nothing returns nothing
			//Wenn akt. Runde groesser 5 und 13 ist, dann wechsel den Acolyt
            if RoundSystem.actualRound == 6 then
                call TowerSystem.changeBuilder()
            endif
            if RoundSystem.actualRound == 13 then
                call TowerSystem.changeBuilder()
            endif
		endmethod
		
		static method initialize takes nothing returns nothing
			call .teleportBack()
			call .addLumber()
			call .createWardens()
			call .removeForsakenDefense()
			call .changeTowerBuilder()
		endmethod
		
	endstruct

endscope