scope GameTypes

	globals
		private constant integer STANDARD_GAME_TYPE_MODE = 0
	endglobals
	
	struct GameType extends array
        static string array name
        static string array desc
        static string array command
        static integer current = STANDARD_GAME_TYPE_MODE
        
        static method onInit takes nothing returns nothing
            set .name[0] = "Round Challenge"
            set .desc[0] = "This is the default type. 20 Waves of Alliance Soldiers try to destroy the Forsaken Heart."
            set .command[0] = "-rc"
            
            set .name[1] = "TYPE 2"
            set .desc[1] = "TYPE 2 Description"
            set .command[1] = "-t2"
        endmethod
        
        public static method getCurrentMode takes nothing returns integer
            return .current
        endmethod
    endstruct

endscope