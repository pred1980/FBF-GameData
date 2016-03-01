library ItemResourceCost uses Table, WorldBounds optional RegisterPlayerUnitEvent
//===========================================================
// Version 1.1
// Retrieves and saves information about 
// gold and lumber resource costs
// as well as charges for item type ids.
//
// Be aware that the Inventory - Sell Item Return Rate
// of the Gameplay Constant is not taken into account.
//===========================================================
//
//  Credits to:
//      - Bribe for Table
//      - Nestharus for WorldBounds, GetItemCost API and system design.
//      - Magtheridon96 for RegisterPlayerUnitEvent 
//
//===========================================================
//
//  Table                    -  hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
//  WorldBounds              -  github.com/nestharus/JASS/tree/master/jass/Systems/WorldBounds
//  RegisterPlayerUnitEvent  -  hiveworkshop.com/forums/jass-resources-412/snippet-registerplayerunitevent-203338/ 
//
//===========================================================
//
//  API:
//       function GetItemTypeIdGoldCost takes integer itemId returns integer
//       function GetItemTypeIdLumberCost takes integer itemId returns integer
//       function GetItemTypeIdCharges takes integer itemId returns integer
//
//       function GetItemGoldCost takes item whichItem returns integer
//           -   Gets total item gold cost considering the item charges
//       function GetItemLumberCost takes item whichItem returns integer
//           -   Gets total item wood cost considering the item charges
//
//===========================================================
//
//  100% backwards compatible to GetItemCost
//      - github.com/nestharus/JASS/blob/master/jass/Systems/Costs%20-%20Unit%20%26%20Item/item.j 
//
//===========================================================
// User settings.
//===========================================================

    globals                     // Considered as neutral in you map.
        private constant player NEUTRAL_PLAYER = Player(15)
    endglobals
    
    // Boolean "prev" should return the previous setup of your indexer,
    // so the system can properly restore its state once the shop unit is created.
    private function ToogleUnitIndexer takes boolean enable returns boolean
        local boolean prev = true// UnitIndexer.enabled
        // set UnitIndexer.enabled = enable
        return prev
    endfunction
    
    // The unit type id doesn't really matter. Choose whatever you like.
    //! textmacro ITEM_RESOURCE_COST_SHOP_UNIT 
                                                          // For best results choose a corner where no other actions takes place.
            set shop = CreateUnit(NEUTRAL_PLAYER, 'nvlw', WorldBounds.maxX, WorldBounds.maxY, 0)
    //! endtextmacro 

