scope RevengeOwl initializer Init
    /*
     * Description: The Owl of the Priestess flys over the enemys army calls down waves of falling stars 
                    that damage nearby enemy units. The Owl is invulnerable and can be controlled for a short moment.
     * Changelog: 
     *     07.01.2014: Abgleich mit OE und der Exceltabelle
	 *     28.04.2015: Integrated RegisterPlayerUnitEvent
     *
     */    
     globals 
        //Settings for the Owl
        private constant integer SPELL_ID = 'A07H'
        private constant integer OWL_ID = 'h00T' //rawcode of the owl
        private constant real FADE_TIME = 0.3  //the amount of time the owl will take to fade in
        private constant real DIVE_TIME = 0.7   //the time the owl will take into diving in and out
        private constant real SPEED = 8 //the speed of the owl
        private constant integer HEIGHT = 375 //the bombard height
        private constant real MOVE_TIME = 0.02 //the frequency of the timer
        private constant real INTERVAL = 0.5 //the interval that separates each missile
        private constant string BOOM = "Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl" //the effect that appears when the owl dies before finishing the mission
        private constant integer OWL_RED = 255  //The Red RGB color of the Owl 
        private constant integer OWL_GREEN = 255  //The Green RGB color of the Owl 
        private constant integer OWL_BLUE = 255  //The Blue RGB color of the Owl 
        private constant integer FADE_MAX = 255  //The maximum Alpha the owl will have. This is ralated to the transparency and therefore to the fading.
        
        //Settings for the Missile
        private constant integer MISSILE_ID = 'h00U' //the Id of the missile
        private constant integer DUMMY_ID = 'h00V'    //the dummy unit that will attack and cause sfx
        private constant string DUMMY_ORDER = "attackground"  //it's order
        private constant integer DUMMY_SPELL_ID = 'A07I'   //Burning Oil Ability
        private constant integer EFFECT_UNIT_ID = 'h00S'  //Effect effect unit
        private constant real EFFECT_DURATION = 1.//duration of the sfx effect
        private constant real GRAVITY = 8.5 //the velocity at which the missile will fall
    endglobals   
    
    private constant function OwlStartDistance takes integer level returns real
    //the ditance that the owl will be from the caster when it is created 
    //you can make it depend on the level like in the next example
        return 700.
    endfunction
    
    private constant function MissilesNumber takes integer level returns integer
        //the number of missiles the owl will drop
        return 4 + (level * 1)
    endfunction
    
    private function MissileEffect takes unit aMissile returns nothing
    //This is the effect of the missile. It will be displayed when it dies.
    //the function takes as a parameter the dying missile
        local unit missile = aMissile
        local real bombX = GetUnitX(missile)
        local real bombY = GetUnitY(missile)
        local player p = GetOwningPlayer(missile)
        local unit dummy
        local unit sfx
        
         //if the missile is falling inside the map we create the sfx
        if (GetRectMinX(bj_mapInitialPlayableArea) <= bombX) and (bombX <= GetRectMaxX(bj_mapInitialPlayableArea)) and (GetRectMinY(bj_mapInitialPlayableArea) <= bombY) and (bombY <= GetRectMaxY(bj_mapInitialPlayableArea)) then
            //here the dummy launches burning oil to the ground
            set dummy = CreateUnit(p, DUMMY_ID, bombX, bombY, 0.0)
            call UnitAddAbility(dummy, DUMMY_SPELL_ID)
            call IssuePointOrder(dummy, DUMMY_ORDER, bombX, bombY)
            call UnitApplyTimedLife( dummy,'BTLF', 1.)

            //here we use a dummy unit as an effect of the sfx
            set sfx = CreateUnit(p, EFFECT_UNIT_ID, bombX, bombY, 0.0) 
            call UnitApplyTimedLife( sfx,'BTLF', EFFECT_DURATION)
            call SetUnitPathing(sfx, false)
        endif
        
        set missile = null
        set p = null
        set dummy = null
        set sfx = null          
    endfunction

    globals
        private group Missileers   //to store the owls!
        private HandleTable activeTable //your private Table's global variable
    endglobals
    
    //this keeps track of all information we need for the owl
    private struct OwlData 
        unit caster //the caster of the spell
        integer level   //the level of the ability
        unit owl //this is the owl that will appear
        real height     //this is the innitial height of the owl. It starts with 600 (look object editor)
        timer mover //this timer will move the owl
        real elapsedTime    //this specifies the current time of the spell
        integer missilesDropped    //number of missiles dropped
        real totalFlightDuration    //the total amount of time the flight will take
        boolean isOnMissileingHeight   //if true than our owl is dropping missiles, else it is flying

        static method create takes unit caster, real spellX, real spellY, real angle returns OwlData
            local OwlData data = OwlData.allocate()
            
            //set variables about the caster
            set data.caster = caster
            set data.level = GetUnitAbilityLevel(data.caster, SPELL_ID)
            
            //variables about the owl
            set data.owl = CreateUnit(GetOwningPlayer(data.caster),  OWL_ID, spellX - OwlStartDistance(data.level) * Cos(angle * bj_DEGTORAD), spellY - OwlStartDistance(data.level) * Sin(angle * bj_DEGTORAD), angle)
            set data.height = GetUnitFlyHeight(data.owl)
            set data.mover = NewTimer()
            set data.missilesDropped = 0
            set data.isOnMissileingHeight = false
            
            set data.elapsedTime = 0
            
            //the total amount of fly time will take
            set data.totalFlightDuration = (FADE_TIME + DIVE_TIME) + (2 * DIVE_TIME) + (2 * FADE_TIME) + (MissilesNumber(data.level) * INTERVAL)
            
            //this makes the owl start invisible
            call SetUnitVertexColor(data.owl, OWL_RED, OWL_GREEN, OWL_BLUE, R2I(255 * (data.elapsedTime / FADE_TIME)))
            call SetUnitPathing(data.owl, false)
            
            //put the struct in the Table, we just use the owl's
            //handle adress as the key which tells us where in the 
            //Table the struct is stored
            set activeTable[data.owl] = data 
            call GroupAddUnit(Missileers, data.owl)
            
            return data
        endmethod
        
        method onDestroy takes nothing returns nothing
            //since the owl dies now we clean the table     
            call activeTable.flush(.owl) 
            
            //the unit is not anymore in the active units group
            call GroupRemoveUnit(Missileers, .owl) 

            call ReleaseTimer(.mover)
            
            if (.elapsedTime >= .totalFlightDuration) then
                call ShowUnit(.owl, false)
                call KillUnit(.owl)
            else
                call DestroyEffect(AddSpecialEffectTarget(BOOM, .owl, "origin"))
            endif
        endmethod
    endstruct
    
    //this takes care of each missile individualy. So if the owl dies while bombing
    //the released missiles will still fall and damage the enemies !
    private struct MissileData
        private unit missile 
        private real bombX
        private real bombY
        private timer t
        
        static method bombFall takes nothing returns nothing
            local MissileData data = MissileData(GetTimerData(GetExpiredTimer())) 
            
            //here we move the missile !
            set data.bombX = GetUnitX(data.missile) + SPEED * Cos(bj_DEGTORAD*GetUnitFacing(data.missile))
            set data.bombY = GetUnitY(data.missile) + SPEED * Sin(bj_DEGTORAD*GetUnitFacing(data.missile))
            call SetUnitPosition(data.missile,data.bombX, data.bombY)
            
            if (GetUnitFlyHeight(data.missile) > GRAVITY) then
                //if the missile didn't reach ground, make it fall
                call SetUnitFlyHeight(data.missile, GetUnitFlyHeight(data.missile) - GRAVITY, 0)
            else
                //if it reached the ground we kill it and sfx the effect trigger
                call data.destroy()
            endif
            
        endmethod
        
        static method create takes unit owl returns MissileData
            local MissileData data = MissileData.allocate()
            
            set data.missile = CreateUnit(GetOwningPlayer(owl), MISSILE_ID, GetUnitX(owl), GetUnitY(owl), GetUnitFacing(owl)) 
            set data.bombX = GetUnitX(owl)
            set data.bombY = GetUnitY(owl)
            
            call SetUnitPathing(data.missile, false)
            call SetUnitFlyHeight(data.missile, GetUnitFlyHeight(owl), 0)
            
            set data.t = NewTimer()
            call SetTimerData(data.t, integer(data))
            call TimerStart(data.t, MOVE_TIME, true, function MissileData.bombFall)
            
            return data
        endmethod
        
        method onDestroy takes nothing returns nothing
            call MissileEffect(.missile)
            call ReleaseTimer(.t)
            call KillUnit(.missile)
        endmethod
    endstruct
