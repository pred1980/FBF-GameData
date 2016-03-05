scope IceShard initializer Init
    /*
     * Description: This tower fires an ice shard towards an enemy. After a distance of 300 the ice shard splits into 2
	   new shards which will split again. If a shard collides with an enemy it deals low spell damage. 
	   There is a maximum of 3/4/5 splits.
     * Last Update: 13.12.2013
     * Changelog: 
     *     13.12.2013: Implementierung
     *     30.12.2013: Fertigstellung und an den Tower gebunden
     */
    globals
        private constant string ICE_EFFECT = "Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl"
        private constant string MISSILE_MODEL = "Abilities\\Weapons\\ColdArrow\\ColdArrowMissile.mdl"
        private constant real MISSILE_SCALE = 1.5
        private constant real MISSILE_SPEED = 1100.0
        private constant real ARC_MIN = 0.
        private constant real ARC_MAX = 0.1
        private constant real Z_START = 0.
        private constant real Z_END = 0.
        private constant real START_DAMAGE = 0
        private constant real DAMAGE_INCREASE = 100
        private constant integer RADIUS = 350
		
		private constant integer array TOWER_ID
		private constant integer array MAX_SPLITS
		private constant integer CHANCE = 25
		private constant real SLOW_DURATION = 8.
		private constant real SLOW_MULTIPLIER_LEVEL1 = .08
        private constant real SLOW_MULTIPLIER_LEVEL2 = .12
        private constant real SLOW_MULTIPLIER_LEVEL3 = .16
        
        private xedamage damageOptions
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
        set d.dtype = DAMAGE_TYPE_COLD   
        set d.atype = ATTACK_TYPE_NORMAL 
        
        set d.exception = UNIT_TYPE_STRUCTURE 
    endfunction
    
    struct Shard extends xehomingmissile
        unit tower //Tower
        unit target  //Ziel
        integer level = 0
        real ms //movementspeed
		private static thistype temp
        
        method onDestroy takes nothing returns nothing
            call SetUnitMoveSpeed(.target, .ms)
            set .tower = null
            set .target = null
        endmethod
        
        private static method slowUnit takes unit target, integer level returns nothing
			local real ms = GetUnitMoveSpeed(target)
			local timer t = NewTimer()
			
			call SetTimerData(t, .temp)
			call TimerStart(t, SLOW_DURATION, false, function thistype.onSlowEnd)
			
			//Slow Unit
			if ms > 0 then
				if level == 1 then
					call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, R2I(-1.*ms*SLOW_MULTIPLIER_LEVEL1))
				elseif level == 2 then
					call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, R2I(-1.*ms*SLOW_MULTIPLIER_LEVEL2))
				elseif level == 3 then
					call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, R2I(-1.*ms*SLOW_MULTIPLIER_LEVEL3))
				else
					debug call BJDebugMsg("Unrecognized Shard level!")
				endif
			endif
			set t = null
		endmethod
		
		private static method onSlowEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
			call ReleaseTimer(GetExpiredTimer())
			call this.terminate()
        endmethod
        
        //tower: Tower
        //shardTarget: Ziel hinter dem ersten Ziel, was getroffen wurde
        //target: erstes Ziel
        static method create takes unit tower, unit shardTarget, unit target, integer level returns thistype
            local thistype this = thistype.allocate(GetWidgetX(target), GetWidgetY(target), Z_START, shardTarget, Z_END)
            
            set this.fxpath = MISSILE_MODEL
            set this.scale = MISSILE_SCALE / 2
            set this.tower = tower
            set this.target = shardTarget
            set this.level = level
			set this.temp = this
            set this.ms = GetUnitMoveSpeed(this.target)
            
            call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
            
            return this
        endmethod
        
        method loopControl takes nothing returns nothing
            if not IsTerrainWalkable(this.x, this.y) then
                call this.terminate()
            endif
        endmethod
        
        method onHit takes nothing returns nothing
            if (damageOptions.allowedTarget(this.tower, this.target )) then
                set DamageType = SPELL
                call UnitDamageTarget(this.tower, this.target, (START_DAMAGE + DAMAGE_INCREASE * this.level)/2, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
			endif
            
            call slowUnit(this.target, this.level)
        endmethod
	    
    endstruct
    
    private struct IceShard extends xehomingmissile
        unit tower
        unit target
        group targets
        integer level
        static thistype tempthis
        
        static method create takes unit tower, unit target, integer level returns thistype
            local thistype this = thistype.allocate(GetWidgetX(tower), GetWidgetY(tower), Z_START, target, Z_END)
            
            set this.fxpath = MISSILE_MODEL
            set this.scale = MISSILE_SCALE
            set this.tower = tower
            set this.target = target
            set this.level = level
            set .targets = NewGroup()
            set this.tempthis = this
            
            call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
            
            return this
        endmethod
        
        method onHit takes nothing returns nothing
            local unit u
            local integer i = MAX_SPLITS[this.level]
            local real x = GetUnitX(this.target)
            local real y = GetUnitY(this.target)
            local Shard s = 0
            
            if (damageOptions.allowedTarget(this.tower, this.target )) then
                set DamageType = SPELL
                call UnitDamageTarget(this.tower, this.target, START_DAMAGE + DAMAGE_INCREASE * this.level, false, false, ATTACK_TYPE_PIERCE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
				call DestroyEffect(AddSpecialEffect(ICE_EFFECT,GetUnitX(this.target),GetUnitY(this.target)))
            endif
            
            loop
                set i = i - 1
                set u = GetClosestUnitInRange(GetUnitX(this.target),GetUnitY(this.target), RADIUS, Condition(function thistype.filterCallback))
                if u != null then
                    call GroupAddUnit(this.targets, u)
                    set s = Shard.create(this.tower, u, this.target, this.level)
                endif
                exitwhen i == 0
            endloop
            
            call this.terminate()
        endmethod
        
        static method filterCallback takes nothing returns boolean
            return GetFilterUnit() != .tempthis.target and not /*
            */     IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) and not /*
            */     IsUnitDead(GetFilterUnit()) and not /*
            */     IsUnitInGroup(GetFilterUnit(), .tempthis.targets) and not /*
            */     IsUnitAlly(GetFilterUnit(), GetOwningPlayer(.tempthis.tower))
        endmethod
       
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(.targets)
            set .targets = null
            set .tower = null
            set .target = null
        endmethod
    endstruct
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
		local integer i = 0
		
		if GetRandomInt(0, 100) <= CHANCE and DamageType == PHYSICAL then
			loop
				exitwhen i > 2
				if GetUnitTypeId(damageSource) == TOWER_ID[i] then
					call IceShard.create(damageSource, damagedUnit, i+1)
				endif
				set i = i + 1
			endloop
		endif
    endfunction
   
    private function Init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
		
        set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)
		
        //Init Towers
        set TOWER_ID[0] = 'u01J'
        set TOWER_ID[1] = 'u01K'
        set TOWER_ID[2] = 'u01L'
		
		set MAX_SPLITS[0] = 3
		set MAX_SPLITS[1] = 4
		set MAX_SPLITS[2] = 5

        call Preload(MISSILE_MODEL)
        call Preload(ICE_EFFECT)
    endfunction
endscope
