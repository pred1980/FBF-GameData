library SpellHelper uses SimError, MiscFunctions, RestoreMana
	
	globals
		private constant string ERROR_MSG = "This unit is immune to magic."
    endglobals

	struct SpellHelper
	
		static method isValidEnemy takes unit target, unit caster returns boolean
			return IsUnitEnemy(target, GetOwningPlayer(caster)) and not /*
				*/ isUnitDead(target) and not /*
				*/ IsUnitType(target, UNIT_TYPE_STRUCTURE) and not /*
				*/ IsUnitType(target, UNIT_TYPE_MECHANICAL)
		endmethod
		
		static method isValidAlly takes unit target, unit caster returns boolean
			return IsUnitAlly(target, GetOwningPlayer(caster)) and not /*
				*/ isUnitDead(target) and not /*
				*/ IsUnitType(target, UNIT_TYPE_STRUCTURE) and not /*
				*/ IsUnitType(target, UNIT_TYPE_MECHANICAL) and /*
				*/ target != caster
		endmethod
		
		static method isUnitDead takes unit target returns boolean
			return IsUnitType(target, UNIT_TYPE_DEAD) or GetUnitTypeId(target) == 0
		endmethod
		
		static method isUnitImmune takes unit target returns boolean
			return IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
		endmethod
		
		//Reset Cooldown of the Ability
		static method resetAbility takes unit target, integer spellId returns nothing
			local integer i = GetUnitAbilityLevel(target, spellId)
			
			if i > 0 and UnitRemoveAbility(target, spellId) then
				call UnitAddAbility(target, spellId)
				call SetUnitAbilityLevel(target, spellId, i)
			endif
		endmethod
		
		//Return Mana Costs
		static method restoreMana takes integer spellId, unit caster, unit target, real spellX, real spellY returns nothing
			call RunManaCost(spellId, caster, target, spellX, spellY)
		endmethod
		
		static method isImmuneOnSpellCast takes integer spellId, unit caster, unit target, real spellX, real spellY returns boolean
			if (isUnitImmune(target)) then
				//Return Mana Costs
				call restoreMana(spellId, caster, target, spellX, spellY)
				//Show Error Message
				call SimError(GetOwningPlayer(caster), ERROR_MSG)
				//Reset Cooldown of the Ability
				call resetAbility(caster, spellId)
				return true
			else
				return false
			endif
		endmethod
		
		//Damage Target
		//Note: attack == true->Angriff, false->Zauber 
		static method damageTarget takes unit source, unit target, real damage, boolean attack, boolean ranged, attacktype attackType, damagetype damageType, weapontype weaponType returns nothing
			call UnitDamageTarget(source, target, damage, attack, ranged, attackType, damageType, weaponType)        
		endmethod
		
		static method explodeUnit takes unit target returns nothing
			call SetUnitExploded(target, true)
			call KillUnit(target)
		endmethod
	endstruct
endlibrary