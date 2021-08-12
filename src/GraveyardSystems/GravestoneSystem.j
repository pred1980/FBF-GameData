scope GravestoneSystem

    globals
		private constant integer MAX_GRAVESTONES = 10
        private constant integer MAX_GRAVESTONE_TYPES = 3
        private constant integer MAX_GRAVESTONE_AREAS = 3
        private constant integer GRAVESTONE_SMALL = 'B006'
        private constant integer GRAVESTONE_MEDIUM = 'B007'
        private constant integer GRAVESTONE_LARGE = 'B008'
        
        private constant integer ZOMBIE_SMALL = 'n00D'
        private constant integer ZOMBIE_MEDIUM = 'n00E'
        private constant integer ZOMBIE_LARGE = 'n00F'
        
        private constant real LIFE_TIME = 300.0
		private constant integer GRAVESTONE_PER_RECT = 1
        private constant real MIN_TIME = 30.0
        private constant real MAX_TIME = 45.0
        
        private constant string ZOMBIE_SPAWN_EFFECT = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
        
        private constant integer INCREASED_GRAVESTONE_HP_PER_ROUND = 100
        private constant integer INCREASED_ZOMBIE_HP_PER_ROUND = 150
        private constant integer INCREASED_ZOMBIE_DAMAGE_PER_ROUND = 15
        
        private integer array GRAVESTONE_TYPES
        private integer array GRAVESTONE_X_ZOMBIES
        private rect array GRAVESTONE_SPAWN_RECTS
        
		private integer array GRAVESTONE_START_HP
        private integer array ZOMBIE_START_HP
        private integer array ZOMBIE_START_DAMAGE
        
        //Diese Faktoren beschreibt die Erhöhung der HP/Damage Werte je nach Spieleranzahl
        private constant real HP_FACTOR = 0.5
        private constant real DAMAGE_FACTOR = 0.75
        
		private integer counter = 0
	endglobals

    private function MainSetup takes nothing returns nothing
        set GRAVESTONE_SPAWN_RECTS[0] = gg_rct_GravestoneRect0
        set GRAVESTONE_SPAWN_RECTS[1] = gg_rct_GravestoneRect1
        set GRAVESTONE_SPAWN_RECTS[2] = gg_rct_GravestoneRect2
        
        set GRAVESTONE_TYPES[0] = GRAVESTONE_SMALL
        set GRAVESTONE_TYPES[1] = GRAVESTONE_MEDIUM
        set GRAVESTONE_TYPES[2] = GRAVESTONE_LARGE
        
        set GRAVESTONE_X_ZOMBIES[0] = ZOMBIE_SMALL
        set GRAVESTONE_X_ZOMBIES[1] = ZOMBIE_MEDIUM
        set GRAVESTONE_X_ZOMBIES[2] = ZOMBIE_LARGE
        
        set GRAVESTONE_START_HP[0] = 180
        set GRAVESTONE_START_HP[1] = 360
        set GRAVESTONE_START_HP[2] = 540
        
        set ZOMBIE_START_HP[0] = 400
        set ZOMBIE_START_DAMAGE[0] = 11
        
        set ZOMBIE_START_HP[1] = 800
        set ZOMBIE_START_DAMAGE[1] = 22
        
        set ZOMBIE_START_HP[2] = 1200
        set ZOMBIE_START_DAMAGE[2] = 33
    endfunction
    
    struct Gravestone
        boolean removed = false
        static thistype tempthis
        static integer counter = 0
        
        static method create takes integer i returns thistype
            local thistype this = thistype.allocate()
			local trigger t = CreateTrigger()
            local real x = GetRandomReal(GetRectMinX(GRAVESTONE_SPAWN_RECTS[i]), GetRectMaxX(GRAVESTONE_SPAWN_RECTS[i]))
            local real y = GetRandomReal(GetRectMinY(GRAVESTONE_SPAWN_RECTS[i]), GetRectMaxY(GRAVESTONE_SPAWN_RECTS[i]))
            local integer rnd = 0
            local destructable g
            
            loop
                exitwhen IsTerrainWalkable(x,y)
                set x = GetRandomReal(GetRectMinX(GRAVESTONE_SPAWN_RECTS[i]), GetRectMaxX(GRAVESTONE_SPAWN_RECTS[i]))
                set y = GetRandomReal(GetRectMinY(GRAVESTONE_SPAWN_RECTS[i]), GetRectMaxY(GRAVESTONE_SPAWN_RECTS[i]))
            endloop
            
            set rnd = GetRandomInt(0,2)
            set g = CreateDestructable(GRAVESTONE_TYPES[rnd], x, y, bj_UNIT_FACING, 1.0, GetRandomInt(0,359))
            call SetDestructableMaxLife(g, I2R(GRAVESTONE_START_HP[rnd] + ( RoundSystem.actualRound * INCREASED_GRAVESTONE_HP_PER_ROUND)))
            
            call TriggerRegisterDeathEvent(t, g )
            call TriggerAddAction(t, function thistype.onGravestoneDeath )
            
            set .counter = .counter + 1
            set .tempthis = this
            
            set t = null
            set g = null
            return this
        endmethod
        
        static method onGravestoneDeath takes nothing returns nothing
            local destructable d = GetDyingDestructable() 
            local integer id = GetDestructableTypeId(d)
            local unit zombie
            local integer i = 0
            local integer index = 0
            local real x = 0.00
            local real y = 0.00
            local integer hp = 0
            local integer dmg = 0
            local integer incHp = 0
            local integer incDmg = 0
            
            if not .tempthis.removed then
                loop
                    exitwhen i >= MAX_GRAVESTONE_TYPES
                    if id == GRAVESTONE_TYPES[i] then
                        set x = GetDestructableX(d)
                        set y = GetDestructableY(d)
                        set zombie = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), GRAVESTONE_X_ZOMBIES[i], x, y, GetRandomInt(0,359))
                        set index = i
                        set i = MAX_GRAVESTONE_TYPES
                    endif
                    set i = i + 1
                endloop
				
                //get new hp+dmg
                set hp = GetDynamicRatioValue(ZOMBIE_START_HP[index], HP_FACTOR)
                set dmg = GetDynamicRatioValue(ZOMBIE_START_DAMAGE[index], DAMAGE_FACTOR)
                set incHp = GetDynamicRatioValue(INCREASED_ZOMBIE_HP_PER_ROUND, HP_FACTOR)
                set incDmg = GetDynamicRatioValue(INCREASED_ZOMBIE_DAMAGE_PER_ROUND, DAMAGE_FACTOR)

                call SetUnitMaxState(zombie, UNIT_STATE_MAX_LIFE, hp + ( RoundSystem.actualRound * incHp))
                call TDS.addDamage(zombie, dmg + ( RoundSystem.actualRound * incDmg))
                call DestroyEffect(AddSpecialEffect(ZOMBIE_SPAWN_EFFECT, x, y))
                call UnitApplyTimedLife(zombie, 'BTLF', LIFE_TIME )
            
                if .counter > 0 then
                    set .counter = .counter - 1
                endif
                set .tempthis.removed = true
                call RemoveDestructable(d)
                set .tempthis.removed = false
            endif
			
			set d = null
            set zombie = null
		endmethod
        
        static method getCounter takes nothing returns integer
            return .counter
        endmethod 
        
        static method resetCounter takes nothing returns nothing
            set .counter = 0
        endmethod
    endstruct
	
	private function Actions takes nothing returns nothing
        local Gravestone g = 0
        local integer i = 0
        local integer count = GRAVESTONE_PER_RECT
        
        loop
            exitwhen i == MAX_GRAVESTONE_AREAS
            loop
                exitwhen count < 0
                set g = Gravestone.create(i)
                set count = count - 1
            endloop
            set count = GRAVESTONE_PER_RECT
            set i = i + 1
        endloop
        
    endfunction
	
	private function Conditions takes nothing returns boolean
        return Gravestone.getCounter() <= MAX_GRAVESTONES
	endfunction
	
	private function DestructableCondition takes nothing returns boolean
		return 	GetDestructableTypeId(GetOrderTargetDestructable()) == GRAVESTONE_SMALL or /*
		*/		GetDestructableTypeId(GetOrderTargetDestructable()) == GRAVESTONE_MEDIUM or /*
		*/		GetDestructableTypeId(GetOrderTargetDestructable()) == GRAVESTONE_LARGE
	endfunction

	private function DestructableActions takes nothing returns nothing
		local unit u = GetTriggerUnit()

		if (GetUnitRace(u) != RACE_UNDEAD ) then
			call PauseUnit(u, true)
			call IssueImmediateOrder(u, "stop")
			call PauseUnit(u, false)
		endif

		set u = null
	endfunction
	
	struct GravestoneSystem
	
		static method initialize takes nothing returns nothing
			local trigger t = CreateTrigger()
			
			call MainSetup()
			call TriggerRegisterTimerEventPeriodic(t, GetRandomReal(MIN_TIME, MAX_TIME))
			call TriggerAddCondition(t, Condition(function Conditions))
			call TriggerAddAction(t, function Actions)
			
			//Add an event for the coalition heroes to make gravestones non-targetable for them!
			//Thx Avahor from hiveworkshop.com for help!
			//http://www.hiveworkshop.com/forums/triggers-scripts-269/destructable-event_attacked-272668/
			call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function DestructableCondition, function DestructableActions)
	 
			set t = null
		endmethod
	
	endstruct
endscope