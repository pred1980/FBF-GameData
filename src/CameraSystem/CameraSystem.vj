library CameraSystem
	globals
		private constant integer STANDARD_ZOOM = 2400
	endglobals

	private function ZoomConditions takes nothing returns boolean
		return GetEventPlayerChatString() == "camera reset"
	endfunction
	
	private function ZoomActions takes nothing returns nothing
		if GetLocalPlayer() == GetTriggerPlayer() then
			call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, STANDARD_ZOOM, 1.0)
		endif
	endfunction
	
	struct CameraSystem
		static method initialize takes nothing returns nothing
			local trigger t = CreateTrigger()
			local integer i = 0
			
			loop
				exitwhen i > bj_MAX_PLAYERS
				if Game.isPlayerInGame(i) then
					call TriggerRegisterPlayerChatEvent(t, Player(i), "camera reset", false)
				endif
				set i = i + 1
			endloop
			
			call TriggerAddCondition( t, Condition( function ZoomConditions ) )
			call TriggerAddAction( t, function ZoomActions )
			
			set t = null
		endmethod
	endstruct
endlibrary