scope LifeVortex initializer init
    /*
     * Description: The Priestess of the Moon summons a powerful vortex, that deals damage to units 
                    in a targeted area for a certain period of time.
     * Changelog: 
     *     	07.01.2014: Abgleich mit OE und der Exceltabelle
	 *     	28.04.2015: Integrated RegisterPlayerUnitEvent
						Integrated SpellHelper for filtering
						Changed AttackType from NORMAL to MAGIC
						Changed DamageType from UNIVERSAL to MAGIC
	 *		27.10.2015: Code Refactoring
     *
     */
    globals
        private constant integer SPELL_ID = 'A0B5'
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
        
	private function groupFilter takes nothing returns boolean
		local unit u = GetFilterUnit()
		local unit c = GetTriggerUnit()
		local boolean b = false
			
		if (SpellHelper.isValidEnemy(u, c) and not /*
		*/	SpellHelper.isUnitImmune(u)) then
			set b = true
		endif
		
		set u = null
		
		return b
    endfunction

    private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local unit u
		local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
		local real targetX = GetSpellTargetX()
        local real targetY = GetSpellTargetY()
        local group targets = CreateGroup()
       
		call DestroyEffect(AddSpecialEffect(EFFECT_LOC, targetX, targetY))
        call GroupEnumUnitsInRange(targets, targetX, targetY, RADIUS, Condition(function groupFilter))
        loop
			set u = FirstOfGroup(targets)
			exitwhen u == null
            set DamageType = SPELL
			call DOT.start(caster, u, DAMAGE[level], DOT_TIME, ATTACK_TYPE, DAMAGE_TYPE, EFFECT, ATT_POINT)
            call GroupRemoveUnit(targets, u)
        endloop
		
		call GroupClear(targets)
		call DestroyGroup(targets)
		set targets = null
		set u = null
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