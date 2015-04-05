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
        private constant integer SPELL_ID = 'A052'
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
        unit caster
        unit dummy
        integer level = 0
        integer id = 0
        real mana
        real maxMana
        real percent
        timer t
		
		method onDestroy takes nothing returns nothing
            call ReleaseTimer( .t )
            set .t = null
            set .caster = null
            set .dummy = null
        endmethod
		
		static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            //Reset ManaAmout Multiplier
            set ManaAmount[.id] = 1.0
            call this.destroy()
        endmethod

        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .id = GetPlayerId(GetOwningPlayer(.caster))
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .mana = GetUnitState(.caster, UNIT_STATE_MANA)
            set .maxMana = GetUnitState(.caster, UNIT_STATE_MAX_MANA)
            set .percent = .mana / .maxMana
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, DURATION[.level], false, function thistype.onEnd)
            //save Mana Amount Multiplier for Player
            set ManaAmount[.id] = ( percent * ( SACRIFICED + ( SACRIFICED * I2R(.level) ) ) ) + 1
            call SetUnitState( .caster, UNIT_STATE_MANA, .mana/2 )
            
            static if SHOW_MESSAGE then
                call DisplayTextToPlayer( GetOwningPlayer(.caster),0,0, "Mana sacrificed: " + R2S(.mana/2) + " Multiplier: " + R2SW(ManaAmount[.id],3,2))
            endif
            
            return this
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