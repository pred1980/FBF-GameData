scope Moonlight initializer init
    /*
     * Description: The Priestess concentrates all her strenght to call the mystic might of the moon giving friendly 
					units a 30% chance to avoid attacks for a few seconds.
     * Changelog: 
     *     	07.01.2014: Abgleich mit OE und der Exceltabelle
	 *     	28.04.2015: Integrated RegisterPlayerUnitEvent
	 *		18.09.2015: Changed Invulnerability to an 30% Evasion Aura
     *
     */
    globals
        private constant integer SPELL_ID = 'A07F'
        private constant integer DUMMY_ID = 'h017'
        private constant integer DUMMY_SPELL_ID = 'S000'
        
        private real array DURATION
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DURATION[1] = 6
        set DURATION[2] = 7
        set DURATION[3] = 8
        set DURATION[4] = 9
        set DURATION[5] = 10
    endfunction

    private function Actions takes nothing returns nothing
        local unit caster = GetSpellAbilityUnit()
        local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
        local unit moon = CreateUnit(GetOwningPlayer(caster), DUMMY_ID, GetSpellTargetX(), GetSpellTargetY(), 0)
        
        call UnitAddAbility(moon, DUMMY_SPELL_ID)
        call SetUnitAbilityLevel(moon, DUMMY_SPELL_ID, 1)
        call UnitApplyTimedLife(moon, 'BTLF', DURATION[level])
        
        set moon = null
        set caster = null
    endfunction
    
    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call MainSetup()
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction

endscope