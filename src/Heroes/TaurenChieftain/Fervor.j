scope Fervor initializer init
    /*
     * Description: By using his mental power, the Tauren Chieftain increases the attack speed based on the number 
                    of allied units in the aura.
     * Changelog: 
     *     	07.01.2014: Abgleich mit OE und der Exceltabelle
	 *		30.04.2015: Integrated SpellHelper for filtering
     *
	 * Info:
	 *     Das ist eine Aura, die mit dem Custom Aura System von Anachrone läuft
     */
    globals
        private constant integer SPELL_ID = 'A07A'
        private constant integer BUFF_ID = 0
        private constant integer BUFF_SPELL = 0
        private constant string BUFF_ORDER = null
        private integer array MAX_ATTACK_SPEED
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set MAX_ATTACK_SPEED[1] = 10
        set MAX_ATTACK_SPEED[2] = 15
        set MAX_ATTACK_SPEED[3] = 20
        set MAX_ATTACK_SPEED[4] = 25
        set MAX_ATTACK_SPEED[5] = 30
    endfunction
    
    private struct Fervor extends AuraTemplate
        //! runtextmacro AuraTemplateMethods()
        integer level = 1
        
        method onLevelup takes integer newLevel returns nothing
            set level = newLevel
        endmethod
    
        method onLoop takes nothing returns nothing
            if .affectedCount <= MAX_ATTACK_SPEED[level] then
                set .as = .affectedCount
            else
                set .as = MAX_ATTACK_SPEED[level]
            endif
        endmethod
        
        method getRadius takes nothing returns real
            return 800.
        endmethod
        
        method unitFilter takes unit theUnit returns boolean
            return not (SpellHelper.isUnitDead(theUnit) and /*
			*/		    SpellHelper.isValidAlly(theUnit, .theUnit))
        endmethod
        
    endstruct

    private function init takes nothing returns nothing
        call MainSetup()
    endfunction
    
endscope