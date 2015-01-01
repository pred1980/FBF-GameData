scope Snack initializer init
    /*
     * Description: Blight Cleaver joyfully feasts on an enemy hero, damaging him and healing himself for an equal amount. 
                    The enemy cannot move while being eaten. If the victim dies in the process, Blight Cleaver will 
                    permanently gain 3 points in Strength.
     * Last Update: 11.11.2013
     * Changelog: 
     *     11.11.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A06L'
        private boolean cancel
        private hashtable unitSpellData = InitHashtable()
        private real baseDamage = 70
        private real damageModifier = 0.5
        private integer iteration = 5
        private constant real INTERVAL = 1.0
        
        //Stun Effect for Pause Target
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = 5.0
    endglobals

    private struct Snack
        unit caster
        unit target
        real damage
        integer count
        
        method onDestroy takes nothing returns nothing
            call UnitEnableAttack(.caster)
            set .caster = null
            set .target = null
        endmethod
        
        static method create takes unit caster, unit target returns thistype
            local thistype data = thistype.allocate()
            set data.caster = caster
            set data.target = target
            set data.count = iteration
            set data.damage = baseDamage + ((baseDamage * damageModifier) * GetUnitAbilityLevel(caster, SPELL_ID))
            //Pause Unit / Used Stun System
            call Stun_UnitEx(target, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            call UnitDisableAttack(caster)
            return data
        endmethod
        
    endstruct

    private function timer_callback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local boolean dead
        local Snack data = LoadIntegerBJ(1,GetHandleId(t),unitSpellData)
        set data.count = data.count - 1
        
        set DamageType = SPELL
        call DamageUnit(data.caster,data.target,data.damage,false)
        if GetUnitState(data.caster, UNIT_STATE_LIFE) > 0 then
            call SetUnitAnimation(data.caster, "stand channel" )
            call SetUnitState(data.caster, UNIT_STATE_LIFE, GetUnitState(data.caster, UNIT_STATE_LIFE) + data.damage)
        endif
        if cancel or data.count == 0 then
            if GetUnitState(data.target,UNIT_STATE_LIFE) <= 0 and GetUnitState(data.caster,UNIT_STATE_LIFE) > 0 then
                call SetHeroStr(data.target,GetHeroStr(data.target,false) - 3,true)
                call SetHeroStr(data.caster,GetHeroStr(data.caster,false) + 3,true)
            endif
            call data.destroy()
            call DestroyTimer(t)
            set t = null
        else
            call TimerStart(t, 1.0, false, function timer_callback)
        endif
    endfunction

    private function conditions takes nothing returns boolean
        return GetSpellAbilityId()== SPELL_ID
    endfunction

    private function actionsStart takes nothing returns nothing
        local Snack s
        local timer t = CreateTimer()
        
        set s = Snack.create(GetTriggerUnit(),GetSpellTargetUnit())
        set cancel = false
        call SaveIntegerBJ(s, 1 ,GetHandleId(t),unitSpellData)
        call TimerStart(t,INTERVAL,false,function timer_callback)
    endfunction

    private function actionsEnd takes nothing returns nothing
        set cancel=true
    endfunction

    private function init takes nothing returns nothing
        local trigger trig = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(trig,EVENT_PLAYER_UNIT_SPELL_CHANNEL)
        call TriggerAddCondition(trig,Condition(function conditions))
        call TriggerAddAction(trig,function actionsStart)
        set trig = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(trig,EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        call TriggerAddCondition(trig,Condition(function conditions))
        call TriggerAddAction(trig,function actionsEnd)
        set trig = null
    endfunction

endscope