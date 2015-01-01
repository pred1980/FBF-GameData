scope Despair initializer init
    /*
     * Description: Kakos makes a unit enter a state crushing fear, reducing its attack speed. 
                    The penalty increases the more enemies the unit has to face.
     * Last Update: 05.11.2013
     * Changelog: 
     *     05.11.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A068'
        private constant integer BUFSPEL_ID = 'A069'
        private constant integer BUFF_ID = 'B033'
        private constant real RADIUS = 350
        private constant real INTERVAL = 0.5
        private constant integer MIN_LEVEL  = 1
        private constant integer MAX_LEVEL  = 9
        private integer array OFFSET
        private real array DURATION
    endglobals

    private function MainSetup takes nothing returns nothing
        
        set OFFSET[0] = 1
        set OFFSET[1] = 2
        set OFFSET[2] = 3
        set OFFSET[3] = 4
        set OFFSET[4] = 5
        
        set DURATION[0] = 8
        set DURATION[1] = 8.5
        set DURATION[2] = 9
        set DURATION[3] = 9.5
        set DURATION[4] = 10
        
    endfunction
    
    private struct Despair
        unit caster
        unit target
        integer advantage = 0
        integer level = 0
        timer intervalTimer
        timer durationTimer
        static thistype tempthis
        
        static method create takes unit c, unit t returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = c
            set .target = t
            set .advantage = 1
            set .level = GetUnitAbilityLevel(c,SPELL_ID)-1
            set .intervalTimer = NewTimer()
            set .durationTimer = NewTimer()
            call SetTimerData(.intervalTimer,this)
            call SetTimerData(.durationTimer,this)
            call UnitAddAbility(.target, BUFSPEL_ID)
            set .tempthis = this
            call GroupEnumUnitsInArea( ENUM_GROUP, GetUnitX(t), GetUnitY(t), RADIUS, Condition( function thistype.group_filter_callback) )
            call SetUnitAbilityLevel(.target,BUFSPEL_ID, IMinBJ(MAX_LEVEL, IMaxBJ(MIN_LEVEL, .advantage + OFFSET[.level])))
            call TimerStart(.intervalTimer, INTERVAL, true, function thistype.onTick)
            call TimerStart(.durationTimer, DURATION[.level], false, function thistype.onEnd)
            return this
        endmethod
                
        static method group_filter_callback takes nothing returns boolean
            local unit u = GetFilterUnit()
            
            if not IsUnitDead(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                if IsUnitAlly(u, GetOwningPlayer(.tempthis.target)) then
                    set .tempthis.advantage = .tempthis.advantage - 1
                endif
                if IsUnitEnemy(u, GetOwningPlayer(.tempthis.target)) then
                    set .tempthis.advantage = .tempthis.advantage + 1
                endif
            endif
            set u = null
            return false
        endmethod
        
        static method onTick takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            if IsUnitDead(this.target) then //Stop when unit is dead
                call this.destroy()
                return
            endif
            set this.advantage = 1
            call GroupEnumUnitsInArea( ENUM_GROUP, GetUnitX(this.target), GetUnitY(this.target), RADIUS, Condition( function thistype.group_filter_callback) )
            call SetUnitAbilityLevel(this.target, BUFSPEL_ID, IMinBJ(MAX_LEVEL, IMaxBJ(MIN_LEVEL,this.advantage + OFFSET[this.level])))
        endmethod
        
        static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
        method onDestroy takes nothing returns nothing
            call UnitRemoveAbility(.target, BUFSPEL_ID)
            call UnitRemoveAbility(.target, BUFF_ID)
            call ReleaseTimer(.intervalTimer)
            call ReleaseTimer(.durationTimer)
            set .intervalTimer = null
            set .durationTimer = null
            set .caster = null
            set .target = null
        endmethod
        
        static method onInit takes nothing returns nothing
            set .tempthis = 0
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local Despair d = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set d = Despair.create( GetTriggerUnit(), GetSpellTargetUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call MainSetup()
        call XE_PreloadAbility(BUFSPEL_ID)
    endfunction

endscope