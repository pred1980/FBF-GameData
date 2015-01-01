scope SleepyDust initializer init
    /*
     * Description: The Snake Tongue summons an invisible Dust Bag on the floor that releases Sleep Powder 
                    when an enemy steps on it, effectively putting the unit to sleep.
     * Last Update: 18.11.2013
     * Changelog: 
     *     18.11.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
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
    
    private function Conditions takes nothing returns boolean
        local integer a = GetUnitTypeId(GetAttacker())
        return a == BAG_IDS[0] or a == BAG_IDS[1] or a == BAG_IDS[2] or a == BAG_IDS[3] or a == BAG_IDS[4]
    endfunction
    
    private function Actions takes nothing returns nothing
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
    
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger(  )
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_ATTACKED )
        call TriggerAddCondition( t, Condition( function Conditions ) )
        call TriggerAddAction( t, function Actions )
        call MainSetup()
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(EFFECT)
    endfunction
    
endscope