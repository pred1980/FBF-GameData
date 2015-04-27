scope Snipe initializer Init
    /*
     * Description: The Dark Ranger shoots an arrow at a target outside of her usual range. 
	                She takes 3 seconds to aim.
     * Changelog: 
     *     	26.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	28.03.2014: Missile Speed von 600 auf 1100 hochgesetzt
	 *     	29.03.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for damaging
	 *		24.04.2015: Fixed a bug with saving the current instance of the snipe struct
     */
    private keyword Snipe
    
    globals
        private constant integer SPELL_ID = 'A075' 
        private constant string MISSILE_MODEL = "Abilities\\Weapons\\MoonPriestessMissile\\MoonPriestessMissile.mdl"
        private constant string CROSS_MODEL = "Models\\Snipe.mdx"
        private constant real MISSILE_SCALE = 1.0
        private constant real MISSILE_SPEED = 1100.0
        private constant real ARC_MIN = 0.
        private constant real ARC_MAX = 0.25
        private constant real Z_START = 0.
        private constant real Z_END = 0.
        private constant real CHANNEL_DURATION = 3.0
        private constant integer BASE_DAMAGE = 25
        private constant integer DAMAGE_PER_LEVEL = 50
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_PIERCE
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
        private xedamage damageOptions
        private Snipe array spellForUnit
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
        set d.dtype = DAMAGE_TYPE   
        set d.atype = ATTACK_TYPE 
        set d.wtype = WEAPON_TYPE
        set d.exception = UNIT_TYPE_STRUCTURE 
    endfunction
    
    struct Snipe extends xehomingmissile
        unit caster
        unit target
        integer level = 0
        real oriDist = 0.00
        real dist = 0.00
        real percent = 100.00
        effect cross
        
        static method getForUnit takes unit u returns thistype
			return spellForUnit[GetUnitId(u)]
		endmethod
		
		 method onDestroy takes nothing returns nothing
            call DestroyEffect(.cross)
			set spellForUnit[GetUnitId(.caster)] = 0
            set .cross = null
            set .caster = null
            set .target = null
        endmethod

        static method onLaunch takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
            call ReleaseTimer(GetExpiredTimer())
        endmethod
        
        method loopControl takes nothing returns nothing
            set this.dist = DistanceBetweenCords(GetUnitX(this.caster), GetUnitY(this.caster), GetUnitX(this.target), GetUnitY(this.target))
            
            if IsTerrainWalkable(this.x, this.y) then
                if (this.dist > this.oriDist) and this.percent >= 0.50 then
                    set this.percent = (this.dist * 100.0) / this.oriDist
                    set this.percent = 100.0 - (this.percent - 100.0)
                endif
            else
                call this.terminate()
            endif
        endmethod
        
        method onHit takes nothing returns nothing
            //Damage Unit depending on distance
            if (damageOptions.allowedTarget(this.caster, this.target)) then
                if GetRandomReal(0.00, 100.00) <= this.percent then
                    set DamageType = PHYSICAL
					call SpellHelper.damageTarget(this.caster, this.target, (BASE_DAMAGE + this.level * DAMAGE_PER_LEVEL), true, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                endif
            endif
        endmethod
       
		static method create takes unit caster, unit target, integer level returns thistype
            local thistype this = thistype.allocate(GetWidgetX(caster), GetWidgetY(caster), Z_START, target, Z_END)
            local timer t = NewTimer()
            
            set this.fxpath = MISSILE_MODEL
            set this.scale = MISSILE_SCALE
            set this.caster = caster
            set this.target = target
            set this.level = level
            set this.oriDist = DistanceBetweenCords(GetUnitX(caster), GetUnitY(caster), GetUnitX(target), GetUnitY(target))
            set .cross = AddSpecialEffectTarget(CROSS_MODEL, .target, "head")
            set spellForUnit[GetUnitId(caster)] = this
			
            call SetTimerData(t , this )
            call TimerStart(t, CHANNEL_DURATION, false, function thistype.onLaunch)
            
            return this
        endmethod
       
    endstruct

    private function Actions takes nothing returns nothing
        local Snipe s = 0
        local unit caster = GetTriggerUnit()
        local unit target = GetSpellTargetUnit()
        local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
    
        set s = Snipe.getForUnit(caster)
        if s == 0 then
            set s = Snipe.create(caster, target, level)
        endif

        set caster = null
        set target = null
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
   
    private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_CHANNEL, function Conditions, function Actions)

        set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)
        
        call Preload(MISSILE_MODEL)
        call Preload(CROSS_MODEL)
    endfunction
endscope
