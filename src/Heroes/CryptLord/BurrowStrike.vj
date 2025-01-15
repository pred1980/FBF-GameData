scope BurrowStrike initializer init
    /*
     * Description: The Crypt Lord burrows himself below the earth, becoming invisible and magic immune. 
                    He digs with 650 speed to the target location, creating a dangerous spike when coming out from 
                    that deals damage to enemies and throws them in the air.
     * Changelog: 
     *     06.11.2013: Abgleich mit OE und der Exceltabelle
	 *     29.03.2015: Integrated SpellHelper for damaging and filtering
	                   Changed ATTACK_TYPE and DAMAGE_TYPE to Spells
     *
     */
    globals
        private constant integer SPELL_ID = 'A06A'
        //set this to 0 if the hero should not get invisible
        private constant integer INVIS_DUMMY_ID = 'A06B'
        //set this to 0 if the hero should not get magic immune
        private constant integer MAGIC_IMMUNITY_DUMMY_ID = 'A06C'
        //if set to true, the caster will be disabled while digging so he wont turn arround to try to attack other units
        private constant boolean DISABLE_CASTER_WHILE_DIGGING = true
        private constant real TIMER_INTERVAL = 0.03125
        private real array IMPALE_HEIGHT
        private real array IMPALE_DURATION
        private real array BURROW_SPEED
    
        //Visual Options
        private constant boolean ADD_BURROW_EFFECT = true
        private constant string BURROW_EFFECT_PATH = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private constant real BURROW_EFFECT_SIZE = 1.00
        private constant real BURROW_EFFECT_Z_OFFSET = 25.00
        private constant real BURROW_EFFECT_SPAWN_INTERVAL = 0.25
        private constant string SPIKE_EFFECT_PATH = "Models\\BurrowStrike.mdx"
        private constant real SPIKE_EFFECT_SIZE = 0.75
        private constant real SPIKE_EFFECT_Z_OFFSET = 5.00
        
        //If true, a circle of spikes is created in the impact area too
        private constant boolean CREATE_SPIKE_CIRCLE = true
        private constant integer SPIKE_CIRCLE_AMOUNT = 10
        private real array SPIKE_CIRCLE_DISTANCE
        //Animation played by the hero while digging
        private constant integer CASTER_ANIMATION = 9
        //Animation played when the hero comes out from the earth
        private constant integer CASTER_END_ANIMATION = 8
   
        // Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
        private real array DAMAGE
        private real array DAMAGE_AREA
        private real array STUN_DURATION
    endglobals

    private function MainSetup takes nothing returns nothing
        set BURROW_SPEED[0] = 650.00
        set BURROW_SPEED[1] = 650.00
        set BURROW_SPEED[2] = 650.00
        set BURROW_SPEED[3] = 650.00
        set BURROW_SPEED[4] = 650.00
        
        set IMPALE_HEIGHT[0] = 200.00
        set IMPALE_HEIGHT[1] = 225.00
        set IMPALE_HEIGHT[2] = 250.00
        set IMPALE_HEIGHT[3] = 275.00
        set IMPALE_HEIGHT[4] = 300.00
        
        set IMPALE_DURATION[0] = 1.00
        set IMPALE_DURATION[1] = 1.00
        set IMPALE_DURATION[2] = 1.00
        set IMPALE_DURATION[3] = 1.00
        set IMPALE_DURATION[4] = 1.00
        
        set SPIKE_CIRCLE_DISTANCE[0] = 125
        set SPIKE_CIRCLE_DISTANCE[1] = 150
        set SPIKE_CIRCLE_DISTANCE[2] = 175
        set SPIKE_CIRCLE_DISTANCE[3] = 200
        set SPIKE_CIRCLE_DISTANCE[4] = 225
    
        set DAMAGE[0] = 80.00
        set DAMAGE[1] = 160.00
        set DAMAGE[2] = 240.00
        set DAMAGE[3] = 320.00
        set DAMAGE[4] = 400.00
        
        set DAMAGE_AREA[0] = 150.00
        set DAMAGE_AREA[1] = 175.00
        set DAMAGE_AREA[2] = 200.00
        set DAMAGE_AREA[3] = 225.00
        set DAMAGE_AREA[4] = 250.00
        
        set STUN_DURATION[0] = 1.50
        set STUN_DURATION[1] = 1.50
        set STUN_DURATION[2] = 1.50
        set STUN_DURATION[3] = 1.50
        set STUN_DURATION[4] = 1.50
    
    endfunction
    
    private struct BurrowStrike
        unit target = null
        real time = 0.00
        integer lvl = 0
        
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
            
            if count <= 0 then
                call PauseTimer(ticker)
            endif
        
        endmethod
        
        static method periodic takes nothing returns nothing
            local thistype this = first
            
            loop
                exitwhen this == 0
                call SetUnitZ(target, (4 * IMPALE_HEIGHT[lvl] / IMPALE_DURATION[lvl]) * (IMPALE_DURATION[lvl] - time) * (time / IMPALE_DURATION[lvl]))
                
                set time = time + TIMER_INTERVAL
                     
                if time >= IMPALE_DURATION[lvl] then
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

            set target = tar
            set lvl = level
            
            set t[target] = integer(this)
            
            call SetUnitX(target, GetUnitX(target))
            call SetUnitY(target, GetUnitY(target))
            call SetUnitPathing(target, false)
            
            call DisableUnit(target, true)
            
            call listAdd()
            if count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.periodic)
            endif
            return this
        endmethod
        
        
        static method onInit takes nothing returns nothing
            set t = HandleTable.create()
            set ticker = CreateTimer()
        endmethod    
    
    endstruct
    
    private struct Main
    
        static constant integer spellId = SPELL_ID
        static constant integer spellType = SPELL_TYPE_TARGET_GROUND
        static constant boolean autoDestroy = false
        
        static boolexpr targetFilter = null
        static timer ticker = null
        static thistype temp = 0
        static delegate xedamage dmg = 0
        
        real cos = 0.00
        real sin = 0.00
        real fxcounter = 0.00
        
        implement List
        
        method onDestroy takes nothing returns nothing
            call listRemove()
            
            if INVIS_DUMMY_ID != 0 then
                call UnitRemoveAbility(caster, INVIS_DUMMY_ID)
                call UnitMakeAbilityPermanent(caster, false, INVIS_DUMMY_ID)
            endif
            
            if MAGIC_IMMUNITY_DUMMY_ID != 0 then
                call UnitRemoveAbility(caster, MAGIC_IMMUNITY_DUMMY_ID)
                call UnitMakeAbilityPermanent(caster, false, MAGIC_IMMUNITY_DUMMY_ID)
            endif
            
            static if DISABLE_CASTER_WHILE_DIGGING then
                call DisableUnit(caster, false)
            endif
            
            if count <= 0 then
                call PauseTimer(ticker)
            endif
        endmethod
        
        static method targetFilterEnum takes nothing returns boolean
            local unit u = GetFilterUnit()
            local thistype this = temp
            
			if (SpellHelper.isValidEnemy(u, caster)) then
                set DamageType = PHYSICAL
				call SpellHelper.damageTarget(caster, u, DAMAGE[lvl], true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                call StunUnitTimed(u, STUN_DURATION[lvl])
                call BurrowStrike.create(caster, u, lvl)
            endif
            
            set u = null
            return false
        endmethod
        
        method spike takes nothing returns nothing
            local integer i = 0
            local real ang = GetRandomReal(0.00, bj_PI * 2)
            local xefx spike = xefx.create(cx, cy, GetRandomReal(0.00, bj_PI * 2))
            set spike.fxpath = SPIKE_EFFECT_PATH
            set spike.scale = SPIKE_EFFECT_SIZE
            set spike.z = SPIKE_EFFECT_Z_OFFSET
            call spike.destroy()
            static if CREATE_SPIKE_CIRCLE then
                loop
                    exitwhen i >= SPIKE_CIRCLE_AMOUNT
                    set spike = xefx.create(cx + SPIKE_CIRCLE_DISTANCE[lvl] * Cos(ang), cy + SPIKE_CIRCLE_DISTANCE[lvl] * Sin(ang), GetRandomReal(0.00, bj_PI * 2))
                    set spike.fxpath = SPIKE_EFFECT_PATH
                    set spike.scale = SPIKE_EFFECT_SIZE
                    set spike.z = SPIKE_EFFECT_Z_OFFSET
                    call spike.destroy()
                    set ang = ang + ((bj_PI * 2) / SPIKE_CIRCLE_AMOUNT)
                    set i = i + 1
                endloop
            endif
            call SetUnitAnimationByIndex(caster, CASTER_END_ANIMATION)
            call QueueUnitAnimation(caster, "stand")
            
            set temp = this
            call GroupEnumUnitsInRange(ENUM_GROUP, cx, cy, DAMAGE_AREA[lvl], targetFilter)
            
            call destroy()
        endmethod
        
        static method periodic takes nothing returns nothing
            local thistype this = first
            local xefx fx = 0
            
            loop
                exitwhen this == 0
                
                if GetWidgetLife(caster) > 0.405 then
                    if IsTerrainWalkable(cx, cy) then
                        set cx = cx + cos
                        set cy = cy + sin
                        
                        call SetUnitX(caster, cx)
                        call SetUnitY(caster, cy)
                        call SetUnitAnimationByIndex(caster, CASTER_ANIMATION)
                        
                        static if ADD_BURROW_EFFECT then
                            set fxcounter = fxcounter + TIMER_INTERVAL
                            if fxcounter >= BURROW_EFFECT_SPAWN_INTERVAL then
                                set fx = xefx.create(cx, cy, angle)
                                set fx.fxpath = BURROW_EFFECT_PATH
                                set fx.scale = BURROW_EFFECT_SIZE
                                set fx.z = BURROW_EFFECT_Z_OFFSET
                                call fx.destroy()
                                set fxcounter = 0.00
                            endif
                        endif
                    
                        set dist = dist - BURROW_SPEED[lvl] * TIMER_INTERVAL
                        
                        if dist <= 0.00 then
                            call spike()
                        endif
                    else
                        call spike()
                    endif
                else
                    call destroy()
                endif
                
                set this = next
            endloop
        endmethod
      
        method onCast takes nothing returns nothing
            set lvl = lvl - 1
            
            call listAdd()
            
            set cos = BURROW_SPEED[lvl] * TIMER_INTERVAL * Cos(angle) 
            set sin = BURROW_SPEED[lvl] * TIMER_INTERVAL * Sin(angle) 
            
            static if DISABLE_CASTER_WHILE_DIGGING then
                call DisableUnit(caster, true)
            endif

            if INVIS_DUMMY_ID != 0 then
                call UnitAddAbility(caster, INVIS_DUMMY_ID)
                call UnitMakeAbilityPermanent(caster, true, INVIS_DUMMY_ID)
            endif
            
            if MAGIC_IMMUNITY_DUMMY_ID != 0 then
                call UnitAddAbility(caster, MAGIC_IMMUNITY_DUMMY_ID)
                call UnitMakeAbilityPermanent(caster, true, MAGIC_IMMUNITY_DUMMY_ID)
            endif
            
            if count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.periodic)
            endif
        endmethod
        
        implement Spell

        static method onInit takes nothing returns nothing
            local integer i = 0
            call MainSetup()
            set ticker = CreateTimer()
            set targetFilter = Condition(function thistype.targetFilterEnum)
            set dmg = xedamage.create()
            set dtype = DAMAGE_TYPE
            set atype = ATTACK_TYPE
			set wtype = WEAPON_TYPE
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                call SetPlayerAbilityAvailable(Player(i), MAGIC_IMMUNITY_DUMMY_ID, false)
                set i = i + 1
            endloop
            
        endmethod
        
    endstruct
    
    private function init takes nothing returns nothing
        call XE_PreloadAbility(INVIS_DUMMY_ID)
        call XE_PreloadAbility(MAGIC_IMMUNITY_DUMMY_ID)
        call Preload(BURROW_EFFECT_PATH)
        call Preload(SPIKE_EFFECT_PATH)
    endfunction
    
endscope