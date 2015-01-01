scope ManaSteal initializer init
    /*
     * Description: Everytime Gundagar attacks a unit, he has a 25% chance to absorbs its mana. 
                    But he cannot absorb more mana than what the target has.
     * Last Update: 14.11.2013
     * Changelog: 
     *     14.11.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A06R'
        private constant integer BUFF_ID = 'B010'
        private constant string EFFECT = "Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl"
        private constant string ATT_POINT = "overhead"
        private constant integer MULTIPLIER = 20
        private constant integer CHANCE = 25
    endglobals
    
    private struct ManaSteal
        
        static method create takes unit attacker, unit target returns thistype
            local thistype this = thistype.allocate()
            local integer level = 0
            local real mana = 0.00
            local real amount = 0.00
            
            set mana = GetUnitState(target, UNIT_STATE_MANA)
            set level = GetUnitAbilityLevel(attacker, SPELL_ID)
            
            if (level * MULTIPLIER) < mana then
                set amount = I2R(level) * MULTIPLIER
            else
                set amount = mana
            endif
            
            call SetUnitState(attacker, UNIT_STATE_MANA, GetUnitState(attacker, UNIT_STATE_MANA) + amount)
            call SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) - (level * MULTIPLIER ))
            call DestroyEffect(AddSpecialEffectTarget(EFFECT, target, ATT_POINT))
            
            return this
        endmethod
        
    endstruct
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local ManaSteal ms = 0
        
        if ( GetUnitAbilityLevel(damageSource, BUFF_ID) > 0 and /*
        */   IsUnitEnemy(damagedUnit, GetOwningPlayer(damageSource)) and /*
        */   DamageType == 0 and /*
        */   GetRandomInt(1, 100) <= CHANCE ) and /*
        */   GetUnitStateSwap(UNIT_STATE_MAX_MANA, damagedUnit) > 0 then
                 set ms = ManaSteal.create(damageSource, damagedUnit)
        endif
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call Preload(EFFECT)
    endfunction

endscope