scope SpiritBurn initializer Init
    /*
     * Description: Lady Venefica slowly consumes the spirit of the targeted unit, draining some of its mana every second. 
                    If the units mana reaches 0 before the spell is over, the unit detonates violently, 
                    dealing damage equal to half of its current health in an area. Units that do not have mana, 
                    instantly detonate. Heroes detonate for only 10% of their current health.
     * Last Update: 29.10.2013
     * Changelog: 
     *     29.10.2013: Abgleich mit OE und der Exceltabelle
     *
     */   
    globals
        private constant integer SPELL_ID = 'A04W'
        private constant integer BUFF_ID = 'B00F'
        private constant string boomEffect = "Units\\NightElf\\Wisp\\WispExplode.mdl"
        private constant real mana_base = 20.0//base mana burned by second
        private constant real mana_inc = 10.0//mana burn increase per level
        private constant real manaTimer = 1.0//timer period between each mana burn
        private constant real explodeDmg = 0.50//percentage of health that detonates if the unit's mana = 0
        private constant real heroExplodeDmg = 0.10//percentage of health that detonates when hero's mana = 0
        private constant real radius = 350.0//radius of the explosion
        private constant real duration = 5.0//duration of the spell, used to control buff stacking
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
    //setup of the damage options
        set d.dtype = DAMAGE_TYPE_MAGIC    //deals magic damage
        set d.atype = ATTACK_TYPE_NORMAL   //normal attack type
        
        set d.damageEnemies = true     //hits enemies
        set d.damageAllies  = false    //doesn't hit allies
        set d.damageNeutral = true     //hits neutral units
        set d.damageSelf    = false    //doesn't hit self
        set d.exception = UNIT_TYPE_STRUCTURE    //doesn't hit structures
    endfunction
    
//**************************************************************************
//*************************** SETUP END ************************************
//**************************************************************************
    globals
        private group all
        private boolexpr b
        private xedamage damageOptions 
    endglobals

    private function Pick takes nothing returns boolean
        return true
    endfunction
    
    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction
    
    private struct Data
        unit caster
        unit target
        boolean hasbuff = false
        real counter
        
        static method create takes unit c, unit t returns Data
            local Data D = Data.allocate()
            set D.caster = c
            set D.target = t
            set D.counter = 0.0
            return D
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .hasbuff = false
        endmethod
    endstruct
    
    private function Loop takes nothing returns nothing
        local real dmg
        local timer t = GetExpiredTimer()
        local Data D = Data(GetTimerData(t))
        local real ManaBurn = (mana_base + mana_inc*(I2R(GetUnitAbilityLevel(D.caster, SPELL_ID)) - 1))
        local real dur = duration
        
        if not D.hasbuff and GetUnitAbilityLevel(D.target, BUFF_ID) > 0 then
            set D.hasbuff = true
        endif
        
        if D.hasbuff and GetUnitAbilityLevel(D.target, BUFF_ID) > 0 then
            set D.counter = D.counter + manaTimer
            if GetUnitState(D.target, UNIT_STATE_MANA) > 1 then
                call SetUnitState(D.target, UNIT_STATE_MANA, GetUnitState(D.target, UNIT_STATE_MANA) - ManaBurn)
            else
                call GroupEnumUnitsInRange(all, GetUnitX(D.target), GetUnitY(D.target), radius, b)
                if not IsUnitType(D.target, UNIT_TYPE_HERO) then
                    set dmg = GetWidgetLife(D.target) * explodeDmg
                else
                    set dmg = GetWidgetLife(D.target) * heroExplodeDmg
                endif
                set DamageType = 1
                call damageOptions.damageGroup(D.caster, all, dmg)
                call DestroyEffect(AddSpecialEffectTarget(boomEffect, D.target, "origin"))
                call UnitRemoveAbility(D.target, BUFF_ID)
            endif
        endif
        if D.hasbuff and (D.counter > dur or GetUnitAbilityLevel(D.target, BUFF_ID) < 1) then
            call D.destroy()
            call ReleaseTimer(t)
        endif
        set t = null
    endfunction
    
    private function Actions takes nothing returns nothing
        local Data D = Data.create(GetTriggerUnit(), GetSpellTargetUnit())
        local timer t = NewTimer()
        call SetTimerData(t, integer(D))
        call TimerStart(t, manaTimer, true, function Loop)
        set t = null
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger SpiritBurnTrg = CreateTrigger()
        set damageOptions=xedamage.create()
        call setupDamageOptions(damageOptions)
        call TriggerRegisterAnyUnitEventBJ(SpiritBurnTrg, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(SpiritBurnTrg, Condition(function Conditions))
        call TriggerAddAction(SpiritBurnTrg, function Actions)
        set all = CreateGroup()
        set b = Condition(function Pick)
        set SpiritBurnTrg = null
        call Preload(boomEffect)
    endfunction
endscope