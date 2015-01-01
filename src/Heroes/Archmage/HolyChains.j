scope HolyChains initializer init
    /*
     * Description: The Archmage casts Holy Chains in the targeted direction, damaging every enemy unit in the spellss path.
     * Last Update: 28.11.2013
     * Changelog: 
     *     28.11.2013: Abgleich mit OE und der Exceltabelle
	 *
	 * Info: 
	 *     15.05.2013: Tab.flush(key) durch  Tab.remove(key) ersetzt da ich die neue Table + Table BC von 
	 *     Bribe gegen die von Vexorian ausgetauscht habe!
     */
    globals
        private constant integer SPELL_ID ='A08M' 
        private constant integer BONUS_SPELL_ID ='AIt6' 
        private constant integer CAST_ABILITY_ID ='A08N'
        private constant integer CAST_REQUIRED_LEVEL = 0 
        private constant integer CAST_REQUIRED_BONUSLEVEL = 1 
        private constant string  MODEL_PATH_MISSILE = "Abilities\\Spells\\Other\\Incinerate\\IncinerateBuff.mdl"
        private constant string  MODEL_PATH_BONUS_MISSILE = "Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl"
        private constant string  MODEL_PATH_BONUS_FLASH = "Abilities\\Spells\\NightElf\\FaerieFire\\FaerieFireTarget.mdl" 
        private constant string  MODEL_PATH_FLASH = "Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl"
    endglobals

    private function castOrderId takes nothing returns integer
       return OrderId("parasite")
    endfunction

    private function radius takes real level returns real
       return level * 0.0 + 200.0
    endfunction

    private function speed takes integer level returns integer
       return level * 0 + 500
    endfunction

    private function maxBolts takes integer level returns integer
       return 6 + level * 0
    endfunction

    private function missileCollision takes real level, real bonuslevel returns real
       return 0.0 * level + 0.0 * bonuslevel + 100.0
    endfunction

    private function damage takes real level, real bonuslevel returns real
        return (10.0 * level) + 5
        //return 10 * level + 5 * bonuslevel + 4.0
    endfunction

    private function missileScale takes real level, real bonuslevel returns real
       return 1.0+level*0.0  + bonuslevel*1.1
    endfunction

    private function initialDistance takes real level, real bonuslevel returns real
       return 500.0 + 0*level+0*bonuslevel
    endfunction

    private function distanceIncrement takes real level, real bonuslevel returns real
       return 100.0 + 0*level+0*bonuslevel
    endfunction

    private function castRecycleDelay takes real level, real bonuslevel returns real
       return 5.0 * level + 0.0*bonuslevel + 0.0
    endfunction

    globals
        private constant integer ALPHA_STARTING_VALUE = 0
        private constant real ALPHA_INCREMENT_PER_SECOND = 150.0
        private constant real FLASH_FX_PERIOD = 0.25

        private constant real INITIAL_THROW   = 0.05 
        private constant real THROW_PERIOD    = 0.35 

        private constant real THROW_ANIMATION_SPEED   = 4.00 
        private constant real RESTORE_ANIMATION_SPEED = 1.00 

        private constant real INITIAL_OFFSET = 60.0

        private constant real BEZIER_Z1 = 60.0
        private constant real BEZIER_Z2 = 30.0
        private constant real BEZIER_Z3 = 180.0
        private constant real BEZIER_Z4 = 0.0


        private constant real CLOCK_TICK = XE_ANIMATION_PERIOD

        private constant integer MAX_SPELL_LEVELS = 5
        private constant integer MAX_BONUS_LEVELS = 5
    endglobals

    private function configDamage takes integer level, integer bonuslevel, xedamage d returns nothing
        call d.useSpecialEffect(GetAbilityEffectById('Afsh', EFFECT_TYPE_TARGET, 0), "origin") 
        set d.tag = 666

        set  d.damageAllies = false //True if you want it to hurt allies.
        set  d.atype = ATTACK_TYPE_NORMAL // NORMAL (spell) attacktype

        if(bonuslevel>0) then //* The bonus version:
            set  d.dtype = DAMAGE_TYPE_UNIVERSAL // UNIVERSAL damage, no building damage reduction
        else //* The normal version:
            set  d.dtype = DAMAGE_TYPE_LIGHTNING // LIGHTNING (magical) damage,
            call d.factor(UNIT_TYPE_STRUCTURE, 0.33) // does 1/3 damage to buildings.
        endif
    endfunction

    private struct missile
        group targetlog
        integer level
        integer bonuslevel
        unit    u
        real x1
        real x2
        real x3
        real x4
        real y1
        real y2
        real y3
        real y4
        real s=0
        real inc=0.01
        xefx fx
        real flashtime=0
        static integer lastid=0
    endstruct
   
   private struct throw
       integer level
       integer bonuslevel
       integer donetimes=0
       real    remaining=0
       integer tog=0
       boolean stop=false
       real    tx
       real    ty
       unit    u
   endstruct

   globals
       private missile array V
       private throw   array VT
       private integer N=0
       private integer NT=0
       private timer T
       private Table Tab
       private group enumgroup
       private boolexpr fetchunits
       private unit array U
       private integer Un
       private xecast Cast
       private xedamage array damageconf
   endglobals

   private function fetchFilterUnit takes nothing returns boolean
       set U[Un] = GetFilterUnit()
       set Un = Un + 1
       return false
   endfunction

    private function processThrow takes throw th returns boolean
        local missile m = missile.create()
        local integer l = th.level
        local real xk
        local real yk
        local real ang
        local real ang2
        local real dist
        local real ca
        local real sa

        if(integer(m) > missile.lastid) then
            set missile.lastid=integer(m)
            set m.targetlog=CreateGroup()
        else
            call GroupClear(m.targetlog)
        endif
        call SetUnitTimeScale(th.u,THROW_ANIMATION_SPEED)
        set m.x1=GetUnitX(th.u)
        set m.y1=GetUnitY(th.u)
        set ang=Atan2(th.ty-m.y1,th.tx-m.x1)

        set m.x1 = m.x1 + INITIAL_OFFSET * Cos(ang)
        set m.y1 = m.y1 + INITIAL_OFFSET * Sin(ang)

        if(th.tog==0) then
           set th.tog=1
           set ang2=ang+bj_PI/2
        else
           set th.tog=0
           set ang2=ang-bj_PI/2
        endif
        set m.fx=xefx.create(m.x1,m.y1,ang2)
        set m.fx.x=m.x1
        set m.fx.y=m.y1
        set m.bonuslevel=th.bonuslevel
        set m.level=l

        if(th.bonuslevel>0) then
           set m.fx.fxpath=MODEL_PATH_MISSILE
        else
           set m.fx.fxpath=MODEL_PATH_BONUS_MISSILE
        endif
        set m.fx.scale=missileScale(l,th.bonuslevel)
        set m.fx.z=BEZIER_Z1

        set dist=initialDistance(l,th.bonuslevel)+th.donetimes*distanceIncrement(l,th.bonuslevel)
        set m.x4=m.x1+dist*Cos(ang)
        set m.y4=m.y1+dist*Sin(ang)
        set ca=radius(l)*Cos(ang2)
        set sa=radius(l)*Sin(ang2)
        set m.x3=m.x4-4*ca
        set m.y3=m.y4-4*sa

        set m.x2=m.x1+3*ca
        set m.y2=m.y1+3*sa

        set m.fx.alpha=ALPHA_STARTING_VALUE
        set dist=SquareRoot( (m.x4-m.x1)*(m.x4-m.x1)+(m.y4-m.y1)*(m.y4-m.y1) ) //sqrt is necessary
        set m.inc=(speed(l)/dist)*CLOCK_TICK

        set m.u=th.u
        set V[N]=m
        set N=N+1

        set th.donetimes=th.donetimes+1
        if (th.donetimes>=maxBolts(l)) then
           call SetUnitTimeScale(th.u,RESTORE_ANIMATION_SPEED)
           set Tab[GetHandleId(th.u)]=0 
           return true
        else
           set th.remaining=THROW_PERIOD
           return false
        endif
        return false
    endfunction

    private function onExpire takes nothing returns nothing
        local integer i=0
        local integer n=N
        local missile m
        local throw   th
        local real s
        local real x
        local real y
        local real z
        local boolean keep
        local integer j
        local integer ab
        local real fc
        local integer k

        //missile code
        set N=0
        loop
            exitwhen i==n
            set m=V[i]
            set s=m.s
            set s=s+m.inc
            set keep=true
            if(s>=1.000000001) then
               set s=1
               set keep=false
            endif
            set x = s*s*s*m.x4 + 3*s*s*(1-s)*m.x3 + 3*s*(1-s)*(1-s)*m.x2+(1-s)*(1-s)*(1-s)*m.x1
            set y = s*s*s*m.y4 + 3*s*s*(1-s)*m.y3 + 3*s*(1-s)*(1-s)*m.y2+(1-s)*(1-s)*(1-s)*m.y1
            set z = s*s*s*BEZIER_Z4 + 3*s*s*(1-s)*BEZIER_Z3 + 3*s*(1-s)*(1-s)*BEZIER_Z2+(1-s)*(1-s)*(1-s)*BEZIER_Z1
            
            set m.fx.xyangle=Atan2(y-m.fx.y,x-m.fx.x)
            set m.flashtime=m.flashtime+CLOCK_TICK
            set m.fx.alpha=m.fx.alpha+R2I(ALPHA_INCREMENT_PER_SECOND*CLOCK_TICK+0.5)
            if (m.flashtime>=FLASH_FX_PERIOD) then
               if(m.bonuslevel>0) then
                   call m.fx.flash(MODEL_PATH_BONUS_FLASH)
               else
                   call m.fx.flash(MODEL_PATH_FLASH)
               endif
               set m.flashtime=0
            endif
            set m.fx.x=x 
            set m.fx.y=y
            set Un=0
            call GroupEnumUnitsInRange(enumgroup,x,y, missileCollision(m.level,m.bonuslevel)+XE_MAX_COLLISION_SIZE, fetchunits)
            set j=0
            set k=m.level*(MAX_BONUS_LEVELS+1)+m.bonuslevel //let's save this array index for later.
            loop
               exitwhen (j==Un)
               if (U[j]!=m.u) and (IsUnitInRangeXY(U[j],x,y,missileCollision(m.level,m.bonuslevel))) and not IsUnitInGroup(U[j],m.targetlog) then
                   set fc=damageconf[k].getTargetFactor(m.u, U[j])
                   if(fc!=0.0) then
                       if(m.level>=CAST_REQUIRED_LEVEL) and (m.bonuslevel>=CAST_REQUIRED_BONUSLEVEL) then
                            set Cast.owningplayer=GetOwningPlayer(m.u)
                            set Cast.level=m.level
                            set Cast.recycledelay=castRecycleDelay(m.level,m.bonuslevel)
                           call Cast.castOnTarget(U[j])
                       endif
                       call GroupAddUnit(m.targetlog,U[j])
                       //notice we are usign forceValue, since we already know the factor, it is also possible to
                       // call damageTarget directly, but that means the system will calculate the factor twice for no reason.
                       call damageconf[k].damageTargetForceValue(m.u, U[j], fc * damage(m.level,m.bonuslevel))
                   endif
               endif
               set j=j+1
            endloop

            if(not keep) or not IsTerrainWalkable(x, y) then
               call m.fx.destroy()
               call GroupClear(m.targetlog)
               call m.destroy()
            else
               set m.s=s
               set V[N]=m
               set N=N+1
            endif
            set i=i+1
        endloop

       //now call throw code, supposedly this is not called as many times as missile code, so
       // we might as well use a function call...
       set n=NT
       set NT=0
       set i=0
       loop
           exitwhen(i==n)
           set th=VT[i]
           set th.remaining = th.remaining - CLOCK_TICK
           if th.stop or ( (th.remaining<=-0.001) and processThrow(th) ) then
               call SetUnitTimeScale(th.u,RESTORE_ANIMATION_SPEED)
               call th.destroy()
           else
               set VT[NT]=th
               set NT=NT+1
           endif
           set i=i+1
       endloop

       if(N==0) and (NT==0) then
           call PauseTimer(T)
       endif
   endfunction

    private function onSpellEffect takes nothing returns nothing
        local location loc =GetSpellTargetLoc()
        local unit u=GetTriggerUnit()
        local throw th=throw.create()

        set Tab[GetHandleId(u)]=integer(th)
        set VT[NT]=th
        set th.level=GetUnitAbilityLevel(u,SPELL_ID)
        set th.bonuslevel=GetUnitAbilityLevel(u,BONUS_SPELL_ID)
        set th.remaining=INITIAL_THROW
        set th.tx=GetLocationX(loc)
        set th.ty=GetLocationY(loc)
        set th.u=u
        set NT=NT+1
        if(NT==1) then
           call TimerStart(T,CLOCK_TICK,true, function onExpire)
        endif

        set loc=null
        set u=null
    endfunction

    private function onSpellEnd takes nothing returns nothing
        local integer key=GetHandleId(GetTriggerUnit())
        local throw th=throw(Tab[key])
        
        if(th!=0) then
            set th.stop=true
            call Tab.remove(key)
        endif
    endfunction
   
    private function spellIdMatch takes nothing returns boolean
        return (SPELL_ID==GetSpellAbilityId())
    endfunction


    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer i
        local integer j
        call XE_PreloadAbility(CAST_ABILITY_ID)
        call Preload(MODEL_PATH_MISSILE)
        call Preload(MODEL_PATH_BONUS_MISSILE)
        call Preload(MODEL_PATH_BONUS_FLASH)
        call Preload(MODEL_PATH_FLASH)
        set Cast=xecast.create()
        set Cast.abilityid=CAST_ABILITY_ID
        set Cast.orderid=castOrderId()
        set enumgroup=CreateGroup()
        set fetchunits=Condition(function fetchFilterUnit)
        set Tab=Table.create()
        set T=CreateTimer()
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function spellIdMatch))
        call TriggerAddAction(t, function onSpellEffect)
        set t=CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        call TriggerAddCondition(t, Condition(function spellIdMatch))
        call TriggerAddAction(t, function onSpellEnd)

        set i=1 

           loop
               exitwhen (i > MAX_SPELL_LEVELS)
               set j=0
               loop
                   exitwhen (j > MAX_BONUS_LEVELS)
                   set damageconf[i*(MAX_BONUS_LEVELS+1) +j]=xedamage.create()
                   call configDamage(i,j, damageconf[i*(MAX_BONUS_LEVELS+1)+j] )
                   set j=j+1
               endloop
               set i=i+1
           endloop
        set t=null
    endfunction
endscope