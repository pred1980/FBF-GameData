scope HerosWill initializer Init
	/*
     * The hero is able to move through all units for 5 seconds.
     * Changelog: 
     *     	xx.xx.2015: Initial Upload
     *		23.08.2021: Used Windwalk Ability
     */
	globals
        private constant integer SPELL_ID = 'A05E'
		private constant integer GHOST_VISIBLE_ID = 'A0B8'
		private constant real DURATION = 5.0
	endglobals
	
	private struct HerosWill
		private unit caster
		private timer t
		
		method onDestroy takes nothing returns nothing
			set .caster = null
        endmethod
		
		static method onHerosWillEnd takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			
			call UnitRemoveAbility(this.caster, GHOST_VISIBLE_ID)
			call ReleaseTimer(this.t)
			call this.destroy()
		endmethod
	
		static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .t = NewTimer()
            call SetTimerData(.t, this)
			call UnitAddAbility(.caster, GHOST_VISIBLE_ID)
            call TimerStart(.t, DURATION, false, function thistype.onHerosWillEnd)
            
            return this
        endmethod
	endstruct
	
	private function Actions takes nothing returns nothing
        call HerosWill.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
    endfunction
endscope