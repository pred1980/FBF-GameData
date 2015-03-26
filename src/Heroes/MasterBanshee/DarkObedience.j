scope DarkObedience initializer init
    /*
     * Description: The Grim Lady expels a magic orb that chases her target around, 
	                dealing damage to all units it passes through.
     * Changelog: 
     *     28.10.2013: Abgleich mit OE und der Exceltabelle
	 *     20.03.2015: Optimized Spell-Event-Handling (Conditions/Actions) + Immunity Check
     *
     */
    globals
        private constant integer SPELL_ID = 'A04V'
        private constant real DAMAGE = 50.0 
        private constant real DURATION = 5.0
        //model of the missile
        private constant string missile = "Models\\Soulfire Missile.mdx"
        //SFX that appears when a target takes damage
        private constant string SFX = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdl"
        //effect that appears when the missile diess
        private constant string deathSFX = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
        //effect displayed on the missile while it's flying around
        private constant string flashSFX = "Abilities\\Spells\\Undead\\CarrionSwarm\\CarrionSwarmDamage.mdl"
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
        //setup of the damage options
        set d.dtype = DAMAGE_TYPE_MAGIC    //deals magic damage
        set d.atype = ATTACK_TYPE_NORMAL   //normal attack type
        
        set d.damageEnemies = true     //hits enemies
        set d.damageAllies  = false    //doesn't hit allies
        set d.damageNeutral = true     //hits neutral units
        set d.damageSelf    = false    //doesn't hit self
        set d.required = UNIT_TYPE_GROUND   //doesn't hit flying units
        set d.exception = UNIT_TYPE_STRUCTURE    //doesn't hit structures
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
                set DamageType = 1
                call damageOptions.damageTarget(this.castingHero  , hitunit, this.level * DAMAGE)
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
        local real x
        local real y
        local ArcaneMissile am
        
        set x = GetUnitX(hero)
        set y = GetUnitY(hero)
        set am = ArcaneMissile.create( x, y, bj_RADTODEG * Atan2(GetUnitY(tar) - y, GetUnitX(tar) - x))
        set am.fxpath = missile
        set am.speed = 285.0
        set am.acceleration = 1100.0
        set am.maxSpeed = 1500.0
        set am.z = 15.0
        set am.angleSpeed = 5.5
        set am.targetUnit = tar
        set am.expirationTime = ( level * DURATION )
        set am.castingHero = hero
        set am.level = GetUnitAbilityLevel(hero, SPELL_ID)
        set tar = null
        set hero = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
		call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        
		set damageOptions=xedamage.create()
        call setupDamageOptions(damageOptions)
		
		set t = null
        call Preload(missile)
        call Preload(SFX)
        call Preload(flashSFX)
        call Preload(deathSFX)
    endfunction
endscope