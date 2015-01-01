scope TidalShield initializer init
    /*
     * Description: This shield makes the Naga immune to spells and boosts her life regeneration.
     * Last Update: 08.01.2014
     * Changelog: 
     *     08.01.2014: Abgleich mit OE und der Exceltabelle + Bugfixing und kleinerem Umbau
     *
     */ 
    globals
        private constant integer SPELL_ID = 'A07O'
        private constant integer BUFF_ID = 'B01C'
        private constant real INTERVAL = 1.0
        //Has to be the same as the duration of the Buff to apply the right heal
        private real array HEAL
        
        //Heal over Time Effect
        private constant real HEAL_DURATION = 10.0
        private constant string EFFECT = ""
        private constant string ATT_POINT = ""
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set HEAL[0] = 100
        set HEAL[1] = 150
        set HEAL[2] = 200
        set HEAL[3] = 250
        set HEAL[4] = 300
    endfunction

    private struct TidalShield
        unit caster
        
        method onDestroy takes nothing returns nothing
            set .caster = null
        endmethod
        
        static method onRegenerate takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            if GetUnitAbilityLevel(this.caster, BUFF_ID) == 0 or GetUnitLifePercent(this.caster) == 100.00 then
                call ReleaseTimer(GetExpiredTimer())
                call UnitRemoveAbility(this.caster, BUFF_ID)
                call this.destroy()
            endif
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            local integer level = 0
            local timer t
            
            set .caster = caster
            set level = GetUnitAbilityLevel(.caster, SPELL_ID) - 1
            
            call HOT.start(.caster, HEAL[level], HEAL_DURATION, EFFECT, ATT_POINT )
            
            set t = NewTimer()
            call SetTimerData(t, this)
            call TimerStart(t, INTERVAL, true, function thistype.onRegenerate)
            
            return this
        endmethod
       
    endstruct

    private function Actions takes nothing returns nothing
        local TidalShield ts = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set ts = TidalShield.create( GetTriggerUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call MainSetup()
        
        set t = null
    endfunction

endscope
