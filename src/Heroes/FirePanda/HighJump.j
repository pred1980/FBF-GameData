scope HighJump initializer init
    /*
     * Description: The Fire Panda quickly jumps in the air moving to the target area, dealing damage to enemies he 
                    lands on and stuns them.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
	 *     19.03.2015: Added Conditions to the "knockbackFilter method" in the Jump struct
     */
    globals
        private constant integer SPELL_ID = 'A08X'
        private constant real JUMP_MIN_DISTANCE = 50.00
        private constant real JUMP_INITIAL_SPEED = 700.00
        private constant real JUMP_ACCELERATION = 750.00
        //This variable determines how strong the curve will be. Values between 0 and 1 are valid. 
        //The higher the amount of the value, the greater is the curve.
        //You can also use 0.00 if you want some kind of an barrel roll :D
        private constant real JUMP_CURVE_FACTOR = 0.60 //1.00
        private constant real TIMER_INTERVAL = 0.03125
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_HERO
        private constant string JUMP_MODEL = "Units\\Creeps\\FirePandarenBrewmaster\\FirePandarenBrewmaster_Missile.mdl"
        private constant real JUMP_MODEL_SCALE = 1.85
        private constant real JUMP_MODEL_Z_OFFSET = 75.00
        private constant string JUMP_IMPACT_MODEL = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
        private constant string JUMP_ENHANCED_IMPACT_MODEL = "Models\\HighJumpFireImpact.mdl"
        private constant real JUMP_IMPACT_AREA = 300.00
        private constant real KNOCKBACK_DURATION_ULTI = 1.50
        
        private real array KNOCKBACK_DISTANCE_ULTI
        private real array ULTI_IMPACT_DAMAGE
        
        private constant damagetype ULTI_IMPACT_DAMAGE_TYPE = DAMAGE_TYPE_FIRE
        private constant attacktype ULTI_IMPACT_ATTACK_TYPE = ATTACK_TYPE_MAGIC
        
        private real array JUMP_IMPACT_DAMAGE
        
        //Stun Effect
        private constant string STUN_EFFECT = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = 1.0
    endglobals
    
    
    private keyword Main
    
    private function MainSetup takes nothing returns nothing
        set JUMP_IMPACT_DAMAGE[0] = 60.00
        set JUMP_IMPACT_DAMAGE[1] = 110.00
        set JUMP_IMPACT_DAMAGE[2] = 160.00
        set JUMP_IMPACT_DAMAGE[3] = 210.00
        set JUMP_IMPACT_DAMAGE[4] = 260.00
        
        set KNOCKBACK_DISTANCE_ULTI[0] = 200.00
        set KNOCKBACK_DISTANCE_ULTI[1] = 275.00
        set KNOCKBACK_DISTANCE_ULTI[2] = 350.00
        
        set ULTI_IMPACT_DAMAGE[0] = 50.00
        set ULTI_IMPACT_DAMAGE[1] = 100.00
        set ULTI_IMPACT_DAMAGE[2] = 150.00
    endfunction
    
    private struct Jump extends xemissile
    
        delegate Main root = 0
        real acc = 0.00
        real spd = 0.00
        boolean enhanced = false
        
        static xedamage dmg = 0
        static xedamage ultidmg = 0
        static boolexpr doKnockback = null
        static thistype temp = 0
        static timer ticker = null

        static method knockbackFilter takes nothing returns boolean
            local unit u = GetFilterUnit()
            local real dx = GetUnitX(temp.caster) - GetUnitX(u)
            local real dy = GetUnitY(temp.caster) - GetUnitY(u)
            local real ang = Atan2(dy, dx) - bj_PI
            
			if (IsUnitEnemy(u, GetOwningPlayer(temp.caster)) and not /*
			*/ IsUnitDead(u) and not /*
			*/ IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not /*
			*/ IsUnitType(u, UNIT_TYPE_MECHANICAL)) then
                call Knockback.create(temp.caster, u, KNOCKBACK_DISTANCE_ULTI[ArtOfFire_GetLevel(temp.caster) - 1], KNOCKBACK_DURATION_ULTI, ang, 0, "", "")
                call Stun_UnitEx(u, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            endif
            
			set u = null
            
			return false
        endmethod
        
        method onHit takes nothing returns nothing
            call hiddenDestroy()
            call SetUnitPosition(caster, GetUnitX(caster), GetUnitY(caster))
            set cx = GetUnitX(caster)
            set cy = GetUnitY(caster)
            call SetUnitVertexColor(caster, 255, 255, 255, 255)
            
            call DestroyEffect(AddSpecialEffect(JUMP_IMPACT_MODEL, cx, cy))
            if enhanced then
                set temp = this
                call GroupRefresh(ENUM_GROUP)
                call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(caster), GetUnitY(caster), JUMP_IMPACT_AREA, doKnockback)
                call DestroyEffect(AddSpecialEffect(JUMP_ENHANCED_IMPACT_MODEL, cx, cy))
                call ultidmg.damageAOE(caster, GetUnitX(caster), GetUnitY(caster), JUMP_IMPACT_AREA, ULTI_IMPACT_DAMAGE[ArtOfFire_GetLevel(caster) - 1])
            endif
            call dmg.damageAOE(caster, GetUnitX(caster), GetUnitY(caster), JUMP_IMPACT_AREA, JUMP_IMPACT_DAMAGE[lvl])
            call DisableUnit(caster, false)
            call root.destroy()
        endmethod

        method loopControl takes nothing returns nothing
            call SetUnitX(caster, x)
            call SetUnitY(caster, y)
            set speed = speed + JUMP_ACCELERATION * XE_ANIMATION_PERIOD
        endmethod
            
        
        static method create takes Main from returns thistype
            local thistype this = 0 
            
            if from.dist < JUMP_MIN_DISTANCE then
                if from.dist > 0.00 then
                    set from.x = from.cx + JUMP_MIN_DISTANCE * Cos(from.angle)
                    set from.y = from.cy + JUMP_MIN_DISTANCE * Sin(from.angle)
                else
                    set from.x = from.cx + JUMP_MIN_DISTANCE * Cos(GetUnitFacing(from.caster) * bj_DEGTORAD)
                    set from.y = from.cy + JUMP_MIN_DISTANCE * Sin(GetUnitFacing(from.caster) * bj_DEGTORAD)
                endif
            endif
            
            set this = allocate(from.cx, from.cy, JUMP_MODEL_Z_OFFSET, from.x, from.y, JUMP_MODEL_Z_OFFSET)
            set root = from
            set fxpath = JUMP_MODEL
            set scale = JUMP_MODEL_SCALE
            
            if ArtOfFire_GetLevel(caster) > 0 then
                set enhanced = true
            endif
            
            call SetUnitVertexColor(caster, 255, 255, 255, 0)
            call launch(JUMP_INITIAL_SPEED, JUMP_CURVE_FACTOR)
            call DisableUnit(caster, true)
            return this
        endmethod
        
        
        static method onInit takes nothing returns nothing
            set dmg = xedamage.create()
            set dmg.atype = ATTACK_TYPE
            set dmg.dtype = DAMAGE_TYPE
            
            set ultidmg = xedamage.create()
            set ultidmg.atype = ULTI_IMPACT_ATTACK_TYPE
            set ultidmg.dtype = ULTI_IMPACT_DAMAGE_TYPE
            set ticker = CreateTimer()
            set doKnockback = Condition(function thistype.knockbackFilter)
        endmethod
    
    endstruct

    private struct Main
        static constant integer spellId = SPELL_ID
        static constant integer spellType = SPELL_TYPE_TARGET_GROUND
        static constant boolean autoDestroy = false
        
        method onCast takes nothing returns nothing
            set lvl = lvl - 1
            call Jump.create(this)
        endmethod
        
        implement Spell
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call Preload(JUMP_MODEL)
        call Preload(JUMP_IMPACT_MODEL)
        call Preload(JUMP_ENHANCED_IMPACT_MODEL)
    endfunction
    
endscope