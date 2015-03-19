scope NaturalSphere initializer init
    /*
     * Description: Cenarius summons a natural sphere flying in the target direction, dealing damage to enemies 
                    it passes through. Whenever the sphere hits an enemy, there is a chance of 20%, that the target 
                    gets entangled for a short time, which disables the target. If the target isnt rooted, 
                    its movement speed is decreased by 30% for 5 seconds.
     * Last Update: 08.01.2014
     * Changelog: 
     *     08.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A08D'
    endglobals

    //Missile Options
    globals
        private constant string MISSILE_MODEL_PATH = "Abilities\\Spells\\Undead\\DarkSummoning\\DarkSummonMissile.mdl" 
        private constant real MISSILE_MODEL_SIZE = 1.50
        private constant real MISSILE_SPEED = 350.00
        private constant real MISSILE_ACCELERATION = 500.00
        private constant real MISSILE_MAX_SPEED = 850.00
        private constant real MISSILE_Z_OFFSET = 75.00
        private constant real MISSILE_AREA = 225.00
        private real array MISSILE_DISTANCE
    endglobals
    
    //Entangle Options
    globals
        private real array ENTANGLE_CHANCE
        private real array ENTANGLE_DURATION
        //Wenn true, wird die Einheit slowed, wenn sie eingewurzelt wird
        private constant boolean SLOW_WHEN_ENTANGLED = false
    endglobals
    
    //Slow Options
    globals
        private constant integer NATURAL_SPHERE_SLOW_BUFF_PLACER_ID = 'A08E'
        private constant integer NATURAL_SPHERE_SLOW_BUFF_ID = 'B01O'
        private real array SLOW_DURATION
    endglobals
    
    //Damage Options
    globals
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private real array DAMAGE
    endglobals

    
    private function MainSetup takes nothing returns nothing
        set MISSILE_DISTANCE[0] = 550
        set MISSILE_DISTANCE[1] = 700
        set MISSILE_DISTANCE[2] = 850
        set MISSILE_DISTANCE[3] = 1000
        set MISSILE_DISTANCE[4] = 1150
        
        set DAMAGE[0] = 50
        set DAMAGE[1] = 100
        set DAMAGE[2] = 150
        set DAMAGE[3] = 200
        set DAMAGE[4] = 250
        
        set ENTANGLE_CHANCE[0] = 0.20
        set ENTANGLE_CHANCE[1] = 0.20
        set ENTANGLE_CHANCE[2] = 0.20
        set ENTANGLE_CHANCE[3] = 0.20
        set ENTANGLE_CHANCE[4] = 0.20
        
        set ENTANGLE_DURATION[0] = 1.50
        set ENTANGLE_DURATION[1] = 2.00
        set ENTANGLE_DURATION[2] = 2.50
        set ENTANGLE_DURATION[3] = 3.00
        set ENTANGLE_DURATION[4] = 3.50
        
        set SLOW_DURATION[0] = 5.00
        set SLOW_DURATION[1] = 5.00
        set SLOW_DURATION[2] = 5.00
        set SLOW_DURATION[3] = 5.00
        set SLOW_DURATION[4] = 5.00
    endfunction
    
    private keyword Main
    
    private struct Slow
    
        static integer buffType = 0
        unit target = null
        dbuff buff = 0
    
        static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod
        
        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            
            if b.isRefreshed then
                call thistype(b.data).destroy()
            endif
            
            set this = allocate()
            set b.data = integer(this)
            set target = b.target
            set buff = b
        endmethod

        static method apply takes unit source, unit target, real duration, integer lvl returns nothing
            call UnitAddBuff(source, target, buffType, duration, lvl + 1)
        endmethod
        
        static method onInit takes nothing returns nothing
            set buffType = DefineBuffType(NATURAL_SPHERE_SLOW_BUFF_PLACER_ID, NATURAL_SPHERE_SLOW_BUFF_ID, 0.00, false, false, thistype.onBuffAdd, 0, 0)
        endmethod

    endstruct
    
    private struct NaturalSphere extends xecollider
    
        unit caster = null
        integer lvl = 0
        group targets = null
        real moved = 0.00
        
        static delegate xedamage damage = 0
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(targets)
        endmethod   
        
        method loopControl takes nothing returns nothing
            set moved = moved + speed * XE_ANIMATION_PERIOD
            if moved >= MISSILE_DISTANCE[lvl] then
                call terminate()
            endif
        endmethod
        
        method onUnitHit takes unit u returns nothing
            if not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not /*
			*/     IsUnitInGroup(u, targets) and not /*
			*/     IsUnitType(u, UNIT_TYPE_FLYING) and /*
			*/     IsUnitEnemy(u, GetOwningPlayer(caster)) then
                set DamageType = 1
                call damageTarget(caster, u, DAMAGE[lvl])
                static if SLOW_WHEN_ENTANGLED then
                    if not IsUnitType(u, UNIT_TYPE_DEAD) and GetRandomReal(0.00, 1.00) <= ENTANGLE_CHANCE[lvl] then
                        call CenariusMain_EntangleUnit(caster, u, ENTANGLE_DURATION[lvl], lvl)
                        call Slow.apply(caster, u, SLOW_DURATION[lvl], lvl)
                    endif
                else
                    if not IsUnitType(u, UNIT_TYPE_DEAD) then
                        if GetRandomReal(0.00, 1.00) <= ENTANGLE_CHANCE[lvl] then
                            call CenariusMain_EntangleUnit(caster, u, ENTANGLE_DURATION[lvl], lvl)
                        else
                            call Slow.apply(caster, u, SLOW_DURATION[lvl], lvl)
                        endif
                    endif
                endif
                call GroupAddUnit(targets, u)
            endif
        endmethod
        
        static method create takes Main data returns thistype
            local thistype this = allocate(GetUnitX(data.caster), GetUnitY(data.caster), data.angle)
            
            set fxpath = MISSILE_MODEL_PATH
            set scale = MISSILE_MODEL_SIZE
            set collisionSize = MISSILE_AREA
            set speed = MISSILE_SPEED
            set acceleration = MISSILE_ACCELERATION
            set z = MISSILE_Z_OFFSET
            
            set targets = NewGroup()
            set caster = data.caster
            set lvl = data.lvl
            
            call setTargetPoint(x, y)            
            return this
        endmethod
            
         private static method onInit takes nothing returns nothing
            set damage = xedamage.create()
            set dtype = DAMAGE_TYPE
            set atype = ATTACK_TYPE
        endmethod
        
    endstruct
     
    private struct Main
        static constant integer spellId = SPELL_ID
        static constant integer spellType = SPELL_TYPE_TARGET_GROUND
        static constant boolean autoDestroy = true
        
        method onCast takes nothing returns nothing   
            set lvl = lvl - 1    
            set x = cx + MISSILE_DISTANCE[lvl] * Cos(angle)
            set y = cy + MISSILE_DISTANCE[lvl] * Sin(angle)
            call NaturalSphere.create(this)
        endmethod
        
        implement Spell
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(NATURAL_SPHERE_SLOW_BUFF_PLACER_ID)
        call Preload(MISSILE_MODEL_PATH)
    endfunction

endscope