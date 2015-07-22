scope UnitShopSystem

    globals
        private constant integer ORC_SHOP_ID = 'n00A' // Shaman (2x)
        private constant integer HUMAN_SHOP_ID = 'n009' // Sorceress (2x)
        private constant integer NIGHTELF_SHOP_ID = 'n00B' // Talon (2x)
		private constant integer FORSAKEN_SHOP_ID = 'n00S' // Zombie (1x)
        private constant real array FACING
		
		private constant string EFFECT = "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl"
		private constant real SHOP_RANGE = 400.0
		private constant real EFFECT_DURATION = 1.5
        
        private real array POSITION[7][2]
        private unit array SHOPS[7]
		private hashtable shops = InitHashtable()
    endglobals
    
    struct UnitShopSystem
	
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
		
		private static method createShop takes integer pId, integer posId, trigger t, integer shopId returns nothing
			local unit shop = CreateUnit(Player(pId), shopId, POSITION[posId][0], POSITION[posId][1], FACING[posId])
			
			call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
			call SetUnitAnimation( shop, "channel" )
			set SHOPS[GetPlayerId(Player(pId))] = shop
			
			call registerOnUnitInRange(shop)
		endmethod
		
        static method initialize takes nothing returns nothing
            local trigger t = CreateTrigger()
			local integer i = 0
			
            //Richtung
            set FACING[0] = 131.74 //Shaman I
            set FACING[1] = 90.50  //Shaman II
            set FACING[2] = 24.39  //Sorceress I
            set FACING[3] = 310.81 //Sorceress II
            set FACING[4] = 264.38 //Talon I
            set FACING[5] = 205.07 //Talon II
			set FACING[6] = 78.85 //Zombie
            
            //Position
            set POSITION[0][0] = -1938.4 //x-pos of Shaman I
            set POSITION[0][1] = 1280.2 //y-pos of Shaman I
            set POSITION[1][0] = -1458.8 //x-pos of Shaman II
            set POSITION[1][1] = 1526.4 //y-pos of Shaman II
            
            set POSITION[2][0] = -1025.0 //x-pos of Sorceress I
            set POSITION[2][1] = 1248.0 //y-pos of Sorceress I
            set POSITION[3][0] = -1015.8 //x-pos of Sorceress II
            set POSITION[3][1] = 726.1 //y-pos of Sorceress II
            
            set POSITION[4][0] = -1491.0 //x-pos of Talon I
            set POSITION[4][1] = 487.4 //y-pos of Talon I
            set POSITION[5][0] = -1963.8 //x-pos of Talon II
            set POSITION[5][1] = 789.0 //y-pos of Talon II
			
			set POSITION[6][0] = 5115.8 //x-pos of Zombie
            set POSITION[6][1] = 4040.4 //y-pos of Zombie
            
            if Game.isPlayerInGame(6) then
				call createShop(6, 2, t, HUMAN_SHOP_ID)
            endif
            
            if Game.isPlayerInGame(7) then
                call createShop(7, 3, t, HUMAN_SHOP_ID)
            endif
            
            if Game.isPlayerInGame(8) then
                call createShop(8, 0, t, ORC_SHOP_ID)
            endif
            
            if Game.isPlayerInGame(9) then
                call createShop(9, 1, t, ORC_SHOP_ID)
            endif
            
            if Game.isPlayerInGame(10) then
                call createShop(10, 4, t, NIGHTELF_SHOP_ID)
            endif
            
            if Game.isPlayerInGame(11) then
                call createShop(11, 5, t, NIGHTELF_SHOP_ID)
            endif
			
			//Forsaken Shop
			loop
				exitwhen i > 5
					if (Game.isPlayerInGame(i)) then
						call createShop(bj_PLAYER_NEUTRAL_EXTRA, 6, t, FORSAKEN_SHOP_ID)
						set i = 6
					endif
				set i = i + 1
			endloop
			
            call TriggerAddAction( t, function thistype.onShopSell )
            
            set t = null
        endmethod
        
        static method getShop takes player p returns unit
            return SHOPS[GetPlayerId(p)]
        endmethod
        
        static method onShopSell takes nothing returns nothing
            call CreepUnit.updateProperties(GetSoldUnit())
        endmethod
    endstruct

endscope