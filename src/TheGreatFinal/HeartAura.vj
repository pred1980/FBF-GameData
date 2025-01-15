scope HeartAura

    globals
        private constant integer SPELL_ID = 'A0AH'
        private constant integer BUFF_ID = 0
        private constant integer BUFF_SPELL = 0
        private constant string BUFF_ORDER = null
        
        private constant real INTERVAL = 1.0
    endglobals
    
    private struct Aura extends AuraTemplate
        static timer t
        //! runtextmacro AuraTemplateMethods()
        
        method getRadius takes nothing returns real
            return 800.
        endmethod
        
        method unitFilter takes unit theUnit returns boolean
            return IsUnitType(theUnit, UNIT_TYPE_HERO) and /*
            */     GetUnitRace(theUnit) == RACE_UNDEAD and /*
            */     theUnit != FinalMode.getHeart()
        endmethod
        
        method onStart takes nothing returns nothing
            set .t = NewTimer()
            call SetTimerData( .t, this )
            call TimerStart( .t, INTERVAL, true, function thistype.timerCallback )
        endmethod
        
        static method timerCallback takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call SetUnitState(theUnit, UNIT_STATE_LIFE, RMaxBJ(0, GetUnitStateSwap(UNIT_STATE_LIFE, theUnit) + this.affectedCount))
        endmethod
        
    endstruct
    
endscope