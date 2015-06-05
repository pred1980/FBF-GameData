scope Necromancy initializer init
    /*
     * Description: The Master Necromancer raises a Skeleton from every corpse in the target area. 
                    The more skeletons raised, the weaker they are.
     * Changelog: 
     *     05.11.2013: Abgleich mit OE und der Exceltabelle
	 *     21.03.2015: Rewrote code from scratch
	 *     18.04.2015: Integrated RegisterPlayerUnitEvent
     *
     */
    globals
        private constant integer SPELL_ID = 'A05D'
        private constant real RADIUS = 250 //must be the same like in OE
        private constant string EFFECT = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
		private constant integer MAX_SKELETON = 3
		
		private group targets
		private integer amount = 0
		private integer array UNIT_IDS
        private real array UNIT_DMG
        private real array UNIT_HPS
        private real array UNIT_DUR
    endglobals

    private function MainSetup takes nothing returns nothing
        set UNIT_IDS[1] = 'u020'
        set UNIT_IDS[2] = 'u022'
        set UNIT_IDS[3] = 'u023'
        set UNIT_IDS[4] = 'u024'
        set UNIT_IDS[5] = 'u025'
        
        set UNIT_DMG[1] = 37.0
        set UNIT_DMG[2] = 63.0
        set UNIT_DMG[3] = 88.0
        set UNIT_DMG[4] = 125.0
        set UNIT_DMG[5] = 163.0
        
        set UNIT_HPS[1] = 510
        set UNIT_HPS[2] = 900
        set UNIT_HPS[3] = 1170
        set UNIT_HPS[4] = 1440
        set UNIT_HPS[5] = 1650
        
        set UNIT_DUR[1] = 60
        set UNIT_DUR[2] = 60
        set UNIT_DUR[3] = 60
        set UNIT_DUR[4] = 60
        set UNIT_DUR[5] = 60
		
		set targets = NewGroup()
    endfunction
    
    private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local unit u = null
		local unit s = null
		local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
		local integer count = 0
		
		//check if there are more than MAX_SKELETON
		if (amount > MAX_SKELETON) then
		   set amount = MAX_SKELETON
		endif
		
		loop
            set u = FirstOfGroup(targets)
            exitwhen u == null or count == MAX_SKELETON 
			set s = CreateUnit(GetOwningPlayer(caster), UNIT_IDS[level], GetUnitX(u), GetUnitY(u), GetRandomReal(0,360))
			call DestroyEffect(AddSpecialEffect(EFFECT, GetUnitX(s), GetUnitY(s)))
			call SetUnitMaxState(s, UNIT_STATE_MAX_LIFE, UNIT_HPS[level]/amount)
			call SetUnitState(s, UNIT_STATE_LIFE, GetUnitState(s, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
			call TDS.addDamage(s, R2I(UNIT_DMG[level]/amount))
			call UnitApplyTimedLife(s, 'BTLF', UNIT_DUR[level])
			
			set count = count + 1
			call GroupRemoveUnit(targets, u)
			call RemoveUnit(u)
        endloop

		call ReleaseGroup(targets)
		set u = null
		set s = null
		set amount = 0
    endfunction
	
	private function EnumFilter takes nothing returns boolean
		return SpellHelper.isUnitDead(GetFilterUnit())
	endfunction

	private function Conditions takes nothing returns boolean
		if (GetSpellAbilityId() == SPELL_ID) then
			call GroupEnumUnitsInArea(targets, GetSpellTargetX(), GetSpellTargetY(), RADIUS, Condition(function EnumFilter))
			set amount = CountUnitsInGroup(targets)
			if (amount > 0) then
				return true
			endif
		endif
			
		return false
	endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
		call MainSetup()
        call Preload(EFFECT)
    endfunction

endscope