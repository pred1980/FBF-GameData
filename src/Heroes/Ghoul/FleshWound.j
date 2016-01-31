scope FleshWound initializer init
    /*
     * Description: Every second hit weakens the enemys armor by 2 points for 3 seconds. 
	                The effect can stack several times.
     * Changelog: 
     *      28.10.2013: Abgleich mit OE und der Exceltabelle
	 *		13.04.2015: Code Refactoring
	 *					Integrated SpellHelper for filtering
	 *		31.01.2016: Reworked stack process (was necessary for working correctly in AI System)
     *
     */
    private keyword FleshWound

    globals
        private constant integer SPELL_ID = 'A04T'
        private constant integer HITS = 2
        private constant real STACK_DURATION = 3.0
		private constant string EFFECT = "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl"
        
		private integer array STACK
        private FleshWound array spellForUnit
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set STACK[1] = 2
        set STACK[2] = 4
        set STACK[3] = 6
        set STACK[4] = 8
        set STACK[5] = 10
    endfunction
    
    private struct FleshWound
        private unit attacker
        private unit target
        private integer hitCounter = 0
        private timer t
		private effect sfx 
		
		method onDestroy takes nothing returns nothing
			call DestroyEffect(.sfx)
			call SetUnitBonus(.target, BONUS_ARMOR, 0)
			
            set spellForUnit[GetUnitId(.attacker)] = 0
            set .attacker = null
            set .target = null
        endmethod
        
		static method getForUnit takes unit u returns thistype
			return spellForUnit[GetUnitId(u)]
		endmethod
		
        static method create takes unit damageSource, unit damagedUnit returns thistype
            local thistype this = thistype.allocate()

			set .attacker = damageSource
            set .hitCounter = 1
			set .target = damagedUnit
			set spellForUnit[GetUnitId(damageSource)] = this
            
			return this
        endmethod
		
		static method onStackReset takes nothing returns nothing
            local timer t = GetExpiredTimer()
			local thistype data = GetTimerData(t)
            
			call DestroyTimer(t)
			set t = null
			call data.destroy()
        endmethod
		
		method onAttack takes unit t, real dmg returns nothing
			local integer level = GetUnitAbilityLevel(.attacker, SPELL_ID)
			
            // same unit ???
			if (t == .target) then 
                set .hitCounter = .hitCounter + 1
                if (.hitCounter == HITS) then
					call SetUnitBonus(.target, BONUS_ARMOR, -STACK[level])
					
					set .sfx = AddSpecialEffect(EFFECT, GetUnitX(.target), GetUnitY(.target))
					set .t = CreateTimer()
					call SetTimerData(.t, this)
					call TimerStart(.t, STACK_DURATION, false, function thistype.onStackReset)
                endif
			else 
				set .target = t
				set .hitCounter = 1
			endif
		endmethod
    endstruct

	// damageSource == Ghoul
	// damagedUnit  == Target
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local FleshWound fw = FleshWound.getForUnit(damageSource)
        
        if (GetUnitAbilityLevel(damageSource, SPELL_ID) > 0 	and /*
		*/	SpellHelper.isValidEnemy(damagedUnit, damageSource) and /*
		*/	DamageType == PHYSICAL ) then
			if (fw == 0) then
				set fw = FleshWound.create(damageSource, damagedUnit)
			else
				call fw.onAttack(damagedUnit, damage)
			endif
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
		call MainSetup()
    endfunction

endscope