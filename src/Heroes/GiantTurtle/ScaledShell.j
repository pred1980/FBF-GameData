scope ScaledShell initializer init
    /*
     * Description: The Turtles shell is full of scales, reducing the damage of attacks from behind and 
                    reflects some part of that damage back to the attacker.
     * Last Update: 10.01.2014
     * Changelog: 
     *     10.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A086'
        private constant real MAX_REFLECTION_ANGLE = 75.00
        private constant string DAMAGE_REFLECTION_TARGET_EFFECT = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
        private constant string DAMAGE_REFLECTION_TARGET_EFFECT_ATTACH = "origin"
        private constant string DAMAGE_REFLECTION_CASTER_EFFECT = "Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl"
        private constant string DAMAGE_REFLECTION_CASTER_EFFECT_ATTACH = "chest"
        private constant damagetype DAMAGE_REFLECTION_DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant attacktype DAMAGE_REFLECTION_ATTACK_TYPE = ATTACK_TYPE_CHAOS
        
        private real array DAMAGE_REFLECTION_FACTOR
        private real array DAMAGE_REDUCTION_FACTOR
    endglobals

    private function MainSetup takes nothing returns nothing
        set DAMAGE_REFLECTION_FACTOR[1] = 0.200
        set DAMAGE_REFLECTION_FACTOR[2] = 0.275
        set DAMAGE_REFLECTION_FACTOR[3] = 0.350
        set DAMAGE_REFLECTION_FACTOR[4] = 0.425
        set DAMAGE_REFLECTION_FACTOR[5] = 0.500
        
        set DAMAGE_REDUCTION_FACTOR[1] = 0.25
        set DAMAGE_REDUCTION_FACTOR[2] = 0.35
        set DAMAGE_REDUCTION_FACTOR[3] = 0.45
        set DAMAGE_REDUCTION_FACTOR[4] = 0.55
        set DAMAGE_REDUCTION_FACTOR[5] = 0.65
    endfunction
    
    private function checkUnit takes unit owner, unit source returns boolean
        return IsUnitEnemy(source, GetOwningPlayer(owner)) and not IsUnitType(source, UNIT_TYPE_MECHANICAL) and IsUnitType(source, UNIT_TYPE_MELEE_ATTACKER) and not IsUnitType(source, UNIT_TYPE_FLYING) and not IsUnitDead(owner)
    endfunction
    
    private function isBackAttack takes unit source, unit target returns boolean
        local real a1 = 0.00 
        local real a2 = 0.00 
        local real ang = 0.00
        
        if checkUnit(target, source) then
            set a1 = GetUnitFacing(target) * bj_DEGTORAD
            set a2 = Atan2(GetUnitY(target) - GetUnitY(source), GetUnitX(target) - GetUnitX(source))
            set ang = a2 - a1

            if ang > bj_PI then
                set ang = - 2 * bj_PI + ang
            elseif ang < - bj_PI then
                set ang = 2 * bj_PI + ang
            endif
            
            if (ang <= MAX_REFLECTION_ANGLE * bj_DEGTORAD) and (ang >= -MAX_REFLECTION_ANGLE * bj_DEGTORAD) then
                return true
            endif
        endif
        return false
    endfunction

    private struct ScaledShell
        unit target
        integer level = 0
        real dmgRed = 0.00
        real dmgRef = 0.00
        timer t
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
            set .t = null
            set .target = null
        endmethod
        
        static method onDamageReduction takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call DestroyEffect(AddSpecialEffectTarget(DAMAGE_REFLECTION_TARGET_EFFECT, this.target, DAMAGE_REFLECTION_TARGET_EFFECT_ATTACH))
            call SetUnitState(this.target, UNIT_STATE_LIFE, GetUnitState(this.target, UNIT_STATE_LIFE) + .dmgRed)
            call this.destroy()
        endmethod
        
        static method create takes unit attacker, unit target, real damage returns thistype
            local thistype this = thistype.allocate()
            
            set .target = target
            set .level = GetUnitAbilityLevel(target, SPELL_ID)
            
            //Damage Reduction
            set .dmgRed = damage * DAMAGE_REDUCTION_FACTOR[.level]
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, 0.1, false, function thistype.onDamageReduction)
            
            //Damage Reflection
            call DestroyEffect(AddSpecialEffectTarget(DAMAGE_REFLECTION_CASTER_EFFECT, attacker, DAMAGE_REFLECTION_CASTER_EFFECT_ATTACH))
            set DamageType = SPELL
            call UnitDamageTarget(target, attacker, damage * DAMAGE_REFLECTION_FACTOR[.level], false, false, DAMAGE_REFLECTION_ATTACK_TYPE, DAMAGE_REFLECTION_DAMAGE_TYPE, WEAPON_TYPE_WHOKNOWS)
            
            return this
        endmethod

    endstruct
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if ( GetUnitAbilityLevel(damagedUnit, SPELL_ID) > 0 and isBackAttack(damageSource, damagedUnit) and DamageType == 0 ) then
            call ScaledShell.create(damageSource, damagedUnit, damage)
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call MainSetup()
        call Preload(DAMAGE_REFLECTION_TARGET_EFFECT)
        call Preload(DAMAGE_REFLECTION_CASTER_EFFECT)
    endfunction

endscope