library PruneGroup

//*****************************************************************
//*  PruneGroup
//*  written by: Anitarf
//*
//*  PruneGroup is a function that removes units from a group based
//*  on a user-specified fitness function.
//*
//*    function PruneGroup takes group g, Fitness Function, integer maxUnits, real minFitness returns nothing
//*
//*  The fitness function must follow the Fitness function 
//*  interface that is defined at the start of this library. The
//*  value it returns specifies a unit's fitness, the units with a
//*  higher value will remain in the group while the units with a
//*  lower fitness will be removed from it.
//*  The maxUnits argument specifies at most how many units may
//*  remain in the group, but the actual number may be lower if the
//*  group didn't have that many units in it to begin with or if
//*  too few units had a fitness higher than minFitness, the last
//*  argument of the PruneGroup function.
//*  The fitness limit can be disabled with the NO_FITNESS_LIMIT
//*  constant value defined in the calibration section, this way
//*  you can prune a group based only on the unit limit.
//*****************************************************************

    // This is the function interface for the fitness functions.
    public function interface Fitness takes unit u returns real

    globals
        // If this constant is passed to the PruneGroup function it will ignore the fitness limit.
        // This is a random value that is unlikely to be ever used, you don't really need to change it.
        constant real NO_FITNESS_LIMIT = -112358.13
    endglobals

// END OF CALIBRATION SECTION    
// ================================================================

    globals
        private Fitness func=0
        private integer maxcount=0
        private real minfit=0.0
        private boolean ignoreminfit=false
        
        private unit array fittest
        private real array fitness
        private integer array next
        private integer last=0
        private integer count=0
        private integer N=0
    endglobals

    private function Enum takes nothing returns nothing
        local unit u=GetEnumUnit()
        local real fit=func.evaluate(u)
        local integer i
        local integer j
        // Check if we should bother adding the unit to the list.
        if (ignoreminfit or fit>minfit) and (count<maxcount or fit>fitness[last]) then
            // Get a new index and store the unit.
            set N=N+1
            set count=count+1
            set fittest[N]=u
            set fitness[N]=fit
            // Add the index to the sorted list.
            if last==0 or fit<fitness[last] then
                set next[N]=last
                set last=N
            else
                set i=last
                loop
                    set j=next[i]
                    exitwhen j==0 or fitness[j]>=fit
                    set i=j
                endloop
                set next[N]=next[i]
                set next[i]=N
            endif
            // Remove the last unit from the list if needed.
            if count>maxcount then
                set last=next[last]
                set count=count-1
            endif
        endif
        set u=null
    endfunction

// ================================================================

    function PruneGroup takes group g, Fitness Function, integer maxUnits, real minFitness returns nothing
        // Remember the previous values in case this is interrupting another PruneGroup call.
        local Fitness f=func
        local integer mc=maxcount
        local real mf=minfit
        local integer l=last
        local integer c=count
        local integer n=N
        // Take care of faulty inputs.
        if maxUnits<=0 then
            call GroupClear(g)
            return
        endif
        // Populate the sorted list.
        set count=0
        set last=0
        set minfit=minFitness
        set maxcount=maxUnits
        set ignoreminfit=minfit==NO_FITNESS_LIMIT
        set func=Function
        call ForGroup(g, function Enum)
        // Repopulate the group from the list.
        call GroupClear(g)
        loop
            exitwhen last==0
            call GroupAddUnit(g, fittest[last])
            set last=next[last]
        endloop
        // Cleanup handle references.
        loop
            exitwhen N==n
            set fittest[N]=null
            set N=N-1
        endloop
        // Return the temporary globals to their previous values.
        set func=f
        set minfit=mf
        set maxcount=mc
        set ignoreminfit=minfit==NO_FITNESS_LIMIT
        set count=c
        set last=l
    endfunction

endlibrary