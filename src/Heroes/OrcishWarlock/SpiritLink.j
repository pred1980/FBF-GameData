scope SpiritLink initializer init
    /*
     * Description: The Orcish Warlock connects his spirit with the target. Whenever the target receives damage and 
                    has less life than the Warlock, the damage will be blocked, by sacrificing the amount of damage 
                    with the Warlocks own life.
     * Last Update: 08.01.2014
     * Changelog: 
     *     08.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A07U'
        private constant integer BUFF_PLACER_ID = 'A07V'
        private constant integer BUFF_ID = 'B01G'
        private constant integer DAMAGE_MODIFIER_PRIORITY = 25
        private real array SPELL_DURATION
    endglobals
    
    private keyword Main
    private keyword DamageModificator
    
    private function MainSetup takes nothing returns nothing
        set SPELL_DURATION[0] = 20.00
        set SPELL_DURATION[1] = 30.00
        set SPELL_DURATION[2] = 40.00
        set SPELL_DURATION[3] = 50.00
        set SPELL_DURATION[4] = 60.00
    endfunction
    
    struct DamageModificator extends DamageModifier
        Main root = 0
            
        static method create takes Main from returns thistype
            local thistype this = allocate(from.target, DAMAGE_MODIFIER_PRIORITY)
            set root = from
            return this
        endmethod
        
        method onDamageTaken takes unit source, real damage returns real
            //Target hat mehr Leben als Caster, nichts tun
            if GetUnitLife(root.target) >= GetUnitLife(root.caster) then
                return 0.00
            else
                //Target hat weniger Leben als Caster, Leben des Casters ?berpr?fen
                if GetUnitLife(root.caster) <= damage then
                    //Leben vom Caster ist kleiner als der Schaden, all den Schaden bis 1 HP blocken
                    call SetUnitLife(root.caster, 1.00)
                    return -(GetUnitLife(root.caster) - 1.00)
                else
                    //Leben vom Caster ist gr??er als der Schaden, kompletten Schaden blocken
                    call SetUnitLife(root.caster, GetUnitLife(root.caster) - damage)
                    return -damage
                endif
            endif
        endmethod
    
    endstruct

    struct Main
        static constant integer spellId = SPELL_ID
        static constant boolean autoDestroy = false
        static constant integer spellType = SPELL_TYPE_TARGET_UNIT
        
        DamageModificator dmgModi = 0
        dbuff buff = 0
        
        static integer buffType = 0
        static thistype temp = 0
        
        method onDestroy takes nothing returns nothing
            call dmgModi.destroy()
        endmethod
        
        static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod
        
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            if b.isRefreshed then
                //Destroying old damage modifier
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
            call UnitAddBuff(caster, target, buffType, SPELL_DURATION[lvl], lvl + 1)
        endmethod
    
        implement Spell
        
        private static method onInit takes nothing returns nothing
            set buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0.00, false, false, thistype.onBuffAdd, 0, thistype.onBuffEnd)
        endmethod
    
    endstruct

    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(BUFF_PLACER_ID)
    endfunction
    
endscope