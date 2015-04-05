scope ManaSteal initializer init
    /*
     * Description: Everytime Gundagar attacks a unit, he has a 25% chance to absorbs its mana. 
                    But he cannot absorb more mana than what the target has.
     * Last Update: 14.11.2013
     * Changelog: 
     *      14.11.2013: Abgleich mit OE und der Exceltabelle
	 *		04.04.2015: Integrated SpellHelper for filtering
						Code-Refactoring
     */
    globals
        private constant integer SPELL_ID = 'A06R'
        private constant integer BUFF_ID = 'B010'
        private constant string EFFECT = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl"
        private constant string ATT_POINT = "overhead"
        private constant integer MULTIPLIER = 20
        private constant integer CHANCE = 25
    endglobals
    
	private function Actions takes unit attacker, unit target returns nothing
		local integer level = GetUnitAbilityLevel(attacker, SPELL_ID)
		local real mana = GetUnitState(target, UNIT_STATE_MANA)
		local real amount = 0.00
		
		if (level * MULTIPLIER) < mana then
			set amount = I2R(level) * MULTIPLIER
		else
			set amount = mana
		endif
		
		call SetUnitState(attacker, UNIT_STATE_MANA, GetUnitState(attacker, UNIT_STATE_MANA) + amount)
		call SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) - (level * MULTIPLIER ))
		call DestroyEffect(AddSpecialEffectTarget(EFFECT, target, ATT_POINT))
	endfunction
    
    private function Conditions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if ( GetUnitAbilityLevel(damageSource, BUFF_ID) > 0 and /*
        */   SpellHelper.isValidEnemy(damagedUnit,damageSource) and /*
        */   DamageType == PHYSICAL and /*
        */   GetRandomInt(1, 100) <= CHANCE ) and /*
        */   GetUnitStateSwap(UNIT_STATE_MAX_MANA, damagedUnit) > 0 then
                 call Actions(damageSource, damagedUnit)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Conditions )
        call Preload(EFFECT)
    endfunction

endscope