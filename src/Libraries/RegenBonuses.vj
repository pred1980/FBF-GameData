library RegenBonuses initializer OnInit requires BonusMod, AutoIndex
////////////////////////////////////////////////////////////////////////////////
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ RegenBonuses for BonusMod
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
//@ This library provides two new bonus types:
//@
//@   - BONUS_MANA_REGEN
//@         Regenerates an absolute amount of mana every second
//@
//@   - BONUS_LIFE_REGEN_PERCENT
//@         Regenerates a percent of a unit's maximum life every second
//@ 
//@ Any value is a valid bonus. There are no limits.
//@ 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
////////////////////////////////////////////////////////////////////////////////

//==============================================================================
// Configuration:
//==============================================================================

//------------------------------------------------------------------------------
// The following constant determines how often the life and mana bonuses are
// applied to units. Note that this will not effect the values of the bonuses.
// The values of the bonuses will always be mana per second/percentage of life
// per second. This constant simply determines how often the values are updated.
//------------------------------------------------------------------------------
globals
    private real REGEN_PERIOD = 0.1
endglobals

//==============================================================================
// End of configuration
//==============================================================================

globals
    Bonus BONUS_MANA_REGEN
    Bonus BONUS_LIFE_REGEN_PERCENT
endglobals

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000RegenBonuses Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

globals
    private timer regenTimer = CreateTimer()
endglobals

private keyword BonusValues

private function DoRegen takes nothing returns nothing
    local integer i
    local BonusValues values
    
    // Loop over all active bonuses
    set i = 0
    loop
        exitwhen i == BonusValues.count
        
        set values = BonusValues.all[i]
        
        if GetWidgetLife(values.owner) > 0.0 then
            if values.manaRegen > 0 then
                // Do mana regen:
                call SetUnitState(values.owner, UNIT_STATE_MANA, GetUnitState(values.owner, UNIT_STATE_MANA) + (values.manaRegen * REGEN_PERIOD))
            endif
            
            if values.lifeRegen > 0 then
                // Do life regen:
                call SetUnitState(values.owner, UNIT_STATE_LIFE, GetUnitState(values.owner, UNIT_STATE_LIFE) + (GetUnitState(values.owner, UNIT_STATE_MAX_LIFE) * (values.lifeRegen / 100.0)) * REGEN_PERIOD)
            endif
        endif
        
        set i = i + 1
    endloop
endfunction

private struct BonusValues
    public integer manaRegen = 0
    public integer lifeRegen = 0
    
    public unit owner
    
    private static thistype array owners
    
    public static thistype array all
    public static integer count = 0
    public integer index
    
    private static method create takes unit u returns thistype
        local thistype this = thistype.allocate()
        
        set this.owner = u
        
        set thistype.owners[GetUnitId(u)] = this
        
        if thistype.count == 0 then
            call TimerStart(regenTimer, REGEN_PERIOD, true, function DoRegen)
        endif
        
        set thistype.all[thistype.count] = this
        set this.index = thistype.count
        set thistype.count = thistype.count + 1
        
        return this
    endmethod
    
    private method onDestroy takes nothing returns nothing
        set thistype.owners[GetUnitId(this.owner)] = thistype(0)
        
        set thistype.all[this.index] = thistype.all[thistype.count]
        set thistype.count = thistype.count - 1
        
        if thistype.count == 0 then
            call PauseTimer(regenTimer)
        endif
        
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

//! textmacro RegenBonuses_RegenBonusDefine takes NAME
private struct RegenBonus_$NAME$ extends Bonus
    integer minBonus = -2147483648
    integer maxBonus =  2147483647
    
    method setBonus takes unit u, integer amount returns integer
        local BonusValues values
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("RegenBonus_$NAME$.setBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values = BonusValues.getInstance(u)
        set values.$NAME$Regen = amount
        
        return amount
    endmethod
    
    method getBonus takes unit u returns integer
        local BonusValues values
        
        if not IsUnitIndexed(u) then
            debug call ErrorMsg("RegenBonus_$NAME$.getBonus()", "Unit that is not indexed by AutoIndex given")
            return 0
        endif
        
        set values = BonusValues[u]
        
        if values == 0 then
            return 0
        endif
        
        return values.$NAME$Regen
    endmethod
    
    method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    method isValidBonus takes unit u, integer value returns boolean
        return IsUnitIndexed(u)
    endmethod
endstruct
//! endtextmacro

//! runtextmacro RegenBonuses_RegenBonusDefine("life")
//! runtextmacro RegenBonuses_RegenBonusDefine("mana")

private function OnLeaveMap takes unit u returns nothing
    if BonusValues[u] != 0 then
        call BonusValues[u].destroy()
    endif
endfunction

private function OnInit takes nothing returns nothing
    call OnUnitDeindexed(OnLeaveMap)
    
    set BONUS_MANA_REGEN         = RegenBonus_mana.create()
    set BONUS_LIFE_REGEN_PERCENT = RegenBonus_life.create()
endfunction
endlibrary