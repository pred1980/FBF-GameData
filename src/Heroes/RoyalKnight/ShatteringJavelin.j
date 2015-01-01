scope ShatteringJavelin initializer Init
    /*
     * Description: The Royal Knight throws a Javelin that deals piercing damage and shatters on impact. 
                    The shattered fragmets hit the units behind the target.
     * Last Update: 09.12.2013
     * Changelog: 
     *     09.12.2013: Abgleich mit OE und der Exceltabelle
     *     10.12.2013: Umbau auf XE Missile System abgeschlossen
     */
    globals
        private constant integer SPELL_ID = 'A08A'
        private constant integer ANIMAL_WAR_TRAINING_ID = 'A081'
        private constant string LANCE_MODEL = "Abilities\\Weapons\\Banditmissile\\Banditmissile.mdl"
        private constant string FRAGMENT_MODEL = "Abilities\\Weapons\\Axe\\AxeMissile.mdl"
        private constant real MISSILE_SCALE = 1.0
        private constant real MISSILE_SPEED = 600.0
        private constant real ARC_MIN = 0.
        private constant real ARC_MAX = 0.1
        private constant real Z_START = 0.
        private constant real Z_END = 0.
        private constant real START_DAMAGE = 0
        private constant real DAMAGE_INCREASE = 100
        private constant real FRAGMENT_START_DAMAGE = 50
        private constant real FRAGMENT_DAMAGE_INCREASE = 25
        private constant integer FRAGMENT_START_NUMBER = 4
        private constant integer FRAGMENT_INCREASE_NUMBER = 1
        private constant integer FRAGMENT_RADIUS = 400
        
        private xedamage damageOptions
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
        set d.dtype = DAMAGE_TYPE_FIRE   
        set d.atype = ATTACK_TYPE_NORMAL 
        
        set d.exception = UNIT_TYPE_STRUCTURE 
    endfunction
    
    struct Fragment extends xehomingmissile
        unit caster //Royal Knight
        unit target  //Fragmentziel
        integer level = 0
        
        //caster: Royal Knight
        //fragTarget: Ziel hinter dem ersten Ziel, was getroffen wurde
        //target: erstes Ziel
        static method create takes unit caster, unit fragTarget, unit target, integer level returns thistype
            local thistype this = thistype.allocate(GetWidgetX(target), GetWidgetY(target), Z_START, fragTarget, Z_END)
            
            set this.fxpath = FRAGMENT_MODEL
            set this.scale = MISSILE_SCALE
            set this.caster = caster
            set this.target = fragTarget
            set this.level = level
            
            call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
            
            return this
        endmethod
        
        method loopControl takes nothing returns nothing
            if not IsTerrainWalkable(this.x, this.y) then
                call this.terminate()
            endif
        endmethod
        
        method onHit takes nothing returns nothing
            if (damageOptions.allowedTarget(this.caster, this.target )) then
                set DamageType = SPELL
                call UnitDamageTarget(this.caster, this.target, FRAGMENT_START_DAMAGE + FRAGMENT_DAMAGE_INCREASE * this.level, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                debug call BJDebugMsg("onFragment Damage: " + R2S(FRAGMENT_START_DAMAGE + FRAGMENT_DAMAGE_INCREASE * this.level))
            endif
            
            call this.terminate()
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .caster = null
            set .target = null
        endmethod
        
    endstruct
    
    private struct ShatteringJavelin extends xehomingmissile
        unit caster
        unit target
        group targets
        integer level
        static thistype tempthis
        
        static method create takes unit caster, unit target, integer level returns thistype
            local thistype this = thistype.allocate(GetWidgetX(caster), GetWidgetY(caster), Z_START, target, Z_END)
            local timer t = NewTimer()
            
            set this.fxpath = LANCE_MODEL
            set this.scale = MISSILE_SCALE
            set this.caster = caster
            set this.target = target
            set this.level = level
            set .targets = NewGroup()
            set this.tempthis = this
            
            call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
            
            return this
        endmethod
        
        method loopControl takes nothing returns nothing
            if not IsTerrainWalkable(this.x, this.y) then
                call this.terminate()
            endif
        endmethod
        
        method onHit takes nothing returns nothing
            local unit u
            local integer i = FRAGMENT_START_NUMBER + FRAGMENT_INCREASE_NUMBER * GetUnitAbilityLevel(this.caster, ANIMAL_WAR_TRAINING_ID)
            local real x = GetUnitX(this.target)
            local real y = GetUnitY(this.target)
            local Fragment f = 0
            
            if (damageOptions.allowedTarget(this.caster, this.target )) then
                set DamageType = SPELL
                call UnitDamageTarget(this.caster, this.target, START_DAMAGE + DAMAGE_INCREASE * this.level, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                debug call BJDebugMsg("onShatteringJavelin Damage: " + R2S(START_DAMAGE + DAMAGE_INCREASE * this.level))
            endif
            
            loop
                set i = i - 1
                set u = GetClosestUnitInRange(1.5 * x-0.5 * GetUnitX(this.caster), 1.5 * y-0.5 * GetUnitY(this.caster), FRAGMENT_RADIUS, Condition(function thistype.filterCallback))
                if u != null then
                    call GroupAddUnit(this.targets, u)
                    set f = Fragment.create(this.caster, u, this.target, this.level)
                endif
                exitwhen i == 0
            endloop
            
            call this.terminate()
        endmethod
        
        static method filterCallback takes nothing returns boolean
            return GetFilterUnit() != .tempthis.target and not /*
            */     IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) and not /*
            */     IsUnitDead(GetFilterUnit()) and not /*
            */     IsUnitInGroup(GetFilterUnit(), .tempthis.targets) and not /*
            */     IsUnitAlly(GetFilterUnit(), GetOwningPlayer(.tempthis.caster))
        endmethod
       
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(.targets)
            set .targets = null
            set .caster = null
            set .target = null
        endmethod
    endstruct
    
    private function Conditions takes nothing returns boolean
        return (GetSpellAbilityId() == SPELL_ID)
    endfunction

    private function Actions takes nothing returns nothing
        local ShatteringJavelin sj = 0
        local unit caster = GetTriggerUnit()
        local unit target = GetSpellTargetUnit()
        local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
    
        set sj = ShatteringJavelin.create(caster, target, level)
        
        set caster = null
        set target = null
    endfunction
   
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()

        set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)

        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        set t = null
        
        call XE_PreloadAbility(ANIMAL_WAR_TRAINING_ID)
        call Preload(LANCE_MODEL)
        call Preload(FRAGMENT_MODEL)
    endfunction
endscope
