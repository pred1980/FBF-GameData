scope Crowbar initializer init
	/*
	 * Item: Crowbar
	 */ 
    private keyword Spell

    globals
        private constant integer ITEM_ID = 'I025'
        private constant integer HITS = 3
        private constant integer DUMMY_ID = 'e00I'
        private constant integer DUMMY_SPELL_ID = 'A03B'
        private constant real DUMMY_LIFE_TIME = .75
        private constant real DAMAGE = 75.0
        
        private Spell array spellForUnit
    endglobals
    
    private struct Spell
        unit attacker
        unit target
        integer counter = 0
        
		static method getForUnit takes unit u returns Spell
			return spellForUnit[GetUnitId(u)]
		endmethod
		
        static method create takes unit damageSource, unit damagedUnit returns Spell
            local Spell this = Spell.allocate()
            set .attacker = damageSource
            set .counter = 1
			set .target = damagedUnit
			set spellForUnit[GetUnitId(damageSource)] = this
            return this
        endmethod
		
		method onAttack takes unit t, real dmg returns nothing
            local unit u = null
            
			if t == .target then // same unit
				set .counter = .counter + 1
               if .counter >= HITS then
                    set u = CreateUnit( GetOwningPlayer( .attacker ), DUMMY_ID, GetUnitX( .target ), GetUnitY( .target ), 0 )
                    call UnitAddAbility( u, DUMMY_SPELL_ID )
                    call SetUnitAbilityLevel( u, DUMMY_SPELL_ID, 1 )
                    call UnitApplyTimedLife( u, 'BTLF', DUMMY_LIFE_TIME )
                    call IssueTargetOrder( u, "slow", .target )
                    set DamageType = SPELL
                    call DamageUnitMagic( .attacker, .target, DAMAGE)
                    call TextTagCriticalStrike(.target, R2I(dmg))
					call onReset()
				endif
			else 
				set .target = t
				set .counter = 1
			endif
		endmethod
        
        method onReset takes nothing returns nothing
            set .counter = 0
        endmethod
        
        method onDestroy takes nothing returns nothing
            set spellForUnit[GetUnitId(.attacker)] = 0
            set .attacker = null
            //set .target = null testen ob das null gesetzt werden muss!
        endmethod
        
    endstruct

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local Spell s = 0
        
        set s = Spell.getForUnit(damageSource)
        if ( UnitHasItemOfTypeBJ(damageSource, ITEM_ID) and DamageType == 0 ) then
			if s == null then
				set s = Spell.create( damageSource, damagedUnit )
			else
				call s.onAttack(damagedUnit, damage)
			endif
        else
            call s.onReset()
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction

endscope