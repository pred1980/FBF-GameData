scope ImpalingSpine initializer Init
    /*
     * Description: The Naga Matriarch throws a magical Spear, dealing damage, stunning the target and 
                    damaging it over 60 seconds.
     * Last Update: 08.01.2014
     * Changelog: 
     *     31.12.2013: Neuimplementierung (Umbau auf xemissile)
     *     08.01.2014: Abgleich mit OE und der Exceltabelle
     *     21.03.2014: Hero Stun auf von 2s/2.5s/3s/3.5s/4s auf 1.5s gesetzt
     */
    globals
        private constant integer SPELL_ID = 'A07P'
		private constant string MISSILE_MODEL = "Abilities\\Weapons\\TuskarSpear\\TuskarSpear.mdl"
        private constant real MISSILE_SCALE = 1.2
        private constant real MISSILE_SPEED = 800.0
        private constant real ARC_MIN = 0.
        private constant real ARC_MAX = 0.15
        private constant real Z_START = 0.
        private constant real Z_END = 0.
        
        private constant real STN_BASE = 1.5
        private constant real STN_INCR = 1
        private constant real HSTN_BASE = 1.5
        private constant real HSTN_INCR = 0
        private constant real DMG_BASE = 10
        private constant real DMG_INCR = 10
        
        //Stun Effect
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        
        //DoT
        private constant string EFFECT = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"
        private constant string ATT_POINT = "chest"
        private constant attacktype ATT_TYPE = ATTACK_TYPE_HERO
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_COLD
        private real array DOT_DAMAGE
        private real DOT_TIME = 60.0
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DOT_DAMAGE[1] = 30.0
        set DOT_DAMAGE[2] = 60.0
        set DOT_DAMAGE[3] = 90.0
        set DOT_DAMAGE[4] = 120.0
        set DOT_DAMAGE[5] = 150.0
    endfunction
	
	struct ImpalingSpine extends xehomingmissile
		unit caster
        unit target
        integer level = 0
		
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate(GetWidgetX(caster), GetWidgetY(caster), Z_START, target, Z_END)
            
            set this.fxpath = MISSILE_MODEL
            set this.scale = MISSILE_SCALE
			set this.caster = caster
            set this.target = target
            set this.level = GetUnitAbilityLevel(caster, SPELL_ID)
			
			call this.launch(MISSILE_SPEED, GetRandomReal(ARC_MIN, ARC_MAX))
			
            return this
        endmethod
        
        method loopControl takes nothing returns nothing
            if not IsTerrainWalkable(this.x, this.y) then
                call this.terminate()
            endif
        endmethod
        
        method onHit takes nothing returns nothing
            if not IsUnitDead(.target) then
                if IsUnitType(.target, UNIT_TYPE_HERO) then
                    call Stun_UnitEx(.target, (HSTN_BASE + HSTN_INCR * .level), false, STUN_EFFECT, STUN_ATT_POINT)
                else
                    call Stun_UnitEx(.target, (STN_BASE + STN_INCR * .level), false, STUN_EFFECT, STUN_ATT_POINT)
                endif
                set DamageType = SPELL
                call UnitDamageTarget(.caster, .target, DMG_BASE + DMG_INCR * .level, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNKNOWN,WEAPON_TYPE_WHOKNOWS)
            endif
			
            call DOT.start(.caster, .target, DOT_DAMAGE[.level], DOT_TIME, ATT_TYPE, DMG_TYPE, EFFECT, ATT_POINT)
            
            call this.terminate()
        endmethod
		
		method onDestroy takes nothing returns nothing
            set .caster = null
			set .target = null
        endmethod
    endstruct
	
	private function Conditions takes nothing returns boolean
        return (GetSpellAbilityId() == SPELL_ID)
    endfunction

    private function Actions takes nothing returns nothing
		local ImpalingSpine is = 0
        
        set is = ImpalingSpine.create(GetTriggerUnit(), GetSpellTargetUnit())
    endfunction
	
	private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()

        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        set t = null
        
        call MainSetup()
		call Preload(MISSILE_MODEL)
        call Preload(EFFECT)
        call Preload(STUN_EFFECT)
        
        set t = null
    endfunction
endscope
