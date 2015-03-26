scope ExplosivTantrum initializer init
    /*
     * Description: Mundzuk orders Octar to thrust with his horn, damaging and knocking its target back.
     * Changelog: 
     *     25.10.2013: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     26.03.2015: Integrated RegisterPlayerUnitEvent
	                   Code refactoring
     *
     */
    globals
        private constant integer SPELL_ID = 'A01L'
        private constant real START_DAMAGE = 25
        private constant real DAMAGE_PER_LEVEL = 75
        private constant string EFFECT = "Abilities\\Spells\\Human\\FlakCannons\\FlakTarget.mdl"
        private constant string ATT_POINT = "origin"
                
        //KNOCK BACK
        private constant integer DISTANCE = 400
        private constant real KB_TIME = 0.85
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_METAL_HEAVY_BASH
    endglobals
    
    private function Actions takes nothing returns nothing
		local unit source = GetTriggerUnit()
		local unit target = GetSpellTargetUnit()
		local integer level = GetUnitAbilityLevel(source, SPELL_ID)
		local real x = GetUnitX(source) - GetUnitX(target)
        local real y = GetUnitY(source) - GetUnitY(target)
		local real ang = Atan2(y, x) - bj_PI
		local real dmg = START_DAMAGE + (level * DAMAGE_PER_LEVEL)
		
		set DamageType = PHYSICAL
		call SpellHelper.damageTarget(source, target, dmg, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
		call DestroyEffect(AddSpecialEffectTarget(EFFECT,target, ATT_POINT))
		call Knockback.create(source, target, DISTANCE, KB_TIME, ang, 0, "", "")
	
		set source = null
		set target = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call Preload(EFFECT)
    endfunction

endscope