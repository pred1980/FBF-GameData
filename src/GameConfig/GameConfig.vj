scope GameConfig
	
	// PUBLIC GLOBALS
	globals
		constant boolean IS_DEBUG_MODE = false
	endglobals
	
	private module Init
        
        static method onInit takes nothing returns nothing
			/*
			 * Module, die vor dem eigentlichen GameStart geladen werden müssen 
			 */
			call GetHost()
			call GoldIncome.initialize()
			
			//GAME START
			call GameStart.initialize()
        endmethod
    endmodule
    
    private struct GameConfig
        implement Init
    endstruct

endscope