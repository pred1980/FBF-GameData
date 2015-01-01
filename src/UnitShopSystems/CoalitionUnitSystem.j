scope CoalitionUnitSystem initializer init

	globals
        private constant integer MAX_BUYABLE_UNITS = 9
        
		//Human
		private constant integer RIFLEMAN_ID = 'h00Z'
		private constant integer KNIGHT_ID = 'h00X'
		private constant integer SORCERESS_ID = 'h012'
		//Orc
		private constant integer GRUNT_ID = 'o004'
		private constant integer HEADHUNTER_ID = 'o007'
		private constant integer SHAMAN_ID = 'o00B'
		//Nightelf
		private constant integer ARCHER_ID = 'e005'
		private constant integer BEAR_ID = 'e000'
		private constant integer TALON_ID = 'e007'
	
		private constant real HP_MULTIPLIER = 0.25
		private constant real MANA_MULTIPLIER = 0.08
		private constant real DAMAGE_MULTIPLIER = 0.35
		private constant real ARMOR_MULTIPLIER = 0.45
		
        private integer rounds = 0
		private string array START_VAL[9][4]
		private hashtable DATA = InitHashtable()
	endglobals

	private function init takes nothing returns nothing
		local integer row = 0
		local integer column = 1
		local integer index = 0
		local string value = ""
		
		//Start HP Werte jeder einzelnen Einheit
		//Rifleman
		set START_VAL[0][0] = "535"
		set START_VAL[0][1] = "-1"
		set START_VAL[0][2] = "21"
		set START_VAL[0][3] = "0.6"
		
		//Knight
		set START_VAL[1][0] = "935"
		set START_VAL[1][1] = "-1"
		set START_VAL[1][2] = "34"
		set START_VAL[1][3] = "4.7"
		
		//Sorceress
		set START_VAL[2][0] = "385"
		set START_VAL[2][1] = "200"
		set START_VAL[2][2] = "11"
		set START_VAL[2][3] = "0.1"
		
		//Grunt
		set START_VAL[3][0] = "750"
		set START_VAL[3][1] = "-1"
		set START_VAL[3][2] = "19"
		set START_VAL[3][3] = "1.2"
		
		//Troll Headhunter
		set START_VAL[4][0] = "350"
		set START_VAL[4][1] = "-1"
		set START_VAL[4][2] = "25"
		set START_VAL[4][3] = "0.7"
		
		//Shaman
		set START_VAL[5][0] = "335"
		set START_VAL[5][1] = "200"
		set START_VAL[5][2] = "8"
		set START_VAL[5][3] = "0.1"
		
		//Archer
		set START_VAL[6][0] = "245"
		set START_VAL[6][1] = "-1"
		set START_VAL[6][2] = "17"
		set START_VAL[6][3] = "0.8"
		
		//Bear
		set START_VAL[7][0] = "960"
		set START_VAL[7][1] = "-1"
		set START_VAL[7][2] = "37"
		set START_VAL[7][3] = "3.2"
		
		//Talon
		set START_VAL[8][0] = "320"
		set START_VAL[8][1] = "200"
		set START_VAL[8][2] = "12"
		set START_VAL[8][3] = "0.1"
		
		//Speicher die Unit_Id in der Spalte "0" in jeder Reihe
		call SaveInteger(DATA, 0, 0, RIFLEMAN_ID)
		call SaveInteger(DATA, 0, 1, KNIGHT_ID)
		call SaveInteger(DATA, 0, 2, SORCERESS_ID)
		
		call SaveInteger(DATA, 0, 3, GRUNT_ID)
		call SaveInteger(DATA, 0, 4, HEADHUNTER_ID)
		call SaveInteger(DATA, 0, 5, SHAMAN_ID)
		
		call SaveInteger(DATA, 0, 6, ARCHER_ID)
		call SaveInteger(DATA, 0, 7, BEAR_ID)
		call SaveInteger(DATA, 0, 8, TALON_ID)
		
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
    
    struct CoalitionUnit
        
        static method updateProperties takes unit u returns nothing
            local integer row = 0
            local integer unitId = GetUnitTypeId(u)
            local real hp = 0.00
            local real mana = 0.00
            local integer damage = 0
            local integer armor = 0
            local integer round = RoundSystem.actualRound
            
            /* Nur f?r den Fall, falls einer zu Beginn des Spieles eine der Einheiten kauft,
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
            //set Mana
            if mana > 0 then
                call SetUnitMaxState(u, UNIT_STATE_MAX_MANA, mana)
                call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA) * RMaxBJ(0,100.) * 0.01)
            endif
            //set Damage
            call TDS.addDamage(u, damage)
            //set Armor
            call AddUnitBonus(u, BONUS_ARMOR, armor)
        endmethod
    
    endstruct

endscope