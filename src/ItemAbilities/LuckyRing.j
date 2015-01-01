scope LuckyRing initializer init
	/*
	 * Item: Lucky Ring
	 */ 
    globals
        private constant integer ITEM_ID = 'I023'
        private constant integer CHANCE = 9
        private constant real HEAL_DURATION = 10.0
        private constant real HEAL_AMOUNT = 500
        private constant integer RADIUS = 250
        private constant string EFFECT = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
        private constant string ATT_POINT = "origin"
    endglobals
    
    private struct Spell
        unit attacker
        group targets
        static Spell tempthis
        
        static method create takes unit attacker returns Spell
            local Spell this = Spell.allocate()
            
            set .attacker = attacker
            set .tempthis = this
            set .targets = NewGroup()
            call GroupEnumUnitsInRange( .targets, GetUnitX(.attacker), GetUnitY(.attacker), RADIUS, function Spell.group_filter_callback )
            call ForGroup( .targets, function Spell.onHeal )
            
            return this
        endmethod
        
        static method onHeal takes nothing returns nothing
            local unit u = GetEnumUnit()
            
            call HOT.start( u, HEAL_AMOUNT, HEAL_DURATION, EFFECT, ATT_POINT )
            call .tempthis.destroy()
            
            set u = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitAlly( GetFilterUnit(), GetOwningPlayer( .tempthis.attacker ) ) and GetFilterUnit() != .tempthis.attacker and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL)
        endmethod
        
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .attacker = null
            set .targets = null
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