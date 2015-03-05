//===========================================================================
// RECT UTILS v 1.2 By Wareditor - 21 / 07 / 12
//===========================================================================
// 
//  AIM : 
// 
//      * Add GetTriggeringRect()
//      * Attach id to saved rect
//      * Easy "gate" system
// 
//  API : 
// 
//      FUNCTIONS : 
//      * call SaveRect( rect, id )
//          - Save a rect and attach a id to it.
//            The GetTriggeringRect will only work with saved rect
//
//      * call ReleaseRect( rect )
//          - Release a saved rect
//
//      * call RegionAddRectSaved( region, rect )
//          - Add a saved rect to a region
//            If you use the native, it will break the system in certain condition
//
//      * call SetRectId( rect, id )
//          - Change the id of a saved rect
//
//      * call GetRectId( rect )
//          - Return the id of the rect
//  
//      * call GetTriggeringRect()
//          - Return the triggering rect of a Unit Enters Event and Leaves Event
// 
//  COMMENTARY : 
// 
//      * Please give credits
// 
//  REQUIRES : 
// 
//      * vJass + New Jass Helper 
// 
// 
//===========================================================================
// Enjoy 
//===========================================================================
 
library RectUtils initializer Init
 
    //===========================================================================
    // GLOBALS - NO TOUCH
    //===========================================================================
    
    globals
    
        private hashtable hash
        private region TriggerRegion = null
        private trigger Trig = CreateTrigger()
    
    endglobals
    
    //===========================================================================
    // GET TRIGGERING RECT
    //===========================================================================
    
    function GetTriggeringRect takes nothing returns rect
        return LoadRectHandle(hash, 1, GetHandleId(TriggerRegion))
    endfunction
    
    private function EnterLeave takes nothing returns nothing
        set TriggerRegion = GetTriggeringRegion()
    endfunction
    
    
    //===========================================================================
    // ID
    //===========================================================================
    
    function SetRectId takes rect r, integer id returns nothing
        call SaveInteger(hash, 0, GetHandleId(r), id)
    endfunction
    
    function GetRectId takes rect r returns integer
        return LoadInteger(hash, 0, GetHandleId(r))
    endfunction
    
    //===========================================================================
    // SAVE
    //===========================================================================
    
    function Saved takes rect r returns boolean
        return LoadRegionHandle(hash, 2, GetHandleId(r)) != null
    endfunction
    
    function SaveRect takes rect r, integer id returns nothing
    
        local region reg
    
        if LoadRegionHandle(hash, 2, GetHandleId(r)) == null then
        
            set reg = CreateRegion()
            call RegionAddRect(reg, r)
            call SaveInteger(hash, 0, GetHandleId(r), id)
            call SaveRectHandle(hash, 1, GetHandleId(reg),  r)
            call SaveRegionHandle(hash, 2, GetHandleId(r),  reg)
            call TriggerRegisterEnterRegion(Trig, reg, null)
            call TriggerRegisterLeaveRegion(Trig, reg, null)
            
        endif
        
    endfunction
        
    function ReleaseRect takes rect r returns nothing
        
        local integer i
        local region reg
        
        if LoadRegionHandle(hash, 2, GetHandleId(r)) != null then
        
            set reg = LoadRegionHandle(hash, 2, GetHandleId(r))
            call RegionClearRect(reg, r)
            call RemoveSavedInteger(hash, 0, GetHandleId(r))
            call RemoveSavedHandle(hash, 1, GetHandleId(reg))
            call RemoveSavedHandle(hash, 2, GetHandleId(r))
            
        endif
        
    endfunction
    
    function RegionAddRectSaved takes region whichRegion, rect r returns nothing
    
        local region reg = LoadRegionHandle(hash, 2, GetHandleId(r))
    
        if reg != null then
            call RegionAddRect(whichRegion, r)
            call RegionClearRect(reg, r)//May seem useless but no
            call RegionAddRect(reg, r)
        endif
    
    endfunction
    
    //===========================================================================
    // INITALIZATION
    //===========================================================================
 
    private function Init takes nothing returns nothing
        set hash = InitHashtable()
        call TriggerAddAction(Trig, function EnterLeave)
    endfunction
    
endlibrary
 
//===========================================================================
// WAREDITOR.TLJ @ GMAIL.COM
//===========================================================================