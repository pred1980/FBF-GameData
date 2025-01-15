scope ScaledShell initializer init
    /*
     * Description: The Turtles shell is full of scales, reducing the damage of attacks from behind and 
                    reflects some part of that damage back to the attacker.
     * Changelog: 
     *      10.01.2014: Abgleich mit OE und der Exceltabelle
	 *		16.04.2015: Integrated SpellHelper for filtering and damging
						Code Refactoring
     */
    globals
        private constant integer SPELL_ID = 'A086'
        private constant real MAX_REFLECTION_ANGLE = 75.00
        private constant string DAMAGE_REFLECTION_TARGET_EFFECT = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
        private constant string DAMAGE_REFLECTION_TARGET_EFFECT_ATTACH = "origin"
        private constant string DAMAGE_REFLECTION_CASTER_EFFECT = "Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl"
        private constant string DAMAGE_REFLECTION_CASTER_EFFECT_ATTACH = "chest"
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
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
    
    private function checkUnit takes unit target, unit caster returns boolean
		return  SpellHelper.isValidEnemy(target, caster) and /*
		*/		SpellHelper.isMelee(target)
    endfunction
    
    private function isBackAttack takes unit caster, unit target returns boolean
        local real a1 = 0.00 
        local real a2 = 0.00 
        local real ang = 0.00
        
        if checkUnit(target, caster) then
            set a1 = GetUnitFacing(target) * bj_DEGTORAD
            set a2 = Atan2(GetUnitY(target) - GetUnitY(caster), GetUnitX(target) - GetUnitX(caster))
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

    private function onAttack takes unit caster, unit target, real damage returns nothing
            local integer level = GetUnitAbilityLevel(target, SPELL_ID)
            local real dmgRed = damage * DAMAGE_REDUCTION_FACTOR[level]
            
			//Damage Reflection
            call DestroyEffect(AddSpecialEffectTarget(DAMAGE_REFLECTION_CASTER_EFFECT, caster, DAMAGE_REFLECTION_CASTER_EFFECT_ATTACH))
            set DamageType = PHYSICAL
			call SpellHelper.damageTarget(target, caster, damage * DAMAGE_REFLECTION_FACTOR[level], true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
			
			//Damage Reduction
			call DestroyEffect(AddSpecialEffectTarget(DAMAGE_REFLECTION_TARGET_EFFECT, caster, DAMAGE_REFLECTION_TARGET_EFFECT_ATTACH))
            call SetUnitState(caster, UNIT_STATE_LIFE, GetUnitState(caster, UNIT_STATE_LIFE) + dmgRed)
        endfunction
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if (GetUnitAbilityLevel(damagedUnit, SPELL_ID) > 0 and /*
		*/	isBackAttack(damageSource, damagedUnit) and /*
		*/	DamageType == PHYSICAL ) then
            call onAttack(damageSource, damagedUnit, damage)
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call MainSetup()
        call Preload(DAMAGE_REFLECTION_TARGET_EFFECT)
        call Preload(DAMAGE_REFLECTION_CASTER_EFFECT)
    endfunction

endscope