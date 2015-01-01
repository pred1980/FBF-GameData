/* ----------------------------------- *//*
    Version: 0.1
    Author: Anachron
    Date: 13th Dec 2009
    
    Release information:
    Do not use this library without 
    copyright information.
    
    Copyright 2009
    
    Requirements:
     * Table
    
    What this module does:
    Adds the ability to save/load/remove
    object instances.
*/
/* ----------------------------------- */

module CAIndex
    public  static      Table     INSTANCES = 0
    public  integer     ID                  = 0

    private static method onInit takes nothing returns nothing
        set thistype.INSTANCES = Table.create()
    endmethod

    public method save takes nothing returns nothing
        set thistype.INSTANCES[.ID] = integer(this)
    endmethod
    
    public method remove takes nothing returns nothing
        call thistype.INSTANCES.remove(.ID)
        //call thistype.INSTANCES.flush(.ID)
        call .destroy()
    endmethod
    
    public method clear takes nothing returns nothing
        call thistype.INSTANCES.remove(.ID)
        //call thistype.INSTANCES.flush(.ID)
    endmethod
    
    public static method load takes integer id returns thistype
        return thistype(thistype.INSTANCES[id])
    endmethod
endmodule