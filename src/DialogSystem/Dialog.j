scope Dialog
	
	struct ShowTutorialsDialog
		private static boolean array show[12]
		private static integer count = 0
		
		static method ForPlayer takes integer pid returns boolean
			return show[pid]
		endmethod
		
		private static method onDialogEnd takes nothing returns nothing
			local Dialog d = Dialog.Get()
			local integer pid = GetPlayerId(GetTriggerPlayer())
			local integer clickedButton = d.GetResult()
			
			if (clickedButton == 89) then //yes
				set show[pid] = true
			else
				set show[pid] = false
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
			
			call d.SetMessage("Do you need any help?")
			
			call d.AddButton("Yes",  HK_Y)
			call d.AddButton("No", HK_N)
			
			call d.AddAction( function thistype.onDialogEnd )
			
			call d.ShowAll()
			
		endmethod
	
	endstruct

endscope