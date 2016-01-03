//! textmacro HeroAIItem 

	globals		
		// The max amount of items a hero can hold
		private constant integer MAX_INVENTORY_SIZE = 6
		// The range at which shops sell items
        public  constant real SELL_ITEM_RANGE = 300.
		// The rate at which items' cost are refunded
		private constant real SELL_ITEM_REFUND_RATE = 0.5
		// The range at which the hero is from a shop and will ignore enemies in favor of buying items. 
		// Only considered if the hero is not already in STATE_ENGAGED
        private constant real IGNORE_ENEMY_SHOP_RANGE = 600.  
		// The max amount of items that can be in one itemset
		private constant integer MAX_ITEMSET_SIZE = 12    
        // Decides if the AI should consider an item's refund price when deciding to buy items
		private constant boolean CHECK_REFUND_ITEM_COST = true  
    endglobals
	
	// Don't touch the following
	public keyword Itemset
	// You must set up all the items the AI can buy here. Each item should only be set up once.
	// Note that a shop type id of 0 will cause the AI to buy the item without bothering to
    // go to an actual shop.
    // It is also advised to set up all items the hero can pick up and sell so that
    // they will be refunded properly.
    //
    // Currently, multiple shops selling the same item is not supported.
	private function registerItems takes nothing returns nothing
		// Syntax:
    	// call Item.setup(ITEM-TYPE ID, SHOP-TYPE ID, GOLD COST, LUMBER COST)
    	/*call AIItem.register(HEALING_POTION, 'u000')
		call AIItem.register(MANA_POTION, 'u000', 3)
		call AIItem.register(HEALING_ELEXIR, 'u000', 1)
		call AIItem.register(MANA_ELEXIR, 'u000', 1)
		call AIItem.register(ANTI_MAGIC_POTION, 'u000', 1)
		call AIItem.register(INVULNERABILITY_POTION, 'u000', 1)
		call AIItem.register(POTION_OF_INVISIBILITY, 'u000', 1)
		call AIItem.register(SPEED_UP_POTION, 'u000', 1)
		call AIItem.register(TELEPORT_STONE, 'u000', 1)
		call AIItem.register(TALISMAN_OF_TRANSLOCATION, 'u000', 1)

		call AIItem.register(HEALING_POTION, 'u00K', 5)
		call AIItem.register(MANA_POTION, 'u00K', 3)
		*/
		/*
		 * Init Undead Items
		 */
		//ITEM_CLASS_ADVANCED: Undead
		//call AIItem.register(BONE_HELMET, 'u001', 1)
    endfunction
	
//==========================================================================================
// END OF USER CONFIGURATION
//==========================================================================================

	struct Itemset
		private integer count = 0
		private TableArray items
		
		// Returns the shop_id
		method shop takes integer index returns integer
        	return items[index][0]
        endmethod
		
		// Returns the Item
		method item takes integer index returns Item
        	return items[index][1]
        endmethod
		
		// Get the current amount of the item
		method getStack takes integer index returns integer
        	return items[index][2]
        endmethod
		
		// increase the current amount of the item
		method increaseStack takes integer index returns nothing
        	set items[index][2] = items[index][2] + 1
        endmethod
		
		// increase the current amount of the item
		method decreaseStack takes integer index returns nothing
        	set items[index][2] = items[index][2] - 1
        endmethod
		
		// Returns the max amount of item the hero can buy
		method getStackMax takes integer index returns integer
        	return items[index][3]
        endmethod
		
		method operator size takes nothing returns integer
			return .count
		endmethod
		
		method addItem takes integer shopTypeId, Item it, integer amountMax returns nothing
			if (.count < MAX_ITEMSET_SIZE) then
				set items[.count][0] = shopTypeId
				set items[.count][1] = it
				set items[.count][2] = 0
				set items[.count][3] = amountMax
				set .count = .count + 1
			else
				call BJDebugMsg("[HeroAIItemset] Error: Itemset already has max item ids, aborted")
			endif
		endmethod
		
		static method create takes nothing returns thistype
			local thistype this = thistype.allocate()
			set .items = TableArray[0x2000]
			
			return this
		endmethod

		private static method onInit takes nothing returns nothing
			//Item System
			call UnitInventory.initialize()
			call ItemShops.initialize()
			call Item.initialize()
			call Items.initialize()
		endmethod				
	endstruct
	
//! endtextmacro