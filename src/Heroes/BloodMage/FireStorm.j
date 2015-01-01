scope FireStorm initializer Init
    /*
     * Description: Joos Ignos proves hes a master of magic by summoning a raging Storm of fire that damages his enemies. 
                    The Storm lasts for 6 seconds.
     * Last Update: 05.01.2014
     * Changelog: 
     *     05.01.2014: Abgleich mit OE und der Exceltabelle
	 *
	 * To-Do: TriggerSleepAction ausbauen!
     */
    globals
        private constant integer SPELL_ID = 'A096'
        private constant integer DUMMY_ID = 'e010'
        private constant real InitDamage = 100
        private constant real LvlInc = 50
        private constant real MaxDist = 500
        private constant real MinDist = 100
        private constant real MaxHeight = 600
        private constant real UnitTime = 6
        private constant real DetectDist = 100
        private constant string ModelPath = "Models\\SunfireMissile.mdx"
        private constant string Effect = "Models\\FireBall.mdx"
        private constant string BirthEffect = "Models\\SunfireMissile.mdx"
            
        private integer counter = 0
        private timer TIM = CreateTimer()
        private Firedata array Data
    endglobals

    struct Firedata
        unit caster = null
        unit entity = null
        real a      = 0
        real x      = 0
        real y      = 0
        real z      = 0
        real d      = 0
        real xC     = 0
        real yC     = 0
        effect s    = null
        
        static method create takes unit u, real x, real y returns Firedata
            local Firedata dat = Firedata.allocate()
            
            set dat.caster = u
            set dat.xC = x
            set dat.yC = y
            set dat.d = GetRandomReal(MinDist, MaxDist)
            set dat.a = GetRandomReal(0, 360)
            set dat.x = x + dat.d * Cos(dat.a * bj_DEGTORAD)
            set dat.y = y + dat.d * Sin(dat.a * bj_DEGTORAD)
            set dat.entity = CreateUnit(GetOwningPlayer(u), DUMMY_ID, dat.x, dat.y, dat.a)
            set dat.s = AddSpecialEffectTarget(ModelPath, dat.entity, "origin")
            
            call DestroyEffect(AddSpecialEffect(BirthEffect, dat.x, dat.y))
            call UnitApplyTimedLife(dat.entity, 'BFLT', UnitTime)
            
            if counter == 0 then
                call TimerStart(TIM, 0.03, true, function thistype.onLoop)
            endif
            
            set counter = counter + 1
            set Data[counter -1] = dat
            
            return dat
        endmethod
        
        static method damageArea takes unit u, real x, real y returns nothing
            local group g = CreateGroup()
            local unit n = null  
            local real d = (GetUnitAbilityLevel(u, SPELL_ID) * LvlInc) + InitDamage
        
            call GroupEnumUnitsInRange(g, x, y, DetectDist, null)
        
            loop
                set n = FirstOfGroup(g)
                exitwhen n == null
                if IsUnitEnemy(n, GetOwningPlayer(u)) == true then
                    set DamageType = SPELL
                    call UnitDamageTarget(u, n, d, true, false, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_NORMAL, null)
                    call DestroyEffect(AddSpecialEffectTarget(Effect, n, "chest"))
                endif
                call GroupRemoveUnit(g, n)
            endloop
            call DestroyGroup(g)
            set g = null
        endmethod
        
        static method detectUnit takes unit u, real x, real y returns integer
            local group g = CreateGroup()
            local integer i = 0
            local unit n = null   
        
            call GroupEnumUnitsInRange(g, x, y, DetectDist, null)
            loop
                set n = FirstOfGroup(g)
                exitwhen n == null
                if IsUnitEnemy(n, GetOwningPlayer(u)) == true then
                    if GetUnitState(n, UNIT_STATE_LIFE) > 0 then
                        call DestroyGroup(g)
                        set g = null
                        set n = null
                        return 0
                    endif
                endif
                call GroupRemoveUnit(g, n)
                
                call DestroyGroup(g)
                set n = null
                set g = null
        
            endloop
        
            call DestroyGroup(g)
            set g = null
        
            return 1
        
        endmethod
        
        static method onLoop takes nothing returns nothing
            local Firedata dat
            local integer i = 0
            
            loop
                exitwhen i >= counter
                set dat = Data[i]
                
                //This is the onLoop actions
                set dat.a = dat.a + 5
                set dat.x = dat.xC + dat.d * Cos(dat.a * bj_DEGTORAD)
                set dat.y = dat.yC + dat.d * Sin(dat.a * bj_DEGTORAD)
                
                call SetUnitX(dat.entity, dat.x)
                call SetUnitY(dat.entity, dat.y)
                
                set dat.z = dat.z + 20
                call SetUnitFlyHeight(dat.entity, dat.z, 40)
                
                if Firedata.detectUnit(dat.entity, dat.x, dat.y) == 0 then
                    call KillUnit(dat.entity)
                    call Firedata.damageArea(dat.caster, dat.x, dat.y)
                endif
                
                //End of onLoop actions
                if GetWidgetLife(dat.entity) < 0.405 then
                    set Data[i] = Data[counter - 1]
                    set counter = counter - 1
                    call DestroyEffect(AddSpecialEffectTarget(Effect, dat.entity, "origin"))
                    
                    call dat.destroy()
                endif
                
                set i = i + 1
            endloop
            
            if counter == 0 then
                call PauseTimer(TIM)
            endif
        
        endmethod
        
        method onDestroy takes nothing returns nothing
            local unit u = .entity
            call DestroyEffect(.s)
            call TriggerSleepAction(.1)
            call RemoveUnit(u)
            
            set u = null
        endmethod

    endstruct

    private function FireStormConditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function FireStormActions takes nothing returns nothing
        local integer i = 0
        local unit u = GetTriggerUnit()
        local real x = GetSpellTargetX()
        local real y = GetSpellTargetY()
        
        loop
            exitwhen i == 20
            set i = i + 1
            call TriggerSleepAction(.1)
            call Firedata.create(u, x, y)
        endloop
        
        set u = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger MainTrigger = CreateTrigger()

        call TriggerRegisterAnyUnitEventBJ( MainTrigger, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddCondition( MainTrigger, Condition( function FireStormConditions ) )
        call TriggerAddAction( MainTrigger, function FireStormActions )

        call Preload(ModelPath)
        call Preload(Effect)
        set MainTrigger = null
    endfunction
    
endscope