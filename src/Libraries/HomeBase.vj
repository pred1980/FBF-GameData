library HomeBase
	private keyword INITS
	
	globals
		private constant rect array HOMEBASE
	endglobals
	
	struct Homebase
		implement INITS
		
		static method get takes integer pid returns rect
			return HOMEBASE[pid]
		endmethod
		
		static method set takes integer pid, rect r returns nothing
			set HOMEBASE[pid] = r
		endmethod
	endstruct
	
	private module INITS
		private static method onInit takes nothing returns nothing
			set HOMEBASE[0] = gg_rct_UndeadHeroMainBase
			set HOMEBASE[1] = gg_rct_UndeadHeroMainBase
			set HOMEBASE[2] = gg_rct_UndeadHeroMainBase
			set HOMEBASE[3] = gg_rct_UndeadHeroMainBase
			set HOMEBASE[4] = gg_rct_UndeadHeroMainBase
			set HOMEBASE[5] = gg_rct_UndeadHeroMainBase
			
			set HOMEBASE[6] = gg_rct_HumanHeroMainBase
			set HOMEBASE[7] = gg_rct_HumanHeroMainBase
			
			set HOMEBASE[8] = gg_rct_OrcHeroMainBase
			set HOMEBASE[9] = gg_rct_OrcHeroMainBase
			
			set HOMEBASE[10] = gg_rct_NightelfHeroMainBase
			set HOMEBASE[11] = gg_rct_NightelfHeroMainBase
		endmethod
	endmodule
endlibrary