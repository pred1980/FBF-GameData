scope ArcaneSwap initializer init
    /*
     * Description: Gundagar restores mana to an enemy but damages his health for the same amount. 
                    The target is damaged by half the spell cost if it has no mana.
     * Last Update: 12.11.2013
     * Changelog: 
     *     12.11.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A06N'
        private constant string EFFECT_1 = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        private constant string EFFECT_2 = "Abilities\\Spells\\Items\\AIvi\\AIviTarget.mdl"
        private constant string ATT_POINT = "overhead"
        
        // Falls das Target kein Mana hat, wird die Hälfte vom Mana, den der Spell hat als Damage wenigstens ausgeteilt
        private real array damage 
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set damage[1] = 60
        set damage[2] = 75
        set damage[3] = 90
        set damage[4] = 105
        set damage[5] = 120
    endfunction
    
    private struct ArcaneSwap
        
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            local integer level = 0
            local real amount = 0.00
            
            set level = GetUnitAbilityLevel(caster, SPELL_ID)
            set amount = RMinBJ(I2R(level) * 100, GetUnitState(target, UNIT_STATE_MAX_MANA) - GetUnitState(target, UNIT_STATE_MANA))
            call SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target,UNIT_STATE_MANA) + amount)
            
            set DamageType = SPELL
            //Hat das Target überhaupt Mana oder ist es z.b. ein Soldat der sowieso kein Mana hat?
            //Ja hat es...
            if GetUnitStateSwap(UNIT_STATE_MAX_MANA, target) > 0.00 then
                call DamageUnit(caster, target, amount, true)
            else //Nein hat es nicht...
                call DamageUnit(caster, target, damage[level], true)
            endif
            call DestroyEffect(AddSpecialEffectTarget(EFFECT_1, target, ATT_POINT))
            call DestroyEffect(AddSpecialEffectTarget(EFFECT_2, target, ATT_POINT))
        
            return this
        endmethod
    endstruct
    
    private function Actions takes nothing returns nothing
        local ArcaneSwap as = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set as = ArcaneSwap.create( GetTriggerUnit(), GetSpellTargetUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call MainSetup()
        call Preload(EFFECT_1)
        call Preload(EFFECT_2)
    endfunction

endscope