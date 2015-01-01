scope GodsSeal initializer init
    /*
     * Description: Blesses an allied unit with the seal of the Sun, reducing any damage it receives and increasing 
                    its health regeneration. The seal breaks when after receiving a certain amount of damage, 
                    hurting enemy units around by the same amount of damage received. If the seal is not broken, 
                    it will heal all allied units around the target for 50% of the base regeneration. 
                    And if the target receives lethal damage, the seal will block it. 
                    It expires after 9 seconds or when broken.
     * Last Update: 02.01.2014
     * Changelog: 
     *     02.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A08K'
        private constant integer BUFF_PLACER_ID = 'A08L'
        private constant integer BUFF_ID = 'B01Q'
        private constant real TIMER_INTERVAL = 0.10
        private constant real SPELL_DURATION = 9.00
        private constant integer DAMAGE_MODIFIER_PRIORITY = 50
        private constant real SEAL_BREAK_DAMAGE_RANGE = 300.00
        private constant real SEAL_AOE_HEAL_RANGE = 300.00
        private constant real SEAL_HEAL_AOE_FACTOR = 0.5
        private constant string SEAL_BREAK_DAMAGE_EFFECT = "Models\\GodsSealExplosion.mdl"
        private constant string SEAL_AOE_HEAL_EFFECT = "Models\\GodsSealAoeHealEffect.mdl"
        private constant string SEAL_AOE_HEAL_EFFECT_ATTACH = "origin"
        private real array SEAL_BREAK_DAMAGE_VALUE
        private real array DAMAGE_REDUCTION
        private real array SEAL_HEAL
    endglobals
    
    private keyword Main
    private keyword DamageModificator
    private keyword damageUpdate
    
    
    private function MainSetup takes nothing returns nothing
        set DAMAGE_REDUCTION[0] = 0.15
        set DAMAGE_REDUCTION[1] = 0.20
        set DAMAGE_REDUCTION[2] = 0.25
        set DAMAGE_REDUCTION[3] = 0.30
        set DAMAGE_REDUCTION[4] = 0.35
        
        set SEAL_BREAK_DAMAGE_VALUE[0] = 75.00
        set SEAL_BREAK_DAMAGE_VALUE[1] = 125.00
        set SEAL_BREAK_DAMAGE_VALUE[2] = 175.00
        set SEAL_BREAK_DAMAGE_VALUE[3] = 225.00
        set SEAL_BREAK_DAMAGE_VALUE[4] = 275.00
        
        set SEAL_HEAL[0] = 10
        set SEAL_HEAL[1] = 20
        set SEAL_HEAL[2] = 30
        set SEAL_HEAL[3] = 40
        set SEAL_HEAL[4] = 50
    endfunction
    
    struct DamageModificator extends DamageModifier
    
        static constant integer prio = DAMAGE_MODIFIER_PRIORITY
        
        Main root = 0
            
        static method create takes Main from returns thistype
            local thistype this = allocate(from.target, prio)
            set root = from
            return this
        endmethod
        
        method onDamageTaken takes unit source, real damage returns real
            if GetUnitLife(root.target) - damage <= 1.00 then
                call root.damageUpdate(damage - GetUnitLife(root.target) + 1.00)
                return -(damage - GetUnitLife(root.target) + 1.00)
            endif
            call root.damageUpdate(damage * DAMAGE_REDUCTION[root.lvl])
            return -(damage * DAMAGE_REDUCTION[root.lvl])
        endmethod
    
    endstruct

    struct Main
        static constant integer spellId = SPELL_ID
        static constant boolean autoDestroy = false
        static constant integer spellType = SPELL_TYPE_TARGET_UNIT
    
        DamageModificator dmgModi = 0
        real damageBlocked = 0.00
        dbuff buff = 0
        
        static delegate xedamage dmg = 0
        static thistype temp = 0
        static integer buffType = 0
        static timer ticker = null
        static boolexpr doHeal = null
        static real array aoeHeal
    
        implement List
        
        method onDestroy takes nothing returns nothing
            call dmgModi.destroy()
        endmethod
        
        method explode takes nothing returns nothing
            set DamageType = 1
            call damageAOE(caster, GetUnitX(target), GetUnitY(target), SEAL_BREAK_DAMAGE_RANGE, SEAL_BREAK_DAMAGE_VALUE[lvl])
            if SEAL_BREAK_DAMAGE_EFFECT != "" then
                call DestroyEffect(AddSpecialEffect(SEAL_BREAK_DAMAGE_EFFECT, GetUnitX(target), GetUnitY(target)))
            endif
            call buff.destroy()
            call destroy()
        endmethod
        
        static method doHealEnum takes nothing returns boolean
            local unit u = GetFilterUnit()
            if IsUnitAlly(u, GetOwningPlayer(temp.caster)) and not IsUnitType(u, UNIT_TYPE_DEAD) and u != temp.target then
                call DestroyEffect(AddSpecialEffectTarget(SEAL_AOE_HEAL_EFFECT, u, SEAL_AOE_HEAL_EFFECT_ATTACH))
                call SetUnitLife(u, GetUnitLife(u) + aoeHeal[temp.lvl])
            endif
            set u = null
            return false
        endmethod
        
        method doEndHeal takes nothing returns nothing
            set temp = this
            call GroupRefresh(ENUM_GROUP)
            call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(target), GetUnitY(target), SEAL_AOE_HEAL_RANGE, doHeal)
        endmethod
        
        method damageUpdate takes real damage returns nothing
            set damageBlocked = damageBlocked + damage
            if damageBlocked >= SEAL_BREAK_DAMAGE_VALUE[lvl] then
                call explode()
            endif
        endmethod
    
        static method periodicActions takes nothing returns nothing
            local dbuff b = GetEventBuff()
            call SetUnitLife(b.target, GetUnitLife(b.target) + SEAL_HEAL[thistype(b.data).lvl] * TIMER_INTERVAL)
        endmethod
        
        static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            if b.isExpired then
                call thistype(b.data).doEndHeal()
                call thistype(b.data).destroy()
            endif
        endmethod
        
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            if b.isRefreshed then
                //Destroying old data
                call thistype(b.data).destroy()
            endif
            
            set this = temp
            set b.data = integer(this)
            set buff = b
            set dmgModi = DamageModificator.create(this)
        endmethod
        
        method onCast takes nothing returns nothing
            set lvl = lvl - 1
            set temp = this
            call UnitAddBuff(caster, target, buffType, SPELL_DURATION, lvl + 1)
        endmethod
    
        implement Spell
        
        private static method onInit takes nothing returns nothing
            set buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, TIMER_INTERVAL, true, false, thistype.onBuffAdd, thistype.periodicActions, thistype.onBuffEnd)
            set dmg = xedamage.create()
            set atype = ATTACK_TYPE_MAGIC
            set dtype = DAMAGE_TYPE_MAGIC
            set doHeal = Condition(function thistype.doHealEnum)
            
            set aoeHeal[0] = SPELL_DURATION * SEAL_HEAL[0] * SEAL_HEAL_AOE_FACTOR
            set aoeHeal[1] = SPELL_DURATION * SEAL_HEAL[1] * SEAL_HEAL_AOE_FACTOR
            set aoeHeal[2] = SPELL_DURATION * SEAL_HEAL[2] * SEAL_HEAL_AOE_FACTOR
            set aoeHeal[3] = SPELL_DURATION * SEAL_HEAL[3] * SEAL_HEAL_AOE_FACTOR
            set aoeHeal[4] = SPELL_DURATION * SEAL_HEAL[4] * SEAL_HEAL_AOE_FACTOR
        endmethod
    
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(BUFF_PLACER_ID)
        call Preload(SEAL_BREAK_DAMAGE_EFFECT)
        call Preload(SEAL_AOE_HEAL_EFFECT)
    endfunction
    
endscope