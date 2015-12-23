scope ItemRegister

    globals 
        private constant integer MAX_CALLBACK_COUNT = 3
        
        constant integer ITEM_CLASS_BASIC = 0
        constant integer ITEM_CLASS_ADVANCED = 1
        constant integer ITEM_CLASS_ANCIENT = 2
        
        private integer array ITEM_LIMIT
        
        private constant boolean ALLOW_DOUBLE_ITEMS = true
        private constant boolean ALLOW_ONLY_RACE_ITEMS = true
    endglobals

    private function interface onPickup takes unit whichUnit returns nothing

    struct Item
        readonly integer id = 0
        readonly integer goldCost = 0
        readonly integer class
        readonly race r
		readonly string path
		integer amount = 0
		integer amountMax = 0
        
        private onPickup array callbacks[3]
        private integer callbackCount
        
        readonly static thistype array all
        readonly static integer count = 0
        
        private static Table t

        static method operator [] takes integer ItemId returns thistype
            return Item(.t[ItemId])
        endmethod
        
        method addCallback takes onPickup callback returns boolean
            if .callbackCount >= MAX_CALLBACK_COUNT then
                return false
            endif
            set .callbacks[.callbackCount] = callback
            set .callbackCount = .callbackCount + 1
            return true
        endmethod
        
        static method create takes integer ItemId, integer goldCost, integer class, race r, string path returns thistype
            local thistype this
            if ItemId:thistype != 0 then
                return ItemId:thistype
            endif
            set this = Item.allocate()
            set .id = ItemId
            set .goldCost = goldCost
            set .class = class
            set .r = r
			set .path = path
            set .t[.id] = this
            set .all[.count] = this
            set .count = .count + 1
            return this
        endmethod
        
        static method onPickup takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local item it = GetManipulatedItem()
            local thistype this = GetItemTypeId(it):thistype
            local thistype tthis
            local integer c = 0
            local integer i = 0
            local string msg
            //Item wurde nicht registriert = Kein normales Item, ignorieren.
            if this == 0 then
                return false
            endif
            //Prüfen, ob die Einheitenrasse passt
            static if ALLOW_ONLY_RACE_ITEMS then
                if .r != null then
                    loop
                        exitwhen i >= UnitInventorySize(u)
                        if GetUnitRace(u) != .r and GetUnitRace(u) != RACE_OTHER then
                            set c = c + 1
                            if c > 1 then
                                if .r == RACE_ORC then
                                    set msg = "an Orc"
                                elseif .r == RACE_UNDEAD then
                                    set msg = "an Undead"
                                elseif .r == RACE_HUMAN then
                                    set msg = "an Human"
                                else
                                    set msg = "a Nightelf"
                                endif
                                call UnitDropItemPoint(u, it, GetUnitX(u), GetUnitY(u))
                                call SimError(GetOwningPlayer(u), "You cannot pickup this item because it's " + msg + " Item.")
                                return false
                            endif
                        endif
                        set i = i + 1
                    endloop
                endif
            endif
            set i = 0
            set c = 0
            //Prüfen, ob die Einheit schon ein Item dieses Types hat
            static if not ALLOW_DOUBLE_ITEMS then
                loop
                    exitwhen i >= UnitInventorySize(u)
                    set tthis = GetItemTypeId(UnitItemInSlot(u, i)):thistype
                    if tthis.class != 0 then
                        if GetItemTypeId(UnitItemInSlot(u, i)) == .id then
                            set c = c + 1
                            if c > 1 then
                                call RemoveItem(it)
                                call SimError(GetOwningPlayer(u), "You cannot have more than one item of the same type.")
                                call Game.playerAddGold(GetPlayerId(GetOwningPlayer(u)), .goldCost)
                                return false
                            endif
                        endif
                    endif
                    set i = i + 1
                endloop
            endif
            //Alle Items im Inventar zählen und deren maximales count verlgeichen
            set i = 0
            set c = 0
            loop
                exitwhen i >= UnitInventorySize(u)
                set tthis = GetItemTypeId(UnitItemInSlot(u, i)):thistype
                //Items hat die selbe Klasse wie eines im Inventar
                if .class == tthis.class then
                    set c = c + 1
                endif
                set i = i + 1
            endloop
            
            //den Counter überprüfen, ob die Einheit ein Item Limit überschritten hat
            if c >= ITEM_LIMIT[.class] + 1 then
                call RemoveItem(it)
                if ITEM_LIMIT[.class] == 1 then
                    call SimError(GetOwningPlayer(u), "You cannot have more than one item of that item class.")
                else
                    call SimError(GetOwningPlayer(u), "You cannot have more than " + I2S(ITEM_LIMIT[.class]) + " items of that item class.")
                endif
                call Game.playerAddGold(GetPlayerId(GetOwningPlayer(u)), .goldCost)
                return false
            endif
            
            //Alle callback executen
            set i = 0
            loop
                exitwhen i >= .callbackCount
                call .callbacks[i].execute(u)
                set i = i + 1
            endloop
            
            return false
        endmethod
            
        static method initialize takes nothing returns nothing
            local trigger t = CreateTrigger()
            set .t = Table.create()
            set ITEM_LIMIT[ITEM_CLASS_BASIC] = 1000
            set ITEM_LIMIT[ITEM_CLASS_ADVANCED] = 6
            set ITEM_LIMIT[ITEM_CLASS_ANCIENT] = 6
            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM)
            call TriggerAddCondition(t, Condition(function thistype.onPickup))
        endmethod
    
    endstruct

endscope