scope ShatteringJavelin initializer Init
    /*
     * Description: The Royal Knight throws a Javelin that deals piercing damage and shatters on impact. 
                    The shattered fragmets hit the units behind the target.
     * Changelog: 
     *     09.12.2013: Abgleich mit OE und der Exceltabelle
     *     10.12.2013: Umbau auf XE Missile System abgeschlossen
	 *     28.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for filtering and damaging
     */
    globals
        private constant integer SPELL_ID = 'A08A'
        private constant integer ANIMAL_WAR_TRAINING_ID = 'A081'
        private constant string LANCE_MODEL = "Abilities\\Weapons\\Banditmissile\\Banditmissile.mdl"
        private constant string FRAGMENT_MODEL = "Abilities\\Weapons\\Axe\\AxeMissile.mdl"
        private constant real MISSILE_SCALE = 1.1
        private constant real MISSILE_SPEED = 700.0
        private constant real ARC_MIN = 0.
        private constant real ARC_MAX = 0.1
        private constant real Z_START = 0.
        private constant real Z_END = 0.
        private constant real START_DAMAGE = 0
        private constant real DAMAGE_INCREASE = 100
        private constant real FRAGMENT_START_DAMAGE = 50
        private constant real FRAGMENT_DAMAGE_INCREASE = 25
        private constant integer FRAGMENT_START_NUMBER = 4
        private constant integer FRAGMENT_INCREASE_NUMBER = 1
        private constant integer FRAGMENT_RADIUS = 400
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_PIERCE
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
        private xedamage damageOptions
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
        set d.atype = ATTACK_TYPE
		set d.dtype = DAMAGE_TYPE   
        set d.wtype = WEAPON_TYPE
        
        set d.exception = UNIT_TYPE_STRUCTURE 
    endfunction
    
    private struct Fragment extends xehomingmissile
        unit caster //Royal Knight
        unit target  //Fragmentziel
        integer level = 0
        
        //caster: Royal Knight
        //fragTarget: Ziel hinter dem ersten Ziel, was getroffen wurde
        //target: erstes Ziel
        static method create takes unit caster, unit fragTarget, unit target, integer level returns thistype
            local thistype this = thistype.allocate(GetWidgetX(target), GetWidgetY(target), Z_START, fragTarget, Z_END)
            
            set this.fxpath = FRAGMENT_MODEL
            set this.scale = MISSILE_SCALE
            set this.caster = caster
            set this.target = fragTarget
            set this.level = level
            
            call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
            
            return this
        endmethod
        
        method loopControl takes nothing returns nothing
            if not IsTerrainWalkable(this.x, this.y) then
                call this.terminate()
            endif
        endmethod
        
        method onHit takes nothing returns nothing
            if (damageOptions.allowedTarget(this.caster, this.target)) then
                set DamageType = PHYSICAL
				call SpellHelper.damageTarget(this.caster, this.target, FRAGMENT_START_DAMAGE + FRAGMENT_DAMAGE_INCREASE * this.level, true, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            endif
            
            call this.terminate()
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .caster = null
            set .target = null
        endmethod
        
    endstruct
    
    private struct ShatteringJavelin extends xehomingmissile
        unit caster
        unit target
        group targets
        integer level
        static thistype tempthis
		
		method onDestroy takes nothing returns nothing
            call ReleaseGroup(.targets)
            set .targets = null
            set .caster = null
            set .target = null
        endmethod

        method loopControl takes nothing returns nothing
            if not IsTerrainWalkable(this.x, this.y) then
                call this.terminate()
            endif
        endmethod
		
		static method filterCallback takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidEnemy(u, .tempthis.caster)) and /*
			*/	u != .tempthis.target and not /*
            */  IsUnitInGroup(u, .tempthis.targets) then
				set b = true
			endif
			
			set u = null
			
			return b
        endmethod
        
        method onHit takes nothing returns nothing
            local unit u
            local integer i = FRAGMENT_START_NUMBER + FRAGMENT_INCREASE_NUMBER * GetUnitAbilityLevel(this.caster, ANIMAL_WAR_TRAINING_ID)
            local real x = GetUnitX(this.target)
            local real y = GetUnitY(this.target)
            
            if (damageOptions.allowedTarget(this.caster, this.target )) then
                set DamageType = PHYSICAL
				call SpellHelper.damageTarget(this.caster, this.target, START_DAMAGE + DAMAGE_INCREASE * this.level, true, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
			endif
            
            loop
                set i = i - 1
                set u = GetClosestUnitInRange(1.5 * x-0.5 * GetUnitX(this.caster), 1.5 * y-0.5 * GetUnitY(this.caster), FRAGMENT_RADIUS, Condition(function thistype.filterCallback))
                if u != null then
                    call GroupAddUnit(this.targets, u)
                    call Fragment.create(this.caster, u, this.target, this.level)
                endif
                exitwhen i == 0
            endloop
            
            call this.terminate()
        endmethod

		static method create takes unit caster, unit target, integer level returns thistype
            local thistype this = thistype.allocate(GetWidgetX(caster), GetWidgetY(caster), Z_START, target, Z_END)
            local timer t = NewTimer()
            
            set this.fxpath = LANCE_MODEL
            set this.scale = MISSILE_SCALE
            set this.caster = caster
            set this.target = target
            set this.level = level
            set .targets = NewGroup()
            set this.tempthis = this
            
            call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
            
            return this
        endmethod
        
    endstruct
    
    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local unit target = GetSpellTargetUnit()
        local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
    
        call ShatteringJavelin.create(caster, target, level)
        
        set caster = null
        set target = null
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction
   
    private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)

        set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)
        
        call XE_PreloadAbility(ANIMAL_WAR_TRAINING_ID)
        call Preload(LANCE_MODEL)
        call Preload(FRAGMENT_MODEL)
    endfunction
endscope
