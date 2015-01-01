scope CoalitionShopSystem

    globals
        private constant integer ORC_SHOP_ID = 'n00A' // Shaman
        private constant integer HUMAN_SHOP_ID = 'n009' // Sorceress
        private constant integer NIGHTELF_SHOP_ID = 'n00B' // Talon
        private constant real array FACING
        
        private real array POSITION[6][2]
        private unit array SHOPS[6]
    endglobals
    
    struct CoalitionShopSystem
    
        static method initialize takes nothing returns nothing
            local unit shop
            local trigger t = CreateTrigger()
            
            //Richtung
            set FACING[0] = 131.74 //Shaman I
            set FACING[1] = 90.50  //Shaman II
            set FACING[2] = 24.39  //Sorceress I
            set FACING[3] = 310.81 //Sorceress II
            set FACING[4] = 264.38 //Talon I
            set FACING[5] = 205.07 //Talon II
            
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
            
            if Game.isPlayerInGame(6) then
                set shop = CreateUnit(Player(6), HUMAN_SHOP_ID, POSITION[2][0], POSITION[2][1], FACING[2])
                call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
                call SetUnitAnimation( shop, "channel" )
                set SHOPS[GetPlayerId(Player(6))] = shop
            endif
            
            if Game.isPlayerInGame(7) then
                set shop = CreateUnit(Player(7), HUMAN_SHOP_ID, POSITION[3][0], POSITION[3][1], FACING[3])
                call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
                call SetUnitAnimation( shop, "channel" )
                set SHOPS[GetPlayerId(Player(7))] = shop
            endif
            
            if Game.isPlayerInGame(8) then
                set shop = CreateUnit(Player(8), ORC_SHOP_ID, POSITION[0][0], POSITION[0][1], FACING[0])
                call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
                call SetUnitAnimation( shop, "channel" )
                set SHOPS[GetPlayerId(Player(8))] = shop
            endif
            
            if Game.isPlayerInGame(9) then
                set shop = CreateUnit(Player(9), ORC_SHOP_ID, POSITION[1][0], POSITION[1][1], FACING[1])
                call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
                call SetUnitAnimation( shop, "channel" )
                set SHOPS[GetPlayerId(Player(9))] = shop
            endif
            
            if Game.isPlayerInGame(10) then
                set shop = CreateUnit(Player(10), NIGHTELF_SHOP_ID, POSITION[4][0], POSITION[4][1], FACING[4])
                call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
                call SetUnitAnimation( shop, "channel" )
                set SHOPS[GetPlayerId(Player(10))] = shop
            endif
            
            if Game.isPlayerInGame(11) then
                set shop = CreateUnit(Player(11), NIGHTELF_SHOP_ID, POSITION[5][0], POSITION[5][1], FACING[5])
                call TriggerRegisterUnitEvent( t, shop, EVENT_UNIT_SELL )
                call SetUnitAnimation( shop, "channel" )
                set SHOPS[GetPlayerId(Player(11))] = shop
            endif
            
            call TriggerAddAction( t, function thistype.onShopSell )
            
            set shop = null
            set t = null
        endmethod
        
        static method getShop takes player p returns unit
            return SHOPS[GetPlayerId(p)]
        endmethod
        
        static method onShopSell takes nothing returns nothing
            call CoalitionUnit.updateProperties(GetSoldUnit())
        endmethod
    endstruct

endscope