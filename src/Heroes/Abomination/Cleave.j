scope Cleave initializer init
    /*
     * Description: The Abominations brutal strikes hit several units at once, a bonus percentage of the damage. 
                    Theres a small chance to stun or knockback weaker units.
     * Changelog: 
     *     	09.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	22.03.2015: ATTACK_TYPE, DAMAGE_TYPE and WEAPON_TYPE specification
	 *		06.05.2015: Integrated SpellHelper for filtering
						Set struct members to private
	 *		24.03.2016: Recoded, optimized and adapted for AI System
     *
     */
	 
	private keyword Cleave
	
    globals
        private constant integer SPELL_ID = 'A064'
		private constant integer BUFF_PLACER_ID = 'A06K'
        private constant integer BUFF_ID = 'B00W'
        private constant real RADIUS = 175
        //Einheiten deren HP unter dem WEAKNESS_FACTOR sind haben ne CHANCE gestunt
        //weggestoßen zu werden
        private constant real WEAKNESS_FACTOR = 50.0
		
		// Duration
		private constant real DURATION = 10.0
        
        //Chance für STUN oder KNOCK BACK
        private constant integer array CHANCE
        
		//prozentualer Schaden
        private constant integer array DAMAGE
        
		//STUN
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = 1.5
        
		//KNOCK BACK
        private constant integer DISTANCE = 350
        private constant real KB_TIME = 0.75
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_METAL_HEAVY_CHOP
		
		private Cleave array cleaveCaster
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set CHANCE[1] = 8
        set CHANCE[2] = 10
        set CHANCE[3] = 12
        set CHANCE[4] = 14
        set CHANCE[5] = 16
        
        set DAMAGE[1] = 60
        set DAMAGE[2] = 55
        set DAMAGE[3] = 50
        set DAMAGE[4] = 45
        set DAMAGE[5] = 40
    endfunction

    private struct Cleave
        private unit caster
        private integer level = 0
        private static thistype tempthis = 0
		private static integer buffType = 0
		private dbuff buff = 0
		
		static method getForUnit takes unit u returns thistype
			return cleaveCaster[GetUnitId(u)]
		endmethod
        
        private  static method group_filter_callback takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidEnemy(u, .tempthis.caster) and /*
			*/	IsUnitType(u, UNIT_TYPE_GROUND)) then
				set b = true
			endif
			
			set u = null
			
            return b
        endmethod
		
		method onAttack takes unit damageSource, unit damagedUnit, real damage returns nothing
			local unit target
			local real x
            local real y
            local real ang
            local real propDmg = (damage * DAMAGE[.level]) / 100 
			
			call GroupClear(ENUM_GROUP)
			call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(.caster), GetUnitY(.caster), RADIUS, function thistype.group_filter_callback)
            
			loop
				set target = FirstOfGroup(ENUM_GROUP)
				exitwhen (target == null)
				
				// Damage
				if (GetUnitState(target, UNIT_STATE_LIFE) > propDmg) then
					set DamageType = SPELL
					call SpellHelper.damageTarget(.caster, target, propDmg, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
				else
					call SetUnitExploded(target, true)
					call KillUnit(target) 
				endif
				
				//Weak Unit?
				if (GetUnitLifePercent(target) <= WEAKNESS_FACTOR and not SpellHelper.isUnitDead(target)) then
					if (GetRandomInt(1, 100) <= CHANCE[.level]) then
						if (GetRandomInt(0, 1) == 0) then
							//Stun
							call Stun_UnitEx(target, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
						else
							//Knockback
							set x = GetUnitX(.caster) - GetUnitX(target)
							set y = GetUnitY(.caster) - GetUnitY(target)
							set ang = Atan2(y, x) - bj_PI
							call Knockback.create(.caster, target, DISTANCE, KB_TIME, ang, 0, "", "")
						endif
					endif
				endif
				
				call GroupRemoveUnit(ENUM_GROUP, target)
			endloop
			
			set target = null
		endmethod
		
		static method create takes unit attacker returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = attacker
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .tempthis = this
			set cleaveCaster[GetUnitId(.caster)] = this
			
			call UnitAddBuff(.caster, .caster, .buffType, DURATION, .level)
            
            return this
        endmethod
		
		private static method onBuffEnd takes nothing returns nothing
			local dbuff b = GetEventBuff()
			local thistype this = thistype(b.data)
			
			if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod
		
		private static method onBuffAdd takes nothing returns nothing
			local dbuff b = GetEventBuff()
            local thistype this = allocate()
			
			set b.data = integer(this)
			set buff = b
		endmethod
		
		static method onInit takes nothing returns nothing
			set .buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0, false, true, thistype.onBuffAdd, 0, thistype.onBuffEnd)
		endmethod

    endstruct
    
	// damageSource == Abomination
	// damagedUnit  == Target
    private function onDamageActions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local Cleave c = Cleave.getForUnit(damageSource)
        
		if ((GetUnitAbilityLevel(damageSource, BUFF_ID) > 0)	  and /*
		*/	(SpellHelper.isValidEnemy(damagedUnit, damageSource)) and /*
		*/	(DamageType == PHYSICAL)) then
			if (c != 0) then
				call c.onAttack(damageSource, damagedUnit, damage)
			endif
        endif
    endfunction
	
	private function Actions takes nothing returns nothing
        call Cleave.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call RegisterDamageResponse( onDamageActions )
        call MainSetup()
        call Preload(STUN_EFFECT)
    endfunction

endscope