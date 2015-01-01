library IntuitiveBuffSystem initializer Init requires Stack, TimerUtils, AutoIndex, optional AbilityPreload
//******************************************************************************
//* BY: Rising_Dusk
//*     (Intuitive) Buff System 1.05
//* 
//* This library is a simple and easy to understand implementation of custom
//* buff handling in JASS. I call it the Intuitive Buff System because anyone
//* should be able to pick it up and use it right away. It uses a callback
//* driven style where the user specifies which callbacks run either
//* periodically over a buff's duration or when the buff is removed. This covers
//* all possible types of buffs that one might want to create.
//* 
//******************************************************************************
//* 
//* In order to make a buff work, one must first create a custom aura ability in
//* the Object Editor and a custom buff for that aura. The raw ids for these
//* objects need to be supplied to the IBS via the DefineBuffType function.
//* 
//*     function DefineBuffType takes integer AbilId, integer BuffId, ...
//*     ... real period, boolean isPeriodic, boolean isPositive, callback onAdd, ...
//*     ... callback onPeriodic, callback onEnd returns integer
//* 
//* The arguments for this function are as follows:
//*     [integer]  AbilId               Owner of the buff being applied
//*     [integer]  BuffId               Target for the buff to be applied to
//*     [real]     period               Type of the buff from DefineBuffType
//*     [boolean]  isPeriodic           Whether the buff is periodic or not
//*     [boolean]  isPositive           Whether the buff is positive or not
//*     [callback] onAdd                Callback to run when a buff is added
//*     [callback] onPeriodic           Callback to run every buff iteration
//*     [callback] onEnd                Callback to run when a buff ends
//* 
//* NOTE: All callbacks must follow the below structural convention
//*     function MyCallback takes nothing returns nothing
//* 
//* The callback functions may be private, public, or whatever. When using them
//* in the DefineBuffType function call, simply put the function's name for the
//* respective argument (no function keyword). If you do not want any function
//* to be called for one of the callbacks, simply use 0 for that argument.
//* 
//* Once the bufftype is registered with the system, you are free to use it
//* whenever you want to. It returns an integer, which you should set to a
//* global integer in a scope initializer or some initialization function. To
//* apply a buff to a unit, simple call the UnitAddBuff function. All of these
//* values are effectively constant for any buff created of the given bufftype.
//* 
//* The period argument tells the system the interval for running the
//* onPeriodic callback function. The period and onPeriodic arguments only
//* matter if the isPeriodic argument is true. The onEnd argument runs when a
//* buff is removed either manually, by it expiring, or by the unit it is on
//* dying. The onAdd argument runs when a buff is either applied or refreshed.
//* Please do not destroy the dbuff struct inside your callback functions; that
//* will cause doublefrees. The system automatically cleans them up.
//* 
//* Inside the callbacks, you get one event response:
//*     function GetEventBuff takes nothing returns dbuff
//* 
//* Usage:
//*     local dbuff db = GetEventBuff()
//* 
//* Within the above struct, the following information can be retrieved (or
//* modified, but I recommend not changing most of the parameters). At any given
//* time during the buff's existence, these values can also be retrieved with a
//* call to GetUnitBuff, GetRandomBuff, or GetRandomBuffSigned on the unit.
//* 
//*     [unit]    .source               Owning unit of the buff
//*     [unit]    .target               Unit the buff is applied to
//*     [real]    .duration             Total duration for buff expiration
//*     [real]    .timeElapsed()        Total elapsed time of the buff
//*     [real]    .timeRemaining()      Remaining time before buff expiration
//*               .setDuration(NewDur)  Sets the current buff duration to NewDur
//*               .addDuration(ModDur)  Adds ModDur to the current buff duration
//*     [integer] .btype.period         Periodicity for the buff
//*     [integer] .level                Level of the buff used on the unit
//*     [integer] .data                 An integer the user can store data to
//*     [boolean] .isPeriodic           Whether the buff is periodic or not
//*     [boolean] .isExpired            Whether the buff expired naturally or not
//*                                     Can only return true in the 'OnEnd' callback
//*     [boolean] .isRemoved            Whether the buff was purged or removed by death or not
//*                                     Can only return true in the 'OnEnd' callback
//*     [boolean] .isRefreshed          Whether the buff was refreshed or not
//*                                     Can only return true in the 'OnAdd' callback
//* 
//******************************************************************************
//* 
//*     function UnitAddBuff takes unit source, unit target, integer btype, ...
//*     ... real dur, integer lvl returns dbuff
//* 
//* The arguments for this function are as follows:
//*     [unit]    source                The 'owner' of the buff being applied
//*     [unit]    target                The target for the buff to be applied to
//*     [integer] btype                 The type of the buff from DefineBuffType
//*     [real]    dur                   The total duration of the buff
//*     [integer] lvl                   The 'level' of the buff
//* 
//* Constants usable in this function call:
//*     [real]    BUFF_PERMANENT        This is the value you should use for the
//*                                     duration argument if you want a buff
//*                                     that never ends.
//* 
//* Additional options of note:
//*     set mybuff.data = SomeInteger   This allows you to attach an integer to
//*                                     a buff that you can get in the event
//*                                     callbacks.
//* 
//* The lvl argument is there for reapplication of buff purposes. A buff being
//* applied of a higher level than the old buff will always overwrite the old
//* one, it doesn't matter if duration is higher or not. This way, if you want a
//* buff to get shorter per level, the system will support that.
//* 
//******************************************************************************
//* 
//* Available system functions:
//* 
//*    > function GetUnitBuff takes unit target, integer whichType returns dbuff
//* 
//* This function allows the user to get a specific buff on a unit at any point
//* if the user knows the bufftype they want. Will return 0 if the buff does not
//* exist.
//* 
//*    > function GetRandomBuff takes unit target returns dbuff
//* 
//* This function allows the user to get a random buff on a unit at any point.
//* Getting a random buff is most useful for stealing or moving of arbitrary
//* buffs on a unit. Will return 0 if the unit has no buffs.
//* 
//*    > function GetRandomBuffSigned takes unit target, boolean isPos returns dbuff
//* 
//* This function, like GetRandomBuff, returns a random buff on a unit given a
//* 'sign'. The isPos argument lets you specify to either get a random positive
//* buff if true or a random negative buff if false. Will return 0 if the unit
//* has no buffs of the desired alignment.
//* 
//*    > function GetLastAppliedBuff takes unit target returns dbuff
//* 
//* This function returns the most recently applied buff on a unit. Will return
//* 0 if the unit has no buffs.
//* 
//*    > function GetFirstAppliedBuff takes unit target returns dbuff
//* 
//* This function returns the first buff in a user's bufflist that is still
//* active. Will return 0 if the unit has no buffs.
//* 
//*    > function UnitHasBuff takes unit target, integer whichType returns boolean
//* 
//* This function will return true if the given unit has the specified buff.
//* 
//*    > function UnitHasAnyBuff takes unit target returns boolean
//* 
//* This function will return true if the given unit has any buff managed by
//* the system.
//* 
//*    > function UnitRemoveBuff takes unit target, integer whichType returns boolean
//* 
//* This function removes a buff of a specified type from a given unit. Will
//* return false if the buff did not exist to be removed.
//* 
//*    > function UnitRemoveAllBuffs takes unit target returns nothing
//* 
//* This function removes all buffs of any type from a given unit.
//* 
//******************************************************************************
//* 
//* Finally, there is the inherent limit that you can only have 8192 buffs and
//* 8192 bufftypes at once. If you ever get this high, your map will have worse
//* problems than this system working improperly.
//* 
//* I hope you find this library as useful as I do. Thanks for reading the
//* documentation. If you have any questions for me about the IBS, how it works,
//* or if you have suggestions for it, please contact me at WC3C by private
//* message. This system is only authorized for release at Warcraft 3 Campaigns.
//* 
//* Enjoy!
//* 

	globals
		//Constant for use with infinite duration buffs
		constant real    BUFF_PERMANENT     = 0x800000
	endglobals

	private keyword TimeOut
	private keyword TempBuff
	private function interface callback takes nothing returns nothing

	globals
		private hashtable     ht    = InitHashtable() //Hashtable for all data attachment
		private integer array lists
		private boolean rflag       = false
	endglobals

	private struct bufftype
		//All readonly so the user doesn't mess with them
		integer  abilid
		integer  buffid
		real     period
		boolean  isPeriodic
		boolean  isPositive
		
		//All of the callback behavior for the bufftype
		callback onAdd
		callback onPeriodic
		callback onEnd
		static method create takes integer abilid, integer buffid, real period, boolean isPeriodic, boolean isPositive, callback onAdd, callback onPeriodic, callback onEnd returns bufftype
			local bufftype bt = bufftype.allocate()
			set bt.abilid     = abilid
			set bt.buffid     = buffid
			set bt.period     = period
			set bt.isPeriodic = isPeriodic
			set bt.onAdd      = onAdd
			set bt.onPeriodic = onPeriodic
			set bt.onEnd      = onEnd
			return bt
		endmethod
	endstruct

	private struct bufflist
		Stack sta
		unit  target
		
		static method create takes unit target returns bufflist
			local bufflist bl = bufflist.allocate()
			set bl.target     = target
			set bl.sta        = Stack.create()
			//Attach it to the unit
			set lists[GetUnitId(target)] = integer(bl)
			return bl
		endmethod
		private method onDestroy takes nothing returns nothing
			call .sta.destroy()               //Destroy the stack
			set lists[GetUnitId(.target)] = 0 //Remove array value
		endmethod
	endstruct

	struct dbuff
		unit     source
		unit     target
		real     elapsed     = 0.
		real     duration
		integer  level
		integer  data        = 0
		bufftype btype
		timer    tmr
		
		//Behavior variables inside the struct
		boolean  isPeriodic
		boolean  isExpired   = false
		boolean  isRemoved   = false
		boolean  isRefreshed = false
		
		//Handy methods that save the user math they don't want to do
		method timeElapsed takes nothing returns real
			if .btype.isPeriodic then
				return .elapsed+TimerGetElapsed(.tmr)
			else
				return TimerGetElapsed(.tmr)
			endif
		endmethod
		method timeRemaining takes nothing returns real
			if .btype.isPeriodic then
				return .duration-.elapsed-TimerGetElapsed(.tmr) 
			else
				return TimerGetRemaining(.tmr)
			endif
		endmethod
		method setDuration takes real newDur returns nothing
			local real oldDur = .duration
			if .timeElapsed() >= newDur then
				//This is equivalent to force removing the buff, so kill it
				set .isExpired   = false
				set .isRemoved   = true
				set .isRefreshed = false
				call .destroy() //Timer gets recycled in here!
			else
				if .isPeriodic then
					if .timeElapsed() + .btype.period > newDur then
						//Update timeout to cover last segment of buff duration
						call TimerStart(.tmr, newDur-.timeElapsed(), false, TimeOut)
						//Since it won't clear a full period, we don't let it run onPeriodic
						set .isPeriodic = false
					endif
				else
					//Run for however long you have to so total duration is the new duration
					call TimerStart(.tmr, newDur-.timeElapsed()  , false, TimeOut)
				endif
				set .duration = newDur
			endif
		endmethod
		method addDuration takes real modDur returns nothing
			//Just calls the setDuration method
			call .setDuration(.duration+modDur)
		endmethod
		//Some callback running methods
		method runAdd takes nothing returns nothing
			set .isExpired   = false
			set .isRemoved   = false
			set .isRefreshed = false
			call .btype.onAdd.execute()
		endmethod
		method runRefreshed takes nothing returns nothing
			set .isRefreshed = true
			set .isExpired   = false
			set .isRemoved   = false
			call .btype.onAdd.execute()
		endmethod
		method runPeriodic takes nothing returns nothing
			set .isExpired   = false
			set .isRemoved   = false
			set .isRefreshed = false
			call .btype.onPeriodic.execute()
		endmethod
		method runExpired takes nothing returns nothing
			//This destroys the dbuff
			set .isExpired   = true
			set .isRemoved   = false
			set .isRefreshed = false
			call .destroy() //Timer gets recycled in here!
		endmethod
		method runRemoved takes nothing returns nothing
			//This destroys the dbuff
			set .isExpired   = false
			set .isRemoved   = true
			set .isRefreshed = false
			call .destroy() //Timer gets recycled in here!
		endmethod
		static method create takes unit source, unit target, bufftype btype, real dur, integer lvl returns dbuff
			local dbuff   db  = dbuff.allocate()
			local integer id  = GetUnitId(target)
			set db.source     = source
			set db.target     = target
			set db.duration   = dur
			set db.btype      = btype
			set db.isPeriodic = btype.isPeriodic
			set db.level      = lvl
			set db.tmr        = NewTimer()
			//Hook the dbuff to the timer
			call SetTimerData(db.tmr, integer(db))
			//Add ability to the target of the buff
			call UnitAddAbility(target, db.btype.abilid)
			call SetUnitAbilityLevel(target, db.btype.abilid, db.level)
			call UnitMakeAbilityPermanent(target, true, db.btype.abilid)
			call SetUnitAbilityLevel(target, db.btype.buffid, db.level)
			//Load to table for future referencing
			call SaveInteger(ht, btype, id, integer(db))
			//Push the buff into the bufflist stack on the target
			call bufflist(lists[id]).sta.add(integer(db))
			return db
		endmethod
		private method onDestroy takes nothing returns nothing
			local integer id = GetUnitId(.target)
			//Clear the table value so the system knows it's done
			//Done before the onRemove call to prevent potential double frees with death trigger
			call RemoveSavedInteger(ht, .btype, id)
			
			//Remove the buff from the bufflist stack on the target
			call bufflist(lists[id]).sta.remove(integer(this))
			
			//Set up and run the onRemove callback
			set TempBuff = this
			call .btype.onEnd.execute()
			
			//Clear stuff inside the struct and on the unit
			call UnitRemoveAbility(.target, .btype.abilid)
			call UnitRemoveAbility(.target, .btype.buffid)
			call ReleaseTimer(.tmr)
		endmethod
	endstruct

	globals
		private code           TimeOut       = null //Code callback for buff timeouts
		private integer        BuffTypeCount = 0    //Counter for how many buff types exist
		private bufftype array BuffTypes            //Array for all defined buff types
		private dbuff          TempBuff      = 0    //Temp buff for callback data
	endglobals

	private function BuffTimeout takes nothing returns nothing
		local timer t  = GetExpiredTimer()
		local dbuff db = dbuff(GetTimerData(t))
		
		//Different behavior for periodic buffs than one-timers
		if db.isPeriodic then
			//Run the onPeriod callback no matter what
			set TempBuff = db
			call db.runPeriodic()
			//Check if this iteration kills the buff
			set db.elapsed = db.elapsed + db.btype.period
			if db.elapsed >= db.duration and not db.isRemoved then
				//Kill the buff completely if it hasn't been cleared elsewhere
				call db.runExpired()
			elseif db.elapsed + db.btype.period > db.duration and not db.isRemoved then
				//Update timeout to cover last segment of buff duration
				call TimerStart(db.tmr, db.duration-db.elapsed, false, function BuffTimeout)
				//Since it won't clear a full period, we don't let it run onPeriodic
				set db.isPeriodic = false
			elseif TimerGetElapsed(db.tmr) < db.btype.period then
				//Update period of timer to normal value
				call TimerStart(db.tmr, db.btype.period, true, function BuffTimeout)
			endif
		elseif not db.isRemoved then
			//Kill the buff completely, set it to expired naturally
			//Shouldn't run if it was force removed by the on-death trigger
			call db.runExpired()
		endif
		
		set t = null
	endfunction

	//******************************************************************************

	function GetEventBuff takes nothing returns dbuff
		return TempBuff
	endfunction

	//******************************************************************************

	function UnitHasBuff takes unit target, integer whichType returns boolean
		return HaveSavedInteger(ht, whichType, GetUnitId(target))
	endfunction

	function UnitHasAnyBuff takes unit target returns boolean
		return bufflist(lists[GetUnitId(target)]).sta.size > 0
	endfunction

	function UnitRemoveBuff takes unit target, integer whichType returns boolean
		local dbuff db = 0
		if HaveSavedInteger(ht, whichType, GetUnitId(target)) then
			set db = dbuff(LoadInteger(ht, whichType, GetUnitId(target)))
			//Buff exists, clear it
			call db.runRemoved()
			return true
		endif
		return false
	endfunction

	private function RemoveAllBuffsEnum takes integer value returns nothing
		call dbuff(value).runRemoved()
	endfunction
	function UnitRemoveAllBuffs takes unit target returns nothing
		call bufflist(lists[GetUnitId(target)]).sta.enum(RemoveAllBuffsEnum, true)
	endfunction

	private function RemoveAllBuffsSignedEnum takes integer value returns nothing
		if dbuff(value).btype.isPositive == rflag then
			call dbuff(value).runRemoved()
		endif
	endfunction
	function UnitRemoveAllBuffsSigned takes unit target, boolean positive returns nothing
		set rflag = positive
		call bufflist(lists[GetUnitId(target)]).sta.enum(RemoveAllBuffsSignedEnum, true)
	endfunction

	function GetUnitBuff takes unit target, integer whichType returns dbuff
		return dbuff(LoadInteger(ht, whichType, GetUnitId(target)))
	endfunction

	function GetRandomBuff takes unit target returns dbuff
		local bufflist bl = bufflist(lists[GetUnitId(target)])
		if bl.sta.size > 0 then
			return dbuff(bl.sta.random)
		endif
		return 0 //No buff to return
	endfunction

	function GetRandomBuffSigned takes unit target, boolean isPos returns dbuff
		local bufflist bl = bufflist(lists[GetUnitId(target)])
		local Stack    s1 = 0
		local Stack    s2 = 0
		local integer  v  = 0
		
		//Only do this stuff if the unit has any buffs at all
		if bl.sta.size > 0 then
			//Build the needed stacks
			set s1 = bl.sta.copy()
			set s2 = Stack.create()
			//Loop through and build a new stack of buffs of desired type
			loop
				exitwhen s1.size == 0
				set v = s1.first
				if dbuff(v).btype.isPositive == isPos then
					//Found one, add to #2 stack
					call s2.add(v)
				endif
				call s1.remove(v)
			endloop
			if s2.size > 0 then
				//Get random member of generated stack
				set v = s2.random
			else
				set v = 0
			endif
			//Destroy the generated stacks
			call s1.destroy()
			call s2.destroy()
			//Return our buff or 0
			if v > 0 then
				return dbuff(v) //Return our buff
			endif
		endif
		return 0 //No buff to return
	endfunction

	function GetLastAppliedBuff takes unit target returns dbuff
		local bufflist bl = bufflist(lists[GetUnitId(target)])
		if bl.sta.size > 0 then
			return dbuff(bl.sta.first)
		endif
		return 0 //No buff to return
	endfunction

	function GetFirstAppliedBuff takes unit target returns dbuff
		local bufflist bl = bufflist(lists[GetUnitId(target)])
		local Stack    s  = 0
		local integer  v  = 0
		
		//Only do this stuff if the unit has any buffs at all
		if bl.sta.size > 0 then
			//Build the stack we need
			set s = bl.sta.copy()
			//Loop through until you find the bottom of the stack
			loop
				exitwhen s.size == 0
				set v = s.first
				call s.remove(v)
			endloop
			return dbuff(v)
		endif
		return 0 //No buff to return
	endfunction

	function UnitAddBuff takes unit source, unit target, integer btype, real dur, integer lvl returns dbuff
		local timer    t  = null
		local integer  id = GetUnitId(target)
		local bufftype bt = bufftype(btype)
		local integer  d  = 0
		local dbuff    db = 0
		
		//Standard debugging procedure
		if source == null or target == null or btype < 0 or lvl < 0 or dur <= 0. then
			debug call BJDebugMsg(SCOPE_PREFIX+"Error: Invalid buff creation parameters")
			return 0 
		endif
		
		//Find if this previous instance exists in the Table
		if HaveSavedInteger(ht, btype, id) then
			//Exists, use its data
			set db = dbuff(LoadInteger(ht, btype, id))
			if (/*lvl == db.level and*/ db.timeRemaining() < dur) or lvl > db.level then
				//Update all applicable values to the newly supplied ones if new instance overwrites
				//Elapsed goes to 0 because it's as if a new buff has been cast, run timer again
				set db.source   = source
				set db.target   = target
				set db.elapsed  = 0.
				set db.duration = dur
				set db.level    = lvl
				if not db.isPeriodic and db.btype.isPeriodic then
					//If it was on the last segment of a periodic timer, reset periodicity
					set db.isPeriodic = true
				endif
				//Run the onAdd callback
				set TempBuff = db
				//It becomes a refreshed buff now
				call db.runRefreshed()
				if db.isPeriodic then
					call TimerStart(db.tmr, db.btype.period-TimerGetElapsed(db.tmr), true , function BuffTimeout)
				else
					call TimerStart(db.tmr, dur                                    , false, function BuffTimeout)
				endif
			endif
		else
			//Doesn't exist, create it
			set db = dbuff.create(source, target, bt, dur, lvl)
			//Run the onAdd callback
			set TempBuff = db
			call db.runAdd()
			if db.isPeriodic then
				call TimerStart(db.tmr, db.btype.period, true , function BuffTimeout)
			else
				call TimerStart(db.tmr, dur            , false, function BuffTimeout)
			endif
		endif
		return db
	endfunction

	function DefineBuffType takes integer AbilId, integer BuffId, real period, boolean isPeriodic, boolean isPositive, callback onAdd, callback onPeriodic, callback onEnd returns integer
		local bufftype bt = bufftype.create(AbilId, BuffId, period, isPeriodic, isPositive, onAdd, onPeriodic, onEnd)
		//Preload abilities to prevent first-buff lag
		static if LIBRARA_AbilityPreload then
			call AbilityPreload(AbilId)
		endif
		set BuffTypeCount = BuffTypeCount + 1
		set BuffTypes[BuffTypeCount] = bt
		return integer(bt)
	endfunction

	//******************************************************************************

	private function DeathActions takes nothing returns nothing
		call UnitRemoveAllBuffs(GetDyingUnit())
	endfunction

	//******************************************************************************

	private function UnitEntersMap takes unit u returns nothing
		call bufflist.create(u)
	endfunction
	
	private function UnitLeavesMap takes unit u returns nothing
		if lists[GetUnitId(u)] != 0 then
			call bufflist(lists[GetUnitId(u)]).destroy()
		endif
	endfunction

	private function Init takes nothing returns nothing
		local trigger trg = CreateTrigger()
		
		//Trigger for removing buffs on death
		call TriggerAddAction(trg, function DeathActions)
		call TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DEATH)
		
		//Indexing callback to create bufflists for indexed units
		call OnUnitIndexed(UnitEntersMap)
		
		//Removal callback to remove bufflists for indexed units
		call OnUnitDeindexed(UnitLeavesMap)
		
		//Initialize the callback code var
		set TimeOut = function BuffTimeout
	endfunction
endlibrary