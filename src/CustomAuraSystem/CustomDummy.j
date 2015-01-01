library CustomDummy
    
    globals
        constant integer CD_UNIT_ID = 'h00R'
    endglobals
    
    function CreateDummy takes player p, real x, real y returns unit
        return CreateUnit(p, CD_UNIT_ID, x, y, 0.)
    endfunction
    
endlibrary