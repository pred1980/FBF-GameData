library CreepSystemUnits uses MiscFunctions

    globals
        private hashtable UNIT_DATA = InitHashtable()
        private integer MAX_CREEPS = 26
    endglobals
    
    function GET_UNIT_DATA takes integer column, integer row returns integer
        //3 == Bounty je nach Round-Config, der gewählt wurde
        if column != 3 then
            return LoadInteger(UNIT_DATA, column, row)
        else
            return S2I(getDataFromString(LoadStr(UNIT_DATA, column, row), RoundType.current))
        endif
    endfunction
    
    function GET_MAX_CREEPS takes nothing returns integer
        return MAX_CREEPS
    endfunction
    
    //value:
    //-1 = Index, also die row
    //0 = Unit Id
    //1 = Unit HP in the TD Part
    //2 = Unit Damage in the AoS Part ( DPS )
    //3 = Bounty per Game Mod
    //4 = Unit HP in the AoS Part
    //5 = Unit Mana in the AoS Part
    //6 = Ability Id
    function GET_UNIT_VALUE takes integer unitId, integer value returns integer
        local integer i = 0
        
        loop
            exitwhen i > MAX_CREEPS
            if (LoadInteger(UNIT_DATA, 0, i) ==  unitId) then
                if value != -1 then
                    //debug call BJDebugMsg("1.i: " + I2S(S2I((getDataFromString(LoadStr(UNIT_DATA, value, i), RoundType.current)))))
                    return S2I((getDataFromString(LoadStr(UNIT_DATA, value, i), RoundType.current)))
                else
                    //debug call BJDebugMsg("2.i: " + I2S(i))
                    return i
                endif
            endif
            set i = i + 1
        endloop
        
        return -1
    endfunction
    
    struct CreepSystemUnits
        
        static method onInit takes nothing returns nothing
            local integer row = 0
            local integer column = 0
            
            /*
             * MELEE UNITS
             */
            //Index: 0        
            //******MURGUL REAVER*******
            call SaveInteger(UNIT_DATA, column, row, 'n00Q') //0 : Unit Id
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 250) //1 : Unit HP in the TD Part
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 17) //2 : Unit Damage in the AoS Part ( DPS )
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "1,2,3,") //3 : Bounty per Config
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 200) //4 : Unit HP in the AoS Part
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0) //5 : Unit Mana in the AoS Part
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1) //6 : Ability Id
            set column = 0
            set row = row + 1
            
            //Index: 1
            //******FOOTMAN*******
            call SaveInteger(UNIT_DATA, column, row, 'h006')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 450)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 11)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "2,3,4,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 385)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 2
            //******HUNTRESS*******
            call SaveInteger(UNIT_DATA, column, row, 'e006')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 650)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 20)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 565)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 3
            //******RAIDER*******
            call SaveInteger(UNIT_DATA, column, row, 'o003')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 850)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 22)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "4,5,6,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 575)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 4
            //******GRUNT*******
            call SaveInteger(UNIT_DATA, column, row, 'o004')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1050)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 17)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "5,6,7,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 765)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 5
            //******SPELL BREAKER*******
            call SaveInteger(UNIT_DATA, column, row, 'h00W')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1250)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 12)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 565)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 6
            //******DRUID OF THE CLAW (NIGHTELF)*******
            call SaveInteger(UNIT_DATA, column, row, 'e000')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1450)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 18)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "2,3,4,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 545)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 300)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 7
            //******DRUID OF THE CLAW (BEAR)*******
            call SaveInteger(UNIT_DATA, column, row, 'e000')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1650)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 26)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "5,6,7,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 925)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 200)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 8
            //******KNIGHT*******
            call SaveInteger(UNIT_DATA, column, row, 'h00X')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1850)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 28)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "6,7,8,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 950)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 9
            //******MOUNTAIN GIANT*******
            call SaveInteger(UNIT_DATA, column, row, 'e003')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 2050)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 26)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "8,9,10,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1565)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 10
            //******TAUREN*******
            call SaveInteger(UNIT_DATA, column, row, 'o006')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 2250)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 29)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "7,8,9,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1265)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 11
            //******NAGA ROYAL GUARD*******
            call SaveInteger(UNIT_DATA, column, row, 'n001')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 2450)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 28)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "9,10,11,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 2065)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 500)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //------RANGED UNITS------
            
            //Index: 12
            //******ARCHER*******
            call SaveInteger(UNIT_DATA, column, row, 'e005')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 250)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 15)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "1,2,3,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 210)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 13
            //******RIFLEMAN*******
            call SaveInteger(UNIT_DATA, column, row, 'h00Z')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 450)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 16)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "2,3,4,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 500)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 14
            //******TROLL HEADHUNTER*******
            call SaveInteger(UNIT_DATA, column, row, 'o007')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 650)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 22)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 315)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 15
            //******SNAP DRAGON*******
            call SaveInteger(UNIT_DATA, column, row, 'n002')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 850)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 24)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "4,5,6,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 615)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 16
            //******DRYAD*******
            call SaveInteger(UNIT_DATA, column, row, 'e004')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1050)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 16)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 400)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 17
            //******MORTAR TEAM*******
            call SaveInteger(UNIT_DATA, column, row, 'h010')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1250)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 51)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 325)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 18
            //******KODO BEAST*******
            call SaveInteger(UNIT_DATA, column, row, 'o008')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1450)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 15)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "5,6,7,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 965)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 19
            //******DRAGON TURTLE*******
            call SaveInteger(UNIT_DATA, column, row, 'n003')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1650)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 22)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "6,7,8,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 840)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 0)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //------CASTER UNITS------
            
            //Index: 20
            //******DRUID OF THE TALON*******
            call SaveInteger(UNIT_DATA, column, row, 'e007')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1450)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 10)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 345)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 300)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 21
            //******PRIEST*******
            call SaveInteger(UNIT_DATA, column, row, 'h011')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1650)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 7)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 335)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 300)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 'A0A3')
            set column = 0
            set row = row + 1
            
            //Index: 22
            //******WITCH DOCTOR*******
            call SaveInteger(UNIT_DATA, column, row, 'o009')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 1850)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 9)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 360)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 300)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 'A0A5')
            set column = 0
            set row = row + 1
            
            //Index: 23
            //******SORCERESS*******
            call SaveInteger(UNIT_DATA, column, row, 'h012')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 2050)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 9)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 370)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 300)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 24
            //******SIREN*******
            call SaveInteger(UNIT_DATA, column, row, 'n004')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 2250)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 8)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "4,5,6,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 460)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 300)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 25
            //******SPIRIT WALKER*******
            call SaveInteger(UNIT_DATA, column, row, 'o00A')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 2450)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 16)
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "5,6,7,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 585)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 300)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, -1)
            set column = 0
            set row = row + 1
            
            //Index: 26
            //******SHAMAN*******
            call SaveInteger(UNIT_DATA, column, row, 'o00B')
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 2650)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 7) 
            set column = column + 1
            call SaveStr(UNIT_DATA, column, row, "3,4,5,")
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 380)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 300)
            set column = column + 1
            call SaveInteger(UNIT_DATA, column, row, 'A0A6')
            
            //save the amount of all creeps
            set MAX_CREEPS = row
        endmethod
    
    endstruct

endlibrary