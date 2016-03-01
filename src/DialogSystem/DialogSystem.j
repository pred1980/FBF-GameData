//==============================================================================
//                    DIALOG SYSTEM BY COHADAR -- v3.1
//==============================================================================
//
//  PURPOUSE:
//       * Displaying dialogs the easy way
//       * Retrieving dialog results the easy way
//
//
//  HOW TO USE:
//       * Dialog is basically a struct wrapper around native dialog 
//
//       * First create a dialog,
//            # local Dialog d = Dialog.create()
//
//         than add a title,
//            # call d.SetMessage("Some Text")
//
//         than add couple of buttons
//            #	call d.AddButton("First Button",  HK_A)
//            #	call d.AddButton("Second Button", HK_B)
//            #	call d.AddButton("Third",         HK_C)
//
//         HK_X is a hotkey constant for a button,
//         there are constants for all letters + numbers 0..9
//         hotkeys are not case-sensitive
//
//         now add a callback method for your dialog
//            # call d.AddAction( function SomeFunction )
//         this is the function that will be called when a player presses a button
//
//         And finally show the dialog in one of two ways:
//            # call d.ShowAll()      // Displays dialog to all human players
//            # call d.Show( player ) // Displays dialog to specified player
//
//         Inside your callback function you can get the clicked Dialog struct like this
//         local Dialog d = Dialog.Get() 
//         and then use d.GetResult() to get the hotkey of a clicked button
//
//         You can also use GetTriggerPlayer() to find out witch player pressed the button
//
//         When you are done with Dialog you can:
//            # call d.destroy()  // destroy it completely
//            # call d.clear()    // or recycle it
//
//  PROS: 
//       * Extremelly easy to use compared to native dialogs
//       * It is fool-proof and will warn you if you try to do something stupid
//
//  DETAILS:
//       * Don't release Dialogs before you are sure user has selected something
//         I recommend to never destroy Dialogs, 
//         just create them when they are first time called and then show/hide them as needed
// 
//  THANKS:
//       * Magentix for finding the triggeraction leak and suggesting clear method
//       * Vexorian for creating Table so I don't have to mess with handles myself
//         
//  REQUIREMENTS:
//       * Table v3.0 or higher
//
//  HOW TO IMPORT:
//       * Just create a trigger named Dialog
//       * convert it to text and replace the whole trigger text with this one
//
//==============================================================================
library DialogSystem uses Table

	globals
		// Dialog button hotkey constants
		constant integer HK_ESC = 512
		
		constant integer HK_0 = 48
		constant integer HK_1 = 49
		constant integer HK_2 = 50
		constant integer HK_3 = 51
		constant integer HK_4 = 52
		constant integer HK_5 = 53
		constant integer HK_6 = 54
		constant integer HK_7 = 55
		constant integer HK_8 = 56
		constant integer HK_9 = 57
		
		constant integer HK_A = 65
		constant integer HK_B = 66
		constant integer HK_C = 67
		constant integer HK_D = 68
		constant integer HK_E = 69
		constant integer HK_F = 70
		constant integer HK_G = 71
		constant integer HK_H = 72
		constant integer HK_I = 73
		constant integer HK_J = 74
		constant integer HK_K = 75
		constant integer HK_L = 76
		constant integer HK_M = 77
		constant integer HK_N = 78
		constant integer HK_O = 79
		constant integer HK_P = 80
		constant integer HK_Q = 81
		constant integer HK_R = 82
		constant integer HK_S = 83
		constant integer HK_T = 84
		constant integer HK_U = 85
		constant integer HK_V = 86
		constant integer HK_W = 87
		constant integer HK_X = 88
		constant integer HK_Y = 89
		constant integer HK_Z = 90
	endglobals

	struct Dialog
		private trigger t = CreateTrigger()
		private triggeraction a = null
		private dialog  d = DialogCreate()
		private string messageText = ""
		private integer button_count = 0
		
		private static HandleTable dialogTable
		private static HandleTable buttonTable
		
		static method onInit takes nothing returns nothing
			set Dialog.dialogTable = HandleTable.create() // Table
			set Dialog.buttonTable = HandleTable.create() // Table
		endmethod
		
		static method create takes nothing returns Dialog
			local Dialog ret = Dialog.allocate()
			call TriggerRegisterDialogEvent( ret.t, ret.d )
			set .dialogTable[GetClickedDialog()] = ret // Table
			return ret
		endmethod
		
		method clear takes nothing returns nothing
			if .a != null then
				call TriggerRemoveAction(.t, .a)
				set .a = null
			endif
			set .messageText = ""
			set .button_count = 0
			call DialogClear(.d)
		endmethod       

		method onDestroy takes nothing returns nothing
			if .a != null then
				call TriggerRemoveAction(.t, .a)
			endif
			call DestroyTrigger(.t)
			call .dialogTable.flush(.d) // Table
			call DialogDestroy(.d)
		endmethod    
		

		static method Get takes nothing returns Dialog 
			return .dialogTable[GetClickedDialog()] // Table   
		endmethod
		
		method GetResult takes nothing returns integer
			return .buttonTable[GetClickedButton()] // Table
		endmethod
		
		method SetMessage takes string messageText returns nothing
			set .messageText = messageText
		endmethod
		
		method AddButton takes string buttonText, integer hotkey returns nothing
			set .buttonTable[DialogAddButton(.d,  buttonText, hotkey)] = hotkey
			set .button_count = .button_count + 1
		endmethod	
		
		method AddAction takes code actionFunc returns nothing
			if .a != null then
				call BJDebugMsg("|c00FF0000Dialog.AddAction: you cannot set more than one dialog action")
			else
				set .a = TriggerAddAction( .t, actionFunc )
			endif
		endmethod
		
		method Show takes player whichPlayer returns nothing
			if .a == null then
				call BJDebugMsg("|c00FF0000Dialog.Show: You forgot to set a dialog action")
			endif
			if .button_count == 0 then
				call BJDebugMsg("|c00FF0000Dialog.Show: You cannot show dialog with no buttons")
			else
				// message must be set before every display because of some bug.
				call DialogSetMessage( .d, .messageText )
				call DialogDisplay(whichPlayer, .d, true) 
			endif
		endmethod
		
		method ShowAll takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i>=12 // maximum of human players is 12
				if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
				if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
					call .Show(Player(i))			
				endif
				endif
				set i = i + 1
			endloop
		endmethod
		
		method Hide takes player whichPlayer returns nothing
			call DialogDisplay(whichPlayer, .d, false) 
		endmethod

		method HideAll takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i>=12 // maximum of human players is 12
					call .Hide(Player(i))			
				set i = i + 1
			endloop
		endmethod
		
	endstruct

endlibrary