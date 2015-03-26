scope MaliciousCurse initializer init
     /*
     * Description: By the power of his black magic, Kakos is able to put a hex on an enemy unit. 
                    This unit will drain either the health or the mana of its nearby allies, 
                    but the unit itself is immune to this effect.
     * Last Update: 05.11.2013
     * Changelog: 
     *     05.11.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A064'
        private constant integer BUFF_ID = 'B00O' //The buff with which to differentiate between states
        private constant integer SWITCH_ID = 'A065' //The ability with which to switch between Life and Mana
        private constant integer LBUFF_ABI = 'A066'
        private constant integer LBUFF_BUF = 'B00P'	
        private constant integer MBUFF_ABI = 'A067'
        private constant integer MBUFF_BUF = 'B00Q'
        private constant integer DUMMY_ID = 'e00T'
        
        private constant boolean LBUFF_AGGRO = false //Whether the Lifedrain should draw aggro towards the Necromancer
        private constant boolean MBUFF_AGGRO = false //Whether the Manadrain should draw aggro towards the Necromancer
        
        private constant real RADIUS = 350
        private real array Drain
        private real array Duration
        private constant real Interval = 0.5
    endglobals

    private function MainSetup takes nothing returns nothing
        set Drain[0] = 0.02
        set Drain[1] = 0.03
        set Drain[2] = 0.04
        set Drain[3] = 0.05
        set Drain[4] = 0.06
        
        set Duration[0] = 10.0
        set Duration[1] = 9.0
        set Duration[2] = 8.0
        set Duration[3] = 7.0
        set Duration[4] = 6.0
    endfunction
    
    private struct MaliciousCurse
        unit caster
        unit target
        unit dummy
        boolean isLife
        timer itrvTimer
        timer durTimer
        integer level = 0
        static thistype tempthis
        
        static method create takes unit c, unit t, boolean l returns thistype
            local thistype this = thistype.allocate()
            set .caster = c
            set .target = t
            set .isLife = l
            set .level = GetUnitAbilityLevel(c,SPELL_ID)-1
            set .itrvTimer = NewTimer()
            set .durTimer = NewTimer()
            set .dummy = CreateUnit(GetOwningPlayer(c), DUMMY_ID, GetUnitX(t), GetUnitY(t), GetUnitFacing(t))
            
            if .isLife then
                call UnitAddAbility(.dummy, LBUFF_ABI)
            else
                call UnitAddAbility(.dummy, MBUFF_ABI)
            endif
            
            call SetTimerData(.itrvTimer,this)
            call SetTimerData(.durTimer,this)
            call TimerStart(.itrvTimer, Interval, true, function thistype.onTick)
            call TimerStart(.durTimer,Duration[.level],false, function thistype.onEnd)
            return this
        endmethod
        
        static method group_filter_callback_life takes nothing returns boolean
            local unit u = GetFilterUnit()
            local real dmg
            if GetUnitAbilityLevel(u, LBUFF_BUF) > 0 or GetUnitAbilityLevel(u, MBUFF_BUF) > 0 and not (u == .tempthis.dummy) then
                set dmg = GetUnitState(u, UNIT_STATE_MAX_LIFE) * Drain[.tempthis.level] * Interval
                
                static if LBUFF_AGGRO then
                    set DamageType = 1
                    call DamageUnitPure(.tempthis.caster, u, dmg)
                else
                    if GetUnitState(u, UNIT_STATE_LIFE) <= dmg then
                        set DamageType = 1
                        call DamageUnitPure(.tempthis.caster, u, dmg) 
                        //Even if it doesn't draw aggro, it should still count as kills
                    else
                        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_LIFE) - dmg)
                    endif
                endif
            endif
            set u = null
            return false
        endmethod
        
        static method group_filter_callback_mana takes nothing returns boolean
            local unit u = GetFilterUnit()
            local real dmg
            if GetUnitAbilityLevel(u, LBUFF_BUF) > 0 or GetUnitAbilityLevel(u, MBUFF_BUF) > 0 and not (u == .tempthis.dummy) then
                set dmg = GetUnitState(u, UNIT_STATE_MAX_MANA) * Drain[.tempthis.level] * Interval
                call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MANA) - dmg)
                static if MBUFF_AGGRO then
                    //Dealing 0 damage still makes the Portrait flash and draws aggro from purposeless 
                    set DamageType = 1
                    call DamageUnitPure(.tempthis.caster, u, 0) units
                endif
            endif
            set u = null
            return false
        endmethod
        
        static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
        static method onTick takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if IsUnitType(this.target,UNIT_TYPE_DEAD) then //Stop when the target is dead
                call this.destroy()
                return
            endif
            set this.tempthis = this
            call SetUnitPosition(this.dummy, GetUnitX(this.target), GetUnitY(this.target))
            if this.isLife then
                call GroupEnumUnitsInArea(ENUM_GROUP,GetUnitX(this.target), GetUnitY(this.target), RADIUS,Condition( function thistype.group_filter_callback_life))
            else
                call GroupEnumUnitsInArea(ENUM_GROUP,GetUnitX(this.target), GetUnitY(this.target), RADIUS,Condition( function thistype.group_filter_callback_mana))
            endif
        endmethod
        
        method onDestroy takes nothing returns nothing
            call UnitRemoveAbility(.dummy,LBUFF_ABI)
            call UnitRemoveAbility(.dummy,MBUFF_ABI)
            call RemoveUnit(.dummy)
            call ReleaseTimer(.itrvTimer)
            call ReleaseTimer(.durTimer)
            set .itrvTimer = null
            set .durTimer = null
            set .caster = null
            set .target = null
            set .dummy = null
        endmethod
        
        static method onInit takes nothing returns nothing
            set .tempthis = 0
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local MaliciousCurse mc = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set mc = MaliciousCurse.create( GetTriggerUnit(), GetSpellTargetUnit(), not (GetUnitAbilityLevel(GetTriggerUnit(),BUFF_ID)>0) )
        endif
    endfunction
    
    private function AddSwitch takes nothing returns boolean
        if GetLearnedSkill() == SPELL_ID and GetUnitAbilityLevel(GetTriggerUnit(),SWITCH_ID) < 1 then
            call UnitAddAbility(GetTriggerUnit(),SWITCH_ID)
        endif
        return false
    endfunction

    private function init takes nothing returns nothing
        local trigger trig = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( trig, function Actions )
        
        set trig = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_HERO_SKILL )
        call TriggerAddCondition(trig, Condition(function AddSwitch))
        
        call MainSetup()
        call XE_PreloadAbility(SWITCH_ID)
        call XE_PreloadAbility(LBUFF_ABI)
        call XE_PreloadAbility(MBUFF_ABI)
    endfunction

endscope