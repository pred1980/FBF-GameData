scope WidowBite initializer init
    /*
     * Description: The Widow strikes an enemy with her deadly fangs, injecting lethal posion to the victim. 
                    The grim venom paralyzes and cripples the unit, until it finally causes a massive amount of damage on it.
     * Last Update: 27.10.2013
     * Changelog: 
     *     27.10.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A003'
        private constant integer DUMMY_SPELL_ID = 'A000'
        private constant real MAX_TIME = 40.0
        private constant real START_DAMAGE = 50
        private constant real DAMAGE_PER_LEVEL = 45
        private constant real DIMENSION = 500
        
        //DOT
        private constant real DOT_TIME = 5.00
        private constant string EFFECT = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
        private constant string ATT_POINT = "origin"
        private constant attacktype ATT_TYPE = ATTACK_TYPE_HERO
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_SLOW_POISON
    endglobals

    private struct WidowBite
        unit caster
        unit target
        real time = 0.00
        real x = 0.00
        real y = 0.00
        real colorVal = 100.0
        real damage
        boolean array progress[4]
        timer t
        rect r
        
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .target = target
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, 1.0, true, function thistype.onPeriodic)
            
            return this
        endmethod
        
        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.time = this.time + 1.0
            set this.colorVal = this.colorVal - 2.0
            call SetUnitVertexColor(this.target, PercentTo255(this.colorVal), PercentTo255(100), PercentTo255(this.colorVal), PercentTo255(100))
            //progress Statue 1
            if this.time <= 10 and .progress[0] == false then
                set .progress[0] = true
                call UnitAddAbility( this.target, DUMMY_SPELL_ID )
                call SetUnitAbilityLevel( this.target, DUMMY_SPELL_ID, 1 )
            endif
            //progress Statue 2
            if (this.time > 10 and this.time <= 20) and .progress[1] == false then
                set .progress[1] = true
                call SetUnitAbilityLevel( this.target, DUMMY_SPELL_ID, 2 )
            endif
            //progress Statue 3
            if (this.time > 20 and this.time <= 30) and .progress[2] == false then
                if ( this.time == 21) then
                    call SetUnitAbilityLevel( this.target, DUMMY_SPELL_ID, 3 )
                endif
                if ( this.time == 27) then
                    set .progress[2] = true
                endif
                set .r = Rect( GetUnitX(this.target) - DIMENSION, GetUnitY(this.target) - DIMENSION, GetUnitX(this.target) + DIMENSION, GetUnitY(this.target) + DIMENSION )
                set .x = GetRandomReal( GetRectMinX(r), GetRectMaxX(r) )
                set .y = GetRandomReal( GetRectMinY(r), GetRectMaxY(r) )
                call IssuePointOrder( this.target, "attack", .x, .y )
            endif
            //progress Statue 4
            if (this.time > 30 and this.time <= MAX_TIME) and .progress[3] == false then
                if (this.time == 31 and not IsUnitInvulnerable(this.target))  then
                    call SetUnitAbilityLevel( this.target, DUMMY_SPELL_ID, 4 )
                    set damage = (START_DAMAGE + (GetUnitAbilityLevel(this.caster, SPELL_ID) * DAMAGE_PER_LEVEL)) * DOT_TIME
                    call DOT.start( this.caster , this.target , damage , DOT_TIME , ATT_TYPE , DMG_TYPE , EFFECT , ATT_POINT )
                endif
                if ( this.time == 37) then
                    set .progress[3] = true
                endif
                set .r = Rect( GetUnitX(this.target) - DIMENSION, GetUnitY(this.target) - DIMENSION, GetUnitX(this.target) + DIMENSION, GetUnitY(this.target) + DIMENSION )
                set .x = GetRandomReal( GetRectMinX(r), GetRectMaxX(r) )
                set .y = GetRandomReal( GetRectMinY(r), GetRectMaxY(r) )
                call IssuePointOrder( this.target, "attack" , .x, .y )
            endif
            if this.time > MAX_TIME then
                call this.destroy()
            endif
        endmethod
        
        method onDestroy takes nothing returns nothing
            call UnitRemoveAbility(.target, DUMMY_SPELL_ID)
            call SetUnitVertexColor(.target, PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(100))
            set .caster = null
            set .target = null
            call ReleaseTimer( .t )
            set .t = null
            set .r = null
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local WidowBite wb = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set wb = WidowBite.create( GetTriggerUnit(), GetSpellTargetUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger trig = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( trig, function Actions )
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(EFFECT)
    endfunction

endscope