scope SoulTrap initializer init
    /*
     * Description: The Gatekeeper traps a unit in within his tormented soul, removing it from the battlefield 
                    and damaging it in the process. Mana Concentration increases the damage done.
     * Changelog: 
     *     	01.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	24.03.2015: Fixed a bug after the "Spell-End" (onEnd) that the target ran in different directions
	 *     	30.03.2015: Integrated RegisterPlayerUnitEvent
						Integrated SpellHelper for damaging
	 *		22.04.2015: Changed complete spell in object editor to guarantee spell immunity
	 *		15.10.2015: Deactivated HIDE_ADV because it causes a problem at the end of a round when the hero teleports
						back to its base
     *
     */
    globals
        private constant integer SPELL_ID = 'A00I'
        private constant integer DUMMY_SPELL_ID = 'A051'
        private constant integer DUMMY_ID = 'e00R'
        private constant real DURATION = 8.0
        private constant real DURATION_HERO = 4.0
        private constant string START_EFFECT = "Abilities\\Spells\\Items\\AIso\\AIsoTarget.mdl" 
        private constant string END_EFFECT = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
        private constant rect DUMMY_RECT = gg_rct_SoulTrapDummyPosition
        //Die Einheit mit der Abi "Unsichtbarkeit" zusätzlich verstecken?
        private constant boolean HIDE_ADV = false
        
        //Stun Effect for Pause Target
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
		private real array DAMAGE
    endglobals
	
	private function MainSetup takes nothing returns nothing
        set DAMAGE[1] = 112
        set DAMAGE[2] = 187
        set DAMAGE[3] = 262
        set DAMAGE[4] = 337
        set DAMAGE[5] = 412
	endfunction
    
    private struct SoulTrap
        private unit caster
        private unit target
        private unit dummy
        private timer t
        private real x
        private real y
        private integer level = 0
        private integer id = 0
		
		method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
            set .t = null
            set .caster = null
            set .target = null
            set .dummy = null
        endmethod
        
		static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call ShowUnit(this.target, true)
			
			if not (TeleportBack.isHeroInGroup(this.target)) then
				call SetUnitX(this.target, this.x)
				call SetUnitY(this.target, this.y)
			endif
			call IssueImmediateOrder(this.target, "holdposition")
            
			set DamageType = SPELL
			call SpellHelper.damageTarget(this.caster, this.target, DAMAGE[this.level] * ManaConcentration_GET_MANA_AMOUNT(this.id), false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            call DestroyEffect(AddSpecialEffect(END_EFFECT, GetUnitX(this.target), GetUnitY(this.target)))
        
            call this.destroy()
        endmethod
        
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .target = target
            set .x = GetUnitX(.target)
            set .y = GetUnitY(.target)
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .id = GetPlayerId(GetOwningPlayer(.caster))
            
            call DestroyEffect(AddSpecialEffect( START_EFFECT, GetUnitX(.target), GetUnitY(.target)))
            //Hide Advanced: Einheit mit Abi "Unsichtbarkeit" verstecken und dann in die
            //untere rechte Ecke der Karte stellen
			//Note: Deactivated because "invisibility" not teleporting an hero back to its base
            static if HIDE_ADV then
                set .dummy = CreateUnit(GetOwningPlayer(.caster), DUMMY_ID, .x, .y, bj_UNIT_FACING)
                call UnitAddAbility( .dummy, DUMMY_SPELL_ID )
                call SetUnitAbilityLevel( .dummy, DUMMY_SPELL_ID, 1 )
                call UnitApplyTimedLife( .dummy, 'BTLF', 1.0 )
                call IssueTargetOrder(.dummy, "invisibility", .target)
                //Setzt den richtigen Held in die untere rechte Ecke der Karte
                call SetUnitX(.target, GetRectCenterX(DUMMY_RECT))
                call SetUnitY(.target, GetRectCenterY(DUMMY_RECT))
            endif
            //Hide Unit
            call ShowUnit(.target, false)
            
            set .t = NewTimer()
            call SetTimerData(.t, this)
            
            if IsUnitType(.target, UNIT_TYPE_HERO) then
                call TimerStart(.t, DURATION_HERO, false, function thistype.onEnd)
				call Stun_UnitEx(.target, DURATION_HERO, false, STUN_EFFECT, STUN_ATT_POINT)
            else
                call TimerStart(.t, DURATION, false, function thistype.onEnd)
				call Stun_UnitEx(.target, DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            endif
            
            return this
        endmethod
    endstruct
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function Actions takes nothing returns nothing
        call SoulTrap.create(GetTriggerUnit(), GetSpellTargetUnit())
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		
		call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(START_EFFECT)
        call Preload(END_EFFECT)
		call MainSetup()
    endfunction

endscope