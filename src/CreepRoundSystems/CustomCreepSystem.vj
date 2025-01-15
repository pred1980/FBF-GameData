scope CustomCreepSystem
	/*
	 * This System allows the Coalition Players to send their own creep units.
	 * Note: not yet finished
	 */

	globals
		private constant integer ORC_SHOP_ID = 'u009' 
		private constant integer NE_SHOP_ID = 'e00N'
		private constant integer HUM_SHOP_ID = 'n00P'
		private constant real array FACING
		
		private constant string EFFECT = "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl"
		private constant real SHOP_RANGE = 400.0
		private constant real EFFECT_DURATION = 1.5
		
        private real array position[3][2]
		private hashtable shops = InitHashtable()
	endglobals
	
	struct CustomCreepSystem
	
		private static method onShopSellCondition takes nothing returns boolean
			local unit u = GetSoldUnit()
			local boolean b = true
			
			if (GetPlayerRace(GetOwningPlayer(u)) == RACE_UNDEAD) then
				set b = false
				call KillUnit(u)
				call RemoveUnit(u)
			endif
			
			set u = null
			return b
		endmethod
		
		private static method onShopSell takes nothing returns nothing
			call CustomWave.addUnitToWaypoint(GetSoldUnit())
		endmethod
		
		private static method onUnitInRangeAction takes nothing returns nothing
			local unit u = LoadUnitHandle(shops, 0, GetHandleId(GetTriggeringTrigger()))
			
			call TimedEffect.createOnUnit(EFFECT, u, "overhead", EFFECT_DURATION)
			
			set u = null
		endmethod
		
		private static method onUnitInRangeCondition takes nothing returns boolean
			return IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO)
		endmethod
		
		private static method registerOnUnitInRange takes unit shop returns nothing
			local trigger t = CreateTrigger()
			
			call SaveUnitHandle(shops, 0, GetHandleId(t), shop)
			call TriggerRegisterUnitInRange(t, shop, SHOP_RANGE, null)
			call TriggerAddCondition(t,  Condition(function thistype.onUnitInRangeCondition))
			call TriggerAddAction(t, function thistype.onUnitInRangeAction)
			
			set t = null
		endmethod
		
		private static method createShop takes integer pId, integer posId, integer shopId returns nothing
			local trigger t = CreateTrigger()
			local unit shop = CreateUnit(Player(pId), shopId, position[posId][0], position[posId][1], FACING[posId])
			
			call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
			call TriggerAddCondition(t, function thistype.onShopSellCondition)
			call TriggerAddAction(t, function thistype.onShopSell)
			
			call registerOnUnitInRange(shop)
			
			set t = null
		endmethod
	
		static method initialize takes nothing returns nothing
			//Unit facing
			//Orc|Dassir Summons
            set FACING[0] = 0.00
			//NE|DBloodBlade Sanctum
			set FACING[1] = 275.0
			//HUM|North Mountain Mercs
			set FACING[2] = 275.0 
			
			//Position
			//x/y-pos of Orc|Dassir Summons
            set position[0][0] = -9216.4 
            set position[0][1] = -3498.7
			//x/y-pos of NE|DBloodBlade Sanctum
			set position[1][0] = 8319.0 
            set position[1][1] = -2822.4 
            //x/y-pos of HUM|North Mountain Mercs
			set position[2][0] = -300.2 
            set position[2][1] = -11450.3
			
			call createShop(PLAYER_NEUTRAL_PASSIVE, 0, ORC_SHOP_ID)
			call createShop(PLAYER_NEUTRAL_PASSIVE, 1, NE_SHOP_ID)
			call createShop(PLAYER_NEUTRAL_PASSIVE, 2, HUM_SHOP_ID)
            
		endmethod
	
	endstruct

endscope