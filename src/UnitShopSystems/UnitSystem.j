scope UnitSystem initializer init

	globals
        private constant integer MAX_BUYABLE_UNITS = 19
        
		//Human
		private constant integer FOOTMAN_ID = 'h006'
		private constant integer RIFLEMAN_ID = 'h00Z'
		private constant integer KNIGHT_ID = 'h00X'
		private constant integer MOTAR_TEAM_ID = 'h010'
		private constant integer PRIEST_ID = 'h011'
		private constant integer SORCERESS_ID = 'h012'
		
		//Orc
		private constant integer GRUNT_ID = 'o004'
		private constant integer RAIDER_ID = 'o003'
		private constant integer HEADHUNTER_ID = 'o007'
		private constant integer TAUREN_ID = 'o006'
		private constant integer SHAMAN_ID = 'o00B'
		private constant integer WITCH_DOCTOR_ID = 'o009'
		
		//Nightelf
		private constant integer ARCHER_ID = 'e005'
		private constant integer HUNTRESS_ID = 'e006'
		private constant integer DRYAD_ID = 'e004'
		private constant integer MOUNTAIN_GIANT_ID = 'e003'
		private constant integer BEAR_ID = 'e000'
		private constant integer TALON_ID = 'e007'
		
		//Forsaken
		private constant integer SCARAB_ID = 'u00B'
	
		private constant real HP_MULTIPLIER = 0.25
		private constant real MANA_MULTIPLIER = 0.08
		private constant real DAMAGE_MULTIPLIER = 0.35
		private constant real ARMOR_MULTIPLIER = 0.45
		
        private integer rounds = 0
		private string array START_VAL[MAX_BUYABLE_UNITS][4]
		private hashtable DATA = InitHashtable()
	endglobals

	private function init takes nothing returns nothing
		local integer row = 0
		local integer column = 1
		local integer index = 0
		local string value = ""
		
		//Start HP Werte jeder einzelnen Einheit
		//Rifleman (Human)
		set START_VAL[0][0] = "535" //HP
		set START_VAL[0][1] = "-1"  //Mana (-1 == kein Mana)
		set START_VAL[0][2] = "21"  //Damage
		set START_VAL[0][3] = "0.6" //Armor
		
		//Knight (Human)
		set START_VAL[1][0] = "935"
		set START_VAL[1][1] = "-1"
		set START_VAL[1][2] = "34"
		set START_VAL[1][3] = "4.7"
		
		//Sorceress (Human)
		set START_VAL[2][0] = "385"
		set START_VAL[2][1] = "200"
		set START_VAL[2][2] = "11"
		set START_VAL[2][3] = "0.1"
		
		//Grunt (Orc)
		set START_VAL[3][0] = "750"
		set START_VAL[3][1] = "-1"
		set START_VAL[3][2] = "19"
		set START_VAL[3][3] = "1.2"
		
		//Troll Headhunter (Orc)
		set START_VAL[4][0] = "350"
		set START_VAL[4][1] = "-1"
		set START_VAL[4][2] = "25"
		set START_VAL[4][3] = "0.7"
		
		//Shaman (Orc)
		set START_VAL[5][0] = "335"
		set START_VAL[5][1] = "200"
		set START_VAL[5][2] = "8"
		set START_VAL[5][3] = "0.1"
		
		//Archer Nightelf)
		set START_VAL[6][0] = "245"
		set START_VAL[6][1] = "-1"
		set START_VAL[6][2] = "17"
		set START_VAL[6][3] = "0.8"
		
		//Bear Nightelf)
		set START_VAL[7][0] = "960"
		set START_VAL[7][1] = "-1"
		set START_VAL[7][2] = "37"
		set START_VAL[7][3] = "3.2"
		
		//Talon (Nightelf)
		set START_VAL[8][0] = "320"
		set START_VAL[8][1] = "200"
		set START_VAL[8][2] = "12"
		set START_VAL[8][3] = "0.1"
		
		//Footman (Human)
		set START_VAL[9][0] = "320"
		set START_VAL[9][1] = "-1"
		set START_VAL[9][2] = "11"
		set START_VAL[9][3] = "2.0"
		
		//Motar Team (Human)
		set START_VAL[10][0] = "360"
		set START_VAL[10][1] = "-1"
		set START_VAL[10][2] = "51"
		set START_VAL[10][3] = "0.5"
		
		//Priest (Human)
		set START_VAL[11][0] = "290"
		set START_VAL[11][1] = "200"
		set START_VAL[11][2] = "7"
		set START_VAL[11][3] = "0.1"
		
		//Raider (Orc)
		set START_VAL[12][0] = "610"
		set START_VAL[12][1] = "-1"
		set START_VAL[12][2] = "22"
		set START_VAL[12][3] = "0.8"
		
		//Tauren (Orc)
		set START_VAL[13][0] = "1300"
		set START_VAL[13][1] = "-1"
		set START_VAL[13][2] = "29"
		set START_VAL[13][3] = "3.2"
		
		//Witch Doctor (Orc)
		set START_VAL[14][0] = "315"
		set START_VAL[14][1] = "200"
		set START_VAL[14][2] = "9"
		set START_VAL[14][3] = "0.1"
		
		//Huntress (Nightelf)
		set START_VAL[15][0] = "575"
		set START_VAL[15][1] = "-1"
		set START_VAL[15][2] = "15"
		set START_VAL[15][3] = "2.0"
		
		//Dryad (Nightelf)
		set START_VAL[16][0] = "435"
		set START_VAL[16][1] = "200"
		set START_VAL[16][2] = "14"
		set START_VAL[16][3] = "0.3"
		
		//Mountain Giant (Nightelf)
		set START_VAL[17][0] = "1400"
		set START_VAL[17][1] = "-1"
		set START_VAL[17][2] = "26"
		set START_VAL[17][3] = "0.7"
		
		//Scarab (Forsaken)
		set START_VAL[18][0] = "625"
		set START_VAL[18][1] = "-1"
		set START_VAL[18][2] = "32"
		set START_VAL[18][3] = "2.1"
		
		
		//Speicher die Unit_Id in der Spalte "0" in jeder Reihe
		//Human
		call SaveInteger(DATA, 0, 9, FOOTMAN_ID)
		call SaveInteger(DATA, 0, 0, RIFLEMAN_ID)
		call SaveInteger(DATA, 0, 10, MOTAR_TEAM_ID)
		call SaveInteger(DATA, 0, 1, KNIGHT_ID)
		call SaveInteger(DATA, 0, 11, PRIEST_ID)
		call SaveInteger(DATA, 0, 2, SORCERESS_ID)
		//Orc
		call SaveInteger(DATA, 0, 3, GRUNT_ID)
		call SaveInteger(DATA, 0, 12, RAIDER_ID)
		call SaveInteger(DATA, 0, 4, HEADHUNTER_ID)
		call SaveInteger(DATA, 0, 13, TAUREN_ID)
		call SaveInteger(DATA, 0, 5, SHAMAN_ID)
		call SaveInteger(DATA, 0, 14, WITCH_DOCTOR_ID)
		//Nightelf
		call SaveInteger(DATA, 0, 6, ARCHER_ID)
		call SaveInteger(DATA, 0, 15, HUNTRESS_ID)
		call SaveInteger(DATA, 0, 16, DRYAD_ID)
		call SaveInteger(DATA, 0, 17, MOUNTAIN_GIANT_ID)
		call SaveInteger(DATA, 0, 7, BEAR_ID)
		call SaveInteger(DATA, 0, 8, TALON_ID)
		//Forsaken
		call SaveInteger(DATA, 0, 18, SCARAB_ID)
		
        // How many Rounds?
        set rounds = RoundType.getRounds() 
        
		loop
			exitwhen row == MAX_BUYABLE_UNITS
			loop
				exitwhen column > rounds
				loop
					exitwhen index == 4
					if index == 0 then
						set value = value + I2S(R2I((S2R(START_VAL[row][index]) + (I2R(column) * (S2R(START_VAL[row][index]) * HP_MULTIPLIER))))) //HP
					elseif index == 1 then
						set value = value + "," + I2S(R2I((S2R(START_VAL[row][index]) + (I2R(column) * (S2R(START_VAL[row][index]) * MANA_MULTIPLIER))))) //Mana
					elseif index == 2 then
						set value = value + "," + I2S(R2I((S2R(START_VAL[row][index]) + (I2R(column) * (S2R(START_VAL[row][index]) * DAMAGE_MULTIPLIER))))) //Damage
					else
						set value = value + "," + R2S((S2R(START_VAL[row][index]) + (I2R(column) * (S2R(START_VAL[row][index]) * ARMOR_MULTIPLIER)))) + "," //Armor
					endif
					set index = index + 1
				endloop
				//speichere den String der 4 Werte nun in der Hashtable
				call SaveStr(DATA, column, row, value) //(HP,MANA,DAMAGE,ARMOR,) Beispiel: "535,200,21,0.6,"
				set value = ""
				set index = 0
				set column = column + 1
			endloop
			set column = 1
			set row = row + 1
		endloop
		
	endfunction
    
    struct CreepUnit
        
        static method updateProperties takes unit u returns nothing
            local integer row = 0
            local integer unitId = GetUnitTypeId(u)
            local real hp = 0.00
            local real mana = 0.00
            local integer damage = 0
            local integer armor = 0
            local integer round = RoundSystem.actualRound
            
            /* Nur für den Fall, falls einer zu Beginn des Spieles eine der Einheiten kauft,
             * dass diese dann schon die HP/Mana... Werte der ersten Runde haben, da RoundSystem.actualRound
             * erst zum Begin der ersten Runde auf 1 steht, vorher 0
             */
            if round == 0 then
                set round = 1
            endif
            
            loop
                exitwhen row > MAX_BUYABLE_UNITS
                if LoadInteger(DATA, 0, row) == unitId then
                    set hp = S2R(getDataFromString(LoadStr(DATA, round, row), 0))
                    set mana = S2R(getDataFromString(LoadStr(DATA, round, row), 1))
                    set damage = S2I(getDataFromString(LoadStr(DATA, round, row), 2))
                    set armor = S2I(getDataFromString(LoadStr(DATA, round, row), 3))
                    set row = MAX_BUYABLE_UNITS
                endif
                set row = row + 1
            endloop
            
            //set HP
            call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, hp)
			call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100) * 0.01)
            //set Mana
            if mana > 0 then
                call SetUnitMaxState(u, UNIT_STATE_MAX_MANA, mana)
                call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA) * RMaxBJ(0,100) * 0.01)
            endif
            //set Damage
            call TDS.addDamage(u, damage)
            //set Armor
            call AddUnitBonus(u, BONUS_ARMOR, armor)
        endmethod
    
    endstruct

endscope