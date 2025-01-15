//==========================================================================================
//  HeroAIEventResponse
//      by watermelon_1234
//==========================================================================================
// An optional add-on to HeroAI, intended to allow outside event responses to interact with
// the AI. The library allows the AI to act immediately after casting a spell or picking up
// an item and allowing custom AI to define a method that fires whenever the hero gets attacked
//
// NOTE: It is unadvised to use this library unless you're comfortable with writing vJass code. 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Installing:
//  1. Copy this trigger into your map.
//  2. Configure the constants to determine which event responses will be used
//==========================================================================================

library HeroAIEventResponse

	globals
		private constant boolean ACT_AFTER_ACTION 	= true
		// If set to true, causes the default AI to do looping actions  
		// immediately after finishing spell casts or picking up items.
														 
		private constant boolean USE_ON_ATTACKED 	= false 
		// If set to true, allows custom AI structs to define an onAttacked method
		// that fires whenever the hero gets attacked.
		// 
		// The onAttacked method should be defined as the following:
		// * method onAttacked takes unit attacker returns nothing *
		//	attacker refers to the unit that attacked the hero
		
		private constant boolean USE_ON_ACQUIRE		= false
		// If set to true, allows custom AI structs to define an onAcquire method that
		// fires whenever the hero acquires a target.
		//
		// The onAcquire method should be defined as the following:
		// * method onAcquire takes unit target returns nothing *
		// target refers to the unit that the hero targetted
	endglobals
    
//==========================================================================================
//                              END OF CONFIGURATION
//==========================================================================================

	module HeroAIEventResponse
    
        static if ACT_AFTER_ACTION then
        
        private static method actAfterwards takes nothing returns nothing
            local thistype this = thistype.getAIIndexFromHero(GetTriggerUnit())
            call .update()
            static if thistype.loopActions.exists then
                call .loopActions()
            else
                call .defaultLoopActions()
            endif
        endmethod
        
        endif
        
        static if USE_ON_ATTACKED and thistype.onAttacked.exists then
        
        private static method fireAttackedEvent takes nothing returns nothing
        	local thistype this = thistype.getAIIndexFromHero(GetTriggerUnit())
        	call .onAttacked(GetAttacker())
        endmethod
        
        endif
        
        static if USE_ON_ACQUIRE and thistype.onAcquire.exists then
        
        private static method fireAcquireEvent takes nothing returns nothing
        	local thistype this = thistype.getAIIndexFromHero(GetTriggerUnit())
        	call .onAcquire(GetEventTargetUnit())
        endmethod
        
        endif
        
        // Registers event responses only when the AI is used for a hero. 
        // In an ideal world, this would be private, but it needs to be 
        // called by the create method in the HeroAIStruct module. So please
        // don't call this method because it's unnecessary for you to do so.
		method registerEventResponses takes nothing returns nothing
            local trigger trig
            
            static if ACT_AFTER_ACTION then
            
            set trig = CreateTrigger()
            call TriggerRegisterUnitEvent(trig, .hero, EVENT_UNIT_SPELL_ENDCAST)
            call TriggerRegisterUnitEvent(trig, .hero, EVENT_UNIT_PICKUP_ITEM)
            call TriggerAddAction(trig, function thistype.actAfterwards)
            
            endif
            
            static if USE_ON_ATTACKED and thistype.onAttacked.exists then
            
            set trig = CreateTrigger()
            call TriggerRegisterUnitEvent(trig, .hero, EVENT_UNIT_ATTACKED)
            call TriggerAddAction(trig, function thistype.fireAttackedEvent)
            
            endif
            
            static if USE_ON_ACQUIRE and thistype.onAcquire.exists then
            
            set trig = CreateTrigger()
            call TriggerRegisterUnitEvent(trig, .hero, EVENT_UNIT_ACQUIRED_TARGET)
            call TriggerAddAction(trig, function thistype.fireAcquireEvent)
            
            endif
            
            set trig = null
            
		endmethod
        
	endmodule
	
endlibrary