scope DamageLog initializer Init

	globals
		private constant real DURATION = 3.0
	endglobals

	private struct Data
		 unit u
	 endstruct

	struct DamageLog
		private static group g
		
		private static method remove takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local Data data = GetTimerData(t)
			call ReleaseTimer(t)
			call GroupRemoveUnit(.g, data.u)
			call data.destroy()
			debug call BJDebugMsg("Remove Unit " + GetUnitName(data.u) + " from the System.")
		endmethod
		
		static method add takes unit u returns nothing
			local timer t
			local Data data
			
			if not IsUnitInGroup(u, .g) then
				set data = Data.create()
				set data.u = u
				set t = NewTimer()
				call SetTimerData(t, data)
				call TimerStart(t, DURATION, false, function thistype.remove)
				call GroupAddUnit(.g, u)
				set t = null
				debug call BJDebugMsg("Add Unit " + GetUnitName(u) + " to the System.")
			endif
		endmethod
		
		static method isUnitDamaged takes unit u returns boolean
			return IsUnitInGroup(u, .g)
		endmethod
	
		private static method onInit takes nothing returns nothing
			set g = NewGroup()
		endmethod
	endstruct
	
	private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if (IsUnitType(damagedUnit, UNIT_TYPE_HERO) and /*
		*/  IsUnitType(damageSource, UNIT_TYPE_HERO) and /*
		*/  GetPlayerController(GetOwningPlayer(damageSource)) == MAP_CONTROL_USER and /*
		*/	GetPlayerController(GetOwningPlayer(damagedUnit)) == MAP_CONTROL_USER and not /*
		*/	DamageLog.isUnitDamaged(damagedUnit)) then
				call DamageLog.add(damagedUnit)
        endif
    endfunction
	
	private function Init takes nothing returns nothing
		call RegisterDamageResponse(Actions)
	endfunction
endscope