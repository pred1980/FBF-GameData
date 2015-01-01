scope HolyStrike initializer init
     /*
     * Description: The Paladin enchances his mace with holy power, causing his next attack to deal bonus percentage 
                    magic damage to enemies around the target. Holy Strike will be activated automatically 
                    once the cooldown is over.
     * Last Update: 02.01.2014
     * Changelog: 
     *     02.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A08P'
        private constant integer EFFECT_ID = 'A08Q'
        private constant real TIMER_INTERVAL = 0.5
        private real array SPELL_COOLDOWN
    endglobals
    
    //Damage Configuration
    globals
        private real array DAMAGE_FACTOR
        private real array DAMAGE_AREA    
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant string DAMAGE_EFFECT = "Abilities\\Spells\\Other\\HealingSpray\\HealBottleMissile.mdl"
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set SPELL_COOLDOWN[0] = 15.00
        set SPELL_COOLDOWN[1] = 12.00
        set SPELL_COOLDOWN[2] = 9.00
        set SPELL_COOLDOWN[3] = 6.00
        set SPELL_COOLDOWN[4] = 3.00
        
        set DAMAGE_FACTOR[0] = 1.50
        set DAMAGE_FACTOR[1] = 2.00
        set DAMAGE_FACTOR[2] = 2.50
        set DAMAGE_FACTOR[3] = 3.00
        set DAMAGE_FACTOR[4] = 3.50
        
        set DAMAGE_AREA[0] = 250.00
        set DAMAGE_AREA[1] = 300.00
        set DAMAGE_AREA[2] = 350.00
        set DAMAGE_AREA[3] = 400.00
        set DAMAGE_AREA[4] = 450.00
    endfunction
    
    private struct Main
        static constant integer spellId = SPELL_ID
        static constant boolean useDamageEvents = true
        static boolexpr unitFilter = null
        static delegate xedamage dmg = 0
        
        boolean isReady = false
        real counter = 0.00
        
        static timer ticker = null
        static real tempDamage = 0.00
        static thistype temp = 0

        static method unitFilterMethod takes nothing returns boolean
            local thistype this = temp
            local unit u = GetFilterUnit()
            if IsUnitEnemy(u, GetOwningPlayer(owner)) and not IsUnitType(u, UNIT_TYPE_DEAD) then
                set DamageType = SPELL
                call damageTarget(owner, u, tempDamage * DAMAGE_FACTOR[lvl -  1])
            endif
            set u = null
            return false
        endmethod
        
        method onDamage takes unit target, real damage returns nothing
            if isReady and DamageType == 0 then
                set temp = this
                set tempDamage = damage
                call GroupRefresh(ENUM_GROUP)
                call GroupEnumUnitsInArea(ENUM_GROUP, GetUnitX(owner), GetUnitY(owner), DAMAGE_AREA[lvl - 1], unitFilter)
                set isReady = false
                call UnitRemoveAbility(owner, EFFECT_ID)
            endif
        
        endmethod
        
        method activate takes nothing returns nothing
            if not IsUnitType(owner, UNIT_TYPE_DEAD) then
                set isReady = true
                set counter = 0.00
                call UnitAddAbility(owner, EFFECT_ID)
            endif
        endmethod
        
        static method onExpire takes nothing returns nothing
            local thistype this = m_first
            if this == 0 and m_count == 0 then
                call PauseTimer(ticker)
            endif
            loop
                exitwhen this == 0
                if not isReady then
                    set counter = counter + TIMER_INTERVAL
                    if counter >= SPELL_COOLDOWN[lvl - 1] then
                        call activate()
                    endif
                endif
                set this = m_next
            endloop
        endmethod
        
        method onLearn takes nothing returns nothing
            call activate()
            if m_count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.onExpire)
            endif
        endmethod
        
        implement PassiveSpell
            
        private static method onInit takes nothing returns nothing
            set ticker = CreateTimer()
            set dmg = xedamage.create()
            set atype = ATTACK_TYPE
            set dtype = DAMAGE_TYPE
            set unitFilter = Condition(function thistype.unitFilterMethod)
            call useSpecialEffect(DAMAGE_EFFECT, "origin")
        endmethod
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(EFFECT_ID)
        call Preload(DAMAGE_EFFECT)
    endfunction
    
endscope