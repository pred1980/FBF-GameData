scope PoisonMarker initializer init
	/*
	 * Item: Moon Guard Robe
	 */ 
    globals
        private constant integer ITEM_ID = 'I03Y'
        private constant integer AURA_ID = 'A05J'
        private constant integer BUFF_ID = 'B02Z'
        private constant integer DUMMY_SPELL_ID = 'A05I'
        private constant integer DUMMY_ID = 'e00N'

        private constant real DUMMY_LIFE_TIME = .75
        private constant real POISON_DELAY = 3.00
        private constant integer RADIUS = 800
        private constant integer CHANCE = 15
    endglobals

    private struct Spell
        unit caster
        group targets
        timer tim
        static Spell tempthis
        
        static method create takes unit attacker returns Spell
            local Spell this = Spell.allocate()
            
            set .caster = attacker
            set .targets = NewGroup()
            set .tim = NewTimer()
            
            set .tempthis = this
            call GroupEnumUnitsInArea( .targets, GetUnitX( .caster ), GetUnitY( .caster ), RADIUS, Condition( function Spell.group_filter_callback ) )

            call SetTimerData( .tim, this )
            call TimerStart( .tim, POISON_DELAY, false, function Spell.timer_callback )

            return this
        endmethod
        
        static method group_callback takes nothing returns nothing
            local unit u = CreateUnit( GetOwningPlayer( .tempthis.caster ), DUMMY_ID, GetUnitX( .tempthis.caster ), GetUnitY( .tempthis.caster ), 0 )
            
            call UnitAddAbility( u, DUMMY_SPELL_ID )
            call SetUnitAbilityLevel( u, DUMMY_SPELL_ID, 1 )
            call UnitApplyTimedLife( u, 'BTLF', DUMMY_LIFE_TIME )
           
            call IssueTargetOrder( u, "shadowstrike", GetEnumUnit() )
            
            call UnitRemoveAbility( GetEnumUnit(), AURA_ID )
            call UnitRemoveAbility( GetEnumUnit(), BUFF_ID )
            
            set u = null
        endmethod
        
        static method timer_callback takes nothing returns nothing
            local Spell this = GetTimerData( GetExpiredTimer() )
            
            if( this != 0 )then
                set .tempthis = this
                call ForGroup( this.targets, function Spell.group_callback )
                call this.destroy()
            endif
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            if( IsUnitEnemy( GetFilterUnit(), GetOwningPlayer( .tempthis.caster ) ) and not IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) )then
                call UnitAddAbility( GetFilterUnit(), AURA_ID )
                return true
            endif
            return false
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            call ReleaseTimer( .tim )
            set .caster = null
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
        call XE_PreloadAbility(AURA_ID)
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction

endscope