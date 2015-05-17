scope Charge initializer Init
    /*
     * Description: Royal Knight Parthos launches himself into the enemy lines without fear. 
                    He gains bonus attack speed and deals damage to enemy units along the way.
     * Changelog: 
     *     	10.12.2013: Abgleich mit OE und der Exceltabelle
	 *     	29.04.2015: Integrated RegisterPlayerUnitEvent
	 *		16.05.2015: Increased Damage per Level from 100/150/200 to 200/250/300
     */
    globals
        //Spell settings
        private constant integer SPELL_ID = 'A08B' //the spell ability
        private constant real SPELL_PERIOD = XE_ANIMATION_PERIOD //the speed of the periodic timer that moves the caster
        private constant integer DAMAGE_PERIOD_FACTOR = 3 //optimization option, every how many periods are new targets affected

        //Animation options
        private constant real ANIM_SPEED_START = 1.2 //the animation speed at the start of the spell
        private constant real ANIM_SPEED_END = 0.9 //the animation speed at the end of the spell
        private constant boolean DISABLE_SPELL_SOUND = false //may be set to false with a custom warden model
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals

    //spell stats
    private constant function GlideSpeed takes integer level returns real
        return 750.0 //the distance that the caster travles per second
    endfunction
    
    private constant function GlideMaxDistance takes integer level returns real
        return 1000.0 //what is the furthest the caster can glide
    endfunction
    
    private constant function GlideMinDistance takes integer level returns real
        return 1000.0 //if the target point is closer than this, the caster will still glide this far
    endfunction

    private constant function Damage takes integer level returns real
        return 150.0 + 50.0 * level
    endfunction
    
    private constant function DamageRadius takes integer level returns real
        return 128.0
    endfunction
    
    private function DamageOptions takes xedamage spellDamage returns nothing
        //useful read: http://www.wc3campaigns.net/showpost.php?p=1030046&postcount=19
        set spellDamage.dtype = DAMAGE_TYPE
        set spellDamage.atype = ATTACK_TYPE
        set spellDamage.wtype = WEAPON_TYPE
		set spellDamage.tag=0 //the tag attached to the damage by xedamage
        set spellDamage.exception = UNIT_TYPE_STRUCTURE //deal no damage to structures
        set spellDamage.exception = UNIT_TYPE_FLYING //deal no damage to Air Units
    endfunction


