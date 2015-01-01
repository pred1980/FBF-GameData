scope ItemShops
    
    globals
        private unit array SHOPS[4][3]
    endglobals
    
    struct ItemShops
    
        static method getShop takes integer raceId, integer shopId returns unit
            return SHOPS[raceId][shopId]
        endmethod
    
        static method initialize takes nothing returns nothing
            //Undead Shops
            set SHOPS[0][0] = gg_unit_u000_0067
            set SHOPS[0][1] = gg_unit_u001_0010
            set SHOPS[0][2] = gg_unit_u003_0011
            
            //Human Shops
            set SHOPS[1][0] = gg_unit_u00K_0018
            set SHOPS[1][1] = gg_unit_u00L_0019
            set SHOPS[1][2] = gg_unit_u00M_0020
            
            //Orc Shops
            set SHOPS[2][0] = gg_unit_u00N_0021
            set SHOPS[2][1] = gg_unit_u00O_0015
            set SHOPS[2][2] = gg_unit_u00P_0008
            
            //Nightelf Shops
            set SHOPS[3][0] = gg_unit_u00H_0050
            set SHOPS[3][1] = gg_unit_u00I_0017
            set SHOPS[3][2] = gg_unit_u00J_0016
        endmethod
    
    endstruct

endscope