scope Decapitate initializer init
    /*
     * Description: The Ogre performs a mighty attack with his Battle Axe, attempting to decapitate a target enemy. 
                    If the target is low on Health, this attack will instantly kill the target. 
                    Theres a 50% chance to kill the target if its a hero.
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
	 *     24.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for filtering and damaging
     */
    globals
        private constant integer SPELL_ID = 'A09K'
        private constant string DAMAGE_EFFECT = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl"
        private constant string DAMAGE_ATT_POINT = "overhead"
        private constant string KILL_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"
        private constant string KILL_ATT_POINT = "chest"
		private constant integer CHANCE = 50
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
        private integer array HEALTH_CHECK
        private real array DAMAGE
        
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set HEALTH_CHECK[1] = 200
        set HEALTH_CHECK[2] = 300
        set HEALTH_CHECK[3] = 400
        set HEALTH_CHECK[4] = 500
        set HEALTH_CHECK[5] = 600
        
        set DAMAGE[1] = 150
        set DAMAGE[2] = 200
        set DAMAGE[3] = 250
        set DAMAGE[4] = 300
        set DAMAGE[5] = 350
    endfunction

    private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local unit target = GetSpellTargetUnit()
		local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
        
        if GetWidgetLife(target) <= HEALTH_CHECK[level] then
            if IsUnitType( target, UNIT_TYPE_HERO) then
                if GetRandomInt(1,100) <= CHANCE then
                    call DestroyEffect(AddSpecialEffectTarget(KILL_EFFECT, target, KILL_ATT_POINT))
                    call KillUnit(target)
                else
					call DestroyEffect(AddSpecialEffectTarget(DAMAGE_EFFECT, target, DAMAGE_ATT_POINT))
                endif
            else
                call DestroyEffect(AddSpecialEffectTarget(KILL_EFFECT, target, KILL_ATT_POINT))
                call KillUnit(target)
            endif
        else
			call DestroyEffect(AddSpecialEffectTarget(DAMAGE_EFFECT, target, DAMAGE_ATT_POINT))
        endif
		
		set DamageType = PHYSICAL
		call SpellHelper.damageTarget(caster, target, DAMAGE[level], true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
		
        set caster = null
		set target = null
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call MainSetup()
        call Preload(DAMAGE_EFFECT)
        call Preload(KILL_EFFECT)
    endfunction

endscope