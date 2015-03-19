scope RefreshingAura initializer init
    /*
     * Description: The Aura gives all nearby friendly heroes a chance to fully replenish their mana when casting a spell.
     * Last Update: 04.12.2013
     * Changelog: 
     *     04.12.2013: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: Optimized Spell-Event-Handling (conditions/actions)
     */
    globals
        private constant integer SPELL_ID = 'A07M'
        private constant integer BUFF_ID = 'B01B'
        private constant string EFFECT_1 = "Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl"
        private constant string EFFECT_2 = "Abilities\\Spells\\Items\\AIda\\AIdaCaster.mdl"
        private constant string ATT_POINT = "overhead"
        private constant integer RADIUS = 900
        
        private integer array CHANCE
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set CHANCE[1] = 3
        set CHANCE[2] = 5
        set CHANCE[3] = 7
        set CHANCE[4] = 9
        set CHANCE[5] = 11
    endfunction
    
    private struct RefreshingAura
        unit caster
        integer level = 1
        timer t
            
        static method create takes unit caster returns RefreshingAura
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .t = NewTimer()
            call SetTimerData( .t , this )
            call TimerStart(.t, 0.15, false, function thistype.onEnd)
            
            return this
        endmethod
        
        static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real maxMana = GetUnitState(this.caster, UNIT_STATE_MAX_MANA)
            local real mana = GetUnitState(this.caster, UNIT_STATE_MANA)
            
            call SetUnitState(this.caster, UNIT_STATE_MANA, mana + (maxMana - mana) )
            call DestroyEffect(AddSpecialEffectTarget(EFFECT_1, this.caster, ATT_POINT))
            call DestroyEffect(AddSpecialEffectTarget(EFFECT_2, this.caster, ATT_POINT))
            call this.destroy()
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
            set .t = null
            set .caster = null
        endmethod

    endstruct

    private function Actions takes nothing returns nothing
        call RefreshingAura.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		local unit u = GetTriggerUnit()
		local integer level = GetHighestAuraLevel(u, RADIUS, SPELL_ID)
		local boolean b = false
		
		if ( GetUnitAbilityLevel(u, BUFF_ID) > 0 and GetRandomInt(1, 100) <= CHANCE[level] ) then
			set b = true
		else
			set b = false
		endif
		
		set u = null
		
		return b
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
		call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        call MainSetup()
        call Preload(EFFECT_1)
        call Preload(EFFECT_2)
		
		set t = null
    endfunction

endscope