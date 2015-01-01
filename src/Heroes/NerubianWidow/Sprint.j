scope Sprint initializer init
    /*
     * Description: The Widow whispers a forbidden curse that increases her movement speed at a constant mana cost.
     * Last Update: 27.10.2013
     * Changelog: 
     *     27.10.2013: Abgleich mit OE und der Exceltabelle
     *
	 * Note: Level 5 des Speed bed. einen Speed von 520, also fast max. speed bei wc3 ( 522 )
	 *		 INFO: MovementBonus verbauen!!!!!!!
	 *		 call AddUnitBonus(u, BONUS_MOVESPEED,-.BonusMoveSpeed)
     */
	 
    globals
        private constant integer SPELL_ID = 'A024'
        private constant string ORDER_ACTIVATED = "immolation"
        private constant string ORDER_DEACTIVATED = "unimmolation"
        private constant integer SPEED_ACCELERATE = 45
        private constant real MANA_CHECK_INTERVAL = 0.5
    endglobals

    private struct Sprint
        unit caster
        timer ti
        real ms
        integer level
        
        static method timerCallback takes nothing returns boolean
            local thistype this = GetTimerData( GetExpiredTimer() )
            if ( GetUnitState(this.caster, UNIT_STATE_MANA) < 10 ) then
                call ReleaseTimer( this.ti )
                set this.ti = null
                call this.destroy()
                return true
            endif
            return false
        endmethod
        
        static method create takes unit caster, string order returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            
            if ( order == ORDER_ACTIVATED ) then
                set .ti = NewTimer()
                call SetTimerData( .ti, this )
                call TimerStart( .ti, MANA_CHECK_INTERVAL, true, function thistype.timerCallback )
                call SetUnitBonus(.caster, BONUS_MOVEMENT_SPEED, GetUnitBonus(.caster, BONUS_MOVEMENT_SPEED ) + (GetUnitAbilityLevel(.caster, SPELL_ID) * SPEED_ACCELERATE ))
            else
                call SetUnitMoveSpeed( .caster, GetUnitDefaultMoveSpeed(.caster) )
                call this.destroy()
            endif
           
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .caster = null
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local Sprint s = 0
        if GetUnitAbilityLevel(GetTriggerUnit(), SPELL_ID) > 0 then
            if GetIssuedOrderId() == String2OrderIdBJ(ORDER_ACTIVATED) then
                set s = Sprint.create(GetTriggerUnit(), ORDER_ACTIVATED )
            else
                set s = Sprint.create(GetTriggerUnit(), ORDER_DEACTIVATED )
            endif
        endif
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ISSUED_ORDER )
        call TriggerAddAction(t, function Actions)
    endfunction

endscope