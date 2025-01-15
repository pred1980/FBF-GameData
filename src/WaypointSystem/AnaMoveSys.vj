//:******************************************************************************
//:  Anachrons Move System 
//:    by dhk_undead_lord / aka Anachron
//:    version 1.05
//:
//:
//:  ABOUT:
//:  This system has been thought to be able to easily
//:  create and manage spawn ways of troops.
//:  Top priority is the automatic movement control,
//:  such as high customizeability for users.
//:
//:  WHAT YOU NEED:
//:  You need JassNewGenPack to use this vJASS system.
//:  (Download it here: http://www.wc3c.net/showthread.php?goto=newpost&t=90999)
//:  
//:  STEPS TO IMPORT:
//:  I.) Copy this code.
//:  II.) Paste it into the head of your map.
//:  (Therefor go to the Trigger Editor, select the mapname and paste
//:   into the area on the right)
//:  III.) Save your map! 
//:  (With File - Save Map (S) or control + S. DO NOT SAVE WITH SAVE AS!)
//:  IV.) You got it! You imported the system.
//:  
//:  To make sure this system works, you should try a few tests!
//:  
//:  METHODS
//:  
//:  >WayPoint.create takes real baseX, real baseY, real targX, real targY, real targRadius
//:  Constructor of WayPoints.
//:  
//:  >WayPoint.moveUnit takes unit u
//:  Move any unit to the target of this waypoint!
//:  
//:  >Way.create takes boolean scCon, boolean stCon, boolean hdCon returns Way
//:  Create a new Way, say whether orders should recast attack/move or not.
//:  
//:  >Way.addWayPoint takes WayPoint wp returns nothing
//:  Add a waypoint to the system! Horray, another patrol point.
//:
//:  >Way.addUnit takes unit u returns nothing
//:  Adds an unit to the way. Automaticly moves to the first waypoint.
//:
//:  >Way.removeUnit takes unit u returns nothing
//:  Remove a unit from the way system.
//:
//:  >Way.moveUnit takes unit u, integer curPos returns nothing
//:  Move the unit u to the waypoint curPos's position
//:
//:  >Way.moveNext takes unit u, integer curPos returns nothing
//:  Sets the new wayPoint for the unit u
//:
//:  >Way.getNearestWP takes unit u returns integer
//:  A very nice function to find the nearest waypoint of an unit.
//:  Is perfect for Revive spells were you need to reregister,
//:  because with this function its pretty easy to get the correct waypoint.
//:  
//:  Thanks for downloading and using my system!
//:  
//:  Please don't forget to give credits to me (dhk_undead_lord / Aka Anachron)
//:
//:******************************************************************************  
library AnaMoveSys initializer init
    //==========================================================================
    // %CUSTOMIZATION AREA%: Feel free to change anything to what you need!
    //==========================================================================
    globals
        //: %Default Values%
        //:     Basicly the radius the unit has to be to
        //:     get ordered to the next waypoint.
        private constant real TARGET_TOLERANCE          = 192.
        //:     Sets whether the unit should move again
        //:     after it casted a spell.
        private constant boolean SPELLCAST_CONTINUE      = true
        //:     Sets whether the unit should move again
        //:     after it used stop command.
        private constant boolean STOP_CONTINUE          = true
        //:     Sets whether the unit should move again
        //:     after it used the hold position command.
        private constant boolean HOLDPOSITION_CONTINUE  = false
        //:     Sets whether death units will automaticly
        //:     removed by the system.
        //:     WARNING: THIS IS HIGLY RECOMMENDED!
        //:     TO ADD UNITS (LIKE REVIVE) USE THE addUnit()
        //:     METHOD!
        private constant boolean DEATH_REMOVES = true
        
        //: %Hashtable Storage%
        //:     Sets which key is for the unit ID
        private constant integer KEY_UNIT = 0
        //:     Sets which key is for the way ID
        private constant integer KEY_WAY = 1
        //:     Sets which key is for the current
        //:     waypoint ID.
        private constant integer KEY_CURPOS = 2
        
        //: %Order Ids%
        private constant string ORDER_STOP = "stop"
        private constant string ORDER_HOLDPOSITION = "position"
        private constant string ORDER_ATTACKMOVE = "attack"
        private constant string ORDER_MOVE = "move"
        
        //: %Timers%
        private constant timer MOVE_TIMER = CreateTimer()
        private constant real MOVE_INT = 0.20
        
        //: %Saving%
        private hashtable UNIT_DATA = InitHashtable()
        private group MOVING_UNITS = CreateGroup()
        
        //Show Debug Messages
        private constant boolean SHOW_DEBUG_MSG = false
    endglobals
    
    //: %Conditions of reordering the units
    //: Here you can define the conditions,
    //: such as owner controlling and other
    //: useful filters.
    public function globalCheck takes nothing returns boolean
        return LoadWidgetHandle(UNIT_DATA, GetHandleId(GetTriggerUnit()), KEY_UNIT) != null
    endfunction
    
    public function checkSpellcast takes nothing returns boolean
        return globalCheck()
    endfunction
    
    public function checkStopOrder takes nothing returns boolean
        return globalCheck() and GetIssuedOrderId() == OrderId(ORDER_STOP)
    endfunction
    
    public function checkHoldOrder takes nothing returns boolean
        return globalCheck() and GetIssuedOrderId() == OrderId(ORDER_HOLDPOSITION)
    endfunction
    
    public function checkMoveOrder takes nothing returns boolean
        return globalCheck() and GetIssuedOrderId() == OrderId(ORDER_MOVE)
    endfunction
    
    //==========================================================================
    //: %DO NOT CHANGE THIS UNLIKE YOU KNOW WHAT YOU ARE DOING%
    //==========================================================================
    
    public function reOrderUnit takes nothing returns nothing
        local integer unitID = 0
        local integer wayID = 0
        local integer curPos = 0
        
        if IsUnitInGroup(GetTriggerUnit(), MOVING_UNITS) then
            set unitID = GetHandleId(GetTriggerUnit())
            set wayID = LoadInteger(UNIT_DATA, unitID, KEY_WAY)
            set curPos = LoadInteger(UNIT_DATA, unitID, KEY_CURPOS)
            static if SHOW_DEBUG_MSG then
                debug call BJDebugMsg("!AoSMoveSys] |NOTICE| <Way[" + I2S(wayID) + "]> <Reorder unit " + I2S(unitID) + ">")
            endif
            call Way.instances[wayID].moveUnit(GetTriggerUnit(), curPos)
        endif
    endfunction
    
    public function checkUnregister takes nothing returns boolean
        return GetOwningPlayer(GetTriggerUnit()) == Player(0)
    endfunction
    
    public function unregisterUnit takes nothing returns nothing
        local integer wayID = LoadInteger(UNIT_DATA, GetHandleId(GetTriggerUnit()), KEY_WAY)
        
        call Way.instances[wayID].removeUnit(GetTriggerUnit())   
    endfunction

    struct WayPoint
        real baseX = 0.
        real baseY = 0.
        
        real targX = 0.
        real targY = 0.
        real targRadius = 0.
        
        integer ID = 0
        
        //: =================================
        //: CREATE NEW INSTANCES
        //: =================================
        public static method create takes real bX, real bY, real tX, real tY, real tR returns WayPoint
            local thistype wp = thistype.allocate()
                set wp.baseX = bX
                set wp.baseY = bY
                set wp.targX = tX
                set wp.targY = tY
                set wp.targRadius = tR
                
            return wp
        endmethod
        //: =================================
        
        //: =================================
        //: Move the unit to the target loc
        //: =================================
        public method moveUnit takes unit u returns nothing
            call IssuePointOrder(u, ORDER_ATTACKMOVE, .targX, .targY)
        endmethod
        //: =================================   
    endstruct
    
    struct Way
        group units = CreateGroup()
        
        integer ID = 0
        static Way array instances[8191]
        static integer index = 0
        
        integer curwpID = 0
        WayPoint array wayPoints[128]
        
        //: Saves the triggers for the
        //: auto remove functions.
        //:     -> spellcast?
        static trigger scTrig = CreateTrigger()
        //:     -> stop?
        static trigger stTrig = CreateTrigger()
        //:     -> hold position?
        static trigger hpTrig = CreateTrigger()
        //:     -> move?
        static trigger moTrig = CreateTrigger()
        
        //: This unregisters unit which die
        static trigger deathTrig = CreateTrigger()
        
        //: =================================
        //: CREATE NEW INSTANCES
        //: =================================
        public static method create takes nothing returns thistype
            local thistype wy = thistype.allocate()
                call thistype.addWay(wy)
            return wy
        endmethod
        //: =================================
        
        //: =================================
        //: Add and remove ways to the system
        //: =================================
        private static method addWay takes thistype wy returns nothing
            set wy.ID = thistype.index
            set thistype.instances[thistype.index] = wy
            set thistype.index = thistype.index + 1
        endmethod
        
        private static method removeWay takes thistype wy returns nothing
            set thistype.instances[wy.ID] = thistype.instances[thistype.index]
            set thistype.index = thistype.index - 1
        endmethod
        //: =================================
        
        //: ====================================
        //: Add and remove Way Point to the way
        //: ====================================
        public method addWayPoint takes WayPoint wp returns nothing
            set wp.ID = .curwpID
            set .wayPoints[.curwpID] = wp
            set .curwpID = .curwpID + 1
        endmethod
        
        public method removeWayPoint takes WayPoint wp returns nothing
            set .wayPoints[wp.ID] = .wayPoints[.curwpID]
            set .curwpID = .curwpID - 1
        endmethod
        //: ====================================
        
        //: ====================================
        //: Add and remove units to the way
        //: ====================================
        public method addUnit takes unit u, integer curPos returns nothing
            if not(IsUnitInGroup(u, .units)) then
                call SaveWidgetHandle(UNIT_DATA, GetHandleId(u), KEY_UNIT, u)
                call SaveInteger(UNIT_DATA, GetHandleId(u), KEY_WAY, .ID)
                call SaveInteger(UNIT_DATA, GetHandleId(u), KEY_CURPOS, curPos)
                
                call GroupAddUnit(.units, u)
                call GroupAddUnit(MOVING_UNITS, u)
                
                call .moveUnit(u, curPos)
            else
                static if SHOW_DEBUG_MSG then
                    debug call BJDebugMsg("!AoSMoveSys] |ERROR| <Way[" + I2S(.ID) + "]> <addUnit: UNIT ALREADY REGISTERED!>")
                endif
            endif
        endmethod
        
        public method removeUnit takes unit u returns nothing
            call FlushChildHashtable(UNIT_DATA, GetHandleId(u))
            call GroupRemoveUnit(.units, u)
            call GroupRemoveUnit(MOVING_UNITS, u)
            static if SHOW_DEBUG_MSG then
                debug call BJDebugMsg("!AoSMoveSys] |NOTICE| <Way[" + I2S(.ID) + "]> <removeUnit: UNIT HAS BEEN REMOVED!>")
            endif
        endmethod
        
        //Ist die zu checkende Einheit eine, die gerade einen WayPoint abläuft?
        public method checkUnit takes unit u returns boolean
            return IsUnitInGroup(u, .units)
        endmethod
        //: ====================================
        
        //: ====================================
        //: Move an unit to the target 
        //: ====================================
        public method moveUnit takes unit u, integer curPos returns nothing
            call .wayPoints[curPos].moveUnit(u)     
        endmethod
        
        public method moveNext takes unit u, integer curPos returns nothing
            set curPos = curPos + 1
            if curPos < .curwpID then
                //: %Save data and move unit%
                call SaveInteger(UNIT_DATA, GetHandleId(u), KEY_CURPOS, curPos)
                call .moveUnit(u, curPos)
            else
                call .removeUnit(u)
            endif
        endmethod
        //: ====================================
        
        //: ====================================
        //: Additional Methods for users
        //: ====================================
        public method getNearestWP takes unit u returns integer
            local integer foundWP = -1
            local WayPoint wp = 0
            local integer i = 0
            local real tmpDist = 0.
            //: !Do NOT change this
            local real dist = 100000000.
            
            loop
                exitwhen i >= .curwpID
                
                // %Compare the distances%
                set tmpDist = SquareRoot(GetUnitX(u) * wp.targX + GetUnitY(u) * wp.targY)
                if tmpDist <= dist then
                    set foundWP = i
                    set dist = tmpDist    
                endif
                
                set i = i + 1    
            endloop
            
            return foundWP
        endmethod
        //: ====================================
        
        //: ====================================
        //: Desctrutor Method
        //: ====================================
        private method onDestroy takes nothing returns nothing
            local integer i = 0
            
            loop
                exitwhen i >= .curwpID
                
                call .wayPoints[i].destroy()
                 
                set i = i + 1
            endloop
            
            call thistype.removeWay(this)
        endmethod
        //: ====================================
    endstruct
    
    private struct MoveOrders
    
        //: =================================
        //: CHECK ALL WAYS FOR SPAWNING
        //: =================================
        static method checkWays takes nothing returns nothing
            local Way wy = 0
            local WayPoint wp = 0
            local integer i = 0
            
            local unit u = null
            local group g = CreateGroup()
            local integer unitID = 0
            local integer wpID = 0
            
            local real dx = 0.
            local real dy = 0.
            local real dist = 0.
            
            loop
                exitwhen i >= Way.index
                
                //----------------
                //: %Reset Data%
                //----------------
                set u = null
                call GroupClear(g)
                set wy = 0
                set wp = 0
                set unitID = 0
                //----------------
                
                set wy = Way.instances[i]
                call GroupAddGroup(wy.units, g)
                
                loop
                    set u = FirstOfGroup(g)
                    exitwhen u == null
                    
                    //-----------------------
                    // %Get unit data%
                    //-----------------------
                    set unitID = GetHandleId(u)
                    set wpID = LoadInteger(UNIT_DATA, unitID, KEY_CURPOS)
                    set wp = wy.wayPoints[wpID]
                    
                    //: Check whether the unit is in the range of
                    //: her checkpoint
                    set dx = GetUnitX(u) - wp.targX
                    set dy = GetUnitY(u) - wp.targY
                    set dist = SquareRoot(dx * dx + dy * dy)
                    if dist <= wp.targRadius or GetUnitCurrentOrder(u) == 0 then
                        call wy.moveNext(u, wpID)
                        static if SHOW_DEBUG_MSG then
                            debug call BJDebugMsg("!AoSMoveSys] |NOTICE| <Way[" + I2S(wy.ID) + "]> <Unit " + I2S(GetHandleId(u)) + " reached target>")
                        endif
                    endif
                    
                    call GroupRemoveUnit(g, u)
                endloop 
                
                set i = i + 1
            endloop
            
            call GroupClear(g)
            call DestroyGroup(g)
            set u = null
            set g = null
        endmethod
        //: =================================
    endstruct
    
    private function init takes nothing returns nothing
        local integer i = 0
        call TimerStart(MOVE_TIMER, MOVE_INT, true, function MoveOrders.checkWays)
        
        if SPELLCAST_CONTINUE then
            call TriggerAddAction(Way.scTrig, function reOrderUnit)
            call TriggerAddCondition(Way.scTrig, Condition(function checkSpellcast))
            set i = 0
            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                call TriggerRegisterPlayerUnitEvent(Way.scTrig, Player(i), EVENT_PLAYER_UNIT_SPELL_ENDCAST, null)
                set i = i + 1
            endloop
        endif
                
        if STOP_CONTINUE then
            call TriggerAddAction(Way.stTrig, function reOrderUnit)
            call TriggerAddCondition(Way.stTrig, Condition(function checkStopOrder))
            set i = 0
            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                call TriggerRegisterPlayerUnitEvent(Way.stTrig, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
                set i = i + 1
            endloop
        endif
                
        if HOLDPOSITION_CONTINUE then
            call TriggerAddAction(Way.hpTrig, function reOrderUnit)
            call TriggerAddCondition(Way.hpTrig, Condition(function checkHoldOrder))
            set i = 0
            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                call TriggerRegisterPlayerUnitEvent(Way.hpTrig, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
                set i = i + 1
            endloop
        endif
                
        if DEATH_REMOVES then
            call TriggerAddAction(Way.deathTrig, function unregisterUnit)
            call TriggerAddCondition(Way.deathTrig, Condition(function checkUnregister))
            set i = 0
            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                call TriggerRegisterPlayerUnitEvent(Way.deathTrig, Player(i), EVENT_PLAYER_UNIT_DEATH, null)
                set i = i + 1
            endloop
        endif
        
        //um das Zurücklaufen der Einheiten endgültig zu unterbinden!
        call TriggerAddAction(Way.moTrig, function reOrderUnit)
        call TriggerAddCondition(Way.moTrig, Condition(function checkMoveOrder))
        call TriggerRegisterPlayerUnitEvent(Way.moTrig, Player(bj_PLAYER_NEUTRAL_VICTIM), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)
        
    endfunction

endlibrary