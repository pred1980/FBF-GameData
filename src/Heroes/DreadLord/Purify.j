scope Purify initializer init
     /*
     * Description: Tristan heals a friendly unit and removes negative buffs or, 
                    he damages an enemy unit and removes positive buffs. It deals bonus damage to summons.
     * Changelog: 
     *     18.11.2013: Abgleich mit OE und der Exceltabelle
	 *     19.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     05.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for filtering and damaging
     */
    globals
        private constant integer SPELL_ID = 'A06T'
        private constant integer DUMMY_SPELL_ID = 'A06U'
        private constant integer DUMMY_ID = 'e00X'
        private constant string ALLY_EFFECT = "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl" //Effect displayed on Allies when cast
        private constant string FOE_EFFECT = "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl" //Effect displayed on Enemies when cast
        private constant string SUMMON_EFFECT= "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl" //Effect displayed on enemy summons when cast
        
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
		private real array ALLY_HEAL
        private real array ENEMY_DMG
        private real array SUMMON_DMG
    endglobals

    private function MainSetup takes nothing returns nothing 
        set ALLY_HEAL[0] = 140
        set ALLY_HEAL[1] = 280
        set ALLY_HEAL[2] = 420
        set ALLY_HEAL[3] = 560
        set ALLY_HEAL[4] = 700
        
        set ENEMY_DMG[0] = 50
        set ENEMY_DMG[1] = 100
        set ENEMY_DMG[2] = 150
        set ENEMY_DMG[3] = 200
        set ENEMY_DMG[4] = 250
        
        set SUMMON_DMG[0] = 150
        set SUMMON_DMG[1] = 300
        set SUMMON_DMG[2] = 450
        set SUMMON_DMG[3] = 600
        set SUMMON_DMG[4] = 750
    endfunction
  
    private struct Purify
        
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            local unit dummy
            local integer level = GetUnitAbilityLevel(caster, SPELL_ID) - 1
            
            set dummy = CreateUnit(GetOwningPlayer(caster), DUMMY_ID, GetUnitX(target), GetUnitY(target), GetUnitFacing(target))
            call UnitAddAbility(dummy, DUMMY_SPELL_ID)
            call IssueTargetOrder(dummy, "autodispel", target)
            call UnitApplyTimedLife(dummy, 'BTLF', 1.0)
            
            if (SpellHelper.isValidAlly(target, caster)) then
                call DestroyEffect(AddSpecialEffectTarget(ALLY_EFFECT, target, "origin"))
                call SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + ALLY_HEAL[level])
                return this
            endif
            
            if IsUnitType(target, UNIT_TYPE_SUMMONED) then
				set DamageType = SPELL
				call SpellHelper.damageTarget(caster, target, SUMMON_DMG[level], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                call DestroyEffect(AddSpecialEffectTarget(SUMMON_EFFECT, target, "origin"))
                return this
            endif
			
			set DamageType = SPELL
			call SpellHelper.damageTarget(caster, target, ENEMY_DMG[level], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)

            call DestroyEffect(AddSpecialEffectTarget(FOE_EFFECT, target, "origin"))
            
            set dummy = null
            return this
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        call Purify.create(GetTriggerUnit(), GetSpellTargetUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
        call MainSetup()
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(ALLY_EFFECT)
        call Preload(FOE_EFFECT)
        call Preload(SUMMON_EFFECT)
    endfunction
endscope