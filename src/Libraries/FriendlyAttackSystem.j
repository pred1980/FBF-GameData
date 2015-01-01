scope FriendlyAttackSystem initializer init

    private function Actions takes nothing returns nothing
        call IssueImmediateOrder(GetAttacker(), "stop")
    endfunction
    
    private function Conditions takes nothing returns boolean
        return IsUnitAlly(GetAttacker(), GetOwningPlayer(GetTriggerUnit()))
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ATTACKED)
        call TriggerAddCondition(t, Condition( function Conditions ))
        call TriggerAddAction(t, function Actions )
    
        set t = null
    endfunction

endscope

