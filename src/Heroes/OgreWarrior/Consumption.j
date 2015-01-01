library Consumption initializer Init uses GroupUtils, DamageModifiers, SpellEvent, AutoIndex, IntuitiveBuffSystem, TimerUtils
    /*
     * Description: The Ogre Warrior concentrates his power to consume the complete damage to regain his life. 
                    After a short period of time he releases the total consumed power for a last final attack.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
     */
    private keyword Data
    
    globals
        private constant integer AID = 'A09M'
        private constant integer BUFF_PLACER_AID = 'A09L'
        private constant integer BID = 'B01Z'
        private constant string FX = "Abilities\\Spells\\Other\\GeneralAuraTarget\\GeneralAuraTarget.mdl" 
        private constant string FX_ATTPT = "origin"
        private constant real FX_DURATION = 0.
        private constant string TARGET_FX = "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustSpecial.mdl"
        private constant string TARGET_FX_ATTPT = "head"
        private constant integer PRIORITY = 0 
        
        private constant real BONUS_DAMAGE_TIME = 5.0
        private real array DURATION 
        private real array DAMAGE_REDUCTION_PHYISCAL
        private real array DAMAGE_REDUCTION_SPELL
        private real array SCALE
        private integer array MOVEMENT_SPEED
        private integer array ATTACK_SPEED
    endglobals
    
    private function MainSetup takes nothing returns nothing
        // how long does the buff last?
        set DURATION[1] = 5
        set DURATION[2] = 7
        set DURATION[3] = 9
        
        //Physical Damage
        set DAMAGE_REDUCTION_PHYISCAL[1] = 1.6 //+60%
        set DAMAGE_REDUCTION_PHYISCAL[2] = 1.5 //+50%
        set DAMAGE_REDUCTION_PHYISCAL[3] = 1.4 //40%
        
        //Spell Damage
        set DAMAGE_REDUCTION_SPELL[1] = 1.3 //+30%
        set DAMAGE_REDUCTION_SPELL[2] = 1.2 //+20%
        set DAMAGE_REDUCTION_SPELL[3] = 1.1 //+10%
        
        set MOVEMENT_SPEED[1] = 70
        set MOVEMENT_SPEED[2] = 100
        set MOVEMENT_SPEED[3] = 130
        
        set ATTACK_SPEED[1] = 100
        set ATTACK_SPEED[2] = 200
        set ATTACK_SPEED[3] = 300
        
    endfunction
    
    // how much damage to block
    private function Damage_Blocked takes integer level, real damage returns real
        return RMinBJ(damage, I2R(level) * 200.)
    endfunction
    
    globals
        private integer BuffType
    endglobals
    
    private struct Data extends DamageModifier
        unit caster
        unit target
        effect targetFx
        integer level = 0
        real reduction = 0.00
        timer t
        
        static thistype tempthis
        static real CurrentDamage
        
        static thistype array Instance
        
        static method create takes unit caster, unit target returns thistype
            local thistype s = Instance[GetUnitId(target)]
            if s==0 then
                set s=.allocate(target, PRIORITY)
                set s.caster=caster
                set s.target=target
                if TARGET_FX!="" then
                    set s.targetFx = AddSpecialEffectTarget(TARGET_FX, target, TARGET_FX_ATTPT)
                endif
                set s.level=GetUnitAbilityLevel(caster, AID)
                set Instance[GetUnitId(target)]=s
            else
                if s.level<GetUnitAbilityLevel(caster, AID) then
                    set s.caster=caster
                    set s.level=GetUnitAbilityLevel(caster, AID)
                endif
            endif
            set .tempthis = s
            set UnitAddBuff(caster, target, BuffType, DURATION[s.level], s.level).data = s
            return s
        endmethod
        
        private method onDamageTaken takes unit origin, real damage returns real
            local real blocked = Damage_Blocked(.level, damage)
            if DamageType == PHYSICAL then
                set blocked = (DAMAGE_REDUCTION_PHYISCAL[.level] * blocked) - blocked
            endif
            if DamageType == SPELL then
                set blocked = (DAMAGE_REDUCTION_SPELL[.level] * blocked) - blocked
            endif
            set .reduction = .reduction + blocked
            call DestroyEffect(AddSpecialEffectTarget(FX, .target, FX_ATTPT))
            
            return -blocked
        endmethod
        
        static method BuffRemoved takes nothing returns nothing
            call AddUnitBonus(.tempthis.caster, BONUS_DAMAGE, R2I(.tempthis.reduction))
            call AddUnitBonus(.tempthis.caster, BONUS_ATTACK_SPEED, R2I(ATTACK_SPEED[.tempthis.level]))
            call AddUnitBonus(.tempthis.caster, BONUS_MOVEMENT_SPEED, R2I(MOVEMENT_SPEED[.tempthis.level]))
            set .tempthis.t = NewTimer()
            call TimerStart( .tempthis.t, BONUS_DAMAGE_TIME, false, function thistype.onBonusEnd )
        endmethod
        
        static method onBonusEnd takes nothing returns nothing
            call thistype(GetEventBuff().data).destroy()
        endmethod
        
        private method onDestroy takes nothing returns nothing
            set Instance[GetUnitId(.target)] = 0
            call RemoveUnitBonus(.caster, BONUS_DAMAGE)
            call RemoveUnitBonus(.caster, BONUS_ATTACK_SPEED)
            call RemoveUnitBonus(.caster, BONUS_MOVEMENT_SPEED)
            set .caster = null
            set .target = null
            if TARGET_FX != "" then
                call DestroyEffect(.targetFx)
                set .targetFx = null
            endif
            call ReleaseTimer(.t)
            set .t = null
        endmethod
    endstruct
    
    private function CastResponse takes nothing returns nothing
        call Data.create(SpellEvent.CastingUnit, SpellEvent.TargetUnit)
    endfunction
    
    private function Init takes nothing returns nothing
        call RegisterSpellEffectResponse(AID, CastResponse)
        
        set BuffType=DefineBuffType(BUFF_PLACER_AID, BID, 0, false, true, 0,0,Data.BuffRemoved)
        
        call MainSetup()
        call Preload(FX)
        call Preload(TARGET_FX)
        call XE_PreloadAbility(BUFF_PLACER_AID)
    endfunction
    
endlibrary