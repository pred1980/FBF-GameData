scope Entangle initializer init
	/*
	 * Item: Everyoung Leaf
	 */ 
    globals
        private constant integer ITEM_ID = 'I048'
        private constant integer RADIUS = 650
        private constant integer CHANCE = 9
        private constant integer DUMMY_SPELL_ID = 'A05H'
        private constant integer DUMMY_ID = 'e00M'
    endglobals

    private struct Spell
        unit caster
        unit target
        unit dummy
        static Spell tempthis
        
        static method filter_callback takes nothing returns boolean
            local unit u = GetFilterUnit()
            if IsUnitEnemy( u, GetOwningPlayer( .tempthis.caster ) ) and ( GetUnitId(u) != GetUnitId(.tempthis.target) ) and not IsUnitType( u, UNIT_TYPE_DEAD ) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                return true
            endif
            set u = null
            return false
        endmethod
        
        static method create takes unit caster, unit target returns Spell
            local Spell this = Spell.allocate()
            local unit nu //nearest Unit
            
            set .caster = caster
            set .target = target
            set nu = GetClosestUnitInRange(GetUnitX( .caster ), GetUnitY( .caster ), RADIUS, Condition( function Spell.filter_callback ))
            if (nu != null) then
                set .dummy = CreateUnit( GetOwningPlayer( .caster ), DUMMY_ID, GetUnitX( .caster ), GetUnitY( .caster ), 0 )
                call UnitAddAbility( .dummy, DUMMY_SPELL_ID )
                call SetUnitAbilityLevel( .dummy, DUMMY_SPELL_ID, 1 )
                call UnitApplyTimedLife( .dummy, 'BTLF', 1 )
               
                call IssueTargetOrder( .dummy, "entanglingroots", nu )
            endif
            set nu = null
            
            set .tempthis = this
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .caster = null
            set .target = null
            set .dummy = null
        endmethod
    endstruct

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local Spell s = 0
        
        if ( UnitHasItemOfTypeBJ(damageSource, ITEM_ID) and GetRandomInt(1, 100) <= CHANCE and DamageType == 0 and IsDead ) then
            call ResetIsDead()
            set s = Spell.create(damageSource, damagedUnit)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction

endscope