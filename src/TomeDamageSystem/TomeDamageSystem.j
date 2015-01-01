scope TomeDamageSystem

	/*
	 * Dieses System erlaubt es Einheiten per Tomes Schaden zu geben, oder zu entfernen oder zu resetten
	 * Methods:
	 *     -  method addDamage takes unit target, integer damage returns nothing
	 *     -  method removeDamage takes unit target, integer damage returns nothing
	 *     -  method resetDamage takes unit target returns nothing
	 */ 
    globals
        private constant integer array POSITIVE_ITEMS
        private constant integer array NEGATIVE_ITEMS
        private constant integer array ITEM_VALUES
        private constant integer HERO_INVENTAR_ID = 'AInv'
		
		private hashtable DAMAGE_VALUES = InitHashtable()
    endglobals

    struct TDS
        
		static method setDamage takes unit target, integer oriDamage, boolean isBonus returns nothing
			local integer i = 0
            local integer max = 11
            local integer index = 0
			local integer tempDmg = 0
			local integer damage = oriDamage
			
			call UnitAddAbility(target, HERO_INVENTAR_ID)
			loop
                exitwhen i == max
				//Schaden ermitteln und vergleichen
				if (ITEM_VALUES[i] >= damage or i == max-1) then
					if (ITEM_VALUES[i] == damage) then
						set index = i
					else
						set index = i - 1
						set i = 0
					endif
					
					if (isBonus) then
						call UnitAddItemByIdSwapped(POSITIVE_ITEMS[index], target )
					else
						call UnitAddItemByIdSwapped(NEGATIVE_ITEMS[index], target )
					endif
					
					set tempDmg = tempDmg + ITEM_VALUES[index]
					set damage = damage - ITEM_VALUES[index]
					
					if (damage == 0) then
						set i = max-1
					endif
					call RemoveItem( GetLastCreatedItem() )
				endif
				set i = i + 1
			endloop
			call UnitRemoveAbility(target, HERO_INVENTAR_ID)
			
		endmethod
		
		static method resetDamage takes unit target returns nothing
			local integer id = GetUnitId(target)
			
			call setDamage(target, LoadInteger(DAMAGE_VALUES, 0, id), false)
			call SaveInteger(DAMAGE_VALUES, 0, id, 0)
		endmethod
		
		static method addDamage takes unit target, integer damage returns nothing
			local integer id = GetUnitId(target)
			local integer dmg = LoadInteger(DAMAGE_VALUES, 0, id) + damage
			
			call SaveInteger(DAMAGE_VALUES, 0, id, dmg)
			call setDamage(target, damage, true)
		endmethod
		
		static method removeDamage takes unit target, integer damage returns nothing
			local integer id = GetUnitId(target)
			local integer savedDmg = LoadInteger(DAMAGE_VALUES, 0, id)
			
			if (savedDmg >= damage) then
				call SaveInteger(DAMAGE_VALUES, 0, id, (savedDmg-damage))
				call setDamage(target, damage, false)
			else
				if (savedDmg > 0) then
					call SaveInteger(DAMAGE_VALUES, 0, id, (0))
					call setDamage(target, savedDmg, false)
				endif
			endif
		endmethod
		
		static method initialize takes nothing returns nothing
			// Items / Positive Folianten
			set POSITIVE_ITEMS[0] = 'I00U'
			set POSITIVE_ITEMS[1] = 'I04D'
			set POSITIVE_ITEMS[2] = 'I04E'
			set POSITIVE_ITEMS[3] = 'I04F'
			set POSITIVE_ITEMS[4] = 'I04G'
			set POSITIVE_ITEMS[5] = 'I04C'
			set POSITIVE_ITEMS[6] = 'I04H'
			set POSITIVE_ITEMS[7] = 'I04I'
			set POSITIVE_ITEMS[8] = 'I04J'
			set POSITIVE_ITEMS[9] = 'I04K'
			set POSITIVE_ITEMS[10] = 'I04L'
			
			// Items / Negative Folianten
			set NEGATIVE_ITEMS[0] = 'I00T'
			set NEGATIVE_ITEMS[1] = 'I04M'
			set NEGATIVE_ITEMS[2] = 'I04N'
			set NEGATIVE_ITEMS[3] = 'I04O'
			set NEGATIVE_ITEMS[4] = 'I04P'
			set NEGATIVE_ITEMS[5] = 'I04Q'
			set NEGATIVE_ITEMS[6] = 'I04R'
			set NEGATIVE_ITEMS[7] = 'I04S'
			set NEGATIVE_ITEMS[8] = 'I04T'
			set NEGATIVE_ITEMS[9] = 'I04U'
			set NEGATIVE_ITEMS[10] = 'I04V'
			
			// Folianten Werte
			set ITEM_VALUES[0] = 1
			set ITEM_VALUES[1] = 2
			set ITEM_VALUES[2] = 4
			set ITEM_VALUES[3] = 8
			set ITEM_VALUES[4] = 16
			set ITEM_VALUES[5] = 32
			set ITEM_VALUES[6] = 64
			set ITEM_VALUES[7] = 128
			set ITEM_VALUES[8] = 256
			set ITEM_VALUES[9] = 512
			set ITEM_VALUES[10] = 1024
		endmethod
        
    endstruct

endscope