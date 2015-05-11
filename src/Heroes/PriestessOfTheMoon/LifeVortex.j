scope LifeVortex initializer init
    /*
     * Description: The Priestess of the Moon summons a powerful vortex, that deals damage to units 
                    in a targeted area for a certain period of time.
     * Changelog: 
     *     07.01.2014: Abgleich mit OE und der Exceltabelle
	 *     28.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for filtering
					   Changed AttackType from NORMAL to MAGIC
					   Changed DamageType from UNIVERSAL to MAGIC
     *
     */
    globals
        private constant integer SPELL_ID = 'A07E'
        private constant integer RADIUS = 300
        private constant string EFFECT_LOC = "Abilities\\Spells\\Items\\AItb\\AItbTarget.mdl"
        
        //DOT
        private constant real DOT_TIME = 2.5
        private constant string EFFECT = "Abilities\\Spells\\NightElf\\TargetArtLumber\\TargetArtLumber.mdl"
        private constant string ATT_POINT = "origin"
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
        private real array DAMAGE
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DAMAGE[1] = 55
        set DAMAGE[2] = 75
        set DAMAGE[3] = 95
        set DAMAGE[4] = 115
        set DAMAGE[5] = 135
    endfunction

    private struct LifeVortex
        private unit caster
        private group targets
        private integer level = 0
        private static thistype tempthis = 0
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidEnemy(u, .tempthis.caster) and not /*
			*/	SpellHelper.isUnitImmune(u)) then
				set b = true
			endif
			
			set u = null
			
			return b
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            
			set DamageType = SPELL
            call DOT.start(.tempthis.caster, u, DAMAGE[.tempthis.level], DOT_TIME, ATTACK_TYPE, DAMAGE_TYPE, EFFECT, ATT_POINT)
            call GroupRemoveUnit(.tempthis.targets, u)
      
            set u = null
        endmethod
        
        static method create takes unit caster, real x, real y returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .targets = NewGroup()
            set .tempthis = this
            
            call DestroyEffect(AddSpecialEffect(EFFECT_LOC, x, y))
            call GroupEnumUnitsInRange( .targets, x, y, RADIUS, function thistype.group_filter_callback )
            call ForGroup( .targets, function thistype.onDamageTarget )
            call destroy()
			
            return this
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call LifeVortex.create(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call MainSetup()
        call Preload(EFFECT_LOC)
        call Preload(EFFECT)
    endfunction

endscope