scope LifeVortex initializer init
    /*
     * Description: The Priestess of the Moon summons a powerful vortex, that deals damage to units 
                    in a targeted area for a certain period of time.
     * Last Update: 07.01.2014
     * Changelog: 
     *     07.01.2014: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A07E'
        private constant integer RADIUS = 300
        private constant string EFFECT_LOC = "Abilities\\Spells\\Items\\AItb\\AItbTarget.mdl"
        
        //DOT
        private constant real DOT_TIME = 2.5
        private constant string EFFECT = "Abilities\\Spells\\NightElf\\TargetArtLumber\\TargetArtLumber.mdl"
        private constant string ATT_POINT = "origin"
        private constant attacktype ATT_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_UNIVERSAL
        
        private real array DAMAGE
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DAMAGE[1] = 55
        set DAMAGE[2] = 75
        set DAMAGE[3] = 95
        set DAMAGE[4] = 115
        set DAMAGE[5] = 135
    endfunction

    private struct LifeVortex
        unit caster
        group targets
        integer level = 0
        static thistype tempthis
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitEnemy( GetFilterUnit(), GetOwningPlayer( .tempthis.caster ) ) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL)
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            
            call DOT.start( .tempthis.caster , u , DAMAGE[.tempthis.level] , DOT_TIME , ATT_TYPE , DMG_TYPE , EFFECT , ATT_POINT )
            call GroupRemoveUnit(.tempthis.targets, u)
            if ( CountUnitsInGroup(.tempthis.targets) == 0 ) then
                call .tempthis.destroy()
            endif
            set u = null
        endmethod
        
        static method create takes unit caster, real x, real y returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .targets = NewGroup()
            set .tempthis = this
            
            call DestroyEffect(AddSpecialEffect(EFFECT_LOC, x, y))
            call GroupEnumUnitsInRange( .targets, x, y, RADIUS, function thistype.group_filter_callback )
            call ForGroup( .targets, function thistype.onDamageTarget )
            
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set thistype.tempthis = 0
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local LifeVortex lv = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set lv = LifeVortex.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call MainSetup()
        call Preload(EFFECT_LOC)
        call Preload(EFFECT)
        
        set t = null
    endfunction

endscope