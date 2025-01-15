//==========================================================================================
//  HeroAIPriority
//      by watermelon_1234
//==========================================================================================
// An optional add-on to HeroAI. It causes the hero AI to prioritize enemy units based on 
// their life, relative life, and distance. It also allows two methods to be defined to 
// allow custom AI to perceive a more specific priority for a unit.
//
// The inclusion of this library automatically makes it available to HeroAI. 
//##########################################################################################
// Additional Members:
//	* unit priorityEnemy -> The enemy with the most priority
//
// API:
//	* method weightPriority takes unit u returns real *
//		Returns the priority the hero would view from a unit
//
//	* method setPriorityEnemy takes group g returns nothing *
//		Sets the priorityEnemy member to the unit with the most priority from the group
//
// Interface:
//  * static method addPriority takes unit u returns real *
//  	This method allows a custom AI to add priority for the unit u.
//		Return the additional priority as a real. Note that this priority will be added
// 		before being modified by any factor.
//
//  * static method modPriority takes unit u returns real *
//		This method allows a customAI to modify priority for the unit u.
//		Return the factor the unit's priority will be multiplied by.
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//==========================================================================================

library HeroAIPriority

    globals
		// Priority weight given to percent life of the perceived unit
        private constant real LIFE_PERCENT_WEIGHT = 3.25
		// A higher value causes priority perceived from lower percent life to increase
        private constant real LIFE_PERCENT_POWER = 3.5
		// Priority weight given to relative life between the viewer and the perceived unit
        private constant real RELATIVE_LIFE_WEIGHT = 1.5     
        
		// Priority weight given to distance between the viewer and perceived unit
        private constant real DIST_WEIGHT = 2.85
		// A higher value causes priority to increase more if the unit is closer		
        private constant real DIST_POWER = 3.15    
        // Multplies the overall priority if the unit is a hero
        private constant real HERO_FACTOR = 3.25    
    endglobals	
    
//==========================================================================================
//                              END OF CONFIGURATION
//==========================================================================================
    
  	// To avoid needless duplication.
	private function BaseViewedPriority takes unit hero, unit u returns real
		local real life = GetWidgetLife(u)
		local real maxLife = GetUnitState(u, UNIT_STATE_MAX_LIFE)			
		local real lifeWeight = LIFE_PERCENT_WEIGHT * Pow( (maxLife - life)/maxLife, LIFE_PERCENT_POWER ) + RELATIVE_LIFE_WEIGHT * GetWidgetLife(hero)/life
		
		// More priority is given if the unit is closer to the hero
		local real dx = GetUnitX(u) - GetUnitX(hero)
		local real dy = GetUnitY(u) - GetUnitY(hero)
		local real distWeight = DIST_WEIGHT * Pow( (HeroAI_SIGHT_RANGE - SquareRoot(dx*dx + dy*dy))  / HeroAI_SIGHT_RANGE, DIST_POWER)
		return lifeWeight + distWeight
	endfunction
	
	private function BasePriorityFactor takes unit u returns real
		local real factor = 1
		if IsUnitType(u, UNIT_TYPE_HERO) then
			set factor = factor * HERO_FACTOR
		endif
		return factor
	endfunction

    module HeroAIPriority
    
		unit priorityEnemy
        
        method weightPriority takes unit u returns real
        	static if not thistype.addPriority.exists and not thistype.modPriority.exists then
				return BaseViewedPriority(.hero, u) * BasePriorityFactor(u)
        	else
				local real priority = BaseViewedPriority(.hero, u)
				local real factor = BasePriorityFactor(u)
			
				static if thistype.addPriority.exists then
					set priority = priority + .addPriority(u)
				endif
				
				static if thistype.modPriority.exists then
					set factor = factor * .modPriority(u)
				endif
				
				return priority * factor
			endif
        endmethod
        
        method setPriorityEnemy takes group g returns nothing  
            local unit u
            local real highest = 0
            local real priority
            
            set .priorityEnemy = null
            
            // Preserves group g by using another group variable
            call GroupClear(bj_lastCreatedGroup)
            call GroupAddGroup(g, bj_lastCreatedGroup)
            loop
                set u = FirstOfGroup(bj_lastCreatedGroup)
                exitwhen u == null
                call GroupRemoveUnit(bj_lastCreatedGroup, u)

                set priority = .weightPriority(u)
				
                if priority > highest then
                	set highest = priority
                	set .priorityEnemy = u                    
                endif
            endloop
			
			set u = null
        endmethod
    endmodule
endlibrary