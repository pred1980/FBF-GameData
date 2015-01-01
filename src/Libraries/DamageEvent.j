library DamageEvent initializer Init requires optional DamageModifiers, optional LightLeaklessDamageDetect, optional IntuitiveDamageSystem, optional xedamage

//*****************************************************************
//*  DAMAGE EVENT LIBRARY
//*
//*  written by: Anitarf
//*  supports: -DamageModifiers
//*
//*  This is a damage detection library designed to compensate for
//*  the lack of a generic "unit takes damage" event in JASS.
//*
//*  All functions following the Response function interface that
//*  is defined at the end of the calibration section of this
//*  library can be used to respond to damage events. Simply add
//*  such functions to the system's call list with the
//*  RegisterDamageResponse function.
//*
//*  function RegisterDamageResponse takes Response r returns nothing
//*
//*  DamageEvent fully supports the use of DamageModifiers. As
//*  long as you have the DamageModifiers library in your map
//*  DamageEvent will use it to modify the damage before calling
//*  the response functions.
//*
//*  If the map contains another damage detection library,
//*  DamageEvent will interface with it instead of creating
//*  it's own damage event triggers to improve performance.
//*  Currently supported libraries are LightLeaklessDamageDetect
//*  and IntuitiveDamageSystem.
//*
//*  DamageEvent is also set up to automatically ignore dummy
//*  damage events sometimes caused by xedamage when validating
//*  targets (only works with xedamage 0.7 or higher).
//*****************************************************************

    globals
        // In wc3, damage events sometimes occur when no real damage is dealt,
        // for example when some spells are cast that don't really deal damage,
        // so this system will only consider damage events where damage is
        // higher than this threshold value.
        private constant real DAMAGE_THRESHOLD = 0.0
        
    // The following calibration options are only used if the system uses
    // it's own damage detection triggers instead of interfacing with other
    // damage event engines:

        // If this boolean is true, the damage detection trigger used by this
        // system will be periodically destroyed and remade, thus getting rid
        // of damage detection events for units that have decayed/been removed.
        private constant boolean REFRESH_TRIGGER = true

        // Each how many seconds should the trigger be refreshed?
        private constant real TRIGGER_REFRESH_PERIOD = 300.0
        
        // Variables for damage type detection
        integer DamageType = 0
        constant integer PHYSICAL = 0
        constant integer SPELL = 1
        constant integer PHYSICAL_AND_SPELL = 2
        constant real UNIT_MIN_LIFE = 0.406
        boolean IsDead = false
    endglobals

    private function CanTakeDamage takes unit u returns boolean
        // You can filter out which units need damage detection events with this function.
        // For example, dummy casters will never take damage so the system doesn't need to register events for them,
        // by filtering them out you are reducing the number of handles the game will create, thus increasing performance.
        //return GetUnitTypeId(u)!='e000' // This is a sample return statement that lets you ignore a specific unit type.
        return true
    endfunction

    // This function interface is included in the calibration section
    // for user reference only and should not be changed in any way.
    public function interface Response takes unit damagedUnit, unit damageSource, real damage returns nothing

    function SET_DAMAGE_TYPE takes integer dmgtype returns nothing
        set DamageType = dmgtype
    endfunction
    
