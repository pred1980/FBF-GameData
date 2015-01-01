library UnitMaxStateBonuses initializer OnInit requires BonusMod, UnitMaxState, AutoIndex
////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ UnitMaxStateBonuses for BonusMod
//@=============================================================================
//@ Credits:
//@-----------------------------------------------------------------------------
//@    Written by:
//@        Earth-Fury
//@=============================================================================
//@ Requirements:
//@-----------------------------------------------------------------------------
//@ This library requires the BonusMod library, the UnitMaxState library by
//@ Earth-Fury, and the AutoIndex library by grim001.
//@
//@=============================================================================
//@ Readme:
//@-----------------------------------------------------------------------------
//@ This library provides two new bonus types:
//@
//@   - BONUS_LIFE
//@   - BONUS_MANA
//@ 
//@ These bonuses, of course, raise a unit's maximum life and mana.
//@ 
//@ Note that if you simply wish to permanently increase or decrease the maximum
//@ life or mana of a unit, you are likely best off using UnitMaxState directly.
//@
//@ The minimum life and mana bonuses are 1 more than -(unit's max state).
//@ That is to say, these bonuses can not fully remove a unit's life or mana.
//@
//@ There is no maximum bonus.
//@
//@ There is nothing to configure.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

globals
    Bonus BONUS_LIFE
    Bonus BONUS_MANA
endglobals

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000UnitMaxStateBonus Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

private struct BonusValues
    public integer mana = 0
    public integer life = 0
    
    public unit owner
    
    private static thistype array owners
    
    private static method create takes unit u returns thistype
        local thistype this = thistype.allocate()
        
        set this.owner = u
        
        set thistype.owners[GetUnitId(u)] = this
        
        return this
    endmethod
    
    private method onDestroy takes nothing returns nothing
        set thistype.owners[GetUnitId(this.owner)] = thistype(0)
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

//! textmacro UnitMaxStateBonus_DefineBonus takes NAME, STATE, MIN
private struct MaxStateBonus_$NAME$ extends Bonus
    integer minBonus = -2147483648
    integer maxBonus =  2147483647
    
    method setBonus takes unit u, integer amount returns integer
        local BonusValues values
        local integer actual
        local integer new
        local real factor
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("MaxStateBonus_$NAME$.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values = BonusValues.getInstance(u)
        
        set actual = R2I(GetUnitState(u, UNIT_STATE_MAX_$STATE$)) - values.$NAME$
        set new = actual + amount
        
        set factor = GetUnitState(u, UNIT_STATE_$STATE$) / GetUnitState(u, UNIT_STATE_MAX_$STATE$)
        
        if new < $MIN$ then
            if actual < $MIN$ then
                set values.$NAME$ = 0
            else
                set values.$NAME$ = -actual + $MIN$
            endif
            
            call SetUnitState(u, UNIT_STATE_$STATE$, $MIN$)
            call SetUnitMaxState(u, UNIT_STATE_MAX_$STATE$, $MIN$)
            return values.$NAME$
        else
            set values.$NAME$ = amount
            
            call SetUnitMaxState(u, UNIT_STATE_MAX_$STATE$, new)
            call SetUnitState(u, UNIT_STATE_$STATE$, new * factor)
            
            return values.$NAME$
        endif
    endmethod
    
    method getBonus takes unit u returns integer
        local BonusValues values
        local integer actual
        local integer new
        local real factor
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("MaxStateBonus_$NAME$.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values = BonusValues[u]
        
        if values == 0 then
            return 0
        endif
        
        set values.$NAME$ = R2I(GetUnitState(u, UNIT_STATE_MAX_$STATE$)) - (R2I(GetUnitState(u, UNIT_STATE_MAX_$STATE$)) - values.$NAME$)
        
        return values.$NAME$
    endmethod
    
    method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    method isValidBonus takes unit u, integer value returns boolean
        local integer currentBonus
        
        if not IsUnitIndexed(u) then
            return false
        endif
        
        set currentBonus = this.getBonus(u)
        
        return R2I(GetUnitState(u, UNIT_STATE_MAX_$STATE$)) - currentBonus + value >= $MIN$
    endmethod
endstruct
//! endtextmacro

//! runtextmacro UnitMaxStateBonus_DefineBonus("life", "LIFE", "1")
//! runtextmacro UnitMaxStateBonus_DefineBonus("mana", "MANA", "1")

private function OnLeaveMap takes unit u returns nothing
    if BonusValues[u] != 0 then
        call BonusValues[u].destroy()
    endif
endfunction

private function OnInit takes nothing returns nothing
    call OnUnitDeindexed(OnLeaveMap)
    
    set BONUS_LIFE = MaxStateBonus_life.create()
    set BONUS_MANA = MaxStateBonus_mana.create()
endfunction
endlibrary