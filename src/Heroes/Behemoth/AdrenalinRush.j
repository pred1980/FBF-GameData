scope AdrenalinRush initializer init
    /*
     * Description: Mundzuk and Octar become enraged, damaging and knocking back enemy units on their path.
     * Last Update: 25.10.2013
     * Changelog: 
     *     25.10.2013: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     26.03.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for damaging and filtering
     *
	 * Note: Dieser Spell verursacht in der MOVE method ohne Knockback und ohne 
	         IsTerrainWalkable einen hohen Anstieg beim HandleCounter
     */
    globals
        private constant integer SPELL_ID = 'A02L'
        private constant integer RADIUS = 150
        private constant real TIMER_INTERVAL = 0.03
        private constant real SPEED = 20
        private constant string EFFECT = "Abilities\\Spells\\Human\\FlakCannons\\FlakTarget.mdl"
        private constant real START_DAMAGE = 115
        private constant real DAMAGE_PER_LEVEL = 160
        private constant integer KNOCKBACK_DISTANCE = 300
        private constant real KNOCKBACK_SPEED = 0.4
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_METAL_HEAVY_BASH
		
        private string SOUND = "Abilities\\Spells\\Orc\\Shockwave\\Shockwave.wav"
    endglobals

    private struct AdrenalinRush
        unit caster
        real cx
        real cy
        real tx
        real ty
        group targets
        group temp
        timer ti
        static thistype tempthis
        
        static method damage takes unit source, unit target returns nothing
            local real dmg = START_DAMAGE + (GetUnitAbilityLevel(source, SPELL_ID) * DAMAGE_PER_LEVEL)
            
			set DamageType = PHYSICAL
			call SpellHelper.damageTarget(source, target, dmg, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), .tempthis.caster)
        endmethod
        
        static method onKnockback takes nothing returns nothing
            local unit target = GetEnumUnit()
            local real x = GetUnitX(.tempthis.caster) - GetUnitX(target)
            local real y = GetUnitY(.tempthis.caster) - GetUnitY(target)
            local real ang = Atan2(y, x) - bj_PI
            
            call damage(.tempthis.caster, target)
            call GroupAddUnit(.tempthis.temp, target)
            call Knockback.create(.tempthis.caster, target, KNOCKBACK_DISTANCE, KNOCKBACK_SPEED, ang, 0, "", "")
            call GroupRemoveUnit(.tempthis.targets, target)
    
            set target = null
        endmethod
        
        static method onMove takes nothing returns boolean
            local thistype this = GetTimerData( GetExpiredTimer() )
            local real distance = DistanceBetweenCords(this.cx, this.cy, this.tx, this.ty)
            local real a = AngleBetweenCords(this.cx, this.cy, this.tx, this.ty)  
            local real newX = PolarProjectionX(this.cx, SPEED, a)
            local real newY = PolarProjectionY(this.cy, SPEED, a)
            
            if ( distance > 10 and IsTerrainWalkable(newX, newY) ) then
                call er(this.caster, EFFECT)
                call SetUnitPosition(this.caster, newX, newY)
                set this.cx = newX
                set this.cy = newY
                call GroupEnumUnitsInArea( this.targets, this.cx, this.cy, RADIUS, Condition(function thistype.group_filter_callback) )
                call ForGroup( .targets, function thistype.onKnockback )
                return true
            else
                call this.destroy()
            endif

            return false
        endmethod
        
        static method create takes unit c, real tx, real ty returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = c
            set .cx = GetUnitX(c)
            set .cy = GetUnitY(c)
            set .tx = tx
            set .ty = ty
            set .temp = NewGroup()
            set .targets = NewGroup()
            call SetUnitPathing( .caster, false )
            call Sound.runSoundOnUnit(SOUND, .caster)
            set .ti = NewTimer()
            call SetTimerData( .ti, this )
            call TimerStart( .ti, TIMER_INTERVAL, true, function thistype.onMove )
            
            set .tempthis = this
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer( .ti )
            call ReleaseGroup(.temp)
            call ReleaseGroup(.targets)
            call SetUnitPathing( .caster, true )
            set .caster = null
        endmethod
        
        static method onInit takes nothing returns nothing
            set thistype.tempthis = 0
			call Sound.preload(SOUND)
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call AdrenalinRush.create(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call Preload(EFFECT)
    endfunction

endscope