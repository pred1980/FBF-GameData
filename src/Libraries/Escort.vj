library Escort uses GetClosestWidget, Table
/*
 *    This library is based on the "SummonedEscort" from mckill2009.
 *    http://www.hiveworkshop.com/forums/spells-569/summonedescort-v1-5-a-221902/
 *
 *    API: 
 *        static method addUnit takes unit master, unit escort returns nothing
 *            call Escort.addUnit(master, escort)       
 *
 *        static method removeUnit takes unit escort returns nothing
 *            call Escort.removeUnit(escort)
 *
 **/

    globals
        // Searches for closest ally hero if main hero is dead, 
        private constant boolean ALLY_IN_RANGE = true
        private constant real CLOSEST_ALLY = 600 
     
        // This is the offset distance from the unit to his master   
        private constant real OFFSET = 200

        // Targets/attacks closest enemy in range of master
        private constant real CLOSEST_ENEMY = 400
		
		private constant integer ATTACK = 851983
    endglobals

    struct Escort
        private unit master
        private unit escort   
        private real xUnit
        private real yUnit
        
        private static integer DATA
        private static timer t = CreateTimer()
        private static integer instance = 0
        private static integer array insAR
        private static unit TempUnit = null
        private static Table tb
        
        private static method closestEnemy takes nothing returns boolean
            local thistype this = DATA
            
			return SpellHelper.isValidEnemy(GetFilterUnit(), .master)
        endmethod
        
        private static method closestAlly takes nothing returns boolean
            local thistype this = DATA
            
			return SpellHelper.isValidAlly(GetFilterUnit(), .master)
        endmethod
        
        private method destroy takes nothing returns nothing
            set .master = null
            set .escort = null
            call .deallocate()        
        endmethod        
        
        private static method onLoop takes nothing returns nothing
            local thistype this
            local unit target
            local integer orderEscort
            local integer index = 0
            local real angle
            local real xMaster
            local real yMaster
            local real xEscort
            local real yEscort
            
			loop
                set index = index + 1
                set this = insAR[index]
                
				if (not SpellHelper.isUnitDead(.escort) and tb.has(GetHandleId(.escort))) then
                    set angle = GetRandomReal(0,6.28)
                    set orderEscort = GetUnitCurrentOrder(.escort)
                    
					if (not SpellHelper.isUnitDead(.master)) then   
                        if (orderEscort == 0) then
                            set xMaster = GetUnitX(.master) + OFFSET * Cos(angle)
                            set yMaster = GetUnitY(.master) + OFFSET * Sin(angle)
                            
							call IssuePointOrderById(.escort, ATTACK, xMaster, yMaster)
                            
							set DATA = this
                            set target = GetClosestUnitInRange(xMaster, yMaster, CLOSEST_ENEMY, Filter(function thistype.closestEnemy))
                            
							if (target != null) then
                                if (IsUnitType(target, UNIT_TYPE_SLEEPING)) then
                                    call IssueTargetOrderById(.escort, ATTACK, target)
                                else
                                    call IssuePointOrderById(.escort, ATTACK, GetUnitX(target), GetUnitY(target))
                                endif
                                set target = null
                            endif
                        endif  
                    else
                        set DATA = this
                        set xEscort = GetUnitX(.escort)
                        set yEscort = GetUnitY(.escort)
                        static if ALLY_IN_RANGE then
                            set .master = GetClosestUnitInRange(xEscort, yEscort, CLOSEST_ALLY, Filter(function thistype.closestAlly))
                        else
                            set .master = GetClosestUnit(xEscort, yEscort, Filter(function thistype.closestAlly))   
                        endif
                        
						if (.master == null and orderEscort == 0) then
                            call IssuePointOrderById(.escort, ATTACK, .xUnit + OFFSET * Cos(angle), .yUnit + OFFSET * Sin(angle))
                        endif
                    endif            
                else
                    call .destroy()
                    set insAR[index] = insAR[instance]
                    set insAR[instance] = this
                    set index = index - 1
                    set instance = instance - 1
                    
					if (instance == 0) then
                        call PauseTimer(t)
                    endif              
                endif      
                exitwhen index == instance
            endloop
        endmethod   
        
        private static method create takes unit master, unit escort returns thistype
            local thistype this = thistype.allocate()
			
			set .master = master
			set .escort = escort
			set .xUnit = GetUnitX(.escort)
			set .yUnit = GetUnitY(.escort)
			set tb[GetHandleId(.escort)] = 0
			
			if instance == 0 then
				call TimerStart(t, 1.0, true, function thistype.onLoop)
			endif
			
			set instance = instance + 1
			set insAR[instance] = this
			call RemoveGuardPosition(.escort)

            return this
        endmethod
        
        private static method onInit takes nothing returns nothing    
            set tb = Table.create()
        endmethod  
        
		// API 
        static method addUnit takes unit master, unit escort returns nothing
            call thistype.create(master, escort)
        endmethod
        
        static method removeUnit takes unit escort returns nothing
            call tb.remove(GetHandleId(escort))
        endmethod    
    endstruct
endlibrary