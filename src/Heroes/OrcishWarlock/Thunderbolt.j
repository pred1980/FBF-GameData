scope Thunderbolt initializer init
    /*
     * Description: After channeling 1 second, a lightning strike comes down somewhere in an 200 AoE around the target point, 
                    damaging all units around it.
     * Last Update: 08.01.2014
     * Changelog: 
     *     08.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A07T'
        private constant string BOLT_EFFECT = "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl"
        private constant string HIT_EFFECT = "Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl"
        private constant real AoA = 200.0 //Radius of the area where the bolt could come down
        private constant real AoE = 150.0 //Radius of the bolt damage
        private constant real DAMAGE_START = 100 //damage on level 0
        private constant real DAMAGE_INCREASE = 200.0 //additional damage on every level
    endglobals

    private struct Thunderbolt
        unit caster
        integer level = 0
        real damage
        real x
        real y
        group targets
        static thistype tempthis
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return not IsUnitDead(GetFilterUnit())
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            call DestroyEffect(AddSpecialEffectTarget(HIT_EFFECT, u, "origin"))
            set DamageType = SPELL
            call UnitDamageTarget(.tempthis.caster, u, .tempthis.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING,WEAPON_TYPE_WHOKNOWS)
            set u = null
        endmethod
        
        static method create takes unit caster, real x, real y returns thistype
            local thistype this = thistype.allocate()
            local real angle = 0.00
            local real radius = 0.00
            
            set .caster = caster
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .targets = NewGroup()
            set angle = GetRandomReal(-bj_PI,bj_PI)
            set radius = GetRandomReal(0, AoA)
            set .x = x + Sin(angle) * radius
            set .y = y + Cos(angle) * radius
            set .damage = DAMAGE_START + DAMAGE_INCREASE * .level
            set .tempthis = this
            
            call DestroyEffect(AddSpecialEffect(BOLT_EFFECT, .x, .y))
            call GroupEnumUnitsInRange( .targets, .x, .y, AoE, function thistype.group_filter_callback )
            call ForGroup(.targets, function thistype.onDamageTarget)
            
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set thistype.tempthis = 0
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local Thunderbolt t = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set t = Thunderbolt.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call Preload(BOLT_EFFECT)
        call Preload(HIT_EFFECT)
        
        set t = null
    endfunction

endscope