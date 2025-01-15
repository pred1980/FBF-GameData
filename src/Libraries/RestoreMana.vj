library RestoreMana uses TimerUtils

	private struct ManaCost
        unit SpellAbilityUnit
        unit SpellTargetUnit
        integer SpellRawcode
        real SpellX
        real SpellY
        real Mana
    endstruct
	
	private function RestoreMana takes nothing returns nothing
		local ManaCost MC = GetTimerData(GetExpiredTimer())
	
		set MC.Mana = MC.Mana - GetUnitState(MC.SpellAbilityUnit, UNIT_STATE_MANA)
		//restore Mana
		call SetUnitState(MC.SpellAbilityUnit, UNIT_STATE_MANA, GetUnitState(MC.SpellAbilityUnit, UNIT_STATE_MANA) + MC.Mana)
		call MC.destroy()
		
		call ReleaseTimer(GetExpiredTimer())
    endfunction
    
    function RunManaCost takes integer spellId, unit caster, unit target, real spellX, real spellY returns nothing
        local ManaCost M = ManaCost.create()
		local timer t = NewTimer()
        
        set M.SpellAbilityUnit = caster
        set M.SpellTargetUnit = target
        set M.SpellRawcode = spellId
        set M.SpellX = spellX
        set M.SpellY = spellY
        set M.Mana = GetUnitState(M.SpellAbilityUnit, UNIT_STATE_MANA)
		call SetTimerData(t, M)
        call TimerStart(t, 0., false, function RestoreMana)
    endfunction
	
endlibrary