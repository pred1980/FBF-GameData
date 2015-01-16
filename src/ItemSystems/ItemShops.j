scope ItemShops
    
    globals
		private unit array SHOP[4][3]
		private integer array SHOP_IDS[4][3]
    endglobals
    
    struct ItemShops
    
        static method getShop takes integer raceId, integer shopId returns unit
            return SHOP[raceId][shopId]
        endmethod
		
		static method setupUnits takes nothing returns nothing
			local group g = NewGroup()
			local unit u
			local integer i = 0
			local integer k = 0

			//Grab all units on the map and enter them into the system.
			call GroupEnumUnitsInRect(g, GetPlayableMapRect(), null)

			loop
				set u = FirstOfGroup(g)
				exitwhen u == null
				loop
					exitwhen i > 3
					loop
						exitwhen k > 2
						if GetUnitTypeId(u) == SHOP_IDS[i][k] then
							set SHOP[i][k] = u
						endif
						set k = k + 1
					endloop
					set k = 0
					set i = i + 1
				endloop
				set i = 0
				set k = 0
				call GroupRemoveUnit(g, u)
			endloop
			
			call ReleaseGroup(g)
			set u = null
		endmethod
    
        static method initialize takes nothing returns nothing
			
			//Undead Shops
            set SHOP_IDS[0][0] = 'u000'
            set SHOP_IDS[0][1] = 'u001'
            set SHOP_IDS[0][2] = 'u003'
            
            //Human Shops
            set SHOP_IDS[1][0] = 'u00K'
            set SHOP_IDS[1][1] = 'u00L'
            set SHOP_IDS[1][2] = 'u00M'
            
            //Orc Shops
            set SHOP_IDS[2][0] = 'u00N'
            set SHOP_IDS[2][1] = 'u00O'
            set SHOP_IDS[2][2] = 'u00P'
            
            //Nightelf Shops
            set SHOP_IDS[3][0] = 'u00H'
            set SHOP_IDS[3][1] = 'u00I'
            set SHOP_IDS[3][2] = 'u00J'
			
			//setup Units
			call setupUnits()
        endmethod
    
    endstruct

endscope