library CABuff initializer init requires CustomDummy

    globals
        private unit CASTER = null
    endglobals
    
    private function init takes nothing returns nothing
        set CASTER = CreateDummy(Player(PLAYER_NEUTRAL_PASSIVE), 0., 0.)
        call UnitAddAbility(CASTER, 'Aloc')
    endfunction
    
    module CABuff
        private integer theSpell = 0
        private integer theLevel = 0
        private integer theBuff = 0
        private string theOrder = null
        private boolean buffBased = true
        
        public method setBuff takes integer theSpell, integer theLevel, integer theBuff, string theOrder, boolean buffBased returns nothing
            set .theSpell = theSpell
            set .theLevel = theLevel
            set .theBuff = theBuff
            set .theOrder = theOrder
            set .buffBased = buffBased
        endmethod
        
        public method hasUnitBuff takes unit theUnit returns boolean
            return GetUnitAbilityLevel(theUnit, .theBuff) != 0
        endmethod
        
        method addBuff takes unit theUnit returns nothing
            call SetUnitX(CASTER, GetUnitX(theUnit))
            call SetUnitY(CASTER, GetUnitY(theUnit))
            call SetUnitOwner(CASTER, GetOwningPlayer(.theUnit), false)
            call UnitAddAbility(CASTER, .theSpell)
            call SetUnitAbilityLevel(CASTER, .theSpell, .theLevel)
            call IssueTargetOrder(CASTER, .theOrder, theUnit)
            call UnitRemoveAbility(CASTER, .theSpell)
        endmethod
        
        method removeBuff takes unit theUnit returns nothing
            call UnitRemoveAbility(theUnit, .theBuff)
        endmethod
        
        method checkBuff takes unit theUnit returns nothing
            if not .hasUnitBuff(theUnit) then
                call .addBuff(theUnit)
            endif
        endmethod
    endmodule
    
endlibrary