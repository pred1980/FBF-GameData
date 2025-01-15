scope ReflectionOfIllidan initializer Init
    globals
        //! general settings
        private constant integer SPELL_ID = 'A050'
        private constant integer DummyID = 'n00O'
        private constant real Timer = 0.03125
        
        private constant integer IncrOrbAmountMax = 10  // Max amount of orbs
        private constant real InitTime = 30. // How long the effect lasts on level 1
        private constant real AddTime = 0.  // Amount of time added per level
        
        private constant string OrbModel = "Abilities\\Weapons\\IllidanMissile\\IllidanMissile.mdl" // Model of the orbs
        private constant string OrbCreation = "Abilities\\Weapons\\IllidanMissile\\IllidanMissile.mdl" // Model of the "death" animation displayed upon creation of the orbs
        private constant string OrbImpact = "Abilities\\Weapons\\IllidanMissile\\IllidanMissile.mdl" // Model of the "death" animation displayed upon impact on enemied units
        private constant string DummyAttach = "chest" // Attachment point oof the effects on the "Dummy" model as well as the attachment point used on the enemy
        
        private constant real OrbitalSpeedMin = 10.05 // Defines the minimal orbital speed
        private constant real OrbitalSpeedMax = 15.55 // Defines the maximal orbital speed
        
        private constant real OrbitalAngSpMin = 2.05 // Defines the minimal speed of the spin of the orbital movement 
        private constant real OrbitalAngSpMax = 2.55  // Defines the maximal speed of the spin of the orbital movement 
        
        private constant real OrbitalSizeMin = 140.   // Defines the minimal size of the orbital movement of a single orb
        private constant real OrbitalSizeMax = 190.   // Defines the maximal size of the orbital movement of a single orb
        
        private constant real OrbitalHeightMin = 45.    // Defines partially the height of the orbital (minimal).
        private constant real OrbitalHeightMax = 60.    // Defines partially the height of the orbital (maximal).
         //!I recommend playing around with this value for ground units to find something fitting. For air units, i recommend simply "0".
        
        private constant real MinDamageCounter = 5. // Returns the minimal damage necessary to release a countering orb
        
        private constant real ReleasedSpeed = 20.5   // The flying speed of a released orb.
        private constant real PercCounterInit = 120.   // The percentage of damage returned at level 1
        private constant real PercCounterAdd = 75.   // The percentage of damage to return added for every further level
        
        private constant attacktype ATT = ATTACK_TYPE_NORMAL   // The attacktype of the damage dealt
        private constant damagetype DGT = DAMAGE_TYPE_NORMAL   // The damagetype of the damage dealt
        private constant weapontype WPT = WEAPON_TYPE_WHOKNOWS // The weapontype of the damage dealt
         
