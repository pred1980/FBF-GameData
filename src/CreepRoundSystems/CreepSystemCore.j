library CreepSystemCore initializer init requires CreepSystemUnits, TimerUtils, UnitMaxState optional AddDamageSystem

    globals
        private constant real array START_LOC_X
        private constant real array START_LOC_Y
        //Dieser Punkt ist der Endpunkt der TD-Waypoints aller Lanes
        //sowie der Startpunkt für den AoS Teil
        private real AOS_START_LOC_X
        private real AOS_START_LOC_Y
		
		//Zuordnung Player-Id zu WAYPOINT-Index
		//Wird benötigt, damit für P6-12 die Creeps an den richtigen Lanes loslaufen
		private constant integer array PLAYER__X__WAYPOINT
        
        //Berechnungsgrundlage für die HP, Mana und Damage Werte pro Runde
        private constant integer INCREASED_HP_TD_PER_ROUND = 90
        private constant integer INCREASED_HP_AOS_PER_ROUND = 35
        private constant integer INCREASED_DAMAGE_PER_ROUND = 4
        private constant integer INCREASED_MANA_PER_ROUND = 20
    endglobals
    
    private function initLocations takes nothing returns nothing
		/* Forsaken */
        //Player 1 (index 0) == StartLocation of Player 9 (index 8)
        set START_LOC_X[0] = GetStartLocationX(8)
        set START_LOC_Y[0] = GetStartLocationY(8)
        //Player 2 (index 1) == StartLocation of Player 10 (index 9)
        set START_LOC_X[1] = GetStartLocationX(9)
        set START_LOC_Y[1] = GetStartLocationY(9)
        //Player 3 (index 2) == StartLocation of Player 7 (index 6)
        set START_LOC_X[2] = GetStartLocationX(6)
        set START_LOC_Y[2] = GetStartLocationY(6)
        //Player 4 (index 3) == StartLocation of Player 8 (index 7)
        set START_LOC_X[3] = GetStartLocationX(7)
        set START_LOC_Y[3] = GetStartLocationY(7)
        //Player 5 (index 4) == StartLocation of Player 11 (index 10)
        set START_LOC_X[4] = GetStartLocationX(10)
        set START_LOC_Y[4] = GetStartLocationY(10)
        //Player 6 (index 5) == StartLocation of Player 12 (index 11)
        set START_LOC_X[5] = GetStartLocationX(11)
        set START_LOC_Y[5] = GetStartLocationY(11)
		
		/* Coalition */
		//Player 7 (index 0) == StartLocation of Player 9 (index 8)
        set START_LOC_X[8] = GetStartLocationX(8)
        set START_LOC_Y[8] = GetStartLocationY(8)
        //Player 8 (index 1) == StartLocation of Player 10 (index 9)
        set START_LOC_X[9] = GetStartLocationX(9)
        set START_LOC_Y[9] = GetStartLocationY(9)
        //Player 9 (index 2) == StartLocation of Player 7 (index 6)
        set START_LOC_X[6] = GetStartLocationX(6)
        set START_LOC_Y[6] = GetStartLocationY(6)
        //Player 10 (index 3) == StartLocation of Player 8 (index 7)
        set START_LOC_X[7] = GetStartLocationX(7)
        set START_LOC_Y[7] = GetStartLocationY(7)
        //Player 11 (index 4) == StartLocation of Player 11 (index 10)
        set START_LOC_X[10] = GetStartLocationX(10)
        set START_LOC_Y[10] = GetStartLocationY(10)
        //Player 12 (index 5) == StartLocation of Player 12 (index 11)
        set START_LOC_X[11] = GetStartLocationX(11)
        set START_LOC_Y[11] = GetStartLocationY(11)
    endfunction
    
    
    /***********************
     *    S T R U C T S    *
     ***********************/
     
    struct RoundText
    
        static string array roundText
    
        static method getTextOfRound takes integer round returns string
            return roundText[round]
        endmethod
        
        static method onInit takes nothing returns nothing
    
            set roundText[1] = "Scouting... (Mur'gul Reaver and Archer)"
            set roundText[2] = "The Vanguard (Footman and Rifleman)"
            set roundText[3] = "Hit and Run (Huntress)"
            set roundText[4] = "The Siege Part I (Raider and Headhunter)"
            set roundText[5] = "Brute Force (Grunt)"
            set roundText[6] = "Mages, beware! (Spellbreaker and Snap Dragon)"
            set roundText[7] = "Call of Nature (Dryad and Druid of the Talon)"
            set roundText[8] = "The Siege Part II (Mortar Team)"
            set roundText[9] = "Support Team (Priest)"
            set roundText[10] = "The Call for a Doctor (Troll Witch Doctor)"
            set roundText[11] = "The Drums of War (Kodo Beast)"
            set roundText[12] = "Slow Bitches (Sorceress)"
            set roundText[13] = "Alluring Magic (Naga Siren)"
            set roundText[14] = "Sons of Mother Earth (Spirit Walker)"
            set roundText[15] = "Unstoppable Frenzy (Shaman)"
            set roundText[16] = "The Siege Part III (Druid of the Claw and Dragon Turtle)"
            set roundText[17] = "The Human Finale (Knight)"
            set roundText[18] = "The Nightelf Finale (Mountain Giant)"
            set roundText[19] = "The Orc Finale (Tauren)"
            set roundText[20] = "The Grand Finale (Naga Royal Guard)"
        endmethod
    
    endstruct
    
    /*
     * Der RoundMultiplier ist dazu da um den Creep Units je nach Anzahl der Forsaken Spieler im TD Teil eine
     * entsprechend hoehere oder niedrigere HP zu vergeben.
     */ 
    
    struct ConfigMultipliers
        
        private static real hpFactor = 0.08
        private static real roundFactor = 0.05
        
        private static real array hpMultipliers
        private static real array roundMultipliers
        
        static method getHpMultiplier takes nothing returns real
            return hpMultipliers[Game.getForsakenPlayers()]
        endmethod
        
        static method getRoundMultiplier takes nothing returns real
            return roundMultipliers[RoundSystem.actualRound]
        endmethod
        
        static method onInit takes nothing returns nothing
            local integer i = 2
            
            set hpMultipliers[1] = 1.0
            loop
                exitwhen i > 6
                set hpMultipliers[i] = hpMultipliers[i-1] + (hpMultipliers[i-1] * hpFactor)
                set i = i + 1
            endloop
            
            set i = 2
            set roundMultipliers[1] = 1.0
            loop
                exitwhen i > 20
                set roundMultipliers[i] = roundMultipliers[i-1] + (roundMultipliers[i-1] * roundFactor)
                set i = i + 1
            endloop
            
        endmethod
    endstruct
    
    struct RoundType extends array
        static integer current = 0
        
        //TD Types
        static SCC_One sccOne
        static SCC_Two sccTwo
        static SCC_Three sccThree
		static SCC_Four sccFour
        static SCC_Five sccFive
        static SCC_Six sccSix
        
        static IRound array CONFIG
        
        /* Diese Methode wird vor jeder Runde aufgerufen und setzt die akt. Wert dafür, welche Config verwendet werden soll. */
        static method updateRoundConfig takes nothing returns nothing
			if (Game.getForsakenPlayers() > 0) then
				set current = Game.getForsakenPlayers() - 1
			else
				set current = Game.getCoalitionPlayers() - 1
			endif
		 endmethod
        
        static method onInit takes nothing returns nothing
            set sccOne = SCC_One.create()
            set sccTwo = SCC_Two.create()
            set sccThree = SCC_Three.create()
			set sccFour = SCC_Four.create()
            set sccFive = SCC_Five.create()
            set sccSix = SCC_Six.create()
            
            set CONFIG[0] = sccOne
            set CONFIG[1] = sccTwo
            set CONFIG[2] = sccThree
			set CONFIG[3] = sccFour
            set CONFIG[4] = sccFive
            set CONFIG[5] = sccSix
        endmethod
        
        static method getInterval takes nothing returns real
            return CONFIG[current].getInterval()
        endmethod
        
        static method getIterator takes integer round returns integer
            return CONFIG[current].getIterator(round)
        endmethod
        
        static method getCount takes nothing returns integer
            return CONFIG[current].getCount()
        endmethod
        
        static method getUnitIndex takes integer i, integer round returns integer
            return CONFIG[current].getUnitIndex(i, round)
        endmethod

        static method getUnitAmount takes integer i, integer round returns integer
            return CONFIG[current].getUnitAmount(i, round)
        endmethod
        
        static method getRoundTimer takes nothing returns real
            return CONFIG[current].getRoundTimer()
        endmethod
        
        static method getStartNextRound takes nothing returns integer
            return CONFIG[current].getStartNextRound()
        endmethod
        
        static method getRounds takes nothing returns integer
            return CONFIG[current].getRounds()
        endmethod
        
        static method getPause takes nothing returns real
            return CONFIG[current].getPause()
        endmethod
        
    endstruct
    
    /***************************************
     *    U N I T   S P A W N   C O R E    *
     ***************************************/
     
    function interface onSpawn takes nothing returns nothing
    function interface onCheck takes nothing returns boolean
    function interface onUnitSpawn takes unit u returns nothing
    function interface getUnitId takes integer unitId returns integer
    function interface getUnitIndex takes unit u returns integer
    function interface getUnitMaxLife takes integer unitId, boolean isAos returns integer
    function interface getUnitMaxMana takes integer unitId returns integer
    function interface getUnitDamage takes integer unitId returns integer
    function interface getUnitAbility takes integer unitId returns integer
    
    struct SharedObjects
        onSpawn spawnCall = 0
        onCheck checkCall = 0
        boolean isSetSpawn = false
        boolean isSetCheck = false
        
        method setOnSpawnCall takes onSpawn onS returns nothing
            set .spawnCall = onS
            set .isSetSpawn = true
        endmethod
        
        method runOnSpawnCall takes nothing returns nothing
            if .isSetSpawn then
                call .spawnCall.execute()
            endif
        endmethod
        
        method setOnSpawnCheck takes onCheck onC returns nothing
            set .checkCall = onC
            set .isSetCheck = true
        endmethod
        
        method runOnSpawnCheck takes nothing returns boolean
            if .isSetCheck then
                return .checkCall.evaluate()
            endif
            return true
        endmethod
        
        method getUnitId takes integer index returns integer
            return GET_UNIT_DATA(0, index)
        endmethod
        
        static method getUnitIndex takes unit u returns integer
            //-1 bedeutet, dass der Index(row) zurueck gegeben werden soll, siehe GET_UNIT_VALUE
            return GET_UNIT_VALUE(GetUnitTypeId(u), -1) 
        endmethod
        
        static method getUnitMaxLife takes integer index, boolean isAos returns integer
            /* index: Das ist die row f?r den Trigger CS Units --> GET_UNIT_DATA, sprich der Creep f?r den
             *       die HP gesetzt werden soll
             * Die Berechnung erfolgt lt. der Exceltabelle, d.h.
             * ConfigMultipliers.getHpMultiplier() ist ein Faktor der mit der HP multipliziert wird um die HP hoch zu setzen, bei mehr Forsaken Spielern
             * Beispiel:
             * die Basis HP + (Aktuelle Round * INCREASED_HP_AOS_PER_ROUND)
             */
            if isAos then
                return GET_UNIT_DATA(4, index) + (RoundSystem.actualRound * INCREASED_HP_AOS_PER_ROUND)
            else
                return R2I((I2R(GET_UNIT_DATA(1, index)) * ConfigMultipliers.getHpMultiplier()) + (I2R((RoundSystem.actualRound * INCREASED_HP_TD_PER_ROUND)) * ConfigMultipliers.getHpMultiplier()))
            endif
        endmethod
        
        static method getUnitMaxMana takes integer index returns integer
            local integer val = GET_UNIT_DATA(5, index)
            if val == 0 then
                return 0
            else
                return val + (RoundSystem.actualRound * INCREASED_MANA_PER_ROUND)
            endif
        endmethod
        
        method getUnitDamage takes integer index returns integer
            return GET_UNIT_DATA(2, index) + (RoundSystem.actualRound * INCREASED_DAMAGE_PER_ROUND)
        endmethod
        
        static method getUnitAbility takes integer index returns integer
            return GET_UNIT_DATA(6, index)
        endmethod
    endstruct
    
    struct UnitSpawn extends SharedObjects
        integer ID = 0
        
        integer unitID = '0000'
        integer pID = 0
        integer amount = 0
        
        string sfxPath = ""
        
        onUnitSpawn onUnitSpawnCall = 0
        
        static method create takes integer pid, integer unitId, integer amount, onUnitSpawn onUnitSp, string effPath returns UnitSpawn
            local thistype us = thistype.allocate()
                set us.unitID = unitId
                set us.pID = pid
                set us.amount = amount
                set us.onUnitSpawnCall = onUnitSp
                set us.sfxPath = effPath
            return us
        endmethod
        
        method spawn takes player p, integer unitIndex, real posX, real posY returns nothing
            local integer i = 0
            local unit u = null
            local integer abiId = 0
            
            if .runOnSpawnCheck() then
                call .runOnSpawnCall()
                loop
                    exitwhen i >= .amount
                    set u = CreateUnit(p, .unitID, posX, posY, 270)
                    
                    call SetUnitPathing(u, false)
                    call SetUnitX(u, posX)
                    call SetUnitY(u, posY)
					
					//Creep Fähigkeit für TD Teil deaktivieren indem man sie kurz entfernt
                    set abiId = SharedObjects.getUnitAbility(SharedObjects.getUnitIndex(u))
                    if abiId != -1 then
                        //call UnitRemoveAbility(u, abiId)
                        call SetUnitAbilityLevel(u, abiId, 2)
                    endif
                    
                    if .sfxPath != "" then
                        call DestroyEffect(AddSpecialEffect(.sfxPath, GetUnitX(u), GetUnitY(u)))
                    endif
                    
                    //add HP, Mana and Damage
                    call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, I2R(.getUnitMaxLife(unitIndex, false)))
                    call TDS.addDamage(u, .getUnitDamage(unitIndex))
                                        
                    if .onUnitSpawnCall != 0 then
                        call .onUnitSpawnCall.execute(u) 
                    endif
                    
                    //add Unit to the WayPointSystem ( TD Part )
                    call WayPointSystem.addUnit(PLAYER__X__WAYPOINT[.pID], u)
                    
                    set i = i + 1
                endloop
            endif
            
            set u = null
        endmethod
		
		private static method onInit takes nothing returns nothing
			set PLAYER__X__WAYPOINT[0] = 0
			set PLAYER__X__WAYPOINT[1] = 1
			set PLAYER__X__WAYPOINT[2] = 2
			set PLAYER__X__WAYPOINT[3] = 3
			set PLAYER__X__WAYPOINT[4] = 4
			set PLAYER__X__WAYPOINT[5] = 5
			
			set PLAYER__X__WAYPOINT[6] = 2
			set PLAYER__X__WAYPOINT[7] = 3
			set PLAYER__X__WAYPOINT[8] = 0
			set PLAYER__X__WAYPOINT[9] = 1
			set PLAYER__X__WAYPOINT[10] = 4
			set PLAYER__X__WAYPOINT[11] = 5
		endmethod
    endstruct
    
    /*******************************
     *    W A V E   C O N F I G    *
     *******************************/
     
    struct Wave extends SharedObjects
        
        player owner = null
        integer pid = 0
        
        integer id
        integer unitIndex
        integer amount
        integer count
        integer iterator 
        integer rounds
        real interval
        
        UnitSpawn us = 0
        integer round = 0
        integer i = 0
        integer k = 1
        
        static method create takes player p, integer pid, integer r returns thistype
            local thistype this = thistype.allocate()
            local timer t
            
            set .round = r
            set .owner = p
            set .pid = pid
            
            set .interval = RoundType.getInterval()
            set .iterator = RoundType.getIterator(.round)
            set .count = RoundType.getCount()
            
            set t = NewTimer()
            call SetTimerData(t, this)
            call TimerStart(t, .interval, true, function thistype.onSpawnInterval)

            return this
        endmethod
        
        static method onSpawnInterval takes nothing returns nothing
            local Wave this = GetTimerData(GetExpiredTimer())
            
            //get Unit Index of the spawing Unit
            set this.unitIndex = RoundType.getUnitIndex(this.i, this.round)
            //get Unit ID of the spawing Unit
            set this.id = this.us.getUnitId(this.unitIndex)
            set this.amount = RoundType.getUnitAmount(this.i, this.round)
            set this.us = UnitSpawn.create(this.pid, this.id, this.count, 0, "")
            
            call this.us.spawn(this.owner, this.unitIndex, START_LOC_X[this.pid], START_LOC_Y[this.pid])
            
            if this.k < this.amount then
                set this.k = this.k + 1
            else
                set this.k = 1
                set this.i = this.i + 1
                if this.i == this.iterator then
                    call ReleaseTimer(GetExpiredTimer())
                endif
            endif
        endmethod
        
    endstruct
     
    private function init takes nothing returns nothing
        call initLocations()
    endfunction

endlibrary
