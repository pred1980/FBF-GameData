library MathFunctions
//********************************************************
//* :::::::::::::::::::::::::::::::::::::::::::::::::::: *
//* ::::::::::::::::::::MathLibrary::::::::::::::::::::: *
//* :::::::::::::::::::::::::::::::::::::::::::::::::::: *
//* : Comlation of the most important Math Functions : *
//* :::::::::::::::::::::::::::::::::::::::::::::::::::: *
//********************************************************

    globals
        private constant integer  Iterations        = 20           //* Logarithm Iterations!!
        constant real     TwoPI                     = 6.2831853    //* 2 * PI
        constant real     e                         = 2.7182818    //* Euler's number
        constant real     radian                    = .01745329    //* Conversion: Degree to Radian (PI/180)
        constant real     degree                    = 57.295779    //* Conversion: Radian to Degree (180/PI)
        
        private location loc                        = Location(0.0,0.0)
        
        private constant real     AutoDestroyPeriod = 0.1
        private constant boolean  AutoDestroyVector = true
        private constant timer    AutoDestroyTimer  = CreateTimer()
    endglobals
    
    // - # - This function allows you to get the n-th root of a value.
    // - # - Requires 2 arguments:
    // - # -            - real x: the value that shall be rooted.
    // - # -            - real exp: the root amount.
    function xRoot takes real x, real exp returns real
        return Pow(x,1/exp)
    endfunction
    
    // - # - With this function you can return a correct angle value between 0 and 360.
    // - # - Requires 1 argument:
    // - # -            - real angle: the angle that shall be converted
    function realAngle takes real angle returns real
        local real r=angle
        loop
            exitwhen r>=0 and r<=360
            if r<0 then 
                set r=r+360
            elseif r>360 then
                set r=r-360
            endif
        endloop
        return r
    endfunction
    
    // - # - With this function you can get the Angle between 2 Points.
    // - # - Requires 4 arguments:
    // - # -            - real x0: the x-coordinate of the first Point.
    // - # -            - real y0: the y-coordinate of the first Point.
    // - # -            - real x1: the x-coordinate of the second Point.
    // - # -            - real y1: the y-coordinate of the second Point.
    // - # - Angle will be returned in Radians
    function Angle takes real x0, real y0, real x1, real y1 returns real
        return Atan2((y1-y0),(x1-x0))
    endfunction
    
    // - # - With this function you can get the Distance between 2 Points.
    // - # - Requires 4 arguments:
    // - # -            - real x0: the x-coordinate of the first Point.
    // - # -            - real y0: the y-coordinate of the first Point.
    // - # -            - real x1: the x-coordinate of the second Point.
    // - # -            - real y1: the y-coordinate of the second Point.
    function Distance takes real x0, real y0, real x1, real y1 returns real
        return SquareRoot((x1-x0)*(x1-x0)+(y1-y0)*(y1-y0))
    endfunction
    
    // - # - With this function you can get the height-angle difference between 2 Points.
    // - # - Requires 6 arguments:
    // - # -            - real x0: the x-coordinate of the first Point.
    // - # -            - real y0: the y-coordinate of the first Point.
    // - # -            - real z0: the z-coordinate of the first Point.
    // - # -            - real x1: the x-coordinate of the second Point.
    // - # -            - real y1: the y-coordinate of the second Point.
    // - # -            - real z1: the z-coordinate of the second Point.
    function getZAngle takes real x0, real y0, real z0, real x1, real y1, real z1 returns real
        return Atan2(z1-z0,SquareRoot((x1-x0)*(x1-x0)+(y1-y0)*(y1-y0)))
    endfunction
    
    // - # - With this function you can get the Distance between 2 Points in consideration of their heights.
    // - # - Requires 6 arguments:
    // - # -            - real x0: the x-coordinate of the first Point.
    // - # -            - real y0: the y-coordinate of the first Point.
    // - # -            - real z0: the z-coordinate of the first Point.
    // - # -            - real x1: the x-coordinate of the second Point.
    // - # -            - real y1: the y-coordinate of the second Point.
    // - # -            - real z1: the z-coordinate of the second Point.
    function Distance3D takes real x0, real y0, real z0, real x1, real y1, real z1 returns real
        return SquareRoot((x1-x0)*(x1-x0)+(y1-y0)*(y1-y0)+(z1-z0)*(z1-z0))
    endfunction

    // - # - With this function you can get the natural Logarithm of a value.
    // - # - Requires 1 argument:
    // - # -            - real x: the value you want to get the ln from.
    function lnat takes real x returns real
        local integer i=Iterations
        local real min=-88.
        local real max=88.
        local real mid=.0
        loop
            exitwhen (i<=0)
            set mid=(max+min)/2
            if Pow(bj_E,mid)>=x then
                set max=mid
            else
                set min=mid
            endif
            set i=i-1
        endloop
        return mid
    endfunction
    
    // - # - With this function you can get the Logarithm to the base 10 of a value.
    // - # - Requires 1 argument:
    // - # -            - real x: the value you want to get the Logarithm from.
    function logarithm takes real x returns real
        local integer i=Iterations
        local real min=-88.
        local real max=88.
        local real mid=.0
        loop
            exitwhen (i<=0)
            set mid=(max+min)/2
            if Pow(10,mid)>=x then
                set max=mid
            else
                set min=mid
            endif
            set i=i-1
        endloop
        return mid
    endfunction
    
    // - # - With this function you can get the Logarithm to any base of a value.
    // - # - Requires 2 arguments:
    // - # -            - real x: the value you want to get the Logarithm from.
    // - # -            - real base: the basis you want the Logarithm have to.
    function logEx takes real x, real base returns real
        local integer i=Iterations
        local real min=-88.
        local real max=88.
        local real mid=.0
        loop
            exitwhen (i<=0)
            set mid=(max+min)/2
            if Pow(base,mid)>=x then  
                set max=mid
            else
                set min=mid
            endif
            set i=i-1
        endloop
        return mid
    endfunction
    
    // - # - With this function you can get the sign of a value. (positive or negative)
    // - # - Requires 1 argument:
    // - # -            - real a: the value you want to get the sign from.
    function getSign takes real a returns real
        if a>=0 then
            return 1.
        else
            return -1.
        endif
    endfunction

    // - # - With this function you can get the Absolute value of a real.
    // - # - Requires 1 argument:
    // - # -            - real a: the value you want the absolute from.
    function absoluteReal takes real a returns real
        if a>=0 then
            return a
        else
            return -a
        endif
    endfunction
    
    // - # - With this function you can get the Absolute value of an integer.
    // - # - Requires 1 argument:
    // - # -            - integer i: the value you want the absolute from.
    function absoluteInt takes integer i returns integer
        if i>=0 then
            return i
        else
            return -i
        endif
    endfunction

    // - # - With this function you can get the Rest of a division.
    // - # - Requires 2 arguments:
    // - # -            - integer dividend: the value that gets divided.
    // - # -            - integer divisor: the value that divides.
    function modulo takes integer dividend, integer divisor returns integer
        return absoluteInt(dividend-(dividend/divisor)*divisor)
    endfunction

    // - # - With this function you can get a common Parabola curve based on the Maximum height and Maximum distance.
    // - # - Requires 3 arguments:
    // - # -            - real h: the maximum reachable height.
    // - # -            - real d: the maximum reachable distance.
    // - # -            - real x: the current reached distance.
    function ParabolaZ takes real h, real d, real x returns real
        return  (4*h/d)*(d-x)*(x/d)
    endfunction
    
    // - # - With this function you can get an extended Parabola curve based on the
    // - # - Maximum height and Maximum distance in consideration of the Height differences.
    // - # - Requires 5 arguments:
    // - # -            - real h: the maximum reachable height.
    // - # -            - real d: the maximum reachable distance.
    // - # -            - real x: the current reached distance.
    // - # -            - real z0: the height of the starting point.
    // - # -            - real z1: the height of the finishing point.
    function ParabolaZEx takes real h, real d, real x, real z0, real z1 returns real
        return (4*h/d)*(d-x)*(x/d) + (((z1-z0)/d)*x+z0)
    endfunction
    
    // - # - With this struct you are able to create 3-Dimensional Coordinates.
    // - # - To create a vector just call this:
    // - # -                              x-Coordinate | y-Coordinate | z-Coordinate
    // - # - local vector v=vector.create(      x      ,       y      ,      z      )
    struct vector[20000]
        //* x-coordinate of the vector
        real x = 0.0 
        //* y-coordinate of the vector
        real y = 0.0
        //* z-coordinate of the vector
        real z = 0.0
        //* shall this vector be autodestroyed
        private boolean autoDestroy=AutoDestroyVector
        private real    autoTime   =0.0
        private boolean inUse      =false
        
        private static integer vectorCount = 1
        
        method onDestroy takes nothing returns nothing
            set .inUse=false
            set .autoTime=0.0
            set .autoDestroy=AutoDestroyVector
        endmethod
        
        // - # - With this function you can create a vector.
        // - # - Requires 3 arguments:
        // - # -            - real x: the x-coordinate
        // - # -            - real y: the y-coordinate
        // - # -            - real z: the z-coordinate
        static method create takes real x, real y, real z returns thistype
            local thistype vec=thistype.allocate()
            set vec.x=x
            set vec.y=y
            set vec.z=z
            set vec.inUse=true
            if vec==thistype.vectorCount then
                set thistype.vectorCount=thistype.vectorCount+1
            endif
            return vec
        endmethod
        
        // - # - With this function you can stop the autorecycling of a vector.
        method stopAutoClear takes nothing returns nothing
            set this.autoDestroy=false
        endmethod
        
        // - # - With this function you can return the length of a vector.
        method operator length takes nothing returns real
            return SquareRoot(this.x*this.x+this.y*this.y+this.z*this.z)
        endmethod
        
        // - # - With this function you can return the Angle between the
        // - # - x-coordinate and y-coordinate.
        method operator xyAngle takes nothing returns real
            return Angle(0.,0.,this.x,this.y)
        endmethod
        
        // - # - With this function you can return the Angle between the
        // - # - Ground and the vectors z-coordinate.
        method operator zAngle takes nothing returns real
            return getZAngle(0.,0.,0.,this.x,this.y,this.z)
        endmethod
        
        // - # - With this function you can add a vector to another.
        // - # - Requires 1 argument:
        // - # -            - vector additive: the vector that shall be added.
        method add takes thistype additive returns nothing
            set this.x=this.x+additive.x
            set this.y=this.y+additive.y
            set this.z=this.z+additive.z
        endmethod
        
        // - # - With this function you can sum 2 vectors to a new one.
        // - # - Requires 2 arguments:
        // - # -            - vector start: the starting vector.
        // - # -            - vector end: the vector that gets added to the starting vector.
        static method sum takes thistype start, thistype end returns thistype
            return thistype.create(start.x+end.x,start.y+end.y,start.z+end.z)
        endmethod
        
        // - # - With this function you can subtract a vector from another.
        // - # - Requires 1 argument:
        // - # -            - vector subtrahend: the vector that shall be subtracted.
        method subtract takes thistype subtrahend returns nothing
            set this.x=this.x-subtrahend.x
            set this.y=this.y-subtrahend.y
            set this.z=this.z-subtrahend.z
        endmethod
        
        // - # - With this function you can subtract 2 vectors to a new one.
        // - # - Requires 2 arguments:
        // - # -            - vector start: the starting vector.
        // - # -            - vector end: the vector that gets subtracted from the starting vector.
        static method difference takes thistype start, thistype end returns thistype
            return thistype.create(end.x-start.x,end.y-start.y,end.z-start.z)
        endmethod
        
        // - # - With this function you can scale a vector.
        // - # - Requires 1 argument:
        // - # -            - real factor: the scaling factor.
        method scale takes real factor returns nothing
            set this.x=this.x*factor
            set this.y=this.y*factor
            set this.z=this.z*factor
        endmethod
        
        // - # - With this function you can scale a vector to a new one.
        // - # - Requires 2 arguments:
        // - # -            - vector a: the vector that shall be scaled.
        // - # -            - real factor: the scaling factor.
        static method scaleVector takes thistype a, real factor returns thistype
            return thistype.create(a.x*factor,a.y*factor,a.z*factor)
        endmethod
        
        // - # - With this function you can set a vectors length.
        // - # - Requires 1 argument:
        // - # -            - real length: the new length the vector shall have.
        method setLength takes real length returns nothing
            local real l=SquareRoot(this.x*this.x+this.y*this.y+this.z*this.z)
            if l!=0 then
                call this.scale(length/l)
            endif
        endmethod
        
        // - # - With this function you can get the length of a vector.
        // - # - Requires 1 argument:
        // - # -            - vector a: the vector you want the length from.
        static method getLength takes thistype a returns real
            return SquareRoot(a.x*a.x+a.y*a.y+a.z*a.z)
        endmethod
        
        // - # - With this function you can get the ScalarProduct of 2 vectors.
        // - # - Requires 2 arguments:
        // - # -            - vector a: one of the 2 vectors.
        // - # -            - vector b: one of the 2 vectors.
        static method scalarProduct takes thistype a, thistype b returns real
            return (a.x*b.x+a.y*b.y+a.z*b.z)
        endmethod
        
        // - # - With this function you can get the VectorProduct of 2 vectors in a new vector.
        // - # - Requires 2 arguments:
        // - # -            - vector a: one of the 2 vectors.
        // - # -            - vector b: one of the 2 vectors.
        static method vectorProduct takes thistype a, thistype b returns thistype
            return thistype.create(a.y*b.z-a.z-b.y,a.z*b.x-a.x-b.z,a.x*b.y-a.y*b.x)
        endmethod
        
        // - # - With this function you can create the UnitVector of a vector.
        // - # - Requires 1 argument:
        // - # -            - vector a: the vector you want the UnitVector from.
        static method unitVector takes thistype a returns thistype
            return thistype.scaleVector(a,1/a.length)
        endmethod
        
        // - # - With this function you can get the Angle between a vector and another.
        // - # - Requires 1 argument:
        // - # -            - vector a: the vector you want the angle from.
        method angle takes thistype a returns real
            return Atan(scalarProduct(this,a)/(a.length*this.length))
        endmethod

        // - # - With this function you can get the Angle between 2 vectors.
        // - # - Requires 2 arguments:
        // - # -            - vector a: one of the 2 vectors you want the Angle between.
        // - # -            - vector b: one of the 2 vectors you want the Angle between.
        static method getAngle takes thistype a, thistype b returns real
            return Acos(scalarProduct(a,b)/(a.length*b.length))
        endmethod
        
        // - # - With this function you can mirror a vector.
        // - # - Requires 1 argument:
        // - # -            - vector projector: the vector you want the other vector to be mirrored at.
        method mirrorVector takes thistype projector returns nothing
            if projector.length!=0 then
                set this.x=2*projector.x-this.x
                set this.y=2*projector.y-this.y
                set this.z=2*projector.z-this.z
            endif
        endmethod
        
        // - # - With this function you can mirror a vector on another to a new vector.
        // - # - Requires 2 arguments:
        // - # -            - vector projector: the vector you want the other vector to be mirrored at.
        // - # -            - vector projected: the vector you want to be mirrored.
        static method mirrorVectorEx takes thistype projector, thistype projected returns thistype
            if projector.length!=0 then
                return thistype.create(2*projector.x-projected.x,2*projector.y-projected.y,2*projector.z-projected.z)
            else
                return thistype.create(0.,0.,0.)
            endif
        endmethod
        
        // - # - With this function you can project a vector.
        // - # - Requires 1 argument:
        // - # -            - vector direction: the vector you want the other projected to.
        method projectVector takes thistype direction returns nothing
            local real factor=0.0
            if direction.length!=0 then
                set factor=this.length/direction.length
                set this.x=direction.x*factor
                set this.y=direction.y*factor
                set this.z=direction.z*factor
            endif
        endmethod
        
        // - # - With this function you can project a vector to another one to a new vector.
        // - # - Requires 2 arguments:
        // - # -            - vector projected: the vector that gets projected.
        // - # -            - vector direction: the vector you want the other projected to.
        static method projectVectorEx takes thistype projected, thistype direction returns thistype
            local real factor=0.0
            if direction.length!=0 then
                set factor=projected.length/direction.length
                return thistype.create(direction.x*factor,direction.y*factor,direction.z*factor)
            else
                return thistype.create(0.,0.,0.)
            endif
        endmethod
        
        // - # - With this function you can rotate a vector
        // - # - requires 2 values:
        // - # - - xyAngle: the horizontal rotation angle
        // - # - - zAngle: the vertical rotation angle
        method rotate takes real xyAngle, real zAngle returns nothing
            local real a=this.length
            local real b=this.xyAngle
            set this.x=a*Cos(b+xyAngle)
            set this.y=a*Sin(b+xyAngle)
            
            set b=this.zAngle
            set this.x=x*Cos(b+zAngle)
            set this.y=y*Cos(b+zAngle)
            set this.z=z*Sin(b+zAngle)
        endmethod
        
        // - # - With this function you can rotate any vector to a new one.
        // - # - Requires 3 arguments:
        // - # -            - vector a: the vector that shall be rotated.
        // - # -            - real xyAngle: the horizontal rotation angle.
        // - # -            - real zAngle: the vertical rotation angl.
        static method rotateVector takes thistype a, real xyAngle, real zAngle returns thistype
            local real d=a.length
            local real e=a.xyAngle
            local real f=a.zAngle
            local real x=d*Cos(e+xyAngle)
            local real y=d*Sin(e+xyAngle)
            local real z=d*Sin(f+zAngle)
            set x=d*Cos(f+zAngle)
            set y=d*Cos(f+zAngle)
            return thistype.create(x,y,z)
        endmethod
        
        // - # - With this function you can check whether a vector is in sphere of a location with a specific radius.
        // - # - Requires 4 arguments:
        // - # -            - real x: the x-coordinate of the sphere.
        // - # -            - real y: the y-coordinate of the sphere.
        // - # -            - real z: the z-coordinate of the sphere.
        // - # -            - real radius: the radius of the sphere.
        method isInSphere takes real x, real y, real z, real radius returns boolean
            if .x>x-radius and .x<x+radius and .y>y-radius and .y<y+radius and .z>z-radius and .z<z+radius then
                return true
            else
                return false
            endif
        endmethod
        
        // - # - With this function you can check whether a vector is in sphere of another vector.
        // - # - Requires 3 arguments:
        // - # -            - vector a: one of the 2 vectors.
        // - # -            - vector b: one of the 2 vectors.
        // - # -            - real radius: the radius of the sphere.
        static method vectorInSphere takes vector a, vector b, real radius returns boolean
            return a.isInSphere(b.x,b.y,b.z,radius)
        endmethod
        
        static method autoClear takes nothing returns nothing
            local integer i=0
            loop
                exitwhen i==thistype.vectorCount
                if thistype(i).autoDestroy and thistype(i).inUse then
                    if thistype(i).autoTime>=AutoDestroyPeriod then
                        set thistype(i).inUse=false
                        call thistype(i).destroy()
                    endif
                    set thistype(i).autoTime=thistype(i).autoTime+0.05
                endif
                set i=i+1
            endloop
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TimerStart(AutoDestroyTimer,0.05,true,function thistype.autoClear)
        endmethod
            
    endstruct
    
    function LocationZ takes real x, real y returns real
        call MoveLocation(loc,x,y)
        return GetLocationZ(loc)
    endfunction
    
    function AngleBetweenCords takes real x1, real y1, real x2, real y2 returns real
        return bj_RADTODEG*Atan2(y2-y1,x2-x1)
    endfunction

    function DistanceBetweenCords takes real x1, real y1, real x2, real y2 returns real
        local real dx=x2-x1
        local real dy=y2-y1
        return SquareRoot(dx * dx + dy * dy)
    endfunction

    function PolarProjectionX takes real x , real dist , real angle returns real
        return x + dist * Cos(angle * bj_DEGTORAD)
    endfunction

    function PolarProjectionY takes real y , real dist , real angle returns real
        return y + dist * Sin(angle * bj_DEGTORAD)
    endfunction

    function AddAngle takes real angle, real addition returns real
        local real sum=angle+addition+360
        return sum-I2R(R2I(sum/360))*360
    endfunction
    
    //returns the bigger of two vales
    function GetMax takes real r1, real r2 returns real
        if r1 < r2 then
            return r2
        else
            return r1
        endif
    endfunction
    
    //returns the smaller of two vales
    function GetMin takes real r1, real r2 returns real
        if r1 < r2 then
            return r1
        else
            return r2
        endif
    endfunction
    
endlibrary