scope DomeAura initializer Init

	globals
		private constant integer DUMMY_ID = 'e012'
		private constant real X = -1486.1
		private constant real Y = 1003.1
	endglobals

	private function Init takes nothing returns nothing
		call CreateUnit(Player(bj_PLAYER_NEUTRAL_VICTIM), DUMMY_ID, X, Y, 0.00)
	endfunction

endscope