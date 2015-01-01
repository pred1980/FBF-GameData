library Stun

    //-------------------------------------------------------------------------------
    // Keyword used to use un-initialized stuff.
    private keyword Stuns

    //-------------------------------------------------------------------------------
    // Globals
    globals
        private real Interval = 0.05
        private integer AID_UNLIMITED_STUN = 'A001'
        private integer BID_UNLIMITED_STUN = 'B026'
        private integer UID_DUMMY_UNIT = 'h003'
        private string OS_STORM_BOLT = "thunderbolt" 
        private integer array SpellIds
        private integer NSpells = 0 
        
        private timer Timer = null
        private integer array Datas
        private unit array Check
        private integer Counter = 0
    endglobals

    //-------------------------------------------------------------------------------
    // Main loop for managing stun duration.
    private function Periodic takes nothing returns nothing
        local integer i = Counter - 1
        local Stuns s = 0
        loop
            exitwhen i < 0
            set s = Datas[i]
            if (s.Duration <= 0 or GetUnitAbilityLevel(s.Target, BID_UNLIMITED_STUN) < 1) then
                call s.destroy()
                set Counter = Counter - 1
                if (Counter < 0) then
                    set Counter = 0
                    call PauseTimer(Timer)
                endif
                set Datas[i] = Datas[Counter]
                set Check[i] = Check[Counter]
            else
                set s.Duration = s.Duration - Interval
            endif
            set i = i - 1
        endloop
    endfunction

    //-------------------------------------------------------------------------------
    // Struct containing all values we need.
    private struct Stuns
        unit Target
        real Duration
        effect Effect
        
        static group Pivot
        
        //-------------------------------------------------------------------------------
        // Search for getting struct from unit.
        static method Get takes unit whichUnit returns Stuns
            local integer i = Counter - 1
         
            loop
                exitwhen i < 0
                if (Check[i] == whichUnit) then    
                    return Datas[i]
                endif
                set i = i - 1
            endloop
            
            return 0
        endmethod
        
        //-------------------------------------------------------------------------------
        // Main core, allocates struct.
        static method create takes unit whichUnit, real whichDuration, string whichEffect, string whichPos returns Stuns
            local Stuns s
            local boolean b = true
            
            if (whichUnit != null) then
                if (IsUnitInGroup(whichUnit, Stuns.Pivot)) then
                    set s = Stuns.Get(whichUnit)
                    set b = false
                    // Like the normal WcIII stun: if new stun is longer than the current, the swap
                    if (whichDuration > s.Duration) then
                        set s.Duration = whichDuration
                    endif
                endif
                
                if (b) then
                    set s = Stuns.allocate()
                    set s.Target = whichUnit
                    set s.Duration = whichDuration
                    if (whichEffect != "" and whichPos != "") then
                        set s.Effect = AddSpecialEffectTarget(whichEffect, whichUnit, whichPos)
                    endif
                    set Datas[Counter] = s
                    set Check[Counter] = whichUnit
                    set Counter = Counter + 1
                    call GroupAddUnit(Stuns.Pivot, whichUnit)
                endif
            endif
            
            return s
        endmethod
        
        //-------------------------------------------------------------------------------
        // Creates the stun group and global Timer.
        static method onInit takes nothing returns nothing
            set Stuns.Pivot = CreateGroup()
            set Timer = CreateTimer()
        endmethod
        
        //-------------------------------------------------------------------------------
        // Removes the unit from the group and removes stun.
        private method onDestroy takes nothing returns nothing
            call GroupRemoveUnit(Stuns.Pivot, .Target)
            call UnitRemoveAbility(.Target, BID_UNLIMITED_STUN)
            call DestroyEffect(.Effect)
        endmethod
    endstruct

    //-------------------------------------------------------------------------------
    // Stuns the unit here for better readability in the function below.
    private function DummyStun takes unit target returns nothing
        local unit u = CreateUnit(Player(15), UID_DUMMY_UNIT, GetUnitX(target), GetUnitY(target), 0)
           
        call UnitAddAbility(u, AID_UNLIMITED_STUN)
        call IssueTargetOrder(u, OS_STORM_BOLT, target)
        call UnitRemoveAbility(u, AID_UNLIMITED_STUN) 
        
        call ShowUnit(u, false)
        call KillUnit(u)
        set u = null
    endfunction

    //-------------------------------------------------------------------------------
    // call Stun_UnitEx(<YourUnit>, <YourDuration>, <IfCheckImmunity>, <YourEffect>, <YourAttachmentPos>)
    public function UnitEx takes unit whichUnit, real whichDuration, boolean checkImmunity, string whichEffect, string whichPos returns nothing
        local integer i = NSpells 
        local boolean b = true
        local Stuns s
        
        //debug call BJDebugMsg(GetUnitName(whichUnit) + " got stuned for " + R2S(whichDuration) + " seconds!")
        if (checkImmunity) then //<- Check for magic immunity stuff.
            loop  
                exitwhen i < 0
                if (GetUnitAbilityLevel(whichUnit, SpellIds[i]) > 0) then
                    set b = false
                endif
                set i = i - 1
            endloop
            if (IsUnitType(whichUnit, UNIT_TYPE_MAGIC_IMMUNE) == true) then
                set b = false
            endif
        endif
        
        if (b) then
            if (Counter == 0) then
                call TimerStart(Timer, Interval, true, function Periodic)
            endif
           
            set s = Stuns.create(whichUnit, whichDuration, whichEffect, whichPos)
            call DummyStun(whichUnit)
        endif
    endfunction

    //-------------------------------------------------------------------------------
    // call Stun_Unit(<YourUnit>, <YourDuration>, <IfCheckImmunity>)
    public function Unit takes unit whichUnit, real whichDuration, boolean checkImmunity returns nothing
        call Stun_UnitEx(whichUnit, whichDuration, checkImmunity, "", "")
    endfunction

    //-------------------------------------------------------------------------------
    // call Stun_GetRemaining(<YourUnit>) returns <RemainingDuration>
    public function GetRemaining takes unit whichUnit returns real
        local Stuns d = Stuns.Get(whichUnit)
     
        if (d != 0) then
            return d.Duration
        else
            debug call BJDebugMsg("Stun System Error: " + GetUnitName(whichUnit) + " is not stunned or input is null!")
            return 0.
        endif
        return 0.
    endfunction

    //-------------------------------------------------------------------------------
    // call Stun_ModifyDuration(<YourUnit>, <DurationModifier>)
    public function ModifyDuration takes unit whichUnit, real whichModifier returns nothing
        local Stuns d = Stuns.Get(whichUnit)
     
        if (d != 0) then
            set d.Duration = d.Duration + whichModifier
        else
            debug call BJDebugMsg("Stun System Error: " + GetUnitName(whichUnit) + " is not stunned or input is null!")
            return
        endif
    endfunction
    
endlibrary