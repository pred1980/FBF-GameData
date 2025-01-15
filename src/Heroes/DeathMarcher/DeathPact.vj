scope DeathPact initializer init
    /*
     * Description: The Death Marcher sacrifices an allied organic unit to use their HP to fuel an Aura
                    that heals all allied Units nearby. Heroes get a further bonus to regeneration. 
                    Mana Concentration increases the healing and reduces the speed at which the HP is consumend.
     * Changelog: 
     *  	01.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     	31.03.2015: Integrated RegisterPlayerUnitEvent
	                    Integrated SpellHelper for filtering
			03.04.2015: Added exception units which cannot be sacrificd by the Death Marcher 
     */
    globals
        private constant integer SPELL_ID = 'A04Z'
        private constant string KILL_EFFECT = "Models\\DarkExecution.mdx"
        private constant string HEAL_EFFECT = "Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl"
        private constant string ATT_POINT = "origin"
        private constant real RADIUS = 800
        private constant real HEAL_INTERVAL = 1.0
        private constant real HEAL_DURATION = 5.0
        private constant real HOT_DURATION = .75
        
        //max. Anzahl der zu heilenden Allies
        private integer array MAX_HEALS
        //Regeneration Werte | 0 = normale Units | 1 = Heroes
        private real array HOT_REG[5][2]
        
        //DOT
        private constant real DOT_TIME = 5.00
        private constant string DOT_EFFECT = ""
        private constant string DOT_ATT_POINT = ""
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_DEATH
        
        //Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = 5.0
		
		/************** 
		 * EXCEPTIONS *
		 * ************/
        private hashtable DATA = InitHashtable()
        private constant string MESSAGE = "You cannot sacrifice the "
        
        //Brood Mother + Childs
        private constant integer SPIDER_ID = 'n00G'
        private constant integer MALE_ID = 'n00I'
        private constant integer FEMALE_ID = 'n00H'
		private constant integer WARDEN_ID = 'u02A'
		private constant integer ARCHNATHID_ID = 'n00L'
		private constant integer EGG_ID = 'o00C'
		private constant integer TITAN_ID = 'e00C'
		private constant integer HEART_ID = 'H014'
		private constant integer KING_MITHAS_SMALL_ID = 'U02C'
		private constant integer KING_MITHAS_MEDIUM_ID = 'U02D'
		private constant integer KING_MITHAS_LARGE_ID = 'U02E'
		private constant integer WORM_DUMMY_ID = 'h001'
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set MAX_HEALS[1] = 3
        set MAX_HEALS[2] = 4
        set MAX_HEALS[3] = 5
        set MAX_HEALS[4] = 6
        set MAX_HEALS[5] = 7
        
        set HOT_REG[1][0] = 15
        set HOT_REG[1][1] = 20
        set HOT_REG[2][0] = 20
        set HOT_REG[2][1] = 25
        set HOT_REG[3][0] = 25
        set HOT_REG[3][1] = 30
        set HOT_REG[4][0] = 30
        set HOT_REG[4][1] = 35
        set HOT_REG[5][0] = 35
        set HOT_REG[5][1] = 40
		
		call SaveBoolean(DATA, 0, SPIDER_ID, true)
        call SaveBoolean(DATA, 0, MALE_ID, true)
        call SaveBoolean(DATA, 0, FEMALE_ID, true)
		call SaveBoolean(DATA, 0, WARDEN_ID, true)
		call SaveBoolean(DATA, 0, ARCHNATHID_ID, true)
		call SaveBoolean(DATA, 0, EGG_ID, true)
		call SaveBoolean(DATA, 0, TITAN_ID, true)
		call SaveBoolean(DATA, 0, HEART_ID, true)
		call SaveBoolean(DATA, 0, KING_MITHAS_SMALL_ID, true)
		call SaveBoolean(DATA, 0, KING_MITHAS_MEDIUM_ID, true)
		call SaveBoolean(DATA, 0, KING_MITHAS_LARGE_ID, true)
		call SaveBoolean(DATA, 0, WORM_DUMMY_ID, true)
    endfunction
	
	private function CheckTarget takes unit u returns boolean
		return LoadBoolean(DATA, 0, GetUnitTypeId(u))
    endfunction
    
    private struct DeathPact
        unit caster
        unit target
        real store = 0
        real time = HEAL_DURATION
        integer level = 0
        integer id = 0
        group targets
        timer t
        timer main
        static thistype tempthis = 0
		
		method onDestroy takes nothing returns nothing
            call HOT.start( .caster, getStore(), HOT_DURATION, HEAL_EFFECT, ATT_POINT )
            call ReleaseGroup( .targets )
            call ReleaseTimer( .t )
            call ReleaseTimer( .main )
            set .targets = null
            set .t = null
            set .main = null
            set .caster = null
            call KillUnit(.target)
            set .target = null
        endmethod

        static method onMainTimer takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
			set this.time = this.time - 1.0
            if this.time <= 0 then
                call this.destroy()
            endif
        endmethod
		
		static method group_filter_callback takes nothing returns boolean
			return SpellHelper.isValidAlly(GetFilterUnit(), .tempthis.caster)
        endmethod
		
		static method onHealTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            local boolean isHero = IsUnitType(u, UNIT_TYPE_HERO)
            local real hot = .tempthis.getHealAmount(.tempthis.id, .tempthis.level, isHero)
            
			if getStore() >= hot then
                call HOT.start( u, hot, HOT_DURATION, HEAL_EFFECT, ATT_POINT )
            else
                call HOT.start( u, getStore(), HOT_DURATION, HEAL_EFFECT, ATT_POINT )
            endif
            call GroupRemoveUnit(.tempthis.targets, u)
            set u = null
        endmethod
        
        static method onHeal takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            call GroupEnumUnitsInRange( this.targets, GetUnitX(this.target), GetUnitY(this.target), RADIUS, function thistype.group_filter_callback )
            if CountUnitsInGroup(.tempthis.targets) > 0 and getStore() > 0 and .tempthis.time > 0 and not SpellHelper.isUnitDead(this.caster) then
                call ForGroup(GetRandomSubGroup(MAX_HEALS[this.level], this.targets), function thistype.onHealTarget)
            else
                call this.destroy()
            endif
        endmethod

        method getHealAmount takes integer id, integer level, boolean isHero returns real
            local real hot = 0
            if not isHero then
                set hot = HOT_REG[level][0] * ManaConcentration_GET_MANA_AMOUNT(id)
            else
                set hot = HOT_REG[level][1] * ManaConcentration_GET_MANA_AMOUNT(id)
            endif
            
            call setStore(hot)
            
            return hot
        endmethod
        
        static method setStore takes real value returns nothing
            set .tempthis.store = .tempthis.store - value
        endmethod
        
        static method getStore takes nothing returns real
            return .tempthis.store
        endmethod
        
		static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .target = target
            set .id = GetPlayerId(GetOwningPlayer(.caster))
            set .store = GetUnitState(target, UNIT_STATE_LIFE)
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .tempthis = this
            
            if .store > 0 then
                set .targets = NewGroup()
                set .t = NewTimer()
                set .main = NewTimer()
                call SetTimerData(.t, this)
                call SetTimerData(.main, this)
                call TimerStart(.t, HEAL_INTERVAL, true, function thistype.onHeal)
                call TimerStart(.main, HEAL_INTERVAL, true, function thistype.onMainTimer)
            endif
            call DestroyEffect(AddSpecialEffect(KILL_EFFECT, GetUnitX(.target), GetUnitY(.target)))
            call Stun_UnitEx(.target, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
			set DamageType = SPELL
            call DOT.start( this.caster , this.target , .store , DOT_TIME , ATTACK_TYPE , DAMAGE_TYPE , DOT_EFFECT , DOT_ATT_POINT )
            
            return this
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local unit target = GetSpellTargetUnit()
	
		if not CheckTarget(target) then
			call DeathPact.create(caster, target)
		else
			//Return Mana Costs
			call RunManaCost(SPELL_ID, caster, target, GetSpellTargetX(), GetSpellTargetY())
			//Error Message
			call SimError(GetOwningPlayer(caster), MESSAGE + GetUnitName(target) + ".")
			//Reset Cooldown of the Ability
			call SpellHelper.resetAbility(caster, SPELL_ID)
		endif
		
		set caster = null
		set target = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		
		call MainSetup()
        call Preload(KILL_EFFECT)
        call Preload(HEAL_EFFECT)
	endfunction

endscope