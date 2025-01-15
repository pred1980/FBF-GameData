scope BoilingBlood initializer init
     /*
     * Description: Dorians dismal presence makes the blood of all his enemies reach boiling point, 
                    burning them from within. The spells effects last as long as they stay around The Gatekeeper. 
                    When their HP falls below 25%, they have a chance to explode, dealing area damage to nearby units. 
                    Mana Concentration increases damage and explosion chance.
     * Changelog: 
     *     01.11.2013: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     02.04.2015: Integrated RegisterPlayerUnitEvent
	 	               Integrated SpellHelper for filtering and damaging
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
        private constant real EXPLODE_RADIUS = 300
        private constant real DPS_BASE = 10
        private constant real DPS_INCR = 10
        private constant real CHANCE_BASE = 0.20
        private constant real CHANCE_INCR = 0.05
        
        //DOT
        private constant real DOT_TIME = 1.00
        private constant string DOT_EFFECT = ""
        private constant string DOT_ATT_POINT = ""
        
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE_CAST = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE_CAST = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE_CAST = WEAPON_TYPE_WHOKNOWS
		
		private constant attacktype ATTACK_TYPE_EXPLODE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE_EXPLODE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE_EXPLODE = WEAPON_TYPE_WHOKNOWS
        
        private BoilingBlood array spellForUnit
    endglobals

    private struct BoilingBlood
        private unit caster
        private integer level = 0
        private integer id
        private real x
        private real y
        private real damage
        private real chance
        private real explodeDamage
        private timer t
        private group targets
        private group explodes
        private static thistype tempthis = 0
        
        static method getForUnit takes unit u returns thistype
			return spellForUnit[GetUnitId(u)]
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
		
		static method onExplode takes nothing returns nothing
            set DamageType = PHYSICAL
			call SpellHelper.damageTarget(.tempthis.caster, GetEnumUnit(), .tempthis.explodeDamage, true, true, ATTACK_TYPE_EXPLODE, DAMAGE_TYPE_EXPLODE, WEAPON_TYPE_EXPLODE)
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), .tempthis.caster)
		endmethod
		
		static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            local real x = 0.00
            local real y = 0.00

            set DamageType = SPELL
			call SpellHelper.damageTarget(.tempthis.caster, u, .tempthis.damage, false, true, ATTACK_TYPE_CAST, DAMAGE_TYPE_CAST, WEAPON_TYPE_CAST)
            
			if GetUnitState(u, UNIT_STATE_LIFE) / GetUnitState(u, UNIT_STATE_MAX_LIFE) <= 0.25 and not IsUnitType(u, UNIT_TYPE_HERO) then
                if (GetRandomReal(0,1) < .tempthis.chance) then
                    set x = GetUnitX(u)
                    set y = GetUnitY(u)
                    set .tempthis.explodeDamage = GetUnitState(u, UNIT_STATE_MAX_LIFE) *  ManaConcentration_GET_MANA_AMOUNT(.tempthis.id)
					
					call SpellHelper.explodeUnit(u)
					
					set .tempthis.explodes = NewGroup()
                    call GroupEnumUnitsInRange( .tempthis.explodes, x, y, EXPLODE_RADIUS, function thistype.group_filter_callback )
                    call ForGroup(.tempthis.explodes, function thistype.onExplode)
                endif
            endif
            
            set u = null
        endmethod
        
        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.damage = (DPS_BASE + this.level * DPS_INCR) * INTERVAL * ManaConcentration_GET_MANA_AMOUNT(this.id)
            set this.chance = (CHANCE_BASE + this.level * CHANCE_INCR) * ManaConcentration_GET_MANA_AMOUNT(this.id)
            call GroupEnumUnitsInRange(this.targets, this.x, this.y, RADIUS, function thistype.group_filter_callback)
            call ForGroup(this.targets, function thistype.onDamageTarget)
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
    endstruct
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID and /*
		*/     GetUnitTypeId(GetTriggerUnit()) != XE_DUMMY_UNITID
    endfunction
    
    private function Actions takes nothing returns nothing
        local unit u = GetTriggerUnit()
		local BoilingBlood bb = BoilingBlood.getForUnit(u)
		
		if bb == 0 then
			set bb = BoilingBlood.create(u, GetSpellTargetX(), GetSpellTargetY())
		else
			call bb.onDestroy()
		endif
		
		set u = null
    endfunction

    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function Conditions, function Actions)
	endfunction
    
endscope