library Jump initializer Init

// ****************************************************************************
// **                                                                        **
// ** Jump v.20                                                              **
// **                                                                        **
// ** Just a function I made for efficient jumping                           **
// **                                                                        **
// ****************************************************************************

    //=======//
    //Globals//
    //=======//

    globals
        private integer DUMMY_ID = 'e00J'
        private integer array Ar
        
        private constant real Interval = 0.035
        private boolexpr Bool
        private location Loc1 = Location(0, 0)
        private location Loc2 = Location(0, 0)
        
        private unit Dummy
        private timer Tim = CreateTimer()
        private integer Total = 0
        
        private real MAX_X
        private real MAX_Y
        private real MIN_X
        private real MIN_Y
    endglobals

    //===========================================================================

    //========================================//
    //Credits to Shadow1500 for this function!//
    //========================================//

    private function JumpParabola takes real dist, real maxdist, real curve returns real
        local real t = (dist * 2) / maxdist - 1
        return (- t * t + 1) * (maxdist / curve)
    endfunction

    //=======================================//
    //Credits to PitzerMike for this function//
    //=======================================//

    private function TreeFilter takes nothing returns boolean
        local destructable d = GetFilterDestructable()
        local boolean i = IsDestructableInvulnerable(d)
        local boolean result = false
        call SetUnitPosition(Dummy, GetWidgetX(d), GetWidgetY(d))
        if i then
            call SetDestructableInvulnerable(d, false)
        endif
        set result = IssueTargetOrder(Dummy, "harvest", d)
        if i then
          call SetDestructableInvulnerable(d, true)
        endif
        //call IssueImmediateOrder(Dummy, "stop")
        set d = null
        return result
    endfunction

    //===========================================================================

    private function TreeKill takes nothing returns nothing
        call KillDestructable(GetEnumDestructable())
    endfunction

    public struct Data
        unit u
        integer q
        real md
        real d
        real c
        
        real sin
        real cos
        integer i = 1
        
        real p
        real r
        string s
        
        static method create takes unit u, integer q, real x2, real y2, real c, real r, string s1, string s2, string anim returns Data
            local Data dat = Data.allocate()
            
            local real x1 = GetUnitX(u)
            local real y1 = GetUnitY(u)
            local real dx = x1 - x2
            local real dy = y1 - y2
            local real a = Atan2(y2 - y1, x2 - x1)
            local location l1 = Location(x1, y1)
            local location l2 = Location(x2, y2)
            
            call MoveLocation(Loc1, x1, y1)
            
            set dat.u = u
            set dat.q = q
            set dat.md = SquareRoot(dx * dx + dy * dy)
            set dat.d = dat.md / q
            set dat.c = c
            set dat.sin = Sin(a)
            set dat.cos = Cos(a)
            set dat.p = (GetLocationZ(l2) - GetLocationZ(l1)) / q
            set dat.r = r
            set dat.s = s2
            
            if s1 != "" and s1 != null then
                call DestroyEffect(AddSpecialEffect(s1, x1, y1))
            endif
            
            call UnitAddAbility(u, 'Amrf')
            call UnitRemoveAbility(u, 'Amrf')
            call PauseUnit(u, true)
            call SetUnitAnimation(u, anim)
            
            call RemoveLocation(l1)
            call RemoveLocation(l2)
            
            set l1 = null
            set l2 = null
            
            return dat
        endmethod

        method onDestroy takes nothing returns nothing
            local real x = GetUnitX(.u)
            local real y = GetUnitY(.u)
            local rect r
            
            if .r != 0 then
                set r = Rect(x - .r, y - .r, x + .r, y + .r)
                call EnumDestructablesInRect(r, Bool, function TreeKill)
                call RemoveRect(r)

                set r = null
            endif
            
            if .s != "" and .s != null then
                call DestroyEffect(AddSpecialEffect(.s, x, y))
            endif
            
            call PauseUnit(.u, false)
            call IssueImmediateOrder(.u, "stop")
            call SetUnitAnimation(.u, "stand")
            call SetUnitFlyHeight(.u, 0, 0)
        endmethod
    endstruct

    private function Execute takes nothing returns nothing
        local Data dat
        local integer i = 0
        local real x
        local real y
        local location l
        local real h
        local rect r
        
        loop
            exitwhen i >= Total
            set dat = Ar[i]
            set x = GetUnitX(dat.u) + (dat.d) * dat.cos
            set y = GetUnitY(dat.u) + (dat.d) * dat.sin
            
            call MoveLocation(Loc2, x, y)
            
            set h = JumpParabola(dat.d * dat.i, dat.md, dat.c) - (GetLocationZ(Loc2) - GetLocationZ(Loc1)) + dat.p * dat.i
            
            if x < MAX_X and y < MAX_Y and x > MIN_X and y > MIN_Y then
                call SetUnitX(dat.u, x)
                call SetUnitY(dat.u, y)
            endif
            
            call SetUnitFlyHeight(dat.u, h, 0)
            
            if dat.i >= dat.q then
                call dat.destroy()
                set Total = Total - 1
                set Ar[i] = Ar[Total]
            else
                set dat.i = dat.i + 1
            endif
            
            set i = i + 1
        endloop
        
        if Total == 0 then
            call PauseTimer(Tim)
        endif
        
        set l = null
    endfunction

    function Jump takes unit whichUnit, real dur, real destX, real destY, real curve, real radius, string sfx1, string sfx2, string anim returns nothing
        local Data dat = Data.create(whichUnit, R2I(dur / Interval), destX, destY, curve, radius, sfx1, sfx2, anim)
        
        if Total == 0 then
            call TimerStart(Tim, Interval, true, function Execute)
        endif
        
        set Ar[Total] = dat
        set Total = Total + 1
    endfunction

    //==================================================================================

    private function Init takes nothing returns nothing
        set Bool = Filter(function TreeFilter)
        
        set Dummy = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), DUMMY_ID, 0, 0, 0)
        
        call UnitAddAbility(Dummy, 'Amrf')
        call UnitRemoveAbility(Dummy, 'Amrf')
        call UnitAddAbility(Dummy, 'Aloc')
        call SetUnitAnimationByIndex(Dummy, 90)
        
        call UnitAddAbility(Dummy, 'Ahrl')
        
        set MAX_X = GetRectMaxX(bj_mapInitialPlayableArea) - 64
        set MAX_Y = GetRectMaxY(bj_mapInitialPlayableArea) - 64
        set MIN_X = GetRectMinX(bj_mapInitialPlayableArea) + 64
        set MIN_Y = GetRectMinY(bj_mapInitialPlayableArea) + 64
    endfunction

endlibrary