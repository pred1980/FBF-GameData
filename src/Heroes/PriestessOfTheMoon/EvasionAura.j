scope EvasionAura initializer Init

	globals
		private constant integer BUFF_ID = 'B016'
		private constant integer CHANCE = 30
	endglobals
	
	private struct EvadeDamage extends DamageModifier
	
		private static integer PRIORITY = 0

		method onDamageTaken takes unit damagedUnit, real damage returns real
			call TextTagMiss(damagedUnit)
			call .destroy()
			
			return -damage
		endmethod
		
		static method create takes unit damagedUnit, real damage returns thistype
            local thistype this = .allocate(damagedUnit, .PRIORITY)
			
            return this
        endmethod

	endstruct

	private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
		if (GetUnitAbilityLevel(damagedUnit, BUFF_ID) > 0 and /*
		*/	DamageType == PHYSICAL and /*
		*/	GetRandomInt(0,100) <= CHANCE) then
			call EvadeDamage.create(damagedUnit, damage)
        endif
    endfunction
    
    private function Init takes nothing returns nothing
        call RegisterDamageResponse(Actions)
    endfunction

endscope