library StoneOfTeleportation uses RegisterPlayerUnitEvent, HomeBase
	private keyword INITS
	
	globals
		private constant integer SPELL_ID = 'A00U'
		private constant real TELEPORT_DELAY = 1.5
		private constant string EFFECT = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl"
	endglobals
	
	private struct TeleportStone
		implement INITS
		
		private integer pid = 0
		private real pause = 0.00
		private unit source
		private effect ef
		private player p
		
		method onDestroy takes nothing returns nothing
			set .source = null
            set .ef = null
			set .p = null
        endmethod
		
		private static method onReturnToBase takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			local real x = GetRectCenterX(Homebase.get(this.pid))
            local real y = GetRectCenterY(Homebase.get(this.pid))
			
			//Unpause Unit Alternative
			call SetUnitPropWindow(this.source, this.pause)

			if (GetLocalPlayer() == this.p) then
				call PanCameraToTimed(x, y, 0.00)
			endif			
			
			call SetUnitPosition(this.source, x, y)
			call SetUnitInvulnerable(.source, false)
			call ReleaseTimer(GetExpiredTimer())
			call onDestroy()
		endmethod
		
		static method create takes unit source returns thistype
			local thistype this = thistype.allocate()
			local timer t = NewTimer()
			
			set .source = source
			set .p = GetOwningPlayer(.source)
			set .pid = GetPlayerId(.p)
			
			//Pause Unit Alternative
			set .pause = GetUnitPropWindow(.source)
			call SetUnitPropWindow(.source, 0) 
			
			call SetUnitInvulnerable(.source, true)
			call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(.source), GetUnitY(.source)))
			call SetTimerData(t, this)
            call TimerStart(t, TELEPORT_DELAY, false, function thistype.onReturnToBase)
			
			return this
		endmethod
	endstruct
	
	private module INITS
	
		private static method onAction takes nothing returns nothing
			call thistype.create(GetTriggerUnit())
		endmethod
		
		private static method onConditions takes nothing returns boolean
			return GetSpellAbilityId() == SPELL_ID
		endmethod
	
		private static method onInit takes nothing returns nothing
			call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onConditions, function thistype.onAction)
        endmethod
	endmodule
endlibrary