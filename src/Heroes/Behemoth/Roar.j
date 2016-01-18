scope Roar initializer init

	globals
        private constant integer SPELL_ID = 'A07B'
		private constant integer DUMMY_SPELL_ID = 'A00B'
	endglobals
	
	private function Actions takes nothing returns nothing
		local xecast xc = xecast.createA()
		local unit u = GetTriggerUnit()
		
		set xc.abilityid = DUMMY_SPELL_ID
		set xc.level = GetUnitAbilityLevel(u, SPELL_ID)
		set xc.orderstring = "roar"
		set xc.owningplayer = GetOwningPlayer(u)
		call xc.castInPoint(GetUnitX(u), GetUnitY(u))

		set u = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
    endfunction

endscope