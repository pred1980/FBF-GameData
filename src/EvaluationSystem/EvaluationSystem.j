scope EvaluationSystem

    globals
		private constant integer array LUMBER
	endglobals

    struct Evaluation
        
        static method initialize takes nothing returns nothing
			set LUMBER[1] = 150 
            set LUMBER[2] = 170 
			set LUMBER[3] = 190 
			set LUMBER[4] = 210 
			set LUMBER[5] = 230 
			set LUMBER[6] = 250 
			
            set LUMBER[7] = 270 
			set LUMBER[8] = 290 
			set LUMBER[9] = 310 
			set LUMBER[10] = 330 
			set LUMBER[11] = 350 
			set LUMBER[12] = 370 
			set LUMBER[13] = 390 
			
			set LUMBER[14] = 410 
			set LUMBER[15] = 430 
			set LUMBER[16] = 450 
			set LUMBER[17] = 470 
			set LUMBER[18] = 490 
			set LUMBER[19] = 510 
			set LUMBER[20] = 530 
		endmethod
		
		static method getLumber takes integer round returns integer
			return LUMBER[round]
		endmethod
		
    endstruct
	
endscope