library AxeThrow initializer Init requires xedamage, xemissile
    /*
     * Description: The Ogre Warrior throws his mighty axe at a target enemy, damaging and stunning anyone near where it lands.
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
	 *     23.02.2014: Werte erhoeht von 80/160/240/320/400 auf 110/220/330/440/550
	 *     24.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for filtering
     */
    globals
        private constant integer SPELL_ID = 'A09H' //The triggerer spell id.
        private constant real TARGET_RADIUS = 300.0 // In what range to look for child missile targets?
        private constant real LAUNCH_PERIOD = 0.2   // How often to launch child missiles in flight?

        // Main missile visual settings:
        private constant string MAIN_MODEL = "Abilities\\Weapons\\RexxarMissile\\RexxarMissile.mdl"
        private constant real SCALE = 2.5
        private constant real ANGLE_SPEED = 0.3
        private constant real SPEED = 700.0
        private constant real MAX_SPEED = 1200.0
        private constant real ACCELERATION = 1400.0
        
        //Stun Effect
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = 2.0
        
        //KNOCK BACK
        private constant integer DISTANCE = 100
        private constant real KB_TIME = 0.35
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals
    
    private constant function Damage takes integer level returns real
        return 110.0 * level 
    endfunction

    private function setupDamageOptions takes xedamage d returns nothing
		set d.atype = ATTACK_TYPE
		set d.dtype = DAMAGE_TYPE
		set d.wtype = WEAPON_TYPE
       
		set d.exception = UNIT_TYPE_STRUCTURE
		set d.damageEnemies = true  // This evil spell pretty much hits
		set d.damageAllies  = false
		set d.damageNeutral = false  // the casting hero himSelf... it would
		set d.damageSelf    = false // be quite dumb if it was able to hit the hero...
    endfunction

    //**********************************************************************************
    globals
        private xedamage damageOptions
    endglobals

    struct HammerThrowMain extends xecollider
        unit caster
        unit target
        integer level      
        private static group g = CreateGroup()
        private static HammerThrowMain current
        
        private static method group_filter_callback takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidEnemy(u, .current.caster)) and /*
			*/	u != .current.target) then
				set b = true
			endif
			
			set u = null
		
			return b
        endmethod
        
        private static method onStun takes nothing returns nothing
            call Stun_UnitEx(GetEnumUnit(), STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            call GroupRemoveUnit(.current.g, GetEnumUnit())
        endmethod

        method onUnitHit takes unit hitunit returns nothing
            local real x = 0.00
            local real y = 0.00
            local real ang = 0.00
            
            set .current = this
            if (damageOptions.allowedTarget( this.caster  , hitunit ) ) then
                set x = GetUnitX(this.caster) - GetUnitX(this.target)
                set y = GetUnitY(this.caster) - GetUnitY(this.target)
                set ang = Atan2(y, x) - bj_PI
                call Knockback.create(this.caster, this.target, DISTANCE, KB_TIME, ang, 0, "", "")
                set DamageType = PHYSICAL
				call damageOptions.damageTarget(this.caster, hitunit, Damage(this.level))
                call GroupEnumUnitsInRange(this.g, GetUnitX(hitunit), GetUnitY(hitunit), TARGET_RADIUS, function thistype.group_filter_callback)
                call ForGroup( this.g, function thistype.onStun )
                call this.terminate()
            endif
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local unit target = GetSpellTargetUnit()
        local real cx = GetUnitX(caster) 
        local real cy = GetUnitY(caster)
        local real tx = GetUnitX(target)
        local real ty = GetUnitY(target)
        local real ang = Atan2( ty - cy, tx - cx) //the angle between the target and the unit
        local HammerThrowMain ht = HammerThrowMain.create(cx, cy, ang)
        
        set ht.fxpath = MAIN_MODEL
        set ht.scale = SCALE
        set ht.speed = SPEED
        set ht.acceleration = ACCELERATION
        set ht.maxSpeed = MAX_SPEED
        set ht.z = 50.0
        set ht.angleSpeed = ANGLE_SPEED 
        set ht.target = target
        set ht.caster = caster 
        set ht.level = GetUnitAbilityLevel(caster, SPELL_ID)
        
        set caster = null
        set target = null
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

	private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)

        // Initializing the damage options:
        set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)
        call Preload(MAIN_MODEL)
        call Preload(STUN_EFFECT)
    endfunction
endlibrary