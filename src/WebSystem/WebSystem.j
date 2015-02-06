scope WebSystem

    globals
        private constant integer MAX_WEB_TYPES = 3
        private constant integer MAX_WEB_AREAS = 3
        private constant integer WEB_SMALL = 'e008'
        private constant integer WEB_MEDIUM = 'e00A'
        private constant integer WEB_LARGE = 'e00B'
        private constant integer WEB_SPELL_SMALL = 'A0A9'
        private constant integer WEB_SPELL_MEDIUM = 'A0AA'
        private constant integer WEB_SPELL_LARGE = 'A0AC'
        private constant integer WEB_AURA_BUFF_ID = 'B02I'
        private constant real LIFE_TIME = 230.0
		private constant integer WEB_PER_RECT = 2
        private constant real MIN_TIME = 185.0
        private constant real MAX_TIME = 255.0
        
        private rect array WEB_SPAWN_RECTS
        private integer array WEB_TYPES
        private integer array WEB_SPELL_IDS
        private real array WEB_AURA_SIZE
        
        //TO-DO: Funktionalität bauen, wenn bestimmte Einheiten im Netz nicht verlangsamt werden sollen (z.b.Nerubian Widow)
        //Exception Units 
        //private constant integer SPIDER_ID = 'n00G'
        //private constant integer MALE_ID = 'n00I'
        //private constant integer FEMALE_ID = 'n00H'
    endglobals

    private function MainSetup takes nothing returns nothing
        set WEB_SPAWN_RECTS[0] = gg_rct_webSpawnRect0
        set WEB_SPAWN_RECTS[1] = gg_rct_webSpawnRect1
        set WEB_SPAWN_RECTS[2] = gg_rct_webSpawnRect2
        
        set WEB_TYPES[0] = WEB_SMALL
        set WEB_TYPES[1] = WEB_MEDIUM
        set WEB_TYPES[2] = WEB_LARGE
        
        set WEB_SPELL_IDS[0] = WEB_SPELL_SMALL
        set WEB_SPELL_IDS[1] = WEB_SPELL_MEDIUM
        set WEB_SPELL_IDS[2] = WEB_SPELL_LARGE
        
        set WEB_AURA_SIZE[0] = 100.0
        set WEB_AURA_SIZE[1] = 250.0
        set WEB_AURA_SIZE[2] = 350.0
    endfunction
    
    private function RectFromCenterSize takes real tx, real ty, real width, real height returns rect
        local real x = tx
        local real y = ty
        return Rect( x - width*0.5, y - height*0.5, x + width*0.5, y + height*0.5 )
    endfunction
    
    struct WebAreas
    
        static method getArea takes integer index returns rect
            return WEB_SPAWN_RECTS[index]
        endmethod
        
    endstruct
    
    struct Web
        unit web
        timer t
        trigger leaveWebAura
		
		method onDestroy takes nothing returns nothing
			call ReleaseTimer(.t)
			set .t = null
			set .web = null
            set .leaveWebAura = null
		endmethod
        
        static method create takes integer i returns thistype
            local thistype this = thistype.allocate()
			local real x = GetRandomReal(GetRectMinX(WEB_SPAWN_RECTS[i]), GetRectMaxX(WEB_SPAWN_RECTS[i]))
            local real y = GetRandomReal(GetRectMinY(WEB_SPAWN_RECTS[i]), GetRectMaxY(WEB_SPAWN_RECTS[i]))
            local integer rnd = 0
            local rect r
            
            loop
                exitwhen IsTerrainWalkable(x,y)
                set x = GetRandomReal(GetRectMinX(WEB_SPAWN_RECTS[i]), GetRectMaxX(WEB_SPAWN_RECTS[i]))
                set y = GetRandomReal(GetRectMinY(WEB_SPAWN_RECTS[i]), GetRectMaxY(WEB_SPAWN_RECTS[i]))
            endloop
            
            set rnd = GetRandomInt(0,2)
            set r = RectFromCenterSize(x, y, WEB_AURA_SIZE[rnd], WEB_AURA_SIZE[rnd])
            set .web = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), WEB_TYPES[rnd], x, y, bj_UNIT_FACING)
            set .leaveWebAura = CreateTrigger()
            
            call TriggerRegisterLeaveRectSimple(.leaveWebAura, r)
            call TriggerAddAction(.leaveWebAura, function thistype.onLeaveWeb )
            call UnitAddAbility( .web, WEB_SPELL_IDS[rnd] )
            call SetUnitAbilityLevel( .web, WEB_SPELL_IDS[rnd], 1 )
            call UnitApplyTimedLife( .web, 'BTLF', LIFE_TIME )
            
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, LIFE_TIME, false, function thistype.onEnd)
            call UnitAddAbility(.web, XE_HEIGHT_ENABLER)
            call UnitRemoveAbility(.web, XE_HEIGHT_ENABLER)
        
            return this
        endmethod
        
        static method onLeaveWeb takes nothing returns nothing
			local unit u = GetTriggerUnit()
            
            if GetUnitAbilityLevel(u, WEB_AURA_BUFF_ID) > 0 then
                call UnitRemoveAbility(u, WEB_AURA_BUFF_ID)
            endif
            set u = null
		endmethod
        
        static method onEnd takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			
			call KillUnit(this.web)
			call this.destroy()
		endmethod
    
    endstruct
    
    private function Actions takes nothing returns nothing
        local Web w = 0
        local integer i = 0
        local integer count = WEB_PER_RECT
        
        loop
            exitwhen i == MAX_WEB_AREAS
            loop
                exitwhen count < 0
                set w = Web.create(i)
                set count = count - 1
            endloop
            set count = WEB_PER_RECT
            set i = i + 1
        endloop
    endfunction
	
	struct WebSystem
	
		static method initialize takes nothing returns nothing
			local timer t = NewTimer()
			
			call MainSetup()
			call TimerStart(t, GetRandomReal(MIN_TIME, MAX_TIME), true, function Actions )
		endmethod
	
	endstruct

endscope