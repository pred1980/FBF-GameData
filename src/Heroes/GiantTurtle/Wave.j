scope Wave initializer init
    /*
     * Description: The Giant Turtle summons a mighty wave behind him, flowing in the target direction. 
                    Once the wave reaches the Turtles position, he will surf on it to the impact area dealing 
                    damage to enemies in there. Units on the way are slighty pushed back and receive a small 
                    amount of damage.
     * Last Update: 10.01.2014
     * Changelog: 
     *     08.01.2014: Spell konnte noch nicht überprüft werden. Siehe Excelliste!!!
     *     10.01.2014: Abgleich mit OE und der Exceltabelle + Bugfixing
     */
    globals
        private constant integer SPELL_ID = 'A082'
        private constant string WAVE_EFFECT_MODEL = "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl"
        private constant real WAVE_EFFECT_SCALE = 1.75
        private constant real WAVE_EFFECT_Z_ANGLE = -90.00
        private constant real WAVE_EFFECT_INTERVAL = 0.125
        private constant real WAVE_EFFECT_HEIGTH = 75.00
        private constant real WAVE_SPEED = 850.00
        private constant real WAVE_CREATION_DISTANCE = 500.00
        private constant real WAVE_PUSHBACK_AREA = 150.00
        private constant real WAVE_PUSHBACK_DURATION = 0.75
        private constant real WAVE_PUSHBACK_DISTANCE = 300.00
        private constant real WAVE_IMPACT_AREA = 275.00
        private constant real WAVE_PICKUP_SURF_AREA = 100.00
        private constant real WAVE_CASTER_HEIGTH = 75.00
        private constant real ANIMATION_RESET_INTERVAL = 0.50
        private constant real ANIMATION_SPEED_FACTOR = 2.00
        private constant integer WAVE_CASTER_SURF_ANIMATION = 1
        private constant integer WAVE_CASTER_FINISH_ANIMATION = 12
        private constant attacktype WAVE_ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype WAVE_DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant string WAVE_DAMAGE_EFFECT = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl"
        private constant string WAVE_DAMAGE_EFFECT_ATTACH = "origin"
        
        private real array WAVE_PUSHBACK_DAMAGE
        private real array WAVE_END_DAMAGE
    endglobals


    private function MainSetup takes nothing returns nothing
        set WAVE_PUSHBACK_DAMAGE[0] = 35.00
        set WAVE_PUSHBACK_DAMAGE[1] = 55.00
        set WAVE_PUSHBACK_DAMAGE[2] = 75.00
        set WAVE_PUSHBACK_DAMAGE[3] = 95.00
        set WAVE_PUSHBACK_DAMAGE[4] = 115.00
        
        set WAVE_END_DAMAGE[0] = 80.00
        set WAVE_END_DAMAGE[1] = 120.00
        set WAVE_END_DAMAGE[2] = 160.00
        set WAVE_END_DAMAGE[3] = 200.00
        set WAVE_END_DAMAGE[4] = 240.00
    endfunction
    
    private keyword Wave
    private keyword Main
    
    private struct Wave extends xemissile
    
        Main root = 0
        boolean isSurfing = false
        real counter = 0.00
        real animreset = 0.00
        group targets = null
        
        static thistype temp = 0
        static boolexpr doPushback = null
        static delegate xedamage dmg = 0
        static HandleTable t = 0
        
        static method doPushbackEnum takes nothing returns boolean
            local unit u = GetFilterUnit()
            local thistype this = temp
            local real ang = Atan2(GetUnitY(u) - GetUnitY(root.caster), GetUnitX(u) - GetUnitX(root.caster))
            
            if IsUnitEnemy(root.caster, GetOwningPlayer(u)) and not IsUnitInGroup(u, targets) and not IsUnitDead(u) and not IsUnitType(u, UNIT_TYPE_MECHANICAL) then
                call GroupAddUnit(targets, u)
                call Knockback.create(root.caster, u, WAVE_PUSHBACK_DISTANCE, WAVE_PUSHBACK_DURATION, ang, 0, "", "")
                set DamageType = SPELL
                call damageTarget(root.caster, u, WAVE_PUSHBACK_DAMAGE[root.lvl])
            endif
            set u = null
            return false
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(targets)
            set t[root.caster] = 0
            call root.destroy()
        endmethod
        
        method onHit takes nothing returns nothing
            set DamageType = SPELL
            call damageAOE(root.caster, x, y, WAVE_IMPACT_AREA, WAVE_END_DAMAGE[root.lvl])
            //call SetUnitZ(root.caster, GetTerrainZ(x, y))
            if not IsUnitDead(root.caster) then
                call SetUnitAnimationByIndex(root.caster, WAVE_CASTER_FINISH_ANIMATION)
                call QueueUnitAnimation(root.caster, "stand")
                call SetUnitPathing(root.caster, true)
                call SetUnitTimeScale(root.caster, 1.00)
            endif
            call SetUnitPosition(root.caster, x, y)
            call SetUnitZ(root.caster, 0)
            set z = 0.00
            set zangle = 0.00
            call terminate()
        endmethod
        
        method loopControl takes nothing returns nothing
            local real factor = 0.00
            local real dx = GetUnitX(root.caster) - x
            local real dy = GetUnitY(root.caster) - y
            local real cdist = SquareRoot(dx * dx + dy * dy)
            
            set zangle = WAVE_EFFECT_Z_ANGLE
            set z = WAVE_EFFECT_HEIGTH
           
            set counter = counter + XE_ANIMATION_PERIOD
            if counter >= WAVE_EFFECT_INTERVAL then
                //call flash(WAVE_EFFECT_MODEL)
                call DestroyEffect(AddSpecialEffectTarget(WAVE_EFFECT_MODEL, root.caster,"origin"))
                set counter = 0.00
            endif
            
            set temp = this
            call GroupRefresh(ENUM_GROUP)
            call GroupEnumUnitsInRange(ENUM_GROUP, x, y, WAVE_PUSHBACK_AREA, doPushback)
            
            if cdist <= WAVE_PICKUP_SURF_AREA and not isSurfing and t[root.caster] == 0 and not IsUnitDead(root.caster)  then
                set isSurfing = true
                set t[root.caster] = 1
                call IssueImmediateOrder(root.caster, "stop")
                call SetUnitAnimation(root.caster, "stand")
                call SetUnitAnimationByIndex(root.caster, WAVE_CASTER_SURF_ANIMATION)
                call SetUnitTimeScale(root.caster, ANIMATION_SPEED_FACTOR)
                call SetUnitZ(root.caster, WAVE_CASTER_HEIGTH + GetTerrainZ(x, y))
            elseif isSurfing then
                if IsTerrainWalkable(this.x, this.y) then
                    call IssueImmediateOrder(root.caster, "stop")
                    call SetUnitX(root.caster, x)
                    call SetUnitY(root.caster, y)
                    call SetUnitZ(root.caster, WAVE_CASTER_HEIGTH)
                    call SetUnitFacing(root.caster, root.angle * bj_RADTODEG)
                    
                    set animreset = animreset + XE_ANIMATION_PERIOD
                    if animreset >= ANIMATION_RESET_INTERVAL then
                        call SetUnitAnimation(root.caster, "stand")
                        call SetUnitAnimationByIndex(root.caster, WAVE_CASTER_SURF_ANIMATION)
                        set animreset = 0.00
                    endif
                else
                    call onHit()
                endif
            endif
        endmethod
        
        static method create takes Main from returns thistype
            local thistype this = 0
            local real sx = GetUnitX(from.caster) + WAVE_CREATION_DISTANCE * Cos(from.angle - bj_PI)
            local real sy = GetUnitY(from.caster) + WAVE_CREATION_DISTANCE * Sin(from.angle - bj_PI)
            call SetUnitPathing(from.caster, false)
            set this = allocate(sx, sy, WAVE_EFFECT_HEIGTH, from.x, from.y, WAVE_EFFECT_HEIGTH)
            set scale = WAVE_EFFECT_SCALE
            set zangle = WAVE_EFFECT_Z_ANGLE
            set z = WAVE_EFFECT_HEIGTH
            set targets = NewGroup()
            call flash(WAVE_EFFECT_MODEL)
            call launch(WAVE_SPEED, 0.00)
            set root = from
            set root.lvl = root.lvl - 1
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set doPushback = Condition(function thistype.doPushbackEnum)
            set dmg = xedamage.create()
            set atype = WAVE_ATTACK_TYPE
            set dtype = WAVE_DAMAGE_TYPE
            call useSpecialEffect(WAVE_DAMAGE_EFFECT, WAVE_DAMAGE_EFFECT_ATTACH)
            set t = HandleTable.create()
        endmethod
    
    endstruct

    private struct Main
        static constant integer spellId = SPELL_ID
        static constant boolean autoDestroy = false
        static constant integer spellType = SPELL_TYPE_TARGET_GROUND
        
        method onCast takes nothing returns nothing
            call Wave.create(this)
        endmethod
        
        implement Spell
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call Preload(WAVE_EFFECT_MODEL)
        call Preload(WAVE_DAMAGE_EFFECT)
    endfunction
endscope