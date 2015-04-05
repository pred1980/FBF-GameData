scope ReleaseMana initializer init
    /*
     * Description: The Destroyer uses all of his mana to unleash an energy wave around him that damages 
                    and slows every enemy it hits. The AoE depends on the amount of mana used.
     * Last Update: 14.11.2013
     * Changelog: 
     *      14.11.2013: Abgleich mit OE und der Exceltabelle
	 *      19.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     	03.04.2015: Integrated RegisterPlayerUnitEvent
	                    Integrated SpellHelper for filtering and damaging
     */
    globals
        private constant integer SPELL_ID = 'A06Q'
        private constant integer DUMMY_ID = 'e00V'
        private constant integer DUMMY_SPELL_ID = 'A06P'
        private constant real DAMAGE = 240
        private constant string EFFECT_1 = "Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCaster.mdl"
        private constant string EFFECT_2 = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl"
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_SONIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
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
        static thistype tempthis = 0
		
		method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
            set .dummy = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), .tempthis.caster)
		endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            
            set .tempthis.dummy = CreateUnit(Player(.tempthis.id), DUMMY_ID, .tempthis.x, .tempthis.y, 0)
            call UnitApplyTimedLife(.tempthis.dummy, 'BTLF', 12)
            call SetUnitAbilityLevel(.tempthis.dummy, DUMMY_SPELL_ID, .tempthis.level)
            call IssueTargetOrder(.tempthis.dummy, "slow", u)
            
			set DamageType = SPELL
			call SpellHelper.damageTarget(.tempthis.caster, u, I2R(.tempthis.level) * DAMAGE, false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            call DestroyEffect(AddSpecialEffect(EFFECT_2, GetUnitX(u), GetUnitY(u)))
            call GroupRemoveUnit(.tempthis.targets, u)
            
            set u = null
        endmethod

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
    endstruct
    
    private function Actions takes nothing returns nothing
        call ReleaseMana.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
		call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(EFFECT_1)
        call Preload(EFFECT_2)
    endfunction

endscope