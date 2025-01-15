//Version 1.3b
library MeteorSystem initializer MSInit
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//By Adiktuz                                                                                                                                                                                                                           //
//Credits to Vexorian for Dummy.mdx                                                                                                                                                                                                    //    
//                                                                                                                                                                                                                                     //
//How To Import:                                                                                                                                                                                                                       //
//Just copy and paste this library into your map                                                                                                                                                                                       //                                    
//Be sure to export/import the dummy.mdx model and copy the dummy unit                                                                                                                                                                 //                                
//                                                                                                                                                                                                                                     //
//How to use:                                                                                                                                                                                                                          //
//just call the function MSStart(unit caster, real scale,real damage,real x, real y, real radius, real dradius, real speed, real acc, real height, string mfx, string hfx, player owner, attacktype at, damagetype dt, boolean random) //
//Where:                                                                                                                                                                                                                               //
//unit caster = the unit that casted the spell                                                                                                                                                                                         //
//real scale = scale of the unit                                                                                                                                                                                                       //            
//real damage = the damage dealt by each meteor upon contact                                                                                                                                                                           //
//real x = the center of the AOE in the x-axis (SpellTargetX or UnitX)                                                                                                                                                                 //                        
//real y = the center of the AOE in the y-axis (SpellTargetY or UnitY)                                                                                                                                                                 //                
//real radius = the radius of the AOE where the meteors can be created                                                                                                                                                                 //        
//real dradius = the radius of the damage/unitfilter                                                                                                                                                                                   //    
//real speed = the initial distance that will be travelled by the meteor after one timer interval                                                                                                                                      //
//real acc = the increase in speed after one timer interval                                                                                                                                                                            //
//real height = the initial/max height of the meteor                                                                                                                                                                                   //        
//real timedelay = the time before the meteors move, the meteors will hang in the air during this time                                                                                                                                 //                                             //
//string mfx = the path to the model to be used as the meteor                                                                                                                                                                          //    
//string hfx = the path to the effect to be played when the meteor hits the ground or an air unit                                                                                                                                      //        
//player owner = owner of the meteor                                                                                                                                                                                                   //
//attacktype at = the attacktype of the meteor                                                                                                                                                                                         //
//damagetype dt = the damagetype of the meteor                                                                                                                                                                                         //
//boolean random = whether the meteors will all start at max height or can have some discrepancies                                                                                                                                     //    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//How to get an instance: method GetInstance takes unit u returns integer
//call Meteor.GetInstance(unit u)
//where unit u is the meteor unit whose instance you want to get.


    globals
        private constant integer MSDUMMY = 'e00O' //The rawcode of the dummy unit
        private constant real TICK = 0.03 //The periodic loop time
        //DO NOT EDIT BELOW THIS LINE
        //Unless you are sure of what you're doing
        private real xx = 0
        private real yy = 0
        private timer MSTIME = CreateTimer()
        private group MSFILTER = CreateGroup()
        private group MSFILTERED = CreateGroup()
        private group MSFILTERS = CreateGroup()
        private unit MSU = null
        private integer TOTAL = 0
        private integer array METEORS
        private real MAX_X
        private real MAX_Y
        private real MIN_X
        private real MIN_Y
        private integer INSTANCE
    endglobals
    
    //Methods for setting timedelay during flight
    //The first two are instance methods
    //method SetTimeDelay takes real delay returns nothing
    //method AddTimeDelay takes real delay returns nothing
    //The next two are non-instance methods and take the unit as a parameter
    //method AddTimeDelayUnit takes unit u, real delay returns nothing
    //method SetTimeDelayUnit takes unit u, real delay returns nothing
    
    interface MeteorI
        method onHit takes nothing returns nothing
        method onHitFilter takes unit u returns boolean defaults true
        method onLoop takes nothing returns nothing defaults nothing
    endinterface
    
    struct Meteor extends MeteorI
        real x
        real y
        real height
        real radius
        unit caster
        unit meteor
        player owner
        real damage
        damagetype dt
        attacktype at
        real speed
        real acc
        string mfx
        effect sfx
        boolean air
        real timedelay
        static thistype data
        
        method onHitFilter takes unit u returns boolean
            return IsUnitEnemy(u, this.owner) and GetWidgetLife(u) >= .405
        endmethod
        
        method SetTimeDelay takes real delay returns nothing
            set this.timedelay = delay
        endmethod
        
        method AddTimeDelay takes real delay returns nothing
            set this.timedelay = this.timedelay + delay
        endmethod
        
        static method SetTimeDelayUnit takes unit u, real delay returns nothing
            set data = GetInstance(u)
            set data.timedelay = delay
        endmethod
        
        static method AddTimeDelayUnit takes unit u, real delay returns nothing
            set data = GetInstance(u)
            set data.timedelay = data.timedelay + delay
        endmethod
        
        static method GetInstance takes unit u returns integer
            local integer i = 0
            local integer a = 0
            loop
                exitwhen i == TOTAL
                set data = METEORS[i]
                if data.meteor == u then
                    set a = i
                    set i = TOTAL
                else
                    set i = 1 + 1
                endif
            endloop
            return METEORS[a]
        endmethod
        
        method onDestroy takes nothing returns nothing
            call DestroyEffect(AddSpecialEffect(this.mfx, this.x, this.y))
            call DestroyEffect(this.sfx)
            call RemoveUnit(this.meteor)
            set this.sfx = null
            set this.meteor = null
            set this.owner = null
            set this.caster = null
            set this.at = null
            set this.dt = null
        endmethod
        
        static method GLoopAir takes nothing returns nothing
            set data = INSTANCE
            set MSU = GetEnumUnit()
            if data.onHitFilter(MSU) then
                call UnitDamageTarget(data.caster, MSU, data.damage, false, false, data.at, data.dt, WEAPON_TYPE_WHOKNOWS)
                call DestroyEffect(AddSpecialEffectTarget(data.mfx, MSU, "origin"))
            endif
            call GroupRemoveUnit(MSFILTERED, MSU)
        endmethod
        
        static method GLoop takes nothing returns nothing
            set data = INSTANCE
            set MSU = GetEnumUnit()
            if IsUnitEnemy(MSU, data.owner) and GetWidgetLife(MSU) >= .405 then
                call UnitDamageTarget(data.caster, MSU, data.damage, false, false, data.at, data.dt, WEAPON_TYPE_WHOKNOWS)
            endif
            call GroupRemoveUnit(MSFILTERS, MSU)
        endmethod
        
        method onHit takes nothing returns nothing
            set data = this
            set INSTANCE = data
            if data.air then
                call ForGroup(MSFILTERED, function Meteor.GLoopAir)
            else
                call GroupEnumUnitsInRange(MSFILTERS, data.x, data.y, data.radius, null)
                call ForGroup(MSFILTERS, function Meteor.GLoop)
            endif
            call data.destroy()
        endmethod
        
        static method MeteorLoop takes nothing returns nothing
            local integer i = 0
            local real fly = 0
            loop
                 exitwhen i == TOTAL
                 set data = METEORS[i]
                 set data.timedelay = data.timedelay - TICK
                 call data.onLoop()
                 if data.timedelay <= 0 then
                    set data.height = data.height - data.speed
                    call SetUnitFlyHeight(data.meteor, data.height, 0.00)
                    set data.speed = data.speed + data.acc
                    //The following lines until the next comment are for hitting air units
                    call GroupEnumUnitsInRange(MSFILTER, data.x, data.y, data.radius, null)
                    loop
                        set MSU = FirstOfGroup(MSFILTER)
                        exitwhen MSU == null
                        set fly = GetUnitFlyHeight(MSU)
                        if  (fly >= data.height - 50) and (fly <= data.height + 50) and IsUnitEnemy(MSU, data.owner) then
                            call GroupAddUnit(MSFILTERED, MSU)
                        endif
                        call GroupRemoveUnit(MSFILTER, MSU)
                    endloop
                    if FirstOfGroup(MSFILTERED) != null then
                        set data.height = 0
                        set data.air = true
                    endif
                    //End
                    if data.height <= 0 then
                        call data.onHit()
                        set TOTAL = TOTAL - 1
                        set METEORS[i] = METEORS[TOTAL]
                        set i = i - 1
                    endif
                endif
                call GroupClear(MSFILTERED)
                set i = i + 1
            endloop
            if TOTAL == 0 then
                call PauseTimer(MSTIME)
            endif
        endmethod
    endstruct
    
    function MSStart takes unit caster, real scale, real damage, real x, real y, real radius,  real dradius, real speed , real acc, real height, real timedelay, string mfx, string hfx, player owner, attacktype at, damagetype dt, boolean random returns nothing
        local Meteor dat = Meteor.create()
        //These loops is to prevent fatal error due to unit creation outside of map bounds
        //I separated it so that when x is already inside the map bounds it will not be reset anymore 
        loop
            exitwhen (xx == 1)
            set dat.x = x + GetRandomReal(-radius, radius)
            set xx = 1
            if dat.x <= MIN_X or dat.x >= MAX_X then
                set xx = 0
            endif
        endloop
        loop
            exitwhen (yy == 1)
            set dat.y = y + GetRandomReal(-radius, radius)
            set yy = 1
            if dat.y <= MIN_Y or dat.y >= MAX_Y then
                set yy = 0
            endif
        endloop
        set dat.timedelay = timedelay
        set xx = 0
        set yy = 0
        set dat.caster = caster
        set dat.damage = damage
        set dat.meteor = CreateUnit(owner, MSDUMMY, dat.x, dat.y, GetRandomReal(0, 360))
        call SetUnitScale(dat.meteor, scale, scale, scale)
        set dat.air = false
        set dat.radius = dradius
        set dat.speed = speed
        set dat.mfx = hfx
        set dat.sfx = AddSpecialEffectTarget(mfx, dat.meteor, "origin")
        set dat.at = at
        set dat.dt = dt
        set dat.acc = acc
        set dat.owner = owner
        call UnitAddAbility(dat.meteor, 'Amrf')
        call UnitRemoveAbility(dat.meteor, 'Amrf')
        if random then
            set dat.height = height + GetRandomReal(-height*.1, height*.1)
        else
            set dat.height = height
        endif
        call SetUnitFlyHeight(dat.meteor, dat.height, 0.00)
        set METEORS[TOTAL] = dat
        set TOTAL = TOTAL + 1
        if TOTAL == 1 then
            call TimerStart(MSTIME, TICK, true, function Meteor.MeteorLoop)
        endif
    endfunction
    
    function MSInit takes nothing returns nothing
        set MAX_X = GetRectMaxX(bj_mapInitialPlayableArea)
        set MAX_Y = GetRectMaxY(bj_mapInitialPlayableArea)
        set MIN_X = GetRectMinX(bj_mapInitialPlayableArea)
        set MIN_Y = GetRectMinY(bj_mapInitialPlayableArea)
    endfunction
endlibrary