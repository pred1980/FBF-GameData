library ItemStack initializer Init uses RegisterPlayerUnitEvent
	/*
	 *	Note: All stackable Items need an Item Level which represents the stack level
	 */

	globals
		private constant integer MAX_TOMES_X_ITEMS = 2
		// This array consists of the power up item (tome) for each real potion item
		private integer array POWERUP_X_ITEM[MAX_TOMES_X_ITEMS][2]
	endglobals
	
	// add here the tome + real stackable item type
	private function MainSetup takes nothing returns nothing
		set POWERUP_X_ITEM[0][0] = 'I00O' // Tome for Heal Potion
		set POWERUP_X_ITEM[0][1] = 'I000' // Real Heal Potion
		set POWERUP_X_ITEM[1][0] = 'I00Q' // Tome for Mana Potion
		set POWERUP_X_ITEM[1][1] = 'I001' // Real Mana Potion	
	endfunction
	
    private function OnStackItemAction takes nothing returns nothing
        local unit u = GetTriggerUnit()
		local integer pid = GetPlayerId(GetOwningPlayer(u))
		local item x = GetManipulatedItem() // Tome
		local item t // Item on slot
		local item ii
		local integer y = GetItemTypeId(x)
		local integer il = 0
		local integer i = 0
		local integer k = 0
		local integer c = 0
		local integer goldCost = GetItemGoldCost(x)
		local player p = GetOwningPlayer(u)
		local boolean isBuyAble = false
		
		call RemoveItem(x)
		loop
			set t = UnitItemInSlot(u, i)
			set c = GetItemCharges(t)
			set il = GetItemLevel(t)
			exitwhen (i >= bj_MAX_INVENTORY)
			loop
				exitwhen (k >= MAX_TOMES_X_ITEMS)
				if 	(y == POWERUP_X_ITEM[k][0] and /*
			 	*/	(t == null or /*
			    */  (GetItemTypeId(t) == POWERUP_X_ITEM[k][1] and c < il))) then
					set ii = CreateItem(POWERUP_X_ITEM[k][1], GetUnitX(u), GetUnitY(u))
					call SetItemCharges(ii, c + 1)
					call RemoveItem(t)
					call UnitAddItem(u, ii)
					
					set i = bj_MAX_INVENTORY
					set k = MAX_TOMES_X_ITEMS
					set isBuyAble = true
				endif
				set k = k + 1
			endloop	
			set i = i + 1
			set k = 0
		endloop
		
		if (not isBuyAble) then
			call Game.playerAddGold(pid, goldCost)
			call SimError(p, "Inventory is full.")
		endif

		set u = null
		set x = null
		set t = null
		set ii = null
    endfunction
	
	private function OnStackItemCondition takes nothing returns boolean
		return (GetItemType(GetManipulatedItem()) == ITEM_TYPE_POWERUP and GetItemLevel(GetManipulatedItem()) > 0)
	endfunction

    private function Init takes nothing returns nothing
		call MainSetup()
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function OnStackItemCondition, function OnStackItemAction)
    endfunction
endlibrary