library CenariusMain requires ListModule, IntuitiveBuffSystem, Table

    globals
        private constant integer ENTANGLE_BUFF_PLACER_ID = 'A08C'
        private constant integer ENTANGLE_BUFF_ID = 'B01N'
    endglobals

    private keyword Entangle

    struct Entangle
    
        static integer buffType = 0
        unit target = null
        dbuff buff = 0
        
        method onDestroy takes nothing returns nothing
            call DisableUnit(target, false)
        endmethod
    
        static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod
        
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            
            if b.isRefreshed then
                //Destroying old data
                call thistype(b.data).destroy()
            endif
            
            set this = allocate()
            set b.data = integer(this)
            set target = b.target
            set buff = b
            call DisableUnit(target, true)
        endmethod

        static method apply takes unit source, unit target, real duration, integer lvl returns nothing
            call UnitAddBuff(source, target, buffType, duration, lvl)
        endmethod
        
        static method onInit takes nothing returns nothing
            set buffType = DefineBuffType(ENTANGLE_BUFF_PLACER_ID, ENTANGLE_BUFF_ID, 0.00, false, false, thistype.onBuffAdd, 0, thistype.onBuffEnd)
        endmethod

    endstruct

    public function EntangleUnit takes unit source, unit target, real duration, integer lvl returns nothing
        call Entangle.apply(source, target, duration, lvl + 1)
    endfunction
    
    public function IsUnitEntangled takes unit target returns boolean
        return UnitHasBuff(target, Entangle.buffType)
    endfunction

endlibrary