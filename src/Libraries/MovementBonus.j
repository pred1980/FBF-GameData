library MovementBonus initializer OnInit requires BonusMod, AutoIndex
////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ MovementBonus for BonusMod
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library requires the BonusMod library, and the AutoIndex library.
//@
//@=============================================================================
//@ Readme:
//@-----------------------------------------------------------------------------
//@ This library provides one new bonus type:
//@
//@   - BONUS_MOVEMENT_SPEED
//@         Modifies a unit's movement speed. 
//@ 
//@ A unit's movement speed can never go below or above the values configured
//@ in the gameplay constants for a map.
//@ 
//@ You should not modify a unit's movement speed any way other than via
//@ BonusMod. Doing so will cause issues.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// The following constants must be equal to the equivalent gameplay constants.
// By default, these are set to the default vlues for the gameplay constants.
//------------------------------------------------------------------------------
globals
    constant integer MAX_UNIT_MOVEMENT = 522
    constant integer MIN_UNIT_MOVEMENT = 150
    constant integer MAX_BUILDING_MOVEMENT = 400
    constant integer MIN_BUILDING_MOVEMENT = 25
endglobals

//==============================================================================
// End of configuration
//==============================================================================
globals
    Bonus BONUS_MOVEMENT_SPEED
endglobals

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000MovementBonus Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

private struct BonusValue
    public integer speed = 0
    
    public unit owner
    
    private static thistype array owners
    
    public static thistype array all
    public static integer count = 0
    public integer index
    
    private static method create takes unit u returns thistype
        local thistype this = thistype.allocate()
        
        set this.owner = u
        
        set thistype.owners[GetUnitId(u)] = this
        
        set thistype.all[thistype.count] = this
        set this.index = thistype.count
        set thistype.count = thistype.count + 1
        
        return this
    endmethod
    
    private method onDestroy takes nothing returns nothing
        set thistype.owners[GetUnitId(this.owner)] = thistype(0)
        
        set thistype.all[this.index] = thistype.all[thistype.count]
        set thistype.count = thistype.count - 1
        
        set this.owner = null
    endmethod
    
    public static method getInstance takes unit u returns thistype
        if thistype.owners[GetUnitId(u)] == 0 then
            return thistype.create(u)
        else
            return thistype.owners[GetUnitId(u)]
        endif
    endmethod
    
    public static method operator[] takes unit u returns thistype
        return thistype.owners[GetUnitId(u)]
    endmethod
    
    public static method operator[]= takes unit u, thistype i returns nothing
        set thistype.owners[GetUnitId(u)] = i
    endmethod
endstruct

private struct MovementBonus extends Bonus
    integer minBonus
    integer maxBonus
    
    static method create takes integer min, integer max returns thistype
        local thistype this = allocate()
        
        set this.minBonus = min
        set this.maxBonus = max
        
        return this
    endmethod
    
    method setBonus takes unit u, integer amount returns integer
        local BonusValue value
        local integer min
        local integer max
        
        local integer actualSpeed
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("MovementBonus.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set value = BonusValue.getInstance(u)
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set min = MIN_BUILDING_MOVEMENT
            set max = MAX_BUILDING_MOVEMENT
        else
            set min = MIN_UNIT_MOVEMENT
            set max = MAX_UNIT_MOVEMENT
        endif
        
        set actualSpeed = R2I(GetUnitMoveSpeed(u)) - value.speed
        
        if actualSpeed + amount < min then
            debug call ErrorMsg("MovementBonus.setBonus()", "Attempting to set a unit's speed below it's minimum")
            set amount = -actualSpeed + min
        elseif actualSpeed + amount > max then
            debug call ErrorMsg("MovementBonus.setBonus()", "Ateempting to set a unit's speed above it's maximum")
            set amount = max - actualSpeed
        endif
        
        call SetUnitMoveSpeed(u, actualSpeed + amount)
        set value.speed = amount
        
        return amount
    endmethod
    
    method getBonus takes unit u returns integer
        local BonusValue value
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("MovementBonus.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set value = BonusValue[u]
        
        if value == 0 then
            return 0
        endif
        
        return value.speed
    endmethod
    
    method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    method isValidBonus takes unit u, integer value returns boolean
        local integer min
        local integer max
        
        local integer currentBonus
        local integer actualSpeed
        
        if not IsUnitIndexed(u) then
            return false
        endif
        
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            set min = MIN_BUILDING_MOVEMENT
            set max = MAX_BUILDING_MOVEMENT
        else
            set min = MIN_UNIT_MOVEMENT
            set max = MAX_UNIT_MOVEMENT
        endif
        
        set actualSpeed = R2I(GetUnitMoveSpeed(u)) - this.getBonus(u)
        
        if actualSpeed + value < min then
            return false
        elseif actualSpeed + value > max then
            return false
        else
            return true
        endif
    endmethod
endstruct

private function OnLeaveMap takes unit u returns nothing
    if BonusValue[u] != 0 then
        call BonusValue[u].destroy()
    endif
endfunction

private function OnInit takes nothing returns nothing
    local integer min
    local integer max
    
    call OnUnitDeindexed(OnLeaveMap)
    
    if MAX_UNIT_MOVEMENT > MAX_BUILDING_MOVEMENT then
        set max = MAX_UNIT_MOVEMENT
    else
        set max = MAX_BUILDING_MOVEMENT
    endif
    
    if MIN_UNIT_MOVEMENT < MIN_BUILDING_MOVEMENT then
        set min = MIN_UNIT_MOVEMENT
    else
        set min = MIN_BUILDING_MOVEMENT
    endif
    
    set BONUS_MOVEMENT_SPEED = MovementBonus.create(min, max)
endfunction
endlibrary