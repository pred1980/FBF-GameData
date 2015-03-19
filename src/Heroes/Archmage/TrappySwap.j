scope TrappySwap initializer init
    /*
     * Description: Belenus uses his powerful magic to trick and enemys mind into attacking his peers, 
	                the Archmages foes.
     * Changelog: 
     *     29.11.2013: Abgleich mit OE und der Exceltabelle
	 *     02.12.2013: Exceptionsfunktionalitaet eingebaut
     *     04.12.2013: ManaCost-Event verbaut
	 *     28.03.2014: Skorpione auf dem Friedhof können nicht mehr verwendet werden 
     */
    globals
        private constant integer SPELL_ID = 'A07N'
        private constant integer DUMMY_SPELL_ID_1 = 'Avul' //Unverwundbar
        private constant integer DUMMY_SPELL_ID_2 = 'Aloc' //Heuschrecke
        private constant integer DUMMY_SPELL_ID_3 = 'ACmi' //Zauber-Imunität damit kein anderer Spell Probleme macht
        private constant integer DISTANCE = 250
        private constant string START_EFFECT = "GainLife.mdx"
        private constant string END_EFFECT = "HarvestLife.mdx"
        private constant string ATT_POINT = "origin"
        private constant real INTERVAL = 0.5
        private constant rect DUMMY_RECT = gg_rct_SoulTrapDummyPosition
        
        private constant integer INCREASED_HP_PER_ROUND = 250
        private constant integer INCREASED_DAMAGE_PER_ROUND = 35
        private constant integer START_HP = 350
        private constant integer START_DAMAGE = 30
        
        //Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real DURATION = 1.5
        
        private real array LIFE_TIME
		
		/************** 
		 * EXCEPTIONS *
		 * ************/
         //*********************\\
        private hashtable DATA = InitHashtable()
        private constant string MESSAGE = "You cannot swap the "
        
        //Brood Mother + Childs
        private constant integer SPIDER_ID = 'n00G'
        private constant integer MALE_ID = 'n00I'
        private constant integer FEMALE_ID = 'n00H'
		private constant integer WARDEN_ID = 'u02A'
		private constant integer ARCHNATHID_ID = 'n00L'
		private constant integer EGG_ID = 'o00C'
    endglobals
    
	private function MainSetup takes nothing returns nothing
        set LIFE_TIME[1] = 60
        set LIFE_TIME[2] = 55
        set LIFE_TIME[3] = 50
        set LIFE_TIME[4] = 45
        set LIFE_TIME[5] = 40
        
        call SaveBoolean(DATA, 0, SPIDER_ID, true)
        call SaveBoolean(DATA, 0, MALE_ID, true)
        call SaveBoolean(DATA, 0, FEMALE_ID, true)
		call SaveBoolean(DATA, 0, WARDEN_ID, true)
		call SaveBoolean(DATA, 0, ARCHNATHID_ID, true)
		call SaveBoolean(DATA, 0, EGG_ID, true)
		
    endfunction
	
	private function CheckTarget takes unit u returns boolean
		return LoadBoolean(DATA, 0, GetUnitTypeId(u))
    endfunction
        
    private struct TrappySwap
        unit caster
        unit target
        unit dummy
        unit fake
        integer level = 0
        real hp
        real mana
        real time
        real x
        real y
        real x2
        real y2
		timer t
		
		method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
			call KillUnit(.fake)
            call RemoveUnit(.fake)
            call DestroyEffect(AddSpecialEffectTarget(END_EFFECT, .target, ATT_POINT))
            call PauseUnit(.target, false)
            call ShowUnit(.target, true)
            set .caster = null
            set .target = null
            set .dummy = null
            set .fake = null
			set .t = null
		endmethod
		
		static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.time = this.time - INTERVAL
            if IsUnitDead(this.caster) then
				set this.hp = GetUnitState(this.dummy, UNIT_STATE_LIFE)
                set this.mana = GetUnitState(this.dummy, UNIT_STATE_MANA)
                call SetUnitState(this.target, UNIT_STATE_LIFE, this.hp)
                call SetUnitState(this.target, UNIT_STATE_MANA, this.mana)
                call Stun_UnitEx(this.target, DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
                call SetUnitPosition(this.target, GetUnitX(this.dummy), GetUnitY(this.dummy))
                call FadeUnitStart(this.target, 0x44556677, 0xFFFFFFFF, DURATION)
                call KillUnit(this.dummy)
                call ReleaseTimer(this.t)
                call this.destroy()
				return
            endif
            
            if IsUnitDead(this.dummy) then
                //call SetUnitPosition(this.target, this.x, this.y)
				call SetUnitPosition(this.target, GetUnitX(this.dummy), GetUnitY(this.dummy))
                call Stun_UnitEx(this.target, DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
                call FadeUnitStart(this.target, 0x44556677, 0xFFFFFFFF, DURATION)
                call this.destroy()
			    return
            endif
            
            //time is over?
            if this.time <= 0 then
                call this.destroy()
            endif
            
        endmethod
        
        static method onCreateCopiedUnit takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
			// Copied Unit
            set this.dummy = CreateUnit(GetOwningPlayer(this.caster), GetUnitTypeId(this.target) , this.x2, this.y2, GetUnitFacing(this.caster))
            call Stun_UnitEx(this.dummy, DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            call FadeUnitStart(this.dummy, 0x00000000, 0xFFFFFFFF, DURATION)
            call DestroyEffect(AddSpecialEffectTarget(START_EFFECT, this.dummy, ATT_POINT))
            call UnitApplyTimedLife(this.dummy, 'BTLF', LIFE_TIME[this.level] )
            
            //Add Damage + HP
            call SetUnitMaxState(this.dummy, UNIT_STATE_MAX_LIFE, START_HP + ( RoundSystem.actualRound * INCREASED_HP_PER_ROUND))
            call SetUnitState(this.dummy, UNIT_STATE_LIFE, GetUnitState(this.dummy, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
            call TDS.addDamage(this.dummy, START_DAMAGE + ( RoundSystem.actualRound * INCREASED_DAMAGE_PER_ROUND))
            
			call ReleaseTimer(this.t)
			set this.t = NewTimer()
            call SetTimerData(this.t , this )
            call TimerStart(this.t, INTERVAL, true, function thistype.onPeriodic)
        endmethod
        
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            local real a 
            local real x2
            local real y2
            
            set .caster = caster
			set .target = target
			set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
			set .time = LIFE_TIME[.level]
			set .hp = GetUnitState(.target, UNIT_STATE_LIFE)
			set .mana = GetUnitState(.target, UNIT_STATE_MANA)
			set a = AngleBetweenCords(GetUnitX(.caster), GetUnitY(.caster), GetUnitX(.target), GetUnitY(.target))  
			set .x2 = PolarProjectionX(GetUnitX(.caster), DISTANCE, a)
			set .y2 = PolarProjectionY(GetUnitY(.caster), DISTANCE, a)
			
			//save position of target
			set .x = GetUnitX(.target)
			set .y = GetUnitY(.target)
			
			// Original Unit
			call PauseUnit(.target, true)
			call ShowUnit(.target, false)
			//Setzt die Einheit in die untere rechte Ecke der Karte
			call SetUnitX(.target, GetRectCenterX(DUMMY_RECT))
			call SetUnitY(.target, GetRectCenterY(DUMMY_RECT))
			
			//Fake Unit
			set .fake = CreateUnit(GetOwningPlayer(.target), GetUnitTypeId(.target), .x, .y, GetUnitFacing(.target))
			call UnitAddAbility( .fake, DUMMY_SPELL_ID_1 )
			call UnitAddAbility( .fake, DUMMY_SPELL_ID_2 )
			call UnitAddAbility( .fake, DUMMY_SPELL_ID_3 )
			call FadeUnitStart(.fake, 0xFFFFFFFF, 0x44556677, DURATION)
			call PauseUnit(.fake, true)
			
			set .t = NewTimer()
			call SetTimerData(.t, this)
			call TimerStart(.t, DURATION, false, function thistype.onCreateCopiedUnit)
			
            return this
        endmethod
        
    endstruct
    
    private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID and not CheckImmunity(SPELL_ID, GetTriggerUnit(), GetSpellTargetUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction
	
	private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local unit target = GetSpellTargetUnit()
		
		if not CheckTarget(target) then
			call TrappySwap.create(caster, target)
		else
			//Return Mana Costs
			call RunManaCost(SPELL_ID, caster, target, GetSpellTargetX(), GetSpellTargetY())
			//Error Message
			call SimError(GetOwningPlayer(caster), MESSAGE + GetUnitName(target) + ".")
			//Reset Cooldown of the Ability
			call UnitResetSingleCooldown(caster, SPELL_ID)
		endif
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddCondition(t,Condition(function Conditions))
		call TriggerAddAction(t, function Actions )
        call MainSetup()
        call Preload(START_EFFECT)
        call Preload(END_EFFECT)
        call XE_PreloadAbility(DUMMY_SPELL_ID_1)
        call XE_PreloadAbility(DUMMY_SPELL_ID_2)
        call XE_PreloadAbility(DUMMY_SPELL_ID_3)        
    endfunction

endscope