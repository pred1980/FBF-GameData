library GoldSystem uses GetPlayerNameColored, TextTag, CreepSystemUnits

    globals
        private constant integer STARTGOLD_FORSAKEN = 510
        private constant integer STARTLUMBER_FORSAKEN = 350
        private constant integer STARTGOLD_COALITION = 450
        private constant integer RANDOMGOLD = 150
    
        private constant integer HERO_KILL_BONI = 100
        private constant integer HERO_KILL_MULTIPIER = 5
        
        private constant integer ASSIST_BONI = 45
        
        private constant integer MAX_STREAK = 20
        private integer array STREAK_BONI
        
        private constant integer GOLD_LOSS_MULTIPLIER = 70
    endglobals
	
	globals
        //Gold Income
		/*
		 * Forsaken:  Alle 5s gibt es 2 Gold! Nach 1min == 24 | Nach 10min == 240 Gold
		 * Coalition: Alle 5s gibt es 10 Gold! Nach 1min == 120 | Nach 10min == 1200 Gold 
		 */ 
        private constant integer FORSAKEN_GOLD = 2
        private constant integer COALITION_GOLD = 10
        private constant real INCOME_INTERVAL = 5.00
    endglobals
    
    struct BaseGoldSystem
    
        readonly static integer START_GOLD_FORSAKEN = STARTGOLD_FORSAKEN
        readonly static integer START_LUMBER_FORSAKEN = STARTLUMBER_FORSAKEN
        readonly static integer START_GOLD_COALITION = STARTGOLD_COALITION
        readonly static integer RANDOM_GOLD = RANDOMGOLD
    
    endstruct

    //Bonus Gold bei Hero Kill
    struct BonusGoldOnDeath
    
        static integer streakBoni = 0
        
        //returns the Bonus Gold a killed Hero
        private static method getBonusForHero takes unit killed, unit killer returns integer
            return HERO_KILL_BONI + (GetHeroLevel(killed) * HERO_KILL_MULTIPIER)
        endmethod
        
        //returns the Gold who loses the Player for his killed Hero
        private static method getGoldLossForKilledHero takes unit killed returns integer
            return GetHeroLevel(killed) * GOLD_LOSS_MULTIPLIER
        endmethod
        
        //returns the Bonus Gold(Bounty) a killed Creep Unit
        private static method getBonusForCreep takes unit killed returns integer
            return GET_UNIT_VALUE(GetUnitTypeId(killed), 3)
        endmethod
        
        //returns the Death Messages when a hero is killed
		//+add gold/remove gold
        static method showDeathMessageAndUpdateGold takes unit killed, unit killer returns nothing
            local integer pidKiller = GetPlayerId(GetOwningPlayer(killer))
            local integer pidKilled = GetPlayerId(GetOwningPlayer(killed))
            local integer gold = 0
            local integer goldloss = 0
            local integer streak = 0
            local string deathString = ""
            
            if not Unit.isExceptionUnit(killed) then
			    //is a Hero of a Player or is a normal unit?
                if killed == BaseMode.pickedHero[pidKilled] then
                    set gold = getBonusForHero(killed, killer)
                    set goldloss = getGoldLossForKilledHero(killed)
                    set streak = KillStreakSystem.getKillStreak(GetOwningPlayer(killed))

					//Textausgabe zusammenbauen
					if GetPlayerController(GetOwningPlayer(killer)) == MAP_CONTROL_USER then
						set deathString = "The Player "
					endif
					set deathString = deathString + GetPlayerNameColored(Player(pidKiller), false) + " just killed " + GetPlayerNameColored(Player(pidKilled), false) + " for " + "|cffffcc00" + I2S(gold) + "|r gold!"
					
					//Gibt den akt. Streak des gekillten Spielers zur?ck
					if KillStreakSystem.getStreakHasMessage(streak) then
						set deathString = deathString + " Killed Streak Bonus: " + "(|cffffcc00+" + I2S(BonusGoldOnStreak.getStreakBonus(streak)) + ")|r"
					endif
				
					//remove gold for the killed hero
					call Game.playerRemoveGold(pidKilled, goldloss)
					//Show loss gold over the killed
					call TextTagLossGold(killed, goldloss, GetOwningPlayer(killed))
					
					//Ist der Killer ein Spieler?
					if GetPlayerController(GetOwningPlayer(killer)) == MAP_CONTROL_USER then
						//add Gold and Streak Gold for the Killer
						call Game.playerAddGold(pidKiller, gold + streak)
						//Show Gold Bounty over the killed
						call TextTagGoldBounty(killed, gold + streak, GetOwningPlayer(killer))
					endif
					//Display Death Message
                    call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, deathString)
					//Nur wenn der Killer auch ein richtiger Spieler gewesen ist, zähle die Assists + Streak
					if GetPlayerController(GetOwningPlayer(killer)) == MAP_CONTROL_USER then
						//Display Assists
						call BonusGoldOnAssist.showAssistMessage(killed, killer)
						//Assists resetten
						call AssistSystem.resetAllAssistsOfPlayer(GetOwningPlayer(killed))
						//Kill Streak?
						call KillStreakSystem.increaseKillStreak(GetOwningPlayer(killer))
						call KillStreakSystem.displayKillStreakMessage(GetOwningPlayer(killer))
						call KillStreakSystem.resetKillStreak(GetOwningPlayer(killed))
					endif
				else
					//Solange der Killer kein Computer ist, mach folgendes...
					if not Game.isBot[GetPlayerId(GetOwningPlayer(killer))] then
						//Ist die getoetet normale Einheit (also kein Held) eine Untote Einheit?
						if GetUnitRace(killed) == RACE_UNDEAD then
							set gold = ForsakenDefenseUnits.getBounty(killed) // Gold(Bounty) //Forsaken Units
						else
							set gold = GET_UNIT_VALUE(GetUnitTypeId(killed), 3) // Gold(Bounty) //Creep Round Units
						endif
						/*******************************************************************************
						 * Wenn Gold immer noch 0 ist, dann pruefe auf alle anderen normalen Einheiten, *
						 * die im struct Unit (Unit System) abgespeichert sind und hole dort           *
						 * den Bounty Wert heraus. Falls -1 zurueck kommt, muss die getoetete Einheit    *
						 * in diesem System erfasst werden                                             *
						 *******************************************************************************/
						 if gold <= 0 then
							set gold = Unit.getBounty(killed) // Gold(Bounty)
						 endif
						
						//display Gold Text Tag
						if gold > 0 then
							//add Gold and Streak Gold for the Killer
							call Game.playerAddGold(pidKiller, gold)
							//Show Gold Bounty over the killed
							call TextTagGoldBounty(killed, gold, GetOwningPlayer(killer))
						else
							call Usability.getTextMessage(2, 0, true, GetOwningPlayer(killer), true, 0.1)
						endif
					endif
                endif
            endif
        endmethod
		
    endstruct
    
    //Bonus Gold fuer einen Assist
    struct BonusGoldOnAssist
        
        private static method getAssistBonus takes unit killed returns integer
            return ASSIST_BONI / AssistSystem.getAssistCount(GetOwningPlayer(killed))
        endmethod
        
        static method showAssistMessage takes unit killed, unit killer returns nothing
            local integer i = 0
            local string assistString = ""
            local boolean hit = false
            local integer gold = getAssistBonus(killed)
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) and AssistSystem.isPlayerAssist(Player(i), GetOwningPlayer(killed)) and Player(i) != GetOwningPlayer(killer) then
                    if not hit then
                        set assistString = "Assists: " + GetPlayerNameColored(Player(i), false) + "(|cffffcc00+" + I2S(gold) + "|r)"
                        set hit = true
                    else
                        set assistString = assistString + ", " + GetPlayerNameColored(Player(i), false) + "(|cffffcc00+" + I2S(gold) + "|r)"
                    endif
                    call Game.playerAddGold(i, gold)
                    //Update Multiboard
                    call FBFMultiboard.onUpdateAssits(i)
                endif
                set i = i + 1
            endloop
            
            if hit then
                //Display Assist Message
                call DisplayTimedTextToForce(bj_FORCE_ALL_PLAYERS, 5.0, assistString)
            endif
        endmethod
        
    endstruct
    
    //Bonus Gold f?r eine Kill Streak
    struct BonusGoldOnStreak
        
        static method getStreakBonus takes integer streak returns integer
            if streak <= MAX_STREAK then
                return STREAK_BONI[streak]
            else
                return STREAK_BONI[MAX_STREAK]
            endif
        endmethod
        
        static method initialize takes nothing returns nothing
            set STREAK_BONI[0] = 0
            set STREAK_BONI[1] = 0
            set STREAK_BONI[2] = 0
            set STREAK_BONI[3] = 30
            set STREAK_BONI[5] = 60
            set STREAK_BONI[6] = 90
            set STREAK_BONI[7] = 120
            set STREAK_BONI[8] = 150
            set STREAK_BONI[9] = 180
            set STREAK_BONI[10] = 210
            set STREAK_BONI[11] = 240
            set STREAK_BONI[12] = 270
            set STREAK_BONI[13] = 300
            set STREAK_BONI[14] = 330
            set STREAK_BONI[15] = 360
            set STREAK_BONI[16] = 390
            set STREAK_BONI[17] = 420
            set STREAK_BONI[18] = 450
            set STREAK_BONI[19] = 480
            set STREAK_BONI[20] = 510
        endmethod
        
    endstruct
    
    
    
    struct GoldIncome
        timer t
        boolean isForsaken = false
        static real array time[2]
        static string array goldPerTime[2]
        
        static method create takes boolean isForsaken returns thistype
            local thistype this = thistype.allocate()
            
            set .isForsaken = isForsaken
            set .t = NewTimer()
            call SetTimerData(.t, this)
            
            if .isForsaken then
                call TimerStart(.t, .time[0], true, function thistype.onPeriodic)
            else
                call TimerStart(.t, .time[1], true, function thistype.onPeriodic)
            endif
            
            return this
        endmethod
        
        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local integer i = 0
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) then
                    if this.isForsaken then
                        if GetPlayerRace(Player(i)) == RACE_UNDEAD then
                            call Game.playerAddGold(i, FORSAKEN_GOLD)
                        endif
                    else
                        if GetPlayerRace(Player(i)) != RACE_UNDEAD then
                            call Game.playerAddGold(i, COALITION_GOLD)
                        endif
                    endif
                endif
                set i = i + 1
            endloop
            
        endmethod
        
        //index 0 == forsaken | index 1 == coalition
        static method getIncomeGoldPerTime takes integer index returns string
            return thistype.goldPerTime[index]
        endmethod
        
        static method initialize takes nothing returns nothing
            set .time[0] = INCOME_INTERVAL
            set .goldPerTime[0] = I2S(FORSAKEN_GOLD) + " gold/" + R2SW(.time[0],0,2) + "s"
            
            set .time[1] = INCOME_INTERVAL
            set .goldPerTime[1] = I2S(COALITION_GOLD) + " gold/" + R2SW(.time[1],0,2) + "s"
        endmethod
    
    endstruct

endlibrary