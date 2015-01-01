scope AICreeps

    globals
        private constant integer MAX_UNITS = 3
        private integer array CHANCE
        private integer array UNIT_ID
        private string array ORDER_ID
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set UNIT_ID[0] = 'u01Z' //Necromancer
        set UNIT_ID[1] = 'u021' //Banshee
        set UNIT_ID[2] = 'o009' //Witch Doctor
        
        set ORDER_ID[0] = "cripple"
        set ORDER_ID[1] = "curse"
        set ORDER_ID[2] = "healingward"
        
        set CHANCE[0] = 10 //10% chance to cast cripple if Necromancer is under attack
        set CHANCE[1] = 60
        set CHANCE[2] = 30
    endfunction
    
    private function onCastSpell takes unit caster, unit target, integer index returns nothing
        call IssueTargetOrder(caster, ORDER_ID[index], target)
    endfunction

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local integer id = GetUnitTypeId(damagedUnit)
        local integer i = 0
        
        loop
            exitwhen i == MAX_UNITS
            if id == UNIT_ID[i] and DamageType == 0 and GetRandomInt(1, 100) <= CHANCE[i] then
                call onCastSpell(damagedUnit, damageSource, i)
            endif
            set i = i + 1
        endloop
    endfunction
	
	struct KI
	
		static method initialize takes nothing returns nothing
			call MainSetup()
			call RegisterDamageResponse( Actions )
		endmethod
	
	endstruct

endscope