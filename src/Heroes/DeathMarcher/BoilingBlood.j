scope BoilingBlood initializer init
     /*
     * Description: Dorians dismal presence makes the blood of all his enemies reach boling point, 
                    burning them from within. The spells effects last as long as they stay around The Gatekeeper. 
                    When their HP falls below 25%, they have a chance to implode, dealing area damage to nearby units. 
                    Mana Concentration increases damage and implosion chance.
     * Last Update: 01.11.2013
     * Changelog: 
     *     01.11.2013: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
     *
	 * Note:
	 *     EVENT_PLAYER_UNIT_SPELL_FINISH --> Das Event hatte Gerald noch zusätzlich drin aber es scheint besser 
											  ohne zu sein, da sonst die onDestroy in der Actions nochmal aufgerufen 
											  wird, wenn der Spell zu ende ist.
     */
    private keyword BoilingBlood
    
    globals
        private constant integer SPELL_ID = 'A053'
        private constant real INTERVAL = 1.0
        private constant real DURATION = 15
        private constant real RADIUS = 400
        private constant real EXPLODE_RADIUS = 100
        private constant real DPS_BASE = 10
        private constant real DPS_INCR = 10
        private constant real CHANCE_BASE = 0.02
        private constant real CHANCE_INCR = 0.02
        
        //DOT
        private constant real DOT_TIME = 1.00
        private constant string DOT_EFFECT = ""
        private constant string DOT_ATT_POINT = ""
        private constant attacktype ATT_TYPE = ATTACK_TYPE_HERO
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_NORMAL
        
        private BoilingBlood array spellForUnit
    endglobals

    private struct BoilingBlood
        unit caster
        integer level = 0
        integer id
        real x
        real y
        real damage
        real chance
        real explodeDamage
        timer t
        group targets
        group explodes
        static BoilingBlood tempthis
        
        static method getForUnit takes unit u returns thistype
			return spellForUnit[GetUnitId(u)]
		endmethod
        
        static method create takes unit caster, real tx, real ty returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .id = GetPlayerId(GetOwningPlayer(.caster))
            set .x = GetSpellTargetX()
            set .y = GetSpellTargetY()
            set .targets = NewGroup()
            set spellForUnit[GetUnitId(.caster)] = this
            set .tempthis = this
            
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, INTERVAL, true, function thistype.onPeriodic)
            
            return this
        endmethod
        
        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.damage = (DPS_BASE + this.level * DPS_INCR) * INTERVAL * ManaConcentration_GET_MANA_AMOUNT(this.id)
            set this.chance = (CHANCE_BASE + this.level * CHANCE_INCR) * ManaConcentration_GET_MANA_AMOUNT(this.id)
            call GroupEnumUnitsInRange(this.targets, this.x, this.y, RADIUS, function thistype.group_filter_callback)
            call ForGroup(this.targets, function thistype.onDamageTarget)
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return not IsUnitDead(GetFilterUnit()) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_UNDEAD) and not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            local real x
            local real y
            //set DamageType = SPELL
            //call DOT.start( .tempthis.caster , u , .tempthis.damage , DOT_TIME , ATT_TYPE , DMG_TYPE , DOT_EFFECT , DOT_ATT_POINT )
            set DamageType = SPELL
            call UnitDamageTarget(.tempthis.caster, u, .tempthis.damage, false, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNKNOWN, WEAPON_TYPE_WHOKNOWS)
            
			if GetUnitState(u, UNIT_STATE_LIFE) / GetUnitState(u, UNIT_STATE_MAX_LIFE) <= 0.25 and not IsUnitType(u, UNIT_TYPE_HERO) then
                if GetRandomReal(0,1) < .tempthis.chance then
                    set x = GetUnitX(u)
                    set y = GetUnitY(u)
                    set .tempthis.explodeDamage = GetUnitState(u,UNIT_STATE_LIFE)
                    call SetUnitExploded(u, true)
                    set DamageType = SPELL
                    call UnitDamageTarget(.tempthis.caster, u, 9999999, false, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNKNOWN, WEAPON_TYPE_WHOKNOWS)
                    set .tempthis.explodes = NewGroup()
                    call GroupEnumUnitsInRange( .tempthis.explodes, x, y, EXPLODE_RADIUS, function thistype.group_filter_callback )
                    call ForGroup(.tempthis.explodes, function thistype.onExplode)
                endif
            endif
            
            set u = null
        endmethod
        
        static method onExplode takes nothing returns nothing
            local unit u = GetEnumUnit()
            set DamageType = 1
            call UnitDamageTarget(.tempthis.caster, u, .tempthis.explodeDamage, false, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNKNOWN, WEAPON_TYPE_WHOKNOWS)
            set u = null
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer( .t )
            call ReleaseGroup( .targets )
            call ReleaseGroup( .explodes )
            set spellForUnit[GetUnitId(.caster)] = 0
            set .caster = null
            set .targets = null
            set .explodes = null
            set .t = null
        endmethod
        
        static method onInit takes nothing returns nothing
            set .tempthis = 0
        endmethod
    endstruct
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID and /*
		*/     GetUnitTypeId(GetTriggerUnit()) != XE_DUMMY_UNITID
    endfunction
    
    private function Actions takes nothing returns nothing
        local BoilingBlood bb = 0
		local unit u = GetTriggerUnit()
        
        set bb = BoilingBlood.getForUnit(u)
		
		if bb == null then
			set bb = BoilingBlood.create(u, GetSpellTargetX(), GetSpellTargetY())
		else
			call bb.onDestroy()
		endif
		
		set u = null
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_ENDCAST )
        //call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_FINISH )
        call TriggerAddCondition(t, function Conditions)
        call TriggerAddAction( t, function Actions )
    endfunction
    
endscope