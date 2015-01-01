scope SpikeTrap
    
    globals
        private constant integer ARCHNATHID_ID = 'n00L'
        private constant integer SPELL_ID = 'A0AR'
        private constant integer DUMMY_ID = 'o00E'
        private constant string TRAP_EFFECT = "Abilities\\Spells\\Orc\\SpikeBarrier\\SpikeBarrier.mdl"
        private constant string ATTACK_EFFECT = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
        private constant real RADIUS = 45.
        private constant real INTERVAL = .01
        private constant integer MAX_ARCHNATHID = 5
        
        private rect array GRAVESTONE_SPAWN_RECTS
        private constant integer HP = 4000
        private constant integer DAMAGE = 135
        //Diese Faktoren beschreibt die Erh?hung der HP/Damage Werte je nach Spieleranzahl, im akt. Fall 5%
        private constant real HP_FACTOR = 0.10 //0.05
        private constant real DAMAGE_FACTOR = 0.12 //0.09
    endglobals
    
    private function Damage takes nothing returns real
        return 25. + I2R(RoundSystem.actualRound) * 50.
    endfunction
    
    private function MainSetup takes nothing returns nothing
        set GRAVESTONE_SPAWN_RECTS[0] = gg_rct_GravestoneRect0
        set GRAVESTONE_SPAWN_RECTS[1] = gg_rct_GravestoneRect1
        set GRAVESTONE_SPAWN_RECTS[2] = gg_rct_GravestoneRect2
    endfunction
    
    private keyword Data
    
    globals
        private integer array Index
        private integer Count = 0
        private group G = CreateGroup()
        private timer T = CreateTimer()
    endglobals
    
    private function Filters takes nothing returns boolean
        return IsUnitType(GetFilterUnit(), UNIT_TYPE_FLYING) != true and not IsUnitDead(GetFilterUnit())
    endfunction
    
    private struct Data
        unit caster
        unit victim
        unit trap
        effect e
        real x
        real y
        real dmg
        
        static method create takes unit u, integer lvl returns Data
            local Data d = Data.allocate()
            set d.caster = u
            set d.x = GetUnitX(d.caster)
            set d.y = GetUnitY(d.caster)
            set d.dmg = Damage()
            call ShowUnit(d.caster, false)
            set d.trap = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), DUMMY_ID, d.x, d.y, 0)
            set d.e = AddSpecialEffect(TRAP_EFFECT, d.x, d.y)
            return d
        endmethod
        
        static method update takes nothing returns nothing
            local Data d
            local integer i = Count
            
            loop
                exitwhen i == 0
                set d = Index[i]
                
                call GroupEnumUnitsInRange(G, d.x, d.y, RADIUS, Condition(function Filters))
                set d.victim = FirstOfGroup(G)
                if(d.victim != null and IsUnitEnemy(d.victim, GetOwningPlayer(d.caster))) then
                    call DestroyEffect(d.e)
                    call DestroyEffect(AddSpecialEffect(ATTACK_EFFECT, GetUnitX(d.victim), GetUnitY(d.victim)))
                    call ShowUnit(d.caster, true)
                    call SetUnitX(d.caster, GetUnitX(d.victim) + 100 * Cos((GetUnitFacing(d.victim) - 180) * bj_DEGTORAD))
                    call SetUnitY(d.caster, GetUnitY(d.victim) + 100 * Sin((GetUnitFacing(d.victim) - 180) * bj_DEGTORAD))
                    call SetUnitAnimation(d.caster, "attack")
                    set DamageType = SPELL
                    call UnitDamageTarget(d.caster, d.victim, d.dmg, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
                    call d.destroy()
                    set Index[i] = Index[Count]
                    set Count = Count - 1
                endif
                call GroupClear(G)
                set i = i - 1
            endloop
            if(d == 0) then
                call PauseTimer(T)
            endif
        endmethod
        
    endstruct
    
    private function Actions takes nothing returns nothing
        local Data d = Data.create(GetTriggerUnit(), GetUnitAbilityLevel(GetTriggerUnit(), SPELL_ID))
        set Count = Count + 1
        set Index[Count] = d
        
        call IssueImmediateOrder(d.caster, "stop")
            
        if(Count == 1) then
            call TimerStart(T, INTERVAL, true, function Data.update)
        endif
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction
    
    private function CreateArchnathid takes nothing returns nothing
        local integer rectIndex = GetRandomInt(0,2)
        local integer hp = 0
        local integer dmg = 0
        local real x = GetRandomReal(GetRectMinX(GRAVESTONE_SPAWN_RECTS[rectIndex]), GetRectMaxX(GRAVESTONE_SPAWN_RECTS[rectIndex]))
        local real y = GetRandomReal(GetRectMinY(GRAVESTONE_SPAWN_RECTS[rectIndex]), GetRectMaxY(GRAVESTONE_SPAWN_RECTS[rectIndex]))
        local unit archnathid = null
        
        loop
            exitwhen IsTerrainWalkable(x,y)
            set x = GetRandomReal(GetRectMinX(GRAVESTONE_SPAWN_RECTS[rectIndex]), GetRectMaxX(GRAVESTONE_SPAWN_RECTS[rectIndex]))
            set y = GetRandomReal(GetRectMinY(GRAVESTONE_SPAWN_RECTS[rectIndex]), GetRectMaxY(GRAVESTONE_SPAWN_RECTS[rectIndex]))
        endloop
        
        set hp = GetTeamRatioValue(HP, HP_FACTOR)
        set dmg = GetTeamRatioValue(DAMAGE, DAMAGE_FACTOR)
        
        set archnathid = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), ARCHNATHID_ID, x, y, GetRandomInt(0,359))
        call SetUnitMaxState(archnathid, UNIT_STATE_MAX_LIFE, hp)
        call SetUnitState(archnathid, UNIT_STATE_LIFE, GetUnitState(archnathid, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
        call TDS.addDamage(archnathid, dmg)
        call UnitAddAbility(archnathid, SPELL_ID)
        call SetUnitAbilityLevel(archnathid, SPELL_ID, 1)
        call IssueImmediateOrder(archnathid, "burrow")
        
        //Cleanup
        set archnathid = null
    endfunction
    
    private function CreateArchnathidAction takes nothing returns nothing
        local integer i = 0
        
        loop
            exitwhen i == MAX_ARCHNATHID
            call CreateArchnathid()
            set i = i + 1
        endloop
    endfunction
    
    struct SpikeTrap
	
		static method initialize takes nothing returns nothing
			local trigger t = CreateTrigger()
			
			call MainSetup()
			call Preload(TRAP_EFFECT)
			call Preload(ATTACK_EFFECT)
			
			call TriggerRegisterPlayerUnitEvent(t, Player(bj_PLAYER_NEUTRAL_EXTRA), EVENT_PLAYER_UNIT_SPELL_EFFECT, null)
			call TriggerAddCondition(t, Condition(function Conditions))
			call TriggerAddAction(t, function Actions)
			
			call CreateArchnathidAction()
			
			set t = null
		endmethod
	
	endstruct
    
endscope