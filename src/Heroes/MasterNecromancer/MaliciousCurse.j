scope MaliciousCurse initializer init
     /*
     * Description: By the power of his black magic, Kakos is able to put a hex on an enemy unit. 
                    This unit will drain either the health or the mana of its nearby allies, 
                    but the unit itself is immune to this effect.
     * Changelog: 
     *     	05.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	18.04.2015: Integrated RegisterPlayerUnitEvent
						Integrated SpellHelper for filtering and damaging
	 *		27.09.2015: Increased the cooldown from 12s to 18s
						Changed the mana from 120 to 120/130/140/150/160
     *
     */
    globals
        private constant integer SPELL_ID = 'A064'
        private constant integer BUFF_ID = 'B00O' //The buff with which to differentiate between states
        private constant integer SWITCH_ID = 'A065' //The ability with which to switch between Life and Mana
        private constant integer LBUFF_ABI = 'A066'
        private constant integer LBUFF_BUF = 'B00P'	
        private constant integer MBUFF_ABI = 'A067'
        private constant integer MBUFF_BUF = 'B00Q'
        private constant integer DUMMY_ID = 'e00T'
        private constant boolean LBUFF_AGGRO = false //Whether the Lifedrain should draw aggro towards the Necromancer
        private constant boolean MBUFF_AGGRO = false //Whether the Manadrain should draw aggro towards the Necromancer
        private constant real RADIUS = 350
		private constant real Interval = 0.5
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
        private real array Drain
        private real array Duration
        
    endglobals

    private function MainSetup takes nothing returns nothing
        set Drain[0] = 0.02
        set Drain[1] = 0.03
        set Drain[2] = 0.04
        set Drain[3] = 0.05
        set Drain[4] = 0.06
        
        set Duration[0] = 10.0
        set Duration[1] = 9.0
        set Duration[2] = 8.0
        set Duration[3] = 7.0
        set Duration[4] = 6.0
    endfunction
    
    private struct MaliciousCurse
        private unit caster
        private unit target
        private unit dummy
        private boolean isLife
        private timer itrvTimer
        private timer durTimer
        private integer level = 0
        private static thistype tempthis = 0
        
        method onDestroy takes nothing returns nothing
            call UnitRemoveAbility(.dummy,LBUFF_ABI)
            call UnitRemoveAbility(.dummy,MBUFF_ABI)
            call RemoveUnit(.dummy)
            call ReleaseTimer(.itrvTimer)
            call ReleaseTimer(.durTimer)
            set .itrvTimer = null
            set .durTimer = null
            set .caster = null
            set .target = null
            set .dummy = null
        endmethod
		
		static method group_filter_callback_life takes nothing returns boolean
            local unit u = GetFilterUnit()
            local real dmg
			
			if (SpellHelper.isValidEnemy(u, .tempthis.caster)) and /*
			*/  GetUnitAbilityLevel(u, LBUFF_BUF) > 0 and not /*
			*/	(u == .tempthis.dummy) then
                set dmg = GetUnitState(u, UNIT_STATE_MAX_LIFE) * Drain[.tempthis.level] * Interval
                
                static if LBUFF_AGGRO then
                    set DamageType = SPELL
					call SpellHelper.damageTarget(.tempthis.caster, u, dmg, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                else
                    if GetUnitState(u, UNIT_STATE_LIFE) <= dmg then
                        set DamageType = SPELL
						call SpellHelper.damageTarget(.tempthis.caster, u, dmg, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
						//Even if it doesn't draw aggro, it should still count as kills
                    else
                        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_LIFE) - dmg)
                    endif
                endif
            endif
			
            set u = null
			
            return false
        endmethod
        
        static method group_filter_callback_mana takes nothing returns boolean
            local unit u = GetFilterUnit()
            local real dmg
			
			if (SpellHelper.isValidEnemy(u, .tempthis.caster)) and /*
			*/  GetUnitAbilityLevel(u, MBUFF_BUF) > 0 and not /*
			*/	(u == .tempthis.dummy) then
			    set dmg = GetUnitState(u, UNIT_STATE_MAX_MANA) * Drain[.tempthis.level] * Interval
                call SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MANA) - dmg)
                static if MBUFF_AGGRO then
                    //Dealing 0 damage still makes the Portrait flash and draws aggro from purposeless 
                    set DamageType = SPELL
					call SpellHelper.damageTarget(.tempthis.caster, u, 0, false, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                endif
            endif
			
            set u = null
            
			return false
        endmethod
        
        static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call this.destroy()
        endmethod
        
        static method onTick takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
			
			//Stop when the target is dead
			if (SpellHelper.isUnitDead(this.target)) then
                call this.destroy()
                return
            endif
            
			set this.tempthis = this
            call SetUnitPosition(this.dummy, GetUnitX(this.target), GetUnitY(this.target))
            if this.isLife then
                call GroupEnumUnitsInArea(ENUM_GROUP,GetUnitX(this.target), GetUnitY(this.target), RADIUS,Condition( function thistype.group_filter_callback_life))
            else
                call GroupEnumUnitsInArea(ENUM_GROUP,GetUnitX(this.target), GetUnitY(this.target), RADIUS,Condition( function thistype.group_filter_callback_mana))
            endif
        endmethod
        
		static method create takes unit c, unit t, boolean l returns thistype
            local thistype this = thistype.allocate()
            
			set .caster = c
            set .target = t
            set .isLife = l
            set .level = GetUnitAbilityLevel(c,SPELL_ID)-1
            set .itrvTimer = NewTimer()
            set .durTimer = NewTimer()
            set .dummy = CreateUnit(GetOwningPlayer(c), DUMMY_ID, GetUnitX(t), GetUnitY(t), GetUnitFacing(t))
            
            if .isLife then
                call UnitAddAbility(.dummy, LBUFF_ABI)
            else
                call UnitAddAbility(.dummy, MBUFF_ABI)
            endif
            
            call SetTimerData(.itrvTimer,this)
            call SetTimerData(.durTimer,this)
            call TimerStart(.itrvTimer, Interval, true, function thistype.onTick)
            call TimerStart(.durTimer,Duration[.level],false, function thistype.onEnd)
            
			return this
        endmethod
    endstruct

    private function SpellActions takes nothing returns nothing
        call MaliciousCurse.create( GetTriggerUnit(), GetSpellTargetUnit(), not (GetUnitAbilityLevel(GetTriggerUnit(),BUFF_ID) > 0) )
    endfunction
	
	private function SpellConditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
	
	private function LearnActions takes nothing returns nothing
        call UnitAddAbility(GetTriggerUnit(),SWITCH_ID)
    endfunction
	
	private function LearnConditions takes nothing returns boolean
		return GetLearnedSkill() == SPELL_ID and GetUnitAbilityLevel(GetTriggerUnit(),SWITCH_ID) < 1
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function SpellConditions, function SpellActions)
		call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function LearnConditions, function LearnActions)
        
        call MainSetup()
        call XE_PreloadAbility(SWITCH_ID)
        call XE_PreloadAbility(LBUFF_ABI)
        call XE_PreloadAbility(MBUFF_ABI)
    endfunction

endscope