scope PlagueCloud initializer init
    /*
     * Description: Each unit that comes in range of Blight Cleaver has a chance to get infected with the plague, 
                    taking damage over time. Each infected unit also has a low chance to infect others. 
                    The plague disappears after a few seconds if the unit is not reinfected.
     * Last Update: 11.11.2013
     * Changelog: 
     *     11.11.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        // The interval all units get checkes of bein infected / reinfected, 
        // higher values will increse the possible spread speed
        private real INTERVAL = 0.5
        private integer SPELL_ID = 'A06G'
        //The effect spell which is casted on enemys and causes their pain
        private integer DUMMY_SPELL_ID = 'A06J'
        //The id of a dummy used to cast the spell above when a unit gets infected/ reinfected
        private integer DUMMY =  'h015'
        //The buff an infected uni got of the effect spell 
        private integer BUFF_ID = 'B00T'
        //The order id of the effect spell
        private string ORDER_ID = "unholyfrenzy"
        // Do not change the following
        private group Infected = CreateGroup()
        private group g = CreateGroup()
        private timer t = CreateTimer()
        private boolexpr filter = null
    endglobals


    ///////////////////////////////////Defining most relevant Values////////////////////////////////////////////////

    //Defines how long an infection will last without any reinfactions
    private function DurationPerLevel takes integer level returns integer
        return 2 + level
    endfunction

    //Defines the infection range of the hero spreading the flu
    private constant function InfectionRange takes real level returns real
        return 175 + 25 * level 
    endfunction

    //Defines the infection range of an infected unit
    private constant function InfectedInfectionRange takes real level returns real
        return 175 + 25 * level 
    endfunction

    //Defines the chance per interval to infect a unit with the hero 
    private constant function InfectionChance takes real level returns real
        return 0.2 + 0.15 * level
    endfunction

    //Defines the chance per interval of an infected unit to infect another 
    private constant function InfectedInfectionChance takes real level returns real
        return 0.12
    endfunction

    //The conditions a unit can be infected 
    private function InfectCondition takes unit a, player p returns boolean
        return not IsUnitType(a, UNIT_TYPE_MECHANICAL) and not /*
        */         IsUnitType(a, UNIT_TYPE_MAGIC_IMMUNE) and not/*
        */         IsUnitDead(a) and IsPlayerEnemy(GetOwningPlayer(a),p) // The condition if a unit is infected
    endfunction

     //The condition if trigger should run (refers to the event : EVENT_PLAYER_HERO_SKILL)
    private function RunCondition takes nothing returns boolean
        return GetUnitAbilityLevel(GetTriggerUnit(), SPELL_ID) != 0
    endfunction

    //////////////////////////////////Main Struckt//Do not change//////////////////////////////////////////////

    private struct Infection
        static integer Index = 0
        static Infection array Data
        integer left 
        unit u = null
        player p 
        integer level = 0
        static method create takes nothing returns Infection
            local Infection data = Infection.allocate()
            set Infection.Data[Infection.Index] = data
            set Infection.Index = Infection.Index + 1
            return data
        endmethod
    endstruct

    ////////////////////////////////Main script// Do not edit unless you understand it////////////////////////////////

    private function AddPlagueCloud takes unit target, integer level, player a returns nothing
        local unit dummy = CreateUnit(a,DUMMY,GetUnitX(target),GetUnitY(target), 0)
        call UnitAddAbility(dummy,DUMMY_SPELL_ID)
        call SetUnitAbilityLevel(dummy, DUMMY_SPELL_ID,level)
        call UnitApplyTimedLife(dummy, 'BTLF', 0.75)
        call IssueTargetOrder( dummy,  ORDER_ID, target)
        set dummy = null
    endfunction

    private function GetStructOfUnit takes unit u returns integer
        local integer ret = 0
        local Infection data
        local integer i = 0
        loop
            exitwhen i >= Infection.Index
            set data = Infection.Data[i]
            if data.u == u then 
                set ret = i
            endif
            set i = i +1
        endloop
        return ret       
    endfunction

    private constant function NullFilter takes nothing returns boolean
        return true
    endfunction

    private function Callback takes nothing returns nothing
        local Infection data
        local integer i = 0
        local integer ii = 0
        local integer level = 0
        local unit b 
        local unit a
        local real x 
        local real y
        local real c 
        local integer max = Infection.Index
        loop //looping through all structs
            exitwhen i >= max
            set data = Infection.Data[i]
            set a = data.u
            if (GetWidgetLife(a) > 0) and (data.left != 0) then //buff gets removed +  struct destroey if the unit is dead or its infection timer expires
                if data.left != -1 then
                    set data.left = data.left-1 // decreases infection timer , -1 means its forever (in this case for your hero)
                endif
                set level = data.level
                set x = GetUnitX(a)
                set y = GetUnitY(a)
                if GetOwningPlayer(a) == data.p then
                    call GroupEnumUnitsInRange(g, x, y,InfectionRange(I2R(data.level)), filter) 
                else
                    call GroupEnumUnitsInRange(g, x, y,InfectedInfectionRange(I2R(data.level)), filter) 
                endif
                call GroupRemoveUnit(g,a)
                loop //looping through all units in range
                    set b = FirstOfGroup(g)            
                    exitwhen b == null
                    call GroupRemoveUnit(g,b)
                    set ii = GetStructOfUnit(b)
                    set c = GetRandomReal(0.00, 1.00)
                    if ((c < InfectionChance(data.level) and GetOwningPlayer(a) == data.p) or (c < InfectedInfectionChance(data.level) and GetOwningPlayer(a) != data.p)) and InfectCondition(b,data.p) == true and ((Infection.Data[ii].left != -1) or not(IsUnitInGroup(b,Infected)))then
                        if not(IsUnitInGroup(b,Infected)) then
                            //Infecting the target 
                            call GroupAddUnit(Infected,b)   
                            call AddPlagueCloud(b,data.level,data.p)
                            call Infection.create()
                            set Infection.Data[Infection.Index-1].u = b
                            set Infection.Data[Infection.Index-1].p = data.p
                            set Infection.Data[Infection.Index-1].level = data.level
                            set Infection.Data[Infection.Index-1].left = R2I(I2R(DurationPerLevel(data.level))/INTERVAL)                        
                        else
                            //Reinfecting the target
                            if Infection.Data[ii].level < data.level then
                                set Infection.Data[ii].level = data.level
                                set Infection.Data[ii].p = data.p
                                call AddPlagueCloud(b,data.level,data.p)
                                set Infection.Data[ii].left = R2I(I2R(DurationPerLevel(data.level))/INTERVAL)    
                            else 
                                set Infection.Data[ii].left = R2I(I2R(DurationPerLevel(data.level))/INTERVAL)    
                            endif
                        endif 
                    endif
                endloop
            else 
                //detroying struct + removing buff
                call UnitRemoveAbility(data.u, BUFF_ID)
                call GroupRemoveUnit(Infected,data.u)
                set data.u = null
                set data.p = null
                call Infection.destroy(data)
                set ii = i
                loop                
                    exitwhen ii == Infection.Index
                    set Infection.Data[ii] = Infection.Data[ii+1]
                    set ii = ii + 1
                endloop
                set i = i -1
                set Infection.Index = Infection.Index - 1
                set max = max - 1            
            endif
            set i = i + 1
            set ii = 0
            set level = 0
        endloop
        set a = null
        set b = null
    endfunction

    private function Actions takes nothing returns nothing
        local integer i
        local unit u = GetTriggerUnit()
        if IsUnitInGroup(u, Infected) then 
            //modifing the current struct if the unit had Plague Cloud before
            set i = GetStructOfUnit(u)
            set Infection.Data[i].p = GetOwningPlayer(u)
            set Infection.Data[i].level = GetUnitAbilityLevel(u, SPELL_ID)
        else
            //creating the struct and adding the hero
            call GroupAddUnit(Infected,u)
            call Infection.create()
            set Infection.Data[Infection.Index-1].u = u
            set Infection.Data[Infection.Index-1].left = -1
            set Infection.Data[Infection.Index-1].p = GetOwningPlayer(u)
            set Infection.Data[Infection.Index-1].level = GetUnitAbilityLevel(u, SPELL_ID)
            if Infection.Data[Infection.Index-1].Index == 1 then
                call TimerStart(t, INTERVAL, true, function Callback)
            endif
        endif
        set u = null
    endfunction

    //===========================================================================
    private function init takes nothing returns nothing
        local integer index
        local trigger tr = CreateTrigger()
        local boolexpr cond = Condition( function RunCondition )
        set filter = Filter(function NullFilter)
        set index = 0
        loop
            call TriggerRegisterPlayerUnitEvent(tr, Player(index), EVENT_PLAYER_HERO_SKILL, filter)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddCondition( tr, cond )
        call TriggerAddAction( tr, function Actions )
        set cond = null
        
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction

endscope