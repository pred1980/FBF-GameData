scope FleshWound initializer init
    /*
     * Description: Every second hit weakens the enemys armor by 2 points for 5 seconds. 
	                The effect can stack several times.
     * Changelog: 
     *      28.10.2013: Abgleich mit OE und der Exceltabelle
	 *		13.04.2015: Code Refactoring
	 *					Integrated SpellHelper for filtering
	 *		31.01.2016: Reworked stack process (was necessary for working correctly in AI System)
	 *		07.02.2016: Bugfixing
     *
     */
    private keyword FleshWound
	private keyword FleshWoundData

    globals
        private constant integer SPELL_ID = 'A04T'
        private constant integer HITS = 2
		// This delay is for reseting the hitCounter + stackCounter if no stroke comes after the last one
		private constant real HIT_DELAY = 3.0
		// This duration describes how long the "-armor" works
        private constant real STACK_DURATION = 5.0
		// this duration is for the effect
		private constant real EFFECT_DURATION = 1.5
		private constant string EFFECT = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl"
        
		private integer array ARMOR_REDUCE
        private FleshWound array fleshWoundForCaster
		private FleshWoundData array fleshWoundForTarget
    endglobals
    
    private function MainSetup takes nothing returns nothing
		set ARMOR_REDUCE[1] = -2
        set ARMOR_REDUCE[2] = -4
        set ARMOR_REDUCE[3] = -6
        set ARMOR_REDUCE[4] = -8
        set ARMOR_REDUCE[5] = -10
    endfunction
	
	private struct FleshWoundData
		unit target
		integer hitCounter
		integer stackCounter
		timer hitTimer
		timer stackTimer
		boolean isHitInTime
		real time = 0.
		trigger t
		private static thistype tempthis = 0
		
		method onDestroy takes nothing returns nothing
			set fleshWoundForTarget[GetUnitId(.target)] = 0
			set .target = null
		endmethod
		
		private static method onUnitDeath takes nothing returns nothing
			local unit killedUnit = GetTriggerUnit()
			
			if (getForUnit(killedUnit) != 0) then
				call getForUnit(killedUnit).destroy()
			endif
			
			set killedUnit = null
		endmethod
		
		static method getForUnit takes unit u returns thistype
			return fleshWoundForTarget[GetUnitId(u)]
		endmethod
		
		static method onFleshWoundEnd takes nothing returns nothing
			local thistype data = GetTimerData(GetExpiredTimer())
           
			set data.time = data.time - 1.0
			if (data.time <= 0) then
				call ReleaseTimer(GetExpiredTimer())
				call RemoveUnitBonus(data.target, BONUS_ARMOR)
			endif
		endmethod
		
		static method onHitReset takes nothing returns nothing
			local thistype data = GetTimerData(GetExpiredTimer())
			
			call ReleaseTimer(GetExpiredTimer())
			if (not data.isHitInTime) then
				set data.hitCounter = 0
				set data.stackCounter = 0
				set data.isHitInTime = false
			endif
		endmethod

		static method create takes unit damagedUnit returns thistype
			local thistype this = thistype.allocate()
			local trigger t = CreateTrigger()

			set fleshWoundForTarget[GetUnitId(damagedUnit)] = this
			
			call TriggerRegisterUnitEvent(t, damagedUnit, EVENT_UNIT_DEATH)
			call TriggerAddAction(t, function thistype.onUnitDeath)
			set t = null
			
			set .tempthis = this
			
			return this
		endmethod
	endstruct
    
    private struct FleshWound
		
		static method getForUnit takes unit u returns thistype
			return fleshWoundForCaster[GetUnitId(u)]
		endmethod

		method onAttack takes unit damageSource, unit damagedUnit, real dmg returns nothing
			local integer level = GetUnitAbilityLevel(damageSource, SPELL_ID)
			local FleshWoundData data = FleshWoundData.getForUnit(damagedUnit)

			if (data == 0) then
				set data = FleshWoundData.create(damagedUnit)
				set data.target = damagedUnit
				set data.hitCounter = 0
				set data.stackCounter = 0
			endif

			set data.hitCounter = data.hitCounter + 1
			set data.isHitInTime = true
			
			if (data.hitCounter == HITS) then
				set data.hitCounter = 0

				if (data.stackCounter <= level) then
					if (data.stackCounter < level) then
						set data.stackCounter = data.stackCounter + 1
					endif
					
					if (GetUnitBonus(data.target, BONUS_ARMOR) != ARMOR_REDUCE[data.stackCounter]) then
						call AddUnitBonus(data.target, BONUS_ARMOR, ARMOR_REDUCE[data.stackCounter])
						call TimedEffect.createOnUnit(EFFECT, data.target, "origin", EFFECT_DURATION)
					endif
					
					if (data.time <= 0.) then
						set data.time = STACK_DURATION
						set data.stackTimer = NewTimer()
						call SetTimerData(data.stackTimer, data)
						call TimerStart(data.stackTimer, 1.0, true, function FleshWoundData.onFleshWoundEnd)
					else
						set data.time = STACK_DURATION
					endif
				endif			
			endif
			
			if (TimerGetRemaining(data.hitTimer) <= 0.) then
				set data.hitTimer = NewTimer()
				call SetTimerData(data.hitTimer, data)
				call TimerStart(data.hitTimer, HIT_DELAY, false, function FleshWoundData.onHitReset)
				
				set data.isHitInTime = false
			endif
		endmethod

		static method create takes unit damageSource returns thistype
            local thistype this = thistype.allocate()

			set fleshWoundForCaster[GetUnitId(damageSource)] = this
			
			return this
        endmethod
    endstruct
	
	// damageSource == Ghoul
	// damagedUnit  == Target
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local FleshWound fw = FleshWound.getForUnit(damageSource)
        
        if (GetUnitAbilityLevel(damageSource, SPELL_ID) > 0 	and /*
		*/	SpellHelper.isValidEnemy(damagedUnit, damageSource) and /*
		*/	DamageType == PHYSICAL ) then
			if (fw != 0) then
				call fw.onAttack(damageSource, damagedUnit, damage)
			endif
        endif
    endfunction
	
	private function SkillActions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local FleshWound fw = FleshWound.getForUnit(caster)
		
		if (fw == 0) then
			set fw = FleshWound.create(caster)
		endif
		
        set caster = null
	endfunction
	
	//The condition if trigger should run (refers to the event : EVENT_PLAYER_HERO_SKILL)
    private function Conditions takes nothing returns boolean
        return GetUnitAbilityLevel(GetTriggerUnit(), SPELL_ID) != 0
    endfunction

    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function Conditions, function SkillActions)
        call RegisterDamageResponse( Actions )
		call MainSetup()
    endfunction

endscope