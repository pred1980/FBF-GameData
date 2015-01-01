scope Decapitate initializer init
    /*
     * Description: The Ogre performs a mighty attack with his Battle Axe, attempting to decapitate a target enemy. 
                    If the target is low on Health, this attack will instantly kill the target. 
                    There's a 50% chance to kill the target if it's a hero.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A09K'
        private constant attacktype ATT_TYPE = ATTACK_TYPE_MELEE
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_NORMAL
        private constant string DAMAGE_EFFECT = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl"
        private constant string DAMAGE_ATT_POINT = "overhead"
        private constant string KILL_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"
        private constant string KILL_ATT_POINT = "chest"
        
        private integer array HEALTH_CHECK
        private real array DAMAGE
        private constant integer CHANCE = 50
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

    private function damageTarget takes unit caster, unit target returns nothing
        local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
        
        if GetWidgetLife(target) <= HEALTH_CHECK[level] then
            if IsUnitType( target, UNIT_TYPE_HERO) then
                if GetRandomInt(1,100) <= CHANCE then
                    call DestroyEffect(AddSpecialEffectTarget(KILL_EFFECT, target, KILL_ATT_POINT))
                    call KillUnit(target)
                else
                    set DamageType = SPELL
                    call UnitDamageTarget(caster, target, DAMAGE[level], false, false, ATT_TYPE, DMG_TYPE, WEAPON_TYPE_WHOKNOWS)
                    call DestroyEffect(AddSpecialEffectTarget(DAMAGE_EFFECT, target, DAMAGE_ATT_POINT))
                endif
            else
                call DestroyEffect(AddSpecialEffectTarget(KILL_EFFECT, target, KILL_ATT_POINT))
                call KillUnit(target)
            endif
        else
            set DamageType = SPELL
            call UnitDamageTarget(caster, target, DAMAGE[level], false, false, ATT_TYPE, DMG_TYPE, WEAPON_TYPE_WHOKNOWS)
            call DestroyEffect(AddSpecialEffectTarget(DAMAGE_EFFECT, target, DAMAGE_ATT_POINT))
        endif
            
    endfunction

    private function Actions takes nothing returns nothing
        if( GetSpellAbilityId() == SPELL_ID )then
            call damageTarget( GetTriggerUnit(), GetSpellTargetUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call MainSetup()
        call Preload(DAMAGE_EFFECT)
        call Preload(KILL_EFFECT)
    endfunction

endscope