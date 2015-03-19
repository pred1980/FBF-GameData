scope ConfusedSight initializer init
	/*
	 * Item: Seeing Staff
	 */ 
    globals
        private constant integer SPELL_ID= 'A03L'
        private constant integer WARD_ID = 'o002'
        private constant real WARD_LIFE_TIME = 30
        private constant integer DUMMY_ID = 'e00H'
        private constant integer DUMMY_SPELL_ID = 'A03M'
        private constant real DUMMY_LIFE_TIME = .75
        private constant string SFX = "Abilities\\Spells\\Other\\Andt\\Andt.mdl"
        private constant string SFX_ATTPT = "origin"
        private constant real RADIUS = 350
        private constant integer MIN_TARGETS = 1
        private constant integer MAX_TARGETS = 4
        private constant real MIN_RANDOM_TIME = .75
        private constant real MAX_RANDOM_TIME = 2.0
        
    endglobals

    private struct Spell
        unit caster
        unit ward
        effect sfx
        group targets
        timer t
        timer main
        static Spell tempthis
        
        static method create takes unit caster returns Spell
            local Spell this = Spell.allocate()
            local real x
            local real y
            
            set .caster = caster
            set x = GetLocationX(GetSpellTargetLoc())
            set y = GetLocationY(GetSpellTargetLoc())
            set .ward = CreateUnit( GetOwningPlayer( .caster ), WARD_ID, x, y, 0 )
            set .sfx = AddSpecialEffectTarget(SFX, .ward, SFX_ATTPT)
            set .targets = NewGroup()
            set .t = NewTimer()
            set .main = NewTimer()
            set .tempthis = this
            
            call SetTimerData(.main, this)
            call TimerStart(.main, WARD_LIFE_TIME , false, function thistype.onMainTimerEnd)
            call SetTimerData(.t, this)
            call TimerStart(.t, GetRandomReal(MIN_RANDOM_TIME, MAX_RANDOM_TIME) , false, function thistype.onRandomTimerEnd)
            
            call UnitApplyTimedLife( .ward, 'BTLF', WARD_LIFE_TIME )
            call GroupEnumUnitsInRange( .targets, GetUnitX(.ward), GetUnitY(.ward), RADIUS, function Spell.group_filter_callback )
            
            return this
        endmethod
        
        static method onMainTimerEnd takes nothing returns nothing
            local Spell this = GetTimerData(GetExpiredTimer())
            
            call this.destroy()
        endmethod
        
        static method onRandomTimerEnd takes nothing returns nothing
            local Spell this = GetTimerData(GetExpiredTimer())
            
            call ForGroup( GetRandomSubGroup(GetRandomInt(MIN_TARGETS, MAX_TARGETS), this.targets), function Spell.onGetTargets )
            if .ward != null then
                call GroupEnumUnitsInRange( this.targets, GetUnitX(this.ward), GetUnitY(this.ward), RADIUS, function Spell.group_filter_callback )
                call SetTimerData(GetExpiredTimer(), this)
                call TimerStart(GetExpiredTimer(), GetRandomReal(MIN_RANDOM_TIME, MAX_RANDOM_TIME) , false, function thistype.onRandomTimerEnd)
            endif
        endmethod
        
        static method onGetTargets takes nothing returns nothing
            local unit dummy = null
            local unit filterUnit = GetEnumUnit()
            
            set dummy = CreateUnit( GetOwningPlayer( .tempthis.caster ), DUMMY_ID, GetUnitX( filterUnit ), GetUnitY( filterUnit ), 0 )
            call UnitAddAbility( dummy, DUMMY_SPELL_ID )
            call SetUnitAbilityLevel( dummy, DUMMY_SPELL_ID, 1 )
            call UnitApplyTimedLife( dummy, 'BTLF', DUMMY_LIFE_TIME )
            call IssueTargetOrder( dummy, "invisibility", filterUnit )
            
            call GroupRemoveUnit(.tempthis.targets, filterUnit)
            set dummy = null
            set filterUnit = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitAlly( GetFilterUnit(), GetOwningPlayer( .tempthis.caster ) ) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL) and not IsUnitHidden(GetFilterUnit())
        endmethod
        
         method onDestroy takes nothing returns nothing
            set .caster = null
            set .ward = null
            call DestroyEffect(.sfx)
            call ReleaseGroup( .targets )
            call ReleaseTimer( .t )
            call ReleaseTimer( .main )
            set .targets = null
            set .t = null
            set .main = null
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local Spell s = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set s = Spell.create( GetTriggerUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call XE_PreloadAbility(DUMMY_SPELL_ID)
		
		set t = null
    endfunction

endscope