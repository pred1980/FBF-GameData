scope VampireBlood initializer Init
    /*
     * Description: The Dread Lord spills his own blood into a target area, 
	                enchanting allied units with a life-draining attack.
     * Changelog: 
     *     	15.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	26.11.2013: Umbau auf xemissile 
	 *     	19.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     	04.04.2015: Integrated RegisterPlayerUnitEvent
						Integrated SpellHelper for filtering and damaging
	 *		07.05.2015: Fixed a bug with the current level
     */
    globals
        private constant integer SPELL_ID = 'A06V'
		private constant integer BUFFSPELL = 'A06W'
        private constant integer BUFF_ID = 'B011'
        private constant integer DUMMY_ID = 'e00W'
        private constant string MISSILE_MODEL = "CurseBolt.mdl"
        private constant string EFFECT = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"
        private constant real MISSILE_SCALE = 1.0
        private constant real MISSILE_SPEED = 700.0
        private constant real ARC_MIN = 0.
        private constant real ARC_MAX = 0.15
        private constant real Z_START = 0.
        private constant real Z_END = 0.
        private constant real RADIUS = 250
        private constant real LIFE_LEECH = 20.0
        private integer array NUM_DROPS
    endglobals
	
	private function MainSetup takes nothing returns nothing
        set NUM_DROPS[0] = 3
        set NUM_DROPS[1] = 4
        set NUM_DROPS[2] = 5
        set NUM_DROPS[3] = 6
        set NUM_DROPS[4] = 7
    endfunction
    
    private struct VampireBlood
		unit caster
        group targets
		integer numTargets = 0
        integer level = 0
		static thistype tempthis
		
		method onDestroy takes nothing returns nothing
			call ReleaseGroup(.targets)
			set .targets = null
		endmethod
		
		static method groupFilterCallback takes nothing returns boolean
            local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidAlly(u, .tempthis.caster)) and not /*
            */ (.tempthis.numTargets >= NUM_DROPS[.tempthis.level]) then
				set .tempthis.numTargets = .tempthis.numTargets + 1
				set b = true
            endif
            set u = null
			
            return b
        endmethod
		
		static method create takes unit caster, real x, real y returns thistype
			local thistype this = thistype.allocate()
			local unit u
	
            set this.caster = caster
			set this.level = GetUnitAbilityLevel(caster, SPELL_ID) - 1
			set this.targets = NewGroup()
			set this.tempthis = this
			
			call GroupEnumUnitsInArea(this.targets, x, y, RADIUS, Condition( function thistype.groupFilterCallback))
			
			loop
				set u = FirstOfGroup(this.targets)
				exitwhen u == null
				call BloodMissile.create(caster, u, GetUnitX(u), GetUnitY(u))
				call GroupRemoveUnit(this.targets, u)
			endloop
			
			set u = null
			call this.destroy()
			
			return this
		endmethod
	endstruct
	
	struct BloodMissile extends xemissile
		unit caster
        unit target
        integer level = 0
		
		method onDestroy takes nothing returns nothing
            set .caster = null
			set .target = null
        endmethod
		
        static method create takes unit caster, unit target, real x, real y returns thistype
            local thistype this = thistype.allocate(GetUnitX(caster), GetUnitY(caster), 0.0, x, y, 0.0)
            
            set this.fxpath = MISSILE_MODEL
            set this.scale = MISSILE_SCALE
			set this.caster = caster
            set this.target = target
            set this.level = GetUnitAbilityLevel(caster, SPELL_ID)
			
			call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
			
            return this
        endmethod
        
        method loopControl takes nothing returns nothing
            if not IsTerrainWalkable(this.x, this.y) then
                call this.terminate()
            endif
        endmethod
        
        method onHit takes nothing returns nothing
            local unit d
			
			if not SpellHelper.isUnitDead(.target) then
                set d = CreateUnit(GetOwningPlayer(.caster), DUMMY_ID, GetUnitX(.target), GetUnitY(.target), GetUnitFacing(.target))
                call UnitAddAbility(d, BUFFSPELL)
                call SetUnitAbilityLevel(d, BUFFSPELL, .level)
                call IssueTargetOrder(d, "bloodlust", .target)
                call UnitApplyTimedLife(d, 'BTLF', 1.0)
            endif
			
			set d = null
			
			call this.terminate()
        endmethod
		
    endstruct
	
	private function onLeech takes unit damagedUnit, unit damageSource, real damage returns nothing
        if (GetUnitAbilityLevel(damageSource, BUFF_ID) > 0 and /*
		*/ SpellHelper.isValidEnemy(damagedUnit, damageSource) and /*
		*/  DamageType == PHYSICAL ) then
				call SetUnitState(damageSource, UNIT_STATE_LIFE, GetUnitState(damageSource,UNIT_STATE_LIFE) + LIFE_LEECH)
				call DestroyEffect(AddSpecialEffectTarget(EFFECT,damageSource,"origin"))
        endif
    endfunction

    private function Actions takes nothing returns nothing
		call VampireBlood.create(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction
	
	private function Conditions takes nothing returns boolean
        return (GetSpellAbilityId() == SPELL_ID)
    endfunction

    private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)

        call RegisterDamageResponse( onLeech )
		call MainSetup()
        call Preload(MISSILE_MODEL)
        call Preload(EFFECT)
    endfunction
endscope
