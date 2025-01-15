scope KingMithasMode

    globals
		private constant integer HEART_ID = 'H014'
		private constant integer SPELL_ID = 'A0AH'
        private constant real X = 8640.0
        private constant real Y = 4672.0
        private constant integer HEART_LEVEL = 30
        private constant integer HEART_HP = 25000
		private constant integer HEART_DMG = 325
        //Diese Faktoren beschreibt die Erhoehung der HP/Damage Werte je nach Spieleranzahl, im akt. Fall 10%
        private constant real HP_FACTOR = 0.08
		private constant real DAMAGE_FACTOR = 0.03 //Prozentwert
    endglobals
        
    struct KingMod extends IFinalMode
		
		implement MFinalMode
		
		method getHeart takes nothing returns unit
			return thistype.heart
		endmethod
		
		//update HP+Damage if a player left game
        static method onUpdate takes nothing returns nothing
			local integer hp = 0
			local integer dmg = 0
			
            if not SpellHelper.isUnitDead(thistype.heart) then
                //get new hp+dmg
				set hp = GetGameStartRatioValue(HEART_HP, HP_FACTOR)
                set dmg = GetGameStartRatioValue(HEART_DMG, DAMAGE_FACTOR)
                call SetUnitMaxState(thistype.heart, UNIT_STATE_MAX_LIFE, hp)
                call TDS.resetDamage(thistype.heart)
				call TDS.addDamage(thistype.heart, dmg)
            endif
        endmethod
        
        static method onKingMithasCoreStart takes nothing returns nothing
            call ReleaseTimer(GetExpiredTimer())
            call KingMithasCore.start()
        endmethod
		
		static method create takes nothing returns thistype
			local thistype this = thistype.allocate()
            local integer hp = GetGameStartRatioValue(HEART_HP, HP_FACTOR)
			local integer dmg = GetGameStartRatioValue(HEART_DMG, DAMAGE_FACTOR)
            local timer t = NewTimer()
            
			set thistype.heart = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), HEART_ID, X, Y, GetRandomReal(0., 359.))
			call SetUnitMaxState(thistype.heart, UNIT_STATE_MAX_LIFE, hp)
            call SetUnitState(thistype.heart, UNIT_STATE_LIFE, GetUnitState(thistype.heart, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
            call TDS.addDamage(thistype.heart, dmg)
			call SetHeroLevel(thistype.heart, HEART_LEVEL, false)
			//call SelectHeroSkill(thistype.heart, SPELL_ID) //Aura vorerst deakt. da sie zu Rucklern fuehrt
            
            call TimerStart(t, 1.0, false, function thistype.onKingMithasCoreStart)
            
			return this
        endmethod
    
    endstruct
    
    globals
        private constant real HEALTH_CHECK_INTERVAL = 1.0
        private constant real KING_LIFE_TIME = 120.0
        private constant boolean KING_HAS_LIFE_TIME = false
        private constant integer DIABOLIC_SPELL_ID = 'A0AG'
        private constant string EFFECT_1 = "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl"
        private constant real TEXT_DURATION = 10.0
        private constant integer RADIUS = 1000
        private string SOUND_1 = "Sound\\Ambient\\DoodadEffects\\LichKingDream.wav"
        private string SOUND_2 = "KingMarcoMithas01.mp3"
        
        private boolean showCinematic = true
        
        //KING MARCO MITHAS
        private constant real FACE = 220.0
        private real array heartLifeFactors
        private integer array kingId
        private integer array kingLevel
		private integer array kingHP
		private integer array kingDMG
        private string introMessage
        private string array messages
        
    endglobals
    
    struct KingMithasCore
        static unit king
        static unit fakeKing
		static unit heart
        static integer hp = 0
        static integer dmg = 0
        static real face
        static real camX = 0.00
        static real camY = 0.00
        static integer index = 0
        static integer level = 1
        static timer kingTimer
        static timer heartTimer
        static group targets
		
		//update HP+Damage if a player left game
        static method onUpdate takes nothing returns nothing
            if not SpellHelper.isUnitDead(.king) then
                //get new hp+dmg
				set .hp = GetDynamicRatioValue(kingHP[.index], HP_FACTOR)
                set .dmg = GetDynamicRatioValue(kingDMG[.index], DAMAGE_FACTOR)
                call SetUnitMaxState(.king, UNIT_STATE_MAX_LIFE, .hp)
                call TDS.resetDamage(.king)
				call TDS.addDamage(.king, .dmg)
            endif
        endmethod
		
        static method groupFilterCallback takes nothing returns boolean
            return not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL)
        endmethod
        
        static method onCinematicStart takes nothing returns nothing
			local real x = GetRectCenterX(gg_rct_SpawnKingMithas)
            local real y = GetRectCenterY(gg_rct_SpawnKingMithas)
			
            if GetUnitLifePercent(.heart) <= heartLifeFactors[.index] then
				//Bestimme eine gueltige x/y position fuer King Mithas ( Cinematic )
				loop
					exitwhen IsTerrainWalkable(x,y)
					set x = GetRectCenterX(gg_rct_SpawnKingMithas)
					set y = GetRectCenterY(gg_rct_SpawnKingMithas)
				endloop
				
                call ReleaseTimer(GetExpiredTimer())
                //Show Cinematic
                if showCinematic then
                    set showCinematic = false
                    set .fakeKing = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), kingId[2], x, y, FACE)
                    set .camX = GetCameraTargetPositionX()
                    set .camY = GetCameraTargetPositionY()
                    call ShowUnit(.fakeKing, false)
                    call PauseUnit(.fakeKing, true)
                    call GroupEnumUnitsInRange( .targets, GetUnitX(.fakeKing), GetUnitY(.fakeKing), RADIUS, function thistype.groupFilterCallback )
                    call ForGroup( .targets, function thistype.onChangeFacing )
					//starte Cinematic
                    call KingCinematic.start()
                else
                    set .heartTimer = NewTimer()
                    call TimerStart(.heartTimer, HEALTH_CHECK_INTERVAL, true, function thistype.onHeartHealthCheck)
                endif
                //Make the Forsaken Heart invulnerable
                call SetUnitInvulnerable(.heart, true)
            endif
        endmethod
        
        static method onChangeFacing takes nothing returns nothing
            local unit u = GetEnumUnit()
            local real angle = AngleBetweenCords(GetUnitX(u), GetUnitY(u), GetUnitX(.fakeKing), GetUnitY(.fakeKing))  
            
            call SetUnitFacing(u, angle)
            if ( CountUnitsInGroup(.targets) == 0 ) then
                call ReleaseGroup( .targets )
                set .targets = null
            endif
            set u = null
        endmethod
        
        static method onHeartHealthCheck takes nothing returns nothing
			//Forsaken Heart Health < 25% ???
			if .index == 3 then
				call ReleaseTimer(GetExpiredTimer())
				return
			endif
			
            if GetUnitLifePercent(.heart) <= heartLifeFactors[.index] then
				call ReleaseTimer(.heartTimer)
				set .heartTimer = null
				call onCreateKingMithas()
			endif
        endmethod
		
		//Check if the King is dead
        static method onKingHealthCheck takes nothing returns nothing
            if IsUnitDead(.king) then
                call ReleaseTimer(.kingTimer)
                set .kingTimer = null
                call SetUnitInvulnerable(.heart, false)
				set .heartTimer = NewTimer()
                call TimerStart(.heartTimer, HEALTH_CHECK_INTERVAL, true, function thistype.onHeartHealthCheck)
            endif
        endmethod
		
		static method onCreateKingMithas takes nothing returns nothing
			local real x = GetRectCenterX(gg_rct_SpawnKingMithas)
            local real y = GetRectCenterY(gg_rct_SpawnKingMithas)
			
			loop
				exitwhen IsTerrainWalkable(x,y)
				set x = GetRectCenterX(gg_rct_SpawnKingMithas)
				set y = GetRectCenterY(gg_rct_SpawnKingMithas)
			endloop

			//Create the King, save the current hp, setup the life time and size
			set .king = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), kingId[.index], x, y, FACE)
			set .hp = GetGameStartRatioValue(kingHP[.index], HP_FACTOR)
			set .dmg = GetGameStartRatioValue(kingDMG[.index], DAMAGE_FACTOR)
			call SetHeroLevelBJ(.king, kingLevel[.index], false)
			call SetUnitMaxState(.king, UNIT_STATE_MAX_LIFE, .hp)
            call SetUnitState(.king, UNIT_STATE_LIFE, GetUnitState(.king, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
            call TDS.addDamage(.king, .dmg)
			
			call SetUnitInvulnerable(.king, true)
		
			call ClearTextMessages()
			call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.00, 0.00, TEXT_DURATION, "|cffff0000" + GetUnitName(.king) + ": |r" + messages[GetRandomInt(0,10)])
			call SelectHeroSkill(.king, DIABOLIC_SPELL_ID)
			call SetUnitAbilityLevel(.king, DIABOLIC_SPELL_ID, .level)
			call IssuePointOrder(.king, "silence", GetUnitX(.king), GetUnitY(.king))
			
			static if KING_HAS_LIFE_TIME then
				call UnitApplyTimedLife(.king, 'BTLF', KING_LIFE_TIME)
			endif
			
			//Check if the King dies
			set .kingTimer = NewTimer()
			call TimerStart(.kingTimer, HEALTH_CHECK_INTERVAL, true, function thistype.onKingHealthCheck)
			
			//Make the Forsaken Heart invulnerable
			call SetUnitInvulnerable(.heart, true)
			
			set .index = .index + 1
			set .level = .level + 1
		endmethod
        
        static method start takes nothing returns nothing
			set .heart = FinalMode.getHeart()
            set .targets = NewGroup()
            set .heartTimer = NewTimer()
            call TimerStart(.heartTimer, HEALTH_CHECK_INTERVAL, true, function thistype.onCinematicStart)
		endmethod
        
        static method onInit takes nothing returns nothing
            set heartLifeFactors[0] = 75.
            set heartLifeFactors[1] = 50.
            set heartLifeFactors[2] = 25.
            
            set kingId[0] = 'U02C'
            set kingId[1] = 'U02D'
            set kingId[2] = 'U02E'
       
            set kingLevel[0] = 10
            set kingLevel[1] = 20
            set kingLevel[2] = 30
			
			set kingHP[0] = 10000
			set kingHP[1] = 20000
			set kingHP[2] = 30000
			
			set kingDMG[0] = 250
			set kingDMG[1] = 300
			set kingDMG[2] = 350
            
            set introMessage = "Make haste! My enemies draw near! Our time is almost spent!"
            set messages[0] = "Long live the King!"
            set messages[1] = "Remember us! Remember The Forsaken!"
            set messages[2] = "From my land, no one escapes!"
            set messages[3] = "One HEART to rule them ALL!"
            set messages[4] = "Tremble, mortals, and despair! Doom has come to this world!"
            set messages[5] = "Release me! I COMMAND you!"
            set messages[6] = "There is no good and evil! There is only power, and those too weak to seek it."
            set messages[7] = "To die, or not to die."
            set messages[8] = "NEVER! I... I will never... serve... you"
            set messages[9] = "I will show you the justice of the grave. And the true meaning of fear!"
        endmethod
    
    endstruct
	
	/*
	 * Cinematic fuer den King Marco Mithas
	 */ 
	
	struct KingCinematic
        
		static method step3 takes nothing returns nothing
			call CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1.00, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.00, 100.00, 100.00, 0)
            call CameraSetupApplyForPlayer( true, gg_cam_MainCameraView, GetLocalPlayer(), 0 )
            call CinematicModeBJ(false, GetPlayersAll())
            call PauseAllUnitsBJ(false)
            
			call SetCameraPosition(KingMithasCore.camX, KingMithasCore.camY)
			call ReleaseTimer(GetExpiredTimer())
			call KingMithasCore.onCreateKingMithas()
		endmethod
		
		static method step2 takes nothing returns nothing
		    call KillUnit(KingMithasCore.fakeKing)
            call CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2.00, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.00, 100.00, 100.00, 0)
            call TimerStart(GetExpiredTimer(), 3.0, false, function thistype.step3 )
		endmethod
		
        static method step1 takes nothing returns nothing
		    call Sound.runSound(SOUND_1)
            call ShowUnit(KingMithasCore.fakeKing, true)
            call CameraSetupApplyForPlayer( true, gg_cam_KingMarcoMithas, GetLocalPlayer(), 0 )
            call CinematicModeBJ(true, GetPlayersAll())
            call CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1.00, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.00, 100.00, 100.00, 0)
            call TransmissionFromUnitWithNameBJ( GetPlayersAll(), KingMithasCore.fakeKing, "King", null, introMessage, bj_TIMETYPE_SET, TEXT_DURATION, false )
            call DestroyEffect(AddSpecialEffect(EFFECT_1, GetUnitX(KingMithasCore.fakeKing), GetUnitY(KingMithasCore.fakeKing)))
            call Sound.runSound(SOUND_2)
            
            call TimerStart(GetExpiredTimer(), 8.0, false, function thistype.step2 )
		endmethod
        
		static method start takes nothing returns nothing
			local timer t = NewTimer()
            
			call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call VolumeGroupSetVolumeBJ(SOUND_VOLUMEGROUP_AMBIENTSOUNDS, 0.00)
            call VolumeGroupSetVolumeBJ(SOUND_VOLUMEGROUP_SPELLS, 0.00)
            call VolumeGroupSetVolumeBJ(SOUND_VOLUMEGROUP_COMBAT, 0.00)
            call VolumeGroupSetVolumeBJ(SOUND_VOLUMEGROUP_FIRE, 0.00)
            call CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 1.00, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 100.00, 100.00, 100.00, 0)
            call PauseAllUnitsBJ(true)
            call TimerStart(t, 3.0, false, function thistype.step1 )
		endmethod
        
        static method onInit takes nothing returns nothing
            call Sound.preload(SOUND_1)
			call Sound.preload(SOUND_2)
        endmethod
        
    endstruct

endscope
