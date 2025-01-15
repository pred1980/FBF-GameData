scope CoupDeGrace initializer Init
    /*
     * Description: Gabrielle fires an arrow at an allied hero and instantly kills it. 
                    The energy released creates a powerful explosion that deals heavy area of 
					effect damage to all enemy units.
     * Changelog: 
     *      26.11.2013: Abgleich mit OE und der Exceltabelle
	 *      17.02.2015: Kein Schaden auf umliegende gegnerische Einheiten beim Kill des Helden behoben
	 *      18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *      29.03.2015: Check immunity on spell cast
					    Integrated RegisterPlayerUnitEvent
	                    Integrated SpellHelper for damaging and filtering
	 *		30.03.2015: Increased Base-Damage from 250 to 500
						Increased Radius from 300 to 400
						Increased Missile Speed from 750 to 800
	 *		12.10.2015:	Added a note for the killed ally by Coup de Grace					
     */
    globals
        private constant integer SPELL_ID = 'A0B4'
        private constant integer REVIVE_ID = 'A077'
        private constant string MISSILE_MODEL = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl"
        private constant string EFFECT = "DarkLightningNova.mdx"
        private constant string DAMAGE_EFFECT = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl"
        private constant real MISSILE_SCALE = 1.0
        private constant real MISSILE_SPEED = 850.0
        private constant real ARC_MIN = 0.
        private constant real ARC_MAX = 0.15
        private constant real Z_START = 0.
        private constant real Z_END = 0.
        private constant integer BASE_DAMAGE = 500
        private constant integer DAMAGE_PER_LEVEL = 500
        private constant real RADIUS = 400
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE_KILL = ATTACK_TYPE_PIERCE
        private constant damagetype DAMAGE_TYPE_KILL = DAMAGE_TYPE_DEATH
        private constant weapontype WEAPON_TYPE_KILL = WEAPON_TYPE_WHOKNOWS
		
		private constant attacktype ATTACK_TYPE_EXPLOSION = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE_EXPLOSION = DAMAGE_TYPE_DEATH
        private constant weapontype WEAPON_TYPE_EXPLOSION = WEAPON_TYPE_WHOKNOWS
        
        private xedamage damageOptions
    endglobals
    
    struct CoupDeGrace extends xehomingmissile
        unit caster
        unit target
        group g
        integer level = 0
        static thistype tempthis
		
		method onDestroy takes nothing returns nothing
            call ReleaseGroup(.g)
            set .g = null
            set .caster = null
            set .target = null
        endmethod

		static method onDealDamage takes nothing returns nothing
            local unit u = GetEnumUnit()
			local real dmg = BASE_DAMAGE + DAMAGE_PER_LEVEL * .tempthis.level
            
			set DamageType = PHYSICAL
			call SpellHelper.damageTarget(.tempthis.caster, u, dmg, true, true, ATTACK_TYPE_EXPLOSION, DAMAGE_TYPE_EXPLOSION, WEAPON_TYPE_EXPLOSION)
            call DestroyEffect(AddSpecialEffectTarget(DAMAGE_EFFECT, u, "chest"))

            call GroupRemoveUnit(.tempthis.g, u)
			set u = null
            if CountUnitsInGroup(.tempthis.g) == 0 then
                call .tempthis.terminate()
            endif
        endmethod
		
		static method group_filter_callback takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), .tempthis.caster)
        endmethod
        
        method onHit takes nothing returns nothing
            local real x = GetUnitX(.target)
            local real y = GetUnitY(.target)
            
            if (damageOptions.allowedTarget(.caster, .target)) then
                call UnitAddAbility(.target, REVIVE_ID)
                call KillUnit(.target)
                call DestroyEffect(AddSpecialEffect(EFFECT, x, y))
                call GroupEnumUnitsInRange(.tempthis.g, x, y, RADIUS, function thistype.group_filter_callback)
                call ForGroup(.tempthis.g, function thistype.onDealDamage)
				call Usability.getTextMessage(0, 14, true, GetOwningPlayer(.target), true, 0.00)
            endif
        endmethod

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
    endstruct
	
	private function setupDamageOptions takes xedamage d returns nothing
        set d.damageAllies = true
        set d.damageEnemies = false

		set d.dtype = DAMAGE_TYPE_KILL  
        set d.atype = ATTACK_TYPE_KILL
		set d.wtype = WEAPON_TYPE_KILL
    endfunction

    private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID and not /*
		*/	   SpellHelper.isImmuneOnSpellCast(SPELL_ID, GetTriggerUnit(), GetSpellTargetUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction

    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local unit target = GetSpellTargetUnit()
        local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
    
        call CoupDeGrace.create(caster, target, level)
       
        set caster = null
        set target = null
    endfunction
   
    private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		
		set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)

        call Preload(MISSILE_MODEL)
        call Preload(EFFECT)
        call Preload(DAMAGE_EFFECT)
    endfunction
endscope