// END OF CALIBRATION SECTION
// ================================================================

    //Sliding and damage
    private keyword instance
    globals
        private xedamage xed
        private timer slide
        private instance array instances
        private integer instanceCount = 0

        private group tempg = CreateGroup()
        private boolexpr tempbx
        private real tempx
        private real tempy
        private instance tempsi
    endglobals

    private function Targets takes nothing returns boolean
        local unit u = GetFilterUnit()
		local boolean b = false
		
        if not(IsUnitInGroup(u, tempsi.affected)) and /*
		*/	   IsUnitInRangeXY(u, tempx, tempy, DamageRadius(tempsi.level)) then
				call GroupAddUnit(tempsi.affected, u)
				set b = true
        endif
		
        set u = null
		
        return b
    endfunction

    private function Periodic takes nothing returns nothing
        local integer i=0
        loop
            exitwhen i>=instanceCount
            set tempsi = instances[i]
            set tempx = GetUnitX(tempsi.caster)+tempsi.dx
            set tempy = GetUnitY(tempsi.caster)+tempsi.dy
            set tempsi.time=tempsi.time-SPELL_PERIOD
            if tempsi.time > 0.0 and IsTerrainWalkable(tempx,tempy) then
                call SetUnitX(tempsi.caster, tempx)
                call SetUnitY(tempsi.caster, tempy)
                if tempsi.whenToDamage <= 0 then
                    set tempsi.whenToDamage=DAMAGE_PERIOD_FACTOR
                    call GroupEnumUnitsInRange(tempg,tempx,tempy,DamageRadius(tempsi.level) + XE_MAX_COLLISION_SIZE , tempbx)
                    call xed.damageGroup(tempsi.caster, tempg, Damage(tempsi.level)) //empties the group
                endif
                set tempsi.whenToDamage=tempsi.whenToDamage-1
                set i=i+1
            else //if instance is on the list it should still be active so it's safe to call finish
                call tempsi.finish()
            endif
        endloop
    endfunction

    //Animations
    private function Animation_Finish takes nothing returns nothing
        local instance si=instance(GetTimerData(GetExpiredTimer()))
        call SetUnitTimeScale(si.caster, 1.0)
        call si.destroy() //this will release the expired timer, so no need to do it here 
    endfunction
    
    private function Animation_Child takes nothing returns nothing
        local instance si=instance(GetTimerData(GetExpiredTimer()))
        call SetUnitFlyHeight(si.caster, 0.0, 48.0/0.125*si.timescale)
        call ReleaseTimer(GetExpiredTimer())
    endfunction
    
    private function Animation takes nothing returns nothing
        local instance si=instance(GetTimerData(GetExpiredTimer()))
        local timer t
        if si.active then //go into next animation cycle
            set t = NewTimer()
            call SetTimerData(t, integer(si))
            call SetUnitTimeScale(si.caster, si.timescale)
            call SetUnitAnimationByIndex(si.caster, 6)
            call SetUnitFlyHeight(si.caster, 48.0, 48.0/0.125*si.timescale)
            call TimerStart(t, 0.125/si.timescale, false, function Animation_Child) //run secondary function in this interval
            call TimerStart(GetExpiredTimer(), 0.35/si.timescale, false, function Animation) //run next interval
            set si.timescale=si.timescale+si.dtimescale*0.35/si.timescale //how the time scale changes during the interval
        else //let the animation finish
            call SetUnitTimeScale(si.caster, 1.5)
            call TimerStart(GetExpiredTimer(), 0.45, false, function Animation_Finish) //allow animation to finish
        endif
    endfunction
    
    //Spell instance
    private struct instance
        private integer index

        private timer t //this timer needs to be on a per-caster basis
        real timescale
        real dtimescale

        boolean active = true
        boolean interrupted = false
        integer whenToDamage = DAMAGE_PERIOD_FACTOR
        unit caster
        integer level
        real dx
        real dy
        group affected
        real time
		
		method onDestroy takes nothing returns nothing
            if not(this.interrupted) then //if the channeling wasn't interrupted by the player...
                call IssueImmediateOrder(this.caster, "stop") //...then stop it now
            endif
            call ReleaseTimer(this.t)
            call GroupClear(this.affected) //the next time this instance id is used we won't need to create a group
        endmethod
		
		static method get takes unit u returns instance
            local integer i=0
            loop
                exitwhen i==instanceCount
                if instances[i].caster==u then
                    return instances[i]
                endif
                set i=i+1
            endloop
            return 0
        endmethod
        
        method finish takes nothing returns nothing
            set this.active=false //spell stopped, wait for animation to finish and then end it
            set instanceCount=instanceCount-1
            set instances[this.index]=instances[instanceCount]
            set instances[instanceCount].index=this.index

            if instanceCount==0 then
                call ReleaseTimer(slide)
                //end of evil
                if DISABLE_SPELL_SOUND then
                    call VolumeGroupReset()
                endif
            endif
        endmethod
        
        static method create takes unit caster, integer level, real targetx, real targety returns instance
            local instance si=instance.allocate()
            local real distance
            local real factor=1.0

            call UnitAddAbility(caster, XE_HEIGHT_ENABLER)
            call UnitRemoveAbility(caster, XE_HEIGHT_ENABLER)
            set si.caster=caster
            set si.level=level
            set si.dx=targetx-GetUnitX(caster)
            set si.dy=targety-GetUnitY(caster)
            set distance = SquareRoot(si.dx*si.dx+si.dy*si.dy)+1.0 //to avoid division by zero later

            if distance>GlideMaxDistance(level) then
                set factor = GlideMaxDistance(level)/distance
            elseif distance<GlideMinDistance(level) then
                set factor = GlideMinDistance(level)/distance
            endif
            
            set si.time = factor*distance/GlideSpeed(level) //duration of the spell
            set factor = factor/si.time*SPELL_PERIOD
            set si.dx = si.dx*factor //distance traveled per interval
            set si.dy = si.dy*factor

            set si.timescale=ANIM_SPEED_START
            set si.dtimescale=(ANIM_SPEED_END-ANIM_SPEED_START)/(GlideMaxDistance(level)/GlideSpeed(level)) //animation speed change per second

            if si.affected == null then //create a group if this is the first time this instance id is used
                set si.affected = CreateGroup()
            endif

            set si.t=NewTimer() //animation timer
            call SetTimerData(si.t, integer(si))
            call TimerStart(si.t, 0.0, false, function Animation)

            //neccessary evil, the spell sounds like crap if the warden's animation sounds are allowed to play
            if DISABLE_SPELL_SOUND then
                call VolumeGroupSetVolume(SOUND_VOLUMEGROUP_SPELLS, 0.0)
            endif

            if instanceCount==0 then //slide timer
                set slide=NewTimer()
                call TimerStart(slide, SPELL_PERIOD, true, function Periodic)
            endif

            set instances[instanceCount]=si
            set si.index=instanceCount
            set instanceCount=instanceCount+1
            return si
        endmethod

    endstruct
	
	private function EndActions takes nothing returns nothing
        local instance si
        
		set si = instance.get(GetTriggerUnit())
		if si != 0 then
			call si.finish()
			set si.interrupted=true
		endif
    endfunction

    private function StartActions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
		local unit target = GetSpellTargetUnit()
        local integer lvl = GetUnitAbilityLevel(caster, SPELL_ID)
		
		if target == null then
			//point-target cast
			call instance.create(caster, lvl, GetSpellTargetX(), GetSpellTargetY())
		else
			//unit-target cast
			call instance.create(caster, lvl, GetUnitX(target), GetUnitY(target))
		endif
		
		set caster = null
		set target = null
    endfunction
    
    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function Init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function StartActions)
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function Conditions, function EndActions)

        //init damage filter
        set tempbx=Condition(function Targets)
        
        //init xedamage
        set xed=xedamage.create()
        call DamageOptions(xed)
    endfunction

endscope