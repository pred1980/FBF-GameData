scope SleepyDust initializer init
    /*
     * Description: The Snake Tongue summons an invisible Dust Bag on the floor that releases Sleep Powder 
                    when an enemy steps on it, effectively putting the unit to sleep.
     * Changelog: 
     *     	18.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	19.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     	04.04.2015: Integrated RegisterPlayerUnitEvent
	                    Integrated SpellHelper for filtering
	 *		20.04.2016: Adapted for AI System
     */
    globals
		private constant integer SPELL_ID = 'A06T'
        private constant integer DUMMY_ID = 'e00Y'
        private constant integer DUMMY_SPELL_ID = 'A06Y'
        private constant string EFFECT = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageDeathCaster.mdl"
        
        private integer array BAG_IDS
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set BAG_IDS[0] = 'h00M'
        set BAG_IDS[1] = 'h00N'
        set BAG_IDS[2] = 'h00O'
        set BAG_IDS[3] = 'h00P'
        set BAG_IDS[4] = 'h00Q'
    endfunction
	
	private function Actions takes nothing returns nothing
		local unit caster = GetTriggerUnit()
		local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
		call CreateUnit(GetOwningPlayer(caster), BAG_IDS[level], GetSpellTargetX(), GetSpellTargetY(), GetUnitFacing(caster))
		
		set caster = null
	endfunction	
    
    private function BagActions takes nothing returns nothing
        local integer index = 0
        local unit u = GetAttacker()
        local integer a = GetUnitTypeId(u)
        local unit d = CreateUnit(GetOwningPlayer(u),DUMMY_ID,GetUnitX(u),GetUnitY(u),GetUnitFacing(u))
        
        call DestroyEffect( AddSpecialEffect(EFFECT,GetUnitX(u),GetUnitY(u)))
        call UnitAddAbility(d, DUMMY_SPELL_ID)
        
        loop
            exitwhen index > 4 or BAG_IDS[index] == a
            set index = index + 1
        endloop
        
        call SetUnitAbilityLevel(d, DUMMY_SPELL_ID, index + 1)
        call IssueTargetOrder(d, "sleep", GetTriggerUnit())
        call KillUnit(u)
        
        set u = null
        set d = null
    endfunction
	
	private function BagConditions takes nothing returns boolean
		local unit a = GetAttacker()
		local unit u = GetTriggerUnit()
        local integer attId = GetUnitTypeId(a)
		local boolean b = false
		
        set b = attId == BAG_IDS[0] or /*
		*/		attId == BAG_IDS[1] or /*
		*/      attId == BAG_IDS[2] or /*
		*/      attId == BAG_IDS[3] or /*
		*/      attId == BAG_IDS[4] and /*
		*/ 		SpellHelper.isValidEnemy(u, a) and not /*
		*/		SpellHelper.isUnitImmune(u)
		
		set a = null
		set u = null
		
		return b
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
    
    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function BagConditions, function BagActions)
        
        call MainSetup()
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(EFFECT)
	endfunction
    
endscope