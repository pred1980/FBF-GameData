scope StompBlaster initializer init
    /*
     * Description: The Tauren Chieftain stomp the area, damaging and knock back nearby enemy units.
     * Last Update: 06.01.2014
     * Changelog: 
     *     06.01.2014: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A079'
        private constant real START_DAMAGE = 50
        private constant real DAMAGE_PER_LEVEL = 25
        private constant integer RADIUS = 300
        
        //Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = 1.0
        
        //KNOCK BACK
        private constant integer DISTANCE = 350
        private constant real KB_TIME = 0.85
    endglobals

    private struct StompBlaster
        unit caster
        integer num
        group targets
        static thistype tempthis
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitEnemy( GetFilterUnit(), GetOwningPlayer( .tempthis.caster ) ) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL)
        endmethod
        
        static method onKnockBack takes nothing returns nothing
            local unit u = GetEnumUnit()
            local real dmg = START_DAMAGE + (GetUnitAbilityLevel(.tempthis.caster, SPELL_ID) * DAMAGE_PER_LEVEL)
            local real x = GetUnitX(.tempthis.caster) - GetUnitX(u)
            local real y = GetUnitY(.tempthis.caster) - GetUnitY(u)
            local real ang = Atan2(y, x) - bj_PI
            
            call Stun_UnitEx(u, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            call Knockback.create(.tempthis.caster, u, DISTANCE, KB_TIME, ang, 0, "", "")
            
            set DamageType = SPELL
            call DamageUnitPhysical(.tempthis.caster, u, dmg)
            call GroupRemoveUnit(.tempthis.targets, u)
            if ( CountUnitsInGroup(.tempthis.targets) == 0 ) then
                call .tempthis.destroy()
            endif
            set u = null
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .targets = NewGroup()
            set .tempthis = this
            
            call GroupEnumUnitsInRange( .targets, GetUnitX(.caster), GetUnitY(.caster), RADIUS, function thistype.group_filter_callback )
            call ForGroup( .targets, function thistype.onKnockBack )
            
            return this
        endmethod

        static method onInit takes nothing returns nothing
            set thistype.tempthis = 0
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local StompBlaster sb = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set sb = StompBlaster.create( GetTriggerUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        
        set t = null
    endfunction

endscope