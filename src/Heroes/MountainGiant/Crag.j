scope Crag initializer init
    /*
     * Description: The Mountain Giant creates rocks which comes out of the earth in a line, 
                    knocking back every unit they hit, damaging enemies and be a barricade to block units for 5 seconds.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A097'
        private constant integer ROCK_ID = 'B005'
        private constant real DAMAGE = 60.0
        private constant real DISTANCE = 850.0
        private constant real DURATION = 5.0
        
        private hashtable hashData = InitHashtable()
        private boolean destCheck
        
        //KNOCK BACK
        private constant integer KB_DISTANCE = 350
        private constant real KB_TIME = 2.00
        private constant string KB_EFFECT = "Abilities\\Spells\\Human\\FlakCannons\\FlakTarget.mdl"
        private constant string KB_ATT_POINT = "origin"       
    endglobals
    
    private struct spelldata
        unit source
        real x
        real y
        real distance
        real face
        real damage
        real xStart
        real yStart
        group damaged
        
        static method create takes unit source, real face, real damage returns spelldata
            local spelldata data = spelldata.allocate()
            set data.source = source
            set data.face = face
            set data.distance = DISTANCE
            set data.damage = damage
            set data.damaged = CreateGroup()
            return data
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .source = null
            call DestroyGroup(.damaged)
            set .damaged = null
        endmethod    
    endstruct

    private struct destr
        destructable des
        
        static method create takes real x, real y returns destr
            local destr datDest = destr.allocate()
            set datDest.des = CreateDestructable(ROCK_ID, x, y, GetRandomReal(0,360), 1, GetRandomInt(1,5))
            return datDest
        endmethod
        
        method onDestroy takes nothing returns nothing
            call RemoveDestructable(.des)
            set .des = null
        endmethod
    endstruct
    
    private function FilterTrue takes nothing returns boolean
        return true
    endfunction

    private function UnitTargetable takes unit source, unit target returns boolean
        return GetWidgetLife(target) >= 0.406 and IsUnitEnemy( target, GetOwningPlayer( source ) ) and not IsUnitType(target, UNIT_TYPE_DEAD) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(target, UNIT_TYPE_MECHANICAL)
    endfunction

    private function destructableCheck takes nothing returns nothing
        if GetDestructableTypeId(GetEnumDestructable()) == 'YTpb' then
            set destCheck = true
        endif
    endfunction

    private function destroy_destr takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local destr datDest = LoadIntegerBJ(1, GetHandleId(t), hashData)
        call KillDestructable(datDest.des)
        call datDest.destroy()
        call ReleaseTimer(t)
        set t = null    
    endfunction

    private function timer_callback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local timer tDestr = NewTimer()
        local spelldata data = LoadIntegerBJ(1, GetHandleId(t), hashData)
        local destr datDest
        local real speed = 70
        local real radius = 150
        local real x
        local real y
        local real d
        local unit u = null
        local real ang
        local unit dummy
        local rect r
        local group gr = NewGroup()
        
        set data.x = data.x+(Cos(data.face*bj_DEGTORAD)*speed)
        set data.y = data.y+(Sin(data.face*bj_DEGTORAD)*speed)
        set datDest = destr.create(data.x,data.y)
        
        set r = Rect(data.x-65,data.y-65,data.x+65,data.y+65)
        set destCheck = false
        call EnumDestructablesInRect(r, null, function destructableCheck)
            
        call GroupEnumUnitsInRange(gr,data.x,data.y,radius,Condition(function FilterTrue))
        loop
            set u = FirstOfGroup(gr)
            exitwhen u == null
            call GroupRemoveUnit(gr,u)
            
            if GetUnitState(u,UNIT_STATE_LIFE)>0 and u != data.source then
                set x = GetUnitX(u)-data.xStart
                set y = GetUnitY(u)-data.yStart
                set d = SquareRoot(x*x+y*y)
                set x = data.xStart+(Cos(data.face*bj_DEGTORAD)*d)
                set y = data.yStart+(Sin(data.face*bj_DEGTORAD)*d)
                set ang = bj_RADTODEG*Atan2(GetUnitY(u)-y,GetUnitX(u)-x)
                call Knockback.create(data.source, u, KB_DISTANCE, KB_TIME, ang, 0, KB_EFFECT, KB_ATT_POINT)
                    
            endif
            if UnitTargetable(data.source,u) and not(IsUnitInGroup(u,data.damaged)) then
                call DamageUnit(data.source, u, data.damage, true)
                call GroupAddUnit(data.damaged,u)
            endif
        endloop
            
        call SaveIntegerBJ(datDest,1,GetHandleId(tDestr),hashData)
        call TimerStart(tDestr, DURATION, false, function destroy_destr)
            
        if data.distance<=0 then //or destCheck then
            call data.destroy()
            call ReleaseTimer(t)
        else
            set data.distance=data.distance-speed
            call TimerStart(t, 0.03, false, function timer_callback)
        endif
        
        call ReleaseGroup(gr)
        set gr = null
        set dummy = null
        set t = null
        call RemoveRect(r)
        set r = null
    endfunction

    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId()== SPELL_ID
    endfunction
        
    private function Actions takes nothing returns nothing
        local unit source = GetTriggerUnit()
        local real sourceX = GetUnitX(source)
        local real sourceY = GetUnitY(source)
        local timer t = NewTimer()
        local spelldata data
        set data = data.create(source,bj_RADTODEG*Atan2(GetSpellTargetY()-GetUnitY(source),GetSpellTargetX()-GetUnitX(source)), GetUnitAbilityLevel(source, SPELL_ID)*DAMAGE)
        set data.x = sourceX
        set data.y = sourceY
        set data.xStart = sourceX
        set data.yStart = sourceY
        call SaveIntegerBJ(data, 1, GetHandleId(t), hashData)
        call TimerStart(t, 0.03, false, function timer_callback)

        set source = null
        set t = null
    endfunction
        
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t,Condition(function Conditions))
        call TriggerAddAction(t,function Actions)
        call Preload(KB_EFFECT)
        set t = null
    endfunction

endscope