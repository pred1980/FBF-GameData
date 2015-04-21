scope Barrage initializer Init
    /*
     * Description: Venefica shoots a barrage of unwordly missiles at a target area. 
                    These deal small area damage when they collide with a unit.
     * Last Update: 29.10.2013
     * Changelog: 
     *     29.10.2013: Abgleich mit OE und der Exceltabelle
	 *     21.03.2015: Code refactoring
	 *     18.04.2015: Integrated RegisterPlayerUnitEvent
     *
	 * Note:
	 *     Damgage pro Missile:
	 *     Level 1: 200
	 *	   Level 2: 320
	 *	   Level 3: 440
     */ 
    globals
        private constant integer SPELL_ID = 'A04Y'
        //effect that appears when a missile collides with a unit
        private constant string boomEffect = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
        private constant string missile = "Models\\PurpleZigguratMissile.mdl"
        //the missiles' expiration time
        private constant real expTime = 2.0
        //damage per missile
        private constant real damage = 80.0
        //damage increment per level
        private constant real damageInc = 120.0
        //radius of the explosion
        private constant real radius = 300.0
        //timer period between each missile
        private constant real mTimer = 0.05
        //maximum number of missiles
        private constant integer maxM = 30
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals

    private function setupDamageOptions takes xedamage d returns nothing
        //setup of the damage options
		set d.atype = ATTACK_TYPE
        set d.dtype = DAMAGE_TYPE    
		set d.wtype = WEAPON_TYPE
        
        set d.damageEnemies = true     //hits enemies
        set d.damageAllies  = false    //doesn't hit allies
        set d.damageNeutral = true     //hits neutral units
        set d.damageSelf    = false    //doesn't hit self
        set d.required = UNIT_TYPE_GROUND   //doesn't hit flying units
        set d.exception = UNIT_TYPE_STRUCTURE    //doesn't hit structures
    endfunction

    globals
        private xedamage damageOptions
    endglobals
    
    private struct Data
        unit caster
        unit target
        integer intg
        
        static method create takes unit c, unit t, integer i returns Data
            local Data D = Data.allocate()
            set D.caster = c
            set D.target = t
            set D.intg = i
            return D
        endmethod
        
        method onDestroy takes nothing returns nothing
            set this.caster = null
            set this.target = null
        endmethod
        
    endstruct
    
    private struct Missile extends xecollider
        unit caster
        real dmg
        
        method onUnitHit takes unit hitunit returns nothing
            if (damageOptions.allowedTarget( this.caster, hitunit)) then
                call DestroyEffect(AddSpecialEffectTarget(boomEffect, hitunit, "origin"))
                set DamageType = SPELL
                call damageOptions.damageAOE(this.caster, GetUnitX(hitunit), GetUnitY(hitunit), radius, this.dmg)
                call this.terminate()
            endif
        endmethod
        
        method onDestroy takes nothing returns nothing
            set this.caster = null
        endmethod
        
    endstruct
            
    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction
    
    private function Loop takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local Data D = GetTimerData(t)
        local Missile m
        local real finalDmg = damage + damageInc*(I2R(GetUnitAbilityLevel(D.caster, SPELL_ID) - 1))
        if D.intg < maxM then
            set m = Missile.create(GetUnitX(D.caster), GetUnitY(D.caster), D.intg*(2*bj_PI)/maxM)
            set m.fxpath = missile
            set m.speed = 500.0
            set m.acceleration = 1000.0
            set m.maxSpeed = 1500.0
            set m.z = 30.0
            set m.angleSpeed = 3.0
            set m.targetUnit = D.target
            set m.expirationTime = expTime
            set m.caster = D.caster
            set m.dmg = finalDmg
            set D.intg = D.intg + 1
        else
            call D.destroy()
            call ReleaseTimer(t)
        endif
        set t = null    
    endfunction
    
    private function Actions takes nothing returns nothing
        local integer i = 0
        local unit hero = GetTriggerUnit()
        local location tarLoc = GetSpellTargetLoc()
        local unit tarUnit = CreateUnitAtLoc(GetOwningPlayer(hero), XE_DUMMY_UNITID, tarLoc, bj_UNIT_FACING)
        local Data D = Data.create(hero, tarUnit, i)
        local timer t = NewTimer()
        
		call SetTimerData(t, integer(D))
        call TimerStart(t, mTimer, true, function Loop)
        call KillUnit(tarUnit)
        
		set t = null
        set hero = null
        set tarLoc = null
        set tarUnit = null
    endfunction
    
    private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		
        set damageOptions=xedamage.create()
        call setupDamageOptions(damageOptions)
		
        call Preload(boomEffect)
        call Preload(missile)
    endfunction
    
endscope