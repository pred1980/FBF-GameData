scope WardenSystem initializer init

    globals
        private constant integer WARDEN_ID = 'u02A'
        //Warden Area's
        private constant rect array WARDEN_AREA
        //Amount of Wardens per Area
        private constant integer MAX_WARDEN = 1
        //Interval before a new warden spawns
        private constant real INTERVAL = 2.5
        //Life Time
        private real LIFE_TIME = 20.0
        //Fade duration
        private constant real ARGB_DURATION = 2.5
        private constant string ORDER_ATTACKMOVE = "attack"
        
        private constant integer INCREASED_WARDEN_HP_PER_ROUND = 250
        private constant integer INCREASED_WARDEN_DAMAGE_PER_ROUND = 35
        private constant integer WARDEN_START_HP = 750
        private constant integer WARDEN_START_DAMAGE = 115
        //Dieser Faktoren beschreiben die Erh?hung der HP/Damage Werte je nach Spieleranzahl, im akt. Fall 5%
        private constant real HP_FACTOR = 0.10 //0.05
        private constant real DAMAGE_FACTOR = 0.12 //0.09
    endglobals

    private function getRandomX takes integer index returns real
		return GetRandomReal(GetRectMinX(WARDEN_AREA[index]), GetRectMaxX(WARDEN_AREA[index]))
	endfunction
	
	private function getRandomY takes integer index returns real
		return GetRandomReal(GetRectMinY(WARDEN_AREA[index]), GetRectMaxY(WARDEN_AREA[index]))
	endfunction
    
    struct Warden
        timer t
        timer move
        unit warden
        integer index = 0
        static integer hp = 0
        static integer dmg = 0
        static integer incHp = 0
        static integer incDmg = 0
        
        static method create takes integer index returns thistype
            local thistype this = thistype.allocate()
            local real x = getRandomX(index)
            local real y = getRandomY(index)
            local integer sum = Game.getCoalitionPlayers()
            
            set .index = index
            
            loop
                exitwhen IsTerrainWalkable(x,y)
                set x = getRandomX(.index)
                set y = getRandomY(.index)
            endloop
            
            set .hp = GetDynamicRatioValue(WARDEN_START_HP, HP_FACTOR)
            set .dmg = GetDynamicRatioValue(WARDEN_START_DAMAGE, DAMAGE_FACTOR)
            set .incHp = GetDynamicRatioValue(INCREASED_WARDEN_HP_PER_ROUND, HP_FACTOR)
            set .incDmg = GetDynamicRatioValue(INCREASED_WARDEN_DAMAGE_PER_ROUND, DAMAGE_FACTOR)
             
            set .warden = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), WARDEN_ID, x, y, GetRandomInt(0,359))
			call UnitApplyTimedLife(.warden, 'BTLF', LIFE_TIME + ARGB_DURATION )
            call SetUnitMaxState(.warden, UNIT_STATE_MAX_LIFE, .hp + ( RoundSystem.actualRound * .incHp))
            call SetUnitState(.warden, UNIT_STATE_LIFE, GetUnitState(.warden, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
            call TDS.addDamage(.warden, .dmg + (RoundSystem.actualRound * .incDmg))
            call FadeUnitStart(.warden, 0x00000000, 0xFFFFFFFF, ARGB_DURATION)
            
			set .t = NewTimer()
            call SetTimerData( .t, this )
            call TimerStart( .t, LIFE_TIME, false, function thistype.onFadeOut )
            
            set .move = NewTimer()
            call SetTimerData( .move, this )
            call TimerStart( .move, 1.0, true, function thistype.onMove )
            
            return this
        endmethod
        
        static method onMove takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local unit u = this.warden
            local real x = getRandomX(.index)
            local real y = getRandomY(.index)
            local string order = OrderId2String(GetUnitCurrentOrder(u))
            
            //Move to annother point if the Warden has nothing to do
            if not IsUnitDead(u) then
                if order == null then
                    loop
                        exitwhen IsTerrainWalkable(x,y)
                        set x = getRandomX(.index)
                        set y = getRandomY(.index)
                    endloop
                    
                    call IssuePointOrder(u, ORDER_ATTACKMOVE, x, y)
                endif
            else
                call this.destroy()
            endif
        endmethod
        
        static method onEnd takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call this.destroy()
        endmethod
		
		static method onFadeOut takes nothing returns nothing
            local thistype this = GetTimerData( GetExpiredTimer() )
			
			call TimerStart(this.t, ARGB_DURATION, false, function thistype.onEnd)
            call FadeUnitStart(this.warden, 0xFFFFFFFF, 0x00000000, ARGB_DURATION)
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .warden = null
            call ReleaseTimer(.t)
            call ReleaseTimer(.move)
            set .t = null
            set .move = null
        endmethod
    
    endstruct
    
    struct SpawnWarden
    
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            local Warden w = 0
            local integer i = 0
            local integer k = 0
            
            loop
                exitwhen i > 3
                loop
                    exitwhen k >= MAX_WARDEN
                    set w = Warden.create(i)
                    set k = k + 1 
                endloop
                set k = 0
                set i = i + 1
            endloop
            
            call destroy()
            
            return this
        endmethod
    
    endstruct
    
    private function init takes nothing returns nothing
        set WARDEN_AREA[0] = gg_rct_WardArea0
        set WARDEN_AREA[1] = gg_rct_WardArea1
        set WARDEN_AREA[2] = gg_rct_WardArea2
        set WARDEN_AREA[3] = gg_rct_WardArea3
        
        //Die Lebenszeit eines Warden ist die Pausenzeit zw. den einzelnen TD Runden
        set LIFE_TIME = RoundType.getPause()
    endfunction

endscope