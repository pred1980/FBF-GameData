scope EvaluationSystem

    globals
		private constant integer array LUMBER
	endglobals

    struct Evaluation
        
        static method initialize takes nothing returns nothing
			//+ 120 per Round
            set LUMBER[1] = 150 
            set LUMBER[2] = 210 //+60
			set LUMBER[3] = 280 //+70
			set LUMBER[4] = 360 //+80
			set LUMBER[5] = 430 //+70
			set LUMBER[6] = 490 //+60
			
            set LUMBER[7] = 490 //0
			set LUMBER[8] = 480 //-10
			set LUMBER[9] = 460 //-20
			set LUMBER[10] = 440 //-20
			set LUMBER[11] = 420 //-20
			set LUMBER[12] = 400 //-20
			set LUMBER[13] = 370 //-30
			
			set LUMBER[14] = 370 //0
			set LUMBER[15] = 375 //+5
			set LUMBER[16] = 385 //+10
			set LUMBER[17] = 400 //+15
			set LUMBER[18] = 420 //+20
			set LUMBER[19] = 445 //+25
			set LUMBER[20] = 475 //+30
		endmethod
		
		static method getLumber takes integer round returns integer
			return LUMBER[round]
		endmethod
		
    endstruct
	
endscope