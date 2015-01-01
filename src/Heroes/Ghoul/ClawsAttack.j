scope ClawsAttack initializer init
    /*
     * Description: The former Paladin flings his claws around aimlessly dealing bonus physical damage to heroes, 
                    but hurting himself in the process.
     * Last Update: 28.10.2013
     * Changelog: 
     *     28.10.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A04N'
        private constant integer BUFF_ID = 'B00B'
        private constant integer BASE_DAMAGE_MODIFIER = 10
    endglobals
    
    private function addDamage takes unit damageSource, unit damagedUnit, real damage returns nothing
        local integer level = GetUnitAbilityLevel(damageSource, SPELL_ID)
        local real dmg = damage * ( I2R((level * BASE_DAMAGE_MODIFIER)) / 100.0 )
        set DamageType = 1
        call DamageUnitPhysical(damageSource, damagedUnit, dmg)
    endfunction
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if ( GetUnitAbilityLevel(damageSource, BUFF_ID) > 0 and IsUnitEnemy(damagedUnit, GetOwningPlayer(damageSource)) and IsUnitType(damagedUnit, UNIT_TYPE_HERO) and DamageType == 0 ) then
            call addDamage(damageSource, damagedUnit, damage)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
    endfunction

endscope