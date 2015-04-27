scope StarImpact initializer init
    /*
     * Description: Edgar calls down a Falling Star that, on impact, damages and stuns all enemy units, 
                    and splits into several smaller stars that deal less damage. The Star takes 1.5 seconds to summon.
     * Changelog: 
     *     	02.01.2014: Abgleich mit OE und der Exceltabelle
	 *		27.04.2015: Integrated SpellHelper for filtering
     */
    globals
        private constant integer SPELL_ID = 'A08O'
        //Wenn true, wird ein leuchtender Kreis um das Impact Area für alle befreundeten Spieler des Casters angezeigt.
        private constant boolean SHOW_IMPACT_INDICATOR = true
        private constant string IMPACT_INDICATOR_MODEL = "Doodads\\Cinematic\\GlowingRunes\\GlowingRunes3.mdl" //"Doodads\\Cinematic\\GlowingRune\\GlowingRunes3.mdl"
        private constant integer IMPACT_INDICATOR_AMOUNT = 10
    endglobals
    
    //Damage Configuration
    globals
        private constant real STAR_IMPACT_AREA = 300.00
        private constant real SPLITTER_IMPACT_AREA = 75.00
        private real array STAR_IMPACT_DAMAGE
        private real array SPLITTER_DAMAGE
        private constant string STAR_DAMAGE_EFFECT = "Models\\StarImpactExplosion.mdl"
        private constant real STAR_DAMAGE_EFFECT_SCALE = 1.15
        private real array STUN_DURATION
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals
    
    //Missile Configuration
    globals
        private constant string STAR_MISSILE_MODEL = "Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl"
        private constant real STAR_MISSILE_SCALE = 4.50
        private constant real STAR_MISSILE_Z_OFFSET = 10.00
        private constant real STAR_IMPACT_DELAY = 1.5
        private constant real STAR_START_HEIGHT = 2500.00
        private constant real STAR_MIN_CREATION_DISTANCE = 300.00
        private constant real STAR_MAX_CREATION_DISTANCE = 550.00
        private constant string SPLITTER_MISSILE_MODEL = "Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl"
        private constant real SPLITTER_MISSILE_SCALE = 1.75
        private constant real SPLITTER_MISSILE_Z_OFFSET = 7.5
        private constant real SPLITTER_MISSILE_SPEED = 175
        private constant integer SPLITTER_MIN_AMOUNT = 10
        private constant integer SPLITTER_MAX_AMOUNT = 15
    endglobals
    
    private keyword Star
    private keyword Main
    private keyword SplitterGroup
    private keyword Splitter
    
    private function MainSetup takes nothing returns nothing
        set STAR_IMPACT_DAMAGE[0] = 50
        set STAR_IMPACT_DAMAGE[1] = 100
        set STAR_IMPACT_DAMAGE[2] = 150
        set STAR_IMPACT_DAMAGE[3] = 200
        set STAR_IMPACT_DAMAGE[4] = 250
        
        set SPLITTER_DAMAGE[0] = 5.00
        set SPLITTER_DAMAGE[1] = 10.00
        set SPLITTER_DAMAGE[2] = 15.00
        set SPLITTER_DAMAGE[3] = 20.00
        set SPLITTER_DAMAGE[4] = 25.00
        
        set STUN_DURATION[0] = 0.75
        set STUN_DURATION[1] = 1.25
        set STUN_DURATION[2] = 1.75
        set STUN_DURATION[3] = 2.25
        set STUN_DURATION[4] = 2.75
    endfunction
    
    struct Splitter extends xemissile
    
        SplitterGroup sGroup = 0
    
        method onHit takes nothing returns nothing
            call sGroup.terminate(this)
        endmethod
    
        static method create takes SplitterGroup sg, real tx, real ty, real arc returns thistype
            local thistype this = allocate(sg.x, sg.y, STAR_MISSILE_Z_OFFSET, tx, ty, SPLITTER_MISSILE_Z_OFFSET)
            set fxpath = SPLITTER_MISSILE_MODEL
            set scale = SPLITTER_MISSILE_SCALE
            call launch(SPLITTER_MISSILE_SPEED, arc)
            set sGroup = sg
            return this
        endmethod
    
    endstruct
    
    struct SplitterGroup
    
        delegate Main root
        
        Splitter array splitters[SPLITTER_MAX_AMOUNT]
        
        integer splitterCount = 0
        
        static delegate xedamage dmg = 0
        
        method terminate takes Splitter s returns nothing
            set splitterCount = splitterCount - 1
            set DamageType = SPELL
            call damageAOE(caster, s.x, s.y, SPLITTER_IMPACT_AREA, SPLITTER_DAMAGE[lvl])
            call s.terminate()
            if splitterCount <= 0 then
                call root.destroy()
                call this.destroy()
            endif
        endmethod
        
        static method create takes Main from returns thistype
            local thistype this = allocate()
            local integer sc = GetRandomInt(SPLITTER_MIN_AMOUNT, SPLITTER_MAX_AMOUNT)
            local integer i = 0
            local real sa = 0.00
            local real sx = 0.00
            local real sy = 0.00
            local real sarc = GetRandomReal(1.00, 2.00)
            set root = from
            loop
                exitwhen i >= sc
                set sa = GetRandomReal(0.00, 2 * bj_PI)
                set sx = x + GetRandomReal(0.00, STAR_IMPACT_AREA) * Cos(sa)
                set sy = y + GetRandomReal(0.00, STAR_IMPACT_AREA) * Sin(sa)
                call Splitter.create(this, sx, sy, sarc)
                set splitterCount = splitterCount + 1
                set i = i + 1
            endloop
            return this
        endmethod
                
        static method onInit takes nothing returns nothing
            set dmg = xedamage.create()
            set dtype = DAMAGE_TYPE
            set atype = ATTACK_TYPE
			set wtype = WEAPON_TYPE
        endmethod
        
    endstruct
    
    struct Star extends xemissile
    
        delegate Main root
        static delegate xedamage dmg = 0
        static thistype temp = 0
        static boolexpr damageFilter = null
        xefx array indicator[IMPACT_INDICATOR_AMOUNT]
        
        real counter = 0.00
        
        method loopControl takes nothing returns nothing
            set counter = counter + XE_ANIMATION_PERIOD
        endmethod
        
        static method damageFilterEnum takes nothing returns boolean
            local unit u = GetFilterUnit()
			
			if (SpellHelper.isValidEnemy(u, temp.caster) and not IsUnitType(u, UNIT_TYPE_FLYING)) then
				call StunUnitTimed(u, STUN_DURATION[temp.lvl])
                set DamageType = SPELL
                call damageTarget(temp.caster, u, STAR_IMPACT_DAMAGE[temp.lvl])
            endif
            set u = null
            return false
        endmethod
        
        method onHit takes nothing returns nothing
            local integer i = 0
            
            set temp = this
            call GroupEnumUnitsInRange(ENUM_GROUP, x, y, STAR_IMPACT_AREA, damageFilter)

            call SplitterGroup.create(root)
            call terminate()
            if STAR_DAMAGE_EFFECT != "" then
                set zangle = 0.00
                set scale = STAR_DAMAGE_EFFECT_SCALE
                call flash(STAR_DAMAGE_EFFECT)
            endif
            static if SHOW_IMPACT_INDICATOR then
                loop
                    exitwhen i >= IMPACT_INDICATOR_AMOUNT
                    call indicator[i].destroy()
                    set i = i + 1
                endloop
            endif
        endmethod
        
        static method create takes Main from returns thistype
            local thistype this
            local real ang = GetRandomReal(0.00, bj_PI * 2)
            local real startDist = GetRandomReal(STAR_MIN_CREATION_DISTANCE, STAR_MAX_CREATION_DISTANCE)
            local real startX = from.x + startDist * Cos(ang)
            local real startY = from.y + startDist * Sin(ang)
            local real startZ = STAR_START_HEIGHT + STAR_MISSILE_Z_OFFSET
            local real dx = startX - from.x
            local real dy = startY - from.y
            local real dz = startZ - STAR_MISSILE_Z_OFFSET
            local real dist = SquareRoot(dx * dx + dy * dy + dz * dz)
            local real spd = dist / STAR_IMPACT_DELAY * startDist / dist
            
            //INDICATOR VARIABLES
            static if SHOW_IMPACT_INDICATOR then
                local string fx = ""
                local integer i = 0
                local real a = 0.00
            endif
            
            set this = allocate(startX, startY, startZ, from.x, from.y, STAR_MISSILE_Z_OFFSET)
            set fxpath = STAR_MISSILE_MODEL
            set scale = STAR_MISSILE_SCALE
            
            //INDICATOR CREATION
            static if SHOW_IMPACT_INDICATOR then
            
                loop
                    exitwhen i >= bj_MAX_PLAYERS
                    if IsPlayerAlly(Player(i), GetOwningPlayer(from.caster)) or Player(i) == GetOwningPlayer(from.caster) then
                        if GetLocalPlayer() == Player(i) then
                            set fx = IMPACT_INDICATOR_MODEL
                        endif
                    endif
                    set i = i + 1
                endloop
                
                
                set i = 0
                loop
                    exitwhen i >= IMPACT_INDICATOR_AMOUNT
                    set indicator[i] = xefx.create(from.x + STAR_IMPACT_AREA  * Cos(a), from.y + STAR_IMPACT_AREA  * Sin(a), a)
                    set indicator[i].fxpath = fx
                    set a = a + (2 * bj_PI / IMPACT_INDICATOR_AMOUNT)
                    set i = i + 1
                endloop
                
            endif
            
            call launch(spd, 0.00)
            set root = from
            return this
        endmethod
        
        
        static method onInit takes nothing returns nothing
            set dmg = xedamage.create()
            set dmg.dtype = DAMAGE_TYPE
            set dmg.atype = ATTACK_TYPE
            set damageFilter = Condition(function thistype.damageFilterEnum)
        endmethod
    
    endstruct
    
    struct Main

        private static constant integer spellId = SPELL_ID
        private static constant integer spellType = SPELL_TYPE_TARGET_GROUND
        private static constant boolean autoDestroy = false
        
        method onCast takes nothing returns nothing
            set lvl = lvl - 1
            call Star.create(this)
        endmethod      
        
        implement Spell
        
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call Preload(IMPACT_INDICATOR_MODEL)
        call Preload(STAR_DAMAGE_EFFECT)
        call Preload(STAR_MISSILE_MODEL)
        call Preload(SPLITTER_MISSILE_MODEL)
    endfunction

endscope