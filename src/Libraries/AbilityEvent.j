//############################## ~AbilityEvent~ ##################################//
//##
//## Version:       1.0
//## System:        Axarion
//## IndexerUtils:  Axarion
//## AutoIndex:     grim001
//## AIDS:          Jesus4Lyf
//## UnitIndexer:   Nestharus
//##
//############################### DESCRIPTION ###################################//
//##
//## This system allows to track when a unit acquires an ability.
//## 
//############################### HOW DOES IT WORK ##############################//
//## 
//## To use this system create a struct and implement the AbilityEvent module.
//## In the structs onInit  method you have to define the ability, for which the
//## event is executed:
//##    
//##        set ability   = YourId 
//##
//## If you want all abilities to register use:
//##
//##        set ability   = ABILITIES_ALL
//##
//## Another way is to create a static constant variable called ability.
//## 
//################################# METHODS #####################################//
//##   
//##    You can implement these functions into your struct. They are 
//##    all optional. 
//##
//##    - happens when a unit enters which has the ability.
//##        static method onIndexWithAbility takes unit u returns nothing
//## 
//##    - happens when a unit leaves the map with the ability    
//##        static method onDeindexWithAbility takes unit u returns nothing
//##
//##    - happens when the ability is added to the unit
//##        static method onAddAbility takes unit u, integer id returns nothing
//##    
//##    - happens when the ability is removed from the unit
//##        static method onRemoveAbility takes unit u, integer id returns nothing
//##
//##    - happens when the ability is skilled by a hero
//##        static method onSkillAbility takes unit u, integer id returns nothing
//##
//################################################################################//

library AbilityEvent initializer onInit requires IndexerUtils

globals
    // decide yourself if you want to use hooks or UnitAddAbilityEx and 
    // UnitRemoveAbilityEx instead of the calling UnitAddAbility and 
    // UnitRemoveAbility. 
    private constant boolean USE_HOOKS  = true 
    
//###################### DON'T TOUCH ANYTHING BELOW! ##############################//    
    
    
    private trigger ADD                 = CreateTrigger()
    private trigger REM                 = CreateTrigger()
    private trigger SKILL               = CreateTrigger()
    private unit    currUnit            = null
    private integer currId              = 0
    public  key     ABILITIES_ALL
endglobals

module AbilityEvent
    static if thistype.onIndexWithAbility.exists then
        static method onUnitIndex takes unit u returns nothing
            if GetUnitAbilityLevel(u, .ability) != 0 or ability == ABILITIES_ALL then
                call onIndexWithAbility(u)
            endif
        endmethod
    endif
    
    static if thistype.onDeindexWithAbility.exists then
        static method onUnitDeindex takes unit u returns nothing
            if GetUnitAbilityLevel(u, ability) != 0 or ability == ABILITIES_ALL then
                call onDeindexWithAbility(u)
            endif
        endmethod
    endif
    
    static if thistype.onSkillAbility.exists then
        private static method REGISTER_SKILL takes nothing returns boolean
            if GetLearnedSkill() == ability or ability == ABILITIES_ALL then
                call onSkillAbility(GetTriggerUnit(), GetLearnedSkill())
            endif
            return false
        endmethod
    endif
    
    static if thistype.onAddAbility.exists then
        private static method REGISTER_ADD takes nothing returns boolean
            if currId == ability or ability == ABILITIES_ALL then
                call onAddAbility(currUnit, currId)
            endif
            return false
        endmethod
    endif
    
    static if thistype.onRemoveAbility.exists then
        private static method REGISTER_REM takes nothing returns boolean
            if currId == ability or ability == ABILITIES_ALL then
                call onRemoveAbility(currUnit, currId)
            endif
            return false
        endmethod 
    endif
    
    static if thistype.onAddAbility.exists then
        static if thistype.onRemoveAbility.exists then
            static if thistype.onSkillAbility.exists then
                private static method onInit takes nothing returns nothing
                    call TriggerAddCondition(ADD,   function thistype.REGISTER_ADD)
                    call TriggerAddCondition(REM,   function thistype.REGISTER_REM)
                    call TriggerAddCondition(SKILL, function thistype.REGISTER_SKILL)
                    call TriggerRegisterAnyUnitEventBJ(SKILL, EVENT_PLAYER_HERO_SKILL)
                endmethod
            else
                private static method onInit takes nothing returns nothing
                    call TriggerAddCondition(ADD,   function thistype.REGISTER_ADD)
                    call TriggerAddCondition(REM,   function thistype.REGISTER_REM)
                endmethod
            endif
        elseif static if thistype.onSkillAbility.exists then
            private static method onInit takes nothing returns nothing
                call TriggerAddCondition(ADD,   function thistype.REGISTER_ADD)
                call TriggerAddCondition(SKILL, function thistype.REGISTER_SKILL)
                call TriggerRegisterAnyUnitEventBJ(SKILL, EVENT_PLAYER_HERO_SKILL)
            endmethod
        else
            private static method onInit takes nothing returns nothing
                call TriggerAddCondition(ADD,   function thistype.REGISTER_ADD)
            endmethod
        endif
    elseif thistype.onRemoveAbility.exists then
        static if thistype.onSkillAbility.exists then
            private static method onInit takes nothing returns nothing
                call TriggerAddCondition(REM,   function thistype.REGISTER_REM)
                call TriggerAddCondition(SKILL, function thistype.REGISTER_SKILL)
                call TriggerRegisterAnyUnitEventBJ(SKILL, EVENT_PLAYER_HERO_SKILL)
            endmethod
        else
            private static method onInit takes nothing returns nothing
                call TriggerAddCondition(REM,   function thistype.REGISTER_REM)
            endmethod
        endif
    elseif thistype.onSkillAbility.exists then
        private static method onInit takes nothing returns nothing
            call TriggerAddCondition(REM,   function thistype.REGISTER_REM)
            call TriggerAddCondition(SKILL, function thistype.REGISTER_SKILL)
            call TriggerRegisterAnyUnitEventBJ(SKILL, EVENT_PLAYER_HERO_SKILL)
        endmethod
    endif
    
    implement IndexerUtils
endmodule

static if USE_HOOKS then
    private function hook_UnitAddAbility takes unit u, integer id returns nothing
        set currUnit = u
        set currId   = id
        call TriggerEvaluate(ADD)
        set currUnit = null
        set currId   = 0
    endfunction

    private function hook_UnitRemoveAbility takes unit u, integer id returns nothing
        set currUnit = u
        set currId   = id
        call TriggerEvaluate(REM)
        set currUnit = null
        set currId   = 0
    endfunction

    hook UnitAddAbility hook_UnitAddAbility
    hook UnitRemoveAbility hook_UnitRemoveAbility
else
    function UnitAddAbilityEx takes unit u, integer id returns nothing
        call UnitAddAbility(u, id)
        set currUnit = u
        set currId   = id
        call TriggerEvaluate(ADD)
        set currUnit = null
        set currId   = 0
    endfunction
    
    function UnitRemoveAbilityEx takes unit u, integer id returns nothing
        call UnitRemoveAbility(u, id)
        set currUnit = u
        set currId   = id
        call TriggerEvaluate(REM)
        set currUnit = null
        set currId   = 0
    endfunction
endif

endlibrary