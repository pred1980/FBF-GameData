scope Dialog
	/*
     * Changelog: 
     *     	06.05.2015: Changed question and switches Yes/no
	 *
     */
	
	struct ShowTutorialsDialog
		private static boolean array show
		private static integer count = 0
		
		static method ForPlayer takes integer pid returns boolean
			return show[pid]
		endmethod
		
		private static method onDialogEnd takes nothing returns nothing
			local Dialog d = Dialog.Get()
			local integer pid = GetPlayerId(GetTriggerPlayer())
			local integer clickedButton = d.GetResult()
			
			if (clickedButton == 89) then
				set show[pid] = false
			else
				set show[pid] = true
			endif
			
			set count = count + 1
			
			if (Game.getPlayerCount == count) then
				//INIT GAME MODULES
				call Game.assignPlayerOptions()
				call GameModule.initialize()
			endif
		endmethod
	
		static method initialize takes nothing returns nothing
			local Dialog d = Dialog.create()
			local integer i = 0
			
			loop
                exitwhen i >= bj_MAX_PLAYERS
				set show[i] = false
				set i = i + 1
			endloop
			
			call d.SetMessage("Have you played the game before?")
			
			call d.AddButton("Yes",  HK_Y)
			call d.AddButton("No", HK_N)
			
			call d.AddAction( function thistype.onDialogEnd )
			
			call d.ShowAll()
			
		endmethod
	
	endstruct

endscope