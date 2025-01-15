//############################## ~IndexerUtils ##################################//
//##
//## Version:       1.0
//## System:        Axarion
//## AutoIndex:     grim001
//## AIDS:          Jesus4Lyf
//## UnitIndexer:   Nestharus
//##
//############################### DESCRIPTION ###################################//
//##
//## This system combines the Enter- and Leave-Events of AutoIndex, AIDS and 
//## UnitIndexer. I made this to save some time when doing systems which should
//## be compatible with all indexers.
//## 
//############################### HOW DOES IT WORK ##############################//
//## 
//## To use this system create a struct and implement the IndexerUtils module.   
//## 
//################################# METHODS #####################################//
//##   
//##    You can implement these functions into your struct. They are 
//##    all optional. 
//##
//##    - happens when a unit enters which has the ability.
//##        static method onIndex takes unit u returns nothing
//## 
//##    - happens when a unit leaves the map with the ability    
//##        static method onDeindex takes unit u returns nothing
//##
//##    - defines for which units the event should be fired:
//##        static method onFilter takes unit u returns boolean
//##
//################################################################################//

library IndexerUtils requires optional UnitIndexer, optional AutoIndex, optional AIDS //one is required!

module IndexerUtils 
    
    //for AIDS
    static if LIBRARY_AIDS then
    
        static if thistype.onUnitDeindex.exists then
            private static method onUnitDeindexed takes nothing returns boolean
                static if thistype.onFilter.exists then
                    if thistype.onFilter(u) then
                        call thistype.onUnitDeindex(GetIndexUnit(AIDS_GetDecayingIndex()))
                    endif
                else
                    call thistype.onUnitDeindex(GetIndexUnit(AIDS_GetDecayingIndex()))
                endif
                return false
            endmethod
        endif
        
        static if thistype.onUnitIndex.exists then
            private static method onUnitIndexed takes nothing returns boolean
                static if thistype.onFilter.exists then
                    if thistype.onFilter(u) then
                        call thistype.onUnitIndex(AIDS_GetEnteringIndexUnit())
                    endif
                else
                    call thistype.onUnitIndex(AIDS_GetEnteringIndexUnit())
                endif
                return false
            endmethod
        endif
        
        static if thistype.onUnitIndex.exists then
            static if thistype.onUnitDeindex.exists then
                private static method onInit takes nothing returns nothing
                    call AIDS_RegisterOnDeallocate(Condition(function thistype.onUnitDeindexed))
                    call AIDS_RegisterOnEnter (Condition(function thistype.onUnitIndexed))
                endmethod
            else
                private static method onInit takes nothing returns nothing
                    call AIDS_RegisterOnEnter (Condition(function thistype.onUnitIndexed))
                endmethod
            endif
        elseif thistype.onUnitDeindex.exists then
            private static method onInit takes nothing returns nothing
                call AIDS_RegisterOnDeallocate(Condition(function thistype.onUnitDeindexed))
            endmethod
        endif
    
    //for AutoIndex
    elseif LIBRARY_AutoIndex then
        
        static if thistype.onUnitDeindex.exists then
            private static method onUnitDeindexed takes unit u returns nothing
                static if thistype.onFilter.exists then
                    if thistype.onFilter(u) then
                        call thistype.onUnitDeindex(u)
                    endif
                else
                    call thistype.onUnitDeindex(u)
                endif
            endmethod
        endif
        
        static if thistype.onUnitIndex.exists then
            private static method onUnitIndexed takes unit u returns nothing
                static if thistype.onFilter.exists then
                    if thistype.onFilter(u) then
                        call thistype.onUnitIndex(u)
                    endif
                else
                    call thistype.onUnitIndex(u)
                endif
            endmethod
        endif
        
        static if thistype.onUnitIndex.exists then
            static if thistype.onUnitDeindex.exists then
                private static method onInit takes nothing returns nothing
                    call OnUnitDeindexed(thistype.onUnitDeindexed)
                    call OnUnitIndexed(thistype.onUnitIndexed)
                endmethod
            else
                private static method onInit takes nothing returns nothing
                    call OnUnitIndexed(thistype.onUnitIndexed)
                endmethod
            endif
        elseif thistype.onUnitDeindex.exists then
            private static method onInit takes nothing returns nothing
                call OnUnitDeindex  (Condition(function thistype.onUnitIndexed))
            endmethod
        endif

    // for UnitIndexer
    elseif LIBRARY_UnitIndexer then
        
        static if thistype.onUnitDeindex.exists then
            private static method onUnitDeindexed takes nothing returns boolean
                static if thistype.onFilter.exists then
                    if thistype.onFilter(u) then
                        call thistype.onUnitDeindex(GetIndexedUnit())
                    endif
                else
                    call thistype.onUnitDeindex(GetIndexedUnit())
                endif
                return false
            endmethod
        endif
        
        static if thistype.onUnitIndex.exists then
            private static method onUnitIndexed takes nothing returns boolean
                static if thistype.onFilter.exists then
                    if thistype.onFilter(u) then
                        call thistype.onUnitIndex(GetIndexedUnit())
                    endif
                else
                    call thistype.onUnitIndex(GetIndexedUnit())
                endif
                return false
            endmethod
        endif
        
        static if thistype.onUnitIndex.exists then
            static if thistype.onUnitDeindex.exists then
                private static method onInit takes nothing returns nothing
                    call OnUnitDeindex(Condition(function thistype.onUnitDeindexed))
                    call OnUnitIndex  (Condition(function thistype.onUnitIndexed))
                endmethod
            else
                private static method onInit takes nothing returns nothing
                    call OnUnitIndex  (Condition(function thistype.onUnitIndexed))
                endmethod
            endif
        elseif thistype.onUnitDeindex.exists then
            private static method onInit takes nothing returns nothing
                call OnUnitDeindex  (Condition(function thistype.onUnitIndexed))
            endmethod
        endif
    endif
endmodule

endlibrary