scope Tombstone initializer init
    /*
     * eeve.org / Tower: Tombstone
     * Description: This tower has a small chance on attack to kill a target immediately.
     * Last Update: 19.12.2013
     * Changelog: 
     *     19.12.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A09W'
        private constant string EFFECT = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl"
        private constant real array CHANCE
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set CHANCE[1] = 0.6
        set CHANCE[2] = 0.8
        set CHANCE[3] = 1.0
    endfunction
    
    private function onKill takes unit damagedUnit returns nothing
        call DestroyEffect(AddSpecialEffectTarget(EFFECT, damagedUnit, "origin"))
        call KillUnit(damagedUnit)
    endfunction
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local integer level = 0
        
        if GetUnitAbilityLevel(damageSource, SPELL_ID) > 0 then
            set level = TowerSystem.getTowerValue(GetUnitTypeId(damageSource), 3)
            if GetRandomReal(0,100) <= CHANCE[level] then
                call onKill( damagedUnit )
	        endif
	    endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call MainSetup()
    endfunction

endscope