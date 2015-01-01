scope FireTotem initializer init
    /*
     * Description: The Tauren Chieftain creates a burning Totem at a target point which attacks nearby enemy units.
     * Last Update: 06.01.2014
     * Changelog: 
     *     06.01.2014: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A078'
        private constant integer TOTEM_ID = 'o001'
        private constant integer BASE_DAMAGE = 15
        private constant integer DAMAGE_PER_LEVEL = 20
        private constant real DURATION = 15.0
        
        private string SOUND = "Units\\Orc\\StasisTotem\\StasisTrapBirth.wav"
    endglobals

    private struct FireTotem
        unit totem
        integer level = 0
        timer t
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
            set .t = null
            set .totem = null
        endmethod
        
        static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
        static method create takes unit caster, real x, real y returns thistype
            local thistype this = thistype.allocate()
            
            set .level = GetUnitAbilityLevel(caster, SPELL_ID)
            set .totem = CreateUnit( GetOwningPlayer(caster), TOTEM_ID, x, y, 0 )
            call Sound.runSoundOnUnit(SOUND, .totem)
            call TDS.addDamage(.totem, BASE_DAMAGE + (DAMAGE_PER_LEVEL * .level))
            call UnitApplyTimedLife( .totem, 'BTLF', DURATION )
            set .t = NewTimer()
            call SetTimerData( .t , this )
            call TimerStart(.t, DURATION, false, function thistype.onEnd)
            
            return this
        endmethod
                
        static method onInit takes nothing returns nothing
			call Sound.preload(SOUND)
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local FireTotem ft = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set ft = FireTotem.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        
        set t = null
    endfunction

endscope