scope Snack initializer init
    /*
     * Description: Blight Cleaver joyfully feasts on an enemy hero, damaging him and healing himself for an 
	                equal amount. 
                    The enemy cannot move while being eaten. If the victim dies in the process, Blight Cleaver will 
                    permanently gain 3 points in Strength.
     * Changelog: 
     *     	11.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	24.03.2015: Check immunity on spell cast
	 *     	06.05.2015: Integrated RegisterPlayerUnitEvent
						Integrated SpellHelper for damaging and filtering
						Code Refactoring
	 *		17.10.2015: Changed TimerUtils to normal standard Timer (CreateTimer())
						Fixed a bug and optimize the spell animation
	 *		05.04.2016: Code parts recoded, optimized and adapted for AI System
     *
     */
	 
	private keyword Snack
    
	globals
        private constant integer SPELL_ID = 'A06L'
		private constant integer BUFF_PLACER_ID = 'A0B1'
        private constant integer BUFF_ID = 'B00D'
		private constant real INTERVAL = 1.0
		private constant integer ITERATION = 5
		private constant real DURATION = INTERVAL * ITERATION
		//Stun Effect for Pause Target
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = INTERVAL
				
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
        private real baseDamage = 70
        private real damageModifier = 0.5
    endglobals

    private struct Snack
        private unit caster
        private unit target
        private real damage
        private integer count = 0
		private integer level = 0
		private timer t
		private real x
		private real y
		
		private static integer buffType = 0
		private dbuff buff = 0
        
        method onDestroy takes nothing returns nothing
			call SetUnitAnimation(.caster, "stand")
			call UnitEnableAttack(.caster)
            set .caster = null
            set .target = null
        endmethod
		
		private static method onSnack takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local thistype this = GetTimerData(t)

			if ((this.count == 0) or /*
			*/	((SpellHelper.isUnitDead(this.caster)) or /*
			*/	(SpellHelper.isUnitDead(this.target))) or /*
			*/	((GetUnitX(this.caster) != this.x) and /*
			*/  (GetUnitY(this.caster) != this.y))) then
				call PauseTimer(t)
				call DestroyTimer(t)
				set t = null
				call thistype(GetEventBuff().data).destroy()
			else
				set this.count = this.count - 1
				set DamageType = PHYSICAL
				call SpellHelper.damageTarget(this.caster, this.target,this.damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
				//Pause Unit / Used Stun System
				call Stun_UnitEx(this.target, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
				call SetUnitAnimation(this.caster, "stand channel" )
				call SetUnitState(this.caster, UNIT_STATE_LIFE, GetUnitState(this.caster, UNIT_STATE_LIFE) + this.damage)
				
				if (SpellHelper.isUnitDead(this.target) and not /*
				*/  SpellHelper.isUnitDead(this.caster)) then
					call SetHeroStr(this.target,GetHeroStr(this.target,false) - 3,true)
					call SetHeroStr(this.caster,GetHeroStr(this.caster,false) + 3,true)
				endif
			endif
		endmethod
        
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
			
			set .t = CreateTimer()
            set .caster = caster
            set .target = target
            set .count = ITERATION
			set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
			set .x = GetUnitX(.caster)
			set .y = GetUnitY(.caster)
            set .damage = baseDamage + ((baseDamage * damageModifier) * .level)
			
			call Stun_UnitEx(.target, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
			call UnitDisableAttack(.caster)
			call SetUnitAnimation(.caster, "stand channel" )
			call SetTimerData(.t, this)
			call TimerStart(.t, INTERVAL, true, function thistype.onSnack)
			
			set UnitAddBuff(.caster, .caster, .buffType, DURATION, .level).data = this
			
            return this
        endmethod
		
		static method onInit takes nothing returns nothing
			set .buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0, false, true, 0, 0, 0)
		endmethod
        
    endstruct
	
    private function StartConditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID and not /*
		*/	   SpellHelper.isImmuneOnSpellCast(SPELL_ID, GetTriggerUnit(), GetSpellTargetUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction

    private function StartActions takes nothing returns nothing
        call Snack.create(GetTriggerUnit(), GetSpellTargetUnit())
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function StartConditions, function StartActions)
    endfunction

endscope