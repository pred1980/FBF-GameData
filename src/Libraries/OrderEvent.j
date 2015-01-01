//============================================================================
// OrderEvent by Bribe, special thanks to Nestharus and Azlier, version 2.1.0.0
//
// API
// ---
//     RegisterOrderEvent(integer orderId, code eventFunc)
//     RegisterAnyOrderEvent(code eventFunc) //Runs for point/target/instant for any order
//
// Requires
// --------
//     RegisterPlayerUnitEvent: hiveworkshop.com/forums/showthread.php?t=203338
//
library OrderEvent requires RegisterPlayerUnitEvent
 
    globals
        private trigger array t
    endglobals
     
    //============================================================================
    function RegisterOrderEvent takes integer orderId, code c returns nothing
        set orderId = orderId - 851968
        if t[orderId] == null then
            set t[orderId] = CreateTrigger()
        endif
        call TriggerAddCondition(t[orderId], Filter(c))
    endfunction
     
    //============================================================================
    function RegisterAnyOrderEvent takes code c returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, c)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, c)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, c)
    endfunction
     
    //============================================================================
    private function OnOrder takes nothing returns nothing
        call TriggerEvaluate(t[GetIssuedOrderId() - 851968])
    endfunction
     
    //============================================================================
    private module M
        private static method onInit takes nothing returns nothing
            call RegisterAnyOrderEvent(function OnOrder)
        endmethod
    endmodule
    private struct S extends array
        implement M
    endstruct
 
endlibrary