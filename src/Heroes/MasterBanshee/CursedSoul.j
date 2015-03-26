scope CursedSoul initializer init
    /*
     * Description: She takes the soul from a near corpse, forcing it to possess a random enemy land unit. 
                    If that unit is different to the cursed soul, it will deal damage to the unit, 
                    else it will take control of that unit temporally, draining its life.
     * Last Update: 29.10.2013
     * Changelog: 
     *     29.10.2013: Abgleich mit OE und der Exceltabelle
	 *     21.03.2015: Code refactoring
     *
     */ 
    globals
        private constant integer SPELL_ID = 'A04X'
        private constant integer DUMMY_SPELL_ID_1 = 'Abun'
        private constant integer DUMMY_SPELL_ID_2 = 'Aloc'
        private constant integer DUMMY_SPELL_ID_3 = 'Amrf'
        private constant real POSSESSION_DUR = 10.0
        private constant real MAX_LIFE_TIME_SOUL = 120.0
        private constant real INTERVAL = 1.0
        private constant real PERIOD = 3.5
        private constant real AOE = 600
        private constant real RADIUS = 350
        private constant real NORMAL_MOVEMENT_SPEED = 300.0
        private constant string START_EFFECT = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
        private constant string SPIRIT_EFFECT = "Abilities\\Spells\\Human\\Banish\\BanishTarget.mdl"
        private constant string SPIRIT_EFFECT_DEAD = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl"
        private constant string SPIRIT_EFFECT_TARGET = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl"
        private constant string SPIRIT_EFFECT_POSSESSION = "Abilities\\Spells\\Undead\\Possession\\PossessionMissile.mdl"
        
        private constant real ROTMAJ = Cos(bj_PI * INTERVAL / PERIOD)
        private constant real ROTMIN = Sin(bj_PI * INTERVAL / PERIOD)
        
        private real array DAMAGE
        private group targets
        private group taggedTargets
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DAMAGE[1] = 70
        set DAMAGE[2] = 120
        set DAMAGE[3] = 170
        set DAMAGE[4] = 220
        set DAMAGE[5] = 270
        
        set targets = NewGroup()
        set taggedTargets = NewGroup()
    endfunction
    
    private struct CursedSoul
        unit caster
        unit target
        unit soul
        integer level = 0
        real dx
        real dy
        timer t
        effect fx
        
        static thistype tempthis
        
		method onDestroy takes nothing returns nothing
            set .caster = null
            set .target = null
            set .soul = null
            set .t = null
            call DestroyEffect(.fx)
            set .fx = null
        endmethod

        method getRandomEnemy takes unit c, group g, real range returns unit
            local unit u = null
			local boolean b = false

            loop
				exitwhen (u == null or b == true)
                set u = FirstOfGroup(g)
				if (SpellHelper.isValidEnemy(u, c) and not /*
				*/  IsUnitInGroup(u, taggedTargets)) then
					set b = true
				endif
                call GroupRemoveUnit(g, u)
            endloop
			
			call GroupRefresh(g)
			
            return u
        endmethod
        
        static method onWaitNearbyEnemy takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real x
            local real y
            local timer t
            
            call GroupUnitsInArea(targets, GetUnitX(this.soul), GetUnitY(this.soul), RADIUS)
            set this.target = getRandomEnemy(this.soul, targets, RADIUS)
            
            if this.target != null then
                call ReleaseTimer(GetExpiredTimer())
                
                call GroupAddUnit(taggedTargets, this.target)
                set t = NewTimer()
                call SetTimerData(t, this)
                call TimerStart(t, INTERVAL, true, function thistype.onCatchEnemy)
            else
                set x = this.dx
                set y = this.dy
                set this.dx = ROTMAJ * x - ROTMIN * y
                set this.dy = ROTMAJ * y + ROTMIN * x
                call IssuePointOrder(this.soul, "move", GetUnitX(this.caster) + this.dx, GetUnitY(this.caster) + this.dy)
            endif
        endmethod
        
        static method onCatchEnemy takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local integer st = GetUnitTypeId(this.soul)
            local player pt = GetOwningPlayer(this.target)
            local player ps = GetOwningPlayer(this.soul)
            local boolean b = false
            
            if IsUnitInRange(this.soul, this.target, 50.0) or IsUnitDead(this.soul) or IsUnitDead(this.target) then
                set b = true
                call ReleaseTimer(GetExpiredTimer())
            else
                call IssuePointOrder(this.soul, "move", GetUnitX(this.target), GetUnitY(this.target))
            endif
            if b then
                call GroupRemoveUnit(taggedTargets, this.target)
                
                if IsUnitDead(this.target) and not IsUnitDead(this.soul) then
                    call DestroyEffect(AddSpecialEffect(SPIRIT_EFFECT_DEAD, GetUnitX(this.soul), GetUnitY(this.soul)))
                    call RemoveUnit(this.soul)
                else
                    call DestroyEffect(AddSpecialEffectTarget(SPIRIT_EFFECT_TARGET, this.target, "origin"))
                    if GetUnitTypeId(this.target) == st then
                        call RemoveUnit(this.soul)
                        call DestroyEffect(AddSpecialEffectTarget(SPIRIT_EFFECT_POSSESSION, this.target, "origin"))
                        call SetUnitOwner(this.target, ps, true)
                        call UnitApplyTimedLife(this.target, 'Bpos', POSSESSION_DUR * (GetUnitAbilityLevel(this.caster, SPELL_ID)))
                    else
                        set DamageType = 1
                        call UnitDamageTarget(this.caster, this.target, DAMAGE[GetUnitAbilityLevel(this.caster, SPELL_ID)], true, false, ATTACK_TYPE_MAGIC, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
                        call RemoveUnit(this.soul)
                    endif
                endif
                call this.destroy()
            endif
            
            set pt = null
            set ps = null
        endmethod
        
		static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .soul = CreateUnit(GetOwningPlayer(.caster), GetUnitTypeId(target), GetUnitX(target), GetUnitY(target), GetUnitFacing(target))
            
            call SetUnitMoveSpeed(.soul, NORMAL_MOVEMENT_SPEED)
            call UnitApplyTimedLife( .soul, 'BTLF', MAX_LIFE_TIME_SOUL )
            call DestroyEffect(AddSpecialEffect(START_EFFECT, GetUnitX(target), GetUnitY(target)))
            call UnitAddAbility(.soul, DUMMY_SPELL_ID_1)
            call UnitAddAbility(.soul, DUMMY_SPELL_ID_2)
            set .fx = AddSpecialEffectTarget(SPIRIT_EFFECT, .soul, "origin")
           
            call UnitAddAbility(.soul, DUMMY_SPELL_ID_3)
            call UnitRemoveAbility(.soul, DUMMY_SPELL_ID_3)
            call SetUnitVertexColor(.soul, 100, 100, 100, 85)
            call SetUnitFlyHeight(.soul, 75, 100.0)
            
            set .dx = RADIUS
            set .dy = 0
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, INTERVAL, true, function thistype.onWaitNearbyEnemy)
            
            set .tempthis = this
            return this
        endmethod
              
    endstruct

   private function Actions takes nothing returns nothing
        call CursedSoul.create( GetTriggerUnit(), GetSpellTargetUnit() )
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
		call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
		
		call MainSetup()
        call Preload(START_EFFECT)
        call Preload(SPIRIT_EFFECT)
        call Preload(SPIRIT_EFFECT_DEAD)
        call Preload(SPIRIT_EFFECT_TARGET)
        call Preload(SPIRIT_EFFECT_POSSESSION)
		
		set t = null
    endfunction

endscope