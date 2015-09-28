scope HotCoals initializer init
    /*
     * eeve.org / Tower: Wealthy Fire Pit
     * Description: Whenever the Rock kills a creep it gains 15% bonus crit chance (2x) for 8.5 seconds.
     * Last Update: 18.12.2013
     * Changelog: 
     *      18.12.2013: Abgleich mit OE und der Exceltabelle
	 *      16.03.2014: Chancen von 30%/40%/50% auf 15%/20%/25% reduziert
	 *		17.09.2015: Decreased crit chance from 15%/20%/25% to 15%
						Decreased crit damage multiplier from 3.5 to 2.0
     */
     
    globals
        private constant integer SPELL_ID = 'A09Y'
        private integer array TOWER_ID
        private constant real CRIT_TIME = 8.5
    endglobals
    
    private struct HotCoals
        unit tower
        timer t
        integer level = 1
        
        method onDestroy takes nothing returns nothing
            call UnitRemoveAbility(.tower, SPELL_ID)
            call ReleaseTimer(.t)
            set .t = null
            set .tower = null
        endmethod
        
        static method onTimerEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
	    static method create takes unit tower returns thistype
            local thistype this = thistype.allocate()
            
            set .tower = tower
            set .level = TowerSystem.getTowerValue(GetUnitTypeId(.tower), 3)
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, CRIT_TIME, false, function thistype.onTimerEnd)
            call UnitAddAbility(.tower, SPELL_ID)
            call SetUnitAbilityLevel(.tower, SPELL_ID, .level)
            
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set TOWER_ID[0] = 'u00Y'
            set TOWER_ID[1] = 'u00Z'
            set TOWER_ID[2] = 'u010'
        endmethod
		
    endstruct

    private function Actions takes nothing returns nothing
        local HotCoals hc = 0
        set hc = HotCoals.create( GetKillingUnit() )
    endfunction
    
    private function Conditions takes nothing returns boolean
        local unit u = GetKillingUnit()
        
        if GetUnitTypeId(u) == TOWER_ID[0] or GetUnitTypeId(u) == TOWER_ID[1] or GetUnitTypeId(u) == TOWER_ID[2] and GetUnitAbilityLevel(u, SPELL_ID) == 0 then
            set u = null
            return true
        else
            set u = null
            return false
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_DEATH )
        call TriggerAddCondition( t, Condition( function Conditions ) )
        call TriggerAddAction( t, function Actions )
        set t = null
    endfunction

endscope