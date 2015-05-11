scope FleshWound initializer init
    /*
     * Description: Every second hit weakens the enemys armor by 2 points for 3 seconds. 
	                The effect can stack several times.
     * Changelog: 
     *      28.10.2013: Abgleich mit OE und der Exceltabelle
	 *		13.04.2015: Code Refactoring
	 *					Integrated SpellHelper for filtering
     *
     */
    private keyword FleshWound

    globals
        private constant integer SPELL_ID = 'A04T'
        private constant integer HITS = 2
        private constant integer DUMMY_ID = 'e00F'
        private constant integer DUMMY_SPELL_ID = 'A04S'
        private constant real DUMMY_LIFE_TIME = .75
        private constant real STACK_DURATION = 3.0
        
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
        unit attacker
        unit target
        integer hitCounter = 0
        integer stackCounter = 1
        timer t
		
		method onDestroy takes nothing returns nothing
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
            local thistype this = GetTimerData(GetExpiredTimer())
            
			call ReleaseTimer(this.t)
            set this.stackCounter = 1
            set this.t = null
        endmethod
		
		method onReset takes nothing returns nothing
            set .hitCounter = 0
        endmethod 
		
		method onAttack takes unit t, real dmg returns nothing
            local unit u
            
			if t == .target then // same unit
                set .hitCounter = .hitCounter + 1
                if .hitCounter >= HITS then
                    if (.stackCounter <= STACK[GetUnitAbilityLevel(.attacker, SPELL_ID)]) then
                        set u = CreateUnit( GetOwningPlayer( .attacker ), DUMMY_ID, GetUnitX( .target ), GetUnitY( .target ), 0 )
                        call UnitAddAbility( u, DUMMY_SPELL_ID )
                        call SetUnitAbilityLevel( u, DUMMY_SPELL_ID, .stackCounter )
                        call UnitApplyTimedLife( u, 'BTLF', DUMMY_LIFE_TIME )
                        call IssueTargetOrder( u, "faeriefire", .target )
                        call onReset()
                        
                        set .stackCounter = .stackCounter + 1
                    else
                        set .t = NewTimer()
                        call SetTimerData(.t, this)
                        call TimerStart(.t, STACK_DURATION, false, function thistype.onStackReset)
                    endif
				endif
			else 
				set .target = t
				set .hitCounter = 1
                set .stackCounter = 1
			endif
			
			set u = null
		endmethod
    endstruct

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local FleshWound fw = FleshWound.getForUnit(damageSource)
        
        if (GetUnitAbilityLevel(damageSource, SPELL_ID) > 0 and /*
		*/	SpellHelper.isValidEnemy(damagedUnit, damageSource) and /*
		*/	DamageType == PHYSICAL ) then
			if fw == 0 then
				set fw = FleshWound.create(damageSource, damagedUnit)
			else
				call fw.onAttack(damagedUnit, damage)
			endif
        else
            call fw.onReset()
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call XE_PreloadAbility(DUMMY_SPELL_ID)
		call MainSetup()
    endfunction

endscope