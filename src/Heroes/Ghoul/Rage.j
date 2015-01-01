scope Rage initializer init
    /*
     * Description: Every second hit weakens the enemys armor by 2 points for 3 seconds. The effect can stack several times.
     * Last Update: 28.10.2013
     * Changelog: 
     *     28.10.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer BUFF_ID = 'B00E'
        private constant integer BASE_DAMAGE_MODIFIER = 2
    endglobals
    
    private struct Rage
        
        static method create takes unit attacker, unit target, real damage returns thistype
            local thistype this = thistype.allocate()
            set DamageType = 1
            call DamageUnitPhysical(attacker, target, damage * BASE_DAMAGE_MODIFIER)
            
            return this
        endmethod
        
    endstruct

   private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local Rage r = 0
         
        if ( GetUnitAbilityLevel(damagedUnit, BUFF_ID) > 0 and DamageType == 0 ) then
            set r = Rage.create(damageSource, damagedUnit, damage)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
    endfunction

endscope