scope Fireblast initializer Init
    /*
     * Description: The Blood Mage launches a Fire Blast that spits smaller fireballs at the closest enemy unit. 
                    When the Blast lands, it fires one last wave of fireballs at all nearby enemies.
     * Last Update: 03.01.2014
     * Changelog: 
     *     03.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A091'
        
        private constant real TARGET_RADIUS = 350.0 // In what range to look for child missile targets?
        private constant real LAUNCH_PERIOD = 0.2   // How often to launch child missiles in flight?

        // Main missile visual settings:
        private constant string MAIN_MODEL =  "Models\\Fireblast.mdx"
        private constant real MAIN_SCALE = 2.0
        private constant real MAIN_LAUNCH_OFFSET = 60.0
        private constant real MAIN_SPEED = 500.0
        private constant real MAIN_ARC = 0.25

        // Child missile visual settings:
        private constant string CHILD_MODEL = "Models\\Fireblast.mdx" //"Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl"
        private constant real CHILD_SCALE = 0.5
        private constant real CHILD_SPEED = 1000.0
        private constant real CHILD_ARC = 0.15
    endglobals
    
    private constant function Damage takes integer level returns real
        return 40.0 * level // How much damage each child missile deals.
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
    //  FireblastChild struct: these are our damage-dealing missiles that deal damage.
    // If you have used xecollider before, this should look familiar: by extending an
    // xehomingmissile we can create our own custom homing missile that includes custom
    // data and code.
    //
    //
    struct FireblastChild extends xehomingmissile
        private unit    caster
        private integer level

        //==============================================================================
        //  We can declare a custom create method for our missile, note the parameters used
        // when calling .allocate, they must match those of xehomingmissile's create method.
        //
        static method create takes unit caster, integer level, real x, real y, real z, unit target returns FireblastChild
            local FireblastChild this = FireblastChild.allocate(x,y,z, target,60.0)

            // Let us configure our projectile's custom data:
            set this.caster = caster
            set this.level  = level

            // Time to configure the delegate xefx properties:
            set this.fxpath = CHILD_MODEL
            set this.scale  = CHILD_SCALE

            // Launch the newly created missile:
            call this.launch(CHILD_SPEED, CHILD_ARC)

            return this
        endmethod

        //==============================================================================
        //  The onHit method will be called when the missile reaches its target.
        // In this case, we use it to deal damage to the targeted unit.
        //
        method onHit takes nothing returns nothing
            set DamageType = SPELL
            call damageOptions.damageTarget(.caster, .targetUnit, Damage(.level))
        endmethod
    endstruct

    //==================================================================================
    //  FireblastMain struct: the main spell missile. Since it is not a homing missile,
    // it extends xemissile instead of xehomingmissile. Again, it contains custom data
    // and code that make it a different missile from the FireblastChild one.
    //
    //
    struct FireblastMain extends xemissile
        private unit    caster
        private integer level

        //==============================================================================
        //  We can declare a custom create method for our missile, note the parameters used
        // when calling .allocate, they must match those of xemissile's create method.
        //
        static method create takes unit caster, integer level, real tx, real ty returns FireblastMain
            local real x = GetUnitX(caster)
            local real y = GetUnitY(caster)
            local real z = GetUnitFlyHeight(caster)+MAIN_LAUNCH_OFFSET
            local FireblastMain this = FireblastMain.allocate(x,y,z, tx,ty,0.0)

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
        private static FireblastMain current
     
        private static method targetEnum takes nothing returns boolean
            local unit u        = GetFilterUnit()
            local real dx       = GetUnitX(u) - current.x
            local real dy       = GetUnitY(u) - current.y
            local real distance = dx * dx + dy * dy
                if distance < .closestDistance and (damageOptions.allowedTarget( current.caster, u ) ) then
                    set .closestDistance = distance
                    set .closestTarget   = u
                endif
            set u = null
            return false
        endmethod

        //===============================================================================
        // Let us use the loopControl event to spawn the child missiles periodically.
        // We will also use this method to tweak the missile's trajectory.
        //
        method loopControl takes nothing returns nothing
            // Notice loopControl gets called for the missile every XE_ANIMATION_PERIOD seconds
            set launchtime = launchtime + XE_ANIMATION_PERIOD
           
            // Fire a new child missile every LAUNCH_PERIOD seconds:
            // I use a loop in case LAUNCH_PERIOD is less than XE_ANIMATION_PERIOD,
            // in which case multiple missiles may get launched per update.
            loop
                exitwhen launchtime < LAUNCH_PERIOD
                    set launchtime = launchtime - LAUNCH_PERIOD
                    // Find the nearest enemy unit:
                    set .current         = this
                    set .closestTarget   = null
                    set .closestDistance = TARGET_RADIUS*TARGET_RADIUS
                    call GroupEnumUnitsInRange(.g, .x,.y, TARGET_RADIUS, Condition(function FireblastMain.targetEnum))
                    if .closestTarget!=null then
                        // Create the child missile, its create method should handle the rest.
                        call FireblastChild.create(.caster, .level,.x,.y,.z, .closestTarget)
                    endif
            endloop
           
            // Also, constantly re-launch the missile to get a more unique movement arc
            call this.launch(MAIN_SPEED, MAIN_ARC)
        endmethod
        
        //==============================================================================

        private static method finalEnum takes nothing returns boolean
            local unit u = GetFilterUnit()
            local FireblastMain this = .current //Don't feel like typing "current" everywhere.
            if (damageOptions.allowedTarget( .caster, u ) ) then
                call FireblastChild.create(.caster, .level,.x,.y,.z, u)
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
            call GroupEnumUnitsInRange(.g, .x,.y, TARGET_RADIUS, Condition(function FireblastMain.finalEnum))
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

        local FireblastMain fb = FireblastMain.create(hero, level, tx,ty)

        set hero=null // it is good to null handle variables at the end of a function...
    endfunction

   //=====================================================================================================
   // Init stuff:
   //
   private function Init takes nothing returns nothing
        local trigger t=CreateTrigger()

        // Initializing the damage options:
        set damageOptions=xedamage.create()    // first instanciate a xeobject.
        call setupDamageOptions(damageOptions) // now call the function we saw before.

        //Setting up the spell's trigger:
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function spellIdMatch))
        call TriggerAddAction(t, function onSpellEffect)
        call Preload(MAIN_MODEL)
        set t=null
    endfunction
endscope
