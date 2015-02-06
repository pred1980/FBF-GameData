scope StandardDefenseMode

    globals
        //saves all factors from the excel file (Forsaken Defense System)
        private constant hashtable FACTORS = InitHashtable()
        private constant hashtable SAVED_FACTORS = InitHashtable()
        private constant hashtable UNIT_DATA = InitHashtable()
        //****The Boni to HP and Damage for each Round a Creep is used
        private constant integer INCREASED_HP_AOS_PER_ROUND = 55
        private constant integer INCREASED_DAMAGE_PER_ROUND = 7
        //private constant real MANA_MULTIPLIER = 0.02
		//Wie viele Forsaken Verteidigungseinheiten gibt es?
        private constant integer MAX_UNDEAD = 8 
        private constant string SPAWN_EFFECT = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
		private constant integer MAX_SPAWN_POINTS = 6
        private rect array SPAWN_RECTS[MAX_SPAWN_POINTS][MAX_SPAWN_POINTS]
		//Should the units be removed after every round?
        private constant boolean REMOVE_CREEPS = true 
        private constant string EFFECT = "Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl"
        
        private integer rounds = 0
        private integer array unitIds
        private integer array startHP
        private integer array startDamage
		// Bounty je nach GameType -> GameConfig
        private string array bounty 
        
		//prozentualler Wert zum erhöhen pro Forsaken Creep Einheit
        private real array INCREASE 
        
        //Ist die Verteidigung aktiviert oder nicht?
        private constant boolean ACTIVATED = true
    endglobals
    
    //Diese Funktion gibt den Spawn Point zurück wo die Einheit gespawnt werden soll ( abh. von der Runde )
    private function getSpawnPoint takes real rndVal returns integer
		local integer i = 1
		local integer index = 0
		local real val = 0.00
		
        loop
			exitwhen i > MAX_SPAWN_POINTS or index > 0
			set val = val + DefenseCalc.getValue(RoundSystem.actualRound, i)
            if rndVal <= val then
				set index = i
			endif
			//Durch ungenauer Werte kann der Fall eintreten, dass der gespeicherte Werte trotzdem kleiner ist
			//als der RandomValue, dann wird immer der letzte Spawn Point genutzt
			if i == MAX_SPAWN_POINTS and index == 0 then
				set index = MAX_SPAWN_POINTS
			endif
			
			set i = i + 1
		endloop
		
        return index
	endfunction
    
    //Diese function erstellt die Einheit an der entsprechenden Stelle
    private function spawnUnit takes integer id, integer index returns nothing
        local unit u = null
        local integer unitLife = 0
        local integer damage = 0
        local integer rnd1 = 0
		local integer rnd2 = GetRandomInt(0, MAX_SPAWN_POINTS-1)
        local boolean b = false
        local real x = 0.00
        local real y = 0.00
		
			//Wenn nur Spieler auf der Forsaken Seite sind...
		if (Game.isOneSidedGame()) then
			set rnd1 = GetRandomInt(0, MAX_SPAWN_POINTS - 1)
		else
			//Wenn es Spieler auf beiden Seiten gibt...
			set rnd1 = getSpawnPoint(GetRandomReal(0,100)) - 1
		endif
        
        loop
            exitwhen b
            if SPAWN_RECTS[rnd1][rnd2] != null then
                set b = true
            else
                set rnd2 = GetRandomInt(0, MAX_SPAWN_POINTS-1)
            endif
        endloop
		
        //Zufalls x/y postion ermitteln
        set x = GetRandomReal(GetRectMinX(SPAWN_RECTS[rnd1][rnd2]), GetRectMaxX(SPAWN_RECTS[rnd1][rnd2]))
        set y = GetRandomReal(GetRectMinY(SPAWN_RECTS[rnd1][rnd2]), GetRectMaxY(SPAWN_RECTS[rnd1][rnd2]))
        set u = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), id, x, y, 0)
        set unitLife = S2I(getDataFromString(LoadStr(UNIT_DATA, RoundSystem.actualRound, index), 0))
        set damage = S2I(getDataFromString(LoadStr(UNIT_DATA, RoundSystem.actualRound, index), 1))
        call DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, GetUnitX(u), GetUnitY(u)))
        
        static if REMOVE_CREEPS then
            call ForsakenUnits.add(u)
        endif
        
        //set HP
        call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, unitLife)
        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
        //set Damage
        call TDS.addDamage(u, damage)
    endfunction
    
    //Diese Methode setzt alle gez?hlten Faktoren f?r die neue Runde auf 0
    private function resetFactors takes nothing returns nothing
        //call FlushParentHashtable(SAVED_FACTORS)
    endfunction
    
    private function countFactorForUnit takes unit creepUnit returns nothing
        local real unitLifePercent = GetUnitState(creepUnit, UNIT_STATE_LIFE) / GetUnitState(creepUnit, UNIT_STATE_MAX_LIFE)
        local integer row = GetUnitTypeId(creepUnit)
        local real factor = 0.00
        local integer unitId = 0
        local integer i = 0
        local real savedFactor = 0.00
        loop
            exitwhen i > MAX_UNDEAD
			set factor = LoadReal(FACTORS, i, row) * unitLifePercent
            set savedFactor = LoadReal(SAVED_FACTORS, i, row)
            set savedFactor = savedFactor + factor
            call SaveReal(SAVED_FACTORS, i, row, savedFactor)
			//value > 1.0 ? --> send undead unit
            if (savedFactor >= 1.0) then
				//reduce value by 1
                call SaveReal(SAVED_FACTORS, i, row, (savedFactor - 1.0))
                //get unit ID which concerning to the factor
                set unitId = unitIds[i]
                //spawn unit
                static if ACTIVATED then
			        call spawnUnit(unitId, i)
                endif
            endif
            set i = i + 1
        endloop
    endfunction
    
    struct ForsakenUnits
        static group g
        static boolean removeCreeps = REMOVE_CREEPS
        
        static method removeAll takes nothing returns nothing
            call ForGroup(.g, function thistype.onRemoveAll )
			call FBFMultiboard.onUpdateDefenders(0) //Update MB and set value to 0
        endmethod
        
        static method onRemoveAll takes nothing returns nothing
            local unit u = GetEnumUnit()
            
            if not IsUnitDead(u) then
                call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(u), GetUnitY(u)))
            endif
            
            call KillUnit(u)
            call RemoveUnit(u)
            call GroupRemoveUnit(.g, u)
        endmethod
        
        static method add takes unit u returns nothing
			call GroupAddUnit(.g, u)
        endmethod
		
		static method getCount takes nothing returns integer
			return CountUnitsInGroup(.g)
		endmethod
		
		static method remove takes unit u returns nothing
			call GroupRemoveUnit(.g, u)
		endmethod
		
		static method isForsakenUnit takes unit u returns boolean
			return IsUnitInGroup(u, .g)
		endmethod
		
		static method onInit takes nothing returns nothing
			set .g = CreateGroup()
		endmethod
    
    endstruct
    
    struct StandardDefenseInit extends IDefenseMode
            
        implement DefenseMode
        
        method getId takes nothing returns integer
            return thistype.id
        endmethod
        
        method getName takes nothing returns string
            return thistype.name
        endmethod
        
        method getDesc takes nothing returns string
            return thistype.desc
        endmethod
        
        method setUnitCounter takes integer value returns nothing
            set thistype.unitCounter = thistype.unitCounter + value
        endmethod
        
        method getUnitCounter takes nothing returns integer
            return thistype.unitCounter
        endmethod
        
        static method initialize takes nothing returns nothing
            set thistype.id = 0
            set thistype.name = "Standard Defense Mod"
            set thistype.desc = "A really cool Defense Mod"
            set rounds = RoundType.getRounds() // How many Rounds?
            
            call ForsakenDefenseUnits.initialize()
            call initUnitFactors()
            call initValues()
            call initRects()
            call resetFactors()
            call DefenseCalc.initialize()
            
        endmethod
        
        /*
         * This Method initializes all factors from the excel files
         */
         
         private static method initUnitFactors takes nothing returns nothing
            local integer row = 0
            local integer column = 0
            local integer index = 0 //das ist die Spalte, wo die UnitTypeId drin steht, und die steht immer in der 0. Spalte
            local integer incIndex = 0
            
            /*
             * Mit diesen Prozentwerden kann die Defense der Forsaken verstaerkt oder geschwaecht werden
             * 0.15 == 15% oder -0.10 == -10%
             */
            set INCREASE[0] = 0.00 //Ghul
            set INCREASE[1] = 0.00 //Fiends
            set INCREASE[2] = 0.00 //Abominations
            set INCREASE[3] = 0.00 //Necromancer
            set INCREASE[4] = 0.00 //Banshee
            set INCREASE[5] = 0.00 //Gargoyl
            set INCREASE[6] = 0.00 //Meat Wagon
            set INCREASE[7] = 0.00 //Frostwyrm
            set INCREASE[8] = 0.00 //Skeleton Warrior
            
            //******Row 0 --Murgul Reaver Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.50 + (0.50 * INCREASE[incIndex]))) //0(column),0(row) == Ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),0(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),0(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.15 + (0.15 * INCREASE[incIndex]))) //3(column),0(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),0(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.15 + (0.15 * INCREASE[incIndex]))) //5(column),0(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),0(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),0(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.20 + (0.20 * INCREASE[incIndex]))) //8(column),0(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 1 --Footman Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.72 + (0.72 * INCREASE[incIndex]))) //0(column),0(row) == Ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),0(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),0(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.14 + (0.14 * INCREASE[incIndex]))) //3(column),0(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.09 + (0.09 * INCREASE[incIndex]))) //4(column),0(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),0(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),0(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),0(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //8(column),0(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 2 --Huntress Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.70 + (0.70 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.23 + (0.23 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 3 --Raider Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.31 + (0.31 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.27 + (0.27 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.18 + (0.18 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.19 + (0.19 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 4 --Grunt Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.31 + (0.31 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.09 + (0.09 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.20 + (0.20 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.18 + (0.18 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.22 + (0.22 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 5 --Spellbreaker Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.90 + (0.90 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 6 --DotC (Nightelf) Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.45 + (0.45 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.31 + (0.31 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.14 + (0.14 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 7 --DotC (Bear) Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.23 + (0.23 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.31 + (0.31 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.09 + (0.09 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.06 + (0.06 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.31 + (0.31 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 8 --Knight Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.45 + (0.45 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.18 + (0.18 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.37 + (0.37 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 9 --Mountain Giant Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.81 + (0.81 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.19 + (0.19 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 10 --Tauren Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.68 + (0.68 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.02 + (0.02 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 11 --Royal Guard Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.09 + (0.09 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.81 + (0.81 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 12 --Archer Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.40 + (0.40 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.60 + (0.60 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 13 --Rifleman Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.18 + (0.18 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.31 + (0.31 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.18 + (0.18 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.28 + (0.28 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 14 --Headhunter Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.18 + (0.18 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.31 + (0.31 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.18 + (0.18 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.23 + (0.23 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 15 --Snap Dragon Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.45 + (0.45 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.41 + (0.41 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.14 + (0.14 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 16 --Dryad Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.31 + (0.31 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.45 + (0.45 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.24 + (0.24 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 17 --Motar Team Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.15 + (0.15 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.80 + (0.80 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.05 + (0.05 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0

            //******Row 18 --Kodo Beast Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.90 + (0.90 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.07 + (0.07 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0

            //******Row 19 --Dragon Turtle Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.50 + (0.50 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.20 + (0.20 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.30 + (0.30 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0

            //******Row 20 --DotT Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.50 + (0.50 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 21 --Priest Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.70 + (0.70 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.20 + (0.20 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 22 --Troll Medic Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.15 + (0.15 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 23 --Sorceress Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.34 + (0.34 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.15 + (0.15 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.16 + (0.16 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 24 --Siren Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.30 + (0.30 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.20 + (0.20 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.15 + (0.15 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.10 + (0.10 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
         
            //******Row 25 --GhostWalker Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.30 + (0.30 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.20 + (0.20 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
            set column = 0
            set row = row + 1
            set incIndex = 0
            
            //******Row 26 --Shaman Data ( Factor )--
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //0(column),1(row) == ghuls factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //1(column),1(row) == Fiends factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.20 + (0.20 * INCREASE[incIndex]))) //2(column),1(row) == Abominations factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //3(column),1(row) == Necromancer factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //4(column),1(row) == Banshee factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.30 + (0.30 * INCREASE[incIndex]))) //5(column),1(row) == Gargoyl factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //6(column),1(row) == Meat Wagon factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.00 + (0.00 * INCREASE[incIndex]))) //7(column),1(row) == Frostwyrm factor
            set column = column + 1
            set incIndex = incIndex + 1
            call SaveReal(FACTORS, column, GET_UNIT_DATA(index, row), (0.25 + (0.25 * INCREASE[incIndex]))) //8(column),1(row) == Skeleton Warrior factor
        endmethod
        
        /*
         * This function initializes all HP and Damage values for all undead defense units
         */
         
        private static method initValues takes nothing returns nothing
            local integer i = 0
            local integer j = 2
            local integer hp = 0
            local integer dmg = 0
            
            //Save all Undead Unit IDs in the first column in each row
            loop
                exitwhen i > MAX_UNDEAD
                call SaveInteger(UNIT_DATA, 0, i, unitIds[i])
                set i = i + 1
            endloop
            
            set i = 0
            //save all start values in the second column ( Round 1 )
            loop
                exitwhen i > MAX_UNDEAD
                call SaveStr(UNIT_DATA, 1, i, I2S(startHP[i])+","+I2S(startDamage[i]))
                set i = i + 1
            endloop
            
            set i = 0
            //now save the in column 1-20 all HP+Damage Values like for every rows
            //example: 400,15 (get Data from Array)
            loop
                exitwhen i > MAX_UNDEAD
                loop
                    exitwhen j > rounds + 1
                    set hp = S2I(getDataFromString(LoadStr(UNIT_DATA,j-1, i), 0)) + INCREASED_HP_AOS_PER_ROUND
                    set dmg  = S2I(getDataFromString(LoadStr(UNIT_DATA,j-1, i), 1)) + INCREASED_DAMAGE_PER_ROUND
                    call SaveStr(UNIT_DATA,j,i,I2S(hp)+","+I2S(dmg))
                    set j = j + 1
                endloop
                set i = i + 1
                set j = 2
            endloop
        endmethod
        
        /*
         * This functions initializes the Rectangles for all Unit Events ( spawn... )
         */
        
        static method onEnterCondition takes nothing returns boolean
            return GetOwningPlayer(GetTriggerUnit()) == Player(bj_PLAYER_NEUTRAL_VICTIM)
        endmethod
        
        static method onEnterAction takes nothing returns nothing
            call countFactorForUnit(GetTriggerUnit())
        endmethod
         
        private static method initRects takes nothing returns nothing
            local region rectRegion = CreateRegion()
            local trigger t = CreateTrigger()
            
            call RegionAddRect(rectRegion, gg_rct_countRect)
            call TriggerAddCondition(t, Condition(function thistype.onEnterCondition))
            call TriggerRegisterEnterRegion(t, rectRegion, null)
            call TriggerAddAction(t, function thistype.onEnterAction)
            
            //1 area
            set SPAWN_RECTS[0][0] = gg_rct_spawnRect0
            set SPAWN_RECTS[0][1] = gg_rct_spawnRect1
            set SPAWN_RECTS[0][2] = gg_rct_spawnRect2
            set SPAWN_RECTS[0][3] = null
            
            //2 area ( Spiders Terrain )
            set SPAWN_RECTS[1][0] = gg_rct_spawnRect3
            set SPAWN_RECTS[1][1] = gg_rct_spawnRect4
            set SPAWN_RECTS[1][2] = gg_rct_spawnRect5
            set SPAWN_RECTS[1][3] = null
            
            //3 area ( Graveyard )
            set SPAWN_RECTS[2][0] = gg_rct_spawnRect6
            set SPAWN_RECTS[2][1] = gg_rct_spawnRect7
            set SPAWN_RECTS[2][2] = gg_rct_spawnRect8
            set SPAWN_RECTS[2][3] = gg_rct_spawnRect9
            
            //4 area ( Abomination Way )
            set SPAWN_RECTS[3][0] = gg_rct_spawnRect10
            set SPAWN_RECTS[3][1] = gg_rct_spawnRect11
            set SPAWN_RECTS[3][2] = gg_rct_spawnRect12
            set SPAWN_RECTS[3][3] = null
			
			//5 area ( near the Broodmother )
            set SPAWN_RECTS[4][0] = gg_rct_spawnRect13
            set SPAWN_RECTS[4][1] = gg_rct_spawnRect14
            set SPAWN_RECTS[4][2] = gg_rct_spawnRect15
            set SPAWN_RECTS[4][3] = null
			
			//6 area ( vor dem Eingang zum Friedhof )
            set SPAWN_RECTS[5][0] = gg_rct_spawnRect16
            set SPAWN_RECTS[5][1] = gg_rct_spawnRect17
            set SPAWN_RECTS[5][2] = gg_rct_spawnRect18
            set SPAWN_RECTS[5][3] = null
            
        endmethod
        
    endstruct
    
    
    struct ForsakenDefenseUnits
    
        static method initialize takes nothing returns nothing
            call initUnits()
            call initUnitStartValues()
        endmethod
        
        /*
         * This function initialize all IDs for all defense units
         */
         
        private static method initUnits takes nothing returns nothing
            //Undead Units
            set unitIds[0] = 'u01V' //ghul
            set unitIds[1] = 'u01W' //fiend
            set unitIds[2] = 'u01Y' //abomination
            set unitIds[3] = 'u01Z' //necromancer
            set unitIds[4] = 'u021' //banshee
            set unitIds[5] = 'u026' //gargoyl
            set unitIds[6] = 'u027' //meat wagon
            set unitIds[7] = 'u028' //frost wyrm
            set unitIds[8] = 'u029' //skeleton warrior
        endmethod
        
        /*
         * This function initializes the start values (HP + Damage) of all undead units
		 * Changelog:
		 * 		04.02.2015: Alle Werte (HP+Damage) um 20% erhöht
         */
        
        private static method initUnitStartValues takes nothing returns nothing
            //Ghuls
            set startHP[0] = 288 //start HP Value
            set startDamage[0] = 17 //start Damage Value
            set bounty[0] = "1,2,3,"
            //Fiends
            set startHP[1] = 630 //start HP Value
            set startDamage[1] = 31 //start Damage Value
            set bounty[1] = "3,4,5,"
            //Abomination
            set startHP[2] = 1218 //start HP Value
            set startDamage[2] = 37 //start Damage Value
            set bounty[2] = "4,5,6,"
            //Necromancer
            set startHP[3] = 330 //start HP Value
            set startDamage[3] = 11 //start Damage Value
            set bounty[3] = "2,3,4,"
            //Banshee
            set startHP[4] = 330 //start HP Value
            set startDamage[4] = 10 //start Damage Value
            set bounty[4] = "2,3,4,"
            //Gargoyl
            set startHP[5] = 594 //start HP Value
            set startDamage[5] = 34 //start Damage Value
            set bounty[5] = "3,4,5,"
            //Meat Wagon
            set startHP[6] = 486 //start HP Value
            set startDamage[6] = 84 //start Damage Value
            set bounty[6] = "2,3,4,"
            //Frost Wyrm
            set startHP[7] = 1458 //start HP Value
            set startDamage[7] = 96 //start Damage Value
            set bounty[7] = "5,6,7,"
            //Skeleton Warrior
            set startHP[8] = 342 //start HP Value
            set startDamage[8] = 22 //start Damage Value
            set bounty[8] = "3,4,5,"
        endmethod
        
        static method getBounty takes unit u returns integer
            local integer i = 0
            local integer unitId = GetUnitTypeId(u)
            
            loop
                exitwhen i > MAX_UNDEAD
                if unitId == LoadInteger(UNIT_DATA, 0, i) then
                    return S2I(getDataFromString(bounty[i], RoundType.current))
                endif
                set i = i + 1
            endloop
            
            return -1
        endmethod
    
    endstruct
    
    /*
     * Berechnungsgrundlage fuer die Verteidigung durch die Untoten
     * Die math. Formel wurde von Richard Grosser geschrieben
     * Struktur der Hashtabel (UNIT_DATA):
     * --------------------------------
     *    i0    i1    i2     i3    i4 
     * R1 -   81,76  12,42  1,24  0,04
     * R2 -   74,11 ... ... ... ...
     * R3 -   ... ... ... ... ... ...
     *
     * Das bedeutet, das in der HT Prozentwerte stehen, die besagen, zu wie viel Prozent die Chance besteht,
     * dass eine Verteidigungseinheit an eine von den vier Stellen gespawnt wird bezogen auf die akt. Runde.
     */
     
    globals
        private constant hashtable WEIGHTS = InitHashtable() 
        private constant real array SIGMA
    endglobals
    
    struct DefenseCalc
        
        private static method weight takes integer round, integer column, integer coalitionHeroLevelSum, integer forsakenHeroLevelSum returns real
            local real my = (19 * column - 16) / 3
            local real weight = 0.00
			local real colHeroSum = coalitionHeroLevelSum
			local real forHeroSum = forsakenHeroLevelSum
			local real shiftedRound = 0.00
			local boolean isShiftedRound = false
			
			//Players on both sides?
			if not (Game.isOneSidedGame()) then
				set isShiftedRound = true
				set shiftedRound = I2R(round) * GetMin(1.0, I2R(coalitionHeroLevelSum)/I2R(forsakenHeroLevelSum))
			endif
            
			//Verteidigung abhängig der Heldenlevel beider Teams
            if (isShiftedRound) then
                set weight = 1/SquareRoot(2*bj_PI*Pow(SIGMA[column],2)) * Pow(bj_E, -Pow((shiftedRound - my), 2) / (2*Pow(SIGMA[column],2)))
            else
				//set weight = 1/SquareRoot(2*bj_PI*Pow(SIGMA[column],2)) * Pow(bj_E, -Pow((I2R(round) - my), 2) / (2*Pow(SIGMA[column],2)))
				set weight = 1/SquareRoot(2*bj_PI*Pow(SIGMA[column],2)) * Pow(bj_E, -Pow(my, 2) / (2*Pow(SIGMA[column],2)))
            endif
            
            return weight
        endmethod
		
		static method update takes nothing returns nothing
			local integer row = RoundSystem.actualRound
			local integer column = 1 // 5 places for spawning Defense units ( SPAWN_RECTS )
			local real sum = 0.00
            local real temp = 0.00
            local integer coalitionHeroLevel = Game.getCoalitionHeroLevelSum()
            local integer forsakenHeroLevel = Game.getForsakenHeroLevelSum()
			
			loop
				exitwhen column > MAX_SPAWN_POINTS
				call SaveReal(WEIGHTS, column, row, weight(row, column, coalitionHeroLevel, forsakenHeroLevel))
				set sum = sum + weight(row, column, coalitionHeroLevel, forsakenHeroLevel)
				set column = column + 1
			endloop
            
			set column = 1
			
            loop
				exitwhen column > MAX_SPAWN_POINTS
				set temp = LoadReal(WEIGHTS, column, row)
				set temp = (temp * 100) / sum
				call SaveReal(WEIGHTS, column, row, temp)
				set column = column + 1
			endloop
		endmethod
        
        static method initialize takes nothing returns nothing
            set SIGMA[1] = 3.5
            set SIGMA[2] = 1.5
            set SIGMA[3] = 2.0
            set SIGMA[4] = 2.8
			set SIGMA[5] = 3.2
			set SIGMA[6] = 2.2
        endmethod
        
        //index is the spawn place from 1 to 5
        static method getValue takes integer round, integer index returns real
            return LoadReal(WEIGHTS, index, round)
        endmethod
        
        static method getMainSpawnPointIndex takes nothing returns integer
            local integer i = 1
            local integer index = 0
            local real val = 0.00
            local real maxVal = 0.00
            
            loop
                exitwhen i > MAX_SPAWN_POINTS
                set val = DefenseCalc.getValue(RoundSystem.actualRound, i)
                if val >= maxVal then
                    set maxVal = val
                    set index = i - 1 //muss um einen abgezogen werden denn die Spawn Point beginnen ab Index 0
                endif
                set i = i + 1
            endloop
            
            return index
        endmethod
        
    endstruct
    
endscope