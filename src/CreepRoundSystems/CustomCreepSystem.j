scope CustomCreepSystem
	/*
	 * This System allows the Coalition Players to send their own creep units.
	 * Note: not yet finished
	 */

	globals
		private constant integer ORC_SHOP_ID = 'u009' //Orc|Dassir Summons
		private constant integer INCREASED_HP_PER_ROUND = 55
        private constant integer INCREASED_DAMAGE_PER_ROUND = 7
		private constant real array FACING
        
        private real array POSITION[3][2]
		private hashtable UNIT_DATA = InitHashtable()
		private integer MAX_CREEPS = 0
	endglobals
	
	private struct CustomCreep
		
		static method initialize takes nothing returns nothing
			local unit shop
            local integer row = 0
            local integer column = 0
			local trigger t = CreateTrigger()
			
			//Richtung
            set FACING[0] = 0.00 //Orc|Dassir Summons
			
			//Position
            set POSITION[0][0] = -9216.4 //x-pos of Orc|Dassir Summons
            set POSITION[0][1] = -3498.7 //y-pos of Orc|Dassir Summons
            
            //Index: 0        
            //******CHAOS WARLORD*******
            call SaveInteger(UNIT_DATA, column, row, 'o00F') //0 : Unit Id
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 250) //1 : Unit HP in the TD Part
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 17) //2 : Unit Damage in the AoS Part ( DPS )
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "1,") //3 : Bounty per Config
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 200) //4 : Unit HP in the AoS Part
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0) //5 : Unit Mana in the AoS Part
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1) //6 : Ability Id
			set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1) //7 : Life Time in seconds
            set column = 0
            set row = row + 1
			
			//save the amount of all custom creeps
            set MAX_CREEPS = row
			
			set shop = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), ORC_SHOP_ID, POSITION[0][0], POSITION[0][1], FACING[0])
			call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
			call TriggerAddAction(t, function thistype.onShopSell )
            
            set t = null
		endmethod
		
		static method onShopSell takes nothing returns nothing
			call CustomWave.create(GetSoldUnit())
		endmethod
	
	endstruct


endscope