scope Necromancy initializer init
    /*
     * Description: The Master Necromancer raises a Skeleton from every corpse in the target area. 
                    The more skeletons raised, the weaker they are.
     * Last Update: 05.11.2013
     * Changelog: 
     *     05.11.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A05D'
        private constant integer DUMMY_ID = 'e00S'
        private constant integer CHECK_ID = 'A05E'
        private constant integer BUFF_ID = 'B00N'
        private constant real RADIUS = 250
        private integer array UNIT_IDS
        private real array UNIT_DMG
        private real array UNIT_HPS
        private integer array UNIT_MAX
        private real array UNIT_DUR
        private constant string EFFECT = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
    endglobals

    private function MainSetup takes nothing returns nothing
        
        set UNIT_IDS[1] = 'u020'
        set UNIT_IDS[2] = 'u022'
        set UNIT_IDS[3] = 'u023'
        set UNIT_IDS[4] = 'u024'
        set UNIT_IDS[5] = 'u025'
        
        set UNIT_DMG[1] = 37.0
        set UNIT_DMG[2] = 63.0
        set UNIT_DMG[3] = 88.0
        set UNIT_DMG[4] = 125.0
        set UNIT_DMG[5] = 163.0
        
        set UNIT_HPS[1] = 510
        set UNIT_HPS[2] = 900
        set UNIT_HPS[3] = 1170
        set UNIT_HPS[4] = 1440
        set UNIT_HPS[5] = 1650
        
        set UNIT_MAX[1] = 3
        set UNIT_MAX[2] = 3
        set UNIT_MAX[3] = 3
        set UNIT_MAX[4] = 3
        set UNIT_MAX[5] = 3
        
        set UNIT_DUR[1] = 60
        set UNIT_DUR[2] = 60
        set UNIT_DUR[3] = 60
        set UNIT_DUR[4] = 60
        set UNIT_DUR[5] = 60
        
    endfunction
    
    private struct Necromancy
        unit caster
        group targets
        integer numskellies = 0
        integer level = 0
        static thistype tempthis
		
		method onDestroy takes nothing returns nothing
            call ReleaseGroup(.targets)
            set .targets = null
            set .caster = null
        endmethod
		
		static method onCreateSkeleton takes nothing returns nothing
            local unit s = GetEnumUnit()
            call SetUnitMaxState(s, UNIT_STATE_MAX_LIFE, UNIT_HPS[.tempthis.level]/.tempthis.numskellies)
			call SetUnitState(s, UNIT_STATE_LIFE, GetUnitState(s, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
            call TDS.addDamage(s, R2I(UNIT_DMG[.tempthis.level]/.tempthis.numskellies))
            call UnitApplyTimedLife(s, BUFF_ID, UNIT_DUR[.tempthis.level])
            set s = null
        endmethod
		
		static method group_filter_callback takes nothing returns boolean
            local unit u = GetFilterUnit()
            local unit d
            
			if IsUnitDead(u) and (.tempthis.numskellies <= UNIT_MAX[.tempthis.level]) then
                set d = CreateUnit(GetOwningPlayer(.tempthis.caster),DUMMY_ID, GetUnitX(u), GetUnitY(u), GetUnitFacing(u))
                call UnitAddAbility(d, CHECK_ID)
                if IssueTargetOrder(d,"raisedead", u) then //Only if the corpse is suitable the unit can actually cast. The long animation prevents it from actually doing anything
                    call IssueImmediateOrderById(d, 851973) //Stop it so it doesn't use up the Corpse
                    call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(u), GetUnitY(u)))
                    //Make a Skeleton
                    call GroupAddUnit(.tempthis.targets, CreateUnit(GetOwningPlayer(.tempthis.caster), UNIT_IDS[.tempthis.level], GetUnitX(u), GetUnitY(u), GetUnitFacing(u)))
                    set .tempthis.numskellies = .tempthis.numskellies + 1
                    call RemoveUnit(u)
                endif
                call RemoveUnit(d)
                set d = null
            endif
            set u = null
            return false
        endmethod
        
        static method create takes unit c, real tx, real ty returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = c
            set .targets = NewGroup()
            set .level = GetUnitAbilityLevel(c, SPELL_ID)
            
            set .tempthis = this
            call GroupEnumUnitsInArea( ENUM_GROUP, tx, ty, RADIUS, Condition( function thistype.group_filter_callback ))
            call ForGroup(.targets, function thistype.onCreateSkeleton)
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set .tempthis = 0
        endmethod
		
    endstruct

    private function Actions takes nothing returns nothing
        local Necromancy n = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set n = Necromancy.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() )
            call n.destroy()
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call MainSetup()
        call XE_PreloadAbility(CHECK_ID)
        call Preload(EFFECT)
    endfunction

endscope