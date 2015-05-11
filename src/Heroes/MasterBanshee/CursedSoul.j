scope CursedSoul initializer init
    /*
     * Description: She takes the soul from a near corpse, forcing it to possess a random enemy land unit. 
                    If that unit is different to the cursed soul, it will deal damage to the unit, 
                    else it will take control of that unit temporally, draining its life.
     * Changelog: 
     *     29.10.2013: Abgleich mit OE und der Exceltabelle
	 *     21.03.2015: Code refactoring
	 *     18.04.2015: Integrated RegisterPlayerUnitEvent
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
				
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
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
        private unit caster
        private unit target
        private unit soul
        private integer level = 0
        private real dx
        private real dy
        private timer t
        private effect fx
        
        static thistype tempthis = 0
        
		method onDestroy takes nothing returns nothing
            set .caster = null
            set .target = null
            set .soul = null
            set .t = null
            call DestroyEffect(.fx)
            set .fx = null
			call GroupRefresh(targets)
			call GroupRefresh(taggedTargets)
        endmethod

        method getRandomEnemy takes unit c, group g, real range returns unit
            local unit u = null
			local boolean b = false

            loop
				set u = FirstOfGroup(g)
				if (SpellHelper.isValidEnemy(u, c) and not /*
				*/  IsUnitType(u, UNIT_TYPE_FLYING) and not /*
				*/  IsUnitInGroup(u, taggedTargets)) then
					set b = true
				endif
				exitwhen (u == null or b == true)
                call GroupRemoveUnit(g, u)
            endloop
			
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
			local integer level = GetUnitAbilityLevel(this.caster, SPELL_ID)
            
            if (IsUnitInRange(this.soul, this.target, 50.0) or SpellHelper.isUnitDead(this.soul) or SpellHelper.isUnitDead(this.target)) then
                set b = true
                call ReleaseTimer(GetExpiredTimer())
            else
                call IssuePointOrder(this.soul, "move", GetUnitX(this.target), GetUnitY(this.target))
            endif
            if b then
                call GroupRemoveUnit(taggedTargets, this.target)
                
                if (SpellHelper.isUnitDead(this.target) and not SpellHelper.isUnitDead(this.soul)) then
                    call DestroyEffect(AddSpecialEffect(SPIRIT_EFFECT_DEAD, GetUnitX(this.soul), GetUnitY(this.soul)))
                    call RemoveUnit(this.soul)
                else
                    call DestroyEffect(AddSpecialEffectTarget(SPIRIT_EFFECT_TARGET, this.target, "origin"))
                    if GetUnitTypeId(this.target) == st then
                        call RemoveUnit(this.soul)
                        call DestroyEffect(AddSpecialEffectTarget(SPIRIT_EFFECT_POSSESSION, this.target, "origin"))
                        call SetUnitOwner(this.target, ps, true)
                        call UnitApplyTimedLife(this.target, 'Bpos', POSSESSION_DUR * level)
                    else
                        set DamageType = SPELL
						call SpellHelper.damageTarget(this.caster, this.target, DAMAGE[level], false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
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
			set .target = target
            set .soul = CreateUnit(GetOwningPlayer(caster), GetUnitTypeId(target), GetUnitX(target), GetUnitY(target), GetUnitFacing(target))
            
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
        call CursedSoul.create(GetTriggerUnit(), GetSpellTargetUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)

		call MainSetup()
        call Preload(START_EFFECT)
        call Preload(SPIRIT_EFFECT)
        call Preload(SPIRIT_EFFECT_DEAD)
        call Preload(SPIRIT_EFFECT_TARGET)
        call Preload(SPIRIT_EFFECT_POSSESSION)
    endfunction

endscope