//<o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o>
//:     CustomAura
//:         by Anachron
//:         
//:     This system is thought to provide a basic aura system that can be used
//:     to create auras with buffs and unit stat modifiers.
//:
//:     What this is:
//:         This is a very fast and flexible way to create an AOE aura.
//:
//:     Functionality:
//:         - Use buffs
//:         - Use bonuses
//:         - Highly customizeable ([Don't] use whatever you want)
//:         - Highly flexible (You are allowed to change values at any time)
//:         - Fast
//:         - Easy understandable (Examples to bring the system closer to you)
//:         - Well written (Code is non-redundant, cathegorized)
//:
//:     Credits:
//:         Rising_Dusk for GroupUtils [http://www.wc3c.net/showthread.php?t=104464]
//:         
//:     Thanks to:
//:         Axarion for the idea.
//:
//<o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o>
library CustomAura requires GroupUtils, Table
    
    globals
        private constant real PERIOD = 0.25//0.0375
    endglobals

    private interface eventHandler
        method onLoop takes nothing returns nothing defaults nothing
        method onRegister takes unit theUnit returns nothing defaults nothing
        method onUnregister takes unit theUnit returns nothing defaults nothing
        method onStart takes nothing returns nothing defaults nothing
        method onEnd takes nothing returns nothing defaults nothing
        method getRadius takes nothing returns real defaults 0.
        method onCheck takes unit theUnit returns nothing defaults nothing
        method unitFilter takes unit theUnit returns boolean defaults true
        method onLevelup takes integer theLevel returns nothing defaults nothing
        method activeCond takes nothing returns boolean defaults true
        
        method addBuff takes unit theUnit returns nothing defaults nothing
        method removeBuff takes unit theUnit returns nothing defaults nothing
        method checkBuff takes unit theUnit returns nothing defaults nothing
        
        method addBonus takes unit theUnit returns nothing defaults nothing
        method removeBonus takes unit theUnit returns nothing defaults nothing
    endinterface
    
    struct CustomAura extends eventHandler
        public unit theUnit = null
        private group affect = null
        private group last = null
        public boolean isAlive = true
        public boolean isPaused = false
        private boolean hasStarted = false
        public integer spellId = 0
        
        
        //: == ---------------------------- ---------------------------- 
        //: #  Indexing & Structstuff
        //: == ---------------------------- ---------------------------- 
        private integer index = 0
        private static thistype curInstance = 0
        private static timer t = CreateTimer()
        private static integer a = 0
        private static thistype array i
        
        static integer affectedCount = 0
        
        implement CAIndex
        
        public static method create takes unit theUnit returns thistype
            local thistype this = thistype.allocate()
            
            set .affect = NewGroup()
            set .last = NewGroup()
            set .theUnit = theUnit
            
            set .index              = thistype.a
            set thistype.i[.index]  = this
            set thistype.a          = thistype.a +1
            if thistype.a == 1 then
                call TimerStart(thistype.t, PERIOD, true, function thistype.run)
            endif
            
            return this
        endmethod
        
        public stub method aliveCond takes nothing returns boolean 
            return GetUnitAbilityLevel(.theUnit, .spellId) > 0 
        endmethod
        
        public method isUnitAffected takes unit theUnit returns boolean
            return IsUnitInGroup(theUnit, .affect)
        endmethod
        
        public method affectUnit takes unit theUnit returns nothing
            call GroupAddUnit(.affect, theUnit)
            if not IsUnitInGroup(theUnit, .last) then
                call .addBuff(theUnit)
                call .addBonus(theUnit)
                call .onRegister(theUnit)
                set .affectedCount = .affectedCount + 1
            else
                call .checkBuff(theUnit)
            endif
        endmethod
        
        public method unaffectUnit takes unit theUnit returns nothing
            if not IsUnitInGroup(theUnit, .affect) then
                call GroupRemoveUnit(.last, theUnit)
                call .removeBuff(theUnit)
                call .removeBonus(theUnit)
                call .onUnregister(theUnit)
                set .affectedCount = .affectedCount - 1
            endif
        endmethod
        
        private static method unaffectAllEnum takes nothing returns nothing
            call thistype.curInstance.unaffectUnit(GetEnumUnit())
        endmethod
        
        public method unaffectAll takes nothing returns nothing
            set thistype.curInstance = this
            call GroupClear(.affect)
            call ForGroup(.last, function thistype.unaffectAllEnum)
        endmethod
        
        private static method tryRegister takes nothing returns boolean
            local thistype this = thistype.curInstance
            local unit u = GetFilterUnit()
            
            if .unitFilter(u) then
                call .affectUnit(u)
            endif
            
            set u = null
            return false
        endmethod
        
        private static method tryUnregister takes nothing returns nothing
            call thistype.curInstance.unaffectUnit(GetEnumUnit())
        endmethod
        
        private method move takes nothing returns nothing
            call .onLoop()
            
            set .isAlive = .activeCond()
            
            if .isPaused or not .isAlive then
                return
            endif
            
            if not .hasStarted then
                set .hasStarted = true
                call .onStart()
            endif
            
            //: Replaces call GroupAddGroup(.affect, .last)
            set bj_groupAddGroupDest = .last
            call ForGroup(.affect, function GroupAddGroupEnum)
            
            call GroupClear(.affect)
            call GroupEnumUnitsInRange(.affect, GetUnitX(.theUnit), GetUnitY(.theUnit), .getRadius(), Condition(function thistype.tryRegister))
            call ForGroup(.last, function thistype.tryUnregister)
        endmethod
        
        public static method run takes nothing returns nothing
            local integer i = 0
            
            loop
                exitwhen i >= thistype.a
                
                if thistype.i[i].isAlive and thistype.i[i] != 0 then
                    set thistype.curInstance = thistype.i[i]
                    call thistype.i[i].move()
                else
                    if thistype.i[i] != 0 then
                        call thistype.i[i].destroy()
                    endif
                    set thistype.a = thistype.a -1
                    set thistype.i[i] = thistype.i[thistype.a]
                    set thistype.i[i].index = i
                    set i = i -1
                endif
                
                set i = i +1
            endloop
            
            if thistype.a == 0 then
                call PauseTimer(thistype.t)
            endif
        endmethod
        
        private method onDestroy takes nothing returns nothing
            call .unaffectAll()
            call ReleaseGroup(.affect)
            call ReleaseGroup(.last)
            call .clear()
            call .onEnd()
        endmethod
    endstruct
endlibrary