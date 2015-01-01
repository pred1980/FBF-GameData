library BezierMissiles requires xefx

    globals
        //config
        private constant real dt = 0.04
    endglobals


    //function interfaced for callback-functions
    function interface BeziermissileCallbackEnd takes beziermissile b returns nothing
    function interface BeziermissileCallbackCollision takes unit victim, beziermissile b returns nothing
    function interface BeziermissileCallbackPeriodic takes beziermissile b, real time returns nothing


    struct beziermissile
        private static timer t
        private static beziermissile array active
        private static integer activeCount = 0
        
        private integer activePos
        
        //temp
            private static beziermissile tempthis
            private static real tempx
            private static real tempy
            private static real tempz
            private static group enumgroup = CreateGroup() 
            private static boolexpr enumfilter
        
        //bezier-contol-points:
            private real array px[4]
            private real array py[4]
            private real array pz[4]
        
        //collisionstuff
            private group alreadyhit
            ///owner of the missile
            player owner = Player(PLAYER_NEUTRAL_PASSIVE)
            ///the range in which collisions are detected
            real collisionrange = 0.
            ///units are no spheres usually an so you can use this ratio to make z count less in collision
            ///a value of 0. will disable height-checks in collision
            real zcollisionratio = .5
            ///this function is called whenever this missile collides with an other unit but only once per unit 
            BeziermissileCallbackCollision onCollision = 0
            ///collision ignores friendly and neutral units (.owner must be set)
            boolean collisionEnemiesOnly = true
            ///collision ignores structures
            boolean collisionIgnoreStructures = true
            ///collision ignores magic immune units
            boolean collisionIgnoreImmune = false
            
            
            
        //homing stuff
            //the target which the missile follows (if this is null the missile will not be homing)
            private unit p_target = null
            //the position of the target in the last cycle
            private real targetlastx
            private real targetlasty
        
        //time-stuff
            ///the duration until the target is reached
            real duration
            //the time already passed
            private real time = 0.
        
        //an integer to store your cutom data (i.e. struct)
        integer customdata = 0
        //an second integer to store your custom data (might be handy in some cases)
        integer customdata2 = 0
        
        //this is the fx       
        delegate xefx fx = 0
        
        ///this function is called when the target is reached
        BeziermissileCallbackEnd onEnd = 0
        
        BeziermissileCallbackPeriodic onLoop = 0
        
        ///returns the target the missile is homing on
        method operator target takes nothing returns unit
            return .p_target
        endmethod
        
        ///makes the missile home on a target
        method operator target= takes unit u returns nothing
            set .p_target = u
            set .targetlastx = GetUnitX(u)
            set .targetlasty = GetUnitY(u)
        endmethod
        
        private static method periodic takes nothing returns nothing
            local integer this 
            local integer i = beziermissile.activeCount
            local real p
            local real q
            local real x
            local real y
            local real z
            local real dx
            local real dy
            local real dz
            loop
                set i = i - 1
                exitwhen i < 0
                //---
                set this = beziermissile.active[i]
                set .time = .time + dt
                
                set p = .time / .duration
                set q = 1 - p
                
                if .target != null and not IsUnitType(.target, UNIT_TYPE_DEAD) then
                    set dx = GetUnitX(.target) - .targetlastx
                    set dy = GetUnitY(.target) - .targetlasty
                    
                    set .px[2] = .px[2] + dx
                    set .py[2] = .py[2] + dy
                    
                    set .px[3] = .px[3] + dx
                    set .py[3] = .py[3] + dy
                    
                    set .targetlastx = GetUnitX(.target)
                    set .targetlasty = GetUnitY(.target)
                endif
                
                //set x = q*q*q*.px[0] + 3*p*q*q*.px[1] + 3*p*p*q*.px[2] + p*p*p*.px[3] //14
                set x = ((.px[0]*q + 3*p*.px[1])*q + 3*p*p*.px[2])*q +  p*p*p*.px[3] //11
                //set y = q*q*q*.py[0] + 3*p*q*q*.py[1] + 3*p*p*q*.py[2] + p*p*p*.py[3]
                set y = ((.py[0]*q + 3*p*.py[1])*q + 3*p*p*.py[2])*q +  p*p*p*.py[3]
                //set z = q*q*q*.pz[0] + 3*p*q*q*.pz[1] + 3*p*p*q*.pz[2] + p*p*p*.pz[3]
                set z = ((.pz[0]*q + 3*p*.pz[1])*q + 3*p*p*.pz[2])*q +  p*p*p*.pz[3]
                
                set dx = x - .fx.x
                set dy = y - .fx.y
                set dz = z - .fx.z
                
                if dx != 0 or dy != 0 then 
                    set .fx.zangle = Atan(dz / (SquareRoot(dx*dx + dy*dy)))
                endif
                set .fx.xyangle = Atan2(dy, dx)
                set .fx.x = x
                set .fx.y = y
                set .fx.z = z
                
                if .onCollision != 0 and .collisionrange > 0 then
                    set beziermissile.tempthis = this
                    set beziermissile.tempx = .x
                    set beziermissile.tempy = .y
                    set beziermissile.tempz = .z
                    call GroupEnumUnitsInRange(beziermissile.enumgroup, beziermissile.tempx, beziermissile.tempy, .collisionrange, beziermissile.enumfilter)
                endif           
                
                if onLoop != 0 then
                    call onLoop.evaluate(this, .duration - .time)
                endif
                
                if .time >= .duration then
                    call .destroy()
                endif
            endloop
        endmethod
        
        private static method collision takes nothing returns boolean
            local unit u = GetFilterUnit()
            local beziermissile this = beziermissile.tempthis
            local real r
            local real x
            local real y
            local real dx
            local real dy
            local real dz
            if IsUnitInGroup(u, .alreadyhit) or IsUnitType(u, UNIT_TYPE_DEAD) then
                set u = null
                return false
            endif
            set x = GetUnitX(u)
            set y = GetUnitY(u)
            set dx = x - beziermissile.tempx
            set dy = y - beziermissile.tempy
            set dz = .zcollisionratio*(GetUnitFlyHeight(u) - beziermissile.tempz)
            set r = SquareRoot(dx*dx + dy*dy + dz*dz)
            if IsUnitInRangeXY(u, GetUnitX(u) + r, GetUnitY(u), .collisionrange) then
                if not .collisionEnemiesOnly or IsUnitEnemy(u, .owner) then
                    if not (.collisionIgnoreStructures and IsUnitType(u, UNIT_TYPE_STRUCTURE)) then
                        if not (.collisionIgnoreImmune and IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)) then
                            call .onCollision.evaluate(u, this)
                        endif
                    endif
                endif
                call GroupAddUnit(.alreadyhit, u)
            endif   
            set u = null
            return false
        endmethod
        
        ///creates an beziermissile with all parameters set to default
        ///you will have to set the 4 control points using other functions or direct access
        static method create takes nothing returns beziermissile
            local beziermissile this = beziermissile.allocate()
            set beziermissile.active[beziermissile.activeCount] = this 
            set .activePos = beziermissile.activeCount
            set beziermissile.activeCount = beziermissile.activeCount + 1
            if beziermissile.activeCount == 1 then
                call TimerStart(beziermissile.t, dt, true, function beziermissile.periodic)
            endif
            if .alreadyhit == null then
                set .alreadyhit = CreateGroup()
            else
                call GroupClear(.alreadyhit)
            endif
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            if .onEnd != 0 then
                call .onEnd.evaluate(this)
            endif    
            
            set beziermissile.activeCount = beziermissile.activeCount - 1
            set beziermissile.active[beziermissile.activeCount].activePos = .activePos
            set beziermissile.active[.activePos] = beziermissile.active[beziermissile.activeCount]
            if beziermissile.activeCount == 0 then
                call PauseTimer(beziermissile.t)
            endif
            
            if .fx != 0 then
                set .fx.zangle = 0
                call .fx.destroy()
            endif
        endmethod
        
        ///creates a beziermissile with all 4 control points given as coordinate and the duration
        static method createEx takes real p0x, real p0y, real p0z, real p1x, real p1y, real p1z, real p2x, real p2y, real p2z, real p3x, real p3y, real p3z, real duration returns beziermissile
            local beziermissile this = beziermissile.create()
            set .px[0] = p0x
            set .py[0] = p0y
            set .pz[0] = p0z
            set .px[1] = p1x
            set .py[1] = p1y
            set .pz[1] = p1z
            set .px[2] = p2x
            set .py[2] = p2y
            set .pz[2] = p2z
            set .px[3] = p3x
            set .py[3] = p3y
            set .pz[3] = p3z
            set .duration = duration
            return this
        endmethod
        
        ///creates a beziermissile and sets start-point, end point and duration
        static method createBasic takes real sx, real sy, real sz, real tx, real ty, real tz, real duration returns beziermissile
            local beziermissile this = beziermissile.create()
            set .px[0] = sx
            set .py[0] = sy
            set .pz[0] = sz
            set .px[3] = tx
            set .py[3] = ty
            set .pz[3] = tz
            set .duration = duration
            return this
        endmethod
        
        ///creates a beziermissile and sets start-point, end point and speed
        static method createBasicSpeed takes real sx, real sy, real sz, real tx, real ty, real tz, real speed returns beziermissile
            local beziermissile this = beziermissile.create()
            set .px[0] = sx
            set .py[0] = sy
            set .pz[0] = sz
            set .px[3] = tx
            set .py[3] = ty
            set .pz[3] = tz
            set .duration = SquareRoot((sx-tx)*(sx-tx) + (sy-ty)*(sy-ty) + (sz-tz)*(sz-tz)) / speed
            return this
        endmethod
        
        ///creates a beziermissile and sets start-point, end point and duration where end-point is the position of target
        ///this will not set the target field so the missile will not be homing
        static method createTarget takes real sx, real sy, real sz, unit target, real tz, real duration returns beziermissile
            local beziermissile this = beziermissile.create()
            set .px[0] = sx
            set .py[0] = sy
            set .pz[0] = sz
            set .px[3] = GetUnitX(target)
            set .py[3] = GetUnitY(target)
            set .pz[3] = GetUnitFlyHeight(target) + tz
            set .duration = duration
            return this
        endmethod
        
        ///creates a beziermissile and sets start-point, end point and speed where end-point is the position of target
        ///this will not set the target field so the missile will not be homing
        static method createTargetSpeed takes real sx, real sy, real sz, unit target, real tz, real speed returns beziermissile
            local beziermissile this = beziermissile.create()
            set .px[0] = sx
            set .py[0] = sy
            set .pz[0] = sz
            set .px[3] = GetUnitX(target)
            set .py[3] = GetUnitY(target)
            set .pz[3] = GetUnitFlyHeight(target) + tz
            set .duration = SquareRoot((sx-.px[3])*(sx-.px[3]) + (sy-.py[3])*(sy-.py[3]) + (sz-.pz[3])*(sz-.pz[3])) / speed
            return this
        endmethod
        
        ///set the first control point to the given position
        method setP1 takes real x, real y, real z returns nothing
            set .px[1] = x
            set .py[1] = y
            set .pz[1] = z
        endmethod
        
        ///set the first control point to a position relative to startpoint and endpoint
        ///imagine a coordinate system where the x-axis goes from start to end with start beiing at 0 and
        ///end beiing at 1. with the other two axis it is an orthonormal basis with the y-axis having a z of 0.
        method setP1Rel takes real x, real y, real z returns nothing
            local real dx = .px[3] - .px[0]
            local real dy = .py[3] - .py[0]
            local real dz = .pz[3] - .pz[0]
            local real l1 = SquareRoot(dx*dx + dy*dy + dz*dz)
            local real l2 = SquareRoot(dy*dy + dx*dx)
                   
            set .px[1] = .px[0] + dx*x + dy*y*l1/l2 -         dx*dz*z/l2
            set .py[1] = .py[0] + dy*x - dx*y*l1/l2 -         dy*dz*z/l2
            set .pz[1] = .pz[0] + dz*x              + (dx*dx+dy*dy)*z/l2
        endmethod
        
        ///set the second control point to the given position
        method setP2 takes real x, real y, real z returns nothing
            set .px[2] = x
            set .py[2] = y
            set .pz[2] = z
        endmethod
        
        ///set the second control point to a position relative to startpoint and endpoint
        ///imagine a coordinate system where the x-axis goes from start to end with start beiing at 0 and
        ///end beiing at 1. with the other two axis it is an orthonormal basis with the y-axis having a z of 0.
        method setP2Rel takes real x, real y, real z returns nothing
            local real dx = .px[3] - .px[0]
            local real dy = .py[3] - .py[0]
            local real dz = .pz[3] - .pz[0]
            local real l1 = SquareRoot(dx*dx + dy*dy + dz*dz)
            local real l2 = SquareRoot(dy*dy + dx*dx)
            set .px[2] = .px[0] + dx*x + dy*y*l1/l2 -         dx*dz*z/l2
            set .py[2] = .py[0] + dy*x - dx*y*l1/l2 -         dy*dz*z/l2
            set .pz[2] = .pz[0] + dz*x              + (dx*dx+dy*dy)*z/l2
        endmethod
        
        ///create the xefx-fx. Use this after defining the points so the starting angle is correct.
        method createFX takes string model returns nothing
            set .fx = xefx.create(.px[0], .py[0], Atan2(.py[1]-.py[0], .px[1]-.py[0])*bj_DEGTORAD)
            set .fx.fxpath = model
        endmethod
        
            
        static method onInit takes nothing returns nothing
            set beziermissile.t = CreateTimer()
            set beziermissile.enumfilter = Condition(function beziermissile.collision)
        endmethod

    endstruct

endlibrary