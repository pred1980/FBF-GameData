//*********************Disable/Enable attack by Elphis v0.0.3*********************
//*********************Allow you disable/enable attack staus of unit*********************
//*********************API:
//                          - function DisableAttack takes unit u returns nothing
//                          **Allow you disable attack of unit**
//                          - function EnableAttack takes unit u returns nothing
//                          **Enable attack of unit**
//                          - function DisableAttackAOE takes unit u,real radius returns nothing
//                          **Allow you disable attack of unit in wide Area**
//                          - function EnableAttackAOE takes unit u returns nothing
//                          **Enable attack of unit in wide Area**
//********************************************************************************************************
//********************************************************************************************************
//*************************************************************************************
//          - Installation:
//                                - Import/copy the required libraries and Attack Staus code to your map
//                                - Copy DummyUnit of this map into your map
//                                - Import/copy the custom ability to your map and change the ORDER, DISABLE_ABI_ID, BUFF_ID if needed
//                                - You may view the raw ID of the objects by pressing CTRL+D in the object editor
//                                - You may play with the configurables below
//
//          - Special Thank to TriggerHappy, who help me to improve this code.
//*************************************************************************************
//
library DisableAttack initializer Init
    
    globals
        private     constant        integer     ORDER          = 0xD0270
        private     constant        integer     DISABLE_ABI_ID = 'DISA' // Rawcode of Ability Disable, changes if needed
        private     constant        integer     BUFF_ID        = 'BDIS' // Rawcode of Buff Disable, changes if needed
        private     constant        integer     DUMMY_ID       = 'e00D' //Dummy rawcode
        
        /*=Non - Configurables=*/
        private unit Dummy
    endglobals

    function UnitDisableAttack takes unit u returns boolean
        if GetUnitAbilityLevel(u,BUFF_ID) > 0x0 then
            return false
        endif
        call SetUnitX(Dummy,GetUnitX(u))
        call SetUnitY(Dummy,GetUnitY(u))
        call IssueTargetOrderById(Dummy,ORDER,u)
        return true
    endfunction

    function UnitEnableAttack takes unit u returns boolean
        return UnitRemoveAbility(u,BUFF_ID)
    endfunction
    
    private function GroupDisable takes nothing returns nothing
        call UnitDisableAttack(GetEnumUnit())
    endfunction
    
    private function GroupEnable takes nothing returns nothing
        call UnitEnableAttack(GetEnumUnit())
    endfunction
    
    function GroupDisableAttack takes group g returns nothing
        call ForGroup(g, function GroupDisable)
    endfunction
    
    function GroupEnableAttack takes group g returns nothing
        call ForGroup(g, function GroupEnable)
    endfunction
    
    function Init takes nothing returns nothing
        set Dummy = CreateUnit(Player(15),DUMMY_ID,0.,0.,0.)
    endfunction

endlibrary