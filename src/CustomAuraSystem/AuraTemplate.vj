library AuraTemplate requires CustomAura
    struct AuraTemplate extends CustomAura
        implement CABonus
        implement CABuff
    endstruct
endlibrary

//! textmacro AuraTemplateMethods
    private static method new takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local integer i = GetHandleId(u)
        local integer s = GetLearnedSkill()
        local integer l = GetUnitAbilityLevel(u, s)
        local thistype this = thistype.load(i)
        
        //: Check whether the aura spell ID is valid
        if s != SPELL_ID then
            set u = null
            return false
        endif
        
        if this == 0 then
            set this = thistype.create(u)
            set this.spellId = SPELL_ID
            set .ID = i
            call .save()
        else
            //: If we can load the data unaffect all so they get the
            //: new bonuses
            call .unaffectAll()
        endif
        
        //: Update the buff and bonus data
        //: PLEASE DO NOT PUT THIS BEFORE .unaffectAll() !
        if BUFF_SPELL != 0 and BUFF_ID != 0 and BUFF_ORDER != null then
            call .setBuff(BUFF_SPELL, l, BUFF_ID, BUFF_ORDER, true)
        endif
        call .onLevelup(l)
        
        set u = null
        return false
    endmethod
    
    private static method onInit takes nothing returns nothing
        local integer i = 0
        local trigger t = null
        
        if SPELL_ID == 0 then
            return
        endif
        
        set t = CreateTrigger()
        call TriggerAddCondition(t, Condition(function thistype.new))
        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            
            call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_HERO_SKILL, null)
            set i = i +1
        endloop
    endmethod
//! endtextmacro