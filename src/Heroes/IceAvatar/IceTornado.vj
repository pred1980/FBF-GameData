scope IceTornado initializer init
     /*
     * Description: The Cold Jester summons a frightful twister of frozen shrapnels around himself, 
                    hurting every enemy unit standing in his way.
     * Changelog: 
     *     	27.10.2013: Abgleich mit OE und der Exceltabelle
	 *     	20.03.2015: Optimized Spell-Event-Handling (Conditions/Actions) + 
						Spell-Immunity-Check in the "DamageTargets method"
	 *     	17.04.2015: Integrated RegisterPlayerUnitEvent
						Integrated SpellHelper for damaging and filtering
	 *		08.05.2015:	Bugfix: onDestroy()
	 *		04.09.2015: Increased damage per level by 7%
	 *		23.08.2021: reduced damage per level from 74/102/141/179/203 to 75/100/125/150/175
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
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_COLD
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
		private real array DURATION
        private real array DAMAGE
		//Entries of the Rotational Matrix
        private real MATRIX_MAJOR 
        private real MATRIX_MINOR
    endglobals
    
    private function MainSetup takes nothing returns nothing
        local real theta
        
        set DURATION[0] = 8
        set DURATION[1] = 8
        set DURATION[2] = 8
        set DURATION[3] = 8
        set DURATION[4] = 8
        
        set DAMAGE[0] = 75
        set DAMAGE[1] = 100
        set DAMAGE[2] = 125
        set DAMAGE[3] = 150
        set DAMAGE[4] = 175
        
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
        private unit caster
        private unit dummy
        private group targets
        private real rx
        private real ry
        private timer durationTimer
        private timer intervalTimer
        private integer level = 0
        
        private static thistype tempthis = 0
		
		method onDestroy takes nothing returns nothing
            call RemoveUnit( .dummy )
            call ReleaseTimer( .durationTimer )
            call ReleaseTimer( .intervalTimer )
			set .caster = null
			set .dummy = null
        endmethod
		
		private static method filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), .tempthis.caster)
		endmethod
        
        private static method damageTargets takes nothing returns nothing
            local unit u = GetTriggerUnit()
			
			set DamageType = SPELL
			call SpellHelper.damageTarget(.tempthis.caster, u, DAMAGE[.tempthis.level], false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
			call DestroyEffect(AddSpecialEffect(EFFECT_ID, GetUnitX(u), GetUnitY(u)))
			set u = null
		endmethod
        
        private static method interval takes nothing returns nothing
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
        endmethod
		
		private static method endDuration takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
        static method create takes unit c returns thistype
            local thistype this = thistype.allocate()
            local real theta = GetUnitFacing(c) * bj_DEGTORAD
			local trigger t = CreateTrigger()
            
            set .caster = c
            set .level = GetUnitAbilityLevel(c, SPELL_ID) - 1
            set .targets = NewGroup()
            set .rx = CRCL_RADIUS * Cos(theta)
            set .ry = CRCL_RADIUS * Sin(theta)
            set .dummy = CreateUnit(GetOwningPlayer(.caster),DUMMY_ID,GetUnitX(.caster),GetUnitY(.caster),0)
            call SetUnitScale( .dummy, 0.5, 0.5, 0.5 )
			call TriggerRegisterUnitInRange(t, .dummy, AOE_RANGE, Condition(function thistype.filter))
			call TriggerAddAction(t, function thistype.damageTargets)
            
			set .tempthis = this
            set .durationTimer = NewTimer()
            set .intervalTimer = NewTimer()
            call SetTimerData( .durationTimer , this )
            call SetTimerData( .intervalTimer , this )
            call TimerStart(.intervalTimer, TMR_INTERVAL, true, function thistype.interval)
            call TimerStart(.durationTimer, DURATION[.level], false, function thistype.endDuration)
            
			set t = null
			
            return this
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