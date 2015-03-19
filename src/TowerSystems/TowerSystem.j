scope TowerSystem

	/*
	  HOW TO USE:
	       * function IsUnitFinished takes unit u returns boolean
	       * function IsUnitBeingBuilt takes unit u returns boolean
	       * function IsUnitBeingUpgraded takes unit u returns boolean
	
	       * Note that these 3 functions will return false if the unit is dead or not valid (for example == null)
	
	  NOTE:
	       * It will fail if the unit has an usable revive ability if the unit die during the upgrade or construction
	       * I could handle it thought, let me know if you have the use of it, but then you have to know that it will require more stuff
	*/
    
    /*
     * Hashtable:
     * 0 = Tower Id
     * 1 = Tower Damage
     * 2 = Tower Ability
     * 3 = Tower Ability Level
     */
    
    
	globals
        private constant integer ACOLYTE_I_ID = 'u00Q'
        private constant integer ACOLYTE_II_ID = 'u008'
        private constant integer ACOLYTE_III_ID = 'u006'
        private constant integer SELL = 'n005'
        private constant integer MAX_TOWERS = 33
        
		private hashtable TOWER_DATA = InitHashtable()
        private unit array ACOLYTS
        private real array START_POS_X
        private real array START_POS_Y
		
		// It is the periodic time (seconds) which the group will be refreshed (ghost units are removed)
		private constant real TIME_OUT = 30.0 
		private group BEING_BUILT_UNITS
		private group BEING_UPGRADE_UNITS
        
        private constant integer MAX_NON_TOWER_AREAS = 10 //Anzahl der Gebiete wo keine T?rme gebaut werden d?rfen
        private rect array NON_TOWER_RECTS
    endglobals
	
	function IsUnitFinished takes unit u returns boolean
		return GetUnitTypeId(u) != 0 and not IsUnitDead(u) and not IsUnitInGroup(u,BEING_BUILT_UNITS) and not IsUnitInGroup(u,BEING_UPGRADE_UNITS)
	endfunction

	function IsUnitBeingBuilt takes unit u returns boolean
		return not IsUnitDead(u) and IsUnitInGroup(u,BEING_BUILT_UNITS)
	endfunction

	function IsUnitBeingUpgraded takes unit u returns boolean
		return not IsUnitDead(u) and IsUnitInGroup(u,BEING_UPGRADE_UNITS)
	endfunction
	
	private function RefreshGroup takes nothing returns nothing
		call GroupRefresh(BEING_BUILT_UNITS)
		call GroupRefresh(BEING_UPGRADE_UNITS)
	endfunction
    
    private function MainSetup takes nothing returns nothing
		local integer row = 0
        local integer column = 0
			
        //Start Positions of the Acolyte Builder
        set START_POS_X[0] = GetRectCenterX(gg_rct_P1AcolyteStartPos)
        set START_POS_Y[0] = GetRectCenterY(gg_rct_P1AcolyteStartPos)
        set START_POS_X[1] = GetRectCenterX(gg_rct_P2AcolyteStartPos)
        set START_POS_Y[1] = GetRectCenterY(gg_rct_P2AcolyteStartPos)
        set START_POS_X[2] = GetRectCenterX(gg_rct_P3AcolyteStartPos)
        set START_POS_Y[2] = GetRectCenterY(gg_rct_P3AcolyteStartPos)
        set START_POS_X[3] = GetRectCenterX(gg_rct_P4AcolyteStartPos)
        set START_POS_Y[3] = GetRectCenterY(gg_rct_P4AcolyteStartPos)
        set START_POS_X[4] = GetRectCenterX(gg_rct_P5AcolyteStartPos)
        set START_POS_Y[4] = GetRectCenterY(gg_rct_P5AcolyteStartPos)
        set START_POS_X[5] = GetRectCenterX(gg_rct_P6AcolyteStartPos)
        set START_POS_Y[5] = GetRectCenterY(gg_rct_P6AcolyteStartPos)
		
        //Nicht bebaubare Gebiete
        set NON_TOWER_RECTS[0] = gg_rct_NonTowerRect0
        set NON_TOWER_RECTS[1] = gg_rct_NonTowerRect1
        set NON_TOWER_RECTS[2] = gg_rct_NonTowerRect2
        set NON_TOWER_RECTS[3] = gg_rct_NonTowerRect3
        set NON_TOWER_RECTS[4] = gg_rct_NonTowerRect4
        set NON_TOWER_RECTS[5] = gg_rct_NonTowerRect5
        set NON_TOWER_RECTS[6] = gg_rct_NonTowerRect6
        set NON_TOWER_RECTS[7] = gg_rct_NonTowerRect7
        set NON_TOWER_RECTS[8] = gg_rct_NonTowerRect8
        set NON_TOWER_RECTS[9] = gg_rct_UDVisibleArea5
    	
        /*
		 * TOWER DATA
		 */
         
        /*******************
         *   Base Towers   *
         *******************/
        //Index: 0        
		//****** Shady Spire *******
		call SaveInteger(TOWER_DATA, column, row, 'u00R') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 49) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level
		set column = 0
		set row = row + 1
		
		//Index: 1
		//****** Dark Spire *******
		call SaveInteger(TOWER_DATA, column, row, 'u00S') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 75) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 2
		//****** Black Spire *******
		call SaveInteger(TOWER_DATA, column, row, 'u00T') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 111) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //----------------------------------------------------------//
        
        /*******************
         *   Ice Towers    *
         *******************/
         //Index: 3
        //****** Cold Obelisk *******
		call SaveInteger(TOWER_DATA, column, row, 'u00U') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 47) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AK') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 4
        //****** Frosty Obelisk *******
		call SaveInteger(TOWER_DATA, column, row, 'u00V') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 54) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AK') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 5
        //****** Glacial Obelisk *******
		call SaveInteger(TOWER_DATA, column, row, 'u00W') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 63) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AK') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 6
        //****** Flaming Rock *******
		call SaveInteger(TOWER_DATA, column, row, 'u00Y') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 173) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 7
        //****** Blazing Rock *******
		call SaveInteger(TOWER_DATA, column, row, 'u00Z') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 222) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 8
        //****** Magma Rock *******
		call SaveInteger(TOWER_DATA, column, row, 'u010') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 276) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 9
        //****** Cursed Gravestone *******
		call SaveInteger(TOWER_DATA, column, row, 'u00X') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 216) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A09W') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 10
        //****** Cursed Tombstone *******
		call SaveInteger(TOWER_DATA, column, row, 'u011') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 252) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A09W') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 11
        //****** Cursed Memento *******
		call SaveInteger(TOWER_DATA, column, row, 'u012') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 294) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A09W') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
		
		/*
		 * Rare Towers
		 */
        
        //Index: 12
        //****** Decayed Earth Tower *******
		call SaveInteger(TOWER_DATA, column, row, 'u013') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 277) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 13
        //****** Plagued Earth Tower *******
		call SaveInteger(TOWER_DATA, column, row, 'u014') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 346) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1

        //Index: 14
        //****** Blighted Earth Tower *******
		call SaveInteger(TOWER_DATA, column, row, 'u015') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 433) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, -1) //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 15
        //****** Ice Frenzy *******
		call SaveInteger(TOWER_DATA, column, row, 'u016') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 147) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A072') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 16
        //****** Ice Fury *******
		call SaveInteger(TOWER_DATA, column, row, 'u017') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 157) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A072') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 17
        //****** Icy Rage *******
		call SaveInteger(TOWER_DATA, column, row, 'u018') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 166) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A072') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 18
        //****** Putrid Pot *******
		call SaveInteger(TOWER_DATA, column, row, 'u01A') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1070) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A074') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 19
        //****** Putrid Vat *******
		call SaveInteger(TOWER_DATA, column, row, 'u01B') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1174) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A074') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 20
        //****** Putrid Cauldron *******
		call SaveInteger(TOWER_DATA, column, row, 'u01C') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1278) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A074') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 21
        //****** Gloom Orb *******
		call SaveInteger(TOWER_DATA, column, row, 'u01D') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1505) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AL') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 22
        //****** Ruin Orb *******
		call SaveInteger(TOWER_DATA, column, row, 'u01E') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1084) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AL') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 24
        //****** Doom Orb *******
		call SaveInteger(TOWER_DATA, column, row, 'u01F') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 550) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AL') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
		
		/*
		 * Unique Towers
		 */
        
        //Index: 25
        //****** Monolith of Hatred *******
		call SaveInteger(TOWER_DATA, column, row, 'u01G') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 562) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0A2') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 26
        //****** Monolith of Terror *******
		call SaveInteger(TOWER_DATA, column, row, 'u01H') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 702) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0A2') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 27
        //****** Monolith of Destruction *******
		call SaveInteger(TOWER_DATA, column, row, 'u01I') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 878) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0A2') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 28
        //****** Glacier of Sorrow *******
		call SaveInteger(TOWER_DATA, column, row, 'u01J') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 403) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0A0') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 29
        //****** Glacier of Misery *******
		call SaveInteger(TOWER_DATA, column, row, 'u01K') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 403) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0A0') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 30
        //****** Glacier of Despair *******
		call SaveInteger(TOWER_DATA, column, row, 'u01L') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 378) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0A0') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 31
        //****** Totem of Infamy *******
		call SaveInteger(TOWER_DATA, column, row, 'u01M') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 401) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AN') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 1) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 32
        //****** Totem of Malice *******
		call SaveInteger(TOWER_DATA, column, row, 'u01R') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 501) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AN') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 2) //Tower Ability Level or Tower Level
		set column = 0
		set row = row + 1
        
        //Index: 33
        //****** Totem of Corruption *******
		call SaveInteger(TOWER_DATA, column, row, 'u01T') //Tower Id
		set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 626) //Tower Damage
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 'A0AN') //Tower Ability
        set column = column + 1
		call SaveInteger(TOWER_DATA, column, row, 3) //Tower Ability Level or Tower Level
        
    endfunction
    
    //-------------------------------------------------------------------------//
    struct TowerSystem
        
        static method createBuilder takes integer id returns nothing
            set ACOLYTS[id] = CreateUnit(Player(id), ACOLYTE_I_ID, START_POS_X[id], START_POS_Y[id], bj_UNIT_FACING)
            call SelectUnitByPlayer(ACOLYTS[id], true, Player(id))
			
			if (ShowTutorialsDialog.ForPlayer(GetPlayerId(Player(id)))) then
				call TowerBuilderTutorial.create(Player(id), START_POS_X[id], START_POS_Y[id])
			endif
        endmethod
        
        static method changeBuilder takes nothing returns nothing
            local integer i = 0
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) and GetPlayerRace(Player(i)) == RACE_UNDEAD then
                    //Remove acolyt
                    call KillUnit(ACOLYTS[i])
                    call RemoveUnit(ACOLYTS[i])
                    if RoundSystem.actualRound < 10 then
                        set ACOLYTS[i] = CreateUnit(Player(i), ACOLYTE_II_ID, START_POS_X[i], START_POS_Y[i], bj_UNIT_FACING)
                    else
                        set ACOLYTS[i] = CreateUnit(Player(i), ACOLYTE_III_ID, START_POS_X[i], START_POS_Y[i], bj_UNIT_FACING)
                    endif
                    call Usability.getTextMessage(0, 8, true, Player(i), true, 3.5)
                endif
                set i = i + 1
            endloop
            
        endmethod
        
        private static method onRemove takes nothing returns nothing
            local unit u = GetEnumUnit()
            
            call KillUnit(u)
            call RemoveUnit(u)
            set u = null
        endmethod
        
        static method removeTowersAndBuilder takes player p returns nothing
            local group g = CreateGroup()
            local integer pid = GetPlayerId(p)
            
            //Remove Tower Builder (Acolyt)
            call KillUnit(ACOLYTS[pid])
            call RemoveUnit(ACOLYTS[pid])
            //Search and Remove all Towers of the leaving player
            call GroupEnumUnitsOfPlayer(g, p, null)
            call ForGroup(g, function thistype.onRemove)
            call DestroyGroup(g)
            set g = null
        endmethod
        
        ///If a towers starts building
		private static method onConstructStart takes nothing returns nothing
			local unit t = GetConstructingStructure() //Tower
			local integer i = 0
            local boolean b = false
            
            loop
                exitwhen i >= MAX_NON_TOWER_AREAS
                if RectContainsUnit(NON_TOWER_RECTS[i], t) then
                    set b = true
                    call Game.playerAddLumber(GetPlayerId(GetOwningPlayer(t)),  GetUnitCost(t,COST_LUMBER))
                    call RemoveUnit(t)
                    set i = MAX_NON_TOWER_AREAS
                endif
                set i = i + 1
            endloop
            
            if not b then
                call GroupAddUnit(BEING_BUILT_UNITS, t)
			endif
            
			set t = null
        endmethod
        
        //If a towers start an Upgrade
		private static method onUpgradeStart takes nothing returns nothing
			local unit t = GetTriggerUnit() //Tower
			
			call GroupAddUnit(BEING_UPGRADE_UNITS, t)
			
			set t = null
        endmethod
        
        //If a towers upgrade is finished
        private static method onConstructFinish takes nothing returns nothing
			local unit t = GetTriggerUnit() //Tower
            local integer id = GetUnitTypeId(t)
			local integer damage = getTowerValue(id, 1)
            local integer abi = getTowerValue(id, 2)
            local integer abiLvl = getTowerValue(id, 3)
			
			//Remove rally point ability
            call UnitRemoveAbility(t,'ARal')
			
            call GroupRemoveUnit(BEING_UPGRADE_UNITS, t)
			call TDS.addDamage(t, damage)
            if abi != -1 then
                call UnitAddAbility(t, abi)
                call SetUnitAbilityLevel(t, abi, abiLvl)
            endif
			set t = null
        endmethod
		
		//If a towers cancel an Upgrade
		private static method onUpgradeCancel takes nothing returns nothing
			local unit t = GetTriggerUnit() //Tower
			
			call GroupRemoveUnit(BEING_UPGRADE_UNITS, t)
			
			set t = null
        endmethod
        
        //This method is for giving lumber back to the player
		private static method onSell takes nothing returns nothing
			local unit u = GetTriggerUnit()
            local unit t = GetTrainedUnit()
			
            if GetUnitTypeId(t) == SELL then
                call SetUnitInvulnerable( u, false )
                call IssueTargetOrder( t, "transmute", u )
                call UnitApplyTimedLife(t, 'BTLF', 1.50)
                call GroupRemoveUnit(BEING_UPGRADE_UNITS, u)
			endif
            
			set u = null
            set t = null
        endmethod
        
        static method getTowerValue takes integer id, integer value returns integer
            local integer i = 0
            
            loop
                exitwhen i > MAX_TOWERS
                if (LoadInteger(TOWER_DATA, 0, i) ==  id) then
                    return LoadInteger(TOWER_DATA, value, i)
                endif
                set i = i + 1
            endloop
            return -1
        endmethod
        
        static method initialize takes nothing returns nothing
            local integer i = 0
			local timer t = CreateTimer()
            local trigger t1 = CreateTrigger()
            local trigger t2 = CreateTrigger()
			local trigger t3 = CreateTrigger()
			local trigger t4 = CreateTrigger()
			local trigger t5 = CreateTrigger()
            local trigger t6 = CreateTrigger()
			local code c1 = function thistype.onConstructStart
            local code c2 = function thistype.onConstructFinish
			local code c3 = function thistype.onUpgradeStart
            local code c4 = function thistype.onConstructFinish
			local code c5 = function thistype.onUpgradeCancel
            local code c6 = function thistype.onSell
            
			call MainSetup()
			
			set BEING_BUILT_UNITS = NewGroup()
			set BEING_UPGRADE_UNITS = NewGroup()
			
			call TimerStart(t, TIME_OUT, true, function RefreshGroup)
			
            //Register Tower Events for Player 1-6
            loop
                exitwhen i > 5
                if Game.isPlayerInGame(i) then
					call TriggerRegisterPlayerUnitEvent(t1, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_START, null)
                    call TriggerRegisterPlayerUnitEvent(t2, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, null)
					call TriggerRegisterPlayerUnitEvent(t3, Player(i), EVENT_PLAYER_UNIT_UPGRADE_START, null)
                    call TriggerRegisterPlayerUnitEvent(t4, Player(i), EVENT_PLAYER_UNIT_UPGRADE_FINISH, null)
					call TriggerRegisterPlayerUnitEvent(t5, Player(i), EVENT_PLAYER_UNIT_UPGRADE_CANCEL, null)
                    call TriggerRegisterPlayerUnitEvent(t6, Player(i), EVENT_PLAYER_UNIT_TRAIN_FINISH, null)
                endif
                set i = i + 1
            endloop
            call TriggerAddCondition(t1, Filter(c1))
            call TriggerAddCondition(t2, Filter(c2))
            call TriggerAddCondition(t3, Filter(c3))
            call TriggerAddCondition(t4, Filter(c4))
            call TriggerAddCondition(t5, Filter(c5))
            call TriggerAddCondition(t6, Filter(c6))
            set t1 = null
            set t2 = null
			set t3 = null
			set t4 = null
			set t5 = null
            set t6 = null
            set c1 = null
            set c2 = null
			set c3 = null
			set c4 = null
			set c5 = null
            set c6 = null
			set t = null
        endmethod
        
    endstruct
    
endscope