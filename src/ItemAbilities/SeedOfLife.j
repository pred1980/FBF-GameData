library SeedOfLife initializer Init uses GroupUtils, DamageModifiers, SpellEvent, AutoIndex, IntuitiveBuffSystem
	/*
	 * Item: Holy Shield
	 *
     * Changelog: 
     *     	17.05.2015: Increased the duration from 7/8/9 seconds to 15/20/25 seconds
						Added "Self" as target
     */	 
    private keyword Data 
    
    globals
        private constant integer AID = 'A02O' // ability triggering this. Any unit targeting ability is fine. Used Bloodlust
        private constant integer BUFF_PLACER_AID = 'A02P' // Ability placing BID on the unit this ability is added to. Based off of Slow Aura (Tornado).
        private constant integer BID = 'B003' // buff placed by BUFF_PLACER_AID on the target unit
        private constant string FX = "Models\\HealingSurge.mdl" // displayed on the target unit when the effect of this ability is triggered.
        private constant string FX_ATTPT = "origin"
        private constant real FX_DURATION = 1.833 // 0 or less only plays the death animation // ignored if TimedHandles is not present in the map
        private constant string TARGET_FX = "" // displayed on the target of this spell
        private constant string TARGET_FX_ATTPT = "" // where to display the effect on the target of this spell
        private constant integer PRIORITY = 0 // when to trigger the effects of an instance of this spell when a unit receives damage // refer to DamageModifiers documentation
        private real array DURATION // how long does the buff last?
        private real array AOE // Heals all units around the damaged target in this area
        private integer array MAX_HEALINGS // heal at most this many times // zero or less for no limit
        private integer array HERO_LEVEL_RANGE
    endglobals
    
    private function getAbilityIndex takes integer level returns integer
        local integer index = 0
        
        if level < HERO_LEVEL_RANGE[1] then
            set index = 1
        elseif level >= HERO_LEVEL_RANGE[1] and level < HERO_LEVEL_RANGE[2] then
            set index = 2
        else
            set index = 3
        endif
        
        return index
    endfunction
    
    // how long does the buff last?
    private function Duration takes integer level returns real
        return DURATION[level]
    endfunction
    
    // Heals all units around the damaged target in this area
    private function Aoe takes integer level returns real
        return AOE[level]
    endfunction
    
    // heal at most this many times // zero or less for no limit
    private function Max_Healings takes integer level returns integer
        return MAX_HEALINGS[level]
    endfunction
    
    private function SetUpSpellData takes nothing returns nothing
        // how long does the buff last?
        set DURATION[1]= 15
        set DURATION[2]= 20
        set DURATION[3]= 25
        
        // Heals all units around the damaged target in this area
        set AOE[1] = 300
        set AOE[2] = 350
        set AOE[3] = 400
        
        // heal at most this many times // zero or less for no limit
        set MAX_HEALINGS[1] = 0
        set MAX_HEALINGS[2] = 0
        set MAX_HEALINGS[3] = 0
        
        //Hero Level Range
        set HERO_LEVEL_RANGE[1] = 10
        set HERO_LEVEL_RANGE[2] = 15
        set HERO_LEVEL_RANGE[3] = 20
    endfunction
    
    // if you want to get the targets current HP, use GetUnitLife(whichUnit)
    
    // damage dealt to a unit with this buff active needs to be greater than what this function returns to be blocked
    private function Minimum_Damage takes integer level, unit target returns real
        return 0.
    endfunction
    
    // how much damage to block
    private function Damage_Blocked takes integer level, unit target, real damage returns real
        return 0.
    endfunction
    
    // how much health to restore after blocking
    private function Health_Restored takes integer level, unit target, real damage returns real
        return 10.+level*10.
    endfunction
    
    // how much health to heal units in the area
    private function Aoe_Heal takes integer level, unit target, real damage returns real
        return 10.+level*5.
    endfunction
    
    // only units matching these criteria will get healed
    private function ValidTarget takes unit u, unit caster returns boolean
        return     IsUnitAlly(u, GetOwningPlayer(caster))/*
            */ and IsUnitType(u, UNIT_TYPE_MECHANICAL)==false/*
            */ and IsUnitType(u, UNIT_TYPE_STRUCTURE)==false/*
            */ and IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE)==false/*
            */
    endfunction
    
    globals
        private integer BuffType
    endglobals
    
    private struct Data extends DamageModifier
        unit caster
        unit target
        effect targetFx
        integer level
        integer healings = 0
        
        static thistype Tmps
        static real CurrentDamage
        
        static thistype array Instance
        
        private method onDestroy takes nothing returns nothing
            set Instance[GetUnitId(.target)] = 0
            set .caster=null
            set .target=null
            if TARGET_FX!="" then
                call DestroyEffect(.targetFx)
                set .targetFx=null
            endif
        endmethod
        
        private static method AoeHealEnum takes nothing returns boolean
            local unit u = GetFilterUnit()
            if u != .Tmps.target and ValidTarget(u, .Tmps.caster) then
                call SetUnitLife(u, GetUnitLife(u) + Aoe_Heal(.Tmps.level, .Tmps.target, .CurrentDamage))
                call DestroyEffect(AddSpecialEffectTarget(FX, u, FX_ATTPT))
            endif
            set u = null
            return false
        endmethod
        
        private method onDamageTaken takes unit origin, real damage returns real
            local real blocked = 0 
            if damage + 0.406 >= Minimum_Damage(.level, .target) then
                if ValidTarget(.target, .caster) then
                    call SetUnitLife(.target, GetUnitLife(.target)+Health_Restored(.level, .target, damage))
                    call DestroyEffect(AddSpecialEffectTarget(FX, .target, FX_ATTPT))
                    set blocked = Damage_Blocked(.level, .target, damage)
                endif
                if Aoe(.level) > 0. then
                    set .Tmps = this
                    set .CurrentDamage = damage
                    call GroupEnumUnitsInArea(ENUM_GROUP, GetUnitX(.target), GetUnitY(.target), Aoe(.level), Condition(function thistype.AoeHealEnum))
                endif
                set .healings = .healings + 1
                if Max_Healings(.level) > 0 and .healings >= Max_Healings(.level) then
                    call UnitRemoveBuff(.target, BuffType)
                endif
                return -blocked
            endif
            return 0.
        endmethod
        
        static method create takes unit caster, unit target returns thistype
            local thistype s = Instance[GetUnitId(target)]
            
            set s = .allocate(target, PRIORITY)
            set s.caster = caster
            set s.target = target
            if TARGET_FX != "" then
                set s.targetFx = AddSpecialEffectTarget(TARGET_FX, target, TARGET_FX_ATTPT)
            endif
            set s.level = getAbilityIndex(GetHeroLevel(caster)) 
            set Instance[GetUnitId(target)] = s
            set UnitAddBuff(caster, target, BuffType, Duration(s.level), s.level).data = s
            return s
        endmethod
        
        static method BuffRemoved takes nothing returns nothing
            call thistype(GetEventBuff().data).destroy()
        endmethod
    endstruct
    
    private function CastResponse takes nothing returns nothing
        call Data.create(SpellEvent.CastingUnit, SpellEvent.TargetUnit)
    endfunction
    
    private function Init takes nothing returns nothing
        call RegisterSpellEffectResponse(AID, CastResponse)
        
        set BuffType=DefineBuffType(BUFF_PLACER_AID, BID, 0, false, true, 0,0,Data.BuffRemoved)
        
        call SetUpSpellData()
        call XE_PreloadAbility(BUFF_PLACER_AID)
        call Preload(FX)
    endfunction
    
endlibrary