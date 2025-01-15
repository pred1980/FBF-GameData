library AutoFly requires AutoIndex, xebasic, Table

    private function UnitFlyFilter takes unit u returns boolean
        return GetUnitTypeId(u) != XE_DUMMY_UNITID
    endfunction

    private struct AutoFly extends array
        
        static HandleTable t = 0
        
        static method enableFly takes unit u returns nothing
            if UnitFlyFilter(u) and t[u] == 0 then
                call UnitAddAbility(u, XE_HEIGHT_ENABLER)
                call UnitRemoveAbility(u, XE_HEIGHT_ENABLER)
                set t[u] = 1
            endif
        endmethod
            


        static method onInit takes nothing returns nothing
            call OnUnitIndexed(thistype.enableFly)
            set t = HandleTable.create()
        endmethod

    endstruct

endlibrary