//===========================================================
// ItemResourceCost code. Make changes carefully.
//===========================================================
    
    globals 
        private Table costs
        private Table charges
        private Table guardian
        private unit shop
        private integer tempId
    endglobals

    // Maximum safety which can be provided.
    private function FindBoughtItem takes nothing returns nothing
        local item temp = GetEnumItem()
        if GetItemTypeId(temp) == tempId and not guardian.boolean.has(GetHandleId(temp)) then
            set charges[tempId] = GetItemCharges(temp)// Get default charges.
            set tempId = 0
            call RemoveItem(temp)
        endif
        set temp = null
    endfunction
    
    private function FlagItems takes nothing returns nothing
        set guardian.boolean[GetHandleId(GetEnumItem())] = true
    endfunction
    
    private function GetItemData takes integer id returns nothing
        // Save previous resource state.
        local integer gold = GetPlayerState(NEUTRAL_PLAYER, PLAYER_STATE_RESOURCE_GOLD)
        local integer wood = GetPlayerState(NEUTRAL_PLAYER, PLAYER_STATE_RESOURCE_LUMBER)
        local real x = GetUnitX(shop)// This point should be constant,
        local real y = GetUnitY(shop)// but who knows ...
        local rect temp = Rect(x - 1088, y - 1088, x + 1088, y + 1088)// Pathing checks don't go above 1024.
        
        // If a registered trigger action function 
        // of event trigger EVENT_PLAYER_UNIT_ISSUED_ORDER 
        // creates a new item of the same type id as "id" ...
        // And that item pops up within 1088 units of the shop ...
        // While not having RegisterPlayerUnitEvent in your map ... 
        // Then seriously ... I can't help you.
        static if LIBRARY_RegisterPlayerUnitEvent then
            local trigger trig = GetPlayerUnitEventTrigger(EVENT_PLAYER_UNIT_ISSUED_ORDER)
            local boolean flag = IsTriggerEnabled(trig)// To properly restore the trigger state.
        endif
        
        // Prepare the for shopping.
        call SetPlayerState(NEUTRAL_PLAYER, PLAYER_STATE_RESOURCE_GOLD, 1000000)
        call SetPlayerState(NEUTRAL_PLAYER, PLAYER_STATE_RESOURCE_LUMBER, 1000000)
        call AddItemToStock(shop, id, 1, 1)
        set tempId = id
        
        static if LIBRARY_RegisterPlayerUnitEvent then
            call DisableTrigger(trig)
        endif
        call EnumItemsInRect(temp, null, function FlagItems)
        call IssueNeutralImmediateOrderById(NEUTRAL_PLAYER, shop, id)
        call EnumItemsInRect(temp, null, function FindBoughtItem)
        static if LIBRARY_RegisterPlayerUnitEvent then
            if flag then
                call EnableTrigger(trig)
            endif
            set trig = null
        endif        
        call RemoveItemFromStock(shop, id)
        call guardian.flush()

        // Get gold and lumber costs.
        set costs[id] = 1000000 - GetPlayerState(NEUTRAL_PLAYER, PLAYER_STATE_RESOURCE_GOLD)
        set costs[-id] = 1000000 - GetPlayerState(NEUTRAL_PLAYER, PLAYER_STATE_RESOURCE_LUMBER)
        
        // Restore the resource state as it was before.
        call SetPlayerState(NEUTRAL_PLAYER, PLAYER_STATE_RESOURCE_GOLD, gold)
        call SetPlayerState(NEUTRAL_PLAYER, PLAYER_STATE_RESOURCE_LUMBER, wood)
        
        call RemoveRect(temp)
        set temp = null
    endfunction
    
    function GetItemTypeIdGoldCost takes integer id returns integer
        if not costs.has(id) then
            call GetItemData(id)
        endif
		return costs[id]
    endfunction
    
    function GetItemTypeIdLumberCost takes integer id returns integer
        if not costs.has(id) then
            call GetItemData(id)
        endif
        return costs[-id]
    endfunction
    
    function GetItemTypeIdCharges takes integer id returns integer
        if not charges.has(id) then
            call GetItemData(id)
        endif
        return charges[id]
    endfunction
    
    function GetItemGoldCost takes item whichItem returns integer
        local integer id = GetItemTypeId(whichItem)
        local real count = GetItemTypeIdCharges(id)
        if count > 0 then
            return R2I(costs[id]*(GetItemCharges(whichItem)/count))
        endif
        return costs[id]
    endfunction
    
    function GetItemLumberCost takes item whichItem returns integer
        local integer id = GetItemTypeId(whichItem)
        local real count = GetItemTypeIdCharges(id)
        if count > 0 then
            return R2I(costs[-id]*(GetItemCharges(whichItem)/count))
        endif
        return costs[-id]
    endfunction  
    
    // Make sure it works for everyone and every map.
    private module Inits 
        private static method onInit takes nothing returns nothing
            call thistype.init()
        endmethod
    endmodule
    private struct I extends array
        private static method init takes nothing returns nothing
            local boolean prev = ToogleUnitIndexer(false)
            //! runtextmacro ITEM_RESOURCE_COST_SHOP_UNIT()
            call ToogleUnitIndexer(prev)
            
            debug if GetUnitTypeId(shop) == 0 then
                debug call BJDebugMsg("|cffffa500Error in library ItemResourceCost:\n    |cff99b4d1--> [ Invalid unit type id for shop. Check your user settings! ]|r")
            debug endif
            
            call UnitAddAbility(shop, 'Aloc')
            call UnitAddAbility(shop, 'Asid')// Can shop.
            call SetUnitPropWindow(shop, 0)// Can't move.
            call ShowUnit(shop, false)// Can still shop. Performance friendly.
            set costs = Table.create()
            set charges = Table.create()
            set guardian = Table.create()
        endmethod
        implement Inits
    endstruct
endlibrary

// For backwards compatibility.
// You can safely delete the following code
// if not required in your map.
library_once GetItemCost uses ItemResourceCost 
    function GetItemTypeIdWoodCost takes integer id returns integer
        return GetItemTypeIdLumberCost(id) 
    endfunction
    function GetItemWoodCost takes item i returns integer
        return GetItemLumberCost(i)
    endfunction
endlibrary