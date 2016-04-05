scope ConsumeHimself initializer init
    /*
     * Description: The Abomination consumes a chunk of his body to regenerate some hitpoints over 10 seconds.
     * Changelog: 
     *     	09.11.2013: Abgleich mit OE und der Exceltabelle
	 *		30.03.2016: Added "Return Mana if full hp" functionality
	 *		31.03.2016: Code optimizations
     *
     */
    globals
        private constant integer SPELL_ID = 'A06M'
		private constant integer BUFF_PLACER_ID = 'A0AQ'
        private constant integer BUFF_ID = 'B00V'
        private constant real CONSUME_COUNT = 3.00 //3 Wiederholungen a 1.67s ~ 5s. Heilung
        private constant real INTERVAL = 1.67
        private constant real DURATION = CONSUME_COUNT * INTERVAL
        private constant string MESSAGE = "The Abomination has full health points."
        private constant integer FACTOR = 4
        
        //Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = DURATION
    endglobals

    private struct ConsumeHimself
        private unit caster
        private integer level = 0
        private real duration = DURATION
        private timer t
		private static integer buffType = 0
		private dbuff buff = 0
		
		method onDestroy takes nothing returns nothing
			set .caster = null
		endmethod
        
        static method onPeriodic takes nothing returns nothing
			local timer t = GetExpiredTimer()
            local thistype this = GetTimerData(t)
            
			if ((this.duration <= 0.00) or /*
			*/	(SpellHelper.isUnitDead(this.caster)) or /*
			*/	(GetUnitLifePercent(this.caster) == 100.00)) then
                call ReleaseTimer(t)
				call UnitEnableAttack(this.caster)
				call ResetUnitAnimation(this.caster)
            else
                call SetUnitAnimation(this.caster, "stand channel")
                call SetUnitState(this.caster, UNIT_STATE_LIFE,(0.01 * (this.level + FACTOR) * GetUnitState(this.caster,UNIT_STATE_MAX_LIFE)) + GetUnitState(this.caster, UNIT_STATE_LIFE))
            endif
			set this.duration = this.duration - INTERVAL
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .level = GetUnitAbilityLevel(caster, SPELL_ID)
            set .t = NewTimer()
			call SetTimerData(.t, this)
			call TimerStart(.t, INTERVAL, true, function thistype.onPeriodic)
			call Stun_UnitEx(.caster, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
			call UnitDisableAttack(.caster)
			call IssueImmediateOrder(.caster, "holdposition" )
			
			set UnitAddBuff(.caster, .caster, .buffType, DURATION, .level).data = this

            return this
        endmethod
		
		static method onBuffEnd takes nothing returns nothing
			call thistype(GetEventBuff().data).destroy()
        endmethod
		
		static method onInit takes nothing returns nothing
			set .buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0, false, true, 0, 0, thistype.onBuffEnd)
		endmethod
       
     endstruct

    private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		
		if GetUnitLifePercent(caster) != 100.00 then
			call ConsumeHimself.create(caster)
		else
			//Return Mana Costs
			call RunManaCost(SPELL_ID, caster, caster, 0., 0.)
			//Error Message
			call SimError(Player(GetConvertedPlayerId(GetOwningPlayer(caster)) - 1), MESSAGE)
			//Reset Cooldown of the Ability
			call SpellHelper.resetAbility(caster, SPELL_ID)
		endif
		
		set caster = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
    endfunction

endscope