scope ReleaseMana initializer init
    /*
     * Description: The Destroyer uses all of his mana to unleash an energy wave around him that damages 
                    and slows every enemy it hits. The AoE depends on the amount of mana used.
     * Last Update: 14.11.2013
     * Changelog: 
     *     14.11.2013: Abgleich mit OE und der Exceltabelle
	 *     19.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
     */
    globals
        private constant integer SPELL_ID = 'A06Q'
        private constant integer DUMMY_ID = 'e00V'
        private constant integer DUMMY_SPELL_ID = 'A06P'
        private constant real DAMAGE = 240
        private constant string EFFECT_1 = "Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCaster.mdl"
        private constant string EFFECT_2 = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl"
    endglobals
    
    private struct ReleaseMana
        unit caster
        unit dummy
        group targets
        integer level = 0
        integer id = 0
        real ir = 0.00
        real step = 0.00
        real radius = 0.00
        real x = 0.00
        real y = 0.00
        static thistype tempthis
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .radius = GetUnitState(.caster, UNIT_STATE_MANA)
            set .step = 1440/.radius
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .targets = NewGroup()
            set .x = GetUnitX(.caster)
            set .y = GetUnitY(.caster)
            set .id = GetPlayerId(GetOwningPlayer(.caster))
            set .tempthis = this
            
            call DestroyEffect(AddSpecialEffect(EFFECT_1, .x, .y))
            call SetUnitState(.caster, UNIT_STATE_MANA, 0)
            call GroupEnumUnitsInRange( .targets, .x, .y, .radius, function thistype.group_filter_callback )
            call ForGroup( .targets, function thistype.onDamageTarget )
            
            loop
                exitwhen .ir >= 360
                call DestroyEffect(AddSpecialEffect(EFFECT_2, PolarProjectionX(.x, .radius, .ir), PolarProjectionY(.y, .radius, .ir)))
                set .ir = .ir + .step
            endloop
            
            call destroy()
            return this
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitEnemy( GetFilterUnit(), GetOwningPlayer( .tempthis.caster ) ) and not IsUnitDead(GetFilterUnit()) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL) and IsUnitType(GetFilterUnit(), UNIT_TYPE_GROUND)
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            
            set .tempthis.dummy = CreateUnit(Player(.tempthis.id), DUMMY_ID, .tempthis.x, .tempthis.y, 0)
            call UnitApplyTimedLife(.tempthis.dummy, 'BTLF', 12)
            call SetUnitAbilityLevel(.tempthis.dummy, DUMMY_SPELL_ID, .tempthis.level)
            call IssueTargetOrder(.tempthis.dummy, "slow", u)
            set DamageType = SPELL
            call DamageUnit(.tempthis.caster, u, I2R(.tempthis.level) * DAMAGE, true)
            call DestroyEffect(AddSpecialEffect(EFFECT_2, GetUnitX(u), GetUnitY(u)))
            call GroupRemoveUnit(.tempthis.targets, u)
            
            set u = null
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
            set .dummy = null
        endmethod
        
        static method onInit takes nothing returns nothing
            set .tempthis = 0
        endmethod
    endstruct
    
    private function Actions takes nothing returns nothing
        call ReleaseMana.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
		call TriggerAddCondition(t, Condition( function Conditions))
        call TriggerAddAction(t, function Actions)
        
		call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(EFFECT_1)
        call Preload(EFFECT_2)
		
		set t = null
    endfunction

endscope