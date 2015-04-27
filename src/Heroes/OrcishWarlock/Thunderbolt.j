scope Thunderbolt initializer init
    /*
     * Description: After channeling 1 second, a lightning strike comes down somewhere in an 200 AoE around the target point, 
                    damaging all units around it.
     * Changelog: 
     *     	08.01.2014: Abgleich mit OE und der Exceltabelle
	 *		27.04.2015: Integrated RegisterPlayerUnitEvent
						Integrated SpellHelper for filtering and damaging
						Changed AttackType from NORMAL to MAGIC
						Removed "Ally" from targets of this ability
     */
    globals
        private constant integer SPELL_ID = 'A07T'
        private constant string BOLT_EFFECT = "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl"
        private constant string HIT_EFFECT = "Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl"
        private constant real AoA = 200.0 //Radius of the area where the bolt could come down
        private constant real AoE = 150.0 //Radius of the bolt damage
        private constant real DAMAGE_START = 100 //damage on level 0
        private constant real DAMAGE_INCREASE = 200.0 //additional damage on every level
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_LIGHTNING
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals

    private struct Thunderbolt
        private unit caster
        private integer level = 0
        private real damage
        private real x
        private real y
        private group targets
        private static thistype tempthis = 0
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return SpellHelper.isValidEnemy(GetFilterUnit(), .tempthis.caster)
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            call DestroyEffect(AddSpecialEffectTarget(HIT_EFFECT, u, "origin"))
            set DamageType = SPELL
			call SpellHelper.damageTarget(.tempthis.caster, u, .tempthis.damage, false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
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
            call GroupEnumUnitsInRange(.targets, .x, .y, AoE, function thistype.group_filter_callback)
            call ForGroup(.targets, function thistype.onDamageTarget)
            
            return this
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call Thunderbolt.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
	endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call Preload(BOLT_EFFECT)
        call Preload(HIT_EFFECT)
    endfunction

endscope