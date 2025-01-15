scope HeroWarning initializer Init

	globals
		private constant integer MAX_RECTS = 6
		private constant rect array WARNING_RECTS
		
		//Stun Effect for Pause Target
		private constant string STUN_EFFECT = ""
		private constant string STUN_ATT_POINT = ""
		private constant real STUN_DURATION = 5.0
	endglobals
	
	private function onEnterActions takes nothing returns nothing
		local unit u = GetTriggerUnit()
		local player p = GetOwningPlayer(u)
		
		//Pause Unit / Used Stun System
		call Stun_UnitEx(u, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
		call IssueImmediateOrder(u, "holdposition")
		//Show Warning Message
		call Usability.getTextMessage(1, 0, true, p, true, 0)
	
		set u = null
	endfunction

	private function onEnterConditions takes nothing returns boolean
		local unit u = GetTriggerUnit()
		local boolean b = false
		
		if (IsUnitType(u, UNIT_TYPE_HERO) and /*
		*/	GetUnitRace(u) != RACE_UNDEAD) then
			set b = true
		endif
		
		set u = null
		return b
	endfunction
	
	private function Init takes nothing returns nothing
		local trigger t = CreateTrigger()
		local integer i = 0
	
		set WARNING_RECTS[0] = gg_rct_HeroWarning1
		set WARNING_RECTS[1] = gg_rct_HeroWarning2
		set WARNING_RECTS[2] = gg_rct_HeroWarning3
		set WARNING_RECTS[3] = gg_rct_HeroWarning4
		set WARNING_RECTS[4] = gg_rct_HeroWarning5
		set WARNING_RECTS[5] = gg_rct_HeroWarning6
		
		loop
			exitwhen i == MAX_RECTS
			call TriggerRegisterEnterRectSimple( t, WARNING_RECTS[i] )
			call TriggerAddCondition(t, Condition(function onEnterConditions))
			call TriggerAddAction( t, function onEnterActions )
			
			set i = i + 1
		endloop
		
	endfunction

endscope