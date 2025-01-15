library Knockback requires ListModule, GroupUtils, TerrainPathability, UnitStatus, optional BoundSentinel

    globals
        public constant real TIMER_INTERVAL = 0.03125
        private constant real STANDARD_DEST_RADIUS = 100.00
        private constant real STANDARD_UNIT_RADIUS = 75.00
        private constant boolean PAUSE_UNITS = true
        private constant boolean IGNORE_FLYING_UNITS = true
        private constant string KNOCKBACK_SFX = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private constant string KNOCKBACK_SFX_LOC = "origin"
    endglobals

    //The Action Respones
    private function interface onStart takes Knockback kb returns nothing
    private function interface onLoop takes Knockback kb returns nothing
    private function interface onUnitHit takes Knockback kb, unit hit returns nothing
    private function interface onDestructableHit takes Knockback kb, destructable hit returns nothing
    private function interface onTargetDeath takes Knockback kb returns nothing
    private function interface onEnd takes Knockback kb returns nothing
    private function interface filterFunction takes Knockback kb, unit enum returns boolean
        
    //The KnockbackType Struct
    struct KnockbackType
        onStart onStartAction = 0
        onLoop onLoopAction = 0
        onUnitHit onUnitHitAction = 0
        onDestructableHit onDestructableHitAction = 0
        onEnd onEndAction = 0
        onTargetDeath onTargetDeathAction = 0
        filterFunction filterFunc = 0
    endstruct

    //The Knockback Struct
    struct Knockback
    
        //public readonly variables
        readonly unit caster = null
        readonly unit target = null
        readonly real timeOver = 0.00
        readonly real currentSpeed = 0.00
        readonly real movedDistance = 0.00
        readonly real duration = 0.00
        readonly real distance = 0.00
        
        //variables you can change while the unit is being knocked back
        public real angle = 0.00
        public real aoeUnit = STANDARD_UNIT_RADIUS
        public real aoeDest = STANDARD_DEST_RADIUS
        public integer array userData[3]
        
        //private variables
        private real deceleration = 0.00
        private effect fx = null
        private effect kbEffect = null
        private boolean ranDeathAction = false
        private boolean isGround = false
        private real time = 0.00
        
        //the actions
        private onStart onStartAction = 0
        private onLoop onLoopAction = 0
        private onUnitHit onUnitHitAction = 0
        private onDestructableHit onDestructableHitAction = 0
        private onEnd onEndAction = 0
        private onTargetDeath onTargetDeathAction = 0
        private filterFunction filterFunc = 0
        
        //just some static variables to make the system faster/work
        private static timer ticker = null
        private static boolexpr unitFilter = null 
        private static boolexpr destFilter = null
        private static code unitActions = null
        private static code destActions = null
        private static thistype temp = 0
        private static rect destRect = Rect(0,0,1,1)
        private static real tx = 0.00
        private static real ty = 0.00
        private static HandleTable t = 0
        
        //ListModule
        implement List
        
        
        //saves the actions in the Knockback Struct (will be used in the create method)
        private method assignActions takes KnockbackType kb returns nothing
            set .onStartAction = kb.onStartAction
            set .onLoopAction = kb.onLoopAction
            set .onUnitHitAction = kb.onUnitHitAction
            set .onDestructableHitAction = kb.onDestructableHitAction
            set .onEndAction = kb.onEndAction
            set .onTargetDeathAction = kb.onTargetDeathAction
            set .filterFunc = kb.filterFunc
        endmethod
        
        //this is the filter for destructables around the target
        private static method destFilterMethod takes nothing returns boolean
            local real x = GetDestructableX(GetFilterDestructable())
            local real y = GetDestructableY(GetFilterDestructable())
            return (.tx-x)*(.tx-x) + (.ty-y)*(.ty-y) <= .temp.aoeDest * .temp.aoeDest
        endmethod
        
        //this method will run the onDestructableHit action for every destructable hit
        private static method runDestActions takes nothing returns nothing
            if .temp.onDestructableHitAction != 0 then
                call .temp.onDestructableHitAction.evaluate(.temp, GetEnumDestructable())
            endif
        endmethod
        
        //this method calls the user defined filter method
        private static method filterMethod takes nothing returns boolean
            if .temp.filterFunc != 0 then
                return GetFilterUnit() != .temp.target and temp.filterFunc.evaluate(.temp, GetFilterUnit())
            else
                return GetFilterUnit() != .temp.target
            endif
        endmethod
        
        //this method will run the onUnitHit action for every unit hit
        private static method runUnitActions takes nothing returns nothing
            if .temp.onUnitHitAction != 0 then
                call .temp.onUnitHitAction.evaluate(.temp, GetEnumUnit())
            endif
        endmethod
        
        //cleans up the struct and runs the onEnd actions
        private method onDestroy takes nothing returns nothing
            if .fx != null then
                call DestroyEffect(.fx)
            endif
            
            call DestroyEffect(.kbEffect)
            
            if .onEndAction != 0 then
                call .onEndAction.evaluate(this)
            endif
            
            static if PAUSE_UNITS then
                set t[target] = t[target] - 1
                if t[target] <= 0 then
                    call DisableUnit(target, false)
                endif
            endif
            call .listRemove()
        endmethod
        
        //this method will be called every TIMER_INTERVAL and update the units position as well as runs the onLoop action
        private static method onExpire takes nothing returns nothing
            local thistype this = .first
            local real x 
            local real y
            
            local group g = NewGroup()
            
            loop
                exitwhen this == 0
                
                //run the onLoop action
                if .onLoopAction != 0 then
                    call .onLoopAction.evaluate(this)
                endif
                
                if IsUnitType(.target, UNIT_TYPE_DEAD) or GetUnitTypeId(.target) == 0 and not .ranDeathAction then
                    if .onTargetDeathAction != 0 then
                        call .onTargetDeathAction.evaluate(this)
                    endif
                    set .ranDeathAction = true
                endif
                
                //change the time which has been gone
                set .timeOver = .timeOver + TIMER_INTERVAL
                set .currentSpeed = .currentSpeed - .deceleration
                set .movedDistance = .movedDistance + .currentSpeed
                
                set x = GetUnitX(.target) + (.currentSpeed) * Cos(angle)
                set y = GetUnitY(.target) + (.currentSpeed) * Sin(angle)
                
                ///check for destructables arround the target
                set .tx = x
                set .ty = y
                call SetRect(.destRect, -.aoeDest, -.aoeDest, .aoeDest, .aoeDest)
                call MoveRectTo(.destRect, x, y)
                call EnumDestructablesInRect(.destRect, .destFilter, .destActions)
                
                //check pathability and set new unit position if walkable
                if IsTerrainWalkable(x, y) then
                    call SetUnitX(.target, x)
                    call SetUnitY(.target, y)
                else
                    static if STOP_WHEN_UNPASSABLE then
                        call .destroy()
                    endif
                endif
                
                //catch units in the aoe around the target
                set .temp = this
                call GroupEnumUnitsInArea(g, x, y, .aoeUnit, .unitFilter)
                call ForGroup(g, .unitActions)
                
                //if the knockback ended because the target reached the end or the speed is smaller than 0
                if .currentSpeed <= 0 or .movedDistance >= .distance then
                    call .destroy()
                endif
                
                //pause the timer if no knockback is active anymore
                if .count < 1 then
                    call PauseTimer(.ticker)
                endif
                
                //refresh group and get next instance
                call GroupRefresh(g)
                set this = .next
            endloop
            
            //cleanup locals
            call ReleaseGroup(g)
            set g = null
        endmethod

        //adds or changes the current effect attached to the target
        public method addSpecialEffect takes string fx, string attachPoint returns nothing
            if .fx != null then
                call DestroyEffect(.fx)
            endif
            set .fx = AddSpecialEffectTarget(fx, .target, attachPoint)
        endmethod
        
        //use this method to check if a unit is being knocked back
        static method isUnitKnockedBack takes unit whichUnit returns boolean
            return t[whichUnit] > 0
        endmethod
                
        
        //this method creates a new knockback
        public static method create takes unit caster, unit target, real distance, real time, real angle, KnockbackType kbType, string KB_SFX, string KB_SFX_LOC returns thistype
            local thistype this = thistype.allocate()
            local real speed = 2 * distance / ((time / TIMER_INTERVAL) + 1)
            local real deceleration = speed / (time / TIMER_INTERVAL)
            local integer i = 0
            
            //reset userData
            loop
                exitwhen i >= 2
                set .userData[i] = 0
                set i = i + 1
            endloop
            
            //set variables
            set .caster = caster
            set .target = target
            set .angle = angle
            set .distance = distance
            set .duration = time
            set .currentSpeed = speed
            set .deceleration = deceleration
            set .time = time
            
            set .isGround = not IsUnitType(.target, UNIT_TYPE_FLYING)
            
            if KB_SFX != "" then
                set .kbEffect = AddSpecialEffectTarget(KB_SFX, .target, KB_SFX_LOC)
            else
                set .kbEffect = AddSpecialEffectTarget(KNOCKBACK_SFX, .target, KNOCKBACK_SFX_LOC)
            endif
            
            static if PAUSE_UNITS then
                set t[target] = t[target] + 1
                if t[target] == 1 then
                    call DisableUnit(target, true)
                endif
            endif
            
            //add the event actions to the struct
            if kbType != 0 then
                call .assignActions(kbType)
            endif
            
            //run the onStart action
            if .onStartAction != 0 then
                call .onStartAction.evaluate(this)
            endif
            
            //add the knockback to the List
            call .listAdd()
            
            //start the timer if the new instance is the only one
            if .count == 1 then
                call TimerStart(.ticker, TIMER_INTERVAL, true, function thistype.onExpire)
            endif
        
            return this
        endmethod
    
        //Initialization
        private static method onInit takes nothing returns nothing
            set .ticker = CreateTimer()
            set .unitFilter  = Condition(function thistype.filterMethod)
            set .destFilter  = Condition(function thistype.destFilterMethod)
            set .unitActions = function thistype.runUnitActions
            set .destActions = function thistype.runDestActions
            static if PAUSE_UNITS then
                set t = HandleTable.create()
            endif
        endmethod
    endstruct
 endlibrary