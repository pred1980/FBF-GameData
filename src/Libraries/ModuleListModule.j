library ModuleListModule

    module ModuleList
        private static boolean m_destroying = false
        private boolean m_inlist = false
        
        readonly static integer m_count = 0
        
        readonly thistype m_next = 0
        readonly thistype m_prev = 0
        
        static method operator m_first takes nothing returns thistype
            return thistype(0).m_next
        endmethod
        
        static method operator m_last takes nothing returns thistype
            return thistype(0).m_prev
        endmethod
        
        method m_listRemove takes nothing returns nothing
            if not m_inlist then
                return
            endif
            set m_inlist = false
            set m_prev.m_next = m_next
            set m_next.m_prev = m_prev
            set m_count = m_count - 1
        endmethod

        method m_listAdd takes nothing returns nothing
            if m_inlist or m_destroying then
                return
            endif
            set m_inlist = true
            set m_last.m_next = this
            set m_prev = m_last
            set thistype(0).m_prev = this
            set m_count = m_count + 1
        endmethod
        
        static method m_listDestroy takes nothing returns nothing
            local thistype this = m_last
                set m_destroying = true
                loop
                    exitwhen this == 0
                    call destroy()
                    set this = m_prev
                endloop
                set m_destroying = false
        endmethod
        
    endmodule

endlibrary