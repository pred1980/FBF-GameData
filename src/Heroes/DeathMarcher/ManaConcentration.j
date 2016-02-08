library ManaConcentration initializer init requires TimerUtils
    /*
     * Description: Dorian sacrifices half of his current Mana to amplify the effects of his spells. 
                    The bonus is greater the more Mana is sacrificed.
     * Changelog: 
     *     01.11.2013: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     31.03.2015: Integrated RegisterPlayerUnitEvent
     *
     */
    globals
        private constant integer SPELL_ID = 'A04X'
		private constant integer BUFF_PLACER_ID = 'A052'
        private constant integer BUFF_ID = 'B00I'
        private constant real SACRIFICED = 0.5 //50%
        private constant real array DURATION
        private constant boolean SHOW_MESSAGE = false
        
        private real array ManaAmount
    endglobals
    
    public function GET_MANA_AMOUNT takes integer id returns real
        return ManaAmount[id]
    endfunction
    
    private function MainSetup takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_PLAYERS
            set ManaAmount[i] = 1.0
            set i = i + 1
        endloop
        
        set DURATION[1] = 10
        set DURATION[2] = 15
        set DURATION[3] = 20
        set DURATION[4] = 25
        set DURATION[5] = 30
    endfunction

    private struct ManaConcentration
        private unit caster
        private unit dummy
        private integer level = 0
        private integer id = 0
        private real mana
        private real maxMana
        private real percent
		private static integer buffType = 0
		private dbuff buff = 0
		
		method onDestroy takes nothing returns nothing
            set .caster = null
            set .dummy = null
        endmethod
		
		static method onBuffEnd takes nothing returns nothing
			local dbuff b = GetEventBuff()
			local thistype this = thistype(b.data)
			
			//Reset ManaAmout Multiplier
            set ManaAmount[.id] = 1.0
            
			if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod
		
		static method onBuffAdd takes nothing returns nothing
			local dbuff b = GetEventBuff()
            local thistype this = allocate()
			
			set b.data = integer(this)
			set buff = b
		endmethod
		
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .id = GetPlayerId(GetOwningPlayer(.caster))
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .mana = GetUnitState(.caster, UNIT_STATE_MANA)
            set .maxMana = GetUnitState(.caster, UNIT_STATE_MAX_MANA)
            set .percent = .mana / .maxMana
            
			//save Mana Amount Multiplier for Player
            set ManaAmount[.id] = ( percent * ( SACRIFICED + ( SACRIFICED * I2R(.level) ) ) ) + 1
            call SetUnitState( .caster, UNIT_STATE_MANA, .mana/2 )
            
            static if SHOW_MESSAGE then
                call DisplayTextToPlayer( GetOwningPlayer(.caster),0,0, "Mana sacrificed: " + R2S(.mana/2) + " Multiplier: " + R2SW(ManaAmount[.id],3,2))
            endif

			call UnitAddBuff(.caster, .caster, .buffType, DURATION[.level], .level)
			
            return this
        endmethod
		
		static method onInit takes nothing returns nothing
			set .buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0, false, true, thistype.onBuffAdd, 0, thistype.onBuffEnd)
		endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call ManaConcentration.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		
		call MainSetup()
    endfunction

endlibrary