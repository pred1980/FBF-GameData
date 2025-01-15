native UnitAlive takes unit id returns boolean

library Wander uses Table optional TimerUtils
//==================================================================
// Version: 1.4.2
// Author: BPower
//==================================================================
// Libary Wander mimics the native Wander ability, while
// granting advanced controll over the unit movement.
//==================================================================
// Credits to:
//     Vexorian for TimerUtils    -    wc3c.net/showthread.php?t=101322
//     Bribe for Table            -    hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
//==================================================================
// API:
//
//    Methods:
//
//        static method operator [] takes unit whichUnit returns thistype
//
//        static method create takes unit whichUnit, real range, real cooldown returns thistype
//
//        method destroy takes nothing returns nothing
//
//        method exists takes nothing returns boolean
//
//        method pause takes nothing returns nothing
//
//        method resume takes nothing returns nothing
//
//    Fields:
//
//        readonly unit   source
//                 real   radius
//                 real   centerX
//                 real   centerY
//                 real   timeout ( The timer timeout )
//                 real   random  ( Optionally adds a random interval to the timer timeout )
//                 string order   ( Either "move" or "attack" are recommended )
//
//==================================================================
// User settings:

    globals
        private constant real   DEFAULT_TIMER_TIMEOUT = 1.0
        private constant string DEFAULT_ORDER_STRING  = "move"
    endglobals
   
//==================================================================
// Wander code. Make changes carefully.
//==================================================================
   
    globals
        private Table table
    endglobals
   
    private module Init
        private static method onInit takes nothing returns nothing
            call thistype.init()
        endmethod
    endmodule

    private function Random takes nothing returns real
        return GetRandomReal(0., 1.)
    endfunction
   
    struct Wander// extends array
        // implement Alloc
        //
        // Struct members:
        readonly unit   source
                 real   radius
                 real   centerX
                 real   centerY
                 real   timeout
                 real   random
                 string order
                 
        private  timer  tmr
       
        method operator exists takes nothing returns boolean
            return tmr != null
        endmethod
       
        static method operator [] takes unit whichUnit returns thistype
            return table[GetHandleId(whichUnit)]
        endmethod
       
        method pause takes nothing returns nothing
            call PauseTimer(tmr)
        endmethod
       
        method resume takes nothing returns nothing
            call ResumeTimer(tmr)
        endmethod
           
        method destroy takes nothing returns nothing
            if not exists then
                return
            endif
           
            call deallocate()
            call table.remove(GetHandleId(source))
            static if LIBRARY_TimerUtils then
                call ReleaseTimer(tmr)
            else
                call table.remove(GetHandleId(tmr))
                call DestroyTimer(tmr)
            endif
           
            set source = null
            set tmr    = null
        endmethod
       
        method issueWander takes nothing returns boolean
            local real t = Random()*2*bj_PI
            local real r = Random() + Random()
            if r > 1. then
                set r = (2 - r)*radius
            else
                set r = r*radius
            endif
           
            return IssuePointOrder(source, order, centerX + r*Cos(t), centerY + r*Sin(t))
        endmethod
       
        private static method onPeriodic takes nothing returns nothing
            static if LIBRARY_TimerUtils then
                local thistype this = GetTimerData(GetExpiredTimer())
            else
                local thistype this = table[GetHandleId(GetExpiredTimer())]
            endif
               
            if UnitAlive(source) then
                   // There are a few order ids, which eventually mess with the following unit order comparison.
                   // For example order id 851974. An endless going, undocumented order serving no obvious purpose.
                if GetUnitCurrentOrder(source) == 0 and issueWander() then
                    call TimerStart(tmr, timeout + random*Random(), true, function thistype.onPeriodic)
                else
                    // Update in short intervals until a wander order is issued.
                    call TimerStart(tmr, DEFAULT_TIMER_TIMEOUT, true, function thistype.onPeriodic)
                endif
            else
                call destroy()
            endif
        endmethod
   
        static method create takes unit whichUnit, real range, real cooldown returns thistype
            local thistype this = thistype[whichUnit]
           
            if not exists then
                set this   = thistype.allocate()
                set source = whichUnit
                set order  = DEFAULT_ORDER_STRING
                set table[GetHandleId(whichUnit)] = this
               
                static if not LIBRARY_TimerUtils then
                    set tmr = CreateTimer()
                    set table[GetHandleId(tmr)] = this
                else
                    set tmr = NewTimerEx(this)
                endif
            endif
           
            set radius  = range
            set random  = 0.
            set centerX = GetUnitX(whichUnit)
            set centerY = GetUnitY(whichUnit)
            set timeout = RMaxBJ(0., cooldown)
           
            call TimerStart(tmr, timeout, true, function thistype.onPeriodic)
           
            return this
        endmethod

        private static method init takes nothing returns nothing
            set table = Table.create()
        endmethod
        implement Init
       
    endstruct
endlibrary