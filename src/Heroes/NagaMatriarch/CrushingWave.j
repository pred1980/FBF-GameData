scope CrushingWave initializer init
    /*
     * Description: The Naga Matriarch sends out a deadly gust of water wich will increase in size and damage 
                    with traveled distance. End damage is 4 times the start damage.
     * Last Update: 08.01.2014
     * Changelog: 
     *     08.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A07R'
        private constant integer EFFECT_ID = 'u00E'
        private constant string EFFECT = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl"
        //Collision size at the beginning
        private constant real START_SIZE = 50.0 
        //collision size at the end
        private constant real END_SIZE = 300.0 
        private constant real INTERVAL = 0.03125
        //How fast the wave travels
        private constant real SPEED = 1100.0 * INTERVAL
        //Maximum damage at level 0
        private constant real MAX_DAMAGE_START = 0.0
        //Additional maximum damage possible with every level 
        private constant real MAX_DAMAGE_INCREASE = 300.0
        //Damage at the end of the wave on one target at level 0 
        private constant real END_DAMAGE_START = 0.0
        // Additional damage on one target at the end of the wave 
        private constant real END_DAMAGE_INCREASE = 100.0
        //How far the wave travels 
        private constant real DISTANCE = 800.0
        //The ratio of damage dealt at the beginning to the damage at the end 
        private constant real FRONT_MULTIPLIER = 0.25 
        //Do not change the numbers below, even if they are constants
        private constant real SIZE_INCREASE = (END_SIZE - START_SIZE) * SPEED/DISTANCE
    endglobals
    
    private struct CrushingWave
        unit caster
        unit effect
        integer level = 0
        real dx
        real dy
        real size
        real distance
        real damage
        real totalDamage
        real maxDamage
        real dmgIncrease
        real X
        real Y
        timer t
        group targets //All units that have already been hit
        group g //All units in the range in a certain step
        static thistype tempthis
        
        method onDestroy takes nothing returns nothing
            call KillUnit(.effect)
            call ReleaseGroup( .g )
            set .g = null
            call ReleaseGroup( .targets )
            set .targets = null
            call ReleaseTimer( .t )
            set .t = null
            set .caster = null
            set .effect = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return GetUnitAbilityLevel( GetFilterUnit(), 'Avul' ) <= 0 and GetUnitAbilityLevel( GetFilterUnit(), 'Amim' ) <= 0 and GetUnitAbilityLevel(GetFilterUnit(), 'Aloc') <=0 and not IsUnitAlly(GetFilterUnit(), GetOwningPlayer(.tempthis.caster)) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            
            if (not IsUnitInGroup(u, .tempthis.targets)) and .tempthis.totalDamage < .tempthis.maxDamage and u != null then
                set DamageType = SPELL
                call UnitDamageTarget(.tempthis.caster, u, .tempthis.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNKNOWN, WEAPON_TYPE_WHOKNOWS)
                call DestroyEffect(AddSpecialEffectTarget(EFFECT, u, "origin"))
                set .tempthis.totalDamage = .tempthis.totalDamage + .tempthis.damage
                call GroupAddUnit(.tempthis.targets, u)
            endif
            
            set u = null
        endmethod
        
        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call GroupEnumUnitsInRange(this.g, this.X, this.Y, this.size, function thistype.group_filter_callback)
            call ForGroup(this.g, function thistype.onDamageTarget)
            
            if this.distance < DISTANCE then
                set this.X = this.X + this.dx
                set this.Y = this.Y + this.dy
                set this.size = this.size + SIZE_INCREASE
                set this.damage = this.damage + this.dmgIncrease
                set this.distance = this.distance + SPEED
                call SetUnitX(this.effect, this.X)
                call SetUnitY(this.effect, this.Y)
            else
                call this.destroy()
            endif
        endmethod
        
        static method create takes unit caster, real x, real y returns thistype
            local thistype this = thistype.allocate()
            local real angle
            local real eDmg

            set .caster = caster
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .X = GetUnitX(.caster)
            set .Y = GetUnitY(.caster)
            set .dx = X - x
            set .dy = Y - y
            set angle = Atan2(dx, dy)
            set .dx = -Sin(angle) * SPEED
            set .dy = -Cos(angle) * SPEED
            set eDmg = (END_DAMAGE_START + END_DAMAGE_INCREASE * .level)
            set .damage = eDmg * FRONT_MULTIPLIER
            set .dmgIncrease = (eDmg - .damage) * SPEED/DISTANCE
            set .effect = CreateUnit(GetOwningPlayer(.caster), EFFECT_ID, .X, .Y, -angle/bj_DEGTORAD-90)
            set .maxDamage = MAX_DAMAGE_START + MAX_DAMAGE_INCREASE * .level
            set .distance = 0.0
            set .totalDamage = 0.0
            set .size = START_SIZE
            set .g = NewGroup()
            set .targets = NewGroup()
            set .tempthis = this
            
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, INTERVAL, true, function thistype.onPeriodic)
            
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            set thistype.tempthis = 0
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        local CrushingWave cw = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set cw = CrushingWave.create( GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        call TriggerAddAction( t, function Actions )
        call Preload(EFFECT)
        
        set t = null
    endfunction

endscope