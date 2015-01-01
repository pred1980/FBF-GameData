scope ManaWard initializer init
    /*
     * Description: The Orcish Warlock summons an immobile ward which replenishes the mana of nearby allied units.
     * Last Update: 08.01.2014
     * Changelog: 
     *     08.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A07W'
        private constant integer SUMMONED_ID = 'o00D'
        private constant integer SUMMONED_SPELL_ID = 'A07X'
    endglobals
    
    private function Conditions takes nothing returns boolean
        return GetUnitTypeId(GetSummonedUnit()) == SUMMONED_ID
    endfunction

    private function Actions takes nothing returns nothing
        call SetUnitAbilityLevel(GetSummonedUnit(), SUMMONED_SPELL_ID, GetUnitAbilityLevel(GetSummoningUnit(), SPELL_ID))
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SUMMON )
        call TriggerAddCondition(t, function Conditions)
        call TriggerAddAction(t, function Actions )
        call XE_PreloadAbility(SUMMONED_SPELL_ID)
        
        set t = null
    endfunction

endscope