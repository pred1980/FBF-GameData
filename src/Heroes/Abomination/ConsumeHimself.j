scope ConsumeHimself initializer init
    /*
     * Description: The Abomination consumes a chunk of his body to regenerate some hitpoints over 10 seconds.
     * Last Update: 09.11.2013
     * Changelog: 
     *     09.11.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A06K'
        private constant integer BUFF_ID = 'B00V'
        private constant real CONSUME_COUNT = 3.00 //3 Wiederholungen a 1.67s ~ 5s. Heilung
        private constant real INTERVAL = 1.67
        private constant real DURATION = CONSUME_COUNT * INTERVAL
        private constant string MESSAGE = "The Abomination has full health points."
        private constant integer FACTOR = 4
        private constant boolean LOSE_STRENGTH_PERMENENT = false
        
        //Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = DURATION
    endglobals

    private struct ConsumeHimself
        unit caster
        integer level = 0
        real duration = DURATION
        timer t
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer( .t )
            set .t = null
            call UnitEnableAttack(.caster)
            call ResetUnitAnimation(.caster)
            set .caster = null
        endmethod
        
        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            if this.duration <= 0.00 or IsUnitDead(this.caster) or GetUnitLifePercent(this.caster) == 100.00 then
                call this.destroy()
            else
                call SetUnitAnimation( this.caster, "stand channel" )
                call SetUnitState(this.caster, UNIT_STATE_LIFE,(0.01 * (this.level + FACTOR) * GetUnitState(this.caster,UNIT_STATE_MAX_LIFE)) + GetUnitState(this.caster, UNIT_STATE_LIFE))
            endif
            set this.duration = this.duration - INTERVAL
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .level = GetUnitAbilityLevel(caster, SPELL_ID)
            
            if GetUnitLifePercent(.caster) != 100.00 then
                set .t = NewTimer()
                call SetTimerData(.t, this)
                call TimerStart(.t, INTERVAL, true, function thistype.onPeriodic)
                call Stun_UnitEx(.caster, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
                call UnitDisableAttack(.caster)
                call IssueImmediateOrder(.caster, "holdposition" )
                static if LOSE_STRENGTH_PERMENENT then
                    call ModifyHeroStat(bj_HEROSTAT_STR, .caster, bj_MODIFYMETHOD_SUB, 1)
                endif
            else
                call UnitRemoveAbility(.caster, SPELL_ID)
                call UnitAddAbility(.caster, SPELL_ID)
                call UnitRemoveAbility(.caster, BUFF_ID)
                call SimError(Player(GetConvertedPlayerId(GetOwningPlayer(.caster)) - 1), MESSAGE)
            endif
            
            return this
        endmethod
       
     endstruct

    private function Actions takes nothing returns nothing
		call ConsumeHimself.create( GetTriggerUnit() )
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID and not CheckImmunity(SPELL_ID, GetTriggerUnit(), GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddCondition(t,Condition(function Conditions))
		call TriggerAddAction(t, function Actions )
		
		set t = null
    endfunction

endscope