scope NightAura initializer init
    /*
     * Description: The mighty aura of the Priestess of the Moon surrounds friendly units and gives a 20% chance to reflect 
                    a part of the damage back to the attacker. If the unit dies, 15% of its mana is released and fills 
                    up the mana of the attacker.
     * Last Update: 07.01.2014
     * Changelog: 
     *     07.01.2014: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A07G'
        private constant integer BUFF_ID = 'B017'
        private constant integer CHANCE = 20
        private constant integer STEAL = 15
        private constant string MANA_STEAL = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl"
        private constant string MANA_FILL = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        private constant string ATT_POINT = "overhead"
        private constant integer RADIUS = 800
        
        private integer array REFLECT_DAMAGE
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set REFLECT_DAMAGE[1] = 10
        set REFLECT_DAMAGE[2] = 20
        set REFLECT_DAMAGE[3] = 30
        set REFLECT_DAMAGE[4] = 40
        set REFLECT_DAMAGE[5] = 50
    endfunction
    
    private struct NightAura
        integer level = 1
        group g
        static thistype tempthis
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(.g)
            set .g = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return GetUnitAbilityLevel(GetFilterUnit(), SPELL_ID) > 0
        endmethod
        
        static method onUpdateLevel takes nothing returns nothing
            set .tempthis.level = GetUnitAbilityLevel(GetEnumUnit(), SPELL_ID)
        endmethod
        
        static method create takes unit attacker, unit target, real damage returns thistype
            local thistype this = thistype.allocate()
            local real dmg = 0.00
            local real mana = 0.00
            
            set .tempthis = this
            //get Aura Level by finding the PotM and her current Ability Level
            set .g = NewGroup()
            call GroupEnumUnitsInRange( .g, GetUnitX(target), GetUnitY(target), RADIUS, function thistype.group_filter_callback )
            call ForGroup( .g, function thistype.onUpdateLevel )
            
            //Damage
            set dmg = damage * ( I2R((.level * REFLECT_DAMAGE[.level])) / 100.0 )
            if GetUnitState(attacker, UNIT_STATE_LIFE) > dmg then
                set DamageType = SPELL
                call DamageUnitPhysical(target, attacker, dmg)
            else
                if GetUnitState(attacker, UNIT_STATE_MAX_MANA) > 0 and GetUnitState(target, UNIT_STATE_MAX_MANA) > 0 then
                    set mana = (GetUnitState(target, UNIT_STATE_MANA) * STEAL) / 100
                    call SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + mana)
                    call DestroyEffect(AddSpecialEffectTarget(MANA_STEAL, attacker, ATT_POINT))
                    call DestroyEffect(AddSpecialEffectTarget(MANA_FILL, target, ATT_POINT))
                endif
                call SetUnitExploded(attacker, true)
                call KillUnit(attacker)
            endif
            
            call destroy()
            return this
        endmethod
       
        static method onInit takes nothing returns nothing
            set thistype.tempthis = 0
        endmethod
        
    endstruct

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local NightAura na = 0
         
        if ( GetUnitAbilityLevel(damagedUnit, BUFF_ID) > 0 and GetRandomInt(1, 100) <= CHANCE and IsUnitEnemy(damagedUnit, GetOwningPlayer(damageSource)) and DamageType == PHYSICAL ) then
            set na = NightAura.create(damageSource, damagedUnit, damage)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call MainSetup()
        call Preload(MANA_STEAL)
        call Preload(MANA_FILL)
    endfunction

endscope