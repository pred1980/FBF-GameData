library TableBC requires Table
/*
    Backwards-compatibility add-on for scripts employing Vexorian's Table.

    Added 31 July 2015: introduced static method operator [] and
    static method flush2D for Table, HandleTable and StringTable. Now,
    almost all of the Vexorian API has been replicated (minus the .flush paradox).

    The Table library itself was unchanged to implement these
    enhancements, so you need only update this library to experience the
    improved syntax compatibility.
   
    Disclaimer:
   
    The following error does not occur with HandleTables & StringTables, only
    with the standard, integer-based Table, so you do not need to make any
    changes to StringTable/HandleTable-employing scripts.
   
    The this.flush(key) method from the original Table cannot be parsed with
    the new Table. For the scripts that use this method, they need to be up-
    dated to use the more fitting this.remove(key) method.
   
    Please don't try using StringTables/HandleTables with features exclusive
    to the new Table as they will cause syntax errors. I do not have any plan
    to endorse these types of Tables because delegation in JassHelper is not
    advanced enough for three types of Tables without copying every single
    method over again (as you can see this already generates plenty of code).
    StringTable & HandleTable are wrappers for StringHash & GetHandleId, so
    just type them out.
*/

//! textmacro TABLE_BC_METHODS
    method reset takes nothing returns nothing
        call this.flush()
    endmethod
    method exists takes integer key returns boolean
        return this.has(key)
    endmethod
    static method operator [] takes string id returns Table
        local integer index = StringHash(id)
        local Table t = Table(thistype.typeid)[index]
        if t == 0 then
            set t = Table.create()
            set Table(thistype.typeid)[index] = t
        endif
        return t
    endmethod
    static method flush2D takes string id returns nothing
        local integer index = StringHash(id)
        local Table t = Table(thistype.typeid)[index]
        if t != 0 then
            call t.destroy()
            call Table(thistype.typeid).remove(index)
        endif
    endmethod
//! endtextmacro

//! textmacro TABLE_BC_STRUCTS
struct HandleTable extends array
    static method operator [] takes string index returns thistype
        return Table[index]
    endmethod
    static method flush2D takes string index returns nothing
        call Table.flush2D(index)
    endmethod
    method operator [] takes handle key returns integer
        return Table(this)[GetHandleId(key)]
    endmethod
    method operator []= takes handle key, integer value returns nothing
        set Table(this)[GetHandleId(key)] = value
    endmethod
    method flush takes handle key returns nothing
        call Table(this).remove(GetHandleId(key))
    endmethod
    method exists takes handle key returns boolean
        return Table(this).has(GetHandleId(key))
    endmethod
    method reset takes nothing returns nothing
        call Table(this).flush()
    endmethod
    method destroy takes nothing returns nothing
        call Table(this).destroy()
    endmethod
    static method create takes nothing returns thistype
        return Table.create()
    endmethod
endstruct

struct StringTable extends array
    static method operator [] takes string index returns thistype
        return Table[index]
    endmethod
    static method flush2D takes string index returns nothing
        call Table.flush2D(index)
    endmethod
    method operator [] takes string key returns integer
        return Table(this)[StringHash(key)]
    endmethod
    method operator []= takes string key, integer value returns nothing
        set Table(this)[StringHash(key)] = value
    endmethod
    method flush takes string key returns nothing
        call Table(this).remove(StringHash(key))
    endmethod
    method exists takes string key returns boolean
        return Table(this).has(StringHash(key))
    endmethod
    method reset takes nothing returns nothing
        call Table(this).flush()
    endmethod
    method destroy takes nothing returns nothing
        call Table(this).destroy()
    endmethod
    static method create takes nothing returns thistype
        return Table.create()
    endmethod
endstruct
//! endtextmacro

endlibrary