//!*******************************END OF THE SETTINGS*************************!\\
//**Do not modify anything below this line unless you know what you are doing**\\
//!***************************************************************************!\\
        private real array R
        private trigger DmgSys = CreateTrigger()
        private group DSys = CreateGroup()
    endglobals

    private struct S
        private unit h
        private unit o
        private unit t
        private integer l
        private integer s
        
        private real d1
        private real d2
        private real a1
        private real t1
        private real t2
        
        private real OSp
        private real OAS
        private real OSi
        private real OHe
        private real OEx
        
        private effect fx
        
        private static S array indx
        private static integer counter = 0
        private static timer time = CreateTimer()
		
			static method onDamage takes unit damagedUnit, unit damageSource, real damage returns nothing
				local S d
                local integer i = 0
                local integer ii = 0
                local unit u = null
				
				if (DamageType == PHYSICAL) then
					set u = damagedUnit
					set R[0] = damage
					if damageSource != u then
						loop
							exitwhen i >= S.counter
							set d = S.indx[i] 
							if d.h == u and d.s == 1 then
								//! An orb flying in an orbital shape around the attacked hero is detected here.
								//! d.s = 1 means orbital movement
								//! d.s = 2 means movement to a target
								set d.s  = 2
								set d.t  = damageSource
								set d.d2 = R[0]*((PercCounterInit+(PercCounterAdd*d.l))/100)
								set R[0] = 0
								set i = S.counter
							endif   
							set i = i + 1
						endloop
					endif
					set u = null
				endif
			endmethod
			
            static method Execution takes nothing returns nothing
                local S d
                local integer i = 0
                local unit u
                loop
                    exitwhen i >= S.counter
                    set d = S.indx[i]
                    
                    if d.s == 0 then
                        //! Remove & Recycle
                        call DestroyEffect(d.fx)
                        call RemoveUnit(d.o)
                        set  d.h      = null
                        set  d.o      = null
                        set  d.t      = null
                        call d.destroy()                        
                        set  S.counter = S.counter - 1
                        set  S.indx[i] = d.indx[S.counter]                        
                        set  i = i - 1    

                    elseif d.s == 1 then
                        //! The formula for the orbital movement (by me, i've been asked this already before the official release)
                        set d.t1 = d.t1 + Timer
                        set d.a1 = d.a1 + d.OAS
                        set d.d1 = d.d1 + d.OSp 
                        set R[0] = (d.d1/d.OEx)*bj_DEGTORAD
                        set R[1] = d.OSi*Sin(R[0])
                        set R[2] = d.a1*bj_DEGTORAD
                        call SetUnitX(d.o,GetUnitX(d.h)+R[1]*Cos(R[2]))
                        call SetUnitY(d.o,GetUnitY(d.h)+R[1]*Sin(R[2]))
                        call SetUnitFlyHeight(d.o,(d.OSi-d.OHe)*Cos(R[0])+d.OHe+GetUnitFlyHeight(d.h),0) 
                        set R[2] = 0
                        //! Since the orbs move with a circular movement, we can reset the angle.
                        if d.a1 >= 360 then
                            set d.a1 = d.a1 - 360
                        endif
                        
                        if d.t1 >= d.t2 or GetUnitState(d.h,UNIT_STATE_LIFE) == 0 then
                            set d.s = 0
                        endif
                    elseif d.s == 2 then
                        //! Launch and move the missile
                        
                        //! X/Y Movement
                        set R[0] = GetUnitX(d.t)
                        set R[1] = GetUnitY(d.t)
                        set R[2] = GetUnitX(d.o)
                        set R[3] = GetUnitY(d.o)
                        set R[4] = Atan2(R[1]-R[3],R[0]-R[2])   
                        call SetUnitX(d.o,R[2] + ReleasedSpeed * Cos(R[4]))
                        call SetUnitY(d.o,R[3] + ReleasedSpeed * Sin(R[4]))
                        
                        //! Z Movement
                        set R[0] = R[2] - R[0]
                        set R[1] = R[3] - R[1]
                        set R[2] = SquareRoot(R[0]*R[0]+R[1]*R[1])
                        set R[0] = GetUnitFlyHeight(d.t)
                        set R[1] = GetUnitFlyHeight(d.o)
                        set R[0] = R[0]-R[1]
                        set R[0] = R[0]/(R[2]/ReleasedSpeed)
                        call SetUnitFlyHeight(d.o,R[1]+R[0],0)

                        //! Exit
                        if R[2] <= ReleasedSpeed then
                            set d.s = 0
                            call DestroyEffect(AddSpecialEffectTarget(OrbImpact,d.t,DummyAttach))
                            call UnitDamageTarget (d.h,d.t,d.d2,true,false,ATT,DGT,WPT)
                        elseif GetUnitState(d.t,UNIT_STATE_LIFE) == 0 then
                            set d.s = 0
                        endif
                    endif
                    set i = i + 1
                endloop
                set u = null
                set i = 0
                if S.counter == 0 then
                    call PauseTimer(S.time)
                endif 
            endmethod
            
            static method SetStruct takes unit h, real a1, real a2, real t2, integer l returns nothing
                //! This method mainly inits the orbital movement data and determines the movement shape
                local S d = S.allocate()
                set d.h   = h
                set d.s   = 1
                set d.l   = l
                set d.d1  = 0
                set d.a1  = (360/a1)*a2
                set d.t1  = 0
                set d.t2  = t2
                set d.OSp = GetRandomReal(OrbitalSpeedMin,OrbitalSpeedMax)
                set d.OSi = GetRandomReal(OrbitalSizeMin,OrbitalSizeMax)
                set d.OAS = GetRandomReal(OrbitalAngSpMin,OrbitalAngSpMax)*bj_DEGTORAD
                set d.OHe = GetRandomReal(OrbitalHeightMin,OrbitalHeightMax)
                set d.OEx = d.OSi/90
                set   d.o = CreateUnit(GetOwningPlayer(h),DummyID,GetUnitX(h),GetUnitY(h),0)
                call UnitAddAbility(d.o,'Arav')
                call UnitRemoveAbility(d.o,'Arav')  
                call DestroyEffect(AddSpecialEffectTarget(OrbCreation,d.o,DummyAttach))
                set d.fx = AddSpecialEffectTarget(OrbModel,d.o,DummyAttach)
                if S.counter   == 0 then
                    call TimerStart(S.time,Timer,true,function S.Execution)
                endif
                set S.indx[S.counter] = d
                set S.counter = S.counter + 1
            endmethod
            
            static method Create takes nothing returns nothing
                //! The hero is added to the damage detection
                local unit u = GetTriggerUnit()
                if not IsUnitInGroup(u,DSys) then
                    call GroupAddUnit(DSys,u)
					call RegisterDamageResponse( .onDamage )
                endif
                //! Create the orbs
                set   R[0]   = 0
                set   R[2]   = GetHeroLevel(u)
                set   R[1]   = R[2]
                loop
                    exitwhen R[0] == R[1] or R[0] == IncrOrbAmountMax
                    call S.SetStruct(u,R[1],R[0],InitTime+(AddTime*R[2]),R2I(R[2]))
                    set R[0] = R[0] + 1
                endloop
            endmethod
    endstruct
    
    private function Actions takes nothing returns nothing
        call S.Create()
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
    
    private function Init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
		// Preloading effects
        call Preload(OrbCreation)
        call Preload(OrbImpact)
        call Preload(OrbModel)
        call PreloadStart()
    endfunction
endscope