library ZUtils

    globals
        private location loc = Location(0.00, 0.00)
    endglobals
    
    function GetTerrainZ takes real x, real y returns real
        call MoveLocation(loc, x, y)
        return GetLocationZ(loc)
    endfunction
    
    function GetUnitZ takes unit u returns real
        return GetUnitFlyHeight(u)
    endfunction
    
    function SetUnitZ takes unit u, real height returns nothing
        call SetUnitFlyHeight(u, height, 0.00)
    endfunction

endlibrary