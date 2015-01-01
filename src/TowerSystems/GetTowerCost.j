library GetTowerCost initializer Init requires Table, CommonAIimports

/* Functions: 
 * ==========
 *
 * http://www.wc3c.net/showthread.php?t=107424
 *
 * GetUnitCost(unit,type*)          : Returns the total gold cost of a unit (upgrades included)
 * GetUnitTypeCost(unitId,type*)    : Returns, how much a unit with ID X would cost. Note:
 *                                   This ignores upgrade gold costs, so when you just want the cost of
 *                                   THIS building/unit, you can use GetUnitTypeCost(GetUnitTypeId(#),#)
 *
 * * type can be COST_GOLD or COST_LUMBER
 *
 * Changelog: 
 *     06.01.2014: Anpassung des original Codes an unsere Bedürfnisse
 */
    globals
        private constant integer PLAYER_ID = 14
        private constant integer DUMMY_ID  = 'hpea'
        private constant integer RESOURCE_LIMIT = 100000
        private constant boolean CLONE = true
    endglobals
    
    globals
        private trigger unitEnters = CreateTrigger()
        private HandleTable UnitData
        private Table RawcodeData
        private real maxX
        private real maxY
        private unit dummy = null
        private player dummyOwner = Player(PLAYER_ID)
    endglobals
    
    // return true: Save the unit's cost.
    // return false: Don't save the unit's cost.
    private function UserFilter takes unit u returns boolean
        return ( GetUnitAbilityLevel(u,'Aloc') == 0 )
    endfunction
    
    struct UnitCost
        integer Lumber
        integer Gold
        UnitCost Link = 0
        
        method increaseBy takes UnitCost inc returns nothing
            set .Lumber = .Lumber + inc.Lumber
            set .Gold = .Gold + inc.Gold
            call inc.destroy()
            
            // And now synchronize the Clone.
            // Destroying and recreating would change its ID, so..
            if CLONE then
                if .Link != 0 then
                    set .Link.Gold = .Gold
                    set .Link.Lumber = .Lumber
                endif
            endif
        endmethod
        
        // We want to give the user the UnitCost struct, but we dont want him to access it
        // and change its data. So we make a 'Parastruct'
        method Clone takes nothing returns UnitCost
            if CLONE then
                if .Link == 0 then
                    set .Link = UnitCost.create()
                endif
                // Always restore the data to be safe.
                set .Link.Gold = .Gold
                set .Link.Lumber = .Lumber
                set .Link.Link = -1 // -1 means: This is just a clone.
                return .Link
            else
                return this
            endif
        endmethod
        
        method onDestroy takes nothing returns nothing
            if .Link > 0 then
                call .Link.destroy()
            endif
        endmethod
    endstruct
    
    private function GetUnitCostSimple takes integer ID returns UnitCost
        local UnitCost u = UnitCost.create()
        
        if IsUnitIdType(ID,UNIT_TYPE_HERO) then
            
            call SetPlayerState(dummyOwner, PLAYER_STATE_RESOURCE_GOLD, RESOURCE_LIMIT)
            call SetPlayerState(dummyOwner, PLAYER_STATE_RESOURCE_LUMBER, RESOURCE_LIMIT)
            call SetPlayerState(dummyOwner, PLAYER_STATE_RESOURCE_FOOD_USED,0)
            call AddUnitToStock(dummy, ID, 1, 1)
            call IssueNeutralImmediateOrderById(dummyOwner, dummy, ID)
            call RemoveUnitFromStock(dummy,ID)
            
            set u.Gold = RESOURCE_LIMIT - GetPlayerState(dummyOwner,PLAYER_STATE_RESOURCE_GOLD)
            set u.Lumber = RESOURCE_LIMIT - GetPlayerState(dummyOwner,PLAYER_STATE_RESOURCE_LUMBER)
        else
            set u.Gold = GetUnitGoldCost(ID)
            set u.Lumber = GetUnitWoodCost(ID)
        endif
                
        return u
    endfunction
    
    // ======================================================================
    // ============== USER FUNCTIONS ==============
    // ======================================================================
    
    globals
        constant integer COST_GOLD = 0
        constant integer COST_LUMBER = 1
    endglobals
    
    function GetUnitCost takes unit u, integer cost returns integer
        local UnitCost temp = UnitData[u]
        
        if temp == 0 then
            set temp = GetUnitCostSimple(GetUnitTypeId(u))
            set UnitData[u] = temp
        endif
        
        if cost == COST_GOLD then
            return temp.Gold
        elseif cost == COST_LUMBER then
            return temp.Lumber
        else
            debug call BJDebugMsg("GetUnitCost: Used undefined cost-type")
        endif
        return 0
    endfunction
    
    function GetUnitTypeCost takes integer unitId, integer cost returns integer
        local UnitCost temp = GetUnitCostSimple(unitId)
        if cost == COST_GOLD then
            return temp.Gold
        elseif cost == COST_LUMBER then
            return temp.Lumber
        else
            debug call BJDebugMsg("GetUnitCost: Used undefined cost-type")
        endif
        return 0
    endfunction
    
    // ======================================================================
    // ======================================================================
    // ======================================================================
    
    private function onEnterCondition takes nothing returns boolean
        return IsUnitType(GetTriggerUnit(), UNIT_TYPE_STRUCTURE) and GetUnitRace(GetTriggerUnit()) == RACE_UNDEAD
    endfunction
    
    private function onEnterAction takes nothing returns nothing
        local UnitCost uc
        local unit u = GetTriggerUnit()
        
        if UserFilter(u) then
            if UnitData.exists(u) == false then
                set uc = GetUnitCostSimple(GetUnitTypeId(u))
                set UnitData[u] = uc
            endif
        endif
        
        set u = null
    endfunction
    
    private function returnFlag takes nothing returns boolean
        return UserFilter(GetFilterUnit())
    endfunction

    private function Init takes nothing returns nothing
        local boolexpr condition = Condition(function returnFlag)
        
        set UnitData = HandleTable.create()
        set RawcodeData = Table.create()
        
        set dummy = CreateUnit(dummyOwner,DUMMY_ID,GetRectMaxX(bj_mapInitialPlayableArea), GetRectMaxY(bj_mapInitialPlayableArea),270)
        call UnitAddAbility(dummy,'Asud')
        call UnitAddAbility(dummy,'Aloc')
        call SetUnitAcquireRange(dummy,0.)
        call ShowUnit(dummy,false)
        call SetUnitInvulnerable(dummy,true)
        
        call SetPlayerState(dummyOwner, PLAYER_STATE_RESOURCE_FOOD_CAP,300)
        call TriggerRegisterEnterRectSimple(unitEnters, bj_mapInitialPlayableArea)
        call TriggerAddCondition(unitEnters, Condition( function onEnterCondition ) )
        call TriggerAddAction(unitEnters,function onEnterAction)
        
        call DestroyBoolExpr(condition)
    endfunction
endlibrary