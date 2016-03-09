scope HeroRespawnSystem
	/*
     * Changelog: 
     *     	01.10.2015: Increased the revivetime factor from 4 to 5 x Hero-Level
	 *		12.10.2015: Removed SHORT_REVIVE from hero after revive
     */
    globals
		// Dark Ranger's Ulti --> Falls damit gekillt, soll der Ally Hero nur 10s warten
        private constant integer SHORT_REVIVE = 'A077' 
        private constant real REVIVE_TIME_MAX = 90.0
        private constant real REVIVE_TIME_START = 10.0
        private constant real REVIVE_TIME_PER_LEVEL = 5.0
        private constant real PANCAM = 0.6
    endglobals
    
    private function GetAdjustedTime takes unit hero returns real
        local real reviveTime =  I2R(5 * GetHeroLevel(hero))
		
		if (reviveTime > REVIVE_TIME_MAX) then
			return REVIVE_TIME_MAX
		else
			return reviveTime
		endif
    endfunction
    
    private function FilterHero takes unit u returns boolean
        return IsUnitType(u, UNIT_TYPE_HERO)
    endfunction
    
    struct HeroRespawn
		private timer t
        private real time
        private leaderboard l
        private unit hero
        private real x
        private real y
		private player p
        private boolean eff
		
		method onDestroy takes nothing returns nothing
			call DestroyLeaderboard(.l)
			call PauseTimer(.t)
			call DestroyTimer(.t)
			set t = null
            set .hero = null
		endmethod
		
        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
			
			set this.time = this.time - 1.0
            
			if this.time <= 0 then
				//Player
				set this.p = GetOwningPlayer(this.hero)
				
				//Revive
				call ReviveHero(this.hero, this.x, this.y, this.eff)    
				
				 //Leben und Mana auf 100% setzen
				call SetUnitState(this.hero, UNIT_STATE_LIFE, GetUnitState(this.hero, UNIT_STATE_MAX_LIFE))
				call SetUnitState(this.hero, UNIT_STATE_MANA, GetUnitState(this.hero, UNIT_STATE_MAX_MANA))
				
				//Selection und Kamera
				if GetLocalPlayer() == this.p then
					call ClearSelection()
					call PanCameraToTimed(this.x, this.y, PANCAM)
					call SelectUnit(this.hero, true)
				endif
				
				// Need, if hero is killed while teleporting back to base
				if (Game.isBot[GetPlayerId(this.p)]) then
					call SpellHelper.pauseUnit(this.hero)
					call SpellHelper.unpauseUnit(this.hero)
				endif
				
				//Update Multiboard (Status)
				call FBFMultiboard.onUpdateStatus(GetPlayerId(this.p), this.hero)
				
				call this.destroy()
			else
				call LeaderboardSetLabel(this.l, "Respawns in " + I2S(R2I(this.time)) + " seconds!")
            endif
        endmethod
		
		static method create takes unit hero, boolean doEyecandy returns thistype
			local thistype this = thistype.allocate()
			local real reviveTime = GetAdjustedTime(hero)
			
			set .p = GetOwningPlayer(hero)
			set .hero = hero
			set .x = GetRectCenterX(GET_HERO_RACE_START_RECT(GetPlayerRace(.p)))
			set .y = GetRectCenterY(GET_HERO_RACE_START_RECT(GetPlayerRace(.p)))
			set .eff = doEyecandy
			
			if GetUnitAbilityLevel(.hero, SHORT_REVIVE) > 0 then
				set reviveTime = REVIVE_TIME_START
				call UnitRemoveAbility(.hero, SHORT_REVIVE)
			endif
			
			set .l = CreateLeaderboard()
			call LeaderboardSetLabel(.l, "Respawns in " + I2S(R2I(reviveTime)) + " seconds!" )
			call PlayerSetLeaderboard(.p, .l )
			call LeaderboardDisplay(.l, true )
			
			set .t = CreateTimer()
			set .time = reviveTime
			call SetTimerData(.t, this)
			call TimerStart(.t, 1.0, true, function thistype.onPeriodic)
			
			return this
		endmethod
    
    endstruct
    
endscope