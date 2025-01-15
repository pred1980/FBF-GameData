scope DefenseModes

	globals
		private constant integer STANDARD_DEFENSE_MODE = 0
	endglobals
	
	struct DefenseMode extends array
        static string array name
        static string array desc
        static string array command
        static integer current = STANDARD_DEFENSE_MODE
        
        static method onInit takes nothing returns nothing
            set .name[0] = "Standard Defense Mode"
            set .desc[0] = "This is the default Mode. A mathematical system controls the defense lines."
            set .command[0] = "-sd"
            
            set .name[1] = "Another cool Defense Mode"
            set .desc[1] = "A short description text about this Defense Mode"
            set .command[1] = "-??"
        endmethod
        
        public static method getCurrentMode takes nothing returns integer
            return .current
        endmethod
    endstruct

endscope