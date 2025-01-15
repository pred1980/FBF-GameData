//==========================================================================================
// Diabolic Countdown v1.00a by watermelon_1234
//******************************************************************************************
// Libraries required: (Libraries with * are optional)
//  - TimerUtils
//  - xe system (xebasic and xefx)
//  * BoundSentinel
//  * GroupUtils 
//##########################################################################################
// Importing:
//  1. Copy the ability, Diabolic Countdown.
//  2. Copy this trigger.
//  3. Implement the required libraries.
//  4. Configure the spell.
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Notes:
//  - If BoundSentinel is used, the ghost may not move correctly if it's near the map bounds. 
//==========================================================================================
scope DiabolicCountdown
    native UnitAlive takes unit id returns boolean // It's not neccessary, but you can remove this line if you already have UnitAlive implemented
    
    // Provided as an easier way to use another method that detects if a unit is alive.
    private function IsUnitAlive takes unit u returns boolean
        return UnitAlive(u) // GetWidgetLife(u) > 0.405
    endfunction
    
    globals       
        private constant integer SPELL_ID = 'A0AG' // Raw id of the Diabolic Countdown ability
        private constant integer TICK_NUMBER = 12 // The number of ticks in the clock. Recommended to keep this at 12.
        private constant integer DIRECTION = -1 // -1 for clockwise (default), 1 for counter-clockwise.
        private constant real KILL_DAMAGE = 9999. // The damage an enemy unit will receive if it has less than WeakPercent of its max life.
        private constant real TIMER_LOOP = 0.03 // Determines how often the timer will loop. If it's too high, the spell may not function correctly.
        private constant real START_ANGLE = 1.570796 // Starting angle where the ghost emerges from. In radians. Default is 1/2*PI
        private constant real GHOST_MOVE_SPEED = 500 // Determines the move speed when the ghost is emerging from/going back to the center
        private constant real GHOST_ROTATE_SPEED = 2.094395 // Determines how many radians the ghost will be rotated around the center per second. 
        // SFX settings
        private constant boolean DO_PRELOAD = true // Determines whether or not to preload the SFX
        private constant real SFX_HEIGHT = 65. // Determines the height for all of the sfx used by this spell.
        private constant string CENTER_SFX = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl" // Path for the center of the clock
        private constant string GHOST_SFX = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl" // Path for the ghost
        private constant string HAND_PATH = "FORK" // Path for the lightning which is used as the "hand" of the clock
        private constant string TICK_SFX = "Abilities\\Spells\\Undead\\Curse\\CurseTarget.mdl" // Path for the sfx that's used as a "tick" of the clock
        private constant integer TICK_ALPHA = 255 // Initial alpha the tick starts with
        private constant real TICK_DUR = 1.15 // How long it will take for the "tick" to fade away after the spell is finished.
        private constant real TICK_DELAY = 0.15 // This is a delay added to every tick after the first one before they fade away. Increaes with every other tick.
        private constant string CHIME_SFX = "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl" // Path for the chime sfx
        private constant string DMG_SFX = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl" // Path for the sfx played when a unit is damaged by this spell
        private constant string DMG_SFX_ATTACH = "origin" // Attachment point for the DMG_SFX
        // Damage settings
        private constant attacktype ATK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_UNIVERSAL
        private constant weapontype WPN_TYPE = null        
    endglobals
    
    // Determines which units get affected by the spell
    private function AffectedTargets takes unit targ, player owner returns boolean
        return IsUnitAlive(targ) and IsUnitEnemy(targ,owner) and not IsUnitType(targ,UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(targ,UNIT_TYPE_MECHANICAL)
    endfunction
    
    // The spell's target area
    private constant function Area takes integer lvl returns real
        return 350. + 50*lvl
    endfunction
    
    // Spell's damage
    private constant function Damage takes integer lvl returns real
        return 50. + 125*lvl
    endfunction
    
    // Determines the percent of max life when the unit will be killed regardless of spell damage
    private constant function WeakPercent takes integer lvl returns real
        return .3 + 0*lvl
    endfunction
    
    // Scaling for CHIME_SFX
    private constant function ChimeScale takes integer lvl returns real
        return 1.2 + .2*lvl
    endfunction    
    
//==========================================================================================
// END OF CONFIGURATION
//==========================================================================================

    globals       
        private constant real TWO_PI = 6.283185 // Determines a full rotation
        private constant location loc = Location(0,0) // Global location used for GetLocationZ
        private boolexpr e // Used for group enumeration
        private group g // Will be used if GroupUtils is not present
    endglobals
    
    // Destroys an xefx after making it completely transparent over TICK_DUR seconds. If there is a delay, runs a timer first that will run onLoop later.
    private struct timedxefx
        xefx sfx
        real count = 0        
        timer tim
        
        static method create takes xefx sfx, real delay returns thistype
            local thistype this = thistype.allocate()
            set .sfx = sfx
            set .tim = NewTimer()
            call SetTimerData(.tim,this)
            if delay > 0 then
                call TimerStart(.tim,delay,false,function thistype.delayed)
            else
                call TimerStart(.tim,TIMER_LOOP,true,function thistype.onLoop)
            endif
            return this
        endmethod
        
        static method delayed takes nothing returns nothing
            call TimerStart(GetExpiredTimer(),TIMER_LOOP,true,function thistype.onLoop)
        endmethod
        
        static method onLoop takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if .count + TIMER_LOOP < TICK_DUR then                
                set .sfx.alpha = .sfx.alpha - R2I(TICK_ALPHA*(TIMER_LOOP/TICK_DUR))
                set .count = .count + TIMER_LOOP
            else
                call .sfx.destroy()
                call ReleaseTimer(.tim)
                call .destroy()
            endif
        endmethod
    endstruct
    
    // The actual code of the spell
    struct Diabolic 
        unit cast // Unit who casted the spell
        real x // x-coordinate of spell target
        real y // y-coordinate of spell target    
        integer lvl // The level of the ability
        integer tickNumber = 0 // Counts how many "ticks" were created so far
        real area // Stores Area(.lvl) as it is used a lot    
        real angle = START_ANGLE // Angle used to determine how much to rotate the ghost by
        real count = 0 // Used for various counting, like distance/angles
        real totalCount = 0  // Used to count how much the ghost has rotated by
        real mx // The offset of x where the ghost will move to/from
        real my // The offset of y where the ghost will move to/from              
        lightning hand  // Used to store the lightning for the "hand"
        xefx center // The special effect at the center
        xefx ghost // The ghost sfx
        xefx array ticks[TICK_NUMBER] // Stores the ticks that were created              
        timer tim // Timer for this spell
        static thistype temp
             
        // Starts the spell.
        static method create takes unit c, real x, real y returns thistype
            local thistype this = thistype.allocate()            
            // Variable setting
            set .cast = c
            set .x = x
            set .y = y            
            set .lvl = GetUnitAbilityLevel(.cast,SPELL_ID)
            set .area = Area(.lvl)            
            set .mx = .x + .area*Cos(START_ANGLE)
            set .my = .y + .area*Sin(START_ANGLE)            
            // Special effect creation
            set .center = xefx.create(.x,.y,0)
            set .center.fxpath = CENTER_SFX
            set .center.z = SFX_HEIGHT
            set .ghost = xefx.create(.x,.y,START_ANGLE)
            set .ghost.fxpath = GHOST_SFX
            set .ghost.z = SFX_HEIGHT            
            call MoveLocation(loc,.x,.y)
            set .hand = AddLightningEx(HAND_PATH,true,.x,.y,SFX_HEIGHT+GetLocationZ(loc),.x,.y,SFX_HEIGHT+GetLocationZ(loc))
            
            // Timer Stuff:
            set .tim = NewTimer()
            call SetTimerData(.tim,this)
            call TimerStart(.tim,TIMER_LOOP,true,function thistype.ghostEmerge)            
            return this
        endmethod
        
        // Cleanup the spell when done.
        method onDestroy takes nothing returns nothing
            local integer i = 0   
            loop
                call timedxefx.create(.ticks[i],TICK_DELAY*i)
                set i = i + 1
                exitwhen i >= .tickNumber
            endloop
            call ShowUnit(.cast, true)
            call SetUnitInvulnerable(.cast, false)
            call .center.destroy()
            call .ghost.destroy()
            call DestroyLightning(.hand)
            call ReleaseTimer(.tim)
        endmethod
        
        // Actions done to the units enumerated.
        static method groupActions takes nothing returns boolean
            local unit u = GetFilterUnit()
            if AffectedTargets(u,GetOwningPlayer(temp.cast)) then 
                call DestroyEffect(AddSpecialEffectTarget(DMG_SFX,u,DMG_SFX_ATTACH))
                set DamageType = SPELL
                if GetWidgetLife(u)/GetUnitState(u,UNIT_STATE_MAX_LIFE) <= WeakPercent(temp.lvl) then
                    call UnitDamageTarget(temp.cast,u,KILL_DAMAGE,false,true,ATK_TYPE,DMG_TYPE,WPN_TYPE)
                else
                    call UnitDamageTarget(temp.cast,u,Damage(temp.lvl),false,true,ATK_TYPE,DMG_TYPE,WPN_TYPE)
                endif                
            endif
            set u = null
            return false
        endmethod
        
        // Made as a method since updating the hand is used all the time.
        method updateHand takes nothing returns nothing
            local real h1
            local real h2            
            call MoveLocation(loc,.x,.y)
            set h1 = GetLocationZ(loc)            
            call MoveLocation(loc,.ghost.x,.ghost.y)
            set h2 = GetLocationZ(loc)            
            call MoveLightningEx(.hand,true,.x,.y,SFX_HEIGHT+h1,.ghost.x,.ghost.y,SFX_HEIGHT+h2)
        endmethod
        
        // Deals with the ghost coming out of the center
        static method ghostEmerge takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            if .count + GHOST_MOVE_SPEED*TIMER_LOOP < .area then 
                set .ghost.x = .ghost.x + GHOST_MOVE_SPEED*TIMER_LOOP*Cos(START_ANGLE)
                set .ghost.y = .ghost.y + GHOST_MOVE_SPEED*TIMER_LOOP*Sin(START_ANGLE) 
                
                set .count = .count + GHOST_MOVE_SPEED*TIMER_LOOP
            else
                set .ghost.x = .mx
                set .ghost.y = .my                
                
                set .count = 0                
                call TimerStart(.tim,TIMER_LOOP,true,function thistype.ghostRotate)
            endif
            call .updateHand()
        endmethod
        
        // Deals with rotating the ghost around the center
        static method ghostRotate takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real gx = .ghost.x
            local real gy = .ghost.y
            if .totalCount + GHOST_ROTATE_SPEED*TIMER_LOOP < TWO_PI then
                set .angle = .angle + DIRECTION*GHOST_ROTATE_SPEED*TIMER_LOOP                
                set .ghost.x = .x + .area*Cos(.angle)
                set .ghost.y = .y + .area*Sin(.angle)                  
                set .ghost.xyangle = Atan2(.ghost.y-gy,.ghost.x-gx)
                
                set .totalCount = .totalCount + GHOST_ROTATE_SPEED*TIMER_LOOP
                set .count = .count + GHOST_ROTATE_SPEED*TIMER_LOOP                
                if .count >= TWO_PI/TICK_NUMBER then // TWO_PI/TICK_NUMBER is basically the angle between each tick.
                    set .ticks[.tickNumber] = xefx.create(.x+.area*Cos(START_ANGLE+DIRECTION*TWO_PI/TICK_NUMBER*(.tickNumber+1)),.y+.area*Sin(START_ANGLE+DIRECTION*TWO_PI/TICK_NUMBER*(.tickNumber+1)),0)
                    set .ticks[.tickNumber].fxpath = TICK_SFX
                    set .ticks[.tickNumber].alpha = TICK_ALPHA
                    set .ticks[.tickNumber].z = SFX_HEIGHT
                    set .tickNumber = .tickNumber + 1
                    set .count = 0
                endif                
            else
                set .ghost.x = .mx
                set .ghost.y = .my
                set .ghost.xyangle = Atan2(.y-.my,.x-.mx)
                
                // Create the last tick
                set .ticks[.tickNumber] = xefx.create(.mx,.my,0)
                set .ticks[.tickNumber].fxpath = TICK_SFX
                set .ticks[.tickNumber].alpha = TICK_ALPHA
                set .ticks[.tickNumber].z = SFX_HEIGHT
                set .tickNumber = .tickNumber + 1  
                
                set .count = 0 
                call TimerStart(.tim,TIMER_LOOP,true,function thistype.ghostExit)   
            endif            
            call .updateHand()
        endmethod
        
        // Deals with the ghost going back to the center
        static method ghostExit takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local xefx chime
            if .count + GHOST_MOVE_SPEED*TIMER_LOOP < .area then  
                set .ghost.x = .ghost.x - GHOST_MOVE_SPEED*TIMER_LOOP*Cos(START_ANGLE)
                set .ghost.y = .ghost.y - GHOST_MOVE_SPEED*TIMER_LOOP*Sin(START_ANGLE)                
                call .updateHand()                
                
                set .count = .count + GHOST_MOVE_SPEED*TIMER_LOOP
            else
                set .ghost.x = .x
                set .ghost.y = .y
                
                // Play the CHIME_SFX
                set chime = xefx.create(.x,.y,0)                
                set chime.fxpath = CHIME_SFX
                set chime.scale = ChimeScale(.lvl)
                set chime.z = SFX_HEIGHT
                call chime.destroy()
                
                set temp = this
                static if LIBRARY_GroupUtils then
                    call GroupEnumUnitsInArea(ENUM_GROUP,.x,.y,.area,e)
                else
                    call GroupEnumUnitsInRange(g,.x,.y,.area,e)
                endif
                
                call .destroy()                
            endif            
        endmethod
        
        static method spellActions takes nothing returns boolean
            if GetSpellAbilityId() == SPELL_ID then
                call thistype.create(GetTriggerUnit(),GetSpellTargetX(),GetSpellTargetY())
            endif
            return false
        endmethod
        
        static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(t,Condition(function thistype.spellActions))
            set e = Filter(function thistype.groupActions)
            
            static if not LIBRARY_GroupUtils then
                set g = CreateGroup()
            endif
            
            static if DO_PRELOAD then
                call Preload(CENTER_SFX)
                call Preload(GHOST_SFX)
                call Preload(TICK_SFX)
                call Preload(CHIME_SFX)
                call Preload(DMG_SFX)
                call PreloadStart()
            endif
        endmethod
    endstruct
endscope