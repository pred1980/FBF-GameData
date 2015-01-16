scope FogOfDeath initializer init
    /*
     * Description: Akull partially evaporates into a bone-chilling mist that deals damage over time to all units inside. 
                    As long as the spell is active, hes mostly formless, making 50% of the attacks on him miss.
     * Last Update: 28.10.2013
     * Changelog: 
     *     28.10.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A04M'
        private constant integer DUMMY_ID = 'h005'
        private constant real SPELL_DURATION = 30.0
        private constant real INTERVAL = 5.0 
        private constant integer CHANCE_TO_HIT = 50
        
        //DOT
        private constant real DOT_TIME = .75
        private constant string EFFECT = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"
        private constant string ATT_POINT = "chest"
        private constant attacktype ATT_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_UNIVERSAL
        
        private real array DAMAGE_PER_SECOND
        private real RADIUS = 700
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DAMAGE_PER_SECOND[1] = 20
        set DAMAGE_PER_SECOND[2] = 30
        set DAMAGE_PER_SECOND[3] = 40
    endfunction

    private struct FogOfDeath
        unit caster
        unit dummy
        group targets
        timer main
        timer i
        timer gi
        integer level = 0
        real mainTime = 0
        real intveralTime = 0
        static thistype tempthis
        
        static method create takes unit c returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = c
            set .targets = NewGroup()
            set .main = NewTimer()
            set .i = NewTimer()
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .tempthis = this
            
            call SetTimerData(.main, this)
            call TimerStart(.main, 1.0, true, function thistype.onMainPeriodic)
            call SetTimerData(.i, this)
            call TimerStart(.i, INTERVAL, true, function thistype.onIntervalPeriodic)
            
            return this
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitEnemy( GetFilterUnit(), GetOwningPlayer( .tempthis.caster ) )
        endmethod
        
        static method onMainPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.mainTime = this.mainTime + 1.0
            if this.mainTime > SPELL_DURATION or IsUnitDead(this.caster) then
                call this.destroy()
            endif
        endmethod
        
        static method onIntervalPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.dummy = CreateUnit(GetOwningPlayer(this.caster), DUMMY_ID, GetUnitX(this.caster),GetUnitY(this.caster), 0)
            call UnitApplyTimedLife( this.dummy, 'BTLF', INTERVAL )
            set this.gi = NewTimer()
            call SetTimerData(this.gi, this)
            call TimerStart(this.gi, 1.0, true, function thistype.onDamagePeriodic)
        endmethod
        
        static method onDamagePeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.intveralTime = this.intveralTime + 1.0
            if ( this.intveralTime < INTERVAL ) then
                call GroupEnumUnitsInArea( this.targets, GetUnitX(this.dummy), GetUnitY(this.dummy), RADIUS,  Filter(function thistype.group_filter_callback) )
                call ForGroup( this.targets, function thistype.damage )
            else
                call ReleaseTimer(GetExpiredTimer())
                set this.intveralTime = 0
            endif
        endmethod
        
        static method damage takes nothing returns nothing
            local unit u = GetEnumUnit()
            if GetRandomInt(1,100) >= CHANCE_TO_HIT then
                call DOT.start( .tempthis.caster , u , DAMAGE_PER_SECOND[.tempthis.level] , DOT_TIME , ATT_TYPE , DMG_TYPE , EFFECT , ATT_POINT )
            endif
            call GroupRemoveUnit(.tempthis.targets, u)
            set u = null
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            call ReleaseTimer( .main )
            call ReleaseTimer( .i )
            call ReleaseTimer( .gi )
            set .main = null
            set .i = null
            set .gi = null
            set .caster = null
            set .dummy = null
            set .targets = null
        endmethod
        
        static method onInit takes nothing returns nothing
            set thistype.tempthis = 0
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local FogOfDeath fod = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set fod = FogOfDeath.create( GetTriggerUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call MainSetup()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call Preload(EFFECT)
    endfunction

endscope