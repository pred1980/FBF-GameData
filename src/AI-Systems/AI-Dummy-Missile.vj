scope AIDummyMissile
    /*
     * Description: Shoots a dummy missile to test if the target is reachable.
     * Changelog: 
     *     	27.04.2016: Initial Release
     */
    
    globals
        private constant integer SPELL_ID = 'A075'
		private constant integer BUFF_PLACER_ID = 'A0B3'
        private constant integer BUFF_ID = 'B00N'
        private constant string MISSILE_MODEL = ""
        private constant real MISSILE_SCALE = 1.3
        private constant real MISSILE_SPEED = 100000.0
        private constant real Z_START = 0.
        private constant real Z_END = 0.
		private constant real DURATION = 2.0
    endglobals
    
    struct AIDummyMissile extends xehomingmissile
        private unit caster
        private unit target
		
		private static integer buffType = 0
		private dbuff buff = 0
		
		method onDestroy takes nothing returns nothing
            set .caster = null
            set .target = null
        endmethod

        method loopControl takes nothing returns nothing
			if not IsTerrainWalkable(this.x, this.y) then
                call .terminate()
            endif
        endmethod
        
        method onHit takes nothing returns nothing
			if (not SpellHelper.isUnitDead(.target)) then
				// Add Buff for 2s
				set UnitAddBuff(.target, .target, .buffType, DURATION, 1).data = this
			endif
		endmethod
       
		static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate(GetWidgetX(caster), GetWidgetY(caster), Z_START, target, Z_END)
            
            set this.fxpath = MISSILE_MODEL
            set this.scale = MISSILE_SCALE
            set this.caster = caster
            set this.target = target
			
            call launch(MISSILE_SPEED, .0)
			
            return this
        endmethod
		
		static method onInit takes nothing returns nothing
			set .buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0, false, true, 0, 0, 0)
		endmethod
       
    endstruct

endscope