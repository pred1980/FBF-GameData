scope IceTornado initializer init
     /*
     * Description: The Cold Jester summons a frightful twister of frozen shrapnels around himself, 
                    hurting every enemy unit standing in his way.
     * Changelog: 
     *     27.10.2013: Abgleich mit OE und der Exceltabelle
	 *     20.03.2015: Optimized Spell-Event-Handling (Conditions/Actions) + 
	                   Spell-Immunity-Check in the "DamageTargets method"
	 *     17.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for damaging and filtering					   
     *
	 * Note: Might still leak somewhere (~ 4 Handles per cast)
     */
    globals
        private constant integer SPELL_ID = 'A04J'
        private constant integer DUMMY_ID = 'h004' //Effect Dummy revolving around Caster
        private constant string EFFECT_ID = "Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl"
        private constant real AOE_RANGE = 128.0 //Range of the Tornado
        private constant real CRCL_RADIUS = 180.0 //Distance between Tornado and Caster
        private constant real TMR_INTERVAL = 0.03 //Timer interval in seconds
        private constant real CRCL_PERIOD = 3.6 //Time in seconds needed for one revolution
        private constant boolean CLOCKWISE = true //Whether the Tornado revolves clockwise or counter-clockwise
        
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_ICE
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
		private real array DURATION
        private real array DAMAGE
        private real MATRIX_MAJOR //Entries of the Rotational Matrix
        private real MATRIX_MINOR
    endglobals
    
    private function MainSetup takes nothing returns nothing
        local real theta
        
        set DURATION[0] = 8
        set DURATION[1] = 8
        set DURATION[2] = 8
        set DURATION[3] = 8
        set DURATION[4] = 8
        
        set DAMAGE[0] = 69
        set DAMAGE[1] = 95
        set DAMAGE[2] = 132
        set DAMAGE[3] = 167
        set DAMAGE[4] = 190
        
        // end of user configuration        
        set theta = TwoPI/CRCL_PERIOD*TMR_INTERVAL //Angle the Tornado revolves around each interval
        set MATRIX_MAJOR = Cos(theta)
        static if CLOCKWISE then
            set MATRIX_MINOR = Sin(theta)
        else
            set MATRIX_MINOR = -Sin(theta)
        endif
        
    endfunction

    private struct Tornado
        unit caster
        unit dummy
        group targets
        real rx
        real ry
        timer durationTimer
        timer intervalTimer
        integer level
        
        static thistype tempthis
        static group temptargets
        
        static method DamageTargets takes nothing returns boolean
            local unit u = GetFilterUnit()
            
			if (SpellHelper.isValidEnemy(u, .tempthis.caster)) and not /*
			*/  IsUnitInGroup(u, .tempthis.targets) then
				set DamageType = PHYSICAL
				call SpellHelper.damageTarget(.tempthis.caster, u, DAMAGE[.tempthis.level], true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
				call DestroyEffect(AddSpecialEffect(EFFECT_ID, GetUnitX(u), GetUnitY(u)))
				
				return true
			endif

            set u = null
			
            return false
        endmethod
        
        static method RenewGroup takes nothing returns nothing
            call GroupAddUnit(.tempthis.targets,GetEnumUnit())
        endmethod
        
        static method Interval takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real rxold = this.rx
            local real ryold = this.ry
            
			//Stop when caster dies
			if (SpellHelper.isUnitDead(this.caster)) then
			    call this.destroy()
                return
            endif
			
            //Set Dummy to new position
            set this.rx = rxold * MATRIX_MAJOR - ryold * MATRIX_MINOR
            set this.ry = ryold * MATRIX_MAJOR + rxold * MATRIX_MINOR
            set rxold = this.rx + GetUnitX(this.caster)
            set ryold = this.ry + GetUnitY(this.caster)
            call SetUnitPosition(this.dummy, rxold, ryold)
            //Call Damage Function for new targets
            set .tempthis = this
            call GroupEnumUnitsInRange(.temptargets, rxold, ryold, AOE_RANGE, Condition(function Tornado.DamageTargets))
            call GroupClear(this.targets)
            call ForGroup(.temptargets, function thistype.RenewGroup) //Set the contents of the target group to the units at the moment inside the tornado (targets=temptargets doesn't work thanks to pointers)
        endmethod
        
        static method create takes unit c returns thistype
            local thistype this = thistype.allocate()
            local real theta = GetUnitFacing(c) * bj_DEGTORAD
            
            set .caster = c
            set .level = GetUnitAbilityLevel(c, SPELL_ID) - 1
            set .targets = NewGroup()
            set .rx = CRCL_RADIUS*Cos(theta)
            set .ry = CRCL_RADIUS*Sin(theta)
            set .dummy = CreateUnit(GetOwningPlayer(.caster),DUMMY_ID,GetUnitX(.caster),GetUnitY(.caster),0)
            call SetUnitScale( .dummy, 0.5, 0.5, 0.5 )
            
            set .durationTimer = NewTimer()
            set .intervalTimer = NewTimer()
            call SetTimerData( .durationTimer , this )
            call SetTimerData( .intervalTimer , this )
            call TimerStart(.intervalTimer, TMR_INTERVAL,true, function thistype.Interval)
            call TimerStart(.durationTimer, DURATION[.level],false, function thistype.EndDuration)
            
            return this
        endmethod
        
        static method EndDuration takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
        method onDestroy takes nothing returns nothing
			set .caster = null
			set .dummy = null
            call ReleaseGroup( .targets )
            call RemoveUnit( .dummy )
            call ReleaseTimer( .durationTimer )
            call ReleaseTimer( .intervalTimer )
        endmethod
        
        static method onInit takes nothing returns nothing
            set .tempthis = 0
            set .temptargets = NewGroup()
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call Tornado.create( GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call Preload(EFFECT_ID)
		call MainSetup()
    endfunction

endscope