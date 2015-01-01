scope AuraOfRedemption initializer Init
	/*
	 * Item: Kodo Vest
	 */ 
    globals
        // CLOSE_RANGE_BONUS = How much strength you get when in Close Range
        private constant integer    CLOSE_RANGE_BONUS       = 15
        // MEDIUM_RANGE_BONUS = How much strength you get when in Medium Range
        private constant integer    MEDIUM_RANGE_BONUS      = 10
        // LONG_RANGE_BONUS = How much strength you get when in Long Range
        private constant integer    LONG_RANGE_BONUS        = 5
        // CLOSE_RANGE = Indicates how long Close Range is.
        private constant real       CLOSE_RANGE             = 200
        // MEDIUM_RANGE = Indicates how long Medium Range is.
        private constant real       MEDIUM_RANGE            = 400
        // LONG_RANGE = Indicates how long Long Range is.
        private constant real       LONG_RANGE              = 600
        // FULL_STR = Should it Include Bonuses from strength gain??
        private constant boolean    FULL_STR                = TRUE
        // SPELL_ID = ...
        private constant integer    ITEM_ID                = 'I02Y'
        // BUFF_ID = ...
        private constant integer    BUFF_ID                 = 'B018'
        // TIMERTICK = Every X seconds ticks, checking and adding strength. ( A tip, dont have it below 0.05.
        private constant real       TIMERTICK               = 0.25
        
    //Dont Touch. Just dont do it.
    //**==*==*==*==*==*==*==*==*==*==*==*==*==*==*==*==*==*==*=|
    /*          */private real globX                        //=|
    /*          */private real globY                        //=|
    /*          */private group tmpGrp = CreateGroup()      //=|
    /*          */private unit picked                       //=|
    /*          */private unit Owner                        //=|
    /*          */private timer array ti                    //=|
    /*          */private hashtable table = InitHashtable() //=|
    /*          */private unit array HeroWithAura           //=|
    /*          */private integer HeroWithAuraCount = 0     //=|
    //**==*==*==*==*==*==*==*==*==*==*==*==*==*==*==*==*==*==*=|
    endglobals

    private constant function CLOSE takes nothing returns integer
        return CLOSE_RANGE_BONUS
    endfunction

    private constant function MEDIUM takes nothing returns integer
        return MEDIUM_RANGE_BONUS
    endfunction

    private constant function FAR takes nothing returns integer
        return LONG_RANGE_BONUS
    endfunction

    private struct Data
        private real x
        private real y
        private real range
        private real xx
        private real yy
        private real r
        private unit Enum
        
        private method ApplyBonus takes unit u, integer bonus returns nothing
            //As name, the function used to add bonuses.
            if HaveSavedInteger(table, GetHandleId(u), 1) then
                call SetHeroStr(u, GetHeroStr(u, FULL_STR)-LoadInteger(table, GetHandleId(u), 1), FULL_STR)
                if bonus == 0 then
                    call RemoveSavedInteger(table, GetHandleId(u), 1)
                else
                    call SaveInteger(table, GetHandleId(u), 1, bonus)
                endif
            else
                if bonus != 0 then
                    call SaveInteger(table, GetHandleId(u), 1, bonus)
                endif
            endif
            call SetHeroStr(u, GetHeroStr(u, FULL_STR)+bonus, FULL_STR)
        endmethod

        static method GetUnitAuraBonus takes unit u returns integer 
            //This function "checks" where the unit is, and adds bonus after that condition
            local integer i = 0
            local integer m = 0
            loop
                exitwhen i == HeroWithAuraCount
                if IsUnitInRange(u, HeroWithAura[i], LONG_RANGE) then
                
                    if IsUnitInRange(u, HeroWithAura[i], CLOSE_RANGE) then
                        if CLOSE() > m then
                            set m = CLOSE()
                        endif
                    elseif IsUnitInRange(u, HeroWithAura[i], MEDIUM_RANGE) then
                        if MEDIUM() > m then
                            set m = MEDIUM()
                        endif
                    elseif IsUnitInRange( u ,HeroWithAura[i], LONG_RANGE) then
                        if FAR() > m then
                            set m = FAR()
                        endif
                    endif
                endif
                set i = i + 1
            endloop
            return m
        endmethod

        static method loopFuncEnum takes nothing returns nothing
            local thistype this = allocate()
            set Enum = GetEnumUnit()
            call ApplyBonus(Enum, GetUnitAuraBonus(Enum)) //Applies the bonus.
            set Enum = null
        endmethod
        
    endstruct

    private function hasBuff takes nothing returns boolean
        return GetUnitAbilityLevel(GetFilterUnit(), BUFF_ID) > 0
        // Filter, which picks all units in the range Which has the buff.
    endfunction
    
    private function doLoop takes nothing returns nothing
        local rect r = GetWorldBounds()
        call GroupEnumUnitsInRect(tmpGrp, r, Filter(function hasBuff))
        call ForGroup(tmpGrp, function Data.loopFuncEnum)
        call ReleaseGroup( tmpGrp )
        call RemoveRect(r)
        set r = null
    endfunction
    
    private function pickup takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        set ti[pid] = CreateTimer()
        call TimerStart( ti[pid] , TIMERTICK , true , function doLoop )
        set HeroWithAura[HeroWithAuraCount] = GetTriggerUnit()
        set HeroWithAuraCount = HeroWithAuraCount + 1
    endfunction

    private function drop takes nothing returns nothing
        local integer i = 0
        local unit u = GetTriggerUnit()
        local integer pid = GetPlayerId(GetOwningPlayer(u))
        loop
            exitwhen HeroWithAura[i] == u
            set i = i + 1
        endloop
        set HeroWithAuraCount = HeroWithAuraCount - 1
        loop
            exitwhen i == HeroWithAuraCount
            set HeroWithAura[i] = HeroWithAura[i + 1]
            set i = i + 1
        endloop
        set u = null
        call DestroyTimer(ti[pid])
    endfunction

    private function Conditions takes nothing returns boolean
        return GetItemTypeId(GetManipulatedItem()) == ITEM_ID
    endfunction

    //==================================================================================================================
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger d = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_PICKUP_ITEM )
        call TriggerRegisterAnyUnitEventBJ( d, EVENT_PLAYER_UNIT_DROP_ITEM )
        call TriggerAddCondition( t , Condition(function Conditions ))
        call TriggerAddCondition( d , Condition(function Conditions ))
        call TriggerAddAction( t , function pickup )
        call TriggerAddAction( d , function drop )
    endfunction

endscope