scope ArcaneSwap initializer init
    /*
     * Description: Gundagar restores mana to an enemy but damages his health for the same amount. 
                    The target is damaged by half the spell cost if it has no mana.
     * Changelog: 
     *     12.11.2013: Abgleich mit OE und der Exceltabelle
	 *     19.03.2015: Optimized Spell-Event-Handling (Conditions/Actions) + Immunity Check
	 *     04.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for damaging
     */
    globals
        private constant integer SPELL_ID = 'A06N'
        private constant string EFFECT_1 = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        private constant string EFFECT_2 = "Abilities\\Spells\\Items\\AIvi\\AIviTarget.mdl"
        private constant string ATT_POINT = "overhead"
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_SONIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
        // Falls das Target kein Mana hat, wird die Hälfte vom Mana, den der Spell hat als Damage wenigstens ausgeteilt
        private real array damage 
    endglobals
    
    private function MainSetup takes nothing returns nothing
        // Note: This is the half of the used mana to cast spell (check OE!!!)
		set damage[1] = 60
        set damage[2] = 75
        set damage[3] = 90
        set damage[4] = 105
        set damage[5] = 120
    endfunction
    
    private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local unit target = GetSpellTargetUnit()
		local integer level = 0
		local real amount = 0.00
		
		set level = GetUnitAbilityLevel(caster, SPELL_ID)
		set DamageType = SPELL
		if (GetUnitStateSwap(UNIT_STATE_MAX_MANA, target) > 0.00) then
			set amount = RMinBJ(I2R(level) * 100, GetUnitState(target, UNIT_STATE_MAX_MANA) - GetUnitState(target, UNIT_STATE_MANA))
			call SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target,UNIT_STATE_MANA) + amount)
			call SpellHelper.damageTarget(caster, target, amount, false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
		else
			call SpellHelper.damageTarget(caster, target, damage[level], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
		endif
		call DestroyEffect(AddSpecialEffectTarget(EFFECT_1, target, ATT_POINT))
		call DestroyEffect(AddSpecialEffectTarget(EFFECT_2, target, ATT_POINT))
        
		set caster = null
		set target = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
		call MainSetup()
        call Preload(EFFECT_1)
        call Preload(EFFECT_2)
    endfunction

endscope