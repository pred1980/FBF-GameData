scope Adolescence initializer init
    /*
     * Description: The Nerubian Widow lays eggs that spawn spiderlings. Growing up, 
                    these sworn companions support the Widow in teaching her enemies the real meaning of Arachnophobia.
     * Last Update: 27.10.2013
     * Changelog: 
     *     27.10.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A004'
        private constant integer EGG_ID = 'o00R'
        private constant integer CHILD_ID = 'n00C'
        private constant integer DUMMY_INVENTAR_ID = 'AInv'
        private constant real HATCHING_TIME = 4.5
        private constant real LIFE_TIME = 85
        private constant real TIMER_INTERVAL = 1.0
        private constant real START_SIZE = 0.15
        
        private integer array DAMAGE_PER_SECOND
        private real array START_HP
        private real array HP_PER_SECONDS
     
        private string SOUND_1 = "Units\\Critters\\SpiderCrab\\CrabDeath1.wav"
        private string SOUND_2 = "Units\\Creeps\\Spider\\SpiderYes2.wav"
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DAMAGE_PER_SECOND[1] = 1
        set DAMAGE_PER_SECOND[2] = 2
        set DAMAGE_PER_SECOND[3] = 3
        set DAMAGE_PER_SECOND[4] = 4
        set DAMAGE_PER_SECOND[5] = 5
        
        set START_HP[1] = 150.0
        set START_HP[2] = 175.0
        set START_HP[3] = 200.0
        set START_HP[4] = 225.0
        set START_HP[5] = 250.0
        
        set HP_PER_SECONDS[1] = 5.0
        set HP_PER_SECONDS[2] = 6.0
        set HP_PER_SECONDS[3] = 7.0
        set HP_PER_SECONDS[4] = 8.0
        set HP_PER_SECONDS[5] = 9.0
    endfunction

    private struct Adolescence
        unit caster
        unit egg
        unit child
        real size = 0.00
        timer ti
        
        static method AddValues takes nothing returns nothing
            local thistype this = GetTimerData( GetExpiredTimer() )
            
            if not IsUnitDead(this.child) then
                set .size = .size + 0.01
                call SetUnitScale(this.child, (START_SIZE + .size), (START_SIZE + .size), (START_SIZE + .size))
                call AddUnitMaxState(this.child, UNIT_STATE_MAX_LIFE, HP_PER_SECONDS[GetUnitAbilityLevel(this.caster, SPELL_ID)])
                call TDS.addDamage(this.child, DAMAGE_PER_SECOND[GetUnitAbilityLevel(this.caster, SPELL_ID)])
            else
                call this.destroy()
            endif
        endmethod
        
        static method Child takes nothing returns nothing
            local thistype this = GetTimerData( GetExpiredTimer() )
            
            set .child = CreateUnit( GetOwningPlayer( this.caster ), CHILD_ID, GetUnitX(this.egg), GetUnitY(this.egg), 0 )
            call Sound.runSoundOnUnit(SOUND_2, .child)
            call UnitApplyTimedLife( .child, 'BTLF', LIFE_TIME )
            call SetUnitScale(.child, START_SIZE, START_SIZE, START_SIZE)
            call SetUnitVertexColor( .child, PercentTo255(GetRandomReal(1.00, 100.00)), PercentTo255(GetRandomReal(1.00, 100.00)), PercentTo255(GetRandomReal(1.00, 100.00)), PercentTo255(100))
            call UnitAddAbility( .child, DUMMY_INVENTAR_ID )
            call SetUnitMaxState(.child, UNIT_STATE_MAX_LIFE, START_HP[GetUnitAbilityLevel(this.caster, SPELL_ID)])
            
            call SetTimerData( .ti, this )
            call TimerStart( .ti, 1, true, function thistype.AddValues )
            
            endmethod
        
        static method Egg takes nothing returns nothing
            local thistype this = GetTimerData( GetExpiredTimer() )
            
            call Sound.runSoundOnUnit(SOUND_1, this.egg)
            
            call SetTimerData( .ti, this )
            call TimerStart( .ti, 2.10, false, function thistype.Child )
        endmethod
        
        static method create takes unit c, real tx, real ty returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = c
            set .egg = CreateUnit( GetOwningPlayer( .caster ), EGG_ID, tx, ty, 0 )
            call UnitApplyTimedLife( .egg, 'BTLF', HATCHING_TIME )
            
            set .ti = NewTimer()
            call SetTimerData( .ti, this )
            call TimerStart( .ti, HATCHING_TIME, false, function thistype.Egg )
        
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .caster = null
            set .egg = null
            set .child = null
            call ReleaseTimer( .ti )
        endmethod
        
        static method onInit takes nothing returns nothing
            call MainSetup()
			call Sound.preload(SOUND_1)
			call Sound.preload(SOUND_2)
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local Adolescence a = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set a = Adolescence.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
    endfunction

endscope