scope HeroRespawnSystem

    globals
        private constant integer SHORT_REVIVE = 'A077' // Dark Ranger's Ulti --> Falls damit gekillt, soll der Ally Hero nur 10s warten
        private constant real REVIVE_TIME_MAX = 90.0
        private constant real REVIVE_TIME_START = 10.0
        private constant real REVIVE_TIME_PER_LEVEL = 5.0
        private constant real PANCAM = 0.6
    endglobals
    
    private function GetAdjustedTime takes real time, unit hero returns real
        local real reviveTime =  time + 4. * GetHeroLevel(hero) // Dota Like ^^
		
		if (reviveTime > REVIVE_TIME_MAX) then
			return REVIVE_TIME_MAX
		else
			return reviveTime
		endif
    endfunction
    
    private function FilterHero takes unit u returns boolean
        return IsUnitType(u, UNIT_TYPE_HERO) //and IsUnitDead(u)
    endfunction
    
    private struct Data
        timer t
        real time
        leaderboard l
        unit hero
        real x
        real y
        boolean eff
		
		method onDestroy takes nothing returns nothing
			set .hero = null
		endmethod
        
        static method onPeriodic takes nothing returns nothing
            local Data dat = GetTimerData(GetExpiredTimer())
			local player p
            
			set dat.time = dat.time - 1.0
            
			if dat.time <= 0 then
				//Player
				set p = GetOwningPlayer(dat.hero)
				
				//Revive
				call ReviveHero(dat.hero, dat.x, dat.y, dat.eff)    
				
				 //Leben und Mana auf 100% setzen
				call SetUnitState(dat.hero, UNIT_STATE_LIFE, GetUnitState(dat.hero, UNIT_STATE_MAX_LIFE))
				call SetUnitState(dat.hero, UNIT_STATE_MANA, GetUnitState(dat.hero, UNIT_STATE_MAX_MANA))
				
				//Selection und Kamera
				if GetLocalPlayer() == p then
					call ClearSelection()
					call PanCameraToTimed(dat.x, dat.y, PANCAM)
					call SelectUnit(dat.hero, true)
				endif
				
				//Update Multiboard (Status)
				call FBFMultiboard.onUpdateStatus(GetPlayerId(p), dat.hero)
				
				call ReleaseTimer(dat.t)
                set dat.t = null
                call DestroyLeaderboard(dat.l)
				call dat.destroy()
            endif
            call LeaderboardSetLabel(dat.l, "Respawns in " + I2S(R2I(dat.time)) + " seconds!")
        endmethod
    endstruct 
    
    struct HeroRespawn
        
        static method reviveHero takes unit hero, real time, boolean eff returns nothing
            local Data dat
            local player p
            local real reviveTime = GetAdjustedTime(time, hero)
            
			if FilterHero(hero) then
                set dat = Data.create()
				set p = GetOwningPlayer(hero)
                set dat.hero = hero
                set dat.x = GetRectCenterX(GET_HERO_RACE_START_RECT(GetPlayerRace(p)))
                set dat.y = GetRectCenterY(GET_HERO_RACE_START_RECT(GetPlayerRace(p)))
                set dat.eff = eff
                
                if GetUnitAbilityLevel(hero, SHORT_REVIVE) > 0 then
                    set reviveTime = REVIVE_TIME_START
                endif
                
                set dat.l = CreateLeaderboard()
                call LeaderboardSetLabel( dat.l, "Respawns in " + I2S(R2I(reviveTime)) + " seconds!" )
                call PlayerSetLeaderboard( p, dat.l )
                call LeaderboardDisplay( dat.l, true )
                
				set dat.t = NewTimer()
                set dat.time = reviveTime
                call SetTimerData(dat.t, dat)
                call TimerStart(dat.t, 1.0, true, function Data.onPeriodic)
            endif
        endmethod
    
    endstruct
    
endscope