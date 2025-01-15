scope BattleFury initializer init
    /*
     * Description: Darius enters a state of fury and deals bonus hero damage on every hit. 
                    Bonus damage is reduced everytime he gets hit. If he reaches the maximum of bonus damage 
                    it hold on for the same period of time.
     * Changelog: 
     *     	05.12.2013: Abgleich mit OE und der Exceltabelle
	 *		29.04.2015: Code Refactoring
     */
    private keyword BattleFury
    
    globals
        private constant integer SPELL_ID = 'A080'
        private constant integer BUFF_ID = 'B01J'
        
        private integer array MAX_DAMAGE
        private real array DURATION
        private BattleFury array spellForUnit
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set MAX_DAMAGE[1] = 8
        set MAX_DAMAGE[2] = 16
        set MAX_DAMAGE[3] = 24
        set MAX_DAMAGE[4] = 32
        set MAX_DAMAGE[5] = 40
        
        set DURATION[1] = 10
        set DURATION[2] = 20
        set DURATION[3] = 30
        set DURATION[4] = 25
        set DURATION[5] = 30
    endfunction

    private struct BattleFury
        private unit source
        private integer counter = 0
        private integer level = 0
        private timer t
        private timer extra
        private boolean b = false
        
        static method getForUnit takes unit u returns BattleFury
			return spellForUnit[GetUnitId(u)]
		endmethod
        
		method onDestroy takes nothing returns nothing
            call RemoveUnitBonus(.source, BONUS_DAMAGE)
            call ReleaseTimer(.t)
            set .t = null
            if .extra != null then
                call ReleaseTimer(.extra)
                set .extra = null
            endif
            set spellForUnit[GetUnitId(.source)] = 0
            set .source = null
        endmethod
        
        method onAttack takes unit damageSource, BattleFury s returns nothing
            if damageSource == .source then
                if .counter <= MAX_DAMAGE[.level] then
                    call increaseDamage(s)
                endif
            else
                if GetUnitBonus(.source, BONUS_DAMAGE) > 0 and .counter > 0 then
                    call decreaseDamage()
                endif
            endif
        endmethod
        
        method increaseDamage takes BattleFury s returns nothing
            call AddUnitBonus(.source, BONUS_DAMAGE, 1)
            set .counter = .counter + 1
			
            if .counter == MAX_DAMAGE[.level] then
                call SetUnitAnimation( .source, "spell" )
                set .b = true
                call AddUnitBonus(.source, BONUS_DAMAGE, MAX_DAMAGE[.level])
                //Kill duration timer and Remove Battle Fury Buff
                call UnitRemoveAbility(.source, BUFF_ID)
                call ReleaseTimer(.t)
                set .t = null
                set .extra = NewTimer()
                call SetTimerData(.extra, s)
                call TimerStart(.extra, DURATION[.level], false, function thistype.onBonusEnd)
            endif
        endmethod
        
        method decreaseDamage takes nothing returns nothing
            call RemoveUnitBonus(.source, BONUS_DAMAGE)
            set .counter = .counter - 1
        endmethod
        
        static method onNormalEnd takes nothing returns nothing
            local BattleFury this = GetTimerData(GetExpiredTimer())
            
			if this.b == false then
                call this.destroy()
            endif
        endmethod
        
        static method onBonusEnd takes nothing returns nothing
            local BattleFury this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
		
		static method create takes unit source returns BattleFury
            local BattleFury this = BattleFury.allocate()
            
            set .source = source
            set .level = GetUnitAbilityLevel(.source, SPELL_ID)
            //Reset
            call RemoveUnitBonus(.source, BONUS_DAMAGE)
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, DURATION[.level], false, function thistype.onNormalEnd)
            set spellForUnit[GetUnitId(source)] = this
            
            return this
        endmethod
    endstruct

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local BattleFury s = 0
        
        if ( DamageType == 0 ) then
            if GetUnitAbilityLevel(damageSource, BUFF_ID) > 0 then
                set s = BattleFury.getForUnit(damageSource)
                if s == 0 then
                    set s = BattleFury.create(damageSource)
                else
                    call s.onAttack(damageSource, s)
                endif
            endif
            if GetUnitAbilityLevel(damagedUnit, BUFF_ID) > 0 then
                set s = BattleFury.getForUnit(damagedUnit)
                if s == null then
                    set s = BattleFury.create(damagedUnit)
                else
                    call s.onAttack(damageSource, s)
                endif
            endif
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse(Actions)
		call MainSetup()
    endfunction

endscope