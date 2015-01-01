library ArtOfFire initializer init requires DamageEvent, ListModule, GroupUtils, PassiveSpellSystem, IntuitiveBuffSystem, xedamage, xebasic, xefx
    /*
     * Description: The Fire Panda throws his blades in the target direction, damaging all enemies they hit. 
                    Each blade can only hit an enemy once.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A08U'
        private constant integer ART_OF_FIRE_EFFECT_ID = 'A08V'
        private constant integer IGNITION_BUFF_PLACER_ID = 'A08W'
        private constant integer IGNITION_BUFF_ID = 'B01T'
        private constant real IGNITION_DURATION = 3.00
        private constant real IGNITION_DAMAGE_INTERVAL = 0.25
        private constant damagetype IGNITION_DAMAGE_TYPE = DAMAGE_TYPE_FIRE
        private constant attacktype IGNITION_ATTACK_TYPE = ATTACK_TYPE_MAGIC
        
        private real array IGNITION_DAMAGE
    endglobals

    private keyword Ignition
    
    private function MainSetup takes nothing returns nothing
        set IGNITION_DAMAGE[0] = 15.00
        set IGNITION_DAMAGE[1] = 30.00
        set IGNITION_DAMAGE[2] = 45.00
    endfunction
        

    public function GetLevel takes unit u returns integer
        return GetUnitAbilityLevel(u, SPELL_ID)
    endfunction
    
    public function IgniteUnit takes unit caster, unit target returns nothing
        call Ignition.generate(caster, target, GetLevel(caster))
    endfunction
    
    
    struct Ignition
    
        static delegate xedamage dmg = 0
        static thistype temp = 0
        static integer buffType = 0
        
        unit caster = null
        unit target = null
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
            call damageTarget(caster, target, IGNITION_DAMAGE[lvl] * IGNITION_DAMAGE_INTERVAL)
        endmethod
        
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            
            if b.isRefreshed then
                //Destroying old data
                call thistype(b.data).destroy()
            endif
            
            set this = allocate()
            set b.data = integer(this)
            set caster = b.source
            set target = b.target
            set lvl = b.level - 1
            set buff = b
        endmethod
        
        static method generate takes unit caster, unit target, integer level returns nothing
            call UnitAddBuff(caster, target, buffType, IGNITION_DURATION, level)
        endmethod
        
        static method onInit takes nothing returns nothing
            set buffType = DefineBuffType(IGNITION_BUFF_PLACER_ID, IGNITION_BUFF_ID, IGNITION_DAMAGE_INTERVAL, true, false, thistype.onBuffAdd, thistype.onLoop, thistype.onBuffEnd)
            set dmg = xedamage.create()
            set dtype = IGNITION_DAMAGE_TYPE
            set atype = IGNITION_ATTACK_TYPE
        endmethod
    endstruct
        
    private struct Main
    
        static constant integer spellId = SPELL_ID
        static constant boolean useDamageEvents = true
        
        method onDamage takes unit target, real damage returns nothing
            if IsUnitEnemy(target, GetOwningPlayer(owner)) and DamageType == 0 then
                call Ignition.generate(owner, target, lvl)
            endif
        endmethod
    
        method onLearn takes nothing returns nothing
            call UnitAddAbility(owner, ART_OF_FIRE_EFFECT_ID)
        endmethod
    
        implement PassiveSpell
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(ART_OF_FIRE_EFFECT_ID)
        call XE_PreloadAbility(IGNITION_BUFF_PLACER_ID)
    endfunction

endlibrary