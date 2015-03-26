scope Rage initializer init
    /*
     * Description: The Ghoul charges forward carelessly, thrusting and slashing with tremendous strenght and speed, 
	                but leaving himself open to attacks.
     * Changelog: 
     *     28.10.2013: Abgleich mit OE und der Exceltabelle
	 *     20.03.2015: Code refactoring
     *
     */
    globals
        private constant integer BUFF_ID = 'B00E'
        private constant integer BASE_DAMAGE_MODIFIER = 2
    endglobals
    
    private function OnRage takes unit attacker, unit target, real damage returns nothing
		set DamageType = 1
		call DamageUnitPhysical(attacker, target, damage * BASE_DAMAGE_MODIFIER)
    endfunction

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if ( GetUnitAbilityLevel(damagedUnit, BUFF_ID) > 0 and DamageType == 0) then
            call OnRage(damageSource, damagedUnit, damage)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
    endfunction

endscope