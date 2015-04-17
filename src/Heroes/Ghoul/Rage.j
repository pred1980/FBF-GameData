scope Rage initializer init
    /*
     * Description: The Ghoul charges forward carelessly, thrusting and slashing with tremendous strenght and speed, 
	                but leaving himself open to attacks.
     * Changelog: 
     *      28.10.2013: Abgleich mit OE und der Exceltabelle
	 *      20.03.2015: Code refactoring
	 *		13.04.2015: Code Refactoring
						Integrated SpellHelper for damaging
     *
     */
    globals
        private constant integer BUFF_ID = 'B00E'
        private constant integer BASE_DAMAGE_MODIFIER = 2
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals
    
    private function OnRage takes unit attacker, unit target, real damage returns nothing
		set DamageType = PHYSICAL
		call SpellHelper.damageTarget(attacker, target, damage * BASE_DAMAGE_MODIFIER, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
    endfunction

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if ( GetUnitAbilityLevel(damagedUnit, BUFF_ID) > 0 and DamageType == PHYSICAL) then
            call OnRage(damageSource, damagedUnit, damage)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
    endfunction

endscope