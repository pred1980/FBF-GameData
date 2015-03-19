scope ExplosivTantrum initializer init
    /*
     * Description: Mundzuk orders Octar to thrust with his horn, damaging and knocking its target back.
     * Changelog: 
     *     25.10.2013: Abgleich mit OE und der Exceltabelle
	 *     18.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
     *
     */
    globals
        private constant integer SPELL_ID = 'A01L'
        private constant real START_DAMAGE = 25
        private constant real DAMAGE_PER_LEVEL = 75
        
        //DOT
        private constant real DOT_TIME = 0.45
        private constant string EFFECT = "Abilities\\Spells\\Human\\FlakCannons\\FlakTarget.mdl"
        private constant string ATT_POINT = "origin"
        private constant attacktype ATT_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DMG_TYPE = DAMAGE_TYPE_UNIVERSAL
                
        //KNOCK BACK
        private constant integer DISTANCE = 400
        private constant real KB_TIME = 0.85
    endglobals
    
    private struct ExplosivTantrum
        unit caster
        unit target
        
        method damage takes nothing returns nothing
            local real dmg = START_DAMAGE + (GetUnitAbilityLevel(.caster, SPELL_ID) * DAMAGE_PER_LEVEL)
            call DOT.start( .caster , .target , dmg , DOT_TIME , ATT_TYPE , DMG_TYPE , EFFECT , ATT_POINT )
            call destroy()
        endmethod
          
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            local real x = GetUnitX(caster) - GetUnitX(target)
            local real y = GetUnitY(caster) - GetUnitY(target)
            local real ang = Atan2(y, x) - bj_PI
            
            set .caster = caster
            set .target = target
            
            call Knockback.create(.caster, .target, DISTANCE, KB_TIME, ang, 0, "", "")
            call damage()
            
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            set .caster = null
            set .target = null
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call ExplosivTantrum.create(GetTriggerUnit(), GetSpellTargetUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID and not CheckImmunity(SPELL_ID, GetTriggerUnit(), GetSpellTargetUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
		call TriggerAddCondition(t, Condition(function Conditions))
        call TriggerAddAction(t, function Actions)
        call Preload(EFFECT)
		
		set t = null
    endfunction

endscope