scope HeroAI
//==========================================================================================
//  HeroAI v1.0.0
//      by pred1980
//==========================================================================================
	globals
		// The period in which the hero AI will do actions. A very low period can cause strain.
		public constant real DEFAULT_PERIOD = 1.7
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
		private constant integer HOLD_POSITION = 851993
	
		/*
		 * HERO STATES
		 */
		// The state in which the hero is fighting an enemy
		public constant integer STATE_ENGAGED = 0 
		// The state in which the hero is running to a shop in order to buy an item
		public constant integer STATE_GO_SHOP = 1 
		// The state in which the hero is trying to run away  
        public constant integer STATE_RUN_AWAY = 2
		// The state in which the hero is searching one of the teleporters (base/jump)
		public constant integer STATE_GO_TELEPORT = 3
		// The state in which the hero is doing nothing and waiting for some action
		public constant integer STATE_IDLE = 4 
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
		unit hero
    	player owner
		private integer pid
        private integer hId
		integer aiLevel
		integer heroLevel
		integer orderId
		private real life
        private real maxLife
        private real mana 
		private real maxMana
        real hx            
        real hy
		private timer t
		Itemset itemBuild
		private integer itemSlotCount
		group deads
		group units
		group allies        
        group enemies
		group enemyHeroes
		group allyHeroes
        integer allyNum   
        integer enemyNum
		// closest and furthest enemies
		unit closestEnemy
		unit closestEnemyHero
		unit furthestEnemy
		unit furthestEnemyHero
		// closest and furthest allies
		unit closestAlly
		unit closestAllyHero
		unit furthestAlly
		unit furthestAllyHero
		
		// The Forsaken Heart
		private unit forsakenHeart
		// Fountain
		unit safeUnit
		// Jump Teleporter
		private integer jumpTeleporterNum
		private group jumpTeleporters
		// Base Teleporter
		private unit baseTeleporter
		// Shop unit used internally
		private integer shopNum
		private group shops
		private unit shopUnit
		real moveX
        real moveY
		private real runX
        private real runY		
		
		// Used for creating
		private static integer stack = 1
		// Set whenever update is called
		static thistype tempthis
		// Holds the state of the AI
		private integer state
		// Index of the itemset
		private integer itemsetIndex
		
		private method showState takes nothing returns nothing
			if (.state == STATE_GO_TELEPORT) then
				call BJDebugMsg(GetUnitName(.hero) + ": STATE_GO_TELEPORT")
			elseif (.state == STATE_ENGAGED) then
				call BJDebugMsg(GetUnitName(.hero) + ": STATE_ENGAGED")
			elseif (.state == STATE_GO_SHOP) then
				call BJDebugMsg(GetUnitName(.hero) + ": STATE_GO_SHOP")
			elseif (.state == STATE_IDLE) then
				call BJDebugMsg(GetUnitName(.hero) + ": STATE_IDLE")
			elseif (.state == STATE_RUN_AWAY) then
				call BJDebugMsg(GetUnitName(.hero) + ": STATE_RUN_AWAY")
			else
				call BJDebugMsg(GetUnitName(.hero) + OrderId2StringBJ(GetUnitCurrentOrder(GetTriggerUnit())))
			endif
		endmethod
				
		method operator gold takes nothing returns integer
			return GetPlayerState(.owner, PLAYER_STATE_RESOURCE_GOLD)
    	endmethod
    	
    	method operator gold= takes integer g returns nothing
    		call SetPlayerState(.owner, PLAYER_STATE_RESOURCE_GOLD, g)
    	endmethod
    	
		// Returns current percent Life value
    	method operator percentLife takes nothing returns real
			return .life / .maxLife
        endmethod
		
		// Returns current percent Mana value
    	method operator percentMana takes nothing returns real
			return .mana / .maxMana
        endmethod
		
		method operator isChanneling takes nothing returns boolean
            return IsUnitChanneling(.hero)
		endmethod
		
		method updateLifeAndMana takes nothing returns nothing
			set .life = GetWidgetLife(.hero)
			set .maxLife = GetUnitState(.hero, UNIT_STATE_MAX_LIFE)
			set .mana = GetUnitState(.hero, UNIT_STATE_MANA)
			set .maxMana = GetUnitState(.hero, UNIT_STATE_MAX_MANA)
		endmethod
		
		// The condition in which the hero will return to its normal activities
		method operator goodCondition takes nothing returns boolean
        	call .updateLifeAndMana()
			
			/* COMPUTER EASY */
			if (.aiLevel == 0) then
				return 	((.percentLife >= .65) and (.percentMana >= .45))
			/* COMPUTER NORMAL */
			elseif (.aiLevel == 1) then
				return 	((.percentLife >= .75) and (.percentMana >= .55))
			/* COMPUTER INSANE */
			else
				return 	((.percentLife >= .85) and (.percentMana >= .65))
			endif       
        endmethod
		
		// The condition in which the hero will try to run away to a safe spot. 
		// Optionally complemented by the threat library
		method operator badCondition takes nothing returns boolean
			call .updateLifeAndMana()
			
        	/* COMPUTER EASY */
			if (.aiLevel == 0) then
				return 	((.percentLife <= .35) or (.percentLife <= .35 and .percentMana <= .25))
			/* COMPUTER NORMAL */
			elseif (.aiLevel == 1) then
				return 	((.percentLife <= .45) or (.percentLife <= .45 and .percentMana <= .35))
			/* COMPUTER INSANE */
			else
				return  ((.percentLife <= .55) or (.percentLife <= .55 and .percentMana <= .45))
			endif   
        endmethod
		
		// Action methods
		method move takes nothing returns nothing
			call IssuePointOrderById(.hero, MOVE, .moveX, .moveY)
        endmethod 
        
		//Note: http://www.wc3c.net/showthread.php?t=107999
		// IssuePointOrder does not work!!!
        method run takes nothing returns nothing
			//call BJDebugMsg("[HeroAI] Order " + GetUnitName(.hero) + " to run to the next Teleporter.")
			call IssuePointOrderById(.hero, MOVE, .runX, .runY)
        endmethod
		
		method defaultAssaultEnemy takes nothing returns nothing
			if (.orderId == 0) then
				call GroupClear(ENUM_GROUP)
				call GroupAddGroup(.enemies, ENUM_GROUP)
				call SetFitnessPosition(GetUnitX(.hero), GetUnitY(.hero))
				call PruneGroup(ENUM_GROUP, FitnessFunc_LowDistance, 1, NO_FITNESS_LIMIT)
				call IssueTargetOrder(.hero, "attack", FirstOfGroup(ENUM_GROUP))
			endif
		endmethod
		
		private static method filtUnits takes nothing returns boolean
            local unit u = GetFilterUnit()
			
			// Filter out dead units, the hero itself, and neutral units
            if (u != tempthis.hero) then
				// Add Unit to .units group (all units are stored in this group!!!)
				call GroupAddUnit(tempthis.units, u)
                // Filter unit --> is an ally ???
                if (SpellHelper.isValidAlly(u, tempthis.hero)) then
                    if (IsUnitType(u, UNIT_TYPE_HERO)) then
						//call BJDebugMsg(GetUnitName(u) + " is an ally hero!")
						call GroupAddUnit(tempthis.allyHeroes, u)
					endif
					call GroupAddUnit(tempthis.allies, u)
                    set tempthis.allyNum = tempthis.allyNum + 1
                // Filter unit --> is an enemy, only enum it if it's visible???
                elseif (SpellHelper.isValidEnemy(u, tempthis.hero) and IsUnitVisible(u, tempthis.owner)) then
                    if (IsUnitType(u, UNIT_TYPE_HERO)) then
						//call BJDebugMsg(GetUnitName(u) + " is an enemy hero!")
						call GroupAddUnit(tempthis.enemyHeroes, u)
					endif
					call GroupAddUnit(tempthis.enemies, u)
					set tempthis.enemyNum = tempthis.enemyNum + 1
					//call BJDebugMsg("enemyNum: " + I2S(tempthis.enemyNum))
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
				elseif (SpellHelper.isUnitDead(u)) then
					//call BJDebugMsg(GetUnitName(u) + " is a Shop!")
					call GroupAddUnit(tempthis.deads, u)
				else
					//call BJDebugMsg(GetUnitName(u) + " is actualy not defined!")
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
		
		private method useHealingPotion takes nothing returns nothing
			local Item it
			set .itemsetIndex = 0
			
			loop
				set it = .itemBuild.item(.itemsetIndex)
				exitwhen (.itemsetIndex == .itemBuild.size)
				if (it == HEALING_POTION) then
					loop
						exitwhen (.itemBuild.getStack(.itemsetIndex) == 0)
						call UnitUseItem(.hero, UnitItemInSlot(.hero, .itemsetIndex))
						call .itemBuild.decreaseStack(.itemsetIndex)
					endloop
				endif
				set .itemsetIndex = .itemsetIndex + 1
			endloop
		endmethod
		
		private method useManaPotion takes nothing returns nothing
			local Item it
			set .itemsetIndex = 0
			
			loop
				set it = .itemBuild.item(.itemsetIndex)
				exitwhen (.itemsetIndex == .itemBuild.size)
				if (it == MANA_POTION) then
					loop
						exitwhen (.itemBuild.getStack(.itemsetIndex) == 0)
						call UnitUseItem(.hero, UnitItemInSlot(.hero, .itemsetIndex))
						call .itemBuild.decreaseStack(.itemsetIndex)
					endloop
				endif
				set .itemsetIndex = .itemsetIndex + 1
			endloop
		endmethod
		
		/*
		 * ITEM RELATED CODE
		 */
		private method buyItem takes Item it returns nothing
			if (it.goldCost > 0) then
				set .gold = .gold - it.goldCost
            endif
            
			call UnitAddItemById(.hero, it.id)		
        endmethod
		
		private method canBuyItem takes Item it returns boolean
			return it.goldCost <= .gold
        endmethod
		
		// This method will be called by update periodically to check if the hero can do any shopping
        private method canShop takes nothing returns nothing
			local Item it
			local integer stack = 0
			local integer maxStack = 0
			
			loop
				// get all nessessary data
				set it = .itemBuild.item(.itemsetIndex)
				set stack = .itemBuild.getStack(.itemsetIndex)
				set maxStack = .itemBuild.getStackMax(.itemsetIndex)
				set shopTypeId = .itemBuild.shop(.itemsetIndex)
				set tempHeroOwner = .owner
				set .shopUnit = GetClosestUnit(.hx, .hy, Filter(function shopTypeIdCheck))

				exitwhen (.itemsetIndex == .itemBuild.size)
				if (.canBuyItem(it) and (stack < maxStack)) then
					if (IsUnitInRange(.hero, .shopUnit, SELL_ITEM_RANGE)) then
						loop
							//refresh stack data
							set stack = .itemBuild.getStack(.itemsetIndex)
							set maxStack = .itemBuild.getStackMax(.itemsetIndex)
							exitwhen (stack == maxStack or not .canBuyItem(it))
							call .buyItem(it)
							// Increase the stack of this item
							call .itemBuild.increaseStack(.itemsetIndex)
						endloop
						
						//count Stack Items like Potions as one item per slot
						set .itemsetIndex = .itemsetIndex + 1
					else
						call IssuePointOrderById(.hero, MOVE, GetUnitX(.shopUnit) + GetRandomReal(-SELL_ITEM_RANGE/2, SELL_ITEM_RANGE/2), GetUnitY(.shopUnit) + GetRandomReal(-SELL_ITEM_RANGE/2, SELL_ITEM_RANGE/2))
						exitwhen true
					endif
				else
					//do also increase when can't buy the item to get the next item
					set .itemsetIndex = .itemsetIndex + 1
				endif				
			endloop
        endmethod
		
		method defaultLoopActions takes nothing returns nothing
        	//call showState()
			
			// If the hero feel bad... use heal and mana potions
			if (.badCondition) then
				call useHealingPotion()
				call useManaPotion()
			endif

			if (.state == STATE_GO_SHOP) then
				call .canShop()
				
				//let the hero walk to the teleporter back to the battlefield
				if (.itemsetIndex == .itemBuild.size) then
					set .state = STATE_GO_TELEPORT
					
					// if hero is ok, leave base with the teleporter
					if (.goodCondition) then
						// Set the Base Teleporter as the next target to leave the base
						call .setWayBackToBattleField()
					endif
				endif
			endif
			
			if (.state == STATE_GO_TELEPORT) then
				if (.goodCondition) then
					static if thistype.moveActions.exists then
						if not .moveActions() then
							call .move()
						endif
					else
						call .move()
					endif
				endif
			endif
			
			if (.state == STATE_IDLE) then
				if (not .isChanneling) then
					static if thistype.idleActions.exists then
						call .idleActions()
					else
						// just for development...
						// REMOVE later from AI: Ghoul, ...
						set .moveX = -6535.1
						set .moveY = 2039.7
						call .move()
					endif
				endif
			endif
			
			if (.state == STATE_RUN_AWAY) then
				// if still need more hp/mana, run away!
				if (.badCondition) then
					// Locate the next teleporter back to base!
					call .setWayBackToBase()
					static if thistype.runActions.exists then
						if (.orderId != HOLD_POSITION) then
							call .runActions()
						endif
					else
						call .run()
					endif
				endif
			endif
			
			if (.state == STATE_ENGAGED) then
				if (not .isChanneling) then
					static if thistype.assaultEnemy.exists then
						call .assaultEnemy()
					else
						call .defaultAssaultEnemy()
					endif
				else
				endif
			endif
        endmethod
		
		// Updates information about the hero and its surroundings
        method update takes nothing returns nothing
			// Information about self
			set .heroLevel = GetUnitLevel(.hero)
			set .orderId = GetUnitCurrentOrder(.hero)
			set .hx = GetUnitX(.hero)
			set .hy = GetUnitY(.hero)
			set .itemSlotCount = UnitInventoryCount(.hero)
			set .itemsetIndex = 0
			set .gold = .gold
			set tempthis = this
			
			// clear units
			set .safeUnit = null
			set .forsakenHeart = null
			set .baseTeleporter = null
			set .closestEnemy = null
			set .closestEnemyHero = null
			set .furthestEnemy = null
			set .furthestEnemyHero = null
			set .closestAlly = null
			set .closestAllyHero = null
			set .furthestAlly = null
			set .furthestAllyHero = null
			
			// Group enumeration
			call GroupClear(.deads)
			call GroupClear(.units)
			call GroupClear(.enemies)
			call GroupClear(.enemyHeroes)
			call GroupClear(.allies)
			call GroupClear(.allyHeroes)
			call GroupClear(.jumpTeleporters)
			set .enemyNum = 0
			set .allyNum = 0
			set .jumpTeleporterNum = 0
			call GroupEnumUnitsInRange(.units, .hx, .hy, SIGHT_RANGE, Filter(function thistype.filtUnits))

			// closest and furthest enemies
			set .closestEnemy = GetClosestUnitInGroup(.hx, .hy, .enemies)
			set .closestEnemyHero = GetClosestUnitInGroup(.hx, .hy, .enemyHeroes)
			set .furthestEnemy = GetFurthestUnitInGroup(.hx, .hy, .enemies)
			set .furthestEnemyHero = GetFurthestUnitInGroup(.hx, .hy, .enemyHeroes)
			// closest and furthest allies
			set .closestAlly = GetClosestUnitInGroup(.hx, .hy, .allies)
			set .closestAllyHero = GetClosestUnitInGroup(.hx, .hy, .allyHeroes)
			set .furthestAlly = GetFurthestUnitInGroup(.hx, .hy, .allies)
			set .furthestAllyHero = GetFurthestUnitInGroup(.hx, .hy, .allyHeroes)
			
			/*
			 * STATE_GO_SHOP
			 */
			 if (.state != STATE_GO_SHOP) then
				if ((.goodCondition) 	and /*
				*/	(.safeUnit != null) and /*
				*/	(.state != STATE_GO_TELEPORT)) then
				set .state = STATE_GO_SHOP
				endif
			 endif
			 
			/*
			 * STATE_ENGAGED
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
			 * STATE_IDLE
			 */
			if (.state != STATE_IDLE) then
				if ((.goodCondition) and /*
				*/	(.safeUnit == null) and /*
				*/	(.state != STATE_GO_SHOP) and /*
				*/	(.state != STATE_RUN_AWAY) and /*
				*/	(.state != STATE_ENGAGED) or /*
				*/	(.enemyNum == 0)) then
					set .state = STATE_IDLE
				endif
			endif
			
			/*
			 * STATE_RUN_AWAY
			 */
			if (.state != STATE_RUN_AWAY) then
				// Hero has low HP? Search for the Teleporter back to the base
				if (.badCondition) then
					set .state = STATE_RUN_AWAY
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
			set .pid = GetPlayerId(.owner)
            set .hId = GetHandleId(.hero)
			set .aiLevel = Game.getAIDifficulty(.pid)
			set .heroLevel = GetUnitLevel(.hero)
			set .orderId = GetUnitCurrentOrder(.hero)
			set .deads = CreateGroup()
			set .units = CreateGroup()
			set .enemies = CreateGroup()
			set .enemyHeroes = CreateGroup()
            set .allies = CreateGroup()
			set .allyHeroes = CreateGroup()
			set .itemsetIndex = 0
			set .itemSlotCount = 0
			set .life = GetWidgetLife(.hero)
			set .maxLife = GetUnitState(.hero, UNIT_STATE_MAX_LIFE)
			set .mana = GetUnitState(.hero, UNIT_STATE_MANA)
			set .maxMana = GetUnitState(.hero, UNIT_STATE_MAX_MANA)
			
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
			
			set .t = NewTimerEx(this)
            call TimerStart(.t, DEFAULT_PERIOD, true, function thistype.defaultLoop)
			
			set stack = stack + 1
			set heroesAI[.hId] = this
			
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