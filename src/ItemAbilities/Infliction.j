scope Infliction initializer init
	/*
	 * Item: Stormwind Shield
	 */ 
    globals
        private constant integer SPELL_ID   = 'A031'
        private constant real hitPoints = 150
        private constant real regPerSec = 25
        private constant real timeTillReg = 1.5
        private constant real damageFactor = 0.75
        private constant string colorCode = "|cff089CF7"
        private constant boolean destroy = true
        private constant boolean showBar = true
        private constant real duration = 30
    endglobals

    private struct Spell
        unit caster
        
        static method create takes unit caster returns Spell
            local Spell this = Spell.allocate()
            
            if ( UnitHasShield(caster) ) then
                call DestroyShield(caster)
            else
                call AddShield(caster, hitPoints, regPerSec, timeTillReg, damageFactor, colorCode, destroy, showBar, duration)
            endif
            
            return this
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local Spell s = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set s = Spell.create( GetTriggerUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger trig = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( trig, function Actions )
    endfunction

endscope