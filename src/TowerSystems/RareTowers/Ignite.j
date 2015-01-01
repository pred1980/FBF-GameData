library Ignite uses DamageEvent, BonusMod
    /*
     * Description: The tower has a 30% chance on damaging a creep to ignite the target, dealing 15%/20%/25% of the tower's 
                    attack damage as spell damage per second and reducing the target' s health regeneration 
                    by 25%/30%/35% for 8 seconds.
     * Last Update: 20.12.2013
     * Changelog: 
     *     20.12.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
        // Ability Id of the ignite skill (based on bash)
        private constant integer IGNITE_ABILITY = 'A074'
        
        // Percentual periodic damage on level 1
        private constant real LEVEL_1_DAMAGE_PERCENT = 0.15
        
        // Percentual periodic damage on level 2
        private constant real LEVEL_2_DAMAGE_PERCENT = 0.20
        
        // Percentual periodic damage on level 3
        private constant real LEVEL_3_DAMAGE_PERCENT = 0.25
        
        // Percentual decrease of the life regeneration on level 1
        private constant real LEVEL_1_HEALTH_PERCENT = 0.25
        
        // Percentual decrease of the life regeneration on level 2
        private constant real LEVEL_2_HEALTH_PERCENT = 0.30
        
        // Percentual decrease of the life regeneration on level 3
        private constant real LEVEL_3_HEALTH_PERCENT = 0.35
        
        // Period of the timer callback when a unit is burning
        private constant real TIMER_PERIOD = 1.0
        
        // Total time how long a unit should burn
        private constant real TOTAL_TIME = 8.0
        
        // Percentual chance to ignite an enemy (default 30%)
        private constant real CHANCE_TO_HIT = 0.3
        
        // Path to the special effect of the spell
        private constant string IGNITE_SPECIAL_EFFECT = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl"
        
        // On which attachment point should the special effect be attached
        private constant string IGNITE_SPECIAL_ATTACH = "chest"
        
        private hashtable ht = InitHashtable()
    endglobals

    private struct Ignite extends array
        private static boolean ignite_flag = false
        
        private static method callback takes nothing returns nothing
            local integer id = GetHandleId(GetExpiredTimer())
            local unit source = LoadUnitHandle(ht, id, 0)
            local unit target = LoadUnitHandle(ht, id, 1)
            local real amount = LoadReal(ht, id, 2)
            local integer level = LoadInteger(ht, id, 3)
            local real timeExpired = LoadReal(ht, id, 4) + TIMER_PERIOD
            local integer healthMalus = LoadInteger(ht, id, 6)
            
            if timeExpired > TOTAL_TIME then
                call DestroyTimer(GetExpiredTimer())
                call DestroyEffect(LoadEffectHandle(ht, id, 5))
                call RemoveUnitBonus(target, BONUS_LIFE_REGEN)
                call FlushChildHashtable(ht, id)
                call FlushChildHashtable(ht, GetHandleId(target))
                set source = null
                set target = null
            else
                
                call SaveReal(ht, id, 4, timeExpired)
                set ignite_flag = true
                set DamageType = SPELL
                if level == 1 then
                    call UnitDamageTarget(source, target, LEVEL_1_DAMAGE_PERCENT*amount, true, false, null, DAMAGE_TYPE_UNIVERSAL, null)
                elseif level == 2 then
                    call UnitDamageTarget(source, target, LEVEL_2_DAMAGE_PERCENT*amount, true, false, null, DAMAGE_TYPE_UNIVERSAL, null)
                elseif level == 3 then
                    call UnitDamageTarget(source, target, LEVEL_3_DAMAGE_PERCENT*amount, true, false, null, DAMAGE_TYPE_UNIVERSAL, null)
                endif
            endif
        endmethod
        
        static method onDamage takes unit damagedUnit, unit damageSource, real damage returns nothing
            local real rand 
            local timer time
            local integer id
            local integer unitId
            local integer level
            local integer healthRegen
            local integer healthMalus
            local effect eff
            
            if ignite_flag then
                set ignite_flag = false
                return
            endif
            
            if IsUnitType(damagedUnit, UNIT_TYPE_STRUCTURE) or not IsUnitEnemy(damagedUnit, GetOwningPlayer(damageSource)) then
                return
            endif
            
            set rand = GetRandomReal(0.0, 1.0)
            
            if rand > CHANCE_TO_HIT then
                return
            endif
            
            set unitId = GetHandleId(damagedUnit)
            set level = GetUnitAbilityLevel(damageSource, IGNITE_ABILITY)
            
            if level > 0 and not LoadBoolean(ht, unitId, 0) then
                set rand = GetRandomReal(0.0, 1.0)
                set time = CreateTimer()
                set id = GetHandleId(time)

                set eff = AddSpecialEffectTarget(IGNITE_SPECIAL_EFFECT, damagedUnit, IGNITE_SPECIAL_ATTACH)
                
                if level == 1 then
                    set healthMalus = R2I(LEVEL_1_HEALTH_PERCENT)
                elseif level == 2 then
                    set healthMalus = R2I(LEVEL_2_HEALTH_PERCENT)
                elseif level == 3 then
                    set healthMalus = R2I(LEVEL_3_HEALTH_PERCENT)
                endif
                
                call AddUnitBonus(damagedUnit, BONUS_LIFE_REGEN, -healthMalus)
                
                call SaveUnitHandle(ht, id, 0, damageSource)
                call SaveUnitHandle(ht, id, 1, damagedUnit)
                call SaveReal(ht, id, 2, damage)
                call SaveInteger(ht, id, 3, level)
                call SaveEffectHandle(ht, id, 5, eff)
                call SaveInteger(ht, id, 6, healthMalus)
                call SaveBoolean(ht, unitId, 0, true)
                
                call TimerStart(time, TIMER_PERIOD, true, function thistype.callback)
                
                set eff = null
            endif
            
            call SaveReal(ht, id, 4, 0.0)
        endmethod
        
        private static method onInit takes nothing returns nothing
            call RegisterDamageResponse(thistype.onDamage)
            call Preload(IGNITE_SPECIAL_EFFECT)
        endmethod
    
    endstruct
    
endlibrary