library MagicImmunity initializer init requires CustomAura
	/*
	 * Vorerst deaktiviert bis Anachron das neue Aura System veröffentlicht,
	 * leider ist das akt. Aura System leicht verbuggt und leakt pro Interval
	 */ 
	 
    globals
        private constant integer SPELL_BOOK = 'MIbk'
    endglobals
    
    private function init takes nothing returns nothing
        local integer i = 0
        
        loop
            exitwhen i > bj_MAX_PLAYERS
            call SetPlayerAbilityAvailable(Player(i), SPELL_BOOK, false)
            set i = i + 1
        endloop
    endfunction
    
    struct MagicImmunity extends CustomAura
    
        method activeCond takes nothing returns boolean
            return true
        endmethod
    
        method onRegister takes unit theUnit returns nothing
            call UnitAddAbility(theUnit, SPELL_BOOK)
        endmethod
        
        method onUnregister takes unit theUnit returns nothing
            call UnitRemoveAbility(theUnit, SPELL_BOOK)
        endmethod
        
        method getRadius takes nothing returns real
            return 550.
        endmethod
        
        method unitFilter takes unit theUnit returns boolean
            //: Only for alive, non-reincarnating units
            return GetUnitState(theUnit, UNIT_STATE_LIFE) > 0.40 
        endmethod
    endstruct

endlibrary