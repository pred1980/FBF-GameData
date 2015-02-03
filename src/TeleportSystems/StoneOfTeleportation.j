library StoneOfTeleportation uses RegisterPlayerUnitEvent, HomeBase
	private keyword INITS
	
	globals
		private constant integer SPELL_ID = 'A00U'
		private constant real TELEPORT_DELAY = 1.5
		private constant string EFFECT = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl"
		
		//Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = TELEPORT_DELAY
	endglobals
	
	private struct TeleportStone
		implement INITS
		
		integer pid = 0
		unit source
		effect ef
		
		method onDestroy takes nothing returns nothing
			set .source = null
            set .ef = null
        endmethod
		
		private static method onReturnToBase takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			local real x = GetRectCenterX(Homebase.get(this.pid))
            local real y = GetRectCenterY(Homebase.get(this.pid))
			
			call SetUnitPosition(this.source, x, y)
			call SetUnitInvulnerable(.source, false)
			call ReleaseTimer(GetExpiredTimer())
			call onDestroy()
		endmethod
		
		static method create takes unit source returns thistype
			local thistype this = thistype.allocate()
			local timer t = NewTimer()
			
			set .source = source
			set .pid = GetPlayerId(GetOwningPlayer(.source))
			
			call SetUnitInvulnerable(.source, true)
			call Stun_UnitEx(.source, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
			call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(.source), GetUnitY(.source)))
			call SetTimerData(t, this)
            call TimerStart(t, TELEPORT_DELAY, false, function thistype.onReturnToBase)
			
			return this
		endmethod
	endstruct
	
	private module INITS
	
		private static method onAction takes nothing returns nothing
			if (GetSpellAbilityId() == SPELL_ID) then
				call thistype.create(GetTriggerUnit())
			endif
		endmethod
	
		private static method onInit takes nothing returns nothing
			call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onAction)
        endmethod
	endmodule
endlibrary