scope UltimateFighter
    /*
     * The Tower uses his great power to specialize his attacks:
        - Every 3rd/4rd/5rd attack is a critical hit
        - Every 7th/8th/9th attack deals 1000/1500/2000 bonus spell damage
        - Every 12th/13th/14th attack stuns the target for 1/1.25/1.5 second
        - Every 15th/16th/17th attack adds 0.5% attack damage permanently
     */
     
    private keyword UltimateFighter
    
    globals
        private constant integer CRIT_PROC_LEVEL1 = 3
        private constant integer CRIT_PROC_LEVEL2 = 4
        private constant integer CRIT_PROC_LEVEL3 = 5
        private constant integer SPELL_PROC_LEVEL1 = 7
        private constant integer SPELL_PROC_LEVEL2 = 8
        private constant integer SPELL_PROC_LEVEL3 = 9
        private constant integer STUN_PROC_LEVEL1 = 12
        private constant integer STUN_PROC_LEVEL2 = 13
        private constant integer STUN_PROC_LEVEL3 = 14
        private constant integer BONUS_PROC_LEVEL1 = 15
        private constant integer BONUS_PROC_LEVEL2 = 16
        private constant integer BONUS_PROC_LEVEL3 = 17
        private constant real CRIT_BONUS_LEVEL1 = 1.
        private constant real CRIT_BONUS_LEVEL2 = 1.5
        private constant real CRIT_BONUS_LEVEL3 = 2.
        private constant real SPELL_DAMAGE_LEVEL1 = 1000.
        private constant real SPELL_DAMAGE_LEVEL2 = 1500.
        private constant real SPELL_DAMAGE_LEVEL3 = 2000.
        private constant real STUN_DURATION_LEVEL1 = 1.
        private constant real STUN_DURATION_LEVEL2 = 1.25
        private constant real STUN_DURATION_LEVEL3 = 1.5
        private constant real PERM_DAMAGE_BONUS_MULTIPLIER = .005
        private constant integer array TOWER_TYP
        private UltimateFighter array ultimateFighterForUnit
        
        private group grp = CreateGroup()
        private HandleTable towers
        
        //Stun Effect
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        
        //Bonus Spell Damage
        private constant string SPELL_EFFECT = "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl"
        
        //Attack Damage Permanently
        private constant string ATTACK_DAMAGE_EFFECT = "Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl"
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set TOWER_TYP[0] = 'u01M'
        set TOWER_TYP[1] = 'u01R'
        set TOWER_TYP[2] = 'u01T'
    endfunction
    
    private struct UltimateFighter
        integer critCounter = 0
        integer spellDCounter = 0
        integer stunCounter = 0
        integer bonusPCounter = 0
        
        static method getForUnit takes unit u returns thistype
            return ultimateFighterForUnit[GetUnitId(u)]
		endmethod
        
        static method create takes unit damageSource returns thistype
            local thistype this = thistype.allocate()
            
            set ultimateFighterForUnit[GetUnitId(damageSource)] = this
            
            return this
        endmethod
        
        method onAttack takes unit damagedUnit, unit damageSource, real damage returns nothing
		    local integer i = 0
            local integer level
            local thistype t = getForUnit(damageSource)
            
            if DamageType == PHYSICAL and  IsUnitEnemy(damagedUnit, GetOwningPlayer(damageSource)) then
                loop
                    exitwhen i > 2
                    if GetUnitTypeId(damageSource) == TOWER_TYP[i] then
                        set level = i + 1
                        if level > 0 then
                            set damage = damage
                            set t.critCounter = t.critCounter + 1
                            set t.spellDCounter = t.spellDCounter + 1
                            set t.stunCounter = t.stunCounter + 1
                            set t.bonusPCounter = t.bonusPCounter + 1
                            if level == 1 then
                                if t.critCounter >= CRIT_PROC_LEVEL1 then
                                    call TextTagCriticalStrike(damagedUnit, R2I(damage*CRIT_BONUS_LEVEL1))
                                    set DamageType = SPELL
                                    call UnitDamageTarget(damageSource, damagedUnit, damage*CRIT_BONUS_LEVEL1, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                                    set t.critCounter = 0
                                endif
                                if t.spellDCounter >= SPELL_PROC_LEVEL1 then
                                    call DestroyEffect(AddSpecialEffect(SPELL_EFFECT, GetUnitX(damagedUnit), GetUnitY(damagedUnit)))
                                    set DamageType = SPELL
                                    call UnitDamageTarget(damageSource, damagedUnit, SPELL_DAMAGE_LEVEL1, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                                    set t.spellDCounter = 0
                                endif
                                if t.stunCounter >= STUN_PROC_LEVEL1 then
                                    call Stun_UnitEx(damagedUnit, STUN_DURATION_LEVEL1, false, STUN_EFFECT, STUN_ATT_POINT)
                                    set t.stunCounter = 0
                                endif
                                if t.bonusPCounter>=BONUS_PROC_LEVEL1 then
                                    call DestroyEffect(AddSpecialEffect(ATTACK_DAMAGE_EFFECT, GetUnitX(damagedUnit), GetUnitY(damagedUnit)))
                                    call AddUnitBonus(damageSource, BONUS_DAMAGE,IMaxBJ(1,R2I(damage*PERM_DAMAGE_BONUS_MULTIPLIER)))
                                    set t.bonusPCounter=0
                                endif
                            elseif level == 2 then
                                if t.critCounter >= CRIT_PROC_LEVEL2 then
                                    call TextTagCriticalStrike(damagedUnit, R2I(damage*CRIT_BONUS_LEVEL2))
                                    set DamageType = SPELL
                                    call UnitDamageTarget(damageSource, damagedUnit, damage*CRIT_BONUS_LEVEL2, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                                    set t.critCounter = 0
                                endif
                                if t.spellDCounter >= SPELL_PROC_LEVEL2 then
                                    set DamageType = SPELL
                                    call UnitDamageTarget(damageSource, damagedUnit, SPELL_DAMAGE_LEVEL2, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                                    set t.spellDCounter = 0
                                endif
                                if t.stunCounter >= STUN_PROC_LEVEL2 then
                                    call Stun_UnitEx(damagedUnit, STUN_DURATION_LEVEL2, false, STUN_EFFECT, STUN_ATT_POINT)
                                    set t.stunCounter = 0
                                endif
                                if t.bonusPCounter>=BONUS_PROC_LEVEL2 then
                                    call DestroyEffect(AddSpecialEffect(ATTACK_DAMAGE_EFFECT, GetUnitX(damagedUnit), GetUnitY(damagedUnit)))
                                    call AddUnitBonus(damageSource, BONUS_DAMAGE,IMaxBJ(1,R2I(damage*PERM_DAMAGE_BONUS_MULTIPLIER)))
                                    set t.bonusPCounter=0
                                endif
                            elseif level == 3 then
                                if t.critCounter >= CRIT_PROC_LEVEL3 then
                                    call TextTagCriticalStrike(damagedUnit, R2I(damage*CRIT_PROC_LEVEL3))
                                    set DamageType = SPELL
                                    call UnitDamageTarget(damageSource, damagedUnit, damage*CRIT_BONUS_LEVEL3, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                                    set t.critCounter = 0
                                endif
                                if t.spellDCounter >= SPELL_PROC_LEVEL3 then
                                    set DamageType = SPELL
                                    call UnitDamageTarget(damageSource, damagedUnit, SPELL_DAMAGE_LEVEL3, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                                    set t.spellDCounter = 0
                                endif
                                if t.stunCounter >= STUN_PROC_LEVEL3 then
                                    call Stun_UnitEx(damagedUnit, STUN_DURATION_LEVEL3, false, STUN_EFFECT, STUN_ATT_POINT)
                                    set t.stunCounter = 0
                                endif
                                if t.bonusPCounter >= BONUS_PROC_LEVEL3 then
                                    call DestroyEffect(AddSpecialEffect(ATTACK_DAMAGE_EFFECT, GetUnitX(damagedUnit), GetUnitY(damagedUnit)))
                                    call AddUnitBonus(damageSource, BONUS_DAMAGE,IMaxBJ(1,R2I(damage*PERM_DAMAGE_BONUS_MULTIPLIER)))
                                    set t.bonusPCounter=0
                                endif
                            endif
                        endif
                    endif
                    set i = i + 1
                endloop
            endif
		endmethod
        
        static method onDamage takes unit damagedUnit, unit damageSource, real damage returns nothing
            local thistype uf = 0
            
            if GetUnitTypeId(damageSource) == TOWER_TYP[0] or GetUnitTypeId(damageSource) == TOWER_TYP[1] or GetUnitTypeId(damageSource) == TOWER_TYP[2] then
                set uf = thistype.getForUnit(damageSource)
                if uf == null then
                    set uf = thistype.create(damageSource)
                else
                   call uf.onAttack(damagedUnit, damageSource, damage)
                endif
            endif
        endmethod
        
        static method onInit takes nothing returns nothing
            call RegisterDamageResponse(thistype.onDamage)
            call MainSetup()
        endmethod
		
    endstruct

endscope