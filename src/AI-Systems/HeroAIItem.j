//==========================================================================================
// This is separated from the main system of HeroAI to provide better organization.
//
// It covers what items the AI will buy and how the data structures are set up.
// Configuration of what kinds of items shops sell is also done here.
//##########################################################################################
//  Itemset API:
//
//	* struct HeroAI_Itemset
//		The data structure for storing the item ids and costs. Only holds up to MAX_INVENTORY_SIZE 
//		items. You should treat instances of these as being static since they shouldn't be destroyed.
//
//  * method addItemTypeId takes integer itemTypeId returns nothing *
//      Adds an item type to the itemset instance.  
//==========================================================================================

// Please don't call this textmacro.
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
	public keyword Item
	public keyword Itemset
	globals
		public Itemset DefaultItemBuild
	endglobals
	
	// You must set up all the items the AI can buy here. Each item should only be set up once.
	// Note that a shop type id of 0 will cause the AI to buy the item without bothering to
    // go to an actual shop.
    // It is also advised to set up all items the hero can pick up and sell so that
    // they will be refunded properly.
    //
    // Currently, multiple shops selling the same item is not supported.
	private function SetupItems takes nothing returns nothing
		// Syntax:
    	// call Item.setup(ITEM-TYPE ID, SHOP-TYPE ID, GOLD COST, LUMBER COST)
    	
    	call Item.setup('gcel', 'ngad', 100, 0) // Gloves of Haste
    	call Item.setup('bspd', 'ngad', 150, 0) // Boots of Speed
    	call Item.setup('rlif', 'ngme', 200, 0) // Ring of Regeneration
    	call Item.setup('prvt', 'ngad', 350, 0) // Periapt of Vitality
    	call Item.setup('rwiz', 'ngme', 400, 0) // Sobi Mask
    	call Item.setup('pmna', 'ngad', 500, 0) // Pendant of Mana
        
        // Paladin Items:
        call Item.setup('ratc', 'ngme', 500, 0) // Claws of Attack + 12
        call Item.setup('rst1', 'ngad', 100, 0) // Gauntlets of Ogre Strength +3
        call Item.setup('rde3', 'ngme', 500, 0) // Ring of Protection +4
	endfunction
	
	// Sets up the default item build for AI heroes to get if itemBuild is not overridden.
    // You should configure this for your own map.
	private function SetupDefaultItemBuild takes nothing returns nothing
		// Syntax:
    	// call DefaultItemBuild.addItem(ITEM-TYPE ID)
    	
    	call DefaultItemBuild.addItemTypeId('gcel')
    	call DefaultItemBuild.addItemTypeId('bspd')
    	call DefaultItemBuild.addItemTypeId('rlif')
    	call DefaultItemBuild.addItemTypeId('prvt')
    	call DefaultItemBuild.addItemTypeId('rwiz')
    	call DefaultItemBuild.addItemTypeId('pmna')
        
        call DefaultItemBuild.addItemTypeId('rwiz') // Replaces item in hero's first slot
    endfunction
	
//==========================================================================================
// END OF USER CONFIGURATION
//==========================================================================================	
    
    // serves more of an information wrapper for item cost and shop-type id
	struct Item extends array
		private static integer count = 0
		private static Table info
	
		private static integer array typeIds
		private static integer array shopIds
		private static integer array goldCosts
		private static integer array lumberCosts
	
		static method operator [] takes integer itemTypeId returns thistype	
            debug if not info.has(itemTypeId) then
                debug call BJDebugMsg("[HeroAIItem] Error: Item not registered with system")
                return 0
            debug endif
			return info[itemTypeId]	
		endmethod

		method operator typeId takes nothing returns integer
			return typeIds[this]
		endmethod
	
		method operator shopTypeId takes nothing returns integer
			return shopIds[this]
		endmethod
	
		method operator goldCost takes nothing returns integer	
			return goldCosts[this]	
		endmethod
	
		method operator lumberCost takes nothing returns integer	
			return lumberCosts[this]	
		endmethod
	
		static method setup takes integer itemTypeId, integer shopTypeId, integer goldCost, integer lumberCost returns nothing
			if count < 8190 then	
				set count = count + 1		
				set info[itemTypeId] = count	
				set typeIds[count] = itemTypeId
				set shopIds[count] = shopTypeId		
				set goldCosts[count] = goldCost		
				set lumberCosts[count] = lumberCost		
			debug else	
				debug call BJDebugMsg("[HeroAIItem] Error: Max number of items registered")	
			endif
		endmethod	
	
		static method onInit takes nothing returns nothing
			set thistype.info = Table.create()
			call SetupItems()
		endmethod
	endstruct
	
	struct Itemset extends array
		private static integer stack = 0
		private static Item array items
		private static integer array count
		
		method item takes integer index returns Item
        	return items[this * MAX_ITEMSET_SIZE + index]
        endmethod
		
		method operator size takes nothing returns integer
			return count[this]
		endmethod
		
		method addItemTypeId takes integer itemTypeId returns nothing
			if count[this] < MAX_ITEMSET_SIZE then
				set items[this * MAX_ITEMSET_SIZE + count[this]] = Item[itemTypeId]
				set count[this] = count[this] + 1
			debug else
				debug call BJDebugMsg("[HeroAIItemset] Error: Itemset already has max item ids, aborted")
			endif
		endmethod
		
		static method create takes nothing returns thistype
			set stack = stack + 1
			set count[stack] = 0
			return stack
		endmethod
		
		static method onInit takes nothing returns nothing
			set DefaultItemBuild = Itemset.create()
			call SetupDefaultItemBuild()
		endmethod
	endstruct
	
	globals
		// Used to determine if the AI could only get power ups
		private boolean OnlyPowerUp     
	endglobals
	
	private function AIItemFilter takes nothing returns boolean
		return GetWidgetLife(GetFilterItem()) > 0.405 and IsItemVisible(GetFilterItem()) and (IsItemPowerup(GetFilterItem()) or not OnlyPowerUp)
	endfunction
	
//! endtextmacro