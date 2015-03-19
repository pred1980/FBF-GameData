scope BurningSkin initializer init
    /*
     * Description: FireLord Ignos covers himself with fire. Attacking enemies are hurt by a portion of the damage 
                    they deal to Ignos over a short period of time.
     * Last Update: 05.01.2014
     * Changelog: 
     *     05.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer BURNING_SKIN_SPELL_ID = 'A092'
        private constant integer BURN_BUFF_PLACER_ID = 'A090'
        private constant integer BURN_BUFF_ID = 'B01U'
        private constant real BURN_DAMAGE_INTERVAL = 0.05
        private constant damagetype BURN_DAMAGE_TYPE = DAMAGE_TYPE_FIRE
        private constant attacktype BURN_ATTACK_TYPE = ATTACK_TYPE_MAGIC
        
        private real array BURN_DURATION
        private real array BURNING_SKIN_PROC_CHANCE
        private real array BURNING_SKIN_DAMAGE_FACTOR
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set BURN_DURATION[0] = 4.50
        set BURN_DURATION[1] = 4.00
        set BURN_DURATION[2] = 3.50
        set BURN_DURATION[3] = 3.00
        set BURN_DURATION[4] = 2.50
        
        set BURNING_SKIN_PROC_CHANCE[0] = 0.15
        set BURNING_SKIN_PROC_CHANCE[1] = 0.20
        set BURNING_SKIN_PROC_CHANCE[2] = 0.25
        set BURNING_SKIN_PROC_CHANCE[3] = 0.30
        set BURNING_SKIN_PROC_CHANCE[4] = 0.35
        
        set BURNING_SKIN_DAMAGE_FACTOR[0] = 0.75
        set BURNING_SKIN_DAMAGE_FACTOR[1] = 0.90
        set BURNING_SKIN_DAMAGE_FACTOR[2] = 1.05
        set BURNING_SKIN_DAMAGE_FACTOR[3] = 1.20
        set BURNING_SKIN_DAMAGE_FACTOR[4] = 1.35
    endfunction

    struct BurnBuff
    
        static delegate xedamage dmg = 0
        static thistype temp = 0
        static integer buffType = 0
        static real damageValue = 0.00
        
        unit caster = null
        unit target = null
        real damage = 0.00
        integer lvl = -1
    
        dbuff buff = 0
    
        static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod
        
        static method onLoop takes nothing returns nothing
            local thistype this = thistype(GetEventBuff().data)
            set DamageType = 1
            call damageTarget(caster, target, damage * BURN_DAMAGE_INTERVAL / BURN_DURATION[lvl])
        endmethod
        
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            
            if b.isRefreshed then
                call thistype(b.data).destroy()
            endif
            
            set this = allocate()
            set b.data = integer(this)
            set caster = b.source
            set target = b.target
            set lvl = b.level - 1
            set damage = damageValue
            set buff = b
        endmethod
        
        static method apply takes unit caster, unit target, real value, integer level returns nothing
            set damageValue = value
            call UnitAddBuff(caster, target, buffType, BURN_DURATION[level - 1], level)
        endmethod
        
        static method onInit takes nothing returns nothing
            set buffType = DefineBuffType(BURN_BUFF_PLACER_ID, BURN_BUFF_ID, BURN_DAMAGE_INTERVAL, true, false, thistype.onBuffAdd, thistype.onLoop, thistype.onBuffEnd)
            set dmg = xedamage.create()
            set dtype = BURN_DAMAGE_TYPE
            set atype = BURN_ATTACK_TYPE
        endmethod
    
    endstruct
    
    private struct Main
    
        private static constant integer spellId = BURNING_SKIN_SPELL_ID
        private static constant boolean useDamageEvents = true
        private static constant boolean isNoHeroSpell = true
    
        method onDamaged takes unit source, real damage returns nothing
            if IsUnitEnemy(source, GetOwningPlayer(owner)) and DamageType == 0 and IsUnitType(source, UNIT_TYPE_MELEE_ATTACKER) then
                if GetRandomReal(0.00, 1.00) <= BURNING_SKIN_PROC_CHANCE[lvl - 1] then
                    call BurnBuff.apply(owner, source, damage * BURNING_SKIN_DAMAGE_FACTOR[lvl - 1], lvl)
                endif
            endif        
        endmethod
        
        implement PassiveSpell
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(BURN_BUFF_PLACER_ID)
    endfunction
    
endscope