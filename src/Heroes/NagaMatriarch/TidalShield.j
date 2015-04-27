scope TidalShield initializer init
    /*
     * Description: This shield makes the Naga immune to spells and boosts her life regeneration.
     * Last Update: 08.01.2014
     * Changelog: 
     *     	08.01.2014: Abgleich mit OE und der Exceltabelle + Bugfixing und kleinerem Umbau
	 *     	14.03.2014: Simplification of the code and a small bugfix
	 *     	22.04.2015: Integrated RegisterPlayerUnitEvent
     *
     */ 
    globals
        private constant integer SPELL_ID = 'A07O'
        private constant integer BUFF_ID = 'B01C'
        private constant real INTERVAL = 1.0
		private constant real SPELL_DURATION = 10.0 //HEAL AND IMMUNITY
        //Heal over Time Effect
        private constant string EFFECT = ""
        private constant string ATT_POINT = ""
		
		//Has to be the same as the duration of the Buff to apply the right heal
        private real array HEAL
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set HEAL[1] = 100
        set HEAL[2] = 150
        set HEAL[3] = 200
        set HEAL[4] = 250
        set HEAL[5] = 300
    endfunction

    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
		
		call HOT.start(caster, HEAL[GetUnitAbilityLevel(caster, SPELL_ID)], SPELL_DURATION, EFFECT, ATT_POINT )
		
		set caster = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID and GetUnitLifePercent(GetTriggerUnit()) < 100.00
    endfunction
	
	private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call MainSetup()
    endfunction

endscope
