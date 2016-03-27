scope TowerBuildAI

    globals
        /**
         * The tower size width.
         */
        private constant integer TOWER_SIZE_WIDTH = 0

        /**
         * The tower size height.
         */
        private constant integer TOWER_SIZE_HEIGHT = 1

        /**
         * The event to upgrade after finish build.
         */
        private constant integer TOWER_AI_EVENT_UPGRADE = 1

        /**
         * The event to build next tower after begin build.
         */
        private constant integer TOWER_AI_EVENT_BUILD = 2

        /**
         * The max players.
         */
        private constant integer TOWER_AI_MAX_PLAYER = 12

        /**
         * The max events.
         */
        private constant integer TOWER_AI_MAX_EVENTS = 100

        /**
         * The max upgrade queue.
         */
        private constant integer MAX_UPGRADE_QUEUE = 10
    endglobals

    /**
     * The tower upgrade struct.
     */
    struct TowerUpgrade
        /**
         * The last upgrade tower id.
         * @var integer
         */
        private integer towerId = 0

        /**
         * The tower key.
         * @var integer
         */
        private integer key = -1

        /**
         * Is active
         * @var boolean
         */
        private boolean active = false

        /**
         * Sets the tower id.
         * @param integer towerId
         */
        public method setTowerId takes integer towerId returns nothing
            set .towerId = towerId
        endmethod
        /**
         * Sets the tower id.
         * @param integer towerId
         */
        public method getTowerId takes nothing returns integer
            return .towerId
        endmethod

        /**
         * Sets the tower key.
         * @param integer key
         */
        public method setKey takes integer key returns nothing
            set .key = key
        endmethod

        /**
         * Returns the tower key.
         * @return integer
         */
        public method getKey takes nothing returns integer
            return .key
        endmethod

        /**
         * Sets is active.
         * @param boolean active
         */
        public method setActive takes boolean active returns nothing
            set .active = active
        endmethod

        /**
         * Gets is active.
         * @return boolean
         */
        public method isActive takes nothing returns boolean
            return .active
        endmethod

        /**
         * Reset the upgrade tower object.
         */
        public method reset takes nothing returns nothing
                set .active = false
                set .towerId = 0
                set .key = -1
        endmethod

    endstruct

    /**
     * the config for the tower build
     */
    struct TowerBuildConfig
        /**
         * the buildings that can build. more unique tower is the chance higher that build at next
         * @var integer[]|array
         */
        private integer array buildings[100]
        /**
         * the building position
         * @var integer
         */
        private integer buildingPosition = 0

        /**
         * add an building to the "can build"
         * @param integer building
         */
        public method addBuilding takes integer building returns nothing
            if .buildingPosition < 100 then
                set .buildings[.buildingPosition] = building
                set .buildingPosition = .buildingPosition + 1
            endif
        endmethod

        /**
         * gets an building from the config
         * @return integer
         */
        public method getRandomBuilding takes nothing returns integer
            return .buildings[GetRandomInt(0, .buildingPosition - 1)]
        endmethod

        /**
         * resets the buildings that can build by config
         */
        public method resetBuildings takes nothing returns nothing
            local integer building = 0
            loop
                set .buildings[building] = 0
                set building = building + 1
                exitwhen building >= .buildingPosition
            endloop
            set .buildingPosition = 0
        endmethod
    endstruct

    /**
     * the towers
     */
    struct TowerHelper
        /**
         * the towers
         * @var hashtable
         */
        private hashtable towers

        /**
         * has towers
         * @var boolean
         */
        private boolean hasTowers = false

        /**
         * the column type id
         * @integer
         */
        public integer columnUnitId = -1

        /**
         * the column damage
         * @integer
         */
        public integer columnDamage = -1

        /**
         * the column level
         * @integer
         */
        public integer columnLevel = -1

        /**
         * the column wood cost
         * @integer
         */
        public integer columnWoodCost = -1

        /**
         * the column gold cost
         * @integer
         */
        public integer columnGoldCost = -1

        /**
         * the column child tower
         * @integer
         */
        public integer columnChildTower = -1

        /**
         * set the towers
         * @param hastable towers
         */
        public method setTowers takes hashtable towers returns nothing
            set .towers = towers
            set .hasTowers = true
        endmethod

        /**
         * get the column value
         * @param integer towerKey
         * @param integer column
         * @return integer
         */
        public method getColumnValue takes integer towerKey, integer column returns integer
            local integer result = -1
            if (.hasTowers and column >= 0 and towerKey >= 0) then
                set result = LoadInteger(.towers, column, towerKey)
            endif
            return result
        endmethod

        /**
         * gets parent tower
         * @param integer towerKey
         * @return integer
         */
        public method getParentTowerKey takes integer towerKey returns integer
            local integer tower = 0
            local boolean isParent = false
            local integer towerUnitId
            local integer childTower
            if (.hasTowers and towerKey >= 0) then
                set towerUnitId = LoadInteger(.towers, .columnUnitId, towerKey)
                loop
                    set childTower = LoadInteger(.towers, .columnChildTower, tower)
                    set isParent = childTower == towerUnitId
                    exitwhen LoadInteger(.towers, .columnUnitId, tower) <= 0 or isParent
                    set tower = tower + 1
                endloop
            endif
            if (not isParent) then
                set tower = -1
            endif
            return tower
        endmethod

        /**
         * gets parent tower
         * @param integer unitId
         * @return Tower
         */
        public method getTowerKeyByUnitId takes integer unitId returns integer
            local integer column = 0
            local integer loadUnitId = 0
            if (.columnUnitId >= 0 and .hasTowers) then
                loop
                    set loadUnitId = LoadInteger(.towers, .columnUnitId, column)
                    exitwhen loadUnitId == unitId or loadUnitId == 0
                    set column = column + 1
                endloop
            else
                set column = -1
            endif
            return column
        endmethod

        /**
         * gets parent tower
         * @param integer unitId
         * @return Tower
         */
        public method getTowerKeyFirstLevelByUnitId takes integer unitId returns integer
            local integer column = -1
            local integer lastColumn = -1
            if (.columnUnitId >= 0 and .hasTowers) then
                set column = .getTowerKeyByUnitId(unitId)
                set lastColumn = column
                loop
                    set lastColumn = .getParentTowerKey(lastColumn)
                    exitwhen lastColumn == -1
                    set column = lastColumn
                endloop
            endif
            return column
        endmethod

        /**
         * Returns the tower lumber costs includes upgrades.
         * @param integer unitId
         * @return integer
         */
        public method getTowerLumberCost takes integer unitId returns integer
            local integer column = -1
            local integer lumberCost = 0
            if (.columnUnitId >= 0 and .hasTowers) then
                set column = .getTowerKeyByUnitId(unitId)
                loop
                    set lumberCost = lumberCost + .getColumnValue(column, .columnWoodCost)
                    set column = .getParentTowerKey(column)
                    exitwhen column == -1
                endloop
            endif
            return lumberCost
        endmethod
    endstruct

    /**
     * the AI for the tower build
     */
    struct TowerBuildAI
        /**
         * the tower helper
         * @var TowerHelper
         */
        private TowerHelper towers

        /**
         * has towers helper set
         * @var boolean
         */
        private boolean hasTowersHelper

        /**
         * all positions to build
         * @var hashtable
         * @todo need to add
         */
        private hashtable positions

        /**
         * all tower units
         * @var unit[]|array
         */
        private unit array tower[60]

        /**
         * the current tower count
         * @var integer
         */
        private integer towerCount

        /**
         * The tower build config
         * @var TowerBuildConfig
         */
        private TowerBuildConfig config

        /**
         * the builder unit
         * @var unit
         */
        private unit builder

        /**
         * the tower size
         * @var real[]|array
         */
        private real array towerSize[2]

        /**
         * current region
         */
        private integer countRegion = 0

        /**
         * the tower builder is enabled
         * @var boolean
         */
        private boolean enabled = false

        /**
         * the builder has builded
         * @var boolean
         */
        public boolean builded = false

        /**
         * the builder can build again
         * @var boolean
         */
        public boolean canBuild = false

        /**
         * the upgrade queue
         * @var TowerUpgrade[]|array
         */
        public TowerUpgrade array upgradeQueue[MAX_UPGRADE_QUEUE]

        /**
         * the player id
         * @var integer
         */
        public integer playerId = -1

        /**
         * lumber cost for upgrade
         * @var integer
         */
        private integer lumberCost = 0

        /**
         * The chosen region to build at first.
         * @var integer
         */
        private integer chosenRegion = 0

        /**
         * Remove tower unit id
         * @var integer
         */
        private integer sellTowerTrain = 0

        /**
         * @deprecated
         */
        private static integer MAX_REGIONS = 3
        /**
         * @deprecated
         */
        private real array positionLeft[3]
        /**
         * @deprecated
         */
        private real array positionRight[3]
        /**
         * @deprecated
         */
        private real array positionTop[3]
        /**
         * @deprecated
         */
        private real array positionBottom[3]
        /**
         * @deprecated
         */
        private boolean leftToRight = false
        /**
         * @deprecated
         */
        private boolean topToBottom = false

        /**
         * initialize the tower build ai
         */
        public method initialize takes nothing returns nothing
            local integer counter = 0
            loop
                set .upgradeQueue[counter] = TowerUpgrade.create()
                set counter = counter + 1
                exitwhen counter >= MAX_UPGRADE_QUEUE
            endloop
        endmethod

        /**
         * Sets the builder build an tower.
         * @param boolean builded
         */
        public method setBuilded takes boolean builded returns nothing
            set .builded = builded
        endmethod

        /**
         * Returns the builder build an tower.
         * @return boolean
         */
        public method getBuilded takes nothing returns boolean
            return .builded
        endmethod

        /**
         * Sets the chosen region
         * @param integer chosenRegion
         */
        public method setChosenRegion takes integer chosenRegion returns nothing
            set .chosenRegion = chosenRegion
        endmethod

        /**
         * set the towers
         * @param TowerHelper towers
         */
        public method setTowers takes TowerHelper towers returns nothing
            set .towers = towers
            set .hasTowersHelper = true
        endmethod

        /**
         * Returns the towers.
         * @return TowerHelper
         */
        public method getTowers takes nothing returns TowerHelper
            return .towers
        endmethod

        /**
         * sets the builder
         * @param unit Builder
         */
        public method setBuilder takes unit builder returns nothing
            set .builder = builder
            set .enabled = true
            set .builded = false
        endmethod

        /**
         * Returns the builder.
         * @return unit
         */
        public method getBuilder takes nothing returns unit
            return .builder
        endmethod

        /**
         * add tower to array
         * @param unit tower
         */
        public method addTower takes unit tower returns nothing
            set .tower[.towerCount] = tower
            call .addTowerToUpgradeQueue(.towerCount)
            set .towerCount = .towerCount + 1
        endmethod

        /**
         * Add tower to upgrade queue entry.
         * @param integer towerKey
         */
        public method addTowerToUpgradeQueue takes integer towerKey returns nothing
            local integer currentPosition = 0
            local integer unitId = GetUnitTypeId(.tower[.towerCount])
            local integer upgradeTowerKey
            loop
                set upgradeTowerKey = .towers.getTowerKeyFirstLevelByUnitId(.upgradeQueue[currentPosition].getTowerId())
                if (not .upgradeQueue[currentPosition].isActive() /*
                */ and .towers.getColumnValue(upgradeTowerKey, .towers.columnUnitId) == unitId /*
                */) then
                    call .upgradeQueue[currentPosition].setKey(towerKey)
                    call .upgradeQueue[currentPosition].setActive(true)
                    set currentPosition = MAX_UPGRADE_QUEUE
                endif
                set currentPosition = currentPosition + 1
                exitwhen currentPosition >= MAX_UPGRADE_QUEUE
            endloop
        endmethod

		/**
		 * Sets the train unit to sell an tower.
		 * @param integer unitId
		 */
		public method setSellTowerTrain takes integer unitId returns nothing
			set .sellTowerTrain = unitId
		endmethod

		/**
		 * sell an tower by given key
		 * @param integer towerKey
		 */
        public method sellTowerByBuildUnit takes integer towerKey returns nothing
            local integer key = 0
            local integer currentTowerCount = .towerCount
            if (towerKey < .towerCount and .sellTowerTrain != 0) then
                call IssueImmediateOrderById(.tower[towerKey], .sellTowerTrain)
                set .towerCount = 0
            	loop
                    exitwhen key == currentTowerCount
            		if (key != towerKey) then
                        call .addTower(.tower[key])
                    endif
                    set key = key + 1
            	endloop
            endif
        endmethod

        /**
         * set the tower size
         * @param real height
         * @param real width
         */
        public method setTowerSize takes real height, real width returns nothing
            set .towerSize[TOWER_SIZE_WIDTH] = width / 3
            set .towerSize[TOWER_SIZE_HEIGHT] = height / 3
        endmethod

        /**
         * is the builder enabled as cpu
         */
        public method isEnabled takes nothing returns boolean
            return .enabled
        endmethod

        /**
         * add rectangle to build tower
         * @param rect rectangle
         */
        public method addRectangle takes rect rectangle returns nothing
            if (.MAX_REGIONS > .countRegion) then
                set .positionLeft[.countRegion] = GetRectMinX(rectangle)
                set .positionRight[.countRegion] = GetRectMaxX(rectangle)

                set .positionTop[.countRegion] = GetRectMaxY(rectangle)
                set .positionBottom[.countRegion] = GetRectMinY(rectangle)
                set .countRegion = .countRegion + 1
            endif
        endmethod

        /**
         * resets the rectangles coords
         */
        public method resetRectangles takes nothing returns nothing
            local integer currentRegion = 0
            loop
                exitwhen currentRegion >= .countRegion

                set .positionLeft[currentRegion] = 0
                set .positionRight[currentRegion] = 0

                set .positionTop[currentRegion] = 0
                set .positionBottom[currentRegion] = 0

                set currentRegion = currentRegion + 1
            endloop
        endmethod

        /**
         * sets that the builder builds from left to right and top to bottom or other
         * @param boolean leftToRight
         * @param boolean topToBottom
         */
        public method setBuildFromTo takes boolean leftToRight, boolean topToBottom returns nothing
            set .leftToRight = leftToRight
            set .topToBottom = topToBottom
        endmethod

        /**
         * sets the config
         * @param TowerBuildConfig towerConfig
         */
        public method setConfig takes TowerBuildConfig towerConfig returns nothing
            set .config = towerConfig
        endmethod

        /**
         * Upgrade first towers from the queue.
         * @return boolean
         */
        public method upgradeFirstFromQueue takes nothing returns boolean
            local boolean result = false
            if (.upgradeQueue[0].isActive()) then
                set result = .upgradeTower(0)
            endif
            return result
        endmethod

        /**
         * Upgrade all towers from the queue.
         * @return boolean
         */
        public method upgradeAllFromQueue takes nothing returns nothing
            local integer position = 0
            loop
                if (.upgradeQueue[position].isActive()) then
                    call .upgradeTower(position)
                endif
                set position = position + 1
                exitwhen position >= MAX_UPGRADE_QUEUE
            endloop
        endmethod

        /**
         * Upgrade one tower.
         * @param integer towerUnitId
         * @returns boolean
         */
        private method upgradeTower takes integer upgradeTowerKey returns boolean
            local integer buildTowerId = .upgradeQueue[upgradeTowerKey].getTowerId()
            local integer towerBuildKey = -1
            local boolean result = false
            local integer lastTowerBuildKey = -1
            local TowerUpgrade moveUpgradeTower
            local integer upgradeQueueKey = upgradeTowerKey
            local integer towerKey = .upgradeQueue[upgradeTowerKey].getKey()

            set towerBuildKey = .towers.getTowerKeyByUnitId(GetUnitTypeId(.tower[towerKey]))

            set result = IssueImmediateOrderById(.tower[towerKey], .towers.getColumnValue(towerBuildKey, .towers.columnChildTower))

            if (result) then
                set lastTowerBuildKey = .towers.getTowerKeyByUnitId(.towers.getColumnValue(towerBuildKey, .towers.columnChildTower))
                set .lumberCost = .lumberCost - .towers.getColumnValue(lastTowerBuildKey, .towers.columnWoodCost)
                if (.lumberCost < 0) then
                    set .lumberCost = 0
                endif
            endif
            if (result and .towers.getColumnValue(towerBuildKey, .towers.columnChildTower) == buildTowerId) then
                set moveUpgradeTower = .upgradeQueue[upgradeTowerKey]
                call moveUpgradeTower.reset()
                loop
                    exitwhen upgradeQueueKey < MAX_UPGRADE_QUEUE - 1
                    set .upgradeQueue[upgradeQueueKey] = .upgradeQueue[upgradeQueueKey + 1]
                    set upgradeQueueKey = upgradeQueueKey + 1
                endloop
                set .upgradeQueue[upgradeQueueKey] = moveUpgradeTower
            endif
            if .countUpgradeQueue() == 0 then
                set .lumberCost = 0
            endif
            return result
        endmethod

        /**
         * add an tower type id to upgrade queue
         * @param integer towerUnitId
         */
        private method addToUpgradeQueue takes integer towerUnitId returns nothing
            local integer currentPosition = 0
            loop
                exitwhen (.upgradeQueue[currentPosition].getTowerId() == 0 or currentPosition >= MAX_UPGRADE_QUEUE)
                set currentPosition = currentPosition + 1
            endloop
            if currentPosition < MAX_UPGRADE_QUEUE then
                call .upgradeQueue[currentPosition].setTowerId(towerUnitId)
            endif
        endmethod

        /**
         * build next unit
         * @param integer unitId
         * @return boolean
         */
        public method build takes integer unitId returns boolean
            local real positionY = 0
            local real positionX = 0
            local integer currentRegion = .chosenRegion
            local real width = .towerSize[TOWER_SIZE_WIDTH]
            local real height = .towerSize[TOWER_SIZE_HEIGHT]
            local boolean builded = false
            local boolean buildX = false
            local real regionWidth = 0
            local real regionHeight = 0
            if .topToBottom == true then
                set height = height * -1
            endif
            if (not .leftToRight) then
                set width = width * -1
            endif

            loop
                exitwhen currentRegion >= .countRegion
                if .topToBottom then
                    set positionY = .positionTop[currentRegion] + (height / 2)
                else
                    set positionY = .positionBottom[currentRegion] + (height / 2)
                endif
                if .leftToRight then
                    set positionX = .positionLeft[currentRegion] + (width / 2)
                else
                    set positionX = .positionRight[currentRegion] + (width / 2)
                endif
                set regionWidth = .positionRight[currentRegion] - .positionLeft[currentRegion]
                if (regionWidth < 0) then
                    set regionWidth = regionWidth * -1
                endif
                set regionHeight = .positionTop[currentRegion] - .positionBottom[currentRegion]
                if (regionHeight < 0) then
                    set regionHeight = regionHeight * -1
                endif
                set buildX = regionHeight < regionWidth

                loop
                    if buildX then
                        set positionX = positionX + width
                    else
                        set positionY = positionY + height
                    endif
                    set builded = IssueBuildOrderById(.builder, unitId, positionX, positionY)

                    exitwhen builded or positionX < .positionLeft[currentRegion] or positionX > .positionRight[currentRegion]
                    exitwhen positionY > .positionTop[currentRegion] or positionY < .positionBottom[currentRegion]
                endloop
                exitwhen builded
                if (currentRegion == .chosenRegion) then
                    set currentRegion = 0
                else
                    set currentRegion = currentRegion + 1
                endif

                // if the current region equal to .chosenRegion then must plus 1 or the loop can not end.
                if (currentRegion == .chosenRegion) then
                    set currentRegion = currentRegion + 1
                endif
            endloop
            return builded
        endmethod

        /**
         * build next tower
         */
        public method buildNext takes nothing returns nothing
            local boolean builded = false
            local integer lumber = 0
            local integer towerUpgradeLumber = 0
            local integer playerLumber = GetPlayerState(Player(.playerId), PLAYER_STATE_RESOURCE_LUMBER)
            local integer towerLumber = 400
            local integer towerUnitId = 0
            local integer parentTowerKey = 0
            local integer towerKey = 0
            local integer upgradeQueueCount = .countUpgradeQueue()
            
            local integer playerId = GetPlayerId(GetOwningPlayer(.builder))
            
            if (upgradeQueueCount == 0) then
                set .lumberCost = 0
            endif
            if (.isEnabled() and not .builded) then
                if (.canBuild and playerLumber > .lumberCost and upgradeQueueCount < MAX_UPGRADE_QUEUE) then
                    set towerUnitId = .config.getRandomBuilding()
                    set towerKey = .towers.getTowerKeyByUnitId(towerUnitId)
                    loop
                        set parentTowerKey = .towers.getParentTowerKey(towerKey)
                        set lumber = .towers.getColumnValue(towerKey, .towers.columnWoodCost)
                        exitwhen parentTowerKey < 0
                        set towerUpgradeLumber = towerUpgradeLumber + lumber
                        set towerKey = parentTowerKey
                    endloop
                    if (playerLumber >= lumber + .lumberCost and not .builded) then
                    	set builded = .build(.towers.getColumnValue(towerKey, .towers.columnUnitId))
                        if (builded and not .builded) then
                            set .builded = builded
                            set .lumberCost = .lumberCost + towerUpgradeLumber
		                    if (towerUpgradeLumber > 0) then
		                        call .addToUpgradeQueue(towerUnitId)
		                    endif
                        endif
                    endif
                endif
                set .canBuild = .builded
            endif
            if (upgradeQueueCount > 0) then
	            if (.lumberCost == 0)  then
	                set upgradeQueueCount = 0
	                loop
	                	set .upgradeQueue[upgradeQueueCount] = 0
	                	set upgradeQueueCount = upgradeQueueCount + 1
	                	exitwhen upgradeQueueCount == MAX_UPGRADE_QUEUE
	                endloop
                else
	                call .upgradeFirstFromQueue()
	            endif
            endif
        endmethod

        /**
         * look how many upgrades are in the queue
         * @return integer
         */
        public method countUpgradeQueue takes nothing returns integer
            local integer currentPosition = 0
            local integer queueCount = 0
            loop
                exitwhen currentPosition >= MAX_UPGRADE_QUEUE
                if (.upgradeQueue[currentPosition].getTowerId() != 0) then
                    set queueCount = queueCount + 1
                endif
                set currentPosition = currentPosition + 1
            endloop
            return queueCount
        endmethod
    endstruct


    /**
     * the tower events
     */
    struct TowerEvent
        /**
         * the player id
         * @var integer
         */
        public integer playerId
        /**
         * the event type id
         * @var integer
         */
        public integer eventTypeId
        /**
         * is event initialized
         * @var boolean
         */
        public boolean initialized

        /**
         * initialize event
         * @param integer playerId
         * @param integer eventTypeId
         */
        public method startEvent takes integer playerId, integer eventTypeId returns nothing
            set .playerId = playerId
            set .eventTypeId = eventTypeId
            set .initialized = true
        endmethod
    endstruct

    /**
     * Tower AI Listener to add events
     */
    struct TowerAIEventListener
        /**
         * the events for the tower builder ai
         * @var TowerEvent[]|array
         */
        private static TowerEvent array towerEvents[TOWER_AI_MAX_EVENTS]
        /**
         * the tower builder
         * @var TowerBuildAI[]|array
         */
        private static TowerBuildAI array towerBuilder[TOWER_AI_MAX_PLAYER]

        /**
         * is initialized
         * @var boolean initialized
         */
        private static boolean initialized = false

        /**
         * the events count
         * @var integer
         */
        private static integer eventsCount = 0
        
        /**
         * the event listener is active.
         * @var boolean
         */
        private static boolean isActive = false

        /**
         * sets an tower build ai by an given player id
         * @param integer playerId
         * @param TowerBuildAI towerBuild
         */
        public static method setTowerBuildAI takes integer playerId, TowerBuildAI towerBuild returns nothing
            if (playerId < TOWER_AI_MAX_PLAYER) then
                set thistype.towerBuilder[playerId] = towerBuild
                set thistype.towerBuilder[playerId].playerId = playerId
                call thistype.towerBuilder[playerId].initialize()
            endif
        endmethod

        /**
         * gets the builder-ai by player id
         * @param integer playerId
         * @return TowerBuildAI
         */
        public static method getTowerBuildAI takes integer playerId returns TowerBuildAI
            return thistype.towerBuilder[playerId]
        endmethod

        /**
         * initialize the event listener
         */
        public static method initialize takes nothing returns nothing
            local integer counter = 0
            if (not thistype.initialized) then
                set thistype.initialized = true
                loop
                    set .towerEvents[counter] = TowerEvent.create()
                    set counter = counter + 1
                    exitwhen counter >= TOWER_AI_MAX_EVENTS
                endloop
            endif
        endmethod

        /**
         * build or upgrade tower after sleep
         */
        private static method doAfterSleep takes nothing returns nothing
            local integer counter = 0
            local integer playerId = 0
            local integer eventId = 0
            local timer tAI = null
            local boolean triggerAgain = false
            set thistype.isActive = false
            loop
                exitwhen counter >= TOWER_AI_MAX_EVENTS
                if (thistype.towerEvents[counter].initialized == true) then
	                //set playerId = thistype.towerEvents[counter].playerId
	                set playerId = 0
					set eventId = thistype.towerEvents[counter].eventTypeId
	                set thistype.towerEvents[counter].initialized = false
	                if (eventId == TOWER_AI_EVENT_UPGRADE) then
						loop
		                    call thistype.towerBuilder[playerId].upgradeFirstFromQueue()
		                    set playerId = playerId + 1
		                    exitwhen playerId >= TOWER_AI_MAX_PLAYER
	                    endloop
	                elseif (eventId == TOWER_AI_EVENT_BUILD and not thistype.towerBuilder[playerId].getBuilded()) then
						loop
	                    	call thistype.towerBuilder[playerId].buildNext()
		                    set playerId = playerId + 1
		                    exitwhen playerId >= TOWER_AI_MAX_PLAYER
	                    endloop
	                endif
					set triggerAgain = true
                endif
                set counter = counter + 1
            endloop
        	if (triggerAgain) then
                set thistype.isActive = true
                set tAI = CreateTimer()
                call TimerStart(tAI, 9.0, false, function thistype.doAfterSleep)
    			set tAI = null
			else
                set playerId = 0
                loop
					if (thistype.towerBuilder[playerId].isEnabled()) then
                    	call thistype.towerBuilder[playerId].upgradeAllFromQueue()
	                    call thistype.towerBuilder[playerId].buildNext()
                    endif
                    set playerId = playerId + 1
                    exitwhen playerId >= TOWER_AI_MAX_PLAYER
                endloop
        	endif
        endmethod

        /**
         * that the builders can build after start
         * @param unit triggerUnit
         * @param integer eventType
         */
        public static method addBuildEvent takes unit triggerUnit returns nothing
        	call thistype.towerBuilder[GetPlayerId(GetOwningPlayer(triggerUnit))].setBuilded(false)
            call thistype.addEvent(triggerUnit, TOWER_AI_EVENT_BUILD)
        endmethod

        /**
         * that the builders can build after start
         * @param unit triggerUnit
         * @param integer eventType
         */
        public static method addUpgradeEvent takes unit triggerUnit returns nothing
            call thistype.addEvent(triggerUnit, TOWER_AI_EVENT_UPGRADE)
        endmethod

        /**
         * that the builders can build after start
         * @param unit triggerUnit
         * @param integer eventType
         */
        private static method addEvent takes unit triggerUnit, integer eventType returns nothing
            local timer tAI = CreateTimer()
            local integer counter = thistype.eventsCount
            call thistype.initialize()
            set thistype.eventsCount = thistype.eventsCount + 1
            if (thistype.eventsCount >= TOWER_AI_MAX_EVENTS) then
                set thistype.eventsCount = 0
            endif
            if (counter < TOWER_AI_MAX_EVENTS) then
                call thistype.towerEvents[counter].startEvent(GetPlayerId(GetOwningPlayer(triggerUnit)), eventType)
	            if (not thistype.isActive) then
					set thistype.isActive = true
	                call TimerStart(tAI, 3.0, false, function thistype.doAfterSleep)
	            endif
            endif
            set tAI = null
        endmethod
    endstruct
endscope