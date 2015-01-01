scope CorpseExplosion initializer init
	/*
	 * Ability: Corpse Explosion
     * Description: Explodes a corpse within 1000 range of the tower, causing enemies in 300 range of the corpse to 
	   take 8%/11%/14% more damage from darkness towers and move 8%/12%/16% slower for 8 seconds. 15 second cooldown. 
	   Doesnt affect Air.
     * Last Update: 20.12.2013
     * Changelog: 
     *     20.12.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer array TOWER_ID
        private constant integer BUFF_PLACER_ID = 'A0AM'
		private constant integer BUFF_ID = 'B02L'
        private constant real ENUM_RADIUS = 1000.
        private constant real EXPLODE_RADIUS = 300.
        private constant real DEBUFF_DURATION = 8.
        private constant real BONUS_DAMAGE_MULTIPLIER_LEVEL1 = .08
        private constant real BONUS_DAMAGE_MULTIPLIER_LEVEL2 = .11
        private constant real BONUS_DAMAGE_MULTIPLIER_LEVEL3 = .13
        private constant real SLOW_MULTIPLIER_LEVEL1 = .08
        private constant real SLOW_MULTIPLIER_LEVEL2 = .12
        private constant real SLOW_MULTIPLIER_LEVEL3 = .16
        private constant boolean IGNORE_AIR = true
        private constant string EXPLODE_MODEL = "Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl"
		private constant integer PRIORITY = 0
        
        //Stun Effect
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = DEBUFF_DURATION
    endglobals
    
    private struct BonusDamage extends DamageModifier
		unit target
		integer level
        real ms // movementspeed
	
		static method create takes unit target, integer level returns thistype
			local thistype this = thistype.allocate(target, PRIORITY)
			
			set .target = target
			set .level = level
            set .ms = GetUnitMoveSpeed(.target)
			
			return this
		endmethod
		
		method onDamageTaken takes unit damageSource, real damage returns real
			if GetUnitAbilityLevel(this.target, BUFF_ID) > 0 and not IsUnitDead(this.target) then
				if this.level == 1 then
					return damage * BONUS_DAMAGE_MULTIPLIER_LEVEL1
				elseif this.level == 2 then
					return damage * BONUS_DAMAGE_MULTIPLIER_LEVEL2
				elseif this.level == 3 then
					return damage * BONUS_DAMAGE_MULTIPLIER_LEVEL3
				endif
			else
				call this.destroy()
			endif
			return 0.
		endmethod
		
		method onDestroy takes nothing returns nothing
            call SetUnitMoveSpeed(.target, .ms)
			set .target = null
		endmethod
	
	endstruct
	
	private struct CorpseExplosion
        static integer buffType = 0
        unit summonedUnit
		unit tower
        integer level = 0
		group g
		player p
		private static thistype array owners
		private static integer count = 0
		private integer index
		
        static method create takes unit tower, unit summonedUnit, integer level returns thistype
            local thistype this = thistype.allocate()
            
            set .summonedUnit = summonedUnit
			set .tower = tower
			set .level = level
			set .g = NewGroup()
			set .p = GetOwningPlayer(.summonedUnit)
			set thistype.owners[GetUnitId(summonedUnit)] = this
			set this.index = thistype.count
			set thistype.count = thistype.count + 1
            
            //rend Corpse
			call rendCorpse(.g, .tower, .summonedUnit, .p, .level)
            
            return this
        endmethod
		
		private static method rendCorpse takes group grp, unit tower, unit summonedUnit, player p, integer level returns nothing
			local integer count = 0
            local unit u = null
			local real x = GetUnitX(summonedUnit)
			local real y = GetUnitY(summonedUnit)
            local thistype this = getInstance(tower, summonedUnit, level)
            local timer t = NewTimer()
			
			call GroupEnumUnitsInRange(grp, x, y, EXPLODE_RADIUS, null)
			
            loop
				set u = FirstOfGroup(grp)
				exitwhen u == null
				if  IsUnitEnemy(u, p) and not /*
                */  IsUnitDead(u) and not /*
                */  IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not /*
                */  IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL) and not /*
                */  IsUnitType(u, UNIT_TYPE_FLYING) and  u != null then
                        call debuffUnit(tower, summonedUnit, u, level)
                        set count = count + 1
				endif
                call GroupRemoveUnit(grp, u)
                set u = null
			endloop
			
			call DestroyEffect(AddSpecialEffect(EXPLODE_MODEL, x, y))
			call RemoveUnit(u)
            
            //Wenn keine Einheit in der N?he war dann zerst?re das struct
            if count == 0 then
                set t = null
                call this.destroy()
                return
            endif
            
            call SetTimerData(t, this)
			call TimerStart(t, DEBUFF_DURATION, false, function thistype.onCooldownEnd)
            
            //Hide and stun summoned Unit
            call ShowUnit(summonedUnit, false)
            call Stun_UnitEx(summonedUnit, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
		endmethod
        
		private static method debuffUnit takes unit tower, unit summonedUnit, unit u, integer level returns nothing
			local real ms = GetUnitMoveSpeed(u)
			local thistype this = getInstance(tower, summonedUnit, level)
			
			//Add Damage
			call UnitAddBuff(this.tower, u, thistype.buffType, DEBUFF_DURATION, this.level)
			call BonusDamage.create(u, this.level)
			
			//Slow Unit
			if ms > 0 then
				if level == 1 then
					call SetUnitBonus(u, BONUS_MOVEMENT_SPEED, R2I(-1.*ms*SLOW_MULTIPLIER_LEVEL1))
				elseif level == 2 then
					call SetUnitBonus(u, BONUS_MOVEMENT_SPEED, R2I(-1.*ms*SLOW_MULTIPLIER_LEVEL2))
				elseif level == 3 then
					call SetUnitBonus(u, BONUS_MOVEMENT_SPEED, R2I(-1.*ms*SLOW_MULTIPLIER_LEVEL3))
				else
					debug call BJDebugMsg("Unrecognized CorpseExplosion level!")
				endif
			endif
		endmethod
		
		static method onCooldownEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
			call ReleaseTimer(GetExpiredTimer())
			call this.destroy()
        endmethod
		
		private method onDestroy takes nothing returns nothing
            set thistype.owners[GetUnitId(.summonedUnit)] = thistype(0)
			set thistype.count = thistype.count - 1
            call KillUnit(.summonedUnit)
			set .summonedUnit = null
			call ReleaseGroup(.g)
			set .g = null
		endmethod
		
		private static method getInstance takes unit tower, unit summonedUnit, integer level returns thistype
			if thistype.owners[GetUnitId(summonedUnit)] == 0 then
				return thistype.create(tower, summonedUnit, level)
			else
				return thistype.owners[GetUnitId(summonedUnit)]
			endif
		endmethod
        
		//getter
        private static method operator[] takes unit summonedUnit returns thistype
			return thistype.owners[GetUnitId(summonedUnit)]
		endmethod
		
		//setter
		private static method operator[]= takes unit summonedUnit, thistype i returns nothing
			set thistype.owners[GetUnitId(summonedUnit)] = i
		endmethod
		
		static method onInit takes nothing returns nothing
            set thistype.buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0.00, false, false, 0, 0, 0)
        endmethod
		
    endstruct
    
    private function Actions takes nothing returns nothing
		local integer i = 0
		
		loop
			exitwhen i > 2
			if GetUnitTypeId(GetSummoningUnit()) == TOWER_ID[i] then
				call CorpseExplosion.create(GetSummoningUnit(), GetSummonedUnit(), i+1)
			endif
			set i = i + 1
		endloop
	 endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        //Init Tower Summon Event
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SUMMON )
        call TriggerAddAction( t, function Actions )
        
        //Init Towers
        set TOWER_ID[0] = 'u01D'
        set TOWER_ID[1] = 'u01E'
        set TOWER_ID[2] = 'u01F'
        
        set t = null
    endfunction

endscope