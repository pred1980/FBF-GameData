library AbilityPreload
//===========================================================================
// Information:
//==============
//
//      Preloading removes the noticeable delay the first time an ability
//  is loaded in a game. If an ability was not already on a pre-placed unit
//  or a unit that was created during initialization, preloading is needed
//  to prevent a delay.
//
//===========================================================================
// AbilityPreload API:
//=====================
//
//  AbilityPreload(abilityid) :
//        Call this before any time has elapsed to preload a specific
//     ability. If debug mode is enabled, you will see an error message
//     if you call this after initialization, or if you try to preload
//     an ability that does not exist. Will inline to a UnitAddAbility
//     call if debug mode is disabled.
//
//  AbilityRangePreload(start, end) :
//        Same as AbilityPreload, but preloads a range of abilities.
//      It will iterates between the two rawcode values and preload
//      every ability along the way. It will not show an error message
//      for non-existent abilities.
// 
//===========================================================================
// Configuration:
//================

    globals
        private constant integer PreloadUnitRawcode = 'zsmc'
        //This is the rawcode for "Sammy!". It is never used and has no model,
        //which makes an ideal preloading unit. Change it if you want to.
    endglobals

    //===========================================================================

    globals
        private unit PreloadUnit
    endglobals

    function AbilityPreload takes integer abilityid returns nothing
        static if DEBUG_MODE then
            if GetUnitTypeId(PreloadUnit) == 0 then
                call BJDebugMsg("AbilityPreload error: Can't preload an ability after initialization")
                return
            endif
        endif
        call UnitAddAbility(PreloadUnit, abilityid)
        static if DEBUG_MODE then
            if GetUnitAbilityLevel(PreloadUnit, abilityid) == 0 then
                call BJDebugMsg("AbilityPreload error: Attempted to preload a non-existent ability")
            endif
        endif
    endfunction

    function AbilityRangePreload takes integer start, integer end returns nothing
        local integer i = 1
            static if DEBUG_MODE then
                if GetUnitTypeId(PreloadUnit) == 0 then
                    call BJDebugMsg("AbilityPreload error: Can't preload an ability after initialization")
                    return
                endif
            endif
            if start > end then
                set i = -1
            endif
            loop
                exitwhen start > end
                call UnitAddAbility(PreloadUnit, start)
                set start = start + i
            endloop
    endfunction

    //===========================================================================

    private struct Init extends array
        private static method onInit takes nothing returns nothing
            set PreloadUnit = CreateUnit(Player(15), PreloadUnitRawcode, 0., 0., 0.)
            call UnitApplyTimedLife(PreloadUnit, 0, .001)
            call ShowUnit(PreloadUnit, false)
            call UnitAddAbility(PreloadUnit, 'Aloc')
        endmethod
    endstruct

endlibrary