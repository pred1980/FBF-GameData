/*
            GetItemCost v1.0.0
               by kingking
               
    GetItemCost is a simple snippet that let you to get the cost 
    of an item without entering the relative cost and item id to
    database, like hashtable.
    
    Function provided :
    GetItemGold(itemId) -> integer
    GetItemLumber(itemId) -> integer
    
    Mechanism description :
    GetItemCost creates a dummy at the middle of map.
    To get item cost, simply add the item to the dummy and ask
    the dummy to buy the item.
    Then store the difference between before and after of the
    lumber and gold.
    
    Requires :
    Table
*/
library GetItemCost requires Table
    
    globals
        private Table Gold
        private Table Lumber
        private unit Dummy
        private integer array ItemIdStack
        private integer StackLevel = 0
    endglobals
    
    private function PreloadItemCost takes integer id returns nothing
        local integer gold
        local integer lumber
        call SetPlayerState(Player(15),PLAYER_STATE_RESOURCE_GOLD,1000000)
        call SetPlayerState(Player(15),PLAYER_STATE_RESOURCE_LUMBER,1000000)
        call AddItemToStock(Dummy,id,1,1)
        set StackLevel = StackLevel + 1
        set ItemIdStack[StackLevel] = id
        call IssueImmediateOrderById(Dummy, id)
        set gold = GetPlayerState(Player(15),PLAYER_STATE_RESOURCE_GOLD)
        set lumber = GetPlayerState(Player(15),PLAYER_STATE_RESOURCE_LUMBER)
        set Gold[id] = 1000000 - gold
        set Lumber[id] = 1000000 - lumber
        // All right, get the item cost here and save to hashtable.
    endfunction
    
    function GetItemGold takes integer id returns integer
        if Gold.exists(id) == false then
            call PreloadItemCost(id)
        endif
        return Gold[id]
    endfunction
    
    function GetItemLumber takes integer id returns integer
        if Lumber.exists(id) == false then
            call PreloadItemCost(id)
        endif
        return Lumber[id]
    endfunction
    
    private struct Initializer extends array
        private static timer t
        private static rect r
        private static integer nearest_id
        private static real nearest_range
        private static item nearest_item
        
        private static method getNearestItem takes nothing returns boolean
            local item i = GetFilterItem()
            local real range
            if nearest_id == GetItemTypeId(i) then
                set range = GetWidgetX(i) * GetWidgetX(i) + GetWidgetY(i) * GetWidgetY(i)
                if range <= nearest_range then
                    set nearest_range = range
                    set nearest_item = i
                endif
            endif
            set i = null
            return false
        endmethod
        
        private static method removeItems takes nothing returns nothing
            loop
            exitwhen StackLevel == 0
                set thistype.nearest_range = 10000000000.
                set thistype.nearest_id = ItemIdStack[StackLevel]
                set thistype.nearest_item = null
                call EnumItemsInRect(r,Condition(function thistype.getNearestItem),null)
                call RemoveItem(thistype.nearest_item)
                set StackLevel = StackLevel - 1
            endloop
        endmethod
        
        private static method addDelay takes nothing returns boolean
            call ResumeTimer(thistype.t)
            //Zero callback, else created item can't be found.
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            local trigger trig
            
            set Gold = Table.create()
            set Lumber = Table.create()
            set r = GetWorldBounds()
            
            set Dummy = CreateUnit(Player(15),'nshe',0.,0.,0.)
            call SetUnitPathing(Dummy,false)
            call ShowUnit(Dummy,false)
            call UnitAddAbility(Dummy,'Asid')
            
            set trig = CreateTrigger()
            call TriggerRegisterUnitEvent(trig,Dummy,EVENT_UNIT_ISSUED_ORDER)
            call TriggerAddCondition(trig,Condition(function thistype.addDelay))
            //We have to removed the created item.
            
            set thistype.t = CreateTimer()
            call TimerStart(thistype.t,0.0,false,function thistype.removeItems)
        endmethod
    endstruct
    
endlibrary