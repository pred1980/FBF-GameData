scope ClawsAttack initializer init
    /*
     * Description: The former Paladin flings his claws around aimlessly dealing bonus physical damage to heroes, 
                    but hurting himself in the process.
     * Changelog: 
     *      28.10.2013: Abgleich mit OE und der Exceltabelle
	 *		13.04.2015: Integrated SpellHelper for damaging and filtering
     *
     */
    globals
        private constant integer SPELL_ID = 'A04N'
        private constant integer BUFF_ID = 'B00B'
        private constant integer BASE_DAMAGE_MODIFIER = 10
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals
    
    private function addDamage takes unit damageSource, unit damagedUnit, real damage returns nothing
        local integer level = GetUnitAbilityLevel(damageSource, SPELL_ID)
        local real dmg = damage * ( I2R((level * BASE_DAMAGE_MODIFIER)) / 100.0 )
        
		set DamageType = PHYSICAL
		call SpellHelper.damageTarget(damageSource, damagedUnit, dmg, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
    endfunction
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if (GetUnitAbilityLevel(damageSource, BUFF_ID) > 0 and /*
		*/ 	SpellHelper.isValidEnemy(damagedUnit, damageSource) and /*
		*/	IsUnitType(damagedUnit, UNIT_TYPE_HERO) and /*
		*/	DamageType == PHYSICAL ) then
            call addDamage(damageSource, damagedUnit, damage)
        endif
		
		/*
		 * FOR AI HERO SYSTEM NEEDED!!!
		 */
		// If true, then it's self damage
		if ((damageSource == damagedUnit) and /*
		*/	(GetPlayerController(GetOwningPlayer(damageSource)) == MAP_CONTROL_COMPUTER)) then
			call IssueImmediateOrder(damageSource, "holdposition")
		endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
    endfunction

endscope