scope SkullRod initializer init
	/*
	 * Item: Skull Rod
	 */ 
    globals
        private constant integer SPELL_ID = 'A0AY'
		private constant integer MAX_SKELETONS = 2
		private constant integer INCREASED_HP_PER_ROUND = 55
        private constant integer INCREASED_DAMAGE_PER_ROUND = 7
		private constant string SPAWN_EFFECT = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
		private constant real LIFE_TIME = 60.0
        private constant real HP_FACTOR = 0.10
        private constant real DAMAGE_FACTOR = 0.15
		
		private integer array START_HP
        private integer array START_DAMAGE
		private integer array SKELETONS
    endglobals
	
	private function MainSetup takes nothing returns nothing
        set SKELETONS[0] = 'u022'
        set SKELETONS[1] = 'u025'
        
        set START_HP[0] = 130
        set START_DAMAGE[0] = 45
        set START_HP[1] = 155
        set START_DAMAGE[1] = 42
    endfunction

    private function Actions takes nothing returns nothing
		local player p = GetTriggerPlayer()
		local unit caster = GetTriggerUnit()
		local integer hp = 0
		local integer dmg = 0
		local integer incHp = 0
		local integer incDmg = 0
		local unit skeleton = null
		local integer i = 0
		local integer round = RoundSystem.actualRound
		
		loop
			exitwhen i == MAX_SKELETONS
			set hp = GetDynamicRatioValue(START_HP[i], HP_FACTOR)
			set dmg = GetDynamicRatioValue(START_DAMAGE[i], DAMAGE_FACTOR)
			set incHp = GetDynamicRatioValue(INCREASED_HP_PER_ROUND, HP_FACTOR)
			set incDmg = GetDynamicRatioValue(INCREASED_DAMAGE_PER_ROUND, DAMAGE_FACTOR)
			
			set skeleton = CreateUnit(p, SKELETONS[i], GetUnitX(caster), GetUnitY(caster), GetRandomInt(0,359))
			call SetUnitMaxState(skeleton, UNIT_STATE_MAX_LIFE, hp + ( round * incHp))
			call SetUnitState(skeleton, UNIT_STATE_LIFE, GetUnitState(skeleton, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
			call TDS.addDamage(skeleton, dmg + (round * incDmg))
			call DestroyEffect(AddSpecialEffect(SPAWN_EFFECT, GetUnitX(skeleton), GetUnitY(skeleton)))
			call UnitApplyTimedLife(skeleton, 'BTLF', LIFE_TIME)
		
			set i = i + 1
		endloop
		
		set caster = null
		set skeleton = null
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
		
		call MainSetup()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
		call TriggerAddCondition(t, Condition( function Conditions))
        call TriggerAddAction(t, function Actions )
		call Preload(SPAWN_EFFECT)
		
		set t = null
    endfunction

endscope