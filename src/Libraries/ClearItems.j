library ClearItems initializer init requires TimerUtils

/*
    This library fixes the leak and the lag caused by unremoved items,
    including powerups and manually-destroyed items.

    The dead items are periodically removed. You can adjust the period by changing
    the constant CLEANING_PERIOD. Note that items' death animations need some time
    to play so adjust the DEATH_TIME delay accordingly.

    If you don't know exactly what you are doing, you shouldn't change the life
    of a dead item; the items are no longer usable after their death but
    you can still change their life.  If you set their life to more than 0.405,
    they won't be properly cleaned. You should also remove items manually
    if you kill them when they are carried by a unit.
*/

    globals
        // Interval between item-cleanups.
        private constant real CLEANING_PERIOD = 5.0

        // Time for the item's death animation; optimized for tomes and runes.
        private constant real DEATH_TIME = 1.5
    endglobals
    
    private struct object
        item Item
    endstruct
    
    globals
        private object obj
        private timer tim
    endglobals

    private function DeleteItem takes nothing returns nothing
        set tim = GetExpiredTimer()
        set obj = GetTimerData(tim)
        call ReleaseTimer(tim)
        call SetWidgetLife(obj.Item, 1.0)
        call RemoveItem(obj.Item)
        set obj.Item = null
        call obj.destroy()
    endfunction

    private function CleanItems takes nothing returns boolean
        if (GetWidgetLife(GetFilterItem()) < 0.405) then
            set tim = NewTimer()
            set obj = object.create()
            set obj.Item = GetFilterItem()
            call SetTimerData(tim, integer(obj))
            call TimerStart(tim, DEATH_TIME, false, function DeleteItem)
        endif
        return false
    endfunction
    
    globals
        private rect WorldBounds = null
        private filterfunc Detect = null
    endglobals
    
    private function SweepItems takes nothing returns nothing
        call EnumItemsInRect(WorldBounds, Detect, null)
    endfunction

    private function init takes nothing returns nothing
        call TimerStart(CreateTimer(), CLEANING_PERIOD, true, function SweepItems)
        set WorldBounds = GetWorldBounds()
        set Detect = Filter(function CleanItems)
    endfunction

endlibrary