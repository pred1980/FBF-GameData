/*
    LocalEffects
   
    Small library by Anachron to create
    effects which are displayed locally
    for players and/or forces only.
*/
library LocalEffects

    globals
        private string  eff = null
        private force   for = null
    endglobals

    function addEffectToUnitForPlayer takes player p, unit u, string e, string a returns effect
        set eff = null
       
        if GetLocalPlayer() == p then
             set eff = e
        endif
       
        return AddSpecialEffectTarget(eff, u, a)    
    endfunction
   
    function addEffectOnPositionForPlayer takes player p, string e, real x, real y returns effect
        set eff = null
       
        if GetLocalPlayer() == p then
             set eff = e
        endif
       
        return AddSpecialEffect(eff, x, y)    
    endfunction
   
    function addEffectToUnitForForce takes force f, unit u, string e, string a returns nothing
        local integer i = 0
       
        loop
            exitwhen i >= 15
           
            if IsPlayerInForce(Player(i), f) then
                call addEffectToUnitForPlayer(Player(i), u, e, a)
            endif
           
            set i = i +1
        endloop
    endfunction
   
    function addEffectOnPositionForForce takes force f, string e, real x, real y returns nothing
        local integer i = 0
       
        loop
            exitwhen i >= 15
           
            if IsPlayerInForce(Player(i), f) then
                call addEffectOnPositionForPlayer(Player(i), e, x, y)
            endif
           
            set i = i +1
        endloop
    endfunction

endlibrary
