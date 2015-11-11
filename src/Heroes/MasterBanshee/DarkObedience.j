scope DarkObedience initializer init
    /*
     * Description: The Grim Lady expels a magic orb that chases her target around, 
	                dealing damage to all units it passes through.
     * Changelog: 
     *     	28.10.2013: Abgleich mit OE und der Exceltabelle
	 *     	20.03.2015: Optimized Spell-Event-Handling (Conditions/Actions) + Immunity Check
	 *     	18.04.2015: Integrated RegisterPlayerUnitEvent
	 *		24.10.2015: Changed duration from 5s/10s/15s/20s/25s to 5s
						Changed damage from 50/100/150/200/250 to 75/100/125/150/175
     *
     */
    globals
        private constant integer SPELL_ID = 'A04V'
        
        private constant real DURATION = 5.0
        //model of the missile
        private constant string missile = "Models\\Soulfire Missile.mdx"
        //SFX that appears when a target takes damage
        private constant string SFX = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdl"
        //effect that appears when the missile diess
        private constant string deathSFX = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
        //effect displayed on the missile while it's flying around
        private constant string flashSFX = "Abilities\\Spells\\Undead\\CarrionSwarm\\CarrionSwarmDamage.mdl"
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
		private real array damage 
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
        //setup of the damage options
		set d.atype = ATTACK_TYPE
        set d.dtype = DAMAGE_TYPE    
		set d.wtype = WEAPON_TYPE
        
        set d.damageEnemies = true     //hits enemies
        set d.damageAllies  = false    //doesn't hit allies
        set d.damageNeutral = true     //hits neutral units
        set d.damageSelf    = false    //doesn't hit self
        set d.required = UNIT_TYPE_GROUND   //doesn't hit flying units
        set d.exception = UNIT_TYPE_STRUCTURE    //doesn't hit structures
		
		set damage[1] = 75
		set damage[2] = 100
		set damage[3] = 125
		set damage[4] = 150
		set damage[5] = 175
    endfunction
    
    globals
        private xedamage damageOptions 
    endglobals

    private struct ArcaneMissile extends xecollider
        unit castingHero
        integer level
        
		method onUnitHit takes unit hitunit returns nothing
            if (damageOptions.allowedTarget( this.castingHero  , hitunit ) ) then
                call DestroyEffect( AddSpecialEffectTarget(SFX,hitunit, "origin") )
                set DamageType = SPELL
                call damageOptions.damageTarget(this.castingHero  , hitunit, damage[this.level])
            endif
        endmethod
        
		method onDestroy takes nothing returns nothing
            set this.castingHero = null
            call DestroyEffect( AddSpecialEffect(deathSFX, this.x , this.y ) )
        endmethod
        
		method loopControl takes nothing returns nothing
            if(GetRandomReal(0,1)<0.25) then
                call DestroyEffect( AddSpecialEffect(flashSFX, this.x , this.y ) )
            endif
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
		local unit hero = GetTriggerUnit()
        local unit tar = GetSpellTargetUnit()
        local integer level = GetUnitAbilityLevel(hero, SPELL_ID)
        local real x = GetUnitX(hero)
        local real y = GetUnitY(hero)
        local ArcaneMissile am = ArcaneMissile.create( x, y, bj_RADTODEG * Atan2(GetUnitY(tar) - y, GetUnitX(tar) - x))

        set am.fxpath = missile
        set am.speed = 285.0
        set am.acceleration = 1100.0
        set am.maxSpeed = 1500.0
        set am.z = 15.0
        set am.angleSpeed = 5.5
        set am.targetUnit = tar
        set am.expirationTime = DURATION
        set am.castingHero = hero
        set am.level = level
        
		set tar = null
        set hero = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
		set damageOptions=xedamage.create()
        call setupDamageOptions(damageOptions)
		
        call Preload(missile)
        call Preload(SFX)
        call Preload(flashSFX)
        call Preload(deathSFX)
    endfunction
endscope