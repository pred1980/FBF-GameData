library KillStreakSystem uses GetPlayerNameColored

	/*
		F.A.Q:
		
		Q: 	Was macht das System?
		A: 	Das System z?hlt die Kills eines Spielers, die er gemacht hat ohne dazwischen zu sterben und kann demnach Messages ausgeben.
		
		Q:	Wie gebe ich eine Streak-Message aus?
		A:	Streak-Messages werden mithilfe der Methode displayKillStreakMessage(p) direkt vom System ausgegeben, insofern der Spieler aktuell
			einen Kill-Streak hat, der registriert wurde
			
		Q: 	Wie registriere ich einen normalen Kill-Streak?
		A:	Kill-Streaks werden mithilfe der addStreak(streakCount, message) registriert. Die Variable streakCount steht hierf?r f?r die Anzahl
			der Kills die ohne Unterbrechung gemacht wurden, message ist der String der ausgegeben wird. Message hat zwei - ich nenn sie mal Modifier-Keys -
			die wie folgt funktionieren:
				%s1 wird duch den Namen des Spielers ersetzt, der auf dem Kill-Streak ist
				%s2 wird durch die Anzahl des Streak-Counters ersetzt, sprich 6, wenn der Spieler einen 6er-Kill-Streak hat
		
		Q: 	Z?hlt das System automatisch Kills usw?
		A:	Nein, wie bei meinem Assist-System m?ssen die Streaks per Hand erh?ht werden und zwar mithilfe der increaseKillStreak(p), welche in
			eurer Funktion aufgerufen werden sollte, wenn ein Held get?tet wird. Dasselbe auch mit resetKillStreak(p) f?r den Helden, der get?tet wurde.
			Man sollte aber beachten, dass increaseKillStreak(p) vor Aufruf der Methode displayKillStreakMessage(p) aufgerufen wird.
	
	
		Q:	Wof?r steht ADVANCED_VERSION?
		A:	Die Advanced Version erm?glicht es nicht nur, allgemein Streaks zu z?hlen, sondern Streaks von Spielern auf Spieler.
			Wenn nun anstatt von displayKillStreakMessage(p) die Methode displaySmartKillStreakMessage(p1, p2) aufgerufen wird, ?berpr?ft das
			System erst, ob ein registrierter Streak von Spieler zu Spieler existiert und gibt diese Nachricht aus, sonst die normale (oder gar keine
			falls keine registriert ist.
			
		Q:	Wie registriere ich eine Advanced Kill-Streak Message?
		A:	Mithilfe der Methode addAdvancedKillStreak(streakCount, message) wird sie registriert. Auch sie hat wieder Modifier-Keys:
				%s1: Der Name des Spielers der den Kill-Streak erreicht hat
				%s2: Der Name des Spielers, der Opfer des Streaks ist
				%s3: Der Streak-Count vom Spieler (%s1 auf %s2)
	
	*/

	globals
		/*	Wenn true, dann z?hlt das System die Kill-Streak von jedem Spieler
			zu jedem anderen Spieler und kann Nachrichten ausgeben. Sprich wenn
			ein Spieler einen bestimmten Spieler schon 3x hintereinander get?tet hat
			ohne gestorben zu sein
		*/
		private constant boolean ADVANCED_VERSION = false
		private constant integer PLAYER_AMOUNT = 12
	endglobals
	
	//Basic Streaks Initialization
	private function initiateStreaks takes nothing returns nothing
		call KillStreakSystem.addStreak(3, "%s1 has %s2 kills in a row!")
		call KillStreakSystem.addStreak(5, "%s1 is going mad with %s2 kills in a row!")
		call KillStreakSystem.addStreak(7, "%s1 is going out of control and has %s2 kills out of control!")
		call KillStreakSystem.addStreak(10, "%s1 is completely owning with %s2 kills in a row!")
		call KillStreakSystem.addStreak(15, "%s1 is unstoppable with %s2 kills in a row!")
		call KillStreakSystem.addStreak(20, "%s1 is beyond godlike, %s2 kills in a row, not even a god can do this!")	
	endfunction
		
	//Ersetzt einfach einen Strigteil mit einem anderen String
	private function ReplaceStringInString takes string source, string toreplace, string replacer returns string
		local integer i = StringLength(source)
		local integer j = StringLength(toreplace)
		local integer n = 0
		if (toreplace == replacer) then
			return source
		endif
		loop
			exitwhen (n > i - j)
			if (SubString(source, n, n + j) == toreplace) then
				set source = SubString(source, 0, n) + replacer + SubString(source, n + j, i)
				set i = StringLength(source)
			else
				set n = n + 1
			endif
		endloop
		return source
	endfunction
	
	struct KillStreakSystem
		private static integer array streaks[PLAYER_AMOUNT]
		private static integer array adv_streaks[PLAYER_AMOUNT][PLAYER_AMOUNT]
		private static string array streakStrings
		private static boolean array streakHasMessage
		
		static method addStreak takes integer streakCount, string message returns nothing
			if streakCount >= 1 then
				set streakStrings[streakCount] = message
				set streakHasMessage[streakCount] = true
			endif
		endmethod
		
		//Gibt den aktuellen Kill-Streak eines Spielers zur?ck
		static method getKillStreak takes player p returns integer
			return streaks[GetPlayerId(p)]	
		endmethod
        
        //Gibt den aktuellen Kill-Streak eines Spielers zur?ck
		static method getStreakHasMessage takes integer streak returns boolean
			return streakHasMessage[streak]	
		endmethod
		
		//Setzt dem Kill-Streak Counter eines Spielers zur?ck
		static method resetKillStreak takes player p returns nothing
			set streaks[GetPlayerId(p)] = 0
		endmethod
		
		//Erh?ht den Kill-Streak Counter um 1
		static method increaseKillStreak takes player p returns nothing
            set streaks[GetPlayerId(p)] = streaks[GetPlayerId(p)] + 1
		endmethod
		
		//Gibt die Kill-Streak Message f?r den Spieler aus
		static method displayKillStreakMessage takes player p returns nothing
			local integer id = GetPlayerId(p)
			local string msg = ""
            if streaks[id] > 0 and streakHasMessage[streaks[id]] then
				set msg = ReplaceStringInString(streakStrings[streaks[id]], "%s1", GetPlayerNameColored(p, false))
				set msg = ReplaceStringInString(msg, "%s2", I2S(streaks[id]))
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 5.0, msg)
            endif
		endmethod
			
		static method initialize takes nothing returns nothing
			local integer i = 0
			local integer j = 0
            loop
                exitwhen i >= PLAYER_AMOUNT
				set streaks[i] = 0
				static if ADVANCED_VERSION then
					loop
						exitwhen j >= PLAYER_AMOUNT
						set adv_streaks[i][j] = 0
						set j = j + 1
					endloop
				endif
                set i = i + 1
            endloop
            call initiateStreaks()
        endmethod

	endstruct

endlibrary