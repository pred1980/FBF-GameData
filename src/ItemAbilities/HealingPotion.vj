scope ItemHealingPotion	initializer Init

	globals
		// Real Heal Potion
		private constant integer ITEM_ID = 'I000'
		// Tome Heal Potion
		private constant integer ITEM_TOME_ID = 'I00O'
		private constant real HP_VALUE = 100
	endglobals

	private function Actions takes nothing returns nothing
		local unit caster = GetManipulatingUnit()
		local item it
		
		if (GetUnitLifePercent(caster) < 100) then
			call SetUnitState(caster, UNIT_STATE_LIFE, GetUnitState(caster, UNIT_STATE_LIFE) + HP_VALUE)
		else
			set it = CreateItem(ITEM_TOME_ID, GetUnitX(caster), GetUnitY(caster))
			call UnitAddItem(caster, it)
			call SimError(GetOwningPlayer(caster), "Already at full health.")
		endif

		set caster = null
	endfunction

	private function Conditions takes nothing returns boolean
		return GetItemTypeId(GetManipulatedItem()) == ITEM_ID
	endfunction
	
	private function Init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_USE_ITEM, function Conditions, function Actions)
	endfunction
endscope