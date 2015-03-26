/**************************************************************
*
*   RegisterPlayerUnitEvent
*   v5.1.0.1
*   By Magtheridon96
*
*   I would like to give a special thanks to Bribe, azlier
*   and BBQ for improving this library. For modularity, it only
*   supports player unit events.
*
*   Functions passed to RegisterPlayerUnitEvent must either
*   return a boolean (false) or nothing. (Which is a Pro)
*
*   Warning:
*   --------
*
*       - Don not use TriggerSleepAction inside registered code.
*       - Don not destroy a trigger unless you really know what you are doing.
*
*   API:
*   ----
*
*       - function RegisterPlayerUnitEvent takes playerunitevent whichEvent, code whichFunction returns nothing
*           - Registers code that will execute when an event fires.
*       - function RegisterPlayerUnitEventForPlayer takes playerunitevent whichEvent, code whichFunction, player whichPlayer returns nothing
*           - Registers code that will execute when an event fires for a certain player.
*       - function GetPlayerUnitEventTrigger takes playerunitevent whichEvent returns trigger
*           - Returns the trigger corresponding to ALL functions of a playerunitevent.
*
**************************************************************/
library RegisterPlayerUnitEvent // Special Thanks to Bribe and azlier
    globals
        private trigger array ts
    endglobals
   
    function RegisterPlayerUnitEvent takes playerunitevent p, code cond, code act returns nothing
        local trigger t
		local integer i = GetHandleId(p)
        local integer k = 15
		
		if act != null then
			set t = CreateTrigger()
			loop
                call TriggerRegisterPlayerUnitEvent(t, Player(k), p, null)
                exitwhen k == 0
                set k = k - 1
            endloop
			if cond != null then
				call TriggerAddCondition(t, Filter(cond))
			endif
			call TriggerAddAction(t, act)
			set t = null
		else
			if ts[i] == null then
				set ts[i] = CreateTrigger()
				loop
					call TriggerRegisterPlayerUnitEvent(ts[i], Player(k), p, null)
					exitwhen k == 0
					set k = k - 1
				endloop
			endif
			call TriggerAddCondition(ts[i], Filter(cond))
		endif
    endfunction
	
	function RegisterPlayerUnitEventForPlayer takes playerunitevent p, code cond, code act, player pl returns nothing
        local integer i = 16 * GetHandleId(p) + GetPlayerId(pl)
		local trigger t
		
		if act != null then
			set t = CreateTrigger()
			call TriggerRegisterPlayerUnitEvent(t, pl, p, null)
            if cond != null then
				call TriggerAddCondition(t, Filter(cond))
			endif
			call TriggerAddAction(t, act)
			set t = null
		else
			if ts[i] == null then
				set ts[i] = CreateTrigger()
				call TriggerRegisterPlayerUnitEvent(ts[i], pl, p, null)
			endif
			call TriggerAddCondition(ts[i], Filter(cond))
		endif
    endfunction
   
    function GetPlayerUnitEventTrigger takes playerunitevent p returns trigger
        return ts[GetHandleId(p)]
    endfunction
endlibrary