scope SoulTrap initializer init
    /*
     * Description: The Gatekeeper traps a unit in within his tormented soul, removing it from the battlefield 
                    and damaging it in the process. Mana Concentration increases the damage done.
     * Last Update: 01.11.2013
     * Changelog: 
     *     01.11.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A050'
        private constant integer DUMMY_SPELL_ID = 'A051'
        private constant integer DUMMY_ID = 'e00R'
        private constant real DMG_BASE = 50.0
        private constant real DMG_INCR = 100.0
        private constant real DURATION = 8.0
        private constant real DURATION_HERO = 5.0
        private constant string START_EFFECT = "Abilities\\Spells\\Items\\AIso\\AIsoTarget.mdl" 
        private constant string END_EFFECT = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
        private constant rect DUMMY_RECT = gg_rct_SoulTrapDummyPosition
        //Die Einheit mit der Abi "Unsichtbarkeit" zusätzlich verstecken?
        private constant boolean HIDE_ADV = true
        
        //Stun Effect for Pause Target
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = 5.0

    endglobals
    
    private struct SoulTrap
        unit caster
        unit target
        unit dummy
        timer t
        real x
        real y
        integer level = 0
        integer id = 0
        
        
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .target = target
            set .x = GetUnitX(.target)
            set .y = GetUnitY(.target)
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .id = GetPlayerId(GetOwningPlayer(.caster))
            
            call DestroyEffect(AddSpecialEffect( START_EFFECT, GetUnitX(.target), GetUnitY(.target)))
            //Hide Advanced: Einheit mit Abi "Unsichtbarkeit" verstecken und dann in die
            //untere rechte Ecke der Karte stellen
            static if HIDE_ADV then
                set .dummy = CreateUnit(GetOwningPlayer(.caster), DUMMY_ID, .x, .y, bj_UNIT_FACING)
                call UnitAddAbility( .dummy, DUMMY_SPELL_ID )
                call SetUnitAbilityLevel( .dummy, DUMMY_SPELL_ID, 1 )
                call UnitApplyTimedLife( .dummy, 'BTLF', 1.0 )
                call IssueTargetOrder(.dummy, "invisibility", .target)
                //Setzt die Einheit in die untere rechte Ecke der Karte
                call SetUnitX(.target, GetRectCenterX(DUMMY_RECT))
                call SetUnitY(.target, GetRectCenterY(DUMMY_RECT))
            endif
            //Hide Unit
            call ShowUnit(.target, false)
            //Pause Unit / Used Stun System
            call Stun_UnitEx(.target, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            
            set .t = NewTimer()
            call SetTimerData(.t, this)
            
            if IsUnitType(.target, UNIT_TYPE_HERO) then
                call TimerStart(.t, DURATION_HERO, false, function thistype.onEnd)
            else
                call TimerStart(.t, DURATION, false, function thistype.onEnd)
            endif
            
            return this
        endmethod
        
        static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call ShowUnit(this.target, true)
            call SetUnitX(this.target, this.x)
            call SetUnitY(this.target, this.y)
            set DamageType = 1
            call UnitDamageTarget( this.caster, this.target, (DMG_BASE + ( DMG_INCR * this.level )) * ManaConcentration_GET_MANA_AMOUNT(this.id), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_DEATH, WEAPON_TYPE_WHOKNOWS )
            call DestroyEffect(AddSpecialEffect(END_EFFECT, GetUnitX(this.target), GetUnitY(this.target)))
        
            call this.destroy()
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
            set .t = null
            set .caster = null
            set .target = null
            set .dummy = null
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local SoulTrap st = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set st = SoulTrap.create( GetTriggerUnit(), GetSpellTargetUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger trig = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( trig, function Actions )
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(START_EFFECT)
        call Preload(END_EFFECT)
    endfunction

endscope