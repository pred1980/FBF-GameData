library ForsakenDefenseSystem

    module DefenseMode
        static integer id //Defense Mod Id
        static string name //Name of the Defense Mod
        static string desc //Description of the Defense Mod
        static integer unitCounter //Counter for Creeps
    endmodule
    
    interface IDefenseMode
        method getId takes nothing returns integer 
        method getName takes nothing returns string
        method getDesc takes nothing returns string
        method setUnitCounter takes integer value returns nothing
        method getUnitCounter takes nothing returns integer
    endinterface
    
endlibrary