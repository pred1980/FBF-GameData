scope FountainBlast initializer init
    /*
     * Description: The Giant Turtle summons magical water projectiles, flying around him. After 5 seconds, 
                    the projectiles start to grow and withdraw and then splash down over 1.75 seconds, exploding on impact, 
                    which results in mighty water explosions, that throw enemies in 200 range in the air, dealing damage 
                    and slow them after falling back on the ground for 5 seconds. The projectiles can also be fired 
                    at a target area, causing them to explode on impact.
     * Last Update: 10.01.2014
     * Changelog: 
     *     10.01.2014: Abgleich mit OE und der Exceltabelle
	 *     19.03.2014: Flugzeit von getroffenen Einheiten durch die Projektile reduziert 
     */
    globals
        private constant integer SPELL_ID = 'A087'
        private constant integer FIRE_PROJECTILE_ID = 'A088'
        //Maximale Anzahl an Missiles pro Spell
        private constant integer MAX_MISSILE_AMOUNT = 6 
        private constant real TIMER_INTERVAL = 0.03125
    endglobals

    //Missile Options
    globals
        private constant string MISSILE_MODEL = "Models\\FountainBlastMissile.mdl"
        private constant real MISSILE_SIZE = 1.15
        // PI = 1/2 Umdrehung pro Sekunde
        private constant real MISSILE_TURN_SPEED = bj_PI * 1.2
        private constant real MISSILE_HEIGHT = 75.00
        private constant real MISSILE_MIN_DISTANCE = 150.00
        private constant real MISSILE_MAX_DISTANCE = 425.00
        private integer array MISSILE_AMOUNT
        
        //Advanced Missile Options
        
        /*Wenn dieser Wert auf true gesetzt wird, wird die Explosion zwar ein wenig delayed, aber sieht daf?r geiler aus :D
          Die Kugeln werden erst nach oben schweben, werden dabei gr??er und fallen dann ganz schnell auf den Boden
          
          Mit diesen Einstellungen werden genau 1.75 Sekunden ben?tigt. Bin gr??tenteils durch stundenlanges Rechnen auf 
          diese Werte gekommen, damits auch mehr oder weniger gut aussieht.. :P
        */
        private constant boolean MISSILE_EXPLOSION_EYE_CANDY = true
        private constant real MISSILE_EYE_CANDY_SIZE = 2.5
        
        //Sollte das benutzte Missile ne eigene Death Animation haben, wird es kurz davor auf diesen Wert skalliert,
        //damit dieser Effekt unter Umst?nden nicht zu gro? dargestellt wird..
        private constant real MISSILE_EYE_CANDY_EXPLOSION_SIZE = 1.75
        private constant real MISSILE_EYE_CANDY_UP_START_SPEED = 60.00
        private constant real MISSILE_EYE_CANDY_UP_ACCELERATION = 285.00
        private constant real MISSILE_EYE_CANDY_UP_END_HEIGHT = 375.00
        private constant real MISSILE_EYE_CANDY_DOWN_START_SPEED = 1750.00
        private constant real MISSILE_EYE_CANDY_DOWN_ACCELERATION = 1250.00
        
        //Wenn true, folgen die Missiles noch dem Hero, sieht meiner Meinung nach kacke aus...
        private constant boolean MISSILE_EYE_CANDY_FOLLOW_HERO = false
        
        //Options for Launching
        private constant real MISSILE_LAUNCH_SPEED = 450.00
        private constant real MISSILE_LAUNCH_ACCELERATION = 300.00
    endglobals
    
    //Explosion Options
    globals
        private constant string EXPLOSION_MODEL = "Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl"
        private constant real EXPLOSION_EFFECT_SIZE = 0.95
        private constant real EXPLOSION_RANGE = 200.00
        private constant real EXPLOSION_DELAY = 10.00
        private constant real EXPLOSION_START_SPEED = 850.00
        private constant real EXPLOSION_ACCELERATION = -1888.00//-971.43
        //Formel f?r die Zeit:
        // (StartSpeed / |Acceleration|) * 2
        //Hier: (850 / 971.43) * 2 ~= 1.75
        private constant attacktype EXPLOSION_ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype EXPLOSION_DAMAGE_TYPE = DAMAGE_TYPE_COLD
        private real array EXPLOSION_DAMAGE
    endglobals
    
    //Evaporate Options
    globals
        private constant boolean EVAPORATE_ON_DEAD = true
        private constant real EVAPORATE_DURATION = 1.50
        private constant real EVAPORATE_SPEED = 300.00
    endglobals
    
    
    //Buff Options
    globals
        private constant integer BUFF_PLACER_ID = 'A089'
        private constant integer BUFF_ID = 'B01L'
        private constant real BUFF_DURATION = 10.00
        /*
          Wenn true, wird der Buff bereits beim hochwerfen auf die Einheit applied.
          Wenn false, wird der Buff beim Aufprall auf den Boden applied.
          Es macht keinen Unterschied von der Zeit her, wenn der Buff schon beim Start applied
          wird, da die Duration automatisch vom Code um die Flugzeit erh?ht wird!
        */
        private constant boolean BUFF_APPLY_ON_TOSS_START = true
    endglobals
    
    
    private function MainSetup takes nothing returns nothing
        set MISSILE_AMOUNT[0] = 4
        set MISSILE_AMOUNT[1] = 5
        set MISSILE_AMOUNT[2] = 6
        
        set EXPLOSION_DAMAGE[0] = 125.00
        set EXPLOSION_DAMAGE[1] = 200.00
        set EXPLOSION_DAMAGE[2] = 275.00
    endfunction
    
    
    private keyword Projectile
    private keyword Main
    private keyword Tosser
    private keyword SlowBuff
    
    private struct Tosser
        unit target = null
        unit source = null
        integer lvl = 0
        boolean movingUp = true
        real curSpeed = EXPLOSION_START_SPEED
        
        real time = 0.00
        
        static constant real totalTime = (EXPLOSION_START_SPEED / RAbsBJ(EXPLOSION_ACCELERATION)) * 2
        static HandleTable t = 0
        static timer ticker = null
        static delegate xedamage dmg = 0
        static integer buffType = 0
        
        implement List
        
        method onDestroy takes nothing returns nothing
        
            call t.flush(target)
            call listRemove()

            call DisableUnit(target, false)
            
            call SetUnitPathing(target, true)
            call SetUnitPosition(target, GetUnitX(target), GetUnitY(target))
            
            call SetUnitZ(target, 0.00)
            
            static if not BUFF_APPLY_ON_TOSS_START then
                call UnitAddBuff(source, target, buffType, BUFF_DURATION, lvl + 1)
            endif
            
            
            if count <= 0 then
                call PauseTimer(ticker)
            endif
        
        endmethod
        
        static method periodic takes nothing returns nothing
            local thistype this = first
            
            loop
                exitwhen this == 0
                call SetUnitZ(target, GetUnitZ(target) + curSpeed * TIMER_INTERVAL)
                
                set time = time + TIMER_INTERVAL
                
                set curSpeed = curSpeed + EXPLOSION_ACCELERATION * TIMER_INTERVAL
                     
                
                if time >= totalTime then
                    call destroy()
                endif
                    
                set this = next
            endloop
        endmethod
        
        static method create takes unit caster, unit tar, integer level returns thistype
            local thistype this = 0
            
            if t[tar] != 0 then
                return thistype(t[tar])
            endif
            set this = allocate()
            
            set source = caster
            set target = tar
            set lvl = level
            
            set t[target] = integer(this)
            
            call SetUnitX(target, GetUnitX(target))
            call SetUnitY(target, GetUnitY(target))
            call SetUnitPathing(target, false)
            
            call DisableUnit(target, true)
            
            static if BUFF_APPLY_ON_TOSS_START then
                call UnitAddBuff(source, target, buffType, BUFF_DURATION + totalTime, lvl + 1)
            endif
                
            set DamageType = 1
            call damageTarget(source, target, EXPLOSION_DAMAGE[lvl])
            
            call listAdd()
            if count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.periodic)
            endif
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set t = HandleTable.create()
            set ticker = CreateTimer()
            set dmg = xedamage.create()
            set dtype = EXPLOSION_DAMAGE_TYPE
            set atype = EXPLOSION_ATTACK_TYPE
            
            set buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0.00, false, false, 0, 0, 0)
        endmethod    
    endstruct
    
    private struct Explosion extends array
    
        static unit tempUnit = null
        static unit tempUnitTar = null
        static integer tempInt = 0
        
        static boolexpr explosionTargetFilter = null
        
        static method explosionFilter takes nothing returns boolean
            
            set tempUnitTar = GetFilterUnit()
            if IsUnitEnemy(tempUnit, GetOwningPlayer(tempUnitTar)) and not IsUnitType(tempUnitTar, UNIT_TYPE_DEAD) and not IsUnitType(tempUnitTar, UNIT_TYPE_MECHANICAL) then
                call Tosser.create(tempUnit, tempUnitTar, tempInt)
            endif
            return false
        endmethod
        
        static method spawn takes unit owner, real tx, real ty, integer lvl returns nothing
            local xefx exp = 0
            
            set tempUnit = owner
            set tempInt = lvl
            
            if EXPLOSION_MODEL != "" then
                set exp = xefx.create(tx, ty, GetRandomReal(0.00, 2 * bj_PI))
                set exp.scale = EXPLOSION_EFFECT_SIZE
                set exp.fxpath = EXPLOSION_MODEL
                call exp.destroy()
            endif
            
            call GroupEnumUnitsInArea(ENUM_GROUP, tx, ty, EXPLOSION_RANGE, explosionTargetFilter)
        endmethod 

        private static method onInit takes nothing returns nothing
            set explosionTargetFilter = Condition(function thistype.explosionFilter)
        endmethod
    
    endstruct
    
    private struct HomingProjectile extends xemissile
        unit owner = null
        integer lvl = 0
        
        method explode takes nothing returns nothing
            set zangle = 0.00
            set scale = MISSILE_EYE_CANDY_EXPLOSION_SIZE
            call Explosion.spawn(owner, x, y, lvl)
            call terminate()
        endmethod
        
        method onHit takes nothing returns nothing
            call explode()
        endmethod
        
        method loopControl takes nothing returns nothing
            set speed = speed + MISSILE_LAUNCH_ACCELERATION * XE_ANIMATION_PERIOD
        endmethod
            
        static method create takes Projectile from, real tx, real ty returns thistype
            local real dist = 0.00
            local thistype this = 0
            
            set this = allocate(from.x, from.y, MISSILE_HEIGHT, tx, ty, MISSILE_HEIGHT)
            set fxpath = MISSILE_MODEL
            set scale = MISSILE_SIZE
            set owner = from.owner
            set lvl = from.lvl
            
            call launch(MISSILE_LAUNCH_SPEED, GetRandomReal(0.60, 0.90))            
            return this
        endmethod
    endstruct
    
    private struct Projectile
        real missileAngle = 0.00
        real missileDist = 0.00
        
        delegate xefx missile = 0
        
        unit owner = null
        integer lvl = 0
        
        static method create takes Main root, real ang returns thistype
            local thistype this = allocate()
            local real facing = 0.00
            local real dist = 0.00
            
            set dist = GetRandomReal(MISSILE_MIN_DISTANCE, MISSILE_MAX_DISTANCE)
            set facing = Atan2(root.cy + dist * Sin(ang) - root.cy, root.cx + dist * Cos(ang) - root.cx) + bj_PI / 2
            set missile = xefx.create(root.cx + dist * Cos(ang), root.cy + dist * Sin(ang), facing)
            set fxpath = MISSILE_MODEL
            set z = MISSILE_HEIGHT
            set scale = MISSILE_SIZE
            set missileAngle = ang
            set missileDist = dist
            set owner = root.caster
            set lvl = root.lvl
            
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            call missile.destroy()
        endmethod
        
        method explode takes nothing returns nothing
            set zangle = 0.00
            set scale = MISSILE_EYE_CANDY_EXPLOSION_SIZE
            call Explosion.spawn(owner, x, y, lvl)
            call destroy()
        endmethod
        
        method convertToHomingMissile takes real tx, real ty returns nothing
            call HomingProjectile.create(this, tx, ty)
            call hiddenDestroy()
        endmethod
    endstruct
    
    private struct Main
        static constant integer spellId = SPELL_ID
        static constant integer spellType = SPELL_TYPE_NO_TARGET
        static constant boolean autoDestroy = false
        static constant real upTime = (MISSILE_EYE_CANDY_UP_END_HEIGHT -  MISSILE_EYE_CANDY_UP_START_SPEED) / MISSILE_EYE_CANDY_UP_ACCELERATION
        static constant real growthPerSec = (MISSILE_EYE_CANDY_SIZE - MISSILE_SIZE) / upTime * TIMER_INTERVAL
        static boolean array learned
        static HandleTable t = 0
        
        Projectile array missile[MAX_MISSILE_AMOUNT]
        boolean array isActive[MAX_MISSILE_AMOUNT]
        
        real time = EXPLOSION_DELAY
        real eyeCandyTime = 0.00
        real currentZ = MISSILE_HEIGHT
        real currentScale = MISSILE_SIZE
        boolean eyeCandyMode = false
        real speedZ = MISSILE_EYE_CANDY_UP_START_SPEED
        boolean falling = false
        integer missilesLeft = 0
        boolean didReset = false
        boolean casterDead = false
        boolean evaporating = false
        
        static timer ticker = null
        
        implement List  
        
        method disableFireMode takes nothing returns nothing
            if not didReset then
                call SetPlayerAbilityAvailable(GetOwningPlayer(caster), SPELL_ID, true)
                call SetPlayerAbilityAvailable(GetOwningPlayer(caster), FIRE_PROJECTILE_ID, false)
                call t.flush(caster)
                set didReset = true
            endif
        endmethod
        
        method onDestroy takes nothing returns nothing
            call listRemove()
                        
            if count <= 0 then
                call PauseTimer(ticker)
            endif
            
            call disableFireMode()
        endmethod
        
        method forceExplosion takes boolean doToss returns nothing
            local integer i = 0
            
            loop
                exitwhen i >= MISSILE_AMOUNT[lvl]
                
                if isActive[i] then
                    if doToss then
                        call missile[i].explode()
                    else
                        call missile[i].destroy()
                    endif
                endif
                
                set i = i + 1
            endloop
            
            call destroy()
        endmethod
        
        static method periodic takes nothing returns nothing
            local thistype this = first
            local integer i = 0
            
            loop
                exitwhen this == 0
                
                set time = time - TIMER_INTERVAL
                
                if time <= 0.00 and not eyeCandyMode then
                    static if MISSILE_EXPLOSION_EYE_CANDY then
                        if evaporating then
                            call forceExplosion(false)
                        else
                            set eyeCandyMode = true      
                            call disableFireMode()
                        endif
                    else
                        call forceExplosion(not evaporating)
                    endif
                else
                    
                    if IsUnitType(caster, UNIT_TYPE_DEAD) and not casterDead then
                        set casterDead = true
                        set evaporating = true
                        call disableFireMode()
                        set time = EVAPORATE_DURATION
                    endif
                
                    if not eyeCandyMode then
                        loop
                            exitwhen i >= MISSILE_AMOUNT[lvl]
                            
                            if missile[i] != 0 then
                                if casterDead and EVAPORATE_ON_DEAD then
                                    set missile[i].z = missile[i].z + (EVAPORATE_SPEED / EVAPORATE_DURATION) * TIMER_INTERVAL
                                    set missile[i].alpha = missile[i].alpha - R2I(((255 / EVAPORATE_DURATION) * TIMER_INTERVAL) + 0.50)
                                else   
                                    set missile[i].missileAngle = missile[i].missileAngle + MISSILE_TURN_SPEED * TIMER_INTERVAL
                                    set missile[i].x = GetUnitX(caster) + missile[i].missileDist * Cos(missile[i].missileAngle)
                                    set missile[i].y = GetUnitY(caster) + missile[i].missileDist * Sin(missile[i].missileAngle)
                                    set missile[i].xyangle = Atan2(missile[i].y - GetUnitY(caster), missile[i].x - GetUnitX(caster)) + bj_PI / 2
                                endif
                            endif
        
                            set i = i + 1
                        endloop
                        
                    else
                        
                        if not falling then
                            set speedZ = speedZ + MISSILE_EYE_CANDY_UP_ACCELERATION * TIMER_INTERVAL
                            set currentScale = currentScale + growthPerSec
                        else
                            set speedZ = speedZ + MISSILE_EYE_CANDY_DOWN_ACCELERATION * TIMER_INTERVAL
                        endif
                        
                        set eyeCandyTime = eyeCandyTime + TIMER_INTERVAL
                        
                        static if MISSILE_EYE_CANDY_FOLLOW_HERO then
                            if IsUnitType(caster, UNIT_TYPE_DEAD) and not casterDead then
                                set casterDead = true
                            endif
                        endif
                        
                        loop
                            exitwhen i >= MISSILE_AMOUNT[lvl]
                            
                            if missile[i] != 0 then
                                if not falling then
                                    set missile[i].z = missile[i].z + speedZ * TIMER_INTERVAL
                                    set missile[i].scale = currentScale
                                    set missile[i].zangle = 90.00
                                else
                                    set missile[i].z = missile[i].z - speedZ * TIMER_INTERVAL
                                    set missile[i].zangle = -90.00
                                endif
                            
                                static if MISSILE_EYE_CANDY_FOLLOW_HERO then
                                    if not casterDead then
                                        set missile[i].x = GetUnitX(caster) + missile[i].missileDist * Cos(missile[i].missileAngle)
                                        set missile[i].y = GetUnitY(caster) + missile[i].missileDist * Sin(missile[i].missileAngle)
                                    endif
                                endif
                            
                            endif

                            set i = i + 1
                        
                        endloop
                        
                        if falling then
                            set currentZ = currentZ - speedZ * TIMER_INTERVAL
                        else
                            set currentZ = currentZ + speedZ * TIMER_INTERVAL
                        endif
                        
                        if eyeCandyTime >= upTime and not falling then
                            set falling = true
                            set speedZ = MISSILE_EYE_CANDY_DOWN_START_SPEED
                        elseif currentZ <= MISSILE_HEIGHT then
                            call forceExplosion(true)
                        endif
                        
                    endif
                    
                endif
                
                set i = 0
                set this = next
            endloop
            
        endmethod
        
        method fireProjectile takes real tx, real ty returns nothing
            local integer i = GetRandomInt(0, MISSILE_AMOUNT[lvl])
            
            loop
                
                if isActive[i] then
                    set missilesLeft = missilesLeft - 1
                    
                    call missile[i].convertToHomingMissile(tx, ty)
                    set isActive[i] = false
                    
                    if missilesLeft <= 0 then
                        call destroy()
                    endif
                    
                    exitwhen true
                endif
                
                exitwhen isActive[i]                
                set i = GetRandomInt(0, MISSILE_AMOUNT[lvl])
            endloop
        endmethod
        
        
        method onCast takes nothing returns nothing
            local real ang = GetRandomReal(0.00, 2 * bj_PI)
            local integer i = 0
        
            set lvl = lvl - 1
            loop
                exitwhen i >= MISSILE_AMOUNT[lvl]
                set missile[i] = Projectile.create(this, ang)
                set ang = ang + ((bj_PI * 2) / MISSILE_AMOUNT[lvl])
                set isActive[i] = true
                set i = i + 1
            endloop
            
            set t[caster] = integer(this)
            call SetPlayerAbilityAvailable(GetOwningPlayer(caster), SPELL_ID, false)
            call SetPlayerAbilityAvailable(GetOwningPlayer(caster), FIRE_PROJECTILE_ID, true)
            if GetUnitAbilityLevel(caster, FIRE_PROJECTILE_ID) == 0 then
                call UnitAddAbility(caster, FIRE_PROJECTILE_ID)
            endif
            call SetUnitAbilityLevel(caster, FIRE_PROJECTILE_ID, lvl + 1)
            
            set missilesLeft = MISSILE_AMOUNT[lvl]
            call listAdd()
            
            if count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.periodic)
            endif
            
        endmethod
        
        static method onLearn takes unit u returns nothing
            local integer i = GetPlayerId(GetOwningPlayer(u))
            //THIS METHOD IS FASTER, BUT SO THE SPELL ONLY IS MPI, NOT MUI!!!
            if not learned[i] then
                call UnitAddAbility(u, FIRE_PROJECTILE_ID)
                call SetPlayerAbilityAvailable(GetOwningPlayer(u), FIRE_PROJECTILE_ID, false)
                set learned[i] = true
            endif
        endmethod
        
        static method onSubCast takes nothing returns boolean
            if thistype(t[GetTriggerUnit()]) == 0 or GetSpellAbilityId() != FIRE_PROJECTILE_ID then
                return false
            endif
            call thistype(t[GetTriggerUnit()]).fireProjectile(GetSpellTargetX(), GetSpellTargetY())
            return false
        endmethod
        
        
        implement Spell
        
        static method onInit takes nothing returns nothing
            local trigger trig = CreateTrigger()
            set ticker = CreateTimer()
            set t = HandleTable.create()
            
            call TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddCondition(trig, Condition(function thistype.onSubCast))
        endmethod
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(FIRE_PROJECTILE_ID)
        call XE_PreloadAbility(BUFF_PLACER_ID)
        call Preload(MISSILE_MODEL)
        call Preload(EXPLOSION_MODEL)
    endfunction
    
endscope