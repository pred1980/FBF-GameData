scope WormSystem initializer onInit
	/*
     * Changelog: 
     *  28.03.2014: Spawn Interval von 10s-20s auf 10s-30s erhoeht
     *              Schaden pro Runde um 10% reduziert (von 75 auf 67)
     *	15.09.2015: Changed damage from (200 + (actualRound*67)) to (actualRound * 200)
					Increased the worm count from 4 to 5
     *
     */
    
    globals
        private constant integer WORM_DUMMY = 'h001' // The worm dummy raw code
        private constant integer ABILITY_ID = 'A0AI' // The raw code of the spell
        private constant integer CIRCLE_DIST = 25 // How far apart each effect created in the circle is (increase if lag)
        private constant integer LOCUST_ID = 'Aloc' 
        private constant real WAIT_TIME = 3.5 // The worm timer interval
        private constant real WORM_DISTANCE = 250 // How far away from the target the worm spawns
        private constant real CIRLCE_INT = 0.05 // The timer interval for the circle effect
        private constant string UPRISE_ANIM = "Morph Alternate" // The animation to while when the worm rises
        private constant string DIG_ANIM = "Morph" // The animation to while when the worm rises
        private constant string CIRCLE_FX = "Abilities\\Spells\\Undead\\Impale\\ImpaleMissTarget.mdl" // The fx on cast
        private constant string BLOOD_FX = "Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl" // The effect when the worm impales the enemy
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS // The weapon type
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL // The damage type
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL // The attack type
        
        private constant integer WORM_COUNT = 5
        private constant real SPAWN_INTERVAL_MIN = 10.0
        private constant real SPAWN_INTERVAL_MAX = 30.0
        private constant integer ATTACK_COUNT = 1
        private constant real KILL_FACTOR = 75.00 // <=75% HP
        
        //Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = 3.5
    endglobals
    
    private function GetDamage takes integer round returns real
        return I2R(round * 200)
    endfunction
    
    private constant function GetAOE takes nothing returns real
        return 400.00
    endfunction
    
    private constant function AttackCount takes nothing returns integer
        return ATTACK_COUNT
    endfunction
    
    //==============================
    //  Do not edit past this line
    //==============================
    
    globals
        private group GLOBAL_GROUP = CreateGroup()
    endglobals
    
    native UnitAlive takes unit id returns boolean
    
    private struct DuneWorm
        
        unit worm
        unit target = null
        unit last
        real wormX
        real wormY
        real aoe
        real dmg
        player p
        integer max
        integer tick = 0
        boolean b = false
        string nextAnim = UPRISE_ANIM
        static thistype temp
        
        static method PickUnit takes nothing returns boolean
            return IsPlayerEnemy(GetOwningPlayer(GetFilterUnit()), .temp.p) and UnitAlive(GetFilterUnit())
        endmethod
        
        method onDestroy takes nothing returns nothing
            set this.worm   = null
            set this.target = null
            set this.last   = null
        endmethod
        
        static method callback takes nothing returns nothing
            local real x = 0
            local real y = 0
            local real f = 0.00
            local timer t = GetExpiredTimer()
            local thistype this = GetTimerData(t)
            
            if this.tick >= this.max then
                call RemoveUnit(this.worm)
                call ReleaseTimer(t)
                call this.destroy()
                return
            endif
            
            if this.target == null then
                set .temp.p = this.p
                call GroupEnumUnitsInRange(GLOBAL_GROUP, this.wormX, this.wormY, this.aoe, Filter(function thistype.PickUnit))
                call ForGroup(GLOBAL_GROUP, function GroupPickRandomUnitEnum) // The BJ is completely fine.
                set this.target = FirstOfGroup(GLOBAL_GROUP)
                if not UnitAlive(this.target) or this.target == null then
                    set this.target = null
                    set this.last   = null
                    set this.tick   = this.tick + 1
                    return
                endif
                set this.last = this.target
            endif
            
            if this.target != null then
                if this.nextAnim == UPRISE_ANIM then
                    set f = GetRandomReal(0, 360)
                    set x = GetUnitX(this.target) + WORM_DISTANCE * Cos(f* bj_DEGTORAD)
                    set y = GetUnitY(this.target) + WORM_DISTANCE * Sin(f* bj_DEGTORAD)
                    
                    call SetUnitFacing(this.worm, f + 180)
                    call Stun_UnitEx(this.target, STUN_DURATION, true, STUN_EFFECT, STUN_ATT_POINT)
                    
                    call SetUnitX(this.worm, x)
                    call SetUnitY(this.worm, y)
                else
                    if not IsUnitType(this.last, UNIT_TYPE_HERO) then
                        //no hero - check hp
                        if (GetUnitLifePercent(this.last) <= KILL_FACTOR) then
                            call SetUnitExploded(this.last, true)
                            call KillUnit(this.last)
                        endif
                    endif
                    //Damage Unit if is not eaten ^^
                    if not IsUnitDead(this.last) then
                        set DamageType = PHYSICAL
                        call UnitDamageTarget(this.worm, this.last, this.dmg, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                        call DestroyEffect(AddSpecialEffectTarget(BLOOD_FX, this.target, "origin"))
                    endif
                endif
                
                call SetUnitAnimation(this.worm, this.nextAnim)
                
                set x = WAIT_TIME
                
                if this.nextAnim == UPRISE_ANIM then
                    set this.nextAnim = DIG_ANIM
                    set x = WAIT_TIME - 1
                elseif this.nextAnim == DIG_ANIM then
                    set this.nextAnim = UPRISE_ANIM
                    set this.tick = this.tick + 1
                    set this.target = null
                endif
                
                call PauseTimer(t)
                call TimerStart(t, x, true, function thistype.callback)
                    
            endif
            
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            local timer tmr = NewTimer()
            local real x
            local real y
            local integer i = 0
            
            set .wormX = GetRandomReal(GetRectMinX(gg_rct_WormSpawnArea), GetRectMaxX(gg_rct_WormSpawnArea))
            set .wormY = GetRandomReal(GetRectMinY(gg_rct_WormSpawnArea), GetRectMaxY(gg_rct_WormSpawnArea))
            
            loop
                exitwhen IsTerrainWalkable(.wormX, .wormY)
                set .wormX = GetRandomReal(GetRectMinX(gg_rct_WormSpawnArea), GetRectMaxX(gg_rct_WormSpawnArea))
                set .wormY = GetRandomReal(GetRectMinY(gg_rct_WormSpawnArea), GetRectMaxY(gg_rct_WormSpawnArea))
            endloop
                        
            set .worm = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), WORM_DUMMY, .wormX, .wormY, 0)
            set .aoe = GetAOE()
            set .dmg = GetDamage(RoundSystem.actualRound)
            set .max = AttackCount()
            set .p = GetOwningPlayer(.worm)
            set .temp = this

            loop
                exitwhen i > 360
                set x = .wormX + .aoe * Cos(i*bj_DEGTORAD)
                set y = .wormY + .aoe * Sin(i*bj_DEGTORAD)
                call DestroyEffect(AddSpecialEffect(CIRCLE_FX, x, y))
                set i = i + CIRCLE_DIST
            endloop
            
            call UnitAddAbility(.worm, LOCUST_ID)
            call SetTimerData(tmr, this)
            call TimerStart(tmr, 0, true, function thistype.callback)
            
            return this
        endmethod
        
    endstruct
    
    private function Actions takes nothing returns nothing
        local DuneWorm dw = 0
        local integer i = 0
        
        loop
            exitwhen i == WORM_COUNT
            set dw = DuneWorm.create()
            set i = i + 1
        endloop
    endfunction
    
    //===========================================================================
    private function onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterTimerEventPeriodic(t, GetRandomReal(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX))
        call TriggerAddAction(t, function Actions)
        set t = null
    endfunction
    
endscope