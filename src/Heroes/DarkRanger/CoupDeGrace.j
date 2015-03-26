scope CoupDeGrace initializer Init
    /*
     * Description: Gabrielle fires an arrow at an allied hero and instantly kills it. 
                    The energy released creates a powerful explosion that deals heavy area of 
					effect damage to all enemy units.
     * Changelog: 
     *     26.11.2013: Abgleich mit OE und der Exceltabelle
	 *     17.02.2015: Kein Schaden auf umliegende gegnerische Einheiten beim Kill des Helden behoben
	 *     18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions) + Immunity Check
     */
    globals
        private constant integer SPELL_ID = 'A076'
        private constant integer REVIVE_ID = 'A077'
        private constant string MISSILE_MODEL = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl"
        private constant string EFFECT = "DarkLightningNova.mdx"
        private constant string DAMAGE_EFFECT = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl"
        private constant real MISSILE_SCALE = 1.0
        private constant real MISSILE_SPEED = 750.0
        private constant real ARC_MIN = 0.
        private constant real ARC_MAX = 0.15
        private constant real Z_START = 0.
        private constant real Z_END = 0.
        private constant integer BASE_DAMAGE = 250
        private constant integer DAMAGE_PER_LEVEL = 500
        private constant real RADIUS = 300
        
        private xedamage damageOptions
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
        set d.dtype = DAMAGE_TYPE_FIRE   
        set d.atype = ATTACK_TYPE_NORMAL
        set d.damageAllies = true
        set d.damageEnemies = false
    endfunction
    
    struct CoupDeGrace extends xehomingmissile
        unit caster
        unit target
        group g
        integer level = 0
        static thistype tempthis
        
        static method create takes unit caster, unit target, integer level returns thistype
            local thistype this = thistype.allocate(GetWidgetX(caster), GetWidgetY(caster), Z_START, target, Z_END)
            
            set this.fxpath = MISSILE_MODEL
            set this.scale = MISSILE_SCALE
            set this.caster = caster
            set this.target = target
            set this.level = level
            set this.g = NewGroup()
            set .tempthis = this
            
            call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
            
            return this
        endmethod
        
        method onHit takes nothing returns nothing
            local real x = GetUnitX(.target)
            local real y = GetUnitY(.target)
            
            if (damageOptions.allowedTarget(.caster, .target )) then
                call UnitAddAbility(.target, REVIVE_ID)
                call KillUnit(.target)
                call DestroyEffect(AddSpecialEffect(EFFECT, x, y))
                call GroupEnumUnitsInRange(.tempthis.g, x, y, RADIUS, function thistype.group_filter_callback)
                call ForGroup( .tempthis.g, function thistype.onDealDamage )
            endif
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
			local unit u = GetFilterUnit()
			
			if (IsUnitEnemy( u, GetOwningPlayer( .tempthis.caster ) ) and not /*
			*/     IsUnitDead(u) and not /*
			*/     IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not /*
			*/     IsUnitType(u, UNIT_TYPE_MECHANICAL)) then
				return true
			endif
				
			return false
        endmethod
        
        static method onDealDamage takes nothing returns nothing
            local unit u = GetEnumUnit()
            
			set DamageType = SPELL
            call UnitDamageTarget(.tempthis.caster, u, BASE_DAMAGE + DAMAGE_PER_LEVEL * .tempthis.level, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNKNOWN,WEAPON_TYPE_WHOKNOWS)
            call DestroyEffect(AddSpecialEffectTarget(DAMAGE_EFFECT, u, "chest"))

            call GroupRemoveUnit(.tempthis.g, u)
            if CountUnitsInGroup(.tempthis.g) == 0 then
                call .tempthis.terminate()
            endif
            set u = null
        endmethod
       
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(.g)
            set .g = null
            set .caster = null
            set .target = null
        endmethod
    endstruct

    private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function Actions takes nothing returns nothing
        local CoupDeGrace c = 0
        local unit caster = GetTriggerUnit()
        local unit target = GetSpellTargetUnit()
        local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
    
        set c = CoupDeGrace.create(caster, target, level)
       
        set caster = null
        set target = null
    endfunction
   
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()

        set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)

        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        set t = null
        
        call Preload(MISSILE_MODEL)
        call Preload(EFFECT)
        call Preload(DAMAGE_EFFECT)
    endfunction
endscope
