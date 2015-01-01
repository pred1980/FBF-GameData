scope MetalHand initializer init
	/*
	 * Item: Metal Hand
	 */ 
    globals
        private constant integer ITEM_ID = 'I010'
        private constant integer CHANCE = 3
        private constant real HEAL_DURATION = 12.0
        private constant string EFFECT = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
        private constant string ATT_POINT = "origin"
    endglobals
    
    private struct Spell
        unit attacker
        
        static method create takes unit damagedUnit returns Spell
            local Spell this = Spell.allocate()
            
            set .attacker = damagedUnit
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
        
        if ( UnitHasItemOfTypeBJ(damagedUnit, ITEM_ID) and GetRandomInt(1, 100) <= CHANCE and DamageType == 0 ) then
            set s = Spell.create( damagedUnit )
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call Preload(EFFECT)
    endfunction

endscope