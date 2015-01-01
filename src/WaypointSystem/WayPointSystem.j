library WayPointSystem uses AnaMoveSys, UnitMaxState

    globals
        //AoS constants
        private constant integer AOS_POINTS_PER_WAY = 14
        private WayPoint array WAY_POINTS_AOS
    
        // TD constants
        private constant integer MAX_LANES= 6
        private constant integer LANES_PER_BASE= 2
        private Way array WAYPOINTS[MAX_LANES]
        private Way array ORCS[LANES_PER_BASE]
        private Way array HUMANS[LANES_PER_BASE]
		private Way array NIGHTELVES[LANES_PER_BASE]
		private constant integer TD_POINTS_PER_WAY = 3
		private WayPoint array WAY_POINTS_TD[6][17] //zweiter array wert ==> TD_POINTS_PER_WAY+AOS_POINTS_PER_WAY
        
        private group g = CreateGroup()
    endglobals
	
	struct WayPointSystem
    
        static real endPointTD_X = 0.
        static real endPointTD_Y = 0.
        
        static method onForsakenHeartAction takes nothing returns nothing
            local unit u
            local real x = 0.00
            local real y = 0.00
            
            call GroupEnumUnitsInRect(g, gg_rct_ForsakenArea, null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
				if GetOwningPlayer(u) == Player(bj_PLAYER_NEUTRAL_VICTIM) and not /*
                */ IsUnitDead(u) and /*
                */ OrderId2String(GetUnitCurrentOrder(u)) != "attack" then 
                    //Is das Herz gerade unverwundbar? Wenn ja, dann laufe zu einem zufaelligen Punkt dort
                    if GetUnitAbilityLevel(FinalMode.getHeart(), 'Avul' ) > 0 then
						set x = GetRandomReal(GetRectMinX(gg_rct_ForsakenArea), GetRectMaxX(gg_rct_ForsakenArea))
                        set y = GetRandomReal(GetRectMinY(gg_rct_ForsakenArea), GetRectMaxY(gg_rct_ForsakenArea))
                        call IssuePointOrder(u, "attack", x, y)
                    else
						//andern falls greife das Herz an
                        call IssueTargetOrder(u, "attack", FinalMode.getHeart())
                    endif
                endif
				call GroupRemoveUnit(g,u)
            endloop
            
            set u = null
        endmethod
        
        static method onSplitWayAction takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local integer rnd = GetRandomInt(0,1)
            
            if rnd == 0 then
                call IssuePointOrder(u, "attack", GetRectCenterX(gg_rct_SplitWay0), GetRectCenterY(gg_rct_SplitWay0))
            else
                call IssuePointOrder(u, "attack", GetRectCenterX(gg_rct_SplitWay1), GetRectCenterY(gg_rct_SplitWay1))
            endif
            
            set u = null
        endmethod
        
        static method onSplitWayCondition takes nothing returns boolean
            return GetOwningPlayer(GetTriggerUnit()) == Player(bj_PLAYER_NEUTRAL_VICTIM)
        endmethod
        
        static method onEnterAction takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local player p = GetOwningPlayer(u)
            local integer pid = GetPlayerId(p)
            local integer abiId = 0
            local integer mana = 0
            
            call SetUnitPathing(u, true)
            call SetUnitPosition(u, GetUnitX(u), GetUnitY(u))
            //set new HP for the AoS Part
            call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, I2R(SharedObjects.getUnitMaxLife(SharedObjects.getUnitIndex(u), true)))
            //creep unit has an ability?
            set abiId = SharedObjects.getUnitAbility(SharedObjects.getUnitIndex(u)) 
            if abiId != -1 then
                //Creep F?higkeit f?r AoS Teil aktivieren indem man ihr die Abi. wieder gibt
                call UnitAddAbility(u, abiId)
                call SetUnitAbilityLevel(u, abiId, 1)
            endif
            set mana = SharedObjects.getUnitMaxMana(SharedObjects.getUnitIndex(u)) 
            if mana > 0 then
                call SetUnitMaxState(u, UNIT_STATE_MAX_MANA, I2R(mana))
                call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA) * RMaxBJ(0,100.) * 0.01)
            endif

            set u = null
        endmethod
        
        static method onEnterCondition takes nothing returns boolean
            return GetOwningPlayer(GetTriggerUnit()) == Player(bj_PLAYER_NEUTRAL_VICTIM)
        endmethod
        
        private static method onInit takes nothing returns nothing
			local integer i = 0
			local integer j = 0
            local trigger onEnter
            local trigger onSplitWay
            local timer t
            
            //TD Ways from the Orc Base
			set ORCS[0] = Way.create() 
			set ORCS[1] = Way.create()
			
			//TD Ways from the Human Base
			set HUMANS[0] = Way.create()
			set HUMANS[1] = Way.create()
			
			//TD Ways from the Nightelf Base
			set NIGHTELVES[0] = Way.create()
			set NIGHTELVES[1] = Way.create()
			
			set WAYPOINTS[0] = ORCS[0]
			set WAYPOINTS[1] = ORCS[1]
			set WAYPOINTS[2] = HUMANS[0]
			set WAYPOINTS[3] = HUMANS[1]
			set WAYPOINTS[4] = NIGHTELVES[0]
			set WAYPOINTS[5] = NIGHTELVES[1]
			/*
			 * The WayPoints of the Lanes
			 * TOWER DEFENSE PART
			 */
             
            //save final point of the TD Part
            set .endPointTD_X = -18.2
            set .endPointTD_Y = 454.4
            
			// Orc Base / Top lane
			set WAY_POINTS_TD[0][0] = WayPoint.create(GetStartLocationX(8), GetStartLocationY(8), -6821.4, -1771.1, 192.)
			set WAY_POINTS_TD[0][1] = WayPoint.create(-6821.4, -1771.1, 3.6, -1811.0, 192.)
			set WAY_POINTS_TD[0][2] = WayPoint.create(3.6, -1811.0, .endPointTD_X, .endPointTD_Y, 192.)
			
			// Orc Base / Bottom lane
			set WAY_POINTS_TD[1][0] = WayPoint.create(GetStartLocationX(9), GetStartLocationY(9), -6950.7, -4296.0, 192.)
			set WAY_POINTS_TD[1][1] = WayPoint.create(-6950.7, -4296.0, -448.1, -4413.8, 192.)
			set WAY_POINTS_TD[1][2] = WayPoint.create(-448.1, -4413.8, .endPointTD_X, .endPointTD_Y, 192.)
			
			// Human Base / Left lane
			set WAY_POINTS_TD[2][0] = WayPoint.create(GetStartLocationX(6), GetStartLocationY(6), -3069.5, -9951.2, 192.)
			set WAY_POINTS_TD[2][1] = WayPoint.create(-3069.5, -9951.2, -3065.6, -6997.1, 192.)
			set WAY_POINTS_TD[2][2] = WayPoint.create(-3065.6, -6997.1, .endPointTD_X, .endPointTD_Y, 192.)
			
			// Human Base / Right lane
			set WAY_POINTS_TD[3][0] = WayPoint.create(GetStartLocationX(7), GetStartLocationX(7), 2899.0, -10075.5, 192.)
			set WAY_POINTS_TD[3][1] = WayPoint.create(2899.0, -10075.5, 2921.4, -6955.2, 192.)
			set WAY_POINTS_TD[3][2] = WayPoint.create(2921.4, -6955.2, .endPointTD_X, .endPointTD_Y, 192.)
			
			// Nightelf Base / Top lane
			set WAY_POINTS_TD[4][0] = WayPoint.create(GetStartLocationX(10), GetStartLocationY(10), 6161.9, -1767.4, 192.)
			set WAY_POINTS_TD[4][1] = WayPoint.create(6161.9, -1767.4, 341.3, -1857.3, 192.)
			set WAY_POINTS_TD[4][2] = WayPoint.create(341.3, -1857.3, .endPointTD_X, .endPointTD_Y, 192.)
			
			// Nightelf Base / Bottom lane
			set WAY_POINTS_TD[5][0] = WayPoint.create(GetStartLocationX(11), GetStartLocationX(11), 6227.8, -4406.6, 192.)
			set WAY_POINTS_TD[5][1] = WayPoint.create(6227.8, -4406.6, 645.5, -4331.9, 192.)
			set WAY_POINTS_TD[5][2] = WayPoint.create(645.5, -4331.9, .endPointTD_X, .endPointTD_Y, 192.)
			
            /************************************
             * Way + Way Points of the AoS Part *
             ************************************/
            set WAY_POINTS_AOS[0] = WayPoint.create(.endPointTD_X, .endPointTD_Y, -1459.7, 1016.0, 192.)
            set WAY_POINTS_AOS[1] = WayPoint.create(-1459.7, 1016.0, -2761.6, 1014.7, 192.)
            set WAY_POINTS_AOS[2] = WayPoint.create(-2761.6, 1014.7, -4074.0, 1019.6, 192.)
            set WAY_POINTS_AOS[3] = WayPoint.create(-4074.0, 1019.6, -5603.6, 1238.4, 192.)
            set WAY_POINTS_AOS[4] = WayPoint.create(-5603.6, 1238.4, -7593.7, 2229.5, 192.)
            set WAY_POINTS_AOS[5] = WayPoint.create(-7593.7, 2229.5, -9391.7, 2752.0, 192.)
            set WAY_POINTS_AOS[6] = WayPoint.create(-9391.7, 2752.0, -8448.1, 4636.8, 192.)
            set WAY_POINTS_AOS[7] = WayPoint.create(-8448.1, 4636.8, -6801.6, 5021.6, 192.)
            set WAY_POINTS_AOS[8] = WayPoint.create(-6801.6, 5021.6, -5269.3, 5036.3, 192.)
            set WAY_POINTS_AOS[9] = WayPoint.create(-5269.3, 5036.3, -1762.9, 4905.2, 192.)
            set WAY_POINTS_AOS[10] = WayPoint.create(-1762.9, 4905.2, 1092.6, 4825.2, 192.)
            set WAY_POINTS_AOS[11] = WayPoint.create(1092.6, 4825.2, 3644.8, 2081.6, 192.)
            set WAY_POINTS_AOS[12] = WayPoint.create(3644.8, 2081.6, 6162.4, 2171.6, 192.)
            set WAY_POINTS_AOS[13] = WayPoint.create(6162.4, 2171.6, 7857.0, 3719.3, 192.) // Forsaken Heart!!!
            
            //add waypoints of all Bases
            loop
                exitwhen i == MAX_LANES
                loop
                    exitwhen j == TD_POINTS_PER_WAY
                    call WAYPOINTS[i].addWayPoint(WAY_POINTS_TD[i][j])
                    set j = j + 1
                endloop
                
                set j = 0
                loop
                    exitwhen j == AOS_POINTS_PER_WAY
                    call WAYPOINTS[i].addWayPoint(WAY_POINTS_AOS[j])
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
            
            //OnEnter Event f?r den Final Point der TD-Ways damit die Units dann den AoS Teil ablaufen
            set onEnter = CreateTrigger()
            call TriggerRegisterEnterRectSimple(onEnter, gg_rct_EndOfTD)
            call TriggerAddCondition(onEnter, Condition(function WayPointSystem.onEnterCondition))
            call TriggerAddAction(onEnter, function WayPointSystem.onEnterAction)
            
            //Split Way Event
            set onSplitWay = CreateTrigger()
            call TriggerRegisterEnterRectSimple(onSplitWay, gg_rct_SplitWay)
            call TriggerAddCondition(onSplitWay, Condition(function WayPointSystem.onSplitWayCondition))
            call TriggerAddAction(onSplitWay, function WayPointSystem.onSplitWayAction)
            
            //attack Forsaken Heart
            set t = NewTimer()
            call TimerStart(t, 1.0, true, function thistype.onForsakenHeartAction)
            
            //Clean Up
            set onEnter = null
            set onSplitWay = null
        endmethod
		
		// Add a unit to the way, starting at waypoint 0.
		static method addUnit takes integer index, unit u returns nothing
            call WAYPOINTS[index].addUnit(u, 0)
        endmethod
	
	endstruct

endlibrary