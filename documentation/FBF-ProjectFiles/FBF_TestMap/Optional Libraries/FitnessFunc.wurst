library FitnessFunc requires PruneGroup

//*****************************************************************
//*  FITNESS FUNCTIONS
//*  written by: Anitarf
//*  requires: -PruneGroup
//*
//*  This is a set of functions intended to be used as fitness
//*  functions for PruneGroup calls, so they all take a unit
//*  parameter and return a real in accordance with the Fitness
//*  function interface. The functions provided cover most basic
//*  criteria according to which users might want to sort units.
//*  The functions are:
//*
//*  FitnessFunc_LowLife - favours units with low life
//*  FitnessFunc_HighLife - favours units with high life
//*  FitnessFunc_LowMaxLife - favours units with low max life
//*  FitnessFunc_HighMaxLife - favours units with high max life
//*  FitnessFunc_LowMana - favours units with low mana
//*  FitnessFunc_HighMana - favours units with high mana
//*  FitnessFunc_LowMaxMana - favours units with low max mana
//*  FitnessFunc_HighMaxMana - favours units with high max mana
//*  FitnessFunc_LowDistance - favours units closer to a point
//*  FitnessFunc_HighDistance - favours units further away from a point
//*
//*  The last two functions need to have a point defined before
//*  they can be used as a fitness function for PruneGroup, to
//*  define a point use the following function:
//*
//*    function SetFitnessPosition takes real x, real y returns nothing
//*****************************************************************

    //! textmacro PruneFitness_UnitState takes name, state
    public function Low$name$ takes unit u returns real
        return -GetUnitState(u, $state$)
    endfunction
    public function High$name$ takes unit u returns real
        return GetUnitState(u, $state$)
    endfunction
    //! endtextmacro

    //! runtextmacro PruneFitness_UnitState("Life", "UNIT_STATE_LIFE")
    //! runtextmacro PruneFitness_UnitState("Mana", "UNIT_STATE_MANA")
    //! runtextmacro PruneFitness_UnitState("MaxLife", "UNIT_STATE_MAX_LIFE")
    //! runtextmacro PruneFitness_UnitState("MaxMana", "UNIT_STATE_MAX_MANA")

// ================================================================

    globals
        private real X=0.0
        private real Y=0.0
    endglobals
    function SetFitnessPosition takes real x, real y returns nothing
        set X=x
        set Y=y
    endfunction

    public function LowDistance takes unit u returns real
        local real x = GetUnitX(u)-X
        local real y = GetUnitY(u)-Y
        return -x*x-y*y
    endfunction
    public function HighDistance takes unit u returns real
        local real x = GetUnitX(u)-X
        local real y = GetUnitY(u)-Y
        return x*x+y*y
    endfunction

endlibrary