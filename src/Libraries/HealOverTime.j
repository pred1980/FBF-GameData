library HealOverTime initializer Init

    globals
        // This is how many times the struct loop will run in a single second. 30-40 is recomended
        private constant integer FPS = 40 
        // DO NOT TUCH! =)
        private constant real Interval = (1.0 / FPS)
    endglobals
    
    struct HOT
        unit Target
        real Health
        integer EndCount
        effect Effect
        static integer array Index
        static integer Total = 0
        static timer Tim = null
        static integer Count = -2147483648 // Just a random low number, it is needed
        
        static method Loop takes nothing returns nothing
            local HOT dat
            local integer i = 0

            set HOT.Count = HOT.Count + 1
            
            loop
                exitwhen i >= HOT.Total
                set dat = HOT.Index[i]

                if HOT.Count > dat.EndCount or GetUnitStatePercent(dat.Target, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE) == 100 then
                    call DestroyEffect(dat.Effect)

                    set dat.Effect     = null
                    set dat.Target     = null
                
                    call dat.destroy()
                    
                    set HOT.Total = HOT.Total - 1
                    set HOT.Index[i] = HOT.Index[HOT.Total]

                    set i = i - 1
                else
                    call SetUnitState( dat.Target, UNIT_STATE_LIFE, RMaxBJ(0,GetUnitState(dat.Target, UNIT_STATE_LIFE) + dat.Health) )
                endif
                
                set i = i + 1
            endloop
            
            if HOT.Total == 0 then
                call PauseTimer(HOT.Tim)
            endif
        endmethod
        
        static method start takes unit Target, real Health, real Time, string Effect, string EffectAttach returns HOT
            local HOT dat = HOT.allocate()
            
            set dat.Target     = Target
            
            if Effect != "" and Effect != null then
                if EffectAttach != "" and EffectAttach != null then
                    set dat.Effect = AddSpecialEffectTarget(Effect, Target, EffectAttach)
                endif
            endif
            
            set dat.Health   = Health * Interval / Time
            set dat.EndCount = HOT.Count + R2I(Time / Interval)
            
            if HOT.Total == 0 then
                call TimerStart(HOT.Tim, Interval, true, function HOT.Loop)
            endif
            
            set HOT.Index[HOT.Total] = dat
            set HOT.Total = HOT.Total + 1
            
            return dat
        endmethod
    endstruct
    
//=========================================================================================*/

    private function Init takes nothing returns nothing
        set HOT.Tim = CreateTimer()
    endfunction

endlibrary