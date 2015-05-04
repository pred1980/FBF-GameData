scope FireTotem initializer init
    /*
     * Description: The Tauren Chieftain creates a burning Totem at a target point which attacks nearby enemy units.
     * Changelog: 
     *     	06.01.2014: Abgleich mit OE und der Exceltabelle
	 *     	30.04.2015: Integrated RegisterPlayerUnitEvent
						Code Refactoring
     *
     */
    globals
        private constant integer SPELL_ID = 'A078'
        private constant integer TOTEM_ID = 'o001'
        private constant integer BASE_DAMAGE = 15
        private constant integer DAMAGE_PER_LEVEL = 20
        private constant real DURATION = 15.0
        
        private string SOUND = "Units\\Orc\\StasisTotem\\StasisTrapBirth.wav"
    endglobals

    private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local real targetX = GetSpellTargetX()
		local real targetY = GetSpellTargetY()
		local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
		local unit totem = CreateUnit( GetOwningPlayer(caster), TOTEM_ID, targetX, targetY, 0)
		
		call Sound.runSoundOnUnit(SOUND, totem)
		call TDS.addDamage(totem, BASE_DAMAGE + (DAMAGE_PER_LEVEL * level))
		call UnitApplyTimedLife(totem, 'BTLF', DURATION)
		
		set caster = null
		set totem = null
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		call Sound.preload(SOUND)
    endfunction

endscope