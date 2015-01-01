scope GameModes

	globals
		//0 = All Pick | 1 = All Random
		private constant integer STANDARD_GAME_MODE = 0 
	endglobals
	
	struct GameMode extends array
		static string array name
		static string array desc
		static string array command
		static string array repick
		static integer current = STANDARD_GAME_MODE
		
		static method onInit takes nothing returns nothing
			set .name[0] = "All Pick"
			set .desc[0] = "This is the default mode. Players may pick heroes belonging to their team."
			set .command[0] = "-ap"
			set .repick[0] = "|cff00c400enabled|r"
			
			set .name[1] = "All Random"
			set .desc[1] = "Every player gets a random hero belonging to their team.\n"
			set .command[1] = "-ar"
			set .repick[1] = "|cffff0000disabled|r"
		endmethod
		
		public static method getCurrentMode takes nothing returns integer
			return .current
		endmethod
	endstruct
	
endscope