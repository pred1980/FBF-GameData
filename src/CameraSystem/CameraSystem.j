library CameraSystem

	globals
		private constant hashtable HASH = InitHashtable()
		private constant real CAMERA_ANGLE_SPEED = 2.0
		private constant real ZOOM_ADJUST_OFFSET = 20.
		private constant real DELAY = 0.03
		private constant boolean ENABLE_LAUNCH = false //set to false to set arrow keys manually via GUI or another code
		private constant boolean ENABLE_UNIT_LOCK = false //recommended setting
		private constant boolean ENABLE_LOCK = false //enables lock Zoom and Angle
		
		private real CAMERA_ANGLE
		private real ZOOM
		private unit array DUMMYCAM
		private integer array DUMID
		private timer array CAMTIMER
	endglobals

	//===CAMERA MOVEMENTS: DO NOT TOUCH THIS
	private function CamOn takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local integer tID = GetHandleId(t)
		local player p = LoadPlayerHandle(HASH, tID, 1)
		local integer ID = GetPlayerId(p)
		
		if GetLocalPlayer() == Player(ID) and LoadBoolean(HASH, DUMID[ID], 3) then
		   
			if LoadStr(HASH, tID, 2) == "up" then
				set ZOOM = LoadReal(HASH, DUMID[ID], 1)
				call SaveReal(HASH, DUMID[ID], 1, ZOOM - ZOOM_ADJUST_OFFSET)      
				set ZOOM = LoadReal(HASH, DUMID[ID], 1)
				call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, ZOOM, 0.03)
			   
			elseif LoadStr(HASH, tID, 2) == "down" then
				set ZOOM = LoadReal(HASH, DUMID[ID], 1)
				call SaveReal(HASH, DUMID[ID], 1, ZOOM + ZOOM_ADJUST_OFFSET)      
				set ZOOM = LoadReal(HASH, DUMID[ID], 1)
				call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, ZOOM, 0.03)
		   
			elseif LoadStr(HASH, tID, 2) == "left" then
				set CAMERA_ANGLE = LoadReal(HASH, DUMID[ID], 2)
				call SaveReal(HASH, DUMID[ID], 2, CAMERA_ANGLE - CAMERA_ANGLE_SPEED)      
				set CAMERA_ANGLE = LoadReal(HASH, DUMID[ID], 2)
				call SetCameraField(CAMERA_FIELD_ROTATION, CAMERA_ANGLE, 0.03)
			   
			elseif LoadStr(HASH, tID, 2) == "right" then
				set CAMERA_ANGLE = LoadReal(HASH, DUMID[ID], 2)
				call SaveReal(HASH, DUMID[ID], 2, CAMERA_ANGLE + CAMERA_ANGLE_SPEED)      
				set CAMERA_ANGLE = LoadReal(HASH, DUMID[ID], 2)
				call SetCameraField(CAMERA_FIELD_ROTATION, CAMERA_ANGLE, 0.03)
			endif
		else
			call SaveBoolean(HASH, DUMID[ID], 4, true)
			call PauseTimer(CAMTIMER[ID])    
		endif
		set t = null
	endfunction

	function CamOff takes nothing returns boolean
		local integer i = 0
		loop
			exitwhen i > bj_MAX_PLAYERS
			if Game.isPlayerInGame(i) then
				if GetTriggerPlayer()==Player(i) then
					call SaveBoolean(HASH, DUMID[i], 3, false)
				endif
			endif
			set i = i + 1
		endloop
		return false
	endfunction

	private function LockUnit takes nothing returns boolean
		local integer i = 0
		loop
			exitwhen i > bj_MAX_PLAYERS
			if Game.isPlayerInGame(i) then
				if GetLocalPlayer()==Player(i) then
					call SetCameraTargetController(GetTriggerUnit(), 0, 0, true)
					call SaveUnitHandle(HASH, DUMID[i], 4, GetTriggerUnit())
				endif
			endif
			set i = i + 1
		endloop
		return false
	endfunction

	//============================================================
	//===CAMERA LEFT:
	function CamLEFT_Cond takes nothing returns boolean
		local integer i = GetPlayerId(GetTriggerPlayer())
		
		call SaveBoolean(HASH, DUMID[i], 3, true)
		call SaveBoolean(HASH, DUMID[i], 4, false)
		call SavePlayerHandle(HASH, GetHandleId(CAMTIMER[i]), 1, Player(i))
		call SaveStr(HASH, GetHandleId(CAMTIMER[i]), 2, "left")
		call TimerStart(CAMTIMER[i], DELAY, true, function CamOn)
		return false
	endfunction
	//============================================================
	//===CAMERA RIGHT:
	function CamRIGHT_Cond takes nothing returns boolean
		local integer i = GetPlayerId(GetTriggerPlayer())
		
		call SaveBoolean(HASH, DUMID[i], 3, true)
		call SaveBoolean(HASH, DUMID[i], 4, false)
		call SavePlayerHandle(HASH, GetHandleId(CAMTIMER[i]), 1, Player(i))
		call SaveStr(HASH, GetHandleId(CAMTIMER[i]), 2, "right")
		call TimerStart(CAMTIMER[i], DELAY, true, function CamOn)
		return false
	endfunction
	//============================================================
	//===CAMERA UP:
	function CamUP_Cond takes nothing returns boolean
		local integer i = GetPlayerId(GetTriggerPlayer())
		call SaveBoolean(HASH, DUMID[i], 3, true)
		call SaveBoolean(HASH, DUMID[i], 4, false)
		call SavePlayerHandle(HASH, GetHandleId(CAMTIMER[i]), 1, Player(i))
		call SaveStr(HASH, GetHandleId(CAMTIMER[i]), 2, "up")
		call TimerStart(CAMTIMER[i], DELAY, true, function CamOn)
		return false
	endfunction
	
	//============================================================
	//===CAMERA DOWN:
	function CamDOWN_Cond takes nothing returns boolean
		local integer i = GetPlayerId(GetTriggerPlayer())
		call SaveBoolean(HASH, DUMID[i], 3, true)
		call SaveBoolean(HASH, DUMID[i], 4, false)
		call SavePlayerHandle(HASH, GetHandleId(CAMTIMER[i]), 1, Player(i))
		call SaveStr(HASH, GetHandleId(CAMTIMER[i]), 2, "down")
		call TimerStart(CAMTIMER[i], DELAY, true, function CamOn)
		return false
	endfunction
	
	//============================================================
	private function LockDownAll takes nothing returns boolean
		local integer i = 0
		
		loop
			exitwhen i > bj_MAX_PLAYERS
			if Game.isPlayerInGame(i) then
				if GetLocalPlayer() == Player(i) and LoadBoolean(HASH, DUMID[i], 4) then
					set ZOOM = LoadReal(HASH, DUMID[i], 1)
					set CAMERA_ANGLE = LoadReal(HASH, DUMID[i], 2)
					call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, ZOOM, 0.03)
					call SetCameraField(CAMERA_FIELD_ROTATION, CAMERA_ANGLE, 0.03)        
				endif
			endif
			set i = i + 1
		endloop
		return false
	endfunction

	//============================================================
	// REGISTER ARROW EVENTS
	private function onRegisterArrowEvents takes nothing returns nothing
		local trigger t1 = CreateTrigger()//UP        
		local trigger t2 = CreateTrigger()//DOWN
		local trigger t3 = CreateTrigger()//LEFT
		local trigger t4 = CreateTrigger()//RIGHT
		local trigger t5 = CreateTrigger()//CamOff
		local integer i = 0
	   
		call TriggerAddCondition(t1, Condition(function CamUP_Cond))
		call TriggerAddCondition(t2, Condition(function CamDOWN_Cond))
		call TriggerAddCondition(t3, Condition(function CamLEFT_Cond))
		call TriggerAddCondition(t4, Condition(function CamRIGHT_Cond))
		call TriggerAddCondition(t5, Condition(function CamOff))
	   
		//==PRESSING UP/DOWN/LEFT/RIGHT/CAMERA OFF:
		loop
			exitwhen i > bj_MAX_PLAYERS
			if Game.isPlayerInGame(i) then
				call TriggerRegisterPlayerEvent(t1, Player(i), EVENT_PLAYER_ARROW_UP_DOWN)
				call TriggerRegisterPlayerEvent(t2, Player(i), EVENT_PLAYER_ARROW_DOWN_DOWN)
				call TriggerRegisterPlayerEvent(t3, Player(i), EVENT_PLAYER_ARROW_LEFT_DOWN)
				call TriggerRegisterPlayerEvent(t4, Player(i), EVENT_PLAYER_ARROW_RIGHT_DOWN)
				call TriggerRegisterPlayerEvent(t5, Player(i), EVENT_PLAYER_ARROW_LEFT_UP)
				call TriggerRegisterPlayerEvent(t5, Player(i), EVENT_PLAYER_ARROW_RIGHT_UP)
				call TriggerRegisterPlayerEvent(t5, Player(i), EVENT_PLAYER_ARROW_UP_UP)
				call TriggerRegisterPlayerEvent(t5, Player(i), EVENT_PLAYER_ARROW_DOWN_UP)
			endif
			set i = i + 1
		endloop
	   
		set t1 = null
		set t2 = null
		set t3 = null
		set t4 = null    
		set t5 = null
	endfunction
	
	//============================================================
	// ZOOM CONDITION
	private function ZoomConditions takes nothing returns boolean
		return SubString(GetEventPlayerChatString(), 0, StringLength("-zoom ")) == "-zoom "
	endfunction
	
	//============================================================
	// ZOOM ACTION
	private function ZoomActions takes nothing returns nothing
		local integer i = S2I(SubString(GetEventPlayerChatString(), 6, StringLength(GetEventPlayerChatString())))
		if GetLocalPlayer() == GetTriggerPlayer() then
			call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, i, 0 )
		endif
	endfunction
	
	//============================================================
	// REGISTER ZOOM EVENT
	private function onRegisterZoomEvent takes nothing returns nothing
		local trigger t = CreateTrigger()
		local integer i = 0
		
		loop
			exitwhen i > bj_MAX_PLAYERS
			if Game.isPlayerInGame(i) then
				call TriggerRegisterPlayerChatEvent(t, Player(i), "zoom ", false)
			endif
			set i = i + 1
		endloop
		
		call TriggerAddCondition( t, Condition( function ZoomConditions ) )
		call TriggerAddAction( t, function ZoomActions )
		
		set t = null
	endfunction
	
	struct CameraSystem
	
		static method initialize takes nothing returns nothing
			local trigger t1 = CreateTrigger()
			local trigger t2 = CreateTrigger()
			local integer i = 0
			
			loop
				exitwhen i > bj_MAX_PLAYERS
				if Game.isPlayerInGame(i) then
					set DUMMYCAM[i] = CreateUnit(Player(i), 'hpea', 0,0,0)
					set DUMID[i] = GetHandleId(DUMMYCAM[i])
					call UnitAddAbility(DUMMYCAM[i], 'Amrf')
					call UnitAddAbility(DUMMYCAM[i], 'Aloc')
					call SetUnitPathing(DUMMYCAM[i], false)
					call ShowUnit(DUMMYCAM[i], false)
					call SaveReal(HASH, DUMID[i], 1, 2000.) //Distance
					call SaveReal(HASH, DUMID[i], 2, 90.) //Angle        
					call SaveBoolean(HASH, DUMID[i], 3, false) //Checking
					call SaveBoolean(HASH, DUMID[i], 4, true) //Checking Lock
					set CAMTIMER[i] = CreateTimer()
				endif
				set i = i + 1
			endloop
		   
			//===UNIT LOCK:
			static if ENABLE_UNIT_LOCK then
				set i = 0
				loop
					exitwhen i > bj_MAX_PLAYERS
					if Game.isPlayerInGame(i) then
						call TriggerRegisterPlayerUnitEvent(t1, Player(i), EVENT_PLAYER_UNIT_SELECTED, null)
					endif
					set i = i + 1
				endloop
				call TriggerAddCondition(t1, Condition(function LockUnit))
			endif
		   
			//===LAUNCH TRIGGER:
			static if ENABLE_LAUNCH then
				call onRegisterArrowEvents()
			else
				call onRegisterZoomEvent()
			endif
		   
			//LOCK ZOOM and ANGLE:
			static if ENABLE_LOCK then
				call TriggerRegisterTimerEvent(t2, 0.03, true)
				call TriggerAddCondition(t2, Condition(function LockDownAll))        
			endif
		   
			set t1 = null
			set t2 = null
		endmethod
	
	endstruct

endlibrary