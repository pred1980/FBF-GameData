scope SpiderWeb initializer init
    /*
     * Description: Spiders are known as the world best weavers. The Widow is no different, 
                    with her webs shes able to both catch her enemies and keep them at a distance. 
                    Once a vitcim is caught by her webs, it will be unable to even move a finger.
     * Changelog: 
     *     	27.10.2013: Abgleich mit OE und der Exceltabelle
	 *     	20.02.2015: Cooldown von 1s auf 0 gesetzt
	 *		26.04.2015: Code Refactoring
						Decreased the mana cost from 30 to 20 per Level
						Integrated RegisterPlayerUnitEvent
     *
     */
    globals
        private constant integer SPIDER = 'U01O'
        private constant integer CHILD_ID = 'n00C'
        private constant integer SPELL_ID = 'A005'
        private constant integer DUMMY_ID = 'h016'
        private constant integer DUMMY_SPELL_ID = 'A035'
        private constant integer WEB_AURA_ID = 'B002'
        private constant real WEB_START_DURATION = 5.5
        private constant real WEB_INCREASE_DURATION = 0.5
        private constant real SIZE = 175.0
    endglobals

    private struct SpiderWeb
        private unit caster
        private unit dummy
        private real x
        private real y
        private real duration
        private timer ti
        private integer level = 0
		
		method onDestroy takes nothing returns nothing
            call ReleaseTimer( .ti )
            set .ti = null
            set .caster = null
            set .dummy = null
        endmethod
		
		static method leaveWebActions takes nothing returns nothing
			local unit u = GetTriggerUnit()
        
			if GetUnitAbilityLevel(u, WEB_AURA_ID) > 0 then
				call UnitRemoveAbility(u, WEB_AURA_ID)
			endif
			set u = null
		endmethod
        
        static method timerCallback takes nothing returns nothing
            local thistype this = GetTimerData( GetExpiredTimer() )
            call this.destroy()
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
			local trigger t = CreateTrigger()
            
            set .caster = caster
            set .x = GetUnitX(.caster)
            set .y = GetUnitY(.caster)
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .duration = WEB_START_DURATION + (.level * WEB_INCREASE_DURATION)
        
            set .dummy = CreateUnit(GetOwningPlayer(.caster), DUMMY_ID, .x, .y, bj_UNIT_FACING)
            call UnitAddAbility( .dummy, DUMMY_SPELL_ID )
            call SetUnitAbilityLevel( .dummy, DUMMY_SPELL_ID, .level )
            call UnitApplyTimedLife( .dummy, 'BTLF', .duration )
			
			call TriggerRegisterLeaveRectSimple(t, RectFromCenterSize(.x, .y, SIZE, SIZE))
			call TriggerAddAction(t, function thistype.leaveWebActions )
			set t = null
            
            set .ti = NewTimer()
            call SetTimerData( .ti, this )
            call TimerStart( .ti, .duration, false, function thistype.timerCallback )
            
            return this
        endmethod
    endstruct
	
	private function Actions takes nothing returns nothing
		call SpiderWeb.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
	endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction

endscope