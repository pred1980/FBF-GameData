scope SpiderWeb initializer init
    /*
     * Description: Spiders are known as the world best weavers. The Widow is no different, 
                    with her webs shes able to both catch her enemies and keep them at a distance. 
                    Once a vitcim is caught by her webs, it will be unable to even move a finger.
     * Last Update: 20.02.2015
     * Changelog: 
     *     27.10.2013: Abgleich mit OE und der Exceltabelle
	 *     20.02.2015: Cooldown von 1s auf 0 gesetzt
     *
     */
    globals
        private constant integer SPIDER = 'U01O'
        private constant integer CHILD_ID = 'n00C'
        private constant integer SPELL_ID = 'A005'
        private constant integer DUMMY_ID = 'h016'
        private constant integer DUMMY_SPELL_ID = 'A035'
        private constant integer WEB_AURA_ID = 'B002'
        private constant real WEB_START_DURATION = 5.5
        private constant real WEB_INCREASE_DURATION = 0.5
        private constant real SIZE = 175.0
        
        private trigger leaveWebAura
    endglobals

    private struct SpiderWeb
        unit caster
        unit dummy
        real x
        real y
        real duration
        timer ti
        integer level
        
        static method timerCallback takes nothing returns nothing
            local thistype this = GetTimerData( GetExpiredTimer() )
            call this.destroy()
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .x = GetUnitX(.caster)
            set .y = GetUnitY(.caster)
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .duration = WEB_START_DURATION + ( .level * WEB_INCREASE_DURATION )
        
            set .dummy = CreateUnit(GetOwningPlayer(.caster), DUMMY_ID, .x, .y, bj_UNIT_FACING)
            call UnitAddAbility( .dummy, DUMMY_SPELL_ID )
            call SetUnitAbilityLevel( .dummy, DUMMY_SPELL_ID, .level )
            call UnitApplyTimedLife( .dummy, 'BTLF', .duration )
            call TriggerRegisterLeaveRectSimple(leaveWebAura, RectFromCenterSize(.x, .y, SIZE, SIZE))
            
            set .ti = NewTimer()
            call SetTimerData( .ti, this )
            call TimerStart( .ti, .duration, false, function thistype.timerCallback )
            
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer( .ti )
            set .ti = null
            set .caster = null
            set .dummy = null
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local SpiderWeb sw = 0
        if( GetSpellAbilityId() == SPELL_ID )then
            set sw = SpiderWeb.create(GetTriggerUnit())
        endif
    endfunction
    
    private function LeaveWebAuraActions takes nothing returns nothing
        local unit u = GetTriggerUnit()
        
        if GetUnitAbilityLevel(u, WEB_AURA_ID) > 0 then
            call UnitRemoveAbility(u, WEB_AURA_ID)
        endif
        set u = null
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        set leaveWebAura = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction(t, function Actions)
        call TriggerAddAction( leaveWebAura, function LeaveWebAuraActions )
        
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction

endscope