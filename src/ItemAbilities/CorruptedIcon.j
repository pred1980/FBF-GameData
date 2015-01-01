scope CorruptedIcon initializer init
	/*
	 * Item: Corrupted Icon
	 */ 
    globals
        private constant integer ITEM_ID = 'I00V'
        private constant integer LIFE_TIME = 45
        private constant string EFFECT = "Abilities\\Spells\\Items\\AIvi\\AIviTarget.mdl"
    endglobals
    
    private struct Spell
        unit attacker
        unit target
        timer t
        static Spell tempthis
        
        static method create takes unit attacker, unit target returns Spell
            local Spell this = Spell.allocate()
            
            set .attacker = attacker
            set .target = target
            set .t = NewTimer()
            
            call ef(.target, EFFECT)
            call SetUnitOwner(.target, GetOwningPlayer(.attacker), true)
            call UnitApplyTimedLife( .target, 'BTLF', LIFE_TIME )
            set Spell.tempthis = this
            call SetTimerData(.t, this)
            call TimerStart(.t, LIFE_TIME, false, function thistype.onLifeTimeEnd)
            
            return this
        endmethod
        
        static method onLifeTimeEnd takes nothing returns nothing
            local Spell this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
            set .attacker = null
            set .target = null
            set .t = null
        endmethod
        
        static method onInit takes nothing returns nothing
            set Spell.tempthis = 0
        endmethod
    endstruct
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local Spell s = 0
        
        if ( UnitHasItemOfTypeBJ(damageSource, ITEM_ID) and IsPlayerEnemy(GetOwningPlayer(damageSource), GetOwningPlayer(damagedUnit)) and GetRandomInt(0, 100) <= GetHeroLevel(damageSource) and IsUnitType(damagedUnit, UNIT_TYPE_HERO) == false and DamageType == 0) then
            set s = Spell.create( damageSource, damagedUnit )
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call Preload(EFFECT)
    endfunction

endscope