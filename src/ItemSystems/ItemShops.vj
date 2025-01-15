scope ItemShops
    
    globals
		private constant string EFFECT = "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl"
		private constant real SHOP_RANGE = 400.0
		private constant real EFFECT_DURATION = 1.5
	
		private unit array SHOP[4][3]
		private integer array SHOP_IDS[4][3]
		private hashtable shops = InitHashtable()
    endglobals
    
    struct ItemShops
	
		private static method onUnitInRange takes nothing returns nothing
			local unit u = LoadUnitHandle(shops, 0, GetHandleId(GetTriggeringTrigger()))
			
			call TimedEffect.createOnUnit(EFFECT, u, "overhead", EFFECT_DURATION)
			
			set u = null
		endmethod
		
		private static method onUnitInRangeCondition takes nothing returns boolean
			return IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO)
		endmethod
    
        static method getShop takes integer raceId, integer shopId returns unit
            return SHOP[raceId][shopId]
        endmethod
		
		static method setupUnits takes nothing returns nothing
			local group g = NewGroup()
			local unit u
			local integer i = 0
			local integer k = 0
			local trigger t

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
							set t = CreateTrigger()
							call SaveUnitHandle(shops, 0, GetHandleId(t), u)
							call TriggerRegisterUnitInRange(t, u, SHOP_RANGE, null)
							call TriggerAddCondition(t,  Condition(function thistype.onUnitInRangeCondition))
							call TriggerAddAction(t, function thistype.onUnitInRange)
							set t = null
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