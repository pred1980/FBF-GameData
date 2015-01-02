scope FBFMultiboard

    globals
        private constant string MB_TITLE = "Forsaken Bastion's Fall"
        private constant boolean MB_DISPLAY = true
        private constant boolean MB_MINIMIZE = true
        private constant boolean MB_SUPPRESS = false
        private constant integer ROWS = 22
        private constant integer COLUMNS = 15
        private constant string array HERO_ICONS
		
		private constant string array HUMAN_ITEM_ICONS
		private constant string array NIGHTELF_ITEM_ICONS
		private constant string array ORC_ITEM_ICONS
		private constant string array UNDEAD_ITEM_ICONS
		
        private constant integer array PLAYER_IDS_2_ROW
    endglobals
    
    struct FBFMultiboard

        static Multiboard board
        static real time = 0.
        
        static integer seconds = 0
        static integer minutes = 0
        static integer hours = 0
        static string gameTime = ""
        
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            local timer t = NewTimer()
            
            set .board = Multiboard.create(ROWS, COLUMNS)
            set .board.title = MB_TITLE
            set .board.display = MB_DISPLAY
            set .board.minimize = MB_MINIMIZE
            set .board.suppress = MB_SUPPRESS
            
            call .board.setStyle(true, false)
            call initPlayerIds2Row()
            call initTeams()
            call initColumns()
            call initMisc()
            call initHeroIcons()
            call initPlayerIds2Row()
			call initItems()
            
            call TimerStart(t, 1.0, true, function thistype.onGameTime)
            
            return this
        endmethod
        
        private static method initTeams takes nothing returns nothing
            //Team Undead
            set .board[1][0].text = "The Forsaken Kingdom"
            
            //Player Names
            set .board[2][1].text = GetPlayerNameColored(Player(0), false)
            set .board[3][1].text = GetPlayerNameColored(Player(1), false)
            set .board[4][1].text = GetPlayerNameColored(Player(2), false)
            set .board[5][1].text = GetPlayerNameColored(Player(3), false)
            set .board[6][1].text = GetPlayerNameColored(Player(4), false)
            set .board[7][1].text = GetPlayerNameColored(Player(5), false)
            
            //Hero Icons
            call board[2][0].setStyle(false, true)
            call board[3][0].setStyle(false, true)
            call board[4][0].setStyle(false, true)
            call board[5][0].setStyle(false, true)
            call board[6][0].setStyle(false, true)
            call board[7][0].setStyle(false, true)
            
            //Player Names
            set .board[9][0].text = "The Coalition"
            set .board[10][1].text = GetPlayerNameColored(Player(6), false)
            set .board[11][1].text = GetPlayerNameColored(Player(7), false)
            set .board[12][1].text = GetPlayerNameColored(Player(8), false)
            set .board[13][1].text = GetPlayerNameColored(Player(9), false)
            set .board[14][1].text = GetPlayerNameColored(Player(10), false)
            set .board[15][1].text = GetPlayerNameColored(Player(11), false)
            
            //Hero Icons
            call board[10][0].setStyle(false, true)
            call board[11][0].setStyle(false, true)
            call board[12][0].setStyle(false, true)
            call board[13][0].setStyle(false, true)
            call board[14][0].setStyle(false, true)
            call board[15][0].setStyle(false, true)
        endmethod
		
		private static method initItems takes nothing returns nothing
			local integer i = 0
			local integer k = 9
			
			loop
				exitwhen i >= bj_MAX_PLAYERS
				if Game.isPlayerInGame(i) then
					loop
						exitwhen k > 15 
						call board[PLAYER_IDS_2_ROW[i]][k].setStyle(false, true)
						set board[PLAYER_IDS_2_ROW[i]][k].icon = "EmptyItemIcon.blp"
						set k = k + 1
					endloop
				endif
				set i = i + 1
				set k = 9
			endloop
		endmethod
        
        private static method initColumns takes nothing returns nothing
            local integer i = 0
            local integer k = 2
            
            //columns
            set .board[0][2].text = "L" //Level
            set .board[0][3].text = "HK" //Hero Kills
            set .board[0][4].text = "CK" //Creep Kills
			set .board[0][5].text = "TK" //Tower Kills
            set .board[0][6].text = "D" //Deaths
            set .board[0][7].text = "A" //Assists
            set .board[0][8].text = "Status" //Status (alive or dead)
			set .board[0][9].text = "Iems" //Items
            
            loop
                exitwhen k > 7
                loop
                    exitwhen i >= bj_MAX_PLAYERS
                    if Game.isPlayerInGame(i) then
                        set .board[PLAYER_IDS_2_ROW[i]][k].text = I2S(0)
                    endif
                    set i = i + 1
                endloop
                set k = k + 1
                set i = 0
            endloop
            
            //columns widths
            set .board.column[0].width = .015 // Hero Icon
            set .board.column[1].width = .07 // Hero Name
            set .board.column[2].width = .02  // Level
            set .board.column[3].width = .02  // Hero Kills
            set .board.column[4].width = .02  // Unit Kills
			set .board.column[5].width = .02  // Tower Kills
            set .board.column[6].width = .02  // Deaths
            set .board.column[7].width = .02  // Assists
            set .board.column[8].width = .04  // Status
			
			set .board.column[9].width = .015  // Item 1
			set .board.column[10].width = .015 // Item 2
			set .board.column[11].width = .015 // Item 3
			set .board.column[12].width = .015 // Item 4
			set .board.column[13].width = .015 // Item 5
			set .board.column[14].width = .015 // Item 6
			
            //special widths
            set .board[0][1].width = .07
            set .board[1][0].width = .07
            set .board[9][0].width = .04
            set .board[17][0].width = .07
            set .board[18][0].width = .07
            set .board[19][0].width = .07
			set .board[20][0].width = .07   
        endmethod
        
        private static method initMisc takes nothing returns nothing
            set .board[17][0].text = "Round: "
            set .board[18][0].text = "Attackers: "
			set .board[19][0].text = "Defenders: "
            set .board[20][0].text = "Game Time: "
        endmethod
        
        private static method onGameTime takes nothing returns nothing
            //calculation
            set .gameTime = ""
            set .seconds = .seconds + 1
            if .seconds == 60 then
                set .minutes = .minutes + 1
                set .seconds = 0
            endif
            if .minutes == 60 then
                set .hours = .hours + 1
                set .minutes = 0
            endif
            
            //prepare Time for the update of the Multiboard
            if .hours > 0 then
                if .hours < 10 then
                    set .gameTime = .gameTime + "0" + I2S(.hours) + ":"
                else
                    set .gameTime = .gameTime + I2S(.hours) + ":"
                endif
            endif
            
            if .minutes > 0 then
                if .minutes < 10 then
                    set .gameTime = .gameTime + "0" + I2S(.minutes) + ":"
                else
                    set .gameTime = .gameTime + I2S(.minutes) + ":"
                endif
            endif
            
            if .seconds < 10 then
                set .gameTime = .gameTime + "0" + I2S(.seconds)
            else
                set .gameTime = .gameTime + I2S(.seconds)
            endif
            
            //update Multiboard
            set .board[20][0].text = "Game Time: " + .gameTime
        endmethod
        
        static method initHeroIcons takes nothing returns nothing
            set HERO_ICONS[0] = "ReplaceableTextures\\CommandButtons\\BTNBehemot.blp"
            set HERO_ICONS[1] = "ReplaceableTextures\\CommandButtons\\BTNNerubianWidow.blp"
            set HERO_ICONS[2] = "ReplaceableTextures\\CommandButtons\\BTNGlazeroth.blp"
            set HERO_ICONS[3] = "ReplaceableTextures\\CommandButtons\\BTNGhoul.blp"
            set HERO_ICONS[4] = "ReplaceableTextures\\CommandButtons\\BTNGhost.blp"
            set HERO_ICONS[5] = "ReplaceableTextures\\CommandButtons\\BTNRevenant.blp"
            set HERO_ICONS[6] = "ReplaceableTextures\\CommandButtons\\BTNSkeletonMage.blp"
            set HERO_ICONS[7] = "ReplaceableTextures\\CommandButtons\\BTNKelThuzad.blp"
            set HERO_ICONS[8] = "ReplaceableTextures\\CommandButtons\\BTNHeroCryptLord.blp"
            set HERO_ICONS[9] = "ReplaceableTextures\\CommandButtons\\BTNAbomination.blp"
            set HERO_ICONS[10] = "ReplaceableTextures\\CommandButtons\\BTNDestroyer.blp"
            set HERO_ICONS[11] = "ReplaceableTextures\\CommandButtons\\BTNHeroDreadLord.blp"
            set HERO_ICONS[23] = "ReplaceableTextures\\CommandButtons\\BTNBansheeRanger.blp"
            
            set HERO_ICONS[12] = "ReplaceableTextures\\CommandButtons\\BTNHeroArchMage.blp"
            set HERO_ICONS[13] = "ReplaceableTextures\\CommandButtons\\BTNHeroTaurenChieftain.blp"
            set HERO_ICONS[14] = "ReplaceableTextures\\CommandButtons\\BTNPriestessOfTheMoon.blp"
            set HERO_ICONS[15] = "ReplaceableTextures\\CommandButtons\\BTNNagaSummoner.blp"
            set HERO_ICONS[16] = "ReplaceableTextures\\CommandButtons\\BTNOrcWarlockRed.blp"
            set HERO_ICONS[17] = "ReplaceableTextures\\CommandButtons\\BTNMagharSpiritcaller.blp"
            set HERO_ICONS[18] = "ReplaceableTextures\\CommandButtons\\BTNFireBrewmaster.blp"
            set HERO_ICONS[19] = "ReplaceableTextures\\CommandButtons\\BTNMountainGiant.blp"
            set HERO_ICONS[20] = "ReplaceableTextures\\CommandButtons\\BTNKeeperOfTheGrove.blp"
            set HERO_ICONS[21] = "ReplaceableTextures\\CommandButtons\\BTNHeroPaladin.blp"
            set HERO_ICONS[22] = "ReplaceableTextures\\CommandButtons\\BTNGarithos.blp"
            set HERO_ICONS[24] = "ReplaceableTextures\\CommandButtons\\BTNHeroBloodElfPrince.blp"
            set HERO_ICONS[25] = "ReplaceableTextures\\CommandButtons\\BTNGladiator.BLP"
            set HERO_ICONS[26] = "ReplaceableTextures\\CommandButtons\\BTNGiantTurtle.blp"
        endmethod
		
		static method initPlayerIds2Row takes nothing returns nothing
            set PLAYER_IDS_2_ROW[0] = 2 // Player 1
            set PLAYER_IDS_2_ROW[1] = 3 // Player 2
            set PLAYER_IDS_2_ROW[2] = 4 // Player 3
            set PLAYER_IDS_2_ROW[3] = 5 // Player 4
            set PLAYER_IDS_2_ROW[4] = 6 // Player 5
            set PLAYER_IDS_2_ROW[5] = 7 // Player 6
            
            set PLAYER_IDS_2_ROW[6] = 10 // Player 7
            set PLAYER_IDS_2_ROW[7] = 11 // Player 8
            set PLAYER_IDS_2_ROW[8] = 12 // Player 9
            set PLAYER_IDS_2_ROW[9] = 13 // Player 10
            set PLAYER_IDS_2_ROW[10] = 14 // Player 11
            set PLAYER_IDS_2_ROW[11] = 15 // Player 12
        endmethod
        
        /*********************************
         *     PUBLIC UPDATE METHODS     *
         *********************************/
         
        //update Hero icon
        static method onUpdateHeroIcon takes integer pid returns nothing
            set .board[PLAYER_IDS_2_ROW[pid]][0].icon = HERO_ICONS[BaseMode.pickedHeroIndex[pid]]
        endmethod
        
        static method onUpdatePlayerName takes integer pid returns nothing
			set .board[PLAYER_IDS_2_ROW[pid]][1].text = GetPlayerNameColored(Player(pid), true)
        endmethod
        
        static method onUpdateHeroLevel takes integer pid, unit hero returns nothing
			set .board[PLAYER_IDS_2_ROW[pid]][2].text = "  " + I2S(GetHeroLevel(hero))
        endmethod
        
        static method onUpdateHeroKills takes integer pid returns nothing
            local integer phyKills = KillCounter.getPlayerHeroKills(Player(pid), PHYSICAL, ALL_ROUNDS)
            local integer spellKills = KillCounter.getPlayerHeroKills(Player(pid), SPELL, ALL_ROUNDS)
            set .board[PLAYER_IDS_2_ROW[pid]][3].text = "    " + I2S(phyKills + spellKills)
        endmethod
        
        static method onUpdateUnitKills takes integer pid returns nothing
			local integer phyKills = KillCounter.getPlayerUnitKills(Player(pid), PHYSICAL, ALL_ROUNDS)
            local integer spellKills = KillCounter.getPlayerUnitKills(Player(pid), SPELL, ALL_ROUNDS)
			local integer towerKills = KillCounter.getPlayerTowerKills(Player(pid), PHYSICAL, ALL_ROUNDS)
			set .board[PLAYER_IDS_2_ROW[pid]][4].text = "   " + I2S((phyKills + spellKills) - towerKills)
        endmethod
		
		static method onUpdateTowerKills takes integer pid returns nothing
			local integer towerKills = KillCounter.getPlayerTowerKills(Player(pid), PHYSICAL, ALL_ROUNDS)
			set .board[PLAYER_IDS_2_ROW[pid]][5].text = "   " + I2S(towerKills)
        endmethod
        
        static method onUpdateDeaths takes integer pid returns nothing
            local integer deaths = PlayerStats.getPlayerAllDeaths(Player(pid))
            set .board[PLAYER_IDS_2_ROW[pid]][6].text = "  " + I2S(deaths)
        endmethod
        
        static method onUpdateAssits takes integer pid returns nothing
            set .board[PLAYER_IDS_2_ROW[pid]][7].text = "  " + I2S(AssistSystem.getAssistCount(Player(pid)))
        endmethod
        
        static method onUpdateStatus takes integer pid, unit hero returns nothing
            local boolean isDead = IsUnitDead(hero)
            local string msg = "alive"
            
            if isDead then
                set msg = "dead"
            endif
            set .board[PLAYER_IDS_2_ROW[pid]][8].text = msg
        endmethod
        
        static method onUpdateRound takes integer round returns nothing
            set .board[17][0].text = "Round: " + I2S(round)
        endmethod
        
        static method onUpdateAttackers takes integer amount returns nothing
            set .board[18][0].text = "Attackers: " + I2S(amount)
        endmethod
		
		static method onUpdateDefenders takes integer amount returns nothing
            set .board[19][0].text = "Defenders: " + I2S(amount)
        endmethod
		
		//Update picked, dropped, selled... Item of player x
		static method onUpdateItemIcon takes unit hero returns nothing
            local integer pid = GetPlayerId(GetOwningPlayer(hero))
			local integer slot = 0
			
			loop
                exitwhen slot > 5
                if Game.isPlayerInGame(pid) then
					set .board[PLAYER_IDS_2_ROW[pid]][slot+9].icon = UnitInventory.getItemPath(hero, slot)
				endif
				set slot = slot + 1
			endloop
		endmethod

        //update MB if a player leaves the game --> GameConig
        static method onPlayerLeftGame takes integer pid returns nothing
            set .board[PLAYER_IDS_2_ROW[pid]][0].icon = "ReplaceableTextures\\CommandButtons\\BTNSacrificialSkull.blp"
            set .board[PLAYER_IDS_2_ROW[pid]][1].text = "--- left game ---"
            set .board[PLAYER_IDS_2_ROW[pid]][2].text = "---"
            set .board[PLAYER_IDS_2_ROW[pid]][3].text = "---"
            set .board[PLAYER_IDS_2_ROW[pid]][4].text = "---"
            set .board[PLAYER_IDS_2_ROW[pid]][5].text = "---"
            set .board[PLAYER_IDS_2_ROW[pid]][6].text = "---"
            set .board[PLAYER_IDS_2_ROW[pid]][7].text = "---"
			set .board[PLAYER_IDS_2_ROW[pid]][8].text = "---"
			set .board[PLAYER_IDS_2_ROW[pid]][9].text = "---"
        endmethod
        
        static method onUpdateRepick takes integer pid returns nothing
            set .board[PLAYER_IDS_2_ROW[pid]][0].icon = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
            set .board[PLAYER_IDS_2_ROW[pid]][1].text = "repicking..."
            set .board[PLAYER_IDS_2_ROW[pid]][2].text = "?"
            set .board[PLAYER_IDS_2_ROW[pid]][3].text = "?"
            set .board[PLAYER_IDS_2_ROW[pid]][4].text = "?"
            set .board[PLAYER_IDS_2_ROW[pid]][5].text = "?"
            set .board[PLAYER_IDS_2_ROW[pid]][6].text = "?"
            set .board[PLAYER_IDS_2_ROW[pid]][7].text = "?"
            set .board[PLAYER_IDS_2_ROW[pid]][8].text = "?"
			set .board[PLAYER_IDS_2_ROW[pid]][9].text = "?"
        endmethod
        
    endstruct
	  
endscope