//======================================================================================
    
//======================================================================================
    private function MoveOwl takes nothing returns nothing
        local OwlData owl = OwlData(GetTimerData(GetExpiredTimer())) 
        local MissileData missile 
        
        set owl.elapsedTime = owl.elapsedTime + MOVE_TIME
        
        //here we make the owl fade in or fade out, depending on the timer
        if (owl.elapsedTime <= FADE_TIME) then
            call SetUnitVertexColor(owl.owl, OWL_RED, OWL_GREEN, OWL_BLUE, R2I(255 * (owl.elapsedTime / FADE_TIME)))
        elseif (owl.elapsedTime >= owl.totalFlightDuration - FADE_TIME) then
            call SetUnitVertexColor(owl.owl, OWL_RED, OWL_GREEN, OWL_BLUE, R2I(255 * ((owl.totalFlightDuration - owl.elapsedTime) / FADE_TIME)))
        endif
        
        //here we make the owl dive in or dive out, depending on the timer
        if (owl.elapsedTime >= FADE_TIME) and not(owl.isOnMissileingHeight) then
            set owl.isOnMissileingHeight = true
            call SetUnitFlyHeight(owl.owl, HEIGHT, (owl.height - HEIGHT) / DIVE_TIME)
        elseif (owl.elapsedTime >= owl.totalFlightDuration - DIVE_TIME - FADE_TIME) and (owl.isOnMissileingHeight) then
            set owl.isOnMissileingHeight = false
            call SetUnitFlyHeight(owl.owl, owl.height, (owl.height - HEIGHT) / DIVE_TIME)     
        endif
        
        //if we already faded in and dived in, we drop the missiles !
        if (owl.elapsedTime > (FADE_TIME + DIVE_TIME) + (owl.missilesDropped * INTERVAL)) and (owl.missilesDropped < MissilesNumber(owl.level)) then
            set missile = MissileData.create(owl.owl)
            set owl.missilesDropped = owl.missilesDropped + 1
        endif
        
        //if we already did everything we wanted, we kill everything ! xD
        if (owl.elapsedTime > owl.totalFlightDuration) then
            call owl.destroy()
        endif
        
        call SetUnitPosition(owl.owl, GetUnitX(owl.owl) + SPEED * Cos(bj_DEGTORAD*GetUnitFacing(owl.owl)), GetUnitY(owl.owl) + SPEED * Sin(bj_DEGTORAD*GetUnitFacing(owl.owl)))
    endfunction
	
	private function DeathActions takes nothing returns nothing
		local OwlData owl
        //we make sure that the unit that dies is the owl
        //recover that owl (the struct) from the owl
		set owl = activeTable[GetTriggerUnit()] 
		call owl.destroy()
	endfunction
	
	private function DeathConditions takes nothing returns boolean
        return IsUnitInGroup(GetTriggerUnit(), Missileers)
    endfunction
	
	private function Actions takes nothing returns nothing
        local location spellLoc
        local real angle 
        local OwlData owl
		local unit u = GetTriggerUnit()
        
		set spellLoc = GetSpellTargetLoc()
		set angle = bj_RADTODEG * Atan2(GetLocationY(spellLoc) - GetUnitY(u), GetLocationX(spellLoc) - GetUnitX(u))
		set owl = OwlData.create(u, GetLocationX(spellLoc), GetLocationY(spellLoc), angle)
		
		call SetTimerData(owl.mover, integer(owl))
		call TimerStart(owl.mover, MOVE_TIME, true, function MoveOwl)
		
		call RemoveLocation(spellLoc)
        
        set spellLoc = null 
		set u = null 
    endfunction

    private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function Init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function DeathConditions, function DeathActions)
        
        //SETTING OUR GLOBALS
        set activeTable = HandleTable.create() //Create our spell's private Table for the bombers
        set Missileers = CreateGroup() 
        
        //Preloading Effect
        call Preload(BOOM)
        //Preload Ability
        call XE_PreloadAbility(DUMMY_SPELL_ID)
    endfunction
endscope