scope HolyChains initializer init
	/*
     * Description: The Archmage casts Holy Chains in the targeted direction, damaging every enemy unit 
	                in the spells path.
     * Last Update: 17.02.2015
     * Changelog: 
     *     28.11.2013: Abgleich mit OE und der Exceltabelle
	 *     17.02.2015: Code Refactoring
	 *     26.03.2015: Changed ATTACK_TYPE from Spells to Magic
	                   Integrated RegisterPlayerUnitEvent
	 *
	 * Info: 
	 *     15.05.2013: Tab.flush(key) durch  Tab.remove(key) ersetzt da ich die neue Table + Table BC von 
	 *     Bribe gegen die von Vexorian ausgetauscht habe!
     */
	 
	private keyword missile
	private keyword throw
	 
	globals
        private constant integer SPELL_ID = 'A076'
        private constant integer CAST_ABILITY_ID ='A08N'
        private constant string  MODEL_PATH_MISSILE = "Abilities\\Spells\\Other\\Incinerate\\IncinerateBuff.mdl"
        private constant string  MODEL_PATH_FLASH = "Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl"
    	private constant integer ORDER_ID = OrderId("parasite")
		private constant real RADIUS = 200
		private constant integer SPEED = 500
		private constant real MISSILE_COLLISION = 100
		private constant real MISSILE_SCALE = 1.0
		private constant real INITIAL_DISTANCE = 600
		private constant real DISTANCE_INCREMENT = 100
		private constant real CAST_RECYCLE_DELAY = 5.0
		private constant integer array MAX_BOLTS
		private constant real array DAMAGE
		
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
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_LIGHTNING
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
		private missile array V
		private throw array VT
		private integer N = 0
		private integer NT = 0
		private timer T
		private Table Tab
		private group enumgroup
		private boolexpr fetchunits
		private unit array U
		private integer Un
		private xecast Cast
		private xedamage xeDamage = 0
	endglobals
	
	private function MainSetup takes nothing returns nothing
		set MAX_BOLTS[0] = 5
		set MAX_BOLTS[1] = 6
		set MAX_BOLTS[2] = 7
		set MAX_BOLTS[3] = 8
		set MAX_BOLTS[4] = 9
	endfunction
	
	private function SetupDamage takes nothing returns nothing
		set xeDamage = xedamage.create()
	 
		set xeDamage.damageNeutral = false
		set xeDamage.dtype = DAMAGE_TYPE
		set xeDamage.atype = ATTACK_TYPE
		set xeDamage.wtype = WEAPON_TYPE
		set xeDamage.exception = UNIT_TYPE_STRUCTURE
		set xeDamage.tag = 666
		set xeDamage.damageAllies = false //True if you want it to hurt allies.
		call xeDamage.useSpecialEffect(GetAbilityEffectById('Afsh', EFFECT_TYPE_TARGET, 0), "origin") 
	 
		set DAMAGE[0] = 15
		set DAMAGE[1] = 25
		set DAMAGE[2] = 35
		set DAMAGE[3] = 45
		set DAMAGE[4] = 55
	endfunction
	
	private struct missile
        group targetlog
        integer level
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
        real inc = 0.01
        xefx fx
        real flashtime = 0
        static integer lastid = 0
    endstruct
	
	private struct throw
		integer level
		integer donetimes = 0
		real    remaining = 0
		integer tog = 0
		boolean stop = false
		real    tx
		real    ty
		unit    u
	endstruct
	
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
			set missile.lastid = integer(m)
			set m.targetlog = CreateGroup()
		else
			call GroupClear(m.targetlog)
		endif
		call SetUnitTimeScale(th.u,THROW_ANIMATION_SPEED)
		set m.x1 = GetUnitX(th.u)
		set m.y1 = GetUnitY(th.u)
		set ang = Atan2(th.ty-m.y1,th.tx-m.x1)

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
		set m.level = l

		set m.fx.fxpath = MODEL_PATH_MISSILE
		set m.fx.scale = MISSILE_SCALE
		set m.fx.z = BEZIER_Z1

		set dist = INITIAL_DISTANCE + th.donetimes * DISTANCE_INCREMENT
		set m.x4=m.x1+dist*Cos(ang)
		set m.y4=m.y1+dist*Sin(ang)
		set ca = RADIUS * Cos(ang2)
		set sa = RADIUS * Sin(ang2)
		set m.x3 = m.x4 - 4*ca
		set m.y3 = m.y4 - 4*sa

		set m.x2 = m.x1 + 3*ca
		set m.y2 = m.y1 + 3*sa

		set m.fx.alpha=ALPHA_STARTING_VALUE
		set dist=SquareRoot( (m.x4-m.x1)*(m.x4-m.x1)+(m.y4-m.y1)*(m.y4-m.y1) ) //sqrt is necessary
		set m.inc = (SPEED/dist) * CLOCK_TICK

		set m.u = th.u
		set V[N] = m
		set N = N + 1
		
		set th.donetimes = th.donetimes + 1
		if (th.donetimes >= MAX_BOLTS[m.level]) then
		   call SetUnitTimeScale(th.u,RESTORE_ANIMATION_SPEED)
		   set Tab[GetHandleId(th.u)] = 0 
		   return true
		else
		   set th.remaining = THROW_PERIOD
		   return false
		endif
		return false
	endfunction
	
	private function onExpire takes nothing returns nothing
		local integer i = 0
		local integer n = N
		local missile m
		local throw th
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
		set N = 0
		loop
			exitwhen i == n
			set m = V[i]
			set s = m.s
			set s = s + m.inc
			set keep = true
			if(s >= 1.000000001) then
			   set s = 1
			   set keep = false
			endif
			set x = s*s*s*m.x4 + 3*s*s*(1-s)*m.x3 + 3*s*(1-s)*(1-s)*m.x2+(1-s)*(1-s)*(1-s)*m.x1
			set y = s*s*s*m.y4 + 3*s*s*(1-s)*m.y3 + 3*s*(1-s)*(1-s)*m.y2+(1-s)*(1-s)*(1-s)*m.y1
			set z = s*s*s*BEZIER_Z4 + 3*s*s*(1-s)*BEZIER_Z3 + 3*s*(1-s)*(1-s)*BEZIER_Z2+(1-s)*(1-s)*(1-s)*BEZIER_Z1
			
			set m.fx.xyangle = Atan2(y-m.fx.y,x-m.fx.x)
			set m.flashtime = m.flashtime + CLOCK_TICK
			set m.fx.alpha = m.fx.alpha+R2I(ALPHA_INCREMENT_PER_SECOND*CLOCK_TICK+0.5)
			
			if (m.flashtime >= FLASH_FX_PERIOD) then
			   call m.fx.flash(MODEL_PATH_FLASH)
			   set m.flashtime=0
			endif
			
			set m.fx.x = x 
			set m.fx.y = y
			set Un = 0
			
			call GroupEnumUnitsInRange(enumgroup, x, y, MISSILE_COLLISION + XE_MAX_COLLISION_SIZE, fetchunits)
			
			set j = 0
			set k = m.level //let's save this array index for later.
			
			loop
			   exitwhen (j == Un)
			   if (U[j] != m.u) and (IsUnitInRangeXY(U[j],x,y, MISSILE_COLLISION)) and not IsUnitInGroup(U[j],m.targetlog) then
				   set fc = xeDamage.getTargetFactor(m.u, U[j])
				   if(fc != 0.0) then
						set Cast.owningplayer = GetOwningPlayer(m.u)
						set Cast.level = m.level
						set Cast.recycledelay = CAST_RECYCLE_DELAY
						call Cast.castOnTarget(U[j])
						call GroupAddUnit(m.targetlog,U[j])
						//notice we are usign forceValue, since we already know the factor, it is also possible to
						// call damageTarget directly, but that means the system will calculate the factor twice for no reason.
						call xeDamage.damageTargetForceValue(m.u, U[j], fc * DAMAGE[m.level])
				   endif
			   endif
			   set j = j + 1
			endloop

			if(not keep) or not IsTerrainWalkable(x, y) then
				call m.fx.destroy()
				call GroupClear(m.targetlog)
				call m.destroy()
			else
				set m.s = s
				set V[N] = m
				set N = N + 1
			endif
			set i = i + 1
		endloop

	   //now call throw code, supposedly this is not called as many times as missile code, so
	   //we might as well use a function call...
		set n = NT
		set NT = 0
		set i = 0
		loop
		   exitwhen(i == n)
		   set th = VT[i]
		   set th.remaining = th.remaining - CLOCK_TICK
		   if (th.stop or ((th.remaining <= -0.001) and processThrow(th))) then
			   call SetUnitTimeScale(th.u, RESTORE_ANIMATION_SPEED)
			   call th.destroy()
		   else
			   set VT[NT] = th
			   set NT = NT + 1
		   endif
		   set i = i + 1
		endloop

		if ((N == 0) and (NT == 0)) then
			call PauseTimer(T)
		endif
	endfunction
	
	private function fetchFilterUnit takes nothing returns boolean
	   set U[Un] = GetFilterUnit()
	   set Un = Un + 1
	   
	   return false
	endfunction

	private function ActionsStart takes nothing returns nothing
		local unit u = GetTriggerUnit()
		local throw th = throw.create()
		
		set Tab[GetHandleId(u)] = integer(th)
		set VT[NT] = th
		set th.level = GetUnitAbilityLevel(u, SPELL_ID)
		set th.remaining = INITIAL_THROW
		set th.tx = GetSpellTargetX()
		set th.ty = GetSpellTargetY()
		set th.u = u
		set NT = NT + 1
		
		call TimerStart(T, CLOCK_TICK, true, function onExpire)
        
		set u = null
	endfunction
	
	private function ActionsEnd takes nothing returns nothing
		local integer key = GetHandleId(GetTriggerUnit())
		local throw th = throw(Tab[key])
		
		if(th!=0) then
			set th.stop=true
			call Tab.remove(key)
		endif
	endfunction
	
	private function Conditions takes nothing returns boolean
		return (GetSpellAbilityId() == SPELL_ID)
	endfunction

	private function init takes nothing returns nothing
		call MainSetup()
		call SetupDamage()
		
		call XE_PreloadAbility(CAST_ABILITY_ID)
		call Preload(MODEL_PATH_MISSILE)
		call Preload(MODEL_PATH_FLASH)
		
		set Cast = xecast.create()
		set Cast.abilityid = CAST_ABILITY_ID
		set Cast.orderid = ORDER_ID
		set enumgroup = CreateGroup()
		set fetchunits = Condition(function fetchFilterUnit)
		set Tab = Table.create()
		set T = CreateTimer()
		
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function ActionsStart)
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_ENDCAST, function Conditions, function ActionsEnd)
	endfunction
endscope