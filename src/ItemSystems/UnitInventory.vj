scope UnitInventory
	
	struct UnitInventory
	
		static method getItemPath takes unit hero, integer slot returns string
			local item ite = UnitItemInSlot(hero, slot)
			local integer itemId = GetItemTypeId(ite)
			
			if itemId > 0 then
				return Item[itemId].path
			endif
			set ite = null
			
			return "EmptyItemIcon.blp"
		endmethod
		
		private static method onItemActionCallback takes nothing returns nothing
			local integer id = GetTimerData(GetExpiredTimer())
			
			call FBFMultiboard.onUpdateItemIcon(GetUnitById(id))
			call ReleaseTimer(GetExpiredTimer())
		endmethod
	
		private static method onItemAction takes nothing returns nothing
			local item i = GetOrderTargetItem()
			local integer o = GetIssuedOrderId()
			local unit u = GetTriggerUnit()
			local timer t 
			
			if i == null then
				set i = GetManipulatedItem()
			endif

			if (i != null and IsUnitType(u, UNIT_TYPE_HERO) and (o == 851971 or o == 0 or (o > 852001 and o < 852008))) then
				set t = NewTimer()
				call SetTimerData(t, GetUnitId(u))
				call TimerStart(t, .0, false, function thistype.onItemActionCallback)
			endif
			//Clean up
			set u = null
			set i = null
		endmethod
		
        static method initialize takes nothing returns nothing
            local integer i = 0
			local trigger itemAction = CreateTrigger()
			local code c1 = function thistype.onItemAction
            
			loop
                exitwhen i > bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) then
                    call TriggerRegisterPlayerUnitEvent(itemAction, Player(i), EVENT_PLAYER_UNIT_USE_ITEM, null)
					call TriggerRegisterPlayerUnitEvent(itemAction, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM, null)
					call TriggerRegisterPlayerUnitEvent(itemAction, Player(i), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, null)
					call TriggerRegisterPlayerUnitEvent(itemAction, Player(i), EVENT_PLAYER_UNIT_DROP_ITEM, null)
                endif
                set i = i + 1
            endloop
            
            call TriggerAddCondition(itemAction, Filter(c1))
            set itemAction = null
            set c1 = null
        endmethod
    endstruct

endscope