library CheckImmunity uses SimError, MiscFunctions, RestoreMana

	globals
		private constant string ERROR_MSG = "This unit is immune to magic."
    endglobals
	
	function CheckImmunity takes integer spellId, unit caster, unit target, real spellX, real spellY returns boolean
		if (IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)) then
			//Return Mana Costs
			call RunManaCost(spellId, caster, target, spellX, spellY)
			//Show Error Message
			call SimError(GetOwningPlayer(caster), ERROR_MSG)
			//Reset Cooldown of the Ability
			call UnitResetSingleCooldown(caster, spellId)
			return true
		else
			return false
		endif
	endfunction

endlibrary