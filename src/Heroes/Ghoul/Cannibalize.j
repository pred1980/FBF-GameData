scope Cannibalize initializer init
    /*
     * Description: The Abomination consumes a chunk of his body to regenerate some hitpoints over 10 seconds.
     * Changelog: 
     *     09.11.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
		// fake cannibalize (channel ability)
        private constant integer SPELL_ID = 'A04K'
		// real cannibalize (base ability)
        private constant integer SPELL_DUMMY_ID = 'A04R' 
		private constant string ORDER = "cannibalize"
		private constant integer ORDER_ID = 852188
		private constant integer DURATION = 5
		private constant real ANIMATION = 1.0
    endglobals
	
	private struct Cannibalize
		private unit caster
		private timer t
		private integer level
		private integer loopIndex = 0
		
		method onDestroy takes nothing returns nothing
			call SpellHelper.switchAbility(.caster, SPELL_DUMMY_ID, SPELL_ID, .level)
			set .caster = null
		endmethod
		
		private static method onAnimationLoop takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local thistype data = GetTimerData(t)
			local integer orderId = GetUnitCurrentOrder(data.caster)
			
			if (((data.loopIndex < DURATION) and /*
			*/	(orderId == ORDER_ID)) or /*
			*/	(GetUnitLifePercent(data.caster) < 1.0)) then
				call SetUnitAnimation(data.caster, "stand channel")
				set data.loopIndex = data.loopIndex + 1
			else
				call DestroyTimer(t)
				set t = null
				call data.destroy()
			endif
		endmethod
	
		private static method onCannibalizeEnd takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local thistype data = GetTimerData(t)
			
			call DestroyTimer(t)
			set t = null
			
			call data.destroy()
		endmethod
		
		static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
	
			set .caster = caster
			set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
			
			set .t = CreateTimer()
			call SetTimerData(.t, this)
				
			if (IssueImmediateOrder(.caster, ORDER)) then
				set .t = CreateTimer()
				call SetTimerData(.t, this)
				call TimerStart(.t, ANIMATION, true, function thistype.onAnimationLoop)
				
				call IssueImmediateOrder(.caster, ORDER)
			else
				call TimerStart(.t, 0., false, function thistype.onCannibalizeEnd)
			endif

			return this
        endmethod
	endstruct

    private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
		
		call SpellHelper.switchAbility(caster, SPELL_ID, SPELL_DUMMY_ID, level)
		
		if (IssueImmediateOrder(caster, ORDER)) then
			call Cannibalize.create(caster)
		else
			call SpellHelper.switchAbility(caster, SPELL_DUMMY_ID, SPELL_ID, level)
			//Return Mana Costs
			call SpellHelper.restoreMana(SPELL_ID, caster, null, 0., 0.)
			//Reset Cooldown of the Ability
			call SpellHelper.resetAbility(caster, SPELL_ID)
			
			if (GetUnitLifePercent(caster) == 1.0) then
				call SimError(GetOwningPlayer(caster), "Already at full health.")
			else
				//Error Message
				call SimError(GetOwningPlayer(caster), "There are no usable corpses nearby.")
			endif
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