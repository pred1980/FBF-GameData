scope BladeThrow initializer init
    /*
     * Description: The Fire Panda throws his blades in the target direction, damaging all enemies they hit. 
                    Each blade can only hit an enemy once.
     * Last Update: 09.01.2014
     * Changelog: 
     *     	09.01.2014: Abgleich mit OE und der Exceltabelle
	 *		06.04.2015: Integrated SpellHelper for filtering and damaging
     */
    globals
        private constant integer SPELL_ID = 'A08Y'
        private constant string MISSILE_MODEL = "Models\\BladeThrowMissile.mdl"
        private constant real MISSILE_SCALE = 0.75
        private constant real MISSILE_SPEED = 750.00
        private constant real MISSILE_CURVE_FACTOR = 0.70
        private constant real MISSILE_CURVE_FACTOR_Z = 0.50
        private constant real MISSILE_HEIGHT = 45
        private constant real MISSILE_COLLISION_SIZE = 150.00
        private constant string ENHANCED_MISSILE_EFFECT = "Models\\ArtOfFireWeaponEffect.mdl"
		
		// Dealt damage configuration
		private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
		private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_FIRE
		private constant weapontype WEAPON_TYPE = WEAPON_TYPE_METAL_LIGHT_SLICE
		
        private real array MISSILE_DAMAGE
    endglobals
    
    private keyword Main
    
    private function MainSetup takes nothing returns nothing
        set MISSILE_DAMAGE[0] = 70.00
        set MISSILE_DAMAGE[1] = 90.00
        set MISSILE_DAMAGE[2] = 110.00
        set MISSILE_DAMAGE[3] = 130.00
        set MISSILE_DAMAGE[4] = 150.00
    endfunction
    
    private struct Blade
        private Main root = 0
        private beziermissile missile = 0
        private xefx fireEffect = 0
        
        integer id = 0
        group targetsHit = null
        boolean returning = false
        boolean enhanced = false
        
        static delegate xedamage dmg = 0
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(targetsHit)
        endmethod
        
        static method onCollision takes unit u, beziermissile b returns nothing
            local thistype this = thistype(b.customdata)
            
            if not IsUnitInGroup(u, targetsHit) then
                set DamageType = PHYSICAL
				call SpellHelper.damageTarget(root.caster, u, MISSILE_DAMAGE[root.lvl], true, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
				
                if enhanced then
                    call ArtOfFire_IgniteUnit(root.caster, u)
                endif
                call GroupAddUnit(targetsHit, u)
            endif
        
        endmethod
        
        static method onReturn takes beziermissile b returns nothing
            local thistype this = thistype(b.customdata)
            if enhanced then
                call fireEffect.destroy()
            endif
            call destroy()
        endmethod
        
        static method onLoop takes beziermissile b, real time returns nothing
            local thistype this = thistype(b.customdata)
            set fireEffect.x = missile.x
            set fireEffect.y = missile.y
            set fireEffect.z = missile.z
            set fireEffect.xyangle = missile.xyangle
            set fireEffect.zangle = missile.zangle
        endmethod
            
        static method onFinish takes beziermissile b returns nothing
            local thistype this = thistype(b.customdata)
            local real sx = missile.x
            local real sy = missile.y
            local beziermissile bm = beziermissile.createTargetSpeed(sx, sy, GetUnitFlyHeight(root.caster), root.caster, MISSILE_HEIGHT, MISSILE_SPEED)
            
            if id == 0 then
                call bm.setP1Rel(0.25, -MISSILE_CURVE_FACTOR, 0.00)
                call bm.setP2Rel(0.75, MISSILE_CURVE_FACTOR, MISSILE_CURVE_FACTOR_Z)
            else
                call bm.setP1Rel(0.25, MISSILE_CURVE_FACTOR, MISSILE_CURVE_FACTOR_Z)
                call bm.setP2Rel(0.75, -MISSILE_CURVE_FACTOR, 0.00)
            endif
            
            set bm.onEnd = thistype.onReturn
            set bm.onCollision = thistype.onCollision
            set bm.collisionrange = MISSILE_COLLISION_SIZE
            set bm.customdata = this
            set bm.zcollisionratio = 0.00
            set bm.collisionIgnoreImmune = true
            set bm.owner = GetOwningPlayer(root.caster)
            set bm.target = root.caster
            call bm.createFX(MISSILE_MODEL)
            set bm.scale = MISSILE_SCALE
            
            if enhanced then
                set bm.onLoop = thistype.onLoop
            endif
            
            set missile = bm
        endmethod
        
        static method create takes Main from, integer index returns thistype
            local thistype this = allocate()
            set root = from
            if from.target == null then
                set missile = beziermissile.createBasicSpeed(root.cx, root.cy, GetUnitFlyHeight(root.caster), root.x, root.y, MISSILE_HEIGHT, MISSILE_SPEED)
            else
                set missile = beziermissile.createTargetSpeed(root.cx, root.cy, GetUnitZ(root.caster), root.target, MISSILE_HEIGHT, MISSILE_SPEED)
                set missile.target = root.target
            endif
            set targetsHit = NewGroup()
            if index == 0 then
                call missile.setP1Rel(0.50, -MISSILE_CURVE_FACTOR, MISSILE_CURVE_FACTOR_Z)
                call missile.setP2Rel(0.75, MISSILE_CURVE_FACTOR, 0.00)
            else
                call missile.setP1Rel(0.50, MISSILE_CURVE_FACTOR, 0.00)
                call missile.setP2Rel(0.75, -MISSILE_CURVE_FACTOR, MISSILE_CURVE_FACTOR_Z)
            endif
            
            set id = index
            
            set missile.onEnd = thistype.onFinish
            set missile.onCollision = thistype.onCollision
            set missile.customdata = this
            set missile.collisionrange = MISSILE_COLLISION_SIZE
            set missile.zcollisionratio = 0.00
            set missile.collisionIgnoreImmune = true
            set missile.owner = GetOwningPlayer(root.caster)
            call missile.createFX(MISSILE_MODEL)
            set missile.scale = MISSILE_SCALE
            
            if ArtOfFire_GetLevel(root.caster) > 0 then
                set missile.onLoop = thistype.onLoop
                set fireEffect = xefx.create(missile.x, missile.y, missile.xyangle)
                set fireEffect.fxpath = ENHANCED_MISSILE_EFFECT
                set enhanced = true
            endif
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set dmg = xedamage.create()
            set atype = ATTACK_TYPE
            set dtype = DAMAGE_TYPE
            set wtype = WEAPON_TYPE
        endmethod
    
    endstruct

    private struct Main
        static constant integer spellId = SPELL_ID
        static constant integer spellType = SPELL_TYPE_TARGET_GROUND
        static constant boolean autoDestroy = false
        
        method onCast takes nothing returns nothing
            local integer i = 0
            
            set lvl = lvl - 1
            loop
                exitwhen i >= 2
                call Blade.create(this, i)
                set i = i + 1
            endloop
        endmethod
        
        implement Spell
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call Preload(MISSILE_MODEL)
        call Preload(ENHANCED_MISSILE_EFFECT)
    endfunction
    
endscope