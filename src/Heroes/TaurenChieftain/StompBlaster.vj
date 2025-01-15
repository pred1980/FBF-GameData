scope StompBlaster initializer init
    /*
     * Description: The Tauren Chieftain stomp the area, damaging and knock back nearby enemy units.
     * Changelog: 
     *     06.01.2014: Abgleich mit OE und der Exceltabelle
	 *     29.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for filtering and damaging
					   Increased the stun duration by 0.85s
     *
     */
    globals
        private constant integer SPELL_ID = 'A079'
        private constant real START_DAMAGE = 50
        private constant real DAMAGE_PER_LEVEL = 25
        private constant integer RADIUS = 300
        
        //Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = 1.85
        
        //KNOCK BACK
        private constant integer DISTANCE = 350
        private constant real KB_TIME = 0.85
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals

    private struct StompBlaster
        private unit caster
        private integer num
        private group targets
        private static thistype tempthis = 0
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), .tempthis.caster)
        endmethod
        
        static method onKnockBack takes nothing returns nothing
            local unit u = GetEnumUnit()
            local real dmg = START_DAMAGE + (GetUnitAbilityLevel(.tempthis.caster, SPELL_ID) * DAMAGE_PER_LEVEL)
            local real x = GetUnitX(.tempthis.caster) - GetUnitX(u)
            local real y = GetUnitY(.tempthis.caster) - GetUnitY(u)
            local real ang = Atan2(y, x) - bj_PI
            
            call Knockback.create(.tempthis.caster, u, DISTANCE, KB_TIME, ang, 0, "", "")
			call Stun_UnitEx(u, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
            
            set DamageType = PHYSICAL
			call SpellHelper.damageTarget(.tempthis.caster, u, dmg, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            
			call GroupRemoveUnit(.tempthis.targets, u)
            set u = null
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .targets = NewGroup()
            set .tempthis = this
            
            call GroupEnumUnitsInRange(.targets, GetUnitX(.caster), GetUnitY(.caster), RADIUS, function thistype.group_filter_callback)
            call ForGroup(.targets, function thistype.onKnockBack)
			call destroy()
            
            return this
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call StompBlaster.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
    endfunction

endscope