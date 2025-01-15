scope SkeletonSystem
    /*
     * Dieses System spawnt auf dem Friedhof in regelmaessigen Abstaenden 5 verschiedene Typen von
     * Skeletten
     */
	 
	 /*
     * Changelog: 
     *  	16.09.2015: Increased the amount of skeletons from 12 to 15
	 *					Increased attack-graveyard-chance from 14% to 20%
	 *		28.09.2015:	Increased the base hp of all skeletons by 100
	 *		09.04.2016: Added Wander System for each spawned skeleton
     */

    globals
        private integer array SKELETONS
        private constant integer MAX_SKELETONS = 15
        private constant real MIN_TIME = 90.0
        private constant real MAX_TIME = 150.0
        private constant integer INCREASED_HP_PER_ROUND = 55
        private constant integer INCREASED_DAMAGE_PER_ROUND = 7
        private constant string SPAWN_EFFECT = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
        private integer array START_HP
        private integer array START_DAMAGE
        private constant real LIFE_TIME = 120.0
        //Diese Faktoren beschreibt die Erhoehung der HP/Damage Werte je nach Spieleranzahl
        private constant real HP_FACTOR = 0.10
        private constant real DAMAGE_FACTOR = 0.15
        
        private rect array GRAVESTONE_SPAWN_RECTS
        private constant real GRAVESTONE_ATTACK_RANGE = 600
    endglobals

    private function MainSetup takes nothing returns nothing
        set SKELETONS[0] = 'u020'
        set SKELETONS[1] = 'u022'
        set SKELETONS[2] = 'u023'
        set SKELETONS[3] = 'u024'
        set SKELETONS[4] = 'u025'
        
        set START_HP[0] = 230
        set START_DAMAGE[0] = 45
        set START_HP[1] = 255
        set START_DAMAGE[1] = 42
        set START_HP[2] = 280
        set START_DAMAGE[2] = 50
        set START_HP[3] = 295
        set START_DAMAGE[3] = 47
        set START_HP[4] = 210
        set START_DAMAGE[4] = 40
        
        set GRAVESTONE_SPAWN_RECTS[0] = gg_rct_GravestoneRect0
        set GRAVESTONE_SPAWN_RECTS[1] = gg_rct_GravestoneRect1
        set GRAVESTONE_SPAWN_RECTS[2] = gg_rct_GravestoneRect2
    endfunction
    
    private function onFilterGraveyards takes nothing returns boolean
        local destructable d = GetFilterDestructable()
        local boolean b = false
        
        if GetDestructableTypeId(d) == 'B006' or /*
        */ GetDestructableTypeId(d) == 'B007' or /*
        */ GetDestructableTypeId(d) == 'B008' then
            set b = true
        else
            set b = false
        endif
        
        set d = null
        return b
    endfunction
    
    private function Action takes nothing returns nothing
        local integer rectIndex = GetRandomInt(0,2)
        local integer skeletonIndex = GetRandomInt(0,4)
        local integer hp = 0
        local integer dmg = 0
        local integer incHp = 0
        local integer incDmg = 0
        local real x = GetRandomReal(GetRectMinX(GRAVESTONE_SPAWN_RECTS[rectIndex]), GetRectMaxX(GRAVESTONE_SPAWN_RECTS[rectIndex]))
        local real y = GetRandomReal(GetRectMinY(GRAVESTONE_SPAWN_RECTS[rectIndex]), GetRectMaxY(GRAVESTONE_SPAWN_RECTS[rectIndex]))
        local unit skeleton = null
        local destructable gravestone = null
        local integer rnd = GetRandomInt(0,4) //20%
		local Wander wander
		
        loop
            exitwhen IsTerrainWalkable(x,y)
            set x = GetRandomReal(GetRectMinX(GRAVESTONE_SPAWN_RECTS[rectIndex]), GetRectMaxX(GRAVESTONE_SPAWN_RECTS[rectIndex]))
            set y = GetRandomReal(GetRectMinY(GRAVESTONE_SPAWN_RECTS[rectIndex]), GetRectMaxY(GRAVESTONE_SPAWN_RECTS[rectIndex]))
        endloop
        
        set hp = GetDynamicRatioValue(START_HP[skeletonIndex], HP_FACTOR)
        set dmg = GetDynamicRatioValue(START_DAMAGE[skeletonIndex], DAMAGE_FACTOR)
        set incHp = GetDynamicRatioValue(INCREASED_HP_PER_ROUND, HP_FACTOR)
        set incDmg = GetDynamicRatioValue(INCREASED_DAMAGE_PER_ROUND, DAMAGE_FACTOR)
        
        set skeleton = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), SKELETONS[skeletonIndex], x, y, GetRandomInt(0,359))
        call SetUnitMaxState(skeleton, UNIT_STATE_MAX_LIFE, hp + ( RoundSystem.actualRound * incHp))
        call SetUnitState(skeleton, UNIT_STATE_LIFE, GetUnitState(skeleton, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
        call TDS.addDamage(skeleton, dmg + (RoundSystem.actualRound * incDmg))
        call DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, GetUnitX(skeleton), GetUnitY(skeleton)))
        call UnitApplyTimedLife(skeleton, 'BTLF', LIFE_TIME)
		
		// Add Unit to the Wander System
		set wander = Wander.create(skeleton, 500, GetRandomReal(1., 5.))
        set wander.random = GetRandomReal(1., 5.)
        set wander.order = "attack"
        
        //Attack next closest graveyard / 20% chance
        if rnd == 0 then
			set gravestone = GetClosestDestructableInRange(x, y, GRAVESTONE_ATTACK_RANGE, Condition(function onFilterGraveyards))
            if gravestone != null then
                call IssueTargetOrder(skeleton, "attack", gravestone)
            endif
        endif
        
        //Cleanup
        set skeleton = null
        set gravestone = null
    endfunction
    
    private function onCreate takes nothing returns nothing
        local integer i = 0
        
        loop
            exitwhen i == MAX_SKELETONS
            call Action()
            set i = i + 1
        endloop
    endfunction
    
    struct SkeletonSystem
	
		static method initialize takes nothing returns nothing
			call MainSetup()
			call TimerStart(NewTimer(), GetRandomReal(MIN_TIME, MAX_TIME), true, function onCreate )
		endmethod
	
	endstruct

endscope
