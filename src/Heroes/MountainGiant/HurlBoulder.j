library HurlBoulder initializer Init requires xedamage, xemissile
    /*
     * Description: The Mountain Giant throws a boulder in the target area, causing damage and stunning the target for 2 seconds.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A098'
        
        private constant real TARGET_RADIUS = 200.0
        // Main missile visual settings:
        private constant string MAIN_MODEL =  "Abilities\\Weapons\\RockBoltMissile\\RockBoltMissile.mdl"
        private constant real MAIN_SCALE = 2.0
        private constant real MAIN_LAUNCH_OFFSET = 60.0
        private constant real MAIN_SPEED = 700.0
        private constant real MAIN_ARC = 0.55
        
        //Stun Effect
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = 2.0
    endglobals
    
    private constant function Damage takes integer level returns real
        return 100.0 * level
    endfunction

    //==================================================================================
    // Let's set the damage options up, this function takes a xedamage object d
    // which something else probably instantiated and we would like to configure.
    //
    private function setupDamageOptions takes xedamage d returns nothing
        set d.dtype = DAMAGE_TYPE_FIRE   // Do spell, fire (magic) damage
        set d.atype = ATTACK_TYPE_NORMAL //

        set d.damageEnemies = true
        set d.damageNeutral = false
        set d.exception = UNIT_TYPE_STRUCTURE // Do not hit buildings.
       // For everything else, the default xedamage settings should do fine.
    endfunction

    //**********************************************************************************
    globals
        private xedamage damageOptions
    endglobals

    //==================================================================================
    //  HurlBoulderMain struct: the main spell missile. Since it is not a homing missile,
    // it extends xemissile instead of xehomingmissile. Again, it contains custom data
    // and code that make it a different missile from the HurlBoulderChild one.
    //
    //
    struct HurlBoulderMain extends xemissile
        private unit    caster
        private integer level

        //==============================================================================
        //  We can declare a custom create method for our missile, note the parameters used
        // when calling .allocate, they must match those of xemissile's create method.
        //
        static method create takes unit caster, integer level, real tx, real ty returns HurlBoulderMain
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local real z = GetUnitFlyHeight(caster) + MAIN_LAUNCH_OFFSET
            local HurlBoulderMain this = HurlBoulderMain.allocate(x,y,z, tx,ty,0.0)

            // Let us configure our projectile's custom data:
            set this.caster = caster
            set this.level  = level

            // Time to configure the delegate xefx properties:
            set this.fxpath = MAIN_MODEL
            set this.scale  = MAIN_SCALE

            // Launch the newly created missile:
            call this.launch(MAIN_SPEED, MAIN_ARC)

            return this
        endmethod
        
        // Used for launching child missiles periodically:
        private real launchtime = 0.0
     
        // Used for obtaining the closest target:
        private static group g  = CreateGroup()
        private static unit closestTarget
        private static real closestDistance
        private static HurlBoulderMain current
     
        private static method finalEnum takes nothing returns boolean
            local unit u = GetFilterUnit()
            local HurlBoulderMain this = .current //Don't feel like typing "current" everywhere.
            if (damageOptions.allowedTarget( .caster, u ) ) then
                set DamageType = SPELL
                call damageOptions.damageTarget(.caster, u, Damage(.level))
                call Stun_UnitEx(u, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            endif
            set u = null
            return false
        endmethod

        //==============================================================================
        //  The onHit method will be called when the missile reaches its target.
        // In this case, we use it to spawn one last wave of child missiles.
        // We could also do this in the onDestroy method, in that case the last
        // wave of missiles would be launched even if the main missile was
        // prematurely terminated.
        //
        method onHit takes nothing returns nothing
            set .current = this
            call GroupEnumUnitsInRange(.g, .x,.y, TARGET_RADIUS, Condition(function HurlBoulderMain.finalEnum))
        endmethod
    endstruct

    private function spellIdMatch takes nothing returns boolean
        return (GetSpellAbilityId()==SPELL_ID)
    endfunction

    private function onSpellEffect takes nothing returns nothing
        local real tx = GetSpellTargetX()                   //The spell's target, since a recent patch
        local real ty = GetSpellTargetY()                   //we no longer need to use locations for this.
        local unit hero = GetTriggerUnit()                    //The spell's caster
        local integer level = GetUnitAbilityLevel(hero, SPELL_ID) //The level of the spell
        
        local HurlBoulderMain fb = HurlBoulderMain.create(hero, level, tx,ty)
        set hero = null
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()

        // Initializing the damage options:
        set damageOptions=xedamage.create()    // first instanciate a xeobject.
        call setupDamageOptions(damageOptions) // now call the function we saw before.

        //Setting up the spell's trigger:
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function spellIdMatch))
        call TriggerAddAction(t, function onSpellEffect)
        call Preload(MAIN_MODEL)
        call Preload(STUN_EFFECT)
        
        set t = null
    endfunction
endlibrary
