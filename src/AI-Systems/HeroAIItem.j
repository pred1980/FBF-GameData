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
	public keyword AIItem
	public keyword Itemset
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
    	call AIItem.setup(HEALING_POTION, 'u000', 5)
		/*call AIItem.setup(MANA_POTION, 'u000', 3)
		call AIItem.setup(HEALING_ELEXIR, 'u000', 1)
		call AIItem.setup(MANA_ELEXIR, 'u000', 1)
		call AIItem.setup(ANTI_MAGIC_POTION, 'u000', 1)
		call AIItem.setup(INVULNERABILITY_POTION, 'u000', 1)
		call AIItem.setup(POTION_OF_INVISIBILITY, 'u000', 1)
		call AIItem.setup(SPEED_UP_POTION, 'u000', 1)
		call AIItem.setup(TELEPORT_STONE, 'u000', 1)
		call AIItem.setup(TALISMAN_OF_TRANSLOCATION, 'u000', 1)

		call AIItem.setup(HEALING_POTION, 'u00K', 5)
		call AIItem.setup(MANA_POTION, 'u00K', 3)
		*/
		/*
		 * Init Undead Items
		 */
		//ITEM_CLASS_ADVANCED: Undead
		//call AIItem.setup(BONE_HELMET, 'u001', 1)
    endfunction
	
//==========================================================================================
// END OF USER CONFIGURATION
//==========================================================================================	
    
    // serves more of an information wrapper for item cost and shop-type id
	struct AIItem extends array
		private static integer count = 0
		private static TableArray info
	
		private static integer array typeIds
		private static integer array shopIds
		private static integer array goldCosts
		// current amount of each item type
		private static integer array itemAmount
		// max amount of each item type		
		private static integer array itemAmountMax
	
		static method operator []= takes integer shopTypeId, integer itemTypeId returns thistype	
            if not (info[shopTypeId].has(itemTypeId)) then
                call BJDebugMsg("[HeroAIItem] Error: Item not registered with system")
                return 0
            endif
			call BJDebugMsg("[HeroAIItem] Error: Item already registered with system")
			return info[shopTypeId][itemTypeId]	
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
		
		method operator amount takes nothing returns integer	
			return itemAmount[this]	
		endmethod
		
		method operator amount= takes integer amount returns nothing
    		set itemAmount[this] = itemAmount[this]	 + amount
    	endmethod
		
		method operator amountMax takes nothing returns integer	
			return itemAmountMax[this]	
		endmethod
		
		static method setup takes Item it, integer shopTypeId, integer amount returns nothing
			if (count < 8190) then	
				set count = count + 1
				set info[count][0] = shopTypeId
				set info[count][1] = it.id
				call BJDebugMsg("register shopTypeId on info[" + I2S(count)+ "][0] = " + I2S(shopTypeId))
				call BJDebugMsg("register shopTypeId on info[" + I2S(count)+ "][1] = " + I2S(it.id))
				set typeIds[count] = it.id
				set shopIds[count] = shopTypeId		
				set goldCosts[count] = it.goldCost
				set itemAmount[count] = 0
				set itemAmountMax[count] = amount
			else	
				call BJDebugMsg("[HeroAIItem] Error: Max number of items registered")	
			endif
		endmethod	
	
		static method onInit takes nothing returns nothing
			//set thistype.info = Table.create()
			set thistype.info = TableArray[0x2000]
			
			//Item System
			call UnitInventory.initialize()
			call ItemShops.initialize()
			call Item.initialize()
			call Items.initialize()
			
			call SetupItems()
		endmethod
	endstruct
	
	struct Itemset extends array
		private static integer stack = 0
		private static AIItem array items[8190][2]
		private static integer array count
		
		method item takes integer index returns AIItem
        	return items[this * MAX_ITEMSET_SIZE + index][1]
        endmethod
		
		method operator size takes nothing returns integer
			return count[this]
		endmethod
		
		method addItem takes integer shopTypeId, integer itemTypeId returns nothing
			if count[this] < MAX_ITEMSET_SIZE then
				set items[this * MAX_ITEMSET_SIZE + count[this]][0] = shopTypeId
				set items[this * MAX_ITEMSET_SIZE + count[this]][1] = itemTypeId
				call BJDebugMsg("add shopTypeId on items[" + I2S(this * MAX_ITEMSET_SIZE + count[this])+ "][0] = " + I2S(shopTypeId))
				call BJDebugMsg("add itemTypeId on items[" + I2S(this * MAX_ITEMSET_SIZE + count[this])+ "][1] = " + I2S(itemTypeId))
				set count[this] = count[this] + 1
			else
				call BJDebugMsg("[HeroAIItemset] Error: Itemset already has max item ids, aborted")
			endif
		endmethod
		
		static method create takes nothing returns thistype
			set stack = stack + 1
			set count[stack] = 0
			return stack
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