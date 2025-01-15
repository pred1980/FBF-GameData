scope AngerOfThrall initializer init
	/*
	 * Item: Shaman Hood
	 */ 
    globals
         // The Raw code of the ability
        private constant integer ITEM_ID = 'I02W'
        // Dummy-Id for Chain Lightning and the Ability
        private constant integer DUMMY_ID = 'e00G'
        private constant integer DUMMY_SPELL_MEELE_ID = 'A03Y' // Lightning Shield
        private constant integer DUMMY_SPELL_RANGE_ID = 'A05C' // Chain Lightning
        private constant integer BUFF_ID = 'B005'
        private constant integer ANGER_CHANCE = 15
    endglobals

    private struct Spell
        group gr
        unit gu
        unit attacker
        unit target
        unit dummy 
        static Spell tempthis
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitEnemy(Spell.tempthis.attacker,GetOwningPlayer(Spell.tempthis.gu)) and (Spell.tempthis.gu != Spell.tempthis.attacker)
        endmethod
        
        static method create takes unit attacker, unit target returns Spell
            local Spell this = Spell.allocate()
            local real x = 0
            local real y = 0
            
            set .attacker = attacker
            set .target = target
            set x = GetUnitX(.attacker)
            set y = GetUnitY(.attacker)
            set Spell.tempthis = this
            set .dummy = CreateUnit(GetOwningPlayer(.attacker), DUMMY_ID, x, y, 0)
            
            if IsUnitType(.attacker, UNIT_TYPE_MELEE_ATTACKER) then
                call UnitAddAbility(.dummy, DUMMY_SPELL_MEELE_ID)
                call UnitApplyTimedLife(.dummy, 'BTLF', 1.00)
                call IssueTargetOrder( .dummy, "lightningshield", .attacker )
            else
                set .gr = NewGroup()
                call UnitAddAbility(.dummy, DUMMY_SPELL_RANGE_ID)
                call UnitApplyTimedLife(.dummy, 'BTLF', 1.00)
                call GroupEnumUnitsInArea( .gr, x, y, 900, Condition( function Spell.group_filter_callback ) )
                call GroupRemoveUnit(.gr, .attacker) 
                loop
                    set .gu = FirstOfGroup(.gr)
                    exitwhen .gu == null
                    call GroupRemoveUnit(.gr, .gu)
                    call IssueTargetOrder( .dummy, "chainlightning", .gu )
                endloop
            endif
            
            return this
        endmethod
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(.gr)
            set .gu = null
            set .attacker = null
            set .target = null
            set .dummy = null 
        endmethod
        
        static method onInit takes nothing returns nothing
            set Spell.tempthis = 0
        endmethod
    endstruct
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local Spell s = 0
        
        if ( UnitHasItemOfTypeBJ(damageSource, ITEM_ID) and GetRandomInt(1, 100) <= ANGER_CHANCE and DamageType == 0 and GetUnitAbilityLevel(damageSource, BUFF_ID) == 0 ) then
            set s = Spell.create( damageSource, damagedUnit )
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call XE_PreloadAbility(DUMMY_SPELL_MEELE_ID)
        call XE_PreloadAbility(DUMMY_SPELL_RANGE_ID)
    endfunction

endscope