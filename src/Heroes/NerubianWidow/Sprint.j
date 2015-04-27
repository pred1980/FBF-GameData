scope Sprint initializer init
    /*
     * Description: The Widow whispers a forbidden curse that increases her movement speed at a constant mana cost.
     * Changelog: 
     *     	27.10.2013: Abgleich mit OE und der Exceltabelle
	 *     	21.04.2015: Integrated RegisterPlayerUnitEvent
						Code Refactoring
	 
     *
	 * Note: Level 5 des Speed bed. einen Speed von 520, also fast max. speed bei wc3 ( 522 )
     */
	private keyword Sprint
	 
    globals
        private constant integer SPELL_ID = 'A024'
        private constant string ORDER_ACTIVATED = "immolation"
        private constant string ORDER_DEACTIVATED = "unimmolation"
        private constant integer SPEED_ACCELERATE = 45
        private constant real MANA_CHECK_INTERVAL = 0.5
		
		private Sprint array spellForUnit
    endglobals

    private struct Sprint
        unit caster
        timer ti
        real ms
        
		method onDestroy takes nothing returns nothing
			call ReleaseTimer( this.ti )
			call SetUnitBonus(.caster, BONUS_MOVEMENT_SPEED, 0)
			set spellForUnit[GetUnitId(.caster)] = 0
            set .caster = null
        endmethod
        
		static method getForUnit takes unit u returns thistype
			return spellForUnit[GetUnitId(u)]
		endmethod
		
        static method timerCallback takes nothing returns nothing
            local thistype this = GetTimerData( GetExpiredTimer() )
            if ( GetUnitState(this.caster, UNIT_STATE_MANA) < 10 ) then
                call this.destroy()
            endif
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
			set spellForUnit[GetUnitId(.caster)] = this
			call SetUnitBonus(.caster, BONUS_MOVEMENT_SPEED, GetUnitBonus(.caster, BONUS_MOVEMENT_SPEED ) + (GetUnitAbilityLevel(.caster, SPELL_ID) * SPEED_ACCELERATE ))
			
			set .ti = NewTimer()
			call SetTimerData( .ti, this )
			call TimerStart( .ti, MANA_CHECK_INTERVAL, true, function thistype.timerCallback )
			
            return this
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
		local Sprint s = 0
		local unit caster = GetTriggerUnit()
		local integer orderId = GetIssuedOrderId()
		
		if ((orderId == OrderId(ORDER_ACTIVATED) or orderId == OrderId(ORDER_DEACTIVATED)) and /*
		*/  caster != null) then
			set s = Sprint.getForUnit(caster)
			if s == 0 then
				set s = Sprint.create(caster)
			else
				call s.destroy()
			endif
		endif

		set caster =  null
    endfunction
	
	private function Conditions takes nothing returns boolean
		local unit u = GetTriggerUnit()
		local boolean b = false
		
		if (GetUnitAbilityLevel(u, SPELL_ID) > 0 and /*
		*/	GetPlayerController(GetOwningPlayer(u)) == MAP_CONTROL_USER) then
			set b = true
		endif
		
		set u = null
		
		return b
    endfunction
    
    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function Conditions, function Actions)
    endfunction

endscope