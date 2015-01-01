library ShieldSystem initializer Init
	
	/*
	 * The_Witchers Shield System
	 * 
	 * This is an easy to use shield system.
	 * it allows you to add shield points to a unit
	 * the shield works like in the game halo:
	 * the attacked unit doesnt receive any dmg, the shield gets it
	 * when the shield is down the unit is damaged
	 * the shield can reload constantly or after some seconds of not beeing attacked
	 *
	 * to give a unit a shield just use (if duration is 0 the shield will stay without a time limit)
	 *
	 *  call AddShield( towhichunit, hitpoints, RegPerSec, TimeTillReg,  damage factor, colorcode, destroy when shieldhp = 0, show the bar, Duration  )
	 *                    unit         real       real        real         real           string       boolean                  boolean       real
	 *                                                                                                                  
	 * you can check whether a unit has already a shield with (it will return a boolean)
	 *  UnitHasShield( yourunit)
	 *                  unit
	 *
	 * to implement this system, just copy this trigger in your map
	 * it requires jngp to be edited/saved
	 *
	 * To get rid of a shield just use
	 *   call DestroyShield( which units)
	 *                         unit
	 *
	 * to show or hide the shield bar use
	 *   call ShowShield( WhichUnits, Show? )
	 *                      unit     boolean
	 *
	 * to get information about an existing shield use:
	 *    HP:           GetShieldHp(  unit  )
	 *    maxHP:        GetShieldMaxHp(  unit  )
	 *    percentHP:    GetShieldHpPercent(  unit  )
	 *    regeneration: GetShieldReg(  unit  ) 
	 *    TimeTillReg:  GetShieldTimeTillReg(  unit  )
	 *    DamageFactor: GetShieldDamageFactor(  unit  )
	 *
	 * to change the values of an existing shield use:
	 *    HP:           SetShieldHp(  unit, NewValue  )
	 *    maxHP:        SetShieldMaxHp(  unit, NewValue  )
	 *    percentHP:    SetShieldHpPercent(  unit, NewValue  )
	 *    regeneration: SetShieldReg(  unit, NewValue  )
	 *    TimeTillReg:  SetShieldTimeTillReg(  unit, NewValue  )
	 *    DamageFactor: SetShieldDamageFactor(  unit, NewValue  )
	 *
	 * have fun^^
	 * The (very small^^) Setup part
	 */
    globals
        // the shieldbar's size (should be (7.5 * 0.023 / 10 - 0.00625) or 0.01(which isn't working for everyone) for a good result)
        private constant real size = 7.5 * 0.023 / 10 - 0.00625  
        
        // A ability which gives a high instant life bonus
        private constant integer lifeabi = 'A093'  
        
        // the timer interval (should be 0.01 but if laggy then just change it)
        private constant real interval = 0.03  
        
        //the path of the special effect for untis with a shield
        //another good effect: "Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl"
        private constant string sfx = "Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget.mdl" 
        
        //the attachement point for sfx
        private constant string AtPoint = "chest"
    endglobals
    // end of Setup!!
    private struct shield
        unit u
        real hp
        real fullhp
        real reg
        real f
        string code
        texttag t
        real r
        effect fx
        real remain
        timer time
        boolean kill 
        integer i
        real damage = 0
        boolean show
    endstruct

    globals
        private trigger trg = CreateTrigger()
        private group g = CreateGroup()
        private hashtable h = InitHashtable()
        private integer total = 0
        private unit array units
        private timer tim = CreateTimer()
    endglobals

    function UnitHasShield takes unit u returns boolean
        return LoadInteger(h,GetHandleId(u),0) != 0
    endfunction

    function DestroyShield takes unit whichunits returns nothing
        local shield dat = LoadInteger(h,GetHandleId(whichunits),0)
        local shield dat2 = LoadInteger(h,GetHandleId(units[total-1]),0)
        if dat != 0 then
            call DestroyTextTag(dat.t)
            call DestroyTimer(dat.time)
            call DestroyEffect(dat.fx)
            call FlushChildHashtable(h,GetHandleId(whichunits))
            set total = total - 1
            set units[dat.i] = units[total]
            set dat2.i = dat.i
            call dat.destroy()
        endif
        if total == 0 then
            call PauseTimer(tim)
        endif
    endfunction

    private function regeneration takes nothing returns nothing
        local shield dat
        local string s = "''''''''''''''''''''''''''''''''''''''''''''''''''"
        local integer k
        local integer i = 0
        loop
            exitwhen i >= total
            set dat = LoadInteger(h,GetHandleId(units[i]),0)
            if TimerGetRemaining(dat.time) == 0 then
                if dat.hp < dat.fullhp then
                    set dat.hp = dat.hp + dat.reg
                else
                    set dat.hp = dat.fullhp
                endif
            endif
            if dat.remain > 0 then
                set dat.remain = dat.remain - interval
            elseif dat.remain != -100 then
                call DestroyShield(dat.u)
            endif
            set k = R2I(50 * (dat.hp / dat.fullhp))
            call SetTextTagText(dat.t, dat.code + SubString(s,0, k ) + "|r"  + SubString(s,k + 1,StringLength(s)) , size)
            call SetTextTagPos(dat.t,GetUnitX(dat.u) -40, GetUnitY(dat.u),-100)
            if dat.damage != 0 then
                if dat.hp > (dat.damage * dat.f) then
                    set dat.hp = dat.hp - (dat.damage * dat.f)
                    call SetWidgetLife( dat.u,GetWidgetLife(dat.u) + dat.damage)
                else
                    call SetWidgetLife( dat.u,GetWidgetLife(dat.u) + dat.hp)
                    set dat.hp = 0
                endif
                set dat.damage = 0
            endif
            call UnitRemoveAbility(dat.u,lifeabi)
            if dat.hp <= 0 and dat.kill == true then
                call DestroyShield(dat.u)
                set i = i - 1
            endif
            set i = i + 1
        endloop
        set s = null
    endfunction

    private function attack takes nothing returns nothing
        local shield dat = LoadInteger(h,GetHandleId(GetTriggerUnit()),0)
        local timer t 
        if dat != 0 then
            if dat.hp > 0 then
                set dat.damage = dat.damage + GetEventDamage()
            endif     
            call TimerStart(dat.time,dat.r,false,null)
        endif
    endfunction

    function AddShield takes unit towhich, real hp, real RegPerSec, real TimeTillReg, real dmgfactor, string colorcode, boolean destroy, boolean ShowBar, real Duration returns nothing
        local shield dat
        if LoadInteger(h,GetHandleId(towhich),0) != 0 then
            call DestroyShield(towhich)
        endif
        set dat = shield.create()
        set dat.u = towhich
        set dat.fullhp = hp
        set dat.hp = hp
        set dat.reg = RegPerSec / 100
        set dat.f = dmgfactor
        set dat.code = colorcode
        set dat.r = TimeTillReg
        set dat.kill = destroy
        set dat.time = CreateTimer()
        set dat.t = CreateTextTag()
        set dat.show = ShowBar
        set dat.fx = AddSpecialEffectTarget(sfx, dat.u, AtPoint)      
        set dat.remain = Duration
        if dat.remain == 0 then
            set dat.remain = -100 
        endif
        call SetTextTagVisibility(dat.t,ShowBar)
        set dat.i = total
        if not IsUnitInGroup(dat.u,g) then
            call GroupAddUnit(g,dat.u)
            call TriggerRegisterUnitEvent( trg, towhich, EVENT_UNIT_DAMAGED )
        endif
        set units[total] = dat.u
        set total = total + 1
        call SaveInteger(h,GetHandleId(dat.u),0,dat)
        if total == 1 then
            call TimerStart(tim,interval,true,function regeneration)
        endif
    endfunction

    private function kill takes nothing returns nothing
        call DestroyShield(GetTriggerUnit())
    endfunction

    function ShowShield takes unit u, boolean flag returns nothing
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            set dat.show = flag
            call SetTextTagVisibility(dat.t,flag)
        endif
    endfunction

    function GetShieldHpPercent takes unit u returns real
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            return dat.hp / dat.fullhp * 100.0
        endif
        return .0
    endfunction

    function GetShieldHp takes unit u returns real
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            return dat.hp
        endif
        return .0
    endfunction

    function GetShieldMaxHp takes unit u returns real
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            return dat.fullhp
        endif
        return .0
    endfunction

    function GetShieldReg takes unit u returns real
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            return dat.reg*100
        endif
        return .0
    endfunction

    function GetShieldTimeTillReg takes unit u returns real
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            return dat.r
        endif
        return .0
    endfunction

    function GetShieldDamageFactor takes unit u returns real
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            return dat.f
        endif
        return .0
    endfunction

    function SetShieldHpPercent takes unit u, real new returns nothing
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            set dat.hp = dat.fullhp * new
            if dat.fullhp < dat.hp then
                set dat.hp = dat.fullhp
            endif
        endif
    endfunction

    function SetShieldHp takes unit u, real new returns nothing
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            set dat.hp = new
            if dat.fullhp < dat.hp then
                set dat.hp = dat.fullhp
            endif
        endif
    endfunction

    function SetShieldMaxHp takes unit u, real new returns nothing
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            set dat.fullhp = new
            if dat.fullhp < dat.hp then
                set dat.hp = dat.fullhp
            endif
        endif
    endfunction

    function SetShieldReg takes unit u, real new returns nothing
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            set dat.reg = new/100
        endif
    endfunction
                                                                                
    function SetShieldTimeTillReg takes unit u, real new returns nothing
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            set dat.r = new
            call TimerStart(dat.time,dat.r,false,null)
        endif
    endfunction

    function SetShieldDamageFactor takes unit u, real new returns nothing
        local shield dat = LoadInteger(h,GetHandleId(u),0)
        if dat != 0 then
            set dat.f = new
        endif
    endfunction

    private function Init takes nothing returns nothing
        local trigger tt = CreateTrigger()
        call TriggerAddAction(tt, function kill)
        call TriggerRegisterAnyUnitEventBJ( tt, EVENT_PLAYER_UNIT_DEATH )    
        
        call TriggerAddAction(trg, function attack)    
    endfunction

endlibrary