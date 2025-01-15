scope ColdWrath
    /*
     * eeve.org / Tower: Frosty Rock | Ability: Glacial Wrath
     * Description: Attacks of this tower slow the attacked creep by 7%/9%/11% for 3 seconds. 
     *              Each attack has a 2% chance to stun the target for 0.8 seconds and to deal 100 spelldamage to the target. 
     *              The chance to stun the target will increase by 2% per attack and resets after a target is stunned.
     * Last Update: 19.12.2013
     * Changelog: 
     *     19.12.2013: Abgleich mit OE und der Exceltabelle
     */
     
    private keyword ColdWrath
    
    globals
        private constant integer BUFF_PLACER_ID = 'A09X'
        private constant integer BUFF_ID = 'B02K'
        private constant integer CHANCE_INCREASE = 2
        private constant attacktype at = ATTACK_TYPE_PIERCE
        private constant damagetype dt = DAMAGE_TYPE_COLD
        
        private real array DAMAGE
        private real DURATION = 3.0
        private integer array TOWER_TYP
        private ColdWrath array coldWrathForUnit
        
        //Stun Effect
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = 0.8
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DAMAGE[1] = 100
        set DAMAGE[2] = 200
        set DAMAGE[3] = 300
    endfunction
    
    private struct ColdWrath
        integer level = 0
        integer chance = 0
        unit target
        timer t //clean up Timer
        real duration = 60.
        ColdWrath tempthis
        
        static integer buffType = 0
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer( .t )
            set .t = null
        endmethod
        
        static method getForUnit takes unit u returns thistype
            return coldWrathForUnit[GetUnitId(u)]
		endmethod
        
        method getTargetId takes nothing returns integer
            return GetUnitId(.tempthis.target)
        endmethod
        
        method onIncreaseStun takes unit damagedUnit, unit damageSource returns nothing
		    set .tempthis.chance = .tempthis.chance + CHANCE_INCREASE
            if GetRandomInt(0,100) <= .tempthis.chance then
                set .tempthis.level =  TowerSystem.getTowerValue(GetUnitTypeId(damageSource), 3)
                set DamageType = SPELL
                call UnitDamageTarget(damageSource, damagedUnit, DAMAGE[.tempthis.level], false, false, at, dt, WEAPON_TYPE_WHOKNOWS)
                call Stun_UnitEx(damagedUnit, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
                set .tempthis.chance = 0
            endif
		endmethod
        
        static method onDamage takes unit damagedUnit, unit damageSource, real damage returns nothing
            local thistype cw = 0
            
            if GetUnitTypeId(damageSource) == TOWER_TYP[0] or GetUnitTypeId(damageSource) == TOWER_TYP[1] or GetUnitTypeId(damageSource) == TOWER_TYP[2] then
                set cw = thistype.getForUnit(damageSource)
                if cw == null or cw.getTargetId() != GetUnitId(damagedUnit) then
                    set cw = thistype.create(damagedUnit, damageSource)
                else
                   call cw.onIncreaseStun(damagedUnit, damageSource)
                endif
                
                call UnitAddBuff(damageSource, damagedUnit, thistype.buffType, DURATION, TowerSystem.getTowerValue(GetUnitTypeId(damageSource), 3))
            endif
        endmethod
        
        static method onCleanUp takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
        static method create takes unit damagedUnit, unit damageSource returns thistype
            local thistype this = thistype.allocate()
            
            set .target = damagedUnit
            set .t = NewTimer()
            set .tempthis = this
			set coldWrathForUnit[GetUnitId(damageSource)] = this
            
            call SetTimerData(.t, this)
            call TimerStart(.t, duration, false, function thistype.onCleanUp)
            
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set TOWER_TYP[0] = 'u016'
            set TOWER_TYP[1] = 'u017'
            set TOWER_TYP[2] = 'u018'
            call RegisterDamageResponse(thistype.onDamage)
            set thistype.buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0.00, false, false, 0, 0, 0)
            call MainSetup()
        endmethod
		
    endstruct

endscope