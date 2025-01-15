scope FireStorm initializer Init
    /*
     * Description: Joos Ignos proves hes a master of magic by summoning a raging Storm of fire that damages his enemies. 
                    The Storm lasts for 6 seconds.
     * Changelog: 
     *     05.01.2014: Abgleich mit OE und der Exceltabelle
	 *     27.03.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for damaging and filtering
	 *
     */
    globals
        private constant integer SPELL_ID = 'A096'
        private constant integer DUMMY_ID = 'e010'
        private constant real InitDamage = 100
        private constant real LvlInc = 50
        private constant real MaxDist = 500
        private constant real MinDist = 100
        private constant real MaxHeight = 600
        private constant real UnitTime = 6
        private constant real DetectDist = 100
		private constant integer MAX_FIRE_MISSILES = 20
        private constant string ModelPath = "Models\\SunfireMissile.mdx"
        private constant string Effect = "Models\\FireBall.mdx"
        private constant string BirthEffect = "Models\\SunfireMissile.mdx"
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_FIRE
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
            
        private integer counter = 0
        private timer TIM = CreateTimer()
        private Firedata array Data
    endglobals

    struct Firedata
        unit caster = null
        unit entity = null
        real a      = 0
        real x      = 0
        real y      = 0
        real z      = 0
        real d      = 0
        real xC     = 0
        real yC     = 0
        effect s    = null
        
        static method create takes unit u, real x, real y returns Firedata
            local Firedata dat = Firedata.allocate()
            
            set dat.caster = u
            set dat.xC = x
            set dat.yC = y
            set dat.d = GetRandomReal(MinDist, MaxDist)
            set dat.a = GetRandomReal(0, 360)
            set dat.x = x + dat.d * Cos(dat.a * bj_DEGTORAD)
            set dat.y = y + dat.d * Sin(dat.a * bj_DEGTORAD)
            set dat.entity = CreateUnit(GetOwningPlayer(u), DUMMY_ID, dat.x, dat.y, dat.a)
            set dat.s = AddSpecialEffectTarget(ModelPath, dat.entity, "origin")
            
            call DestroyEffect(AddSpecialEffect(BirthEffect, dat.x, dat.y))
            call UnitApplyTimedLife(dat.entity, 'BFLT', UnitTime)
            
            if counter == 0 then
                call TimerStart(TIM, 0.03, true, function thistype.onLoop)
            endif
            
            set counter = counter + 1
            set Data[counter -1] = dat
            
            return dat
        endmethod
        
        static method damageArea takes unit source, real x, real y returns nothing
            local group g = CreateGroup()
            local unit target = null  
            local real dmg = (GetUnitAbilityLevel(source, SPELL_ID) * LvlInc) + InitDamage
        
            call GroupEnumUnitsInRange(g, x, y, DetectDist, null)
        
            loop
                set target = FirstOfGroup(g)
                exitwhen target == null
				if (SpellHelper.isValidEnemy(target, source)) then
                    set DamageType = SPELL
					call SpellHelper.damageTarget(source, target, dmg, true, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                    call DestroyEffect(AddSpecialEffectTarget(Effect, target, "chest"))
                endif
                call GroupRemoveUnit(g, target)
            endloop
			
            call DestroyGroup(g)
            set g = null
			set target = null
        endmethod
        
        static method detectUnit takes unit source, real x, real y returns integer
            local group g = CreateGroup()
            local integer i = 0
            local unit target = null   
        
            call GroupEnumUnitsInRange(g, x, y, DetectDist, null)
            loop
                set target = FirstOfGroup(g)
                exitwhen target == null
				if (SpellHelper.isValidEnemy(target, source)) then
					call DestroyGroup(g)
					set g = null
					set target = null
					return 0
                endif
                call GroupRemoveUnit(g, target)
            endloop
        
            call DestroyGroup(g)
			set target = null
			set g = null
        
            return 1
        endmethod
        
        static method onLoop takes nothing returns nothing
            local Firedata dat
            local integer i = 0
            
            loop
                exitwhen i >= counter
                set dat = Data[i]
                
                //This is the onLoop actions
                set dat.a = dat.a + 5
                set dat.x = dat.xC + dat.d * Cos(dat.a * bj_DEGTORAD)
                set dat.y = dat.yC + dat.d * Sin(dat.a * bj_DEGTORAD)
                
                call SetUnitX(dat.entity, dat.x)
                call SetUnitY(dat.entity, dat.y)
                
                set dat.z = dat.z + 20
                call SetUnitFlyHeight(dat.entity, dat.z, 40)
                
                if Firedata.detectUnit(dat.entity, dat.x, dat.y) == 0 then
                    call KillUnit(dat.entity)
                    call Firedata.damageArea(dat.caster, dat.x, dat.y)
                endif
                
                //End of onLoop actions
				if (SpellHelper.isUnitDead(dat.entity)) then
                    set Data[i] = Data[counter - 1]
                    set counter = counter - 1
                    call DestroyEffect(AddSpecialEffectTarget(Effect, dat.entity, "origin"))
                    
                    call dat.destroy()
                endif
                
                set i = i + 1
            endloop
            
            if counter == 0 then
                call PauseTimer(TIM)
            endif
        
        endmethod
        
        method onDestroy takes nothing returns nothing
            call DestroyEffect(.s)
            call RemoveUnit(.entity)
        endmethod

    endstruct

    private function Actions takes nothing returns nothing
		local integer i = 0
		
		loop
			exitwhen i == MAX_FIRE_MISSILES
			call Firedata.create(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY())
			set i = i + 1
		endloop
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function Init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
		call Preload(ModelPath)
        call Preload(Effect)
    endfunction
    
endscope