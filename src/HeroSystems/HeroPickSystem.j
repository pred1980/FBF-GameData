scope HeroPickSystem
    
    //****************************\\
    //****** CONFIGURATION *******\\
    //****************************\\
    globals
        private constant region array HERO_PICK_REGION[GET_MAX_HEROES()]
        private constant region array HERO_PICK_RANDOM_REGION[2]     
    endglobals
    
    //***********************************\\
    //***** GLOBAL HELPER FUNCTIONS *****\\
    //***********************************\\
    
    function getRegionIndex takes region r returns integer
        local integer i = 0
        local integer index = 0
        local integer max = GET_MAX_HEROES()
        
        loop
            exitwhen i > max
            if ( HERO_PICK_REGION[i] == r ) then
                set index = i
                set i = max
            endif
            set i = i + 1
        endloop
        return index
    endfunction
    
    struct BaseMode extends array
        static boolean array available
        static unit array pickedHero
        static integer array pickedHeroIndex
        static integer array regionIndex
        static boolean array hasPicked
        static integer array selectableHero
        static integer array repickCount
        static boolean array isRandom
        static boolean array gotRandomGold
        static string array origPlayerName
        
        static method onRandomEvent takes nothing returns boolean
            local integer index = getRandomHero()
            local unit u = GetTriggerUnit()
            local player p = GetOwningPlayer(u)
            local integer pid = GetPlayerId(p)
            
            loop
                exitwhen onEnterFilter(GetTriggerUnit(), index)
                set index = getRandomHero()
            endloop
            
            if GameMode.getCurrentMode() == 0 then
                call AllPick.createRandomHero( p, u, index )
            endif
            
            //Update the Number of Players who selected a hero
            call Game.updatePlayerCount()
            return false
        endmethod
        
        static method onEnterFilter takes unit u, integer index returns boolean
            local player p = GetOwningPlayer(u)
            local race r = GetUnitRace(u)
            local race h = GetUnitRace(FirstOfGroup(GetUnitsOfPlayerAndTypeId(Player(PLAYER_NEUTRAL_PASSIVE), GET_HERO(index))))
            local boolean b = false
            
			// General Condition
			if (IsUnitType(u, UNIT_TYPE_PEON) and BaseMode.available[index]) then
				if ( r == RACE_UNDEAD ) then
					if ( h == r ) then
						set b = true
					endif
				else
					if ( (h == r) or (h == RACE_OTHER) ) then
						set b = true
					else
						call Usability.getTextMessage(0, 7, true, p, true, 0.5)
					endif
				endif 
			endif

			
            return b
        endmethod
    
        static method onEnterEvent takes nothing returns boolean
            local integer index = getRegionIndex(GetTriggeringRegion())
            local unit u = GetTriggerUnit()
            local player p = GetOwningPlayer(u)
            local integer pid = GetPlayerId(p)
            
			if ( onEnterFilter(u, index) ) then
                if GameMode.getCurrentMode() == 0 then
                    call AllPick.step0( p, u, GetTriggeringRegion(), -1 )
                endif
                //Update the Number of Players who selected a hero
                call Game.updatePlayerCount()
                return true
            endif
            return false
        endmethod
        
        static method getRandomHero takes nothing returns integer
            local integer r = GetRandomInt(0, GET_MAX_HEROES() - 1)
            loop
                exitwhen BaseMode.available[r]
                set r = GetRandomInt(0, GET_MAX_HEROES() - 1)
            endloop
            
            return r
        endmethod
        
        static method onUpdateMultiboard takes integer pid returns nothing
            if ( Game.isPlayerInGame(pid) ) then
				call FBFMultiboard.onUpdateHeroIcon(pid)
                call FBFMultiboard.onUpdatePlayerName(pid)
                call FBFMultiboard.onUpdateHeroLevel(pid, pickedHero[pid])
                call FBFMultiboard.onUpdateHeroKills(pid)
                call FBFMultiboard.onUpdateUnitKills(pid)
                call FBFMultiboard.onUpdateDeaths(pid)
                call FBFMultiboard.onUpdateAssits(pid)
                call FBFMultiboard.onUpdateStatus(pid, pickedHero[pid])
            endif
        endmethod
        
        /* Entfernt den Helden vom Spielfeld, sobald er das Spiel verl?sst */
        static method removeHero takes integer pid returns nothing
            call RemoveUnit(.pickedHero[pid])
        endmethod
        
        static method onInit takes nothing returns nothing
            local integer i = 0
            
            loop
                exitwhen i > GET_MAX_HEROES()
                set .available[i] = true
                set .hasPicked[i] = false
                set .gotRandomGold[i] = false
                set i = i + 1
            endloop
            
            set i = 0
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if ( Game.isPlayerInGame(i) ) then
                    set .repickCount[i] = 0
                    set .origPlayerName[i] = GetPlayerName(Player(i))
                endif
                set i = i + 1
            endloop
        endmethod
        
        //returns the picked Hero
        public static method getPickedHero takes integer index returns unit
            return .pickedHero[index]
        endmethod
        
    endstruct
    
    struct HeroPickMode
    
        static method initialize takes nothing returns nothing
            local AllPick ap = 0
            local integer i = 0
			
			call ap.init()
			//create Hero Pick Units
			loop
				exitwhen i >= bj_MAX_PLAYERS
					if Game.isPlayerInGame(i) then
						call CREATE_HERO_PICK_UNIT(i)
						if Game.isRealPlayer(i) then
							call HeroPickTutorial.create(Player(i), ap.getHeroPickTimer())
						endif
					endif
				set i = i + 1
			endloop
		endmethod
    
    endstruct
    
    struct HeroPickSystem
        
        //required triggers
        static trigger onEnter = null
        static trigger onRandom = null
        static boolean started = false
        static integer heroCount = 0
		static string sound_1 = "Sound\\destiny.wav"
        
		private static method addRectEvent takes integer index, boolean random returns nothing
            if not ( random ) then
                set HERO_PICK_REGION[index] = CreateRegion()
                call RegionAddRect( HERO_PICK_REGION[index], OffsetRectBJ(GET_HERO_PICK_RECT(index), 0, 0) )
                call TriggerRegisterEnterRegion(.onEnter, HERO_PICK_REGION[index], null)
            else
                set HERO_PICK_RANDOM_REGION[index] = CreateRegion()
                call RegionAddRect( HERO_PICK_RANDOM_REGION[index], OffsetRectBJ(GET_HERO_PICK_RANDOM_RECT(index), 0, 0) )
                call TriggerRegisterEnterRegion(.onRandom, HERO_PICK_RANDOM_REGION[index], null)
            endif
        endmethod
    	
        static method initialize takes nothing returns nothing
            local integer i = 0
            
            set .started = true
            
            set .onEnter = CreateTrigger()
            set .onRandom = CreateTrigger()
            
            set .heroCount = GET_MAX_HEROES()
            
            // Register all Hero Circles ( Hero Pick )
            set i = 0
            loop
                exitwhen i > .heroCount
                call addRectEvent(i, false)
                set i = i + 1
            endloop
            call TriggerAddCondition(.onEnter, Condition(function BaseMode.onEnterEvent))
            
            //Register the Random Circles
            set i = 0
            loop
                exitwhen i > 1
                call addRectEvent(i, true)
                set i = i + 1
            endloop
            call TriggerAddCondition(.onRandom, Condition(function BaseMode.onRandomEvent))
            
            //preload Sound
			call Sound.preload(sound_1)
        endmethod
        
    endstruct
    
endscope