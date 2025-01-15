library MeteorSystemAutomizer requires MeteorSystem
	/*
	 * Basically this system automizes looped meteor creation for you...
	 * And gives you the ability to easily create meteors over a period of time
	 * So instead of making your own loop to create meteors over time you just need to call
	 * the creation function here which is pretty similar to the Meteor creation
	 * but takes three additional parameters
	 * call AutoMeteor.MeteorAutoCreate(unit caster, integer totalmeteors, integer meteorsperloop, 
	 * real looptime, real scale, real damage, real x, real y, real radius,  real dradius, real speed , 
	 * real acc, real height, real timedelay, string mfx, string hfx, player owner, attacktype at, 
	 * damagetype dt, boolean random)
	 * Where:
	 * integer totalmeteors = total number of meteors to be created
	 * integer meteorsperloop = number of meteors created every real looptime
	 * real looptime = interval in which meteors will be created
	 * the other parameters are the same as those in the MeteorSystem (see MeteorSystem for details about them)
	 */
    globals
        private timer AUTO_M_T = CreateTimer()
        private constant real TICK = .03
        private integer TOTAL = 0
        private integer array AUTO_M
    endglobals

    struct AutoMeteor
        real x
        real y
        real height
        real radius
        real dradius
        unit caster
        real scale
        player owner
        real damage
        damagetype dt
        attacktype at
        real speed
        real acc
        string mfx
        string hfx
        real timedelay
        integer mps
        integer tmc
        real looptime
        real ctime
        boolean random
        static thistype data
        
        static method MeteorAutoLoop takes nothing returns nothing
            local integer i = 0
            local integer a = 1
            loop
                exitwhen i == TOTAL
                set data = AUTO_M[i]
                set data.ctime = data.ctime - TICK
                if data.ctime <= 0.00 then
                    set data.ctime = data.looptime
                    set data.tmc = data.tmc - data.mps
                    loop
                        exitwhen a > data.mps
                        call MSStart(data.caster, data.scale, data.damage, data.x, data.y, data.radius, data.dradius, data.speed, data.acc, data.height, data.timedelay, data.mfx, data.hfx, data.owner, data.at, data.dt, data.random)
                        set a = a + 1
                    endloop
                    set a = 1
                endif
                if data.tmc <= 0 then
                    set TOTAL = TOTAL - 1
                    set AUTO_M[i] = AUTO_M[TOTAL]
                    set i = i - 1
                    call data.destroy()
                endif
                set i = i + 1
            endloop
            if TOTAL == 0 then
                call PauseTimer(AUTO_M_T)
            endif
        endmethod
        
        static method MeteorAutoCreate takes unit caster, integer totalmeteors, integer meteorsperloop, real looptime, real scale, real damage, real x, real y, real radius,  real dradius, real speed , real acc, real height, real timedelay, string mfx, string hfx, player owner, attacktype at, damagetype dt, boolean random returns nothing
            set data = AutoMeteor.create()
            set AUTO_M[TOTAL] = data
            set TOTAL = TOTAL + 1
            set data.caster = caster
            set data.tmc = totalmeteors
            set data.mps = meteorsperloop
            set data.looptime = looptime
            set data.ctime = looptime
            set data.scale = scale
            set data.damage = damage
            set data.x = x
            set data.y = y
            set data.radius = radius
            set data.dradius = dradius
            set data.speed = speed
            set data.acc = acc
            set data.height = height
            set data.timedelay = timedelay
            set data.owner = owner
            set data.mfx = mfx
            set data.hfx = hfx
            set data.at = at
            set data.dt = dt
            set data.random = random
            if TOTAL == 1 then
                call TimerStart(AUTO_M_T, TICK, true, function AutoMeteor.MeteorAutoLoop)
            endif
        endmethod
        
    endstruct
endlibrary

