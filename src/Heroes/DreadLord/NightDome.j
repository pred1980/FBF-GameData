scope NightDome initializer init
    /*
     * Description: Snake Tongue Tristan increases the mana regeneration of friendly units by creating a great Dome around them. 
                    It absorbs mana everytime a unit inside it casts a spell, increasing its own output.
     * Last Update: 18.11.2013
     * Changelog: 
     *     18.11.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A06Z'
        private constant integer AURA_ID = 'A070'
        private constant integer AURA_MAXLVL = 10
        private integer array AURA_START
        private constant real MANA_DRAIN = 100
        private constant real RADIUS = 600
        private real array DURATION
        private constant string DRAIN_EFFECT = "Abilities\\Spells\\NightElf\\MoonWell\\MoonWellCasterArt.mdl"
        private constant real LVL_DUR = 7.0 //Time in seconds the dome output is increased after a cast
        private hashtable unitSpellData = InitHashtable()
        
        private constant integer EFFECT_ID = 'u007'
        private constant real BUILDUP = 1.0
        private constant real DEATH = 0.3
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set AURA_START[0] = 1
        set AURA_START[1] = 2
        set AURA_START[2] = 3
        
        set DURATION[0] = 30
        set DURATION[1] = 30
        set DURATION[2] = 30
    endfunction

    private struct NightDome
        unit dome
        real x
        real y
        trigger castTrigger
        integer charges = 0
        integer level = 0
        timer array chargetimers[AURA_MAXLVL]
        timer aniTimer
        timer durTimer
        
        static method create takes unit c, real tx, real ty returns thistype
            local thistype this = thistype.allocate()
            local integer level = GetUnitAbilityLevel(c,SPELL_ID)-1            
            
            set .dome = CreateUnit(GetOwningPlayer(c),EFFECT_ID,tx,ty,270)
            set .x = tx
            set .y = ty
            set .level = AURA_START[level]
            call SetUnitAbilityLevel(.dome, AURA_ID, .level)
            set .charges = 0
            
            set .aniTimer = NewTimer()
            call SetTimerData(.aniTimer, this)
            call TimerStart(.aniTimer, BUILDUP, false, function thistype.AniStop)
            
            set .durTimer = NewTimer()
            call SetTimerData(.durTimer, this)
            call TimerStart(.durTimer, DURATION[level]-DEATH, false, function thistype.TimeOut)
            
            set .castTrigger = CreateTrigger()
            call TriggerRegisterAnyUnitEventBJ( .castTrigger, EVENT_PLAYER_UNIT_SPELL_EFFECT )
            call TriggerAddCondition(.castTrigger, Condition(function thistype.DomeUp))
            call SaveIntegerBJ(this, 6, GetHandleId(.castTrigger), unitSpellData)
            
            return this
        endmethod
        
        static method TimeOut takes nothing returns nothing
            local thistype this= GetTimerData(GetExpiredTimer())
            
            call SetUnitTimeScale(this.dome,1.0)
            call UnitApplyTimedLife(this.dome,'BTLF',DEATH)
            call this.destroy()
        endmethod
        
        static method AniStop takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call SetUnitTimeScale(this.dome,0.0)
        endmethod
        
        static method DomeDown takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local integer t = 0
            
            loop //Find the correct Timer to release
                exitwhen t == this.charges or this.chargetimers[t] == GetExpiredTimer()
                set t = t + 1
            endloop
            
            call ReleaseTimer(GetExpiredTimer())
            
            loop //Put timer array back together
                exitwhen t == this.charges
                set this.chargetimers[t] = this.chargetimers[t + 1]
                set t = t + 1
            endloop
            
            set this.charges = this.charges - 1 
            set this.level = this.level - 1
            call SetUnitAbilityLevel(this.dome, AURA_ID, this.level)
        endmethod
        
        static method DomeUp takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local real x = GetUnitX(u)
            local real y = GetUnitY(u)
            local thistype this = LoadIntegerBJ(6,GetHandleId(GetTriggeringTrigger()), unitSpellData)
            
            if (x-this.x)*(x-this.x)+(y-this.y)*(y-this.y) <= RADIUS*RADIUS then //Inside the dome
                call DestroyEffect(AddSpecialEffectTarget(DRAIN_EFFECT,u,"origin"))
                if this.level < AURA_MAXLVL then
                    set this.level = this.level + 1
                    call SetUnitAbilityLevel(this.dome,AURA_ID,this.level)
                    set this.chargetimers[this.charges]=NewTimer()
                    call SetTimerData(this.chargetimers[this.charges],this)
                    call TimerStart(this.chargetimers[this.charges],LVL_DUR,false,function thistype.DomeDown)
                    set this.charges = this.charges + 1
                endif
            endif
            set u = null
            return false
        endmethod
        
        method onDestroy takes nothing returns nothing
            loop
                set .charges = .charges - 1
                call ReleaseTimer(.chargetimers[.charges])
                exitwhen .charges == 0
            endloop
            call ReleaseTimer(.aniTimer)
            set .aniTimer = null
            call ReleaseTimer(.durTimer)
            set .durTimer = null
            call DisableTrigger(.castTrigger)
            call TriggerClearConditions(.castTrigger)
            call DestroyTrigger(.castTrigger)
            set .dome = null
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local NightDome nd = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set nd = NightDome.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call MainSetup()
        call XE_PreloadAbility(AURA_ID)
        call Preload(DRAIN_EFFECT)
    endfunction

endscope