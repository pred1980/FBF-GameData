scope CreepConfigs
    /*
     * Aufgrund der Tatsachen, dass bei beispielsweise 6 Spielern auf der Forsaken Seite zu viele Einheiten im 
     * AoS Teil abkommen muss die Anzahl an Creep Units reduziert werden aber je nach Runde verstärtkt HP.
     * Dazu gibt es 3 Versionen:
     * -------------------------
     * SCC_Low: Diese ist für 1-2 Forsaken Spielern gedacht --> max. 30 Creep Units laufen pro Lane
     * SCC_Medium: Diese ist für 3 Forsaken Spielern gedacht --> max. 20 Creep Units laufen pro Lane
     * SCC_Full: Diese ist für 4-6 Forsaken Spielern gedacht --> max. 10 Creep Units laufen pro Lane
     *
     * Durch die Reduzierung der Einheiten je nach Forsaken Spieleranzahl, müssen die HP der Creep Units je nach akt.
     * Runde erhöht werden, da das Holzeinkommen und die Stärker der Tower nicht angepasst werden.
     */
    struct SCC_Low extends IRound
        
        implement Round
        
        method getRounds takes nothing returns integer
            return thistype.rounds
        endmethod
        
        method getIterator takes integer round returns integer
            return thistype.iterator[round]
        endmethod
        
        method getUnitIndex takes integer iterator, integer round returns integer
            return S2I(getDataFromString(thistype.ids[round], iterator))
        endmethod
        
        method getUnitAmount takes integer iterator, integer round returns integer
            return S2I(getDataFromString(thistype.amount[round], iterator))
        endmethod
        
        method getInterval takes nothing returns real
            return thistype.interval
        endmethod
        
        method getPause takes nothing returns real
            return thistype.pause
        endmethod
        
        method getCount takes nothing returns integer
            return thistype.count
        endmethod
        
        method getRoundTimer takes nothing returns real
            return thistype.roundTimer
        endmethod
        
        method getStartNextRound takes nothing returns integer
            return thistype.startNextRound
        endmethod
        
        static method onInit takes nothing returns nothing
            /* Base Information for this Mod */
            //Wie viele Runden?
            set thistype.rounds = 20
            //Nach welchem Rythmus werden die Einheiten pro Lane gespawnt?
            set thistype.interval = 1.0
            //Wie viele Creeps werden pro Intervall gespawnt?
            set thistype.count = 1
            //Wie lang ist die Rundenpause bevor die nächste Runde startet?
            set thistype.pause = 20.
            //Wie lang ist der Rundentimer, der oben rechts angezeigt wird, bevor die n. Runde gestartet wird?
            set thistype.roundTimer = 30.
            //Wann endet eine Runde? Wie viele Creeps müssen noch am Leben sein, damit eine Runde beendet wird?
            //Kurz: Abbruchbedingung für das Ende einer Runde! :)
            set thistype.startNextRound = 0
            
            // Round 1
            set thistype.ids[1] = "0,12,0,12,0,12,0,12,"
            set thistype.amount[1] = "6,4,5,2,3,3,5,2,"
            set thistype.iterator[1] = 8
            
            // Round 2
            set thistype.ids[2] = "0,12,1,13,1,13,0,12,"
            set thistype.amount[2] = "4,3,6,4,5,3,3,2,"
            set thistype.iterator[2] = 8
            
            // Round 3
            set thistype.ids[3] = "1,12,13,2,13,2,12,0,"
            set thistype.amount[3] = "4,1,4,3,4,6,5,3,"
            set thistype.iterator[3] = 8
            
            // Round 4
            set thistype.ids[4] = "11,13,3,13,3,14,3,13,1,"
            set thistype.amount[4] = "4,3,4,3,4,3,4,2,3,"
            set thistype.iterator[4] = 9
            
            // Round 5
            set thistype.ids[5] = "4,2,14,4,14,13,4,12,2,"
            set thistype.amount[5] = "3,4,4,3,2,3,3,3,5,"
            set thistype.iterator[5] = 9
            
            // Round 6
            set thistype.ids[6] = "2,5,14,2,15,5,14,2,"
            set thistype.amount[6] = "3,3,5,4,3,4,3,4,"
            set thistype.iterator[6] = 8
            
            // Round 7
            set thistype.ids[7] = "4,2,16,20,5,15,20,4,20,13,2,"
            set thistype.amount[7] = "3,3,3,1,3,3,2,3,3,3,3,"
            set thistype.iterator[7] = 11
            
            // Round 8
            set thistype.ids[8] = "4,16,3,15,4,17,15,3,17,3,"
            set thistype.amount[8] = "4,3,2,4,2,3,2,3,3,4,"
            set thistype.iterator[8] = 10
            
            // Round 9
            set thistype.ids[9] = "4,14,5,21,13,4,21,16,5,21,14,5,"
            set thistype.amount[9] = "4,4,1,1,3,4,1,4,2,1,2,3,"
            set thistype.iterator[9] = 12
            
            // Round 10
            set thistype.ids[10] = "2,21,16,4,20,16,2,21,16,22,4,20,16,4,"
            set thistype.amount[10] = "5,1,1,2,1,2,4,1,2,1,4,1,2,3,"
            set thistype.iterator[10] = 14
            
            // Round 11
            set thistype.ids[11] = "4,20,18,15,21,4,21,15,22,4,20,18,15,22,4,"
            set thistype.amount[11] = "5,1,1,3,1,4,1,3,1,3,1,1,1,1,3,"
            set thistype.iterator[11] = 15
            
            // Round 12
            set thistype.ids[12] = "3,16,23,21,18,3,23,17,21,3,23,18,17,3,"
            set thistype.amount[12] = "4,3,1,2,1,3,1,3,1,4,1,1,3,2,"
            set thistype.iterator[12] = 14
            
            // Round 13
            set thistype.ids[13] = "4,5,20,22,16,23,5,24,22,15,4,24,22,16,23,4,"
            set thistype.amount[13] = "2,4,2,1,2,1,3,1,1,3,2,1,1,2,2,2,"
            set thistype.iterator[13] = 16
            
            // Round 14
            set thistype.ids[14] = "2,25,22,2,18,16,22,2,18,25,16,2,22,16,2,"
            set thistype.amount[14] = "4,2,1,4,1,3,1,3,1,2,1,3,1,2,1,"
            set thistype.iterator[14] = 15
            
            // Round 15
            set thistype.ids[15] = "4,24,23,26,15,4,26,24,23,4,26,15,23,4"
            set thistype.amount[15] = "5,2,1,1,2,5,1,2,2,3,1,2,2,1,"
            set thistype.iterator[15] = 14
            
            // Round 16
            set thistype.ids[16] = "3,21,17,18,17,21,2,7,6,18,19,17,21,3,7,6,18,19,17,21,3,"
            set thistype.amount[16] = "4,1,1,1,2,1,1,2,1,1,2,1,1,1,1,2,1,1,1,1,3,"
            set thistype.iterator[16] = 21
            
            // Round 17
            set thistype.ids[17] = "1,8,13,5,21,8,23,5,23,21,13,1,"
            set thistype.amount[17] = "2,3,3,3,3,3,2,2,2,2,3,2,"
            set thistype.iterator[17] = 12
            
            // Round 18
            set thistype.ids[18] = "2,12,16,7,6,20,12,2,9,16,7,6,20,16,12,7,6,20,12,2,"
            set thistype.amount[18] = "2,2,1,1,1,1,2,2,1,2,2,2,1,1,2,1,1,1,2,2,"
            set thistype.iterator[18] = 20
            
            // Round 19
            set thistype.ids[19] = "4,14,10,25,22,4,26,18,10,26,22,3,18,14,10,14,3,"
            set thistype.amount[19] = "2,3,3,1,1,3,1,1,2,1,1,2,1,1,3,1,2,"
            set thistype.iterator[19] = 17
            
            // Round 20
            set thistype.ids[20] = "5,7,20,10,23,26,21,18,16,19,9,8,24,22,11,6,16,7,10,21,26,18,16,25,7,10,23,24,8,8,"
            set thistype.amount[20] = "1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[20] = 30
        endmethod
        
    endstruct
    
    struct SCC_Medium extends IRound
        
        implement Round
        
        method getRounds takes nothing returns integer
            return thistype.rounds
        endmethod
        
        method getIterator takes integer round returns integer
            return thistype.iterator[round]
        endmethod
        
        method getUnitIndex takes integer iterator, integer round returns integer
            return S2I(getDataFromString(thistype.ids[round], iterator))
        endmethod
        
        method getUnitAmount takes integer iterator, integer round returns integer
            return S2I(getDataFromString(thistype.amount[round], iterator))
        endmethod
        
        method getInterval takes nothing returns real
            return thistype.interval
        endmethod
        
        method getPause takes nothing returns real
            return thistype.pause
        endmethod
        
        method getCount takes nothing returns integer
            return thistype.count
        endmethod
        
        method getRoundTimer takes nothing returns real
            return thistype.roundTimer
        endmethod
        
        method getStartNextRound takes nothing returns integer
            return thistype.startNextRound
        endmethod
        
        static method onInit takes nothing returns nothing
            /* Base Information for this Mod */
            //Wie viele Runden?
            set thistype.rounds = 20
            //Nach welchem Rythmus werden die Einheiten pro Lane gespawnt?
            set thistype.interval = 1.0
            //Wie viele Creeps werden pro Intervall gespawnt?
            set thistype.count = 1
            //Wie lang ist die Rundenpause bevor die nächste Runde startet?
            set thistype.pause = 20.
            //Wie lang ist der Rundentimer, der oben rechts angezeigt wird, bevor die n. Runde gestartet wird?
            set thistype.roundTimer = 30.
            //Wann endet eine Runde? Wie viele Creeps müssen noch am Leben sein, damit eine Runde beendet wird?
            //Kurz: Abbruchbedingung für das Ende einer Runde! :)
            set thistype.startNextRound = 0
            
            // Round 1
            set thistype.ids[1] = "0,12,0,12,"
            set thistype.amount[1] = "7,3,7,3,"
            set thistype.iterator[1] = 4
            
            // Round 2
            set thistype.ids[2] = "0,12,1,13,"
            set thistype.amount[2] = "5,3,8,4,"
            set thistype.iterator[2] = 4
            
            // Round 3
            set thistype.ids[3] = "0,2,12,13,1,2,12,13,2,12,13,"
            set thistype.amount[3] = "2,2,2,1,3,2,1,2,2,1,2,"
            set thistype.iterator[3] = 11
            
            // Round 4
            set thistype.ids[4] = "1,13,3,13,3,14,"
            set thistype.amount[4] = "5,3,4,2,4,2,"
            set thistype.iterator[4] = 6
            
            // Round 5
            set thistype.ids[5] = "2,12,14,4,12,14,"
            set thistype.amount[5] = "6,2,2,6,2,2,"
            set thistype.iterator[5] = 6
            
            // Round 6
            set thistype.ids[6] = "5,2,15,14,5,2,15,14,"
            set thistype.amount[6] = "3,4,1,2,2,4,1,3,"
            set thistype.iterator[6] = 8
            
            // Round 7
            set thistype.ids[7] = "4,5,20,2,13,16,20,4,5,20,2,15,16,20,"
            set thistype.amount[7] = "2,1,1,2,2,1,1,2,1,1,2,2,1,1,"
            set thistype.iterator[7] = 14
            
            // Round 8
            set thistype.ids[8] = "4,3,15,16,4,3,17,16,15,"
            set thistype.amount[8] = "3,4,2,1,1,2,4,1,2,"
            set thistype.iterator[8] = 9
            
            // Round 9
            set thistype.ids[9] = "4,5,14,16,21,4,5,14,16,21,13,"
            set thistype.amount[9] = "2,2,2,1,1,3,2,2,2,1,2,"
            set thistype.iterator[9] = 11
            
            // Round 10
            set thistype.ids[10] = "2,4,16,22,4,2,20,21,16,"
            set thistype.amount[10] = "4,2,3,1,4,2,1,1,2,"
            set thistype.iterator[10] = 9
            
            // Round 11
            set thistype.ids[11] = "4,20,15,18,21,15,4,22,21,15,"
            set thistype.amount[11] = "5,1,3,1,1,1,5,1,1,1,"
            set thistype.iterator[11] = 10
            
            // Round 12
            set thistype.ids[12] = "3,16,21,23,17,18,3,21,17,23,16,"
            set thistype.amount[12] = "4,1,1,1,2,1,5,1,2,1,1,"
            set thistype.iterator[12] = 11
            
            // Round 13
            set thistype.ids[13] = "4,5,22,23,4,5,24,22,16,15,20,"
            set thistype.amount[13] = "2,2,1,3,2,2,1,1,3,2,1,"
            set thistype.iterator[13] = 11
            
            // Round 14
            set thistype.ids[14] = "2,25,2,16,22,18,25,2,25,2,22,16,"
            set thistype.amount[14] = "3,1,2,2,1,1,1,3,1,2,1,2,"
            set thistype.iterator[14] = 12
            
            // Round 15
            set thistype.ids[15] = "4,15,23,24,26,23,24,15,4,"
            set thistype.amount[15] = "5,1,2,1,2,1,2,2,4,"
            set thistype.iterator[15] = 9
            
            // Round 16
            set thistype.ids[16] = "3,7,19,6,18,17,22,7,19,6,18,17,22,3,"
            set thistype.amount[16] = "3,1,1,1,1,1,2,1,1,1,1,2,1,3,"
            set thistype.iterator[16] = 14
            
            // Round 17
            set thistype.ids[17] = "1,5,8,13,21,23,8,13,21,23,5,1,"
            set thistype.amount[17] = "2,1,2,2,2,1,2,2,1,2,2,1,"
            set thistype.iterator[17] = 12
            
            // Round 18
            set thistype.ids[18] = "2,6,7,16,20,9,12,7,16,20,6,12,"
            set thistype.amount[18] = "4,1,1,2,1,1,2,2,1,1,1,3,"
            set thistype.iterator[18] = 12
            
            // Round 19
            set thistype.ids[19] = "4,10,18,14,22,26,10,26,25,14,3,"
            set thistype.amount[19] = "3,3,1,2,1,1,2,1,1,2,3,"
            set thistype.iterator[19] = 11
            
            // Round 20
            set thistype.ids[20] = "5,16,23,7,25,8,18,10,26,24,11,22,9,16,7,26,10,6,23,16,"
            set thistype.amount[20] = "1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[20] = 20
        endmethod
        
    endstruct
    
    struct SCC_Full extends IRound
        
        implement Round
        
        method getRounds takes nothing returns integer
            return thistype.rounds
        endmethod
        
        method getIterator takes integer round returns integer
            return thistype.iterator[round]
        endmethod
        
        method getUnitIndex takes integer iterator, integer round returns integer
            return S2I(getDataFromString(thistype.ids[round], iterator))
        endmethod
        
        method getUnitAmount takes integer iterator, integer round returns integer
            return S2I(getDataFromString(thistype.amount[round], iterator))
        endmethod
        
        method getInterval takes nothing returns real
            return thistype.interval
        endmethod
        
        method getPause takes nothing returns real
            return thistype.pause
        endmethod
        
        method getCount takes nothing returns integer
            return thistype.count
        endmethod
        
        method getRoundTimer takes nothing returns real
            return thistype.roundTimer
        endmethod
        
        method getStartNextRound takes nothing returns integer
            return thistype.startNextRound
        endmethod
        
        static method onInit takes nothing returns nothing
            /* Base Information for this Mod */
            //Wie viele Runden?
            set thistype.rounds = 20
            //Nach welchem Rythmus werden die Einheiten pro Lane gespawnt?
            set thistype.interval = 1.0
            //Wie viele Creeps werden pro Intervall gespawnt?
            set thistype.count = 1
            //Wie lang ist die Rundenpause bevor die nächste Runde startet?
            set thistype.pause = 20.
            //Wie lang ist der Rundentimer, der oben rechts angezeigt wird, bevor die n. Runde gestartet wird?
            set thistype.roundTimer = 30.
            //Wann endet eine Runde? Wie viele Creeps müssen noch am Leben sein, damit eine Runde beendet wird?
            //Kurz: Abbruchbedingung für das Ende einer Runde! :)
            set thistype.startNextRound = 0
            
            // Round 1
            set thistype.ids[1] = "0,12,0,12,0,"
            set thistype.amount[1] = "2,1,2,2,3,"
            set thistype.iterator[1] = 5
            
            // Round 2
            set thistype.ids[2] = "0,12,1,13,1,13,1,0,"
            set thistype.amount[2] = "1,1,2,1,1,1,1,2,"
            set thistype.iterator[2] = 8
            
            // Round 3
            set thistype.ids[3] = "1,12,1,2,13,2,13,12,0,"
            set thistype.amount[3] = "1,1,1,2,1,1,1,1,1,"
            set thistype.iterator[3] = 9
            
            // Round 4
            set thistype.ids[4] = "1,3,14,3,13,1,"
            set thistype.amount[4] = "2,3,1,1,2,1,"
            set thistype.iterator[4] = 6
            
            // Round 5
            set thistype.ids[5] = "4,2,13,4,14,13,2,"
            set thistype.amount[5] = "1,1,1,2,2,1,2,"
            set thistype.iterator[5] = 7
            
            // Round 6
            set thistype.ids[6] = "2,12,5,15,5,14,2,"
            set thistype.amount[6] = "2,1,2,1,1,2,1,"
            set thistype.iterator[6] = 7
            
            // Round 7
            set thistype.ids[7] = "4,13,20,15,5,16,20,2,"
            set thistype.amount[7] = "2,1,1,1,1,1,1,2,"
            set thistype.iterator[7] = 8
            
            // Round 8
            set thistype.ids[8] = "4,4,15,3,17,17,3,15,16,3,"
            set thistype.amount[8] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[8] = 10
            
            // Round 9
            set thistype.ids[9] = "4,5,14,4,16,21,14,5,13,4,"
            set thistype.amount[9] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[9] = 10
            
            // Round 10
            set thistype.ids[10] = "2,4,2,15,22,16,20,4,2,4,"
            set thistype.amount[10] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[10] = 10
            
            // Round 11
            set thistype.ids[11] = "4,15,21,4,18,22,4,15,4,4,"
            set thistype.amount[11] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[11] = 10
            
            // Round 12
            set thistype.ids[12] = "3,16,17,3,23,18,21,17,3,3,"
            set thistype.amount[12] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[12] = 10
            
            // Round 13
            set thistype.ids[13] = "4,15,20,16,5,24,23,4,22,5,"
            set thistype.amount[13] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[13] = 10
            
            // Round 14
            set thistype.ids[14] = "2,2,16,2,25,18,22,16,2,2,"
            set thistype.amount[14] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[14] = 10
            
            // Round 15
            set thistype.ids[15] = "4,4,24,4,24,26,4,22,15,4,"
            set thistype.amount[15] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[15] = 10
            
            // Round 16
            set thistype.ids[16] = "3,7,21,18,6,19,3,21,17,3,"
            set thistype.amount[16] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[16] = 10
            
            // Round 17
            set thistype.ids[17] = "1,5,8,21,13,8,23,21,5,13,"
            set thistype.amount[17] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[17] = 10
            
            // Round 18
            set thistype.ids[18] = "2,12,16,9,6,7,20,7,12,2,"
            set thistype.amount[18] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[18] = 10
            
            // Round 19
            set thistype.ids[19] = "3,10,14,25,10,18,22,10,26,14,"
            set thistype.amount[19] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[19] = 10
            
            // Round 20
            set thistype.ids[20] = "7,8,10,22,26,11,6,18,24,23,"
            set thistype.amount[20] = "1,1,1,1,1,1,1,1,1,1,"
            set thistype.iterator[20] = 10
        endmethod
        
    endstruct

endscope
