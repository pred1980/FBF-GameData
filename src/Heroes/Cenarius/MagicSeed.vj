scope MagicSeed initializer init
    /*
     * Description: Cenarius throws a magic seed at the target unit, dealing damage. If the target is entangled, 
                    the target will receive additional damage and creates an explosion that damages other enemies around it.
     * Changelog: 
     *     08.01.2014: Abgleich mit OE und der Exceltabelle
	 *     28.03.2015: Integrated SpellHelper for damaging and filtering
     */
    globals
        private constant integer SPELL_ID = 'A08F'
        private constant string MAGIC_SEED_MODEL_PATH = "Models\\MagicSeedMissile.mdl"
        private constant real MAGIC_SEED_MODEL_SIZE = 1.65
        private constant real MAGIC_SEED_SPEED = 675.00
        private constant real MAGIC_SEED_HEIGHT = 25.00
        private constant real MAGIC_SEED_START_HEIGHT = 250.00
        private constant real MAGIC_SEED_RADIUS = 225.00
        private constant string MAGIC_SEED_EXPLOSION_PATH = "Models\\MagicSeedExplosion.mdl"
        private constant real MAGIC_SEED_EXPLOSION_MODEL_SIZE = 0.50
        
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_POISON
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
		private real array MAGIC_SEED_MAIN_DAMAGE
        private real array MAGIC_SEED_ENTANGLED_DAMAGE
        private real array SEED_AREA_DAMAGE
    endglobals
    
    
    private function MainSetup takes nothing returns nothing
        set MAGIC_SEED_MAIN_DAMAGE[0] = 75.00
        set MAGIC_SEED_MAIN_DAMAGE[1] = 125.00
        set MAGIC_SEED_MAIN_DAMAGE[2] = 175.00
        set MAGIC_SEED_MAIN_DAMAGE[3] = 225.00
        set MAGIC_SEED_MAIN_DAMAGE[4] = 275.00
        
        set MAGIC_SEED_ENTANGLED_DAMAGE[0] = 25.00
        set MAGIC_SEED_ENTANGLED_DAMAGE[1] = 50.00
        set MAGIC_SEED_ENTANGLED_DAMAGE[2] = 75.00
        set MAGIC_SEED_ENTANGLED_DAMAGE[3] = 100.00
        set MAGIC_SEED_ENTANGLED_DAMAGE[4] = 125.00
        
        set SEED_AREA_DAMAGE[0] = 50
        set SEED_AREA_DAMAGE[1] = 75
        set SEED_AREA_DAMAGE[2] = 100
        set SEED_AREA_DAMAGE[3] = 125
        set SEED_AREA_DAMAGE[4] = 150
    endfunction
    
    private struct MagicSeedMissile extends xehomingmissile
        unit caster = null
        integer lvl = 0
        
        static thistype temp = 0
        static delegate xedamage dmg = 0
        static boolexpr explosionFilter = null
            
        static method create takes unit from, unit to, integer lv returns thistype
            local thistype this = allocate(GetUnitX(from), GetUnitY(from), GetUnitFlyHeight(from) + MAGIC_SEED_START_HEIGHT, to, MAGIC_SEED_HEIGHT)
            set fxpath = MAGIC_SEED_MODEL_PATH
            set scale = MAGIC_SEED_MODEL_SIZE
            set caster = from
            set lvl = lv
            call launch(MAGIC_SEED_SPEED, GetRandomReal(0.0, 0.25))
            return this
        endmethod
        
        static method explosionFilterEnum takes nothing returns boolean
            local thistype this = temp
            local unit u = GetFilterUnit()
            
			if (SpellHelper.isValidEnemy(u, caster) and not /*
			*/  SpellHelper.isUnitImmune(u)) then
                set DamageType = SPELL
				call SpellHelper.damageTarget(caster, u, SEED_AREA_DAMAGE[lvl], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            endif
            
			set u = null
            
			return false
        endmethod
        
        method onHit takes nothing returns nothing
            local xefx explosion = 0
            call terminate()
            if not SpellHelper.isUnitDead(targetUnit) then
				set DamageType = SPELL
                if CenariusMain_IsUnitEntangled(targetUnit) then
                    if MAGIC_SEED_EXPLOSION_PATH != "" then
                        set explosion = xefx.create(GetUnitX(targetUnit), GetUnitY(targetUnit), GetRandomReal(0.00, bj_PI * 2))
                        set explosion.fxpath = MAGIC_SEED_EXPLOSION_PATH
                        set explosion.scale = MAGIC_SEED_EXPLOSION_MODEL_SIZE
                        call explosion.destroy()
                    endif
                    call SpellHelper.damageTarget(caster, targetUnit, MAGIC_SEED_MAIN_DAMAGE[lvl] + MAGIC_SEED_ENTANGLED_DAMAGE[lvl], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                    set temp = this
                    call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(targetUnit), GetUnitY(targetUnit), MAGIC_SEED_RADIUS, explosionFilter)
                else
					call SpellHelper.damageTarget(caster, targetUnit, MAGIC_SEED_MAIN_DAMAGE[lvl], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                endif
            endif
        endmethod
        
        static method onInit takes nothing returns nothing
            set explosionFilter = Condition(function thistype.explosionFilterEnum)
            set dmg = xedamage.create()
            set dtype = DAMAGE_TYPE
            set atype = ATTACK_TYPE
			set wtype = WEAPON_TYPE
        endmethod
    endstruct

    
    private struct Main
        static constant integer spellId = SPELL_ID
        static constant integer spellType = SPELL_TYPE_TARGET_UNIT
        static constant boolean autoDestroy = true
        
        method onCast takes nothing returns nothing
            call MagicSeedMissile.create(caster, target, lvl - 1)
        endmethod
            
        implement Spell
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call Preload(MAGIC_SEED_MODEL_PATH)
        call Preload(MAGIC_SEED_EXPLOSION_PATH)
    endfunction

endscope