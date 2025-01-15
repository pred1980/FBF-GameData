library Maelstrom initializer onInit requires SpellEvent, Knockback, TimerUtils, GroupUtils, SimError
    /*
     * Description: The Naga channels a deadly Maelstrom, turning all units slowly around her, 
                    dealing damage to all enemy units caught.
     * Changelog: 
     *     	08.01.2014: Abgleich mit OE und der Exceltabelle
	 *		22.04.2015: Integrated SpellHelper for filtering and damaging
	 *		23.04.2015: Increased the damage per level from 50/100/150 to 150/300/450
     */
    globals
        // SPELL CONFIGURABLES
        //~~~~~~~~~~~~~~~~~~~~~~
        private constant integer ABILITY_ID = 'A07S'
        private constant real TIMER_PERIOD = 0.03125
        private constant boolean DISALLOW_MUI = false // Can there be more than one instance per unit?
        private constant string  MUI_ERROR_MSG = "Maelstrom is already active." 

        // VISUAL CONFIGS
        //~~~~~~~~~~~~~~~~~~~~~~
        
        // After the Maelstrom reaches RADIUS.
        // It will adjust to make a sort of randomness in it.
        // The minimum range the Maelstrom can adjust to is:
        private constant real MINIMUM_ADJUST = 200.
        
        private constant string MISSILE_MODEL = "WaterBreathDamage.mdx"//"war3mapImported\\BubbleMissile.mdx"//"war3mapImported\\WaterBoomerang.mdx"//"war3mapImported\\WateryBlade.mdx" //"war3mapImported\\SeaAura.mdx" // "war3mapImported\\WaterArchon_Missile.mdx"
        private constant real   MISSILE_SCALE = 0.75
        private constant real   MISSILE_HEIGHT  = 45.00
        private constant real   ANGLE_INCREMENT = 3 * bj_DEGTORAD   // Angle goes at x every TIMER_PERIOD.
        
        private constant string XEFX_FLASH_SFX = ""
        private constant string TARGET_FLASH_SFX = ""//"war3mapImported\\WateryBlade.mdx"//"Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdx" 
        private constant string TARGET_FLASH_LOC = ""
        
        private constant boolean AT_LOCATION = true // Whether to create the TARGET_FLASH at unit location or on it.
        
        private constant string KB_SFX = "WaterBreathDamage.mdx"
        private constant string KB_SFX_LOC = "origin"
        
        private constant boolean ROTATE_MISSILE = false

        // DAMAGE CONFIGURABLES
        //~~~~~~~~~~~~~~~~~~~~~~
        private constant real ENUM_AOE = 128.00
        private constant real TREE_AOE = 32.00
        
        private constant boolean BUILDUP_DAMAGE = false // Whether damage is built up over time or instantly.
        private constant boolean MULTI_DAMAGE   = true  // Allow units to be swirled more than once per instance?
        
        private constant boolean ABANDON_ON_BLINK = true // For teleport issues, Blinking with Maelstrom is not fun :(
        private constant real BLINK_RANGE = 300. // Range for a Teleport to be counted.
        
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals
    
    // Speed the Maelstrom travels and adjusts.
    private constant function SPEED takes integer level returns real
        return 700.
    endfunction
    
    private constant function DAMAGE takes integer level returns real
        return level * 150.
    endfunction
        
    // Number of waves summoned?
    private constant function WAVES takes integer level returns integer
        return 18
    endfunction
    
    // How long spell last?
    private constant function DURATION takes integer level returns real
        return 15.
    endfunction
    
    // Radius the Maelstrom goes out?
    private constant function RADIUS takes integer level returns real
        return 200.
    endfunction
    
    // Maximum adjust.
    private constant function MAXIMUM_ADJUST takes integer level returns real
        return RADIUS( level ) + 300.
    endfunction
    
    private constant function KB_DISTANCE takes integer level returns real
        return 400.
    endfunction
    
    private constant function KB_DURATION takes integer level returns real
        return 1.0
    endfunction
    
    // How long a unit is in the Maelstrom for.
    private constant function SPIN_DURATION takes integer level returns real
        return 1.75
    endfunction
    
    // How long the wave is 'idle' for after finishing on a unit.
    private constant function SPIN_COOLDOWN takes integer level returns real
        return 1.5
    endfunction
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// CONFIGURABLE GLOBALS - ABOVE
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    
    globals
        private group HOLDER_GROUP = CreateGroup()  // Holds units already in a whirlpool.
        private group CASTER_GROUP = CreateGroup()  // For MUI things.
    endglobals
        
    private struct Data
        private group DmgdGroup
        boolean stable  = false
        boolean higher  = false
        boolean stable2 = false
        unit caster
        unit target = null
        integer lvl
        player owner
        
        real x
        real y
        real lx
        real ly
        real angle
        real cd
        real cdDur
        real spinDur
        boolean pushed  = false
        
        real spellRadius 
        real targetRadius = ENUM_AOE
        real dist   = 0.00
        real cdist  = 0.00
        real speed
        
        xefx sfx
        
        real sec = 0.00
        real dur
        real dmg    = 0.00
        real dmgX
        real kbdist = 0.00
        real kbdur  = 0.00
        real kbdistX
        real kbdurX 
        
        timer t
        static thistype tempData
		
        static method unitFilter takes nothing returns boolean
            local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidEnemy(u, thistype.tempData.caster) or /*
			*/  SpellHelper.isValidAlly(u, thistype.tempData.caster) and not /*
			*/  IsUnitInGroup( u, HOLDER_GROUP ) and /*
            */  thistype.tempData.cd >= thistype.tempData.cdDur) then
                call GroupAddUnit( HOLDER_GROUP, u )
                set thistype.tempData.target = u
                set thistype.tempData.cd = 0.00
                set thistype.tempData.pushed = false
                set b = true
            endif
            
			set u = null
			
            return b
        endmethod
        
        private method knockbackUnit takes nothing returns nothing
            call Knockback.create(this.caster, this.target, this.kbdist, this.kbdur, this.angle /* bj_RADTODEG*/, 0, KB_SFX, KB_SFX_LOC)
            
			static if MULTI_DAMAGE then
                call GroupRemoveUnit( HOLDER_GROUP, this.target )
            else
                call GroupAddUnit( this.DmgdGroup, this.target )
			endif
			
			if (IsUnitEnemy(this.target, GetOwningPlayer(this.caster))) then
				set DamageType = SPELL
				call SpellHelper.damageTarget(this.caster, this.target, this.dmg, false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            endif
			
            set this.pushed = true
            set this.kbdist = 0.
            set this.kbdur = 0.
            set this.dmg = 0.
        endmethod
        
        private static method clearGroup takes nothing returns nothing
            call GroupRemoveUnit( HOLDER_GROUP, GetEnumUnit() )
        endmethod
        
        private method onDestroy takes nothing returns nothing
            static if DISALLOW_MUI then
                if IsUnitInGroup( this.caster, CASTER_GROUP ) then
                    call GroupRemoveUnit( CASTER_GROUP, this.caster )
                endif
            endif
            if this.target != null and this.kbdist > 0 and this.kbdur > 0 then
                call this.knockbackUnit()
                set this.target = null
            endif
            call this.sfx.destroy()

            if MULTI_DAMAGE == false then
                call ForGroup( this.DmgdGroup, function thistype.clearGroup )
                call ReleaseGroup( this.DmgdGroup )
            endif
            
            call ReleaseTimer( this.t )
            set this.t      = null
            set this.caster = null
            set this.owner  = null
        endmethod
                
        private static method periodic takes nothing returns nothing
            local thistype this = GetTimerData( GetExpiredTimer() )
            local real cx = GetUnitX( this.caster )
            local real cy = GetUnitY( this.caster )
            local real tempX = this.lx - cx // For Blink tracking.
            local real tempY = this.ly - cy
            local integer i  = 0 // Boolean, if it is 0 then we move.
            
			set this.x = cx + this.dist * Cos( this.angle )
            set this.y = cy + this.dist * Sin( this.angle )
            set this.lx = cx
            set this.ly = cy
            set this.angle = this.angle + ANGLE_INCREMENT
            set this.sfx.x = this.x
            set this.sfx.y = this.y
                        
            //==============================================================================
            // Maelstrom target movement.
            
            if this.target != null then
                set this.cd = this.cd + TIMER_PERIOD
                // If current cooldown becomes greater than washin duration and we haven't pushed.
                // PUSH THE UNIT.
                                
                if this.cd >= this.spinDur and this.pushed == false then
                    set i = 1
                    call this.knockbackUnit()
                // Otherwise if cooldown is less than spinin duration, we just set X/Y.
                elseif this.cd < this.spinDur then
                    set this.kbdist = this.kbdist + this.kbdistX
                    set this.kbdur  = this.kbdur  + this.kbdurX
                    
                    static if AT_LOCATION then
                        call DestroyEffect( AddSpecialEffect( TARGET_FLASH_SFX, this.x, this.y ) )
                    elseif
                        if TARGET_FLASH_SFX != "" then
                            call DestroyEffect( AddSpecialEffectTarget( TARGET_FLASH_SFX, this.target, TARGET_FLASH_LOC ) )
                        endif
                    endif

                    static if BUILDUP_DAMAGE then
                        set this.dmg = this.dmg + this.dmgX
                    endif
                    
                    // BLINK TRACKER.
                    static if ABANDON_ON_BLINK then
                        if SquareRoot( tempX*tempX+tempY*tempY ) > BLINK_RANGE then
                            set this.cd = this.spinDur - 0.01
                            set i = 1
                        endif
                    endif
                    if i == 0 then
                        call SetUnitX( this.target, this.x )
                        call SetUnitY( this.target, this.y )
                    endif
                endif
                
                if this.cd >= this.cdDur then
                    set this.target = null
                endif
            else
                set thistype.tempData = this
                call GroupEnumUnitsInRange( ENUM_GROUP, this.x, this.y, this.targetRadius, function thistype.unitFilter )
            endif
            
            //==============================================================================
            // Missile visual stuff.
            
            if XEFX_FLASH_SFX != "" then
                call this.sfx.flash( XEFX_FLASH_SFX )
            endif
            
            static if ROTATE_MISSILE then
                set this.sfx.xyangle = this.angle
            endif

            //==============================================================================
            // Reform back inwards.
            
            if this.dist >= this.spellRadius and not this.stable then
                set this.cdist = GetRandomReal( MINIMUM_ADJUST, MAXIMUM_ADJUST( this.lvl ) )
                set this.stable = true
                if this.cdist > this.spellRadius then
                    set this.higher = true
                endif
            elseif not this.stable then
                set this.dist = this.dist + this.speed
                
            elseif this.stable and this.dist >= this.cdist and not this.stable2 then
                set this.dist = this.dist - (this.speed/2)
                 if this.dist <= this.cdist then
                    set this.stable2 = true
                endif
                
            elseif this.stable and this.higher and not this.stable2 then
                set this.dist = this.dist + (this.speed/2)
                if this.dist >= this.cdist then
                    set this.stable2 = true
                endif
            endif
            
            
            //==============================================================================
            // Destruction.
            
            set this.sec = this.sec + TIMER_PERIOD
            if  (this.sec >= this.dur or /*
            */  SpellHelper.isUnitDead(this.caster) or /*
            */  this.caster == null) then
                call .destroy()
            endif
        endmethod
                
        static method create takes unit caster, real angle returns thistype
            local thistype this  = thistype.allocate()
            local real ticks
            
            set this.caster = caster
            set this.lvl = GetUnitAbilityLevel( this.caster, ABILITY_ID )
            set this.owner = GetOwningPlayer( this.caster )
            set this.x = GetUnitX( this.caster )
            set this.y = GetUnitY( this.caster )
            static if ABANDON_ON_BLINK then
                set this.lx = x
                set this.ly = y
            endif
            set this.angle = angle
            
            set this.sfx = xefx.create( this.x, this.y, this.angle )
            set this.sfx.fxpath = MISSILE_MODEL
            set this.sfx.z = MISSILE_HEIGHT
            set this.sfx.scale = MISSILE_SCALE
            
            set this.dur = DURATION( this.lvl )
            set this.spellRadius = RADIUS( this.lvl )
            set this.spinDur = SPIN_DURATION( this.lvl )
            set this.cdDur = SPIN_COOLDOWN( this.lvl ) + this.spinDur
            set this.cd = this.cdDur
            set this.dmg = DAMAGE( this.lvl )

            set ticks = this.spinDur / TIMER_PERIOD
            set this.kbdurX = KB_DURATION( this.lvl ) / ticks
            set this.kbdistX = KB_DISTANCE( this.lvl ) / ticks
            
            set this.speed = SPEED( this.lvl ) * TIMER_PERIOD
            
            static if BUILDUP_DAMAGE then
                set this.dmgX = this.dmg / ticks
                set this.dmg = 0.00
            endif
            
            if MULTI_DAMAGE == false then
                set this.DmgdGroup = NewGroup()
            endif
            
            set this.t = NewTimer()
            call SetTimerData( this.t, this )
            call TimerStart( this.t, TIMER_PERIOD, true, function thistype.periodic)
			
            return this
        endmethod
    endstruct

    private function onEffect takes nothing returns nothing
        local unit u = SpellEvent.CastingUnit
        local integer i = 0
        local integer lvl = GetUnitAbilityLevel(u, ABILITY_ID)
        local real angle = 0.00
        local real aIncr = 360*bj_DEGTORAD / WAVES( lvl)
        
		loop
            exitwhen i == WAVES( lvl )
            call Data.create( u, angle )
            set angle = angle + aIncr
            set i = i + 1
        endloop
        
        static if DISALLOW_MUI then
            call GroupAddUnit( CASTER_GROUP, u )
        endif
        set u = null
    endfunction
    
    private function onChannel takes nothing returns nothing
        local unit u = SpellEvent.CastingUnit
        if IsUnitInGroup( u, CASTER_GROUP ) then
            call SimError( GetOwningPlayer( u ), MUI_ERROR_MSG )
            call PauseUnit( u, true )
            call IssueImmediateOrder( u, "stop" )
            call PauseUnit( u, false )
        endif
        set u = null
    endfunction

    //===========================================================================
    private function onInit takes nothing returns nothing
        call RegisterSpellEffectResponse( ABILITY_ID, onEffect )
        static if DISALLOW_MUI then
            call RegisterSpellChannelResponse( ABILITY_ID, onChannel )
        endif
        call Preload(MISSILE_MODEL)
        call Preload(KB_SFX)
    endfunction

endlibrary