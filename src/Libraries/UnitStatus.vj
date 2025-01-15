library UnitStatus initializer Init requires TimerUtils, AutoIndex, optional xebasic
//******************************************************************************
//* BY: Rising_Dusk
//* 
//* This library exists because oftentimes, a mapmaker needs to apply a specific
//* status effect to a unit. If he were to do it on his own, he'd need to find a
//* way to get the status effects to stack properly with one another and with
//* multiple instances of themselves. This script does just that with the five
//* most useful status options in WC3 that cannot be reproduced perfectly with
//* just code and not actual in-game buffs.
//* 
//* WARNING: This library uses the following buffs. If you use any of the listed
//*          buffs in your map, they will not stack with this script's buffs and
//*          it may not work. If you need these effects, then only use this
//*          script to achieve them.
//*           - Drunken Haze
//*           - Soul Burn
//*           - Ensnare
//*           - Storm Bolt
//*           - Hurl Boulder
//* 
//******************************************************************************
//* 
//* The following status effects are supported by this library.
//* 
//* -   Silence
//*   This status disables a given unit's ability to cast spells. This works
//*   properly on spell immune and normal units.
//*   
//*     Example Usage:
//*   call SilenceUnit(u, true)     //Silences a unit
//*   call SilenceUnit(u, false)    //Removes silence from a unit
//*   call SilenceUnitTimed(u, 4.0) //Adds a timed silence to a unit
//*   
//* -   Disarm
//*   This status disables a given unit's ability to attack and attack ground.
//*   This will not work properly on spell immune units because of a Blizzard
//*   bug. The function calls will return false when used on units that are
//*   spell immune. This status disables both ranged and melee attacks.
//*   
//*     Example Usage:
//*   call DisarmUnit(u, true)      //Disarms a unit
//*   call DisarmUnit(u, false)     //Removes disarm from a unit
//*   call DisarmUnitTimed(u, 4.0)  //Adds a timed disarm to a unit
//*   
//* -   Ensnare
//*   This status disables a given unit's ability to move. This works properly
//*   on spell immune and normal units. Because of the nature of the ability
//*   this is based upon, it will exhibit strange behavior on flying units. If
//*   this is used on flying units, they will retain their flying height, but
//*   be treated as ground units by the game. There is unfortunately no
//*   workaround for this behavior. It is recommended to not use it on flying
//*   units because for that reason.
//*   
//*     Example Usage:
//*   call EnsnareUnit(u, true)     //Ensnares a unit
//*   call EnsnareUnit(u, false)    //Removes ensnare from a unit
//*   call EnsnareUnitTimed(u, 4.0) //Adds a timed ensnare to a unit
//*   
//* -   Stun
//*   This status is identical in nature to the standard melee stun. A stunned
//*   unit cannot move, attack, or cast spells. Both spell immune and normal
//*   units can be stunned.
//*   
//*     Example Usage:
//*   call StunUnit(u, true)        //Ensnares a unit
//*   call StunUnit(u, false)       //Removes stun from a unit
//*   call StunUnitTimed(u, 4.0)    //Adds a timed stun to a unit
//*   
//* -   Disable
//*   Disable is a unique status meant to be used as a replacement for pausing a
//*   unit using the PauseUnit native. Pausing a unit has the negative side
//*   effects of removing the unit's command card and not preserving queued
//*   orders. Disabling a unit retains both of those sought features. Disable is
//*   a non-graphical stun at its core that is always 'underneath' stun when
//*   both are applied on a unit at once as listed below.
//*   
//*   Disable also interacts with stun in a unique way.
//*    - If stun is used on a disabled unit, the unit becomes stunned instead.
//*    - If stun ends on a disabled unit, the unit is disabled until the disable
//*      ends.
//*    - If disable is used on a stunned unit, the unit remains visibly stunned.
//*   
//*     Example Usage:
//*   call DisableUnit(u, true)     //Disables a unit
//*   call DisableUnit(u, false)    //Removes disable from a unit
//*   call DisableUnitTimed(u, 4.0) //Adds a timed disable to a unit
//* 
//* WARNING: These status effects, when used on invulnerable units, will have
//*          absolutely no effect.
//* 
//******************************************************************************
//* 
//* There is a textmacro call below that runs a series of ObjectMerger calls
//* inside of an embedded .lua script. This sub-script generates all of the
//* abilities and buffs required by this library automatically for you. Enable
//* it by uncommenting the textmacro, saving your map, closing your map,
//* reopening your map, and commenting the macro again.
//* 
//* Note that you, as the user, may edit any of the buff icons or tooltips to
//* your liking. It is not recommended to edit the data fields for the spells,
//* though. They are the way they are so that they will work.
//* 
//* WARNING: The ObjectMerger call for Disarm's ability seems to be unable to
//*          properly configure the "Data - Attacks Prevented" field. If you
//*          find that the DisarmUnit call isn't functioning as intended, then
//*          set that field to "None", save your map, set the field back to
//*          "Melee, Ranged", and then save your map again. It should now work
//*          properly.
//* 
//* You may change the raw ids of any of the generated abilities as needed for
//* your map. (If there are conflicts) If you want to do so, then make sure that
//* you change the raw ids inside all affected ObjectMerger calls and the
//* constants in the globals block below.
//* 
//* WARNING: If you choose to change the raw id for the Silence ability, do NOT
//*          let the buff raw id match the ability raw id. If you do, the buff's
//*          special effect fields will not show in-game. (This may or may not
//*          even affect you, but it is worth noting regardless)
//* 
//* xebasic is an optional requirement. If you have xebasic in your map, this
//* script will use xebasic's dummy unit id instead of the constant below. If
//* you do not have xebasic in your map, for this to work you will need to make
//* (if you have not already) a dummy unit caster for your map. Put its raw id
//* below in the DUMMY_UNITID constant field.
//* 
//* Enjoy!
//* 

	globals
		//General constants
		private constant integer DUMMY_UNITID     = 'e00J' //Replace this with your dummy's id
		
		//Stun constants
		private constant integer STUN_ID          = 'stun' //This needs to match the ObjectMerger call above
		private constant integer STUN_ORDER_ID    = 852095 //Order id to stun a unit
		private constant integer STUN_BUFF_ID     = 'BPSE' //Normal storm bolt stun buff
		
		//Silence constants
		private constant integer SILENCE_ID       = '&sil' //This needs to match the ObjectMerger call above
		private constant integer SILENCE_ORDER_ID = 852668 //Order id to soul burn a unit
		private constant integer SILENCE_BUFF_ID  = '&SIL' //Generated soul burn based buff
		
		//Disarm constants
		private constant integer DISARM_ID        = '&arm' //This needs to match the ObjectMerger call above
		private constant integer DISARM_ORDER_ID  = 852585 //Order id to drunken haze a unit
		private constant integer DISARM_BUFF_ID   = '&ARM' //Generated drunken haze based buff
		
		//Ensnare constants
		private constant integer ENSNARE_ID       = '&ens' //This needs to match the ObjectMerger call above
		private constant integer ENSNARE_ORDER_ID = 852106 //Order id to ensnare a unit
		private constant integer ENSNARE_BUFF_ID  = '&EN1' //Generated ensnare based buff (ground)
		private constant integer ENSNARE_BUFF_ID2 = '&EN2' //Generated ensnare based buff (air)
		
		//Disable constants
		private constant integer DISABLE_ID       = '&dis' //This needs to match the ObjectMerger call above
		private constant integer DISABLE_ORDER_ID = 852252 //Order id to hurl boulder at a unit
		private constant integer DISABLE_BUFF_ID  = '&DIS' //Generated hurl boulder based buff
	endglobals

	globals
		private unit  Caster = null //Dummy caster
		private timer Temp   = null //For callback referencing
	endglobals

	//******************************************************************************

	//! textmacro UnitStatus_GenerateBase takes TYPE, CONSTANT, STRUCTNAME, INJECTPOSTBUFF, INJECTCHECK, INJECTPREBUFF
	private struct clear$TYPE$
		unit u = null
		//Exists only for clearing on Add/Remove situations
		static method create takes unit t returns thistype
			local thistype c = thistype.allocate()
			set c.u = t
			return c
		endmethod
	endstruct

	private function TimerRemove$TYPE$ takes nothing returns nothing
		local clear$TYPE$ c         = clear$TYPE$(GetTimerData(GetExpiredTimer()))
		local unit        whichUnit = c.u
		if $TYPE$Counter[GetUnitId(c.u)] == 0 then
			//Make sure we should still remove it
			call UnitRemoveAbility(c.u, $CONSTANT$_BUFF_ID)
			$INJECTPOSTBUFF$
		endif
		call ReleaseTimer(GetExpiredTimer())
		call c.destroy()
		set whichUnit = null
	endfunction

	function $TYPE$Unit takes unit whichUnit, boolean flag returns boolean
		local integer id = GetUnitId(whichUnit)
		local boolean b  = true
		
		if whichUnit == null then
			//Target can't be null
			debug call BJDebugMsg(SCOPE_PREFIX+"Error: Null unit given to $TYPE$Unit")
			return false
		endif
		if flag then
			if $TYPE$Counter[id] == 0 $INJECTCHECK$ then
				//Buff the unit
				$INJECTPREBUFF$
				call UnitShareVision(whichUnit, GetOwningPlayer(Caster), true)
				set b = IssueTargetOrderById(Caster, $CONSTANT$_ORDER_ID, whichUnit)
				call UnitShareVision(whichUnit, GetOwningPlayer(Caster), false)
			endif
			if not b then
				//Cast failed somehow
				debug call BJDebugMsg(SCOPE_PREFIX+"Error: Unit could not be buffed ($TYPE$Unit)")
				return false
			endif
		   set $TYPE$Counter[id] = $TYPE$Counter[id] + 1
		elseif $TYPE$Counter[id] > 0 then //Only run this if unit is buffed at all
			//Decrement Counter
			set $TYPE$Counter[id] = $TYPE$Counter[id] - 1
			if $TYPE$Counter[id] == 0 then
				//Clear the buff
				if GetUnitAbilityLevel(whichUnit, $CONSTANT$_BUFF_ID) == 0 then
					//Remove it in a 0.01s callback because it hasn't been applied yet
					set Temp = NewTimer()
					call SetTimerData(Temp, integer(clear$TYPE$.create(whichUnit)))
					call TimerStart(Temp, 0.01, false, function TimerRemove$TYPE$)
				else
					call UnitRemoveAbility(whichUnit, $CONSTANT$_BUFF_ID)
					$INJECTPOSTBUFF$
				endif
			endif
		else
			//Unit doesn't have the buff we're trying to remove
			return false
		endif
		return true
	endfunction

	private struct $STRUCTNAME$
		timer t
		unit  tar
		real  dur
		
		private static method end takes nothing returns nothing
			call thistype(GetTimerData(GetExpiredTimer())).destroy()
		endmethod
		static method start takes unit target, real duration returns boolean
			local thistype s
			local boolean  b = $TYPE$Unit(target, true)
			if not b then
				//Failed, return false
				return false
			endif
			set s     = thistype.allocate()
			set s.tar = target
			set s.dur = duration
			set s.t   = NewTimer()
			call SetTimerData(s.t, integer(s))
			call TimerStart(s.t, duration, false, function $STRUCTNAME$.end)
			return true
		endmethod
		private method onDestroy takes nothing returns nothing
			call $TYPE$Unit(.tar, false)
			call ReleaseTimer(.t)
		endmethod
	endstruct

	function $TYPE$UnitTimed takes unit whichUnit, real duration returns boolean
		if duration <= 0.01 then
			debug call BJDebugMsg(SCOPE_PREFIX+"Error: Less than 0.01 duration given to $TYPE$UnitTimed")
			return false
		endif
		return $STRUCTNAME$.start(whichUnit, duration)
	endfunction
	//! endtextmacro

	//******************************************************************************

	//Declare all necessary globals first
	globals
		private integer array StunCounter
		private integer array SilenceCounter
		private integer array DisarmCounter
		private integer array EnsnareCounter
		private integer array DisableCounter
	endglobals

	//Special functions for Stun
	private function StunLingeringDisable takes unit u returns nothing
		local integer id = GetUnitId(u)
		if DisableCounter[id] > 0 then
			//Add the disabled buff because it lingers on
			call UnitShareVision(u, GetOwningPlayer(Caster), true)
			call IssueTargetOrderById(Caster, DISABLE_ORDER_ID, u)
			call UnitShareVision(u, GetOwningPlayer(Caster), false)
		endif
	endfunction
	private function StunFinishDisable takes unit u returns nothing
		local integer id = GetUnitId(u)
		if DisableCounter[id] > 0 then
			//Remove the disable buff for first refcount stun
			call UnitRemoveAbility(u, DISABLE_BUFF_ID)
		endif
	endfunction

	//Generates all of the base code
	//! runtextmacro UnitStatus_GenerateBase("Stun"   , "STUN"   , "stun"   , "call StunLingeringDisable(whichUnit)", "", "call StunFinishDisable(whichUnit)")
	//! runtextmacro UnitStatus_GenerateBase("Silence", "SILENCE", "silence", "", "", "")
	//! runtextmacro UnitStatus_GenerateBase("Disarm" , "DISARM" , "disarm" , "", "", "")
	//! runtextmacro UnitStatus_GenerateBase("Ensnare", "ENSNARE", "ensnare", "call UnitRemoveAbility(whichUnit, ENSNARE_BUFF_ID2)", "", "")
	//! runtextmacro UnitStatus_GenerateBase("Disable", "DISABLE", "disable", "", "and StunCounter[id] == 0", "")

	private function Init takes nothing returns nothing
		static if LIBRARY_xebasic then
			set Caster = CreateUnit(Player(15), XE_DUMMY_UNITID, 0., 0., 0.)
		else
			set Caster = CreateUnit(Player(15), DUMMY_UNITID   , 0., 0., 0.)
		endif
		call UnitRemoveAbility(Caster, 'Amov')
		if GetUnitAbilityLevel(Caster, 'Aloc') == 0 then
			call UnitAddAbility(Caster, 'Aloc') //xe dummies don't have this automatically
		endif
		
		//Add the abilities
		call UnitAddAbility(Caster, STUN_ID)
		call UnitAddAbility(Caster, SILENCE_ID)
		call UnitAddAbility(Caster, DISARM_ID)
		call UnitAddAbility(Caster, ENSNARE_ID)
		call UnitAddAbility(Caster, DISABLE_ID)
	endfunction
endlibrary