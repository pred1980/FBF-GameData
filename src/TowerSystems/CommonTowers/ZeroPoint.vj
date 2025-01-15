scope ZeroPoint
     /*
     * Description: The Obelisk will slow the attacked creeps by 30%/40%/50% for 4 seconds.
     * Last Update: 18.12.2013
     * Changelog: 
     *      18.12.2013: Abgleich mit OE und der Exceltabelle
	 *		23.02.2013: Prozente erhoeht: 20%/30%/40% auf 30%/40%/50% 
     */
    
    globals
        private constant integer BUFF_PLACER_ID = 'A09Z'
        private constant integer BUFF_ID = 'B02B'
        private real DURATION = 4.0
        private integer array TOWER_ID
    endglobals
    
    private struct ZeroPoint
        private static integer buffType = 0
        
        static method onDamage takes unit damagedUnit, unit damageSource, real damage returns nothing
            if GetUnitTypeId(damageSource) == TOWER_ID[0] or GetUnitTypeId(damageSource) == TOWER_ID[1] or GetUnitTypeId(damageSource) == TOWER_ID[2] then
                call UnitAddBuff(damageSource, damagedUnit, thistype.buffType, DURATION, TowerSystem.getTowerValue(GetUnitTypeId(damageSource), 3))
            endif
        endmethod
        
        static method onInit takes nothing returns nothing
            set TOWER_ID[0] = 'u00U'
            set TOWER_ID[1] = 'u00V'
            set TOWER_ID[2] = 'u00W'
            call RegisterDamageResponse(thistype.onDamage)
            set thistype.buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0.00, false, false, 0, 0, 0)
        endmethod
		
    endstruct

endscope