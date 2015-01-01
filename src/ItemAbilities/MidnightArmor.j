scope MidnightArmor initializer init
	/*
	 * Item: Midnight Armor
	 */ 
    globals
        private constant integer ITEM_ID = 'I03W'
        private constant integer CHANCE = 5
        private constant real HEAL_DURATION = 15.0
        private constant string EFFECT = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
        private constant string ATT_POINT = "origin"
    endglobals
    
    private struct Spell
        unit attacker
        
        static method create takes unit attacker returns Spell
            local Spell this = Spell.allocate()
            
            set .attacker = attacker
            call HOT.start( .attacker, GetUnitState(.attacker, UNIT_STATE_MAX_LIFE), HEAL_DURATION, EFFECT, ATT_POINT )
            call this.destroy()
            
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .attacker = null
        endmethod
        
    endstruct

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local Spell s = 0
        
        if ( UnitHasItemOfTypeBJ(damageSource, ITEM_ID) and GetRandomInt(1, 100) <= CHANCE and DamageType == 0 and IsDead ) then
            call ResetIsDead()
            set s = Spell.create(damageSource)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call Preload(EFFECT)
    endfunction

endscope