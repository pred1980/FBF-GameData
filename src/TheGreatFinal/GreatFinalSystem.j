library GreatFinalSystem

    module MFinalMode
		static unit heart
	endmodule
	
	interface IFinalMode
		method getHeart takes nothing returns unit
	endinterface
    
    struct FinalMode extends array
        static integer array id
        static string array name
        static string array command
		static integer current = 0
		
		static IFinalMode array mode
		
		static method initialize takes nothing returns nothing
            set .id[0] = 0
            set .name[0] = "King Marco Mithas Mode"
            set .command[0] = "-king"
			set .mode[0] = KingMod.create()
		endmethod
		
        static method getHeart takes nothing returns unit
            return .mode[.current].getHeart()
        endmethod
		
    endstruct
   
endlibrary