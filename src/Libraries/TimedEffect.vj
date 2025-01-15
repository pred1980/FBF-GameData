library TimedEffect /* v1.4
*************************************************************************************
*
*    Allows one to create timed effects on 3d points or units.
*
*************************************************************************************
*
*    API
*
*    static method createOnPoint takes string mdl, real x, real y, real z, real duration returns thistype
*        - starts a timed effect on a 3d point
*
*    static method createOnUnit takes string mdl, unit u, string attach, real duration returns thistype
*        - starts a timed effect on a unit
*
*    method destroy takes nothing returns nothing
*        - destroys an instance
*
*************************************************************************************
*
*    Credits
*
*       PurgeAndFire for the OTip trick.
*       Bannar
*
**************************************************************************************/
    struct TimedEffect extends array
        private static timer t = CreateTimer()
       
        private static thistype instance = 0
        private static integer count = 0

        private static effect tempEffect
        private static destructable platform
        private thistype recycle
        private thistype next
        private thistype prev
       
        private effect effects
        public real time

        method destroy takes nothing returns nothing
            call DestroyEffect(effects)
            set effects = null
            set time = 0
            set prev.next = next
            set next.prev = prev
            set recycle = thistype(0).recycle
            set thistype(0).recycle = this
            set count = count - 1
            if 0 == count then
                call PauseTimer(t)
            endif
        endmethod
       
        private static method periodic takes nothing returns nothing
            local thistype this = thistype(0).next
            loop
                exitwhen 0 == this
                set time = time - 0.031250000
                if 0 >= time then
                    call destroy()
                endif
                set this = next
            endloop
        endmethod
       
        private static method allocate takes nothing returns thistype
            local thistype this = thistype(0).recycle
            if 0 == this then
                set this = instance + 1
                set instance = this
            else
                set thistype(0).recycle = recycle
            endif
            set next = 0
            set prev = thistype(0).prev
            set thistype(0).prev.next = this
            set thistype(0).prev = this
            set count = count + 1
            if 1 == count then
                call TimerStart(t, 0.031250000, true, function thistype.periodic)
            endif
            return this
        endmethod
       
        static method createOnPoint takes string mdl, real x, real y, real z, real duration returns thistype
            local thistype this
            if 0 < z then
                set platform = CreateDestructableZ('OTip', x, y, z, 0, 1, 0)
            endif
            set tempEffect = AddSpecialEffect(mdl, x, y)
            if null != platform then
                call RemoveDestructable(platform)
            endif
            if duration >= 0.031250000 then
                set this = allocate()
                set time = duration
                set effects = tempEffect
                return this
            endif
            call DestroyEffect(tempEffect)
            set tempEffect = null
            return 0
        endmethod
       
        static method createOnUnit takes string mdl, unit u, string attach, real duration returns thistype
            local thistype this
            set tempEffect = AddSpecialEffectTarget(mdl, u, attach)
            if duration >= 0.031250000 then
                set this = allocate()
                set effects = tempEffect
                set time = duration
                return this
            endif
            call DestroyEffect(tempEffect)
            set tempEffect = null
            return 0
        endmethod
    endstruct
endlibrary