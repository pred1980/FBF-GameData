scope TidalShield initializer init
    /*
     * Description: This shield makes the Naga immune to spells and boosts her life regeneration.
     * Last Update: 08.01.2014
     * Changelog: 
     *     	08.01.2014: Abgleich mit OE und der Exceltabelle + Bugfixing und kleinerem Umbau
	 *     	14.03.2014: Simplification of the code and a small bugfix
	 *     	22.04.2015: Integrated RegisterPlayerUnitEvent
	 *		26.05.2016: Changed base ability to channel and implemented spell immunity by code
     *
     */ 
    globals
        private constant integer SPELL_ID = 'A0B7'
		private constant integer BUFF_PLACER_ID = 'A07O'
        private constant integer BUFF_ID = 'B00D'
		private constant integer MAGIC_IMMUNITY_DUMMY_ID = 'A0B7'
		private constant real SPELL_DURATION = 10.0 //HEAL AND IMMUNITY
        //Heal over Time Effect
        private constant string EFFECT = ""
        private constant string ATT_POINT = ""
		
		//Has to be the same as the duration of the Buff to apply the right heal
        private real array HEAL
    endglobals
	
	private struct Data
		private unit caster
		private static integer buffType = 0
		private dbuff buff = 0
		
		method onDestroy takes nothing returns nothing
			call BJDebugMsg("onDestroy")
			set .caster = null
		endmethod
		
		private static method onEndTidalShield takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local Data data = GetTimerData(t)
		 
			call UnitRemoveAbility(data.caster, MAGIC_IMMUNITY_DUMMY_ID)
			call UnitMakeAbilityPermanent(data.caster, false, MAGIC_IMMUNITY_DUMMY_ID)
			call DestroyTimer(t)
			set t = null
			
			call thistype(GetEventBuff().data).destroy()
		endmethod
		
		static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
			local timer t = CreateTimer()
			
			set .caster = caster
			call UnitAddAbility(caster, MAGIC_IMMUNITY_DUMMY_ID)
			call UnitMakeAbilityPermanent(caster, true, MAGIC_IMMUNITY_DUMMY_ID)
		
			call SetTimerData(t, this)
			call TimerStart(t, SPELL_DURATION, false, function thistype.onEndTidalShield)
			set t = null
			set UnitAddBuff(.caster, .caster, .buffType, SPELL_DURATION, GetUnitAbilityLevel(.caster, SPELL_ID)).data = this
			
            return this
		endmethod
		
		static method onInit takes nothing returns nothing
			set .buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0, false, true, 0, 0, 0)
		endmethod
	endstruct
    
    private function MainSetup takes nothing returns nothing
        set HEAL[1] = 100
        set HEAL[2] = 150
        set HEAL[3] = 200
        set HEAL[4] = 250
        set HEAL[5] = 300
    endfunction

    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
		call Data.create(caster)
		
		call HOT.start(caster, HEAL[GetUnitAbilityLevel(caster, SPELL_ID)], SPELL_DURATION, EFFECT, ATT_POINT )

		set caster = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
	
	private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call MainSetup()
    endfunction

endscope
