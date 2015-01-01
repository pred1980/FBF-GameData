library CreepSystemRounds requires MiscFunctions

    module Round
        static string array ids
        static string array amount //How many Creeps should be spawn per Id?
        static integer array iterator //Need for the amount of creep types
        static integer count //How many spawns per Creep Unit
        static integer rounds //How many Rounds
        static real interval //delay between each spawned unit
        static real pause // Pause between every round
        static real roundTimer // Rount Timer before a new round starts
        static integer startNextRound //Abbruchbedingung f?r das Ende einer Runde
    endmodule
    
    interface IRound
        method getRounds takes nothing returns integer 
        method getIterator takes integer round returns integer
        method getUnitIndex takes integer iterator, integer round returns integer
        method getUnitAmount takes integer iterator, integer round returns integer
        method getInterval takes nothing returns real
        method getPause takes nothing returns real
        method getRoundTimer takes nothing returns real
        method getCount takes nothing returns integer
        method getStartNextRound takes nothing returns integer
     endinterface
    
endlibrary