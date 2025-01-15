library UnitFadeSystem initializer Init requires ARGB, Table

//*****************************************************************
//*  UNIT FADE SYSTEM
//*
//*  written by: Anitarf
//*  requires: -ARGB
//*            -Table
//*
//*  A system that makes gradual modification of unit's vertex
//*  colouring, also called fading, an easy affair. The functions
//*  you can use are:
//*
//*  FadeUnitStart - Fades a unit from the start colour to the end
//*                  colour over a given duration.
//*  FadeUnitStop  - If a unit is already fading, then it stops
//*                  and the function returns it's current color;
//*                  else, the function returns 0.
//*  IsUnitFading  - Returns true if the unit is already fading.
//*****************************************************************

    private keyword fadingUnit

    globals
        //this value determines how much time elapses between unit colour updates
        private constant real FADE_PERIOD = 0.04


// END OF CALIBRATION SECTION    
// ================================================================

        private fadingUnit array fuList
        private integer fuListMax = 0
        private HandleTable cache //initialized in Init
    endglobals

    private struct fadingUnit
        integer list
        unit u
        ARGB start = 0
        ARGB end = 0
        real time = 0.0
        real endtime = FADE_PERIOD

        static method check takes unit u returns boolean
            return cache.exists(u)
        endmethod
        static method get takes unit u returns fadingUnit
            local fadingUnit fu = fadingUnit(cache[u])
            if fu==0 then
                set fu = fadingUnit.create()
                set cache[u]=integer(fu)
                set fu.u = u
                set fuList[fuListMax]=fu
                set fu.list = fuListMax
                set fuListMax=fuListMax+1
            endif
            return fu
        endmethod
        method onDestroy takes nothing returns nothing
            call cache.flush(.u)
            set this.u = null
            set fuListMax=fuListMax-1
            set fuList[this.list]=fuList[fuListMax]
            set fuList[this.list].list=this.list
        endmethod
    endstruct

    private function FadeUnits takes nothing returns nothing
        local integer i = 0
        local fadingUnit fu
        loop
            exitwhen i>=fuListMax
            set fu=fuList[i]
            set fu.time=fu.time+FADE_PERIOD
            if fu.time>=fu.endtime then
                set fu.time=fu.endtime
                call fu.destroy()
            else
                set i = i+1
            endif
            call ARGB.mix(fu.start, fu.end, fu.time/fu.endtime).recolorUnit(fu.u)
        endloop
    endfunction

    private function Init takes nothing returns nothing
        local timer t = CreateTimer()
        call TimerStart(t, FADE_PERIOD, true, function FadeUnits)
        set cache = HandleTable.create()
    endfunction

// ================================================================

    function FadeUnitStart takes unit u, ARGB start, ARGB end, real duration returns nothing
        local fadingUnit fu = fadingUnit.get(u)
        if duration < FADE_PERIOD then
            set duration = FADE_PERIOD
        endif
        set fu.start = start
        set fu.end = end
        set fu.time = 0.0
        set fu.endtime = duration
    endfunction

    function FadeUnitStop takes unit u returns ARGB
        local fadingUnit fu = fadingUnit.get(u)
        call fu.destroy()
        return ARGB.mix(fu.start, fu.end, fu.time/fu.endtime)
    endfunction

    function IsUnitFading takes unit u returns boolean
        return fadingUnit.check(u)
    endfunction

endlibrary