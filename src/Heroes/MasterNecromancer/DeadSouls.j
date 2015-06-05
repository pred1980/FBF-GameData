scope DeadSouls initializer init //requires SpellSystem, ListModule, xemissile, xedamage, GroupUtils
    /*
     * Description: The Death Master calls forth vile souls to help him in his fight. 
                    He summons magical ghosts over 12 seconds, flying to enemies around him and dealing damage on impact.
     * Changelog: 
     *     	05.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	28.03.2014: Anzahl der Missiles von 120 auf 20 reduziert 
	 *		21.04.2015: Integrated SpellHelper for filtering
						Code Refactoring
	 *		27.05.2015: Increased damage per missile from 60/120/180 to 120/180/240
     *
     */
    globals
        private constant integer SPELL_ID = 'A08Z'
        private constant real SPELL_DURATION = 12.00
        private constant real MISSILE_SPAWN_INTERVAL = 0.6 //Total Missiles: SPELL_DURATION / MISSILE_SPAWN_INTERVAL (20 here)
        private constant real TIMER_INTERVAL = 0.05 //Should be divisible with MISSILE_SPAWN_INTERVAL without rest (here it would be 2)
        private constant real SPELL_AREA_OF_EFFECT = 750.00
        private constant boolean STOP_IF_CASTER_DEAD = true
        private constant string MISSILE_MODEL = "Models\\SpiritDragonMissile(Dark).mdx"
        private constant string MISSILE_COLLISION_MODEL = "Models\\darkbirth.mdx"
        private constant real MISSILE_SIZE = 0.90
        private constant real MISSILE_Z_OFFSET = 15.00
        private constant real MISSILE_MIN_START_Z = 400.00
        private constant real MISSILE_MAX_START_Z = 600.00
        private constant integer MISSILE_START_ALPHA = 100
        private constant integer MISSILE_ALPHA_GAIN = 31 //Alpha-Increase per Second, here 52, makes 255 Alpha after ca. 5 seconds fly duration
        private constant real MISSILE_START_SPEED = 175.00
        private constant real MISSILE_ACCELERATION = 105.00 //Acceleration per Second, here 105.00, makes 700 Speed after 5 seconds fly duration
        private constant real MISSILE_MAX_SPEED = 700.00
        private constant boolean MISSILE_RANDOM_COLOR = false //If true, the missiles will have a random team color
    
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
		private real array MISSILE_DAMAGE
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set MISSILE_DAMAGE[1] = 120
        set MISSILE_DAMAGE[2] = 180
        set MISSILE_DAMAGE[3] = 240
    endfunction
    
    //The actual missile, using a xemissile
    private struct Missile extends xehomingmissile
        private unit owner = null
        private unit target = null
        private real currentSpeed = MISSILE_START_SPEED
        private real currentAlpha = I2R(MISSILE_START_ALPHA)
        
        private static delegate xedamage damager = 0
        
        private method loopControl takes nothing returns nothing
            //Update Alpha
            if currentAlpha != 255 then
                if currentAlpha + I2R(MISSILE_ALPHA_GAIN) * TIMER_INTERVAL >= 255.00 then
                    set currentAlpha = 255
                else
                    set currentAlpha = currentAlpha + I2R(MISSILE_ALPHA_GAIN) * TIMER_INTERVAL
                endif
            endif
            
            //Update Speed
            if currentSpeed != MISSILE_MAX_SPEED then
                if currentSpeed + MISSILE_ACCELERATION * TIMER_INTERVAL >= MISSILE_MAX_SPEED then
                    set currentSpeed = MISSILE_MAX_SPEED
                else
                    set currentSpeed = currentSpeed + MISSILE_ACCELERATION * TIMER_INTERVAL
                endif
            endif
            
            set alpha = R2I(currentAlpha)
            set speed = currentSpeed
        endmethod
        
        private method onHit takes nothing returns nothing
            call hiddenDestroy()
            call DestroyEffect(AddSpecialEffectTarget(MISSILE_COLLISION_MODEL, target, "foot"))
            set DamageType = SPELL
            call damageTarget(owner, target, MISSILE_DAMAGE[GetUnitAbilityLevel(owner, SPELL_ID)])
        endmethod
        
        static method spawn takes unit caster, unit to returns nothing
            local real angle = bj_DEGTORAD * GetRandomReal(0.00, 360.00)
            local real sx = GetUnitX(caster) + GetRandomReal(0.00, SPELL_AREA_OF_EFFECT) * Cos(angle)
            local real sy = GetUnitY(caster) + GetRandomReal(0.00, SPELL_AREA_OF_EFFECT) * Sin(angle)
            local real sz = GetRandomReal(MISSILE_MIN_START_Z, MISSILE_MAX_START_Z)
            local thistype this = create(sx, sy, sz, to, MISSILE_Z_OFFSET)
            
			set owner = caster
            set target = to
            set fxpath = MISSILE_MODEL
            set scale = MISSILE_SIZE
            set alpha = MISSILE_START_ALPHA
            
            static if MISSILE_RANDOM_COLOR then
                set teamcolor = ConvertPlayerColor(GetRandomInt(0, 11))
            endif
            
            call launch(MISSILE_START_SPEED, GetRandomReal(0.0, 1.0))
        endmethod
        
        private static method onInit takes nothing returns nothing
            set damager = xedamage.create()
            set atype = ATTACK_TYPE
            set dtype = DAMAGE_TYPE
			set wtype = WEAPON_TYPE
        endmethod
        
    endstruct
    
    private struct Main
    
        private static constant integer spellId = SPELL_ID
        private static constant integer spellType = SPELL_TYPE_NO_TARGET
        private static constant boolean autoDestroy = false
        
        private real time = 0.00
        private real counter = 0.00
    
        private static timer ticker = null
        private static boolexpr groupFilter = null
		
		private static unit tempUnit = null
		private static thistype temp = 0
        
        private effect sfx
        
        implement List
        
        private method onDestroy takes nothing returns nothing
            call listRemove()
            call DestroyEffect(sfx)
            set sfx = null
            if count == 0 then
                call PauseTimer(ticker)
            endif
        endmethod

		private static method filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), temp.caster)
		endmethod
	
		private method getRandomUnit takes nothing returns unit
			set temp = this
			call GroupEnumUnitsInArea(ENUM_GROUP, GetUnitX(caster), GetUnitY(caster), SPELL_AREA_OF_EFFECT, groupFilter)
			set tempUnit = GroupPickRandomUnit(ENUM_GROUP)
			return tempUnit
		endmethod
        
        private static method periodicFunc takes nothing returns nothing
            local thistype this = first
            local unit target = null
            local boolean flag = false
            
            loop
                exitwhen this == 0
                set time = time + TIMER_INTERVAL
                set counter = counter + TIMER_INTERVAL
                
                //Check Caster State
                static if STOP_IF_CASTER_DEAD then
                    if IsUnitDead(caster) then
                        call destroy()
                        set flag = true
                    endif
                endif
                
                if not flag then
                    //Check Missile Counter
                    if counter >= MISSILE_SPAWN_INTERVAL then
                        set target = getRandomUnit()
                        if target != null then
                            call Missile.spawn(caster, target)
                            set target = null
                        endif
                        set counter = 0.0
                    endif
                    //Check Timer
                    if time >= SPELL_DURATION then
                        call destroy()
                    endif
                    set flag = false
                endif
                set this = next
            endloop
        endmethod
    
        private method onCast takes nothing returns nothing
            call listAdd()
            
            set sfx = AddSpecialEffectTarget(MISSILE_COLLISION_MODEL, caster, "origin")
            if count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.periodicFunc)
            endif
        endmethod
        
        private static method onInit takes nothing returns nothing
            set ticker = CreateTimer()
            set groupFilter = Condition(function thistype.filter)
        endmethod
        implement Spell
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call Preload(MISSILE_MODEL)
        call Preload(MISSILE_COLLISION_MODEL)
    endfunction
endscope