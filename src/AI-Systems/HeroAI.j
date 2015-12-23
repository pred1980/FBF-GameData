scope HeroAI
//==========================================================================================
//  HeroAI v1.0.0
//      by pred1980
//==========================================================================================
/*
 * This library contains general hero behaviour like
 * - moving around the map
 * - attacking an enemy unit
 * - spending gold on items
 * - running to a "safe point"
 * - use teleporter
 * - register hero for ai
 */
 
	globals
		// The period in which the hero AI will do actions. A very low period can cause strain.
		public constant real DEFAULT_PERIOD = 2.0
		// Determines how the hero looks for items and units.
		public constant real SIGHT_RANGE = 1500.
		// The random amount of distance the hero will move
		public constant real MOVE_DIST = 1500.
		// The range the hero should be within the safe spot. 
		public constant real SAFETY_RANGE = 500.         
		
		/*
		 * ORDER IDs
		 * http://www.wc3c.net/showthread.php?t=104175
		 */
		private constant integer MOVE = 851986
		private constant integer ATTACK = 851983
	
		/*
		 * HERO STATES
		 */
		// The state in which the hero is doing nothing in particular
		public constant integer STATE_IDLE = 0 
		// The state in which the hero is fighting an enemy
		public constant integer STATE_ENGAGED = 1 
		// The state in which the hero is running to a shop in order to buy an item
		public constant integer STATE_GO_SHOP = 2 
		// The state in which the hero is trying to run away  
        public constant integer STATE_RUN_AWAY = 3

		// Tracks the AI struct a hero has
		private Table heroesAI
		// Tracks custom AI structs defined for specific unit-type ids
		private Table infoAI
		// For registering an AI for a unit	
		public unit registerUnit			
		
		// Used to pass the shop type id of an item	
		private integer shopTypeId

		// Used to refer to the AI hero for finding the closest safe unit
		private player tempHeroOwner			
    endglobals
	
	// The function that determines if it's the Forsaken Heart
	private function isForsakenHeart takes unit u returns boolean
    	return GetUnitTypeId(u) == 'H014'
	endfunction
	
	// The function that determines if it's a jump teleporter
	private function isJumpTeleporter takes unit u returns boolean
    	return GetUnitTypeId(u) == 'n007'
	endfunction
	
	// The function that determines if it's a base teleporter (from or to the base)
	private function isBaseTeleporter takes unit u returns boolean
    	//To-Do: Make two different Unit-IDs to get the correct  base teleporter for each race
		return GetUnitTypeId(u) == 'n00M'
	endfunction
	
	// The function that determines if it's a shop
	private function isShop takes unit u returns boolean
    	// Forsaken Shops
		if (GetUnitTypeId(u) == 'u000' or GetUnitTypeId(u) == 'u001' or GetUnitTypeId(u) == 'u003') then
			return true
		// Orc Shop
		elseif (GetUnitTypeId(u) == 'u00N' or GetUnitTypeId(u) == 'u00O' or GetUnitTypeId(u) == 'u00P') then
			return true
		// Human Shops
		elseif (GetUnitTypeId(u) == 'u00K' or GetUnitTypeId(u) == 'u00L' or GetUnitTypeId(u) == 'u00M') then
			return true
		// Nightelf Shops
		elseif (GetUnitTypeId(u) == 'u00H' or GetUnitTypeId(u) == 'u00I' or GetUnitTypeId(u) == 'u00J') then
			return true
		else
			return false
		endif
	endfunction
	
	// The function that determines what is a safe unit, like a fountain, for the hero to run to.
	private function isSafeUnit takes unit u returns boolean
    	return (GetUnitTypeId(u) == 'n006' or GetUnitTypeId(u) == 'n008')
    endfunction
	
	private function shopConditions takes unit u, player heroOwner returns boolean
        return true
    endfunction
	
	private function safeUnitFilter takes nothing returns boolean
		return isSafeUnit(GetFilterUnit())
	endfunction
	
	private function shopTypeIdCheck takes nothing returns boolean
		return GetUnitTypeId(GetFilterUnit()) == shopTypeId and shopConditions(GetFilterUnit(), tempHeroOwner)
	endfunction
	
	// Returns Forsaken Safe Unit (Fountain)
	private function forsakenSafeUnit takes nothing returns boolean
    	return (GetUnitTypeId(GetFilterUnit()) == 'n006')
    endfunction
	
	// Returns Forsaken Base Teleporter
	private function forsakenBaseTeleporter takes nothing returns boolean
    	return (GetUnitTypeId(GetFilterUnit()) == 'n00M')
    endfunction
	
	// Returns Coalition Base Teleporter
	// To-Do.: Create own Teleporter unit with a unique ID
	private function coalitionBaseTeleporter takes nothing returns boolean
    	return (GetUnitTypeId(GetFilterUnit()) == 'xxxx')
    endfunction
	
	//! runtextmacro HeroAILearnset()
	//! runtextmacro HeroAIItem()
	
	module HeroAI
		private unit hero
    	private player owner
        private integer hId
		private real life
        private real maxLife
        private real mana           
        private real hx            
        private real hy
		private timer t
		Itemset itemBuild
		private integer itemCount
		private group units
		private group allies        
        private group enemies       
        private integer allyNum   
        private integer enemyNum
		
		// The Forsaken Heart
		private unit forsakenHeart
		// Fountain
		private unit safeUnit
		// Jump Teleporter
		private integer jumpTeleporterNum
		private group jumpTeleporters
		// Base Teleporter
		private unit baseTeleporter
		// Shop unit used internally
		private integer shopNum
		private group shops
		private unit shopUnit
		private real moveX
        private real moveY
		private real runX
        private real runY		
		
		// Used for creating
		private static integer stack = 1
		// Set whenever update is called
		private static thistype tempthis
		// Holds the state of the AI
		private integer state
		
		private integer itemsetIndex
		
		private method showState takes nothing returns nothing
			if (.state == STATE_IDLE) then
				call BJDebugMsg("STATE: STATE_IDLE")
			elseif (.state == STATE_ENGAGED) then
				call BJDebugMsg("STATE: STATE_ENGAGED")
			elseif (.state == STATE_GO_SHOP) then
				call BJDebugMsg("STATE: STATE_GO_SHOP")
			else
				call BJDebugMsg("STATE: STATE_RUN_AWAY")
			endif
		endmethod
		
		method operator gold takes nothing returns integer
			return GetPlayerState(.owner, PLAYER_STATE_RESOURCE_GOLD)
    	endmethod
    	
    	method operator gold= takes integer g returns nothing
    		call SetPlayerState(.owner, PLAYER_STATE_RESOURCE_GOLD, g)
    	endmethod
    	
    	method operator percentLife takes nothing returns real
            return .life / .maxLife
        endmethod
		
		// The condition in which the hero will return to its normal activities
		method operator goodCondition takes nothing returns boolean
        	return 	.percentLife >= .85 and /*
			*/		.mana / GetUnitState(.hero, UNIT_STATE_MAX_MANA) >= .65      
        endmethod
		
		// The condition in which the hero will try to run away to a safe spot. 
		// Optionally complemented by the threat library
		method operator badCondition takes nothing returns boolean
        	return 	.percentLife <= .35 or /*
			*/	   	(.percentLife <= .55 and .mana / GetUnitState(.hero, UNIT_STATE_MAX_MANA) <= .3) or /*
			*/		(.maxLife < 700 and .life <= 250.)      
        endmethod
		
		method operator isChanneling takes nothing returns boolean
            return IsUnitChanneling(.hero)
        endmethod
		
		// Action methods
		private method move takes nothing returns nothing
			call BJDebugMsg("[HeroAI] Move around to point X/Y.")
            call IssuePointOrderById(.hero, MOVE, .moveX, .moveY)
        endmethod 
        
		//Note: http://www.wc3c.net/showthread.php?t=107999
		// IssuePointOrder does not work!!!
        private method run takes nothing returns nothing
			call BJDebugMsg("[HeroAI] Order " + GetUnitName(.hero) + " to run to the next Teleporter.")
			call IssuePointOrderById(.hero, MOVE, .runX, .runY)
        endmethod
		
		method defaultAssaultEnemy takes nothing returns nothing
			call BJDebugMsg("[HeroAI] Attack enemies.")
			call IssueTargetOrder(.hero, "attack", GroupPickRandomUnit(.enemies))
		endmethod
		
		private static method filtUnits takes nothing returns boolean
            local unit u = GetFilterUnit()
			
			// Filter out dead units, the hero itself, and neutral units
            if not SpellHelper.isUnitDead(u) and u != tempthis.hero then
                // Filter unit --> is an ally ???
                if (SpellHelper.isValidAlly(u, tempthis.hero)) then
                    //call BJDebugMsg(GetUnitName(u) + " is an Ally!")
					call GroupAddUnit(tempthis.allies, u)
                    set tempthis.allyNum = tempthis.allyNum + 1
                // Filter unit --> is an enemy, only enum it if it's visible???
                elseif (SpellHelper.isValidEnemy(u, tempthis.hero) and IsUnitVisible(u, tempthis.owner)) then
                    //call BJDebugMsg(GetUnitName(u) + " is an Enemy!")
					call GroupAddUnit(tempthis.enemies, u)
                    set tempthis.enemyNum = tempthis.enemyNum + 1
				// Filter unit --> is fountain???
                elseif (isSafeUnit(u)) then
					//call BJDebugMsg(GetUnitName(u) + " is an Fountain!")
					set tempthis.safeUnit = u
				// Filter unit --> is a base teleporter???
                elseif (isBaseTeleporter(u)) then
					//call BJDebugMsg(GetUnitName(u) + " is a Base Teleporter!")
					set tempthis.baseTeleporter = u
				// Filter unit --> is a jum teleporter???
                elseif (isJumpTeleporter(u)) then
					//call BJDebugMsg(GetUnitName(u) + " is a Jump Teleporter!")
					call GroupAddUnit(tempthis.jumpTeleporters, u)
                    set tempthis.jumpTeleporterNum = tempthis.jumpTeleporterNum + 1
				// Filter unit --> is a jum teleporter???
                elseif (isForsakenHeart(u)) then
					//call BJDebugMsg(GetUnitName(u) + " is the Forsaken Heart!")
					set tempthis.forsakenHeart = u
				// Filter unit --> is a jum teleporter???
                elseif (isShop(u)) then
					//call BJDebugMsg(GetUnitName(u) + " is a Shop!")
					call GroupAddUnit(tempthis.shops, u)
                    set tempthis.shopNum = tempthis.shopNum + 1
				else
					call BJDebugMsg(GetUnitName(u) + " is actualy not defined!")
				endif
				
                set u = null
                return true
            endif
			
            set u = null
            return false
        endmethod
		
		// This method defines the closest way back to battle field (directly or via teleporter)
		private method setWayBackToBattleField takes nothing returns nothing
			local race r = GetUnitRace(.hero)
			local unit t
			
			//call BJDebugMsg("setWayBackToBattleField")
			if (r == RACE_UNDEAD) then
				set t = GetClosestUnit(.hx, .hy, Filter(function forsakenBaseTeleporter))
			else
				set t = GetClosestUnit(.hx, .hy, Filter(function coalitionBaseTeleporter))
			endif
			
			set .moveX = GetUnitX(t)
			set .moveY = GetUnitY(t)
			
			call PingMinimap(.moveX, .moveY, 1.5)
			
			set t = null
		endmethod
		
		// This method defines the closest way back to base (directly or via teleporter)
		private method setWayBackToBase takes nothing returns nothing
        	// teleporter and safeUnit (Fountain)
			local unit t
			local unit f
			// Distance between teleporter and hero
			local real tDist
			// Distance between fountain and hero
			local real fDist
			// race of the owner
			local race r = GetUnitRace(.hero)
			
        	set tempHeroOwner = .owner
			
			if (r == RACE_UNDEAD) then
				set t = GetClosestUnit(.hx, .hy, Filter(function forsakenBaseTeleporter))
				set f = GetClosestUnit(.hx, .hy, Filter(function forsakenSafeUnit))
				//Calculate which is closer to the hero, fountain or teleporter?!?
				set tDist = Distance(.hx, .hy, GetUnitX(t), GetUnitY(t))
				set fDist = Distance(.hx, .hy, GetUnitX(f), GetUnitY(f))
				
				// Is the hero close to the fountain or the path is shorter?? 
				// --> Always walk directly to the fountain!
				if (.safeUnit != null or tDist > fDist ) then
					set .runX = GetUnitX(f)
					set .runY = GetUnitY(f)
				else
					set .runX = GetUnitX(t)
					set .runY = GetUnitY(t)
				endif
			else
				set t = GetClosestUnit(.hx, .hy, Filter(function coalitionBaseTeleporter))
				set .runX = GetUnitX(t)
				set .runY = GetUnitY(t)
			endif

			call PingMinimap(.runX, .runY, 1.5)
 
			set f = null
			set t = null
        endmethod
		
		/*
		 * ITEM RELATED CODE
		 */
		
		// Item-related methods
      	private method curItem takes integer shopTypeId returns Item
      		local integer itemTypeId = .itemBuild.getItemTypeId(.itemsetIndex)
			
			return AIItem.getItem(shopTypeId, itemTypeId)
      	endmethod

		private method refundItem takes Item it returns nothing
            if (it.goldCost > 0) then
                set .gold = R2I(.gold + it.goldCost * SELL_ITEM_REFUND_RATE)
            endif
        endmethod
		
		private method buyItem takes AIItem it returns nothing
            local item i
            
			//count Stack Items like Potions as one item per slot
			if (it.amount == 0) then
				set .itemsetIndex = .itemsetIndex + 1
			endif
            
        	if it.goldCost > 0 then
				set .gold = .gold - it.goldCost
            endif
            
			call UnitAddItemById(.hero, it.typeId)
			set it.amount = 1			
        endmethod
		
		private method canBuyItem takes Item it returns boolean
            static if CHECK_REFUND_ITEM_COST then
				local Item check
				
				if (.itemCount == MAX_INVENTORY_SIZE) then
					set check = AIItem.getItem(it.shopTypeId, it.id)
					
					return it.goldCost <= .gold + check.goldCost * SELL_ITEM_REFUND_RATE
				endif
            endif
			
			if (it.goldCost <= .gold) then
				call BJDebugMsg("You have enough gold to buy this item!")
			else
				call BJDebugMsg("You do NOT have enough gold to buy this item!")
			endif
			
        	return it.goldCost <= .gold
        endmethod

		// This method will be called by update periodically to check if the hero can do any shopping
        private method canShop takes nothing returns nothing
        	local Item it

        	loop
				set it = .curItem
				exitwhen not (.canBuyItem(it) or .itemsetIndex == .itemBuild.size)
				set shopTypeId = it.shopTypeId
				set tempHeroOwner = .owner
				set .shopUnit = GetClosestUnit(.hx, .hy, Filter(function shopTypeIdCheck))
				
				call BJDebugMsg("itemBuild.size: " + I2S(.itemBuild.size))
				call BJDebugMsg("itemsetIndex: " + I2S(.itemsetIndex))
				call BJDebugMsg("shopTypeId: " + I2S(it.shopTypeId))
				call BJDebugMsg("itemGoldCost: " + I2S(it.goldCost))
				call BJDebugMsg("itemAmountMax: " + I2S(it.amountMax))
				
				if (IsUnitInRange(.hero, .shopUnit, SELL_ITEM_RANGE)) then
					loop
						exitwhen (it.amount ==  it.amountMax or it.goldCost > .gold)
						call .buyItem(it)
					endloop
				else
					call IssuePointOrderById(.hero, MOVE, GetUnitX(.shopUnit) + GetRandomReal(-SELL_ITEM_RANGE/2, SELL_ITEM_RANGE/2), GetUnitY(.shopUnit) + GetRandomReal(-SELL_ITEM_RANGE/2, SELL_ITEM_RANGE/2))
					exitwhen true
				endif
			endloop
			
			// Set back to state idle now that the hero is done shopping.
            //set .state = STATE_IDLE
			// Set the Base Teleporter as the next target to leave the base
			//call .setWayBackToBattleField()
        endmethod
		
		method defaultLoopActions takes nothing returns nothing
        	call showState()
			
			if (.state == STATE_RUN_AWAY) then
				// Locate the next teleporter back to base!
				call .setWayBackToBase()
				
				static if thistype.runActions.exists then
					// Only run if no actions were taken in runActions.
					if not .runActions() then
						call .run()
					endif
				else
					call .run()
				endif
			endif
			
			if (.state == STATE_IDLE) then
				static if thistype.moveActions.exists then
					if not .moveActions() then
						call .move()
					endif
				else
					call .move()
				endif
			endif
			
			if (.state == STATE_ENGAGED) then
				static if thistype.assaultEnemy.exists then
					call .assaultEnemy()
				else
					call .defaultAssaultEnemy()
				endif
			endif
			
			if (.state == STATE_GO_SHOP) then
				call .canShop()
			endif
        endmethod
		
		// Updates information about the hero and its surroundings
        method update takes nothing returns nothing
			// Information about self
			set .hx = GetUnitX(.hero)
			set .hy = GetUnitY(.hero)
			set .life = GetWidgetLife(.hero)
			set .mana = GetUnitState(.hero, UNIT_STATE_MANA)
			set .maxLife = GetUnitState(.hero, UNIT_STATE_MAX_LIFE)
			set .itemCount = UnitInventoryCount(.hero)
			set .gold = .gold
			set tempthis = this
			
			call ClearTextMessages()
			
			// clear units
			set .safeUnit = null
			set .forsakenHeart = null
			set .baseTeleporter = null
			
			// Group enumeration
			call GroupClear(.units)
			call GroupClear(.enemies)
			call GroupClear(.allies)
			call GroupClear(.jumpTeleporters)
			set .enemyNum = 0
			set .allyNum = 0
			set .jumpTeleporterNum = 0
			call GroupEnumUnitsInRange(.units, .hx, .hy, SIGHT_RANGE, Filter(function thistype.filtUnits))
			
			/*
			 * State STATE_RUN_AWAY
			 */
			if (.state != STATE_RUN_AWAY) then
				// Hero has low HP? Search for the Teleporter back to the base
				if (.badCondition) then
					set .state = STATE_RUN_AWAY
				endif
			endif
			
			/*
			 * State STATE_IDLE
			 */
			if (.state != STATE_IDLE) then
				if (.goodCondition and .safeUnit != null) then
					set .state = STATE_IDLE
				endif
			endif
			
			/*
			 * State STATE_ENGAGED
			 */
			if (.state != STATE_ENGAGED) then
				// Is everything ok and no nearby fountain? Search for enemies...
				if (.goodCondition and .safeUnit == null) then
					if (.enemyNum > 0) then
						set .state = STATE_ENGAGED
					endif
				endif
			endif
			
			/*
			 * State STATE_GO_SHOP
			 */
			 if (.state != STATE_GO_SHOP) then
				if (.goodCondition and .safeUnit != null) then
					// Only check to do shopping if in the AI hasn't completed its itemset and it's in STATE_IDLE
					if (.itemsetIndex < .itemBuild.size and .state == STATE_IDLE) then
						set .state = STATE_GO_SHOP
					endif
				endif
			 endif
		endmethod

		private static method defaultLoop takes nothing returns nothing
        	local thistype this = GetTimerData(GetExpiredTimer())
        	
			if not (SpellHelper.isUnitDead(.hero)) then
				call .update()
				static if thistype.loopActions.exists then
					call .loopActions()
				else
					call .defaultLoopActions()
				endif
			endif
        endmethod
		
		static method create takes unit hero returns thistype
    		local thistype this = stack
    		local integer lvl = 1	
            local integer typeId = GetUnitTypeId(hero)
			
			set .hero = hero
            set .owner = GetOwningPlayer(.hero)
            set .hId = GetHandleId(.hero)
			
			set .units = CreateGroup()
			set .enemies = CreateGroup()
            set .allies = CreateGroup()
			
			set .itemBuild = Itemset.create()
            set .itemsetIndex = 0
            
            set .state = STATE_IDLE
			
			set .t = NewTimerEx(this)
            call TimerStart(.t, DEFAULT_PERIOD, true, function thistype.defaultLoop)
			
			static if thistype.onCreate.exists then
				call .onCreate()
			endif
			
			if (GetHeroSkillPoints(.hero) > 0) then
				loop
					exitwhen lvl > GetUnitLevel(.hero)
					call SelectHeroSkill(.hero, learnsetInfo[lvl][typeId])
					set lvl = lvl + 1
				endloop
			endif
			
			set stack = stack + 1
			set heroesAI[.hId] = this
			
			call BJDebugMsg("[HeroAI] Info: The hero " + GetUnitName(.hero) + " is registered to the Hero AI System.")
    		return this
		endmethod
	endmodule
	
	globals
        private trigger fireTrigger = CreateTrigger()
    endglobals
    
    // credits to Magtheridon96 for this function
    private function FireCondition takes boolexpr b returns nothing
        call TriggerClearConditions(fireTrigger)
        call TriggerAddCondition(fireTrigger, b)
        call TriggerEvaluate(fireTrigger)
    endfunction
	
	private struct DefaultHeroAI extends array
    	implement HeroAI
    endstruct
	
	function RunHeroAI takes unit hero returns nothing
		if (heroesAI.has(GetHandleId(hero))) then
            call BJDebugMsg("[Hero AI] Error: Attempt to run an AI for a unit that already has one, aborted.")
			return
        endif
		
		if (infoAI.boolexpr[GetUnitTypeId(hero)] != null) then
        	set registerUnit = hero
			call FireCondition(infoAI.boolexpr[GetUnitTypeId(hero)])
        else
            call DefaultHeroAI.create(hero)        
        endif
	endfunction
	
	function RegisterHeroAI takes integer unitTypeId, code register returns nothing
        if infoAI.boolexpr[unitTypeId] != null then
            call BJDebugMsg("[Hero AI] Error: Attempt to register an AI struct for a unit-type id again, aborted")
            return
        endif
        set infoAI.boolexpr[unitTypeId] = Filter(register)
    endfunction
	
	//! textmacro HeroAI_Register takes HERO_UNIT_TYPEID
    private function RegisterAI takes nothing returns nothing          
        call AI.create(HeroAI_registerUnit)
    endfunction
    
    private module ModuleHack
     	static method onInit takes nothing returns nothing
     		call RegisterHeroAI($HERO_UNIT_TYPEID$, function RegisterAI)
     	endmethod
    endmodule    
    
    private struct StructHack extends array
    	implement ModuleHack
    endstruct
    //! endtextmacro
	
	private module I 
        static method onInit takes nothing returns nothing
			set infoAI = Table.create()
            set heroesAI = Table.create()            
        endmethod
    endmodule
    
    private struct A extends array
        implement I
    endstruct
endscope