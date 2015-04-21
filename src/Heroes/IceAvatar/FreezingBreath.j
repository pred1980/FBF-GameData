scope FreezingBreath initializer init
    /*
     * Description: Akulls foul, freezing breath chills the air to a sub zero level, 
	                slowing enemys movement and attack down.
     * Changelog: 
     *     27.10.2013: Abgleich mit OE und der Exceltabelle
	 *     20.03.2015: Optimized Spell-Event-Handling (Conditions/Actions) + 
	                   Spell-Immunity-Check in the "group_filter_callback method"
	 *     17.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for damaging and filtering
					   Code Refactoring
     *
     */
    globals
        private constant integer SPELL_ID = 'A04K'
        private constant integer DUMMY_ID = 'e00Q'
        private constant integer DEBUF_ID = 'A04L'
        private constant string EFFECT = "Models\\AnthraxBetaBomb.mdx"
        private constant real RADIUS = 350
        private constant real DAMAGE_PER_LEVEL = 10
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_COLD
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals

    private struct FreezingBreath
        unit caster
        group targets
        integer level = 0
        static thistype tempthis = 0
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            local unit u = GetFilterUnit()
            local unit d = null
			
			if (SpellHelper.isValidEnemy(u, .tempthis.caster)) then
				set DamageType = SPELL
				call SpellHelper.damageTarget(.tempthis.caster, u, DAMAGE_PER_LEVEL * .tempthis.level, false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
				
				set d = CreateUnit(GetOwningPlayer(.tempthis.caster), DUMMY_ID, GetUnitX(u), GetUnitY(u), GetUnitFacing(u))
				call UnitAddAbility(d, DEBUF_ID)
				call SetUnitAbilityLevel(d, DEBUF_ID, .tempthis.level)
				call IssueTargetOrder(d, "frostnova", u)
				call UnitApplyTimedLife(d, 'BTLF', 1)
            endif
            //clean
            set d = null
            set u = null
			
            return false
        endmethod
        
        static method create takes unit c, real tx, real ty returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = c
            set .targets = NewGroup()
            set .level = GetUnitAbilityLevel(c, SPELL_ID)
            
            set .tempthis = this
            call GroupEnumUnitsInRange( .targets, tx, ty, RADIUS, function thistype.group_filter_callback )
            call DestroyEffect(AddSpecialEffect(EFFECT,tx,ty))
            call destroy()
			
            return this
        endmethod
    endstruct

	private function Actions takes nothing returns nothing
        call FreezingBreath.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() )
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call XE_PreloadAbility(DEBUF_ID)
        call Preload(EFFECT)
    endfunction

endscope