// END OF CALIBRATION SECTION    
// ================================================================

    globals
        private Response array responses
        private integer responsesCount = 0
    endglobals

    function RegisterDamageResponse takes Response r returns nothing
        set responses[responsesCount]=r
        set responsesCount=responsesCount+1
    endfunction
    
    function ResetIsDead takes nothing returns nothing
        set IsDead = false
    endfunction
    
    private function Damage takes nothing returns nothing
        // Main damage event function.
        local unit damaged=GetTriggerUnit()
        local unit damager=GetEventDamageSource()
        local real damage=GetEventDamage()
        local integer i = 0
        
        loop
            exitwhen not (damage>DAMAGE_THRESHOLD)
            static if LIBRARY_xedamage then
                exitwhen xedamage.isDummyDamage
            endif
          
            if ( GetWidgetLife(damaged) - damage ) < UNIT_MIN_LIFE then
                set IsDead = true
            endif

            static if LIBRARY_DamageModifiers then
                set damage=RunDamageModifiers()
            endif
            
            loop
                exitwhen i>=responsesCount
                call responses[i].execute(damaged, damager, damage)
                set i=i+1
            endloop
            set DamageType = PHYSICAL
            exitwhen true
        endloop

        set damaged=null
        set damager=null
    endfunction
    
    private function DamageC takes nothing returns boolean
        call Damage() // Used to interface with LLDD.
        return false
    endfunction

// ================================================================

    globals
        private group g
        private boolexpr b
        private boolean clear
        
        private trigger currentTrg
        private triggeraction currentTrgA
        private trigger oldTrg = null
        private triggeraction oldTrgA = null
    endglobals

    private function TriggerRefreshEnum takes nothing returns nothing
        // Code "borrowed" from Captain Griffen's GroupRefresh function.
        // This clears the group of any "shadows" left by removed units.
        if clear then
            call GroupClear(g)
            set clear = false
        endif
        call GroupAddUnit(g, GetEnumUnit())
        // For units that are still in the game, add the event to the new trigger.
        call TriggerRegisterUnitEvent( currentTrg, GetEnumUnit(), EVENT_UNIT_DAMAGED )
    endfunction
    private function TriggerRefresh takes nothing returns nothing
        // The old trigger is destroyed with a delay for extra safety.
        // If you get bugs despite this then turn off trigger refreshing.
        if oldTrg!=null then
            call TriggerRemoveAction(oldTrg, oldTrgA)
            call DestroyTrigger(oldTrg)
        endif
        // The current trigger is prepared for delayed destruction.
        call DisableTrigger(currentTrg)
        set oldTrg=currentTrg
        set oldTrgA=currentTrgA
        // The current trigger is then replaced with a new trigger.
        set currentTrg = CreateTrigger()
        set currentTrgA = TriggerAddAction(currentTrg, function Damage)
        set clear = true
        call ForGroup(g, function TriggerRefreshEnum)
        if clear then
            call GroupClear(g)
        endif
    endfunction

// ================================================================

    private function DamageRegister takes nothing returns boolean
        local unit u = GetFilterUnit()
        if CanTakeDamage(u) then
            call TriggerRegisterUnitEvent( currentTrg, u, EVENT_UNIT_DAMAGED )
            call GroupAddUnit(g, u)
        endif
        set u = null
        return false
    endfunction

    private function Init takes nothing returns nothing
        local rect rec
        local region reg
        local trigger t
        
      static if LIBRARY_IntuitiveDamageSystem then

        // IDDS initialization code
        set t=CreateTrigger()
        call TriggerAddAction(t, function Damage)
        call TriggerRegisterDamageEvent(t, 0)

      else
      static if LIBRARY_LightLeaklessDamageDetect then

        // LLDD initialization code
        call AddOnDamageFunc(Condition(function DamageC))

      else
        
        // DamageEvent initialization code
        set rec = GetWorldBounds()
        set reg = CreateRegion()
        set t = CreateTrigger()
        call RegionAddRect(reg, rec)
        call TriggerRegisterEnterRegion(t, reg, Condition(function DamageRegister))
        
        set currentTrg = CreateTrigger()
        set currentTrgA = TriggerAddAction(currentTrg, function Damage)

        set g = CreateGroup()
        call GroupEnumUnitsInRect(g, rec, Condition(function DamageRegister))
        
        if REFRESH_TRIGGER then
            call TimerStart(CreateTimer(), TRIGGER_REFRESH_PERIOD, true, function TriggerRefresh)
        endif
        
        call RemoveRect(rec)
        set rec = null
        set b = null
        
      endif
      endif
    endfunction
endlibrary