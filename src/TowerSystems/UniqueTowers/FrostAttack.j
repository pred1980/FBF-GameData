scope FrostAttack initializer init
	/*
	 * Ability: Frost Attack
     * Description: Attacks of this tower slows enemy units by 15%/30%/45% in range of 250 around the target for 5s.
     * Last Update: 29.12.2013
     * Changelog: 
     *     29.12.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer DUMMY_SPELL_ID = 'A0A1'
        private constant integer BUFF_ID = 'B02C'
        private constant real DURATION = 5.
        private integer array TOWER_TYP
    endglobals
    
    private function Range takes nothing returns real
        return 250.
    endfunction
    
    private function Targets takes unit target returns boolean
        return not IsUnitDead(target) /*
		*/     and (IsUnitType(target, UNIT_TYPE_STRUCTURE) == false) /*
		*/     and (IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) == false) /*
		*/     and (IsUnitType(target, UNIT_TYPE_MECHANICAL) == false) /*
		*/     and (GetUnitAbilityLevel(target, BUFF_ID) == 0)
    endfunction

    globals
        private group all
        private group copy
        private boolexpr b
    endglobals
    
    private struct Data
        unit unitPointer
    endstruct
    
    //In this situation, this is the function that's called by the ForGroup "loop".
    //It adds a unit to the global group bj_groupAddGroupDest.
    //GetEnumUnit() is like the GetFilterUnit() for ForGroup "loops".
    //bj_groupAddGroupDest is a blizzard defined global by the way.
    //You can tell from the bj_ at the start.
    //I think I added more comments than code I copied. 
    private function CopyGroup takes group g returns group
        set bj_groupAddGroupDest = CreateGroup() //This creates a group.
        call ForGroup( g, function GroupAddGroupEnum )
        //This adds all the units in the first group to the newly created group.
        //Just to be clear, ForGroup is like a loop that goes through all the
        //units in a group and calls a function for each of them.
        return bj_groupAddGroupDest //This returns the newly created group.
    endfunction
    
    private function Pick takes nothing returns boolean
        return Targets(GetFilterUnit())
    endfunction 
    
    private function onSlowEnd takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local Data data = GetTimerData(t)
        
        call UnitRemoveAbility(data.unitPointer, DUMMY_SPELL_ID)
        call data.destroy()
        call DestroyTimer(t)
        set t = null
    endfunction
    
    private function slowTargets takes unit damageSource, unit damagedUnit returns nothing
        local integer level = TowerSystem.getTowerValue(GetUnitTypeId(damageSource), 3)
        local unit u
        local unit d
        local timer t
        local Data data
        
        //counting the units
        call GroupEnumUnitsInRange(all, GetUnitX(damagedUnit), GetUnitY(damagedUnit), Range(), b)
        set copy = CopyGroup(all)//By doing this, you're calling a function,
        //then saving whatever it returns to the variable. Let's look at the function...
        loop
            set u = FirstOfGroup(copy)
            exitwhen(u == null)
            set data = Data.create()
            set data.unitPointer = u
            set t = CreateTimer()
            call SetTimerData(t, data)
            call TimerStart(t, DURATION, false, function onSlowEnd)
            call GroupRemoveUnit(copy, u)
            call UnitAddAbility( u, DUMMY_SPELL_ID )
            call SetUnitAbilityLevel( u, DUMMY_SPELL_ID, level )
        endloop
        
        set u = null
        set d = null
    endfunction
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if GetUnitAbilityLevel(damagedUnit, BUFF_ID) == 0 /*
		*/ and GetUnitTypeId(damageSource) == TOWER_TYP[0] /*
		*/ or GetUnitTypeId(damageSource) == TOWER_TYP[1] /*
		*/ or GetUnitTypeId(damageSource) == TOWER_TYP[2] then
               call slowTargets(damageSource, damagedUnit)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        set TOWER_TYP[0] = 'u01J'
        set TOWER_TYP[1] = 'u01K'
        set TOWER_TYP[2] = 'u01L'
        
        //setting globals
        set all = CreateGroup()
        set copy = CreateGroup()
        set b = Condition(function Pick)
        
        call RegisterDamageResponse( Actions )
    endfunction

endscope