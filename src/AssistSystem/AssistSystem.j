library AssistSystem uses DamageEvent, GetPlayerNameColored, TimerUtils

	/*
		F.A.Q.:
	
		Q: 	Was macht das System?
		A: 	Das System added automatisch einen Spieler auf eine Assist-Liste, wenn dieser einem anderen Schaden zuf?gt
		
		Q: 	Was macht es nicht?
		A: 	Nachrichten ausgeben, auf Events reagieren (au?er Schaden) oder irgendwas dergleichen. 
			Das System arbeitet komplett im Hintergrund und macht von sich selbst aus nichts au?er Assist-Timer-Management
		   
		Q:	Wie pr?fe ich, ob ein Spieler ein Assister von einem anderen ist?
		A:	Da das System keine Death-Events von allein hat, muss selbst in einem dieser Events, das woanders deklarier wird, abgefragt
			werden, ob ein Spieler ein Assister von einem anderen Spieler ist.
			
		Q: 	Aha, und wie mach ich das?
		A:	Death-Event erzeugen und mithilfe der isPlayerAssist(p1, p2) abfragen, ob Spieler p1 ein Assister f?r den Spieler p2 ist.
			p1 ist hierf?r die Einheit, die mitgeholfen hat, die Einheit p2 zu t?ten.
			
		Q:	Kann ich auch manuell Assists hinzuf?gen?
		A:	Dies geht ganz einfach mithilfe der setPlayerAssist(p1, p2) oder der setPlayerAssistTimed(p1, p2) Methoden. Wieder steht p1
			f?r den Spieler, der den Assist erhalten soll und p2 f?r das Opfer.
	
		Q:	Was ist mit Assist-Resets bei einem Tod z.B.?
		A:	Da das System keine eigenen Events bis auf Schaden hat, m?ssen die Assists selbst mithilfe der Methode resetAllAssistsOfPlayer(p)
			gel?scht werden, wobei p f?r den Spieler steht, dessen Held halt gestorben ist. Dies geht auch spezifisch f?r einen Spieler mithilfe
			der removeAssistOfPlayer(p1, p2) Methode, hier wird jedoch der spezifische Spieler p1 als Assist von p2 entfernt.
			
		Q:	Sonst noch was?
		A:	Das System verf?gt wahrscheinlich ?ber Syntax-Fehler, daf?r k?nnen aber Allies schon nicht Assister von Spielern aus dem selben Team sein.
			Ach und Bugs k?nnten nat?rlich auch noch drin sein.
			!!!Unbedingt ?berpr?fen, dass das, was in Zeile 109 steht problemlos initialisiert wird und die Meldung in Zeile 91 problemlos erscheint!!!
			
	*/

	globals
		private constant integer PLAYER_AMOUNT = 12
		private constant real ASSIST_DURATION = 10.00
    endglobals

	struct AssistSystem

		private static timer array assistTimer[PLAYER_AMOUNT][PLAYER_AMOUNT]
        
        //Returned true, wenn Spieler p2 einen Assist auf Player p1 hat
		static method isPlayerAssist takes player p2, player p1 returns boolean
			if TimerGetRemaining(assistTimer[GetPlayerId(p1)][GetPlayerId(p2)]) > 0.00 and Game.isPlayerInGame(GetPlayerId(p2)) then
                //debug call BJDebugMsg(GetPlayerNameColored(p1) + " has an assist for " + GetPlayerNameColored(p2) + " for " + R2S(TimerGetRemaining(assistTimer[GetPlayerId(p1)][GetPlayerId(p2)])) + "seconds.")
                return true
           endif
           return false
        endmethod
		
		//Entfernt Spieler p2 als Assist von p1
		static method removeAssistOfPlayer takes player p2, player p1 returns nothing
			if TimerGetRemaining(assistTimer[GetPlayerId(p1)][GetPlayerId(p2)]) > 0.00 then
                //debug call BJDebugMsg("Removing " + GetPlayerNameColored(p1) + " as an assist of " + GetPlayerNameColored(p2) + ".")
				call PauseTimer(assistTimer[GetPlayerId(p1)][GetPlayerId(p2)])
			endif
		endmethod
		
		//L?scht alle Assists vom Spieler
		static method resetAllAssistsOfPlayer takes player p returns nothing
			local integer i = 0
			loop
				exitwhen i >= bj_MAX_PLAYERS
				call thistype.removeAssistOfPlayer(p, Player(i))
				set i = i + 1
			endloop
		endmethod
        
        //F?gt den Spieler p2 als Assist zu Spieler p1 hinzu
        static method setPlayerAssistTimed takes player p2, player p1, real time returns nothing
            local integer p1_id = GetPlayerId(p1)
			local integer p2_id = GetPlayerId(p2)
			
			//Checken, dass kein Ally nen Assist macht
			if IsPlayerEnemy(p1, p2) then
				//Zur Sicherheit
				if thistype.isPlayerAssist(p1, p2) then
					call PauseTimer(assistTimer[p1_id][p2_id])
				else
                    //debug call BJDebugMsg(GetPlayerNameColored(p2) + " was added as an assister to " + GetPlayerNameColored(p1))
                endif
				call TimerStart(assistTimer[p1_id][p2_id], time, false, null)
			endif
		endmethod
        
       //F?gt Spieler p2 als Assist zu Spieler p1 hinzu, allerdings wird ASSIST_DURATION genommen
		static method setPlayerAssist takes player p2, player p1 returns nothing
			call thistype.setPlayerAssistTimed(p2, p1, ASSIST_DURATION)
		endmethod
        
        //Gibt die Anzahl an Assists f?r Spieler p1 zur?ck
        static method getAssistCount takes player p1 returns integer
            local integer i = 0
            local integer count = 0
            loop
                exitwhen i >= PLAYER_AMOUNT
                if thistype.isPlayerAssist(p1, Player(i)) then
                    set count = count + 1
                endif
                set i = i + 1
            endloop
            return count
        endmethod
	
		//Manuelles Assist Event wenn Schaden entsteht
		private static method onDamageEvent takes unit damagedUnit, unit damageSource, real damage returns nothing
            if damagedUnit == BaseMode.pickedHero[GetPlayerId(GetOwningPlayer(damagedUnit))] then
                call thistype.setPlayerAssist(GetOwningPlayer(damagedUnit), GetOwningPlayer(damageSource))
            endif
		endmethod
        
        //Initialisierung des kleinen Systemchens
		static method initialize takes nothing returns nothing
            local integer i = 0
			local integer j = 0
            loop
                exitwhen i >= PLAYER_AMOUNT
				loop
					exitwhen j >= PLAYER_AMOUNT
					set assistTimer[i][j] = NewTimer()
					set j = j + 1
				endloop
                
				set j = 0
                set i = i + 1
            endloop
		    call RegisterDamageResponse(thistype.onDamageEvent)
        endmethod

	endstruct

endlibrary