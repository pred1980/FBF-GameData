library CABonus

    module CABonus
        public integer hp = 0
        public integer mp = 0
        
        public integer amr = 0
        public integer dmg = 0
        
        public integer as = 0
        
        public integer mr = 0
        public integer lf = 0
        
        public integer str = 0
        public integer agi = 0
        public integer int = 0
        
        public integer sr = 0
        
        method addBonus takes unit theUnit returns nothing
            if .hp != 0 then
                call AddUnitBonus(theUnit, BONUS_LIFE, .hp)
            endif
            
            if .mp != 0 then
                call AddUnitBonus(theUnit, BONUS_MANA, .mp)
            endif
            
            if .amr != 0 then
                call AddUnitBonus(theUnit, BONUS_ARMOR, .amr)
            endif
            
            if .dmg != 0 then
                call AddUnitBonus(theUnit, BONUS_DAMAGE, .dmg)
            endif
            
            if .as != 0 then
                call AddUnitBonus(theUnit, BONUS_ATTACK_SPEED, .as)
            endif
            
            if .mr != 0 then
                call AddUnitBonus(theUnit, BONUS_MANA_REGEN_PERCENT, .mr)
            endif
            
            if .lf != 0 then
                call AddUnitBonus(theUnit, BONUS_LIFE_REGEN, .lf)
            endif
            
            if .str != 0 then
                call AddUnitBonus(theUnit, BONUS_STRENGTH, .str)
            endif
            
            if .agi != 0 then
                call AddUnitBonus(theUnit, BONUS_AGILITY, .agi)
            endif
            
            if .int != 0 then
                call AddUnitBonus(theUnit, BONUS_INTELLIGENCE, .int)
            endif
            
            if .sr!= 0 then
                call AddUnitBonus(theUnit, BONUS_SIGHT_RANGE, .sr)
            endif
        endmethod
        
        method removeBonus takes unit theUnit returns nothing
            if .hp != 0 then
                call AddUnitBonus(theUnit, BONUS_LIFE, -.hp)
            endif
            
            if .mp != 0 then
                call AddUnitBonus(theUnit, BONUS_MANA, -.mp)
            endif
            
            if .amr != 0 then
                call AddUnitBonus(theUnit, BONUS_ARMOR, -.amr)
            endif
            
            if .dmg != 0 then
                call AddUnitBonus(theUnit, BONUS_DAMAGE, -.dmg)
            endif
            
            if .as != 0 then
                call AddUnitBonus(theUnit, BONUS_ATTACK_SPEED, -.as)
            endif
            
            if .mr != 0 then
                call AddUnitBonus(theUnit, BONUS_MANA_REGEN_PERCENT, -.mr)
            endif
            
            if .lf != 0 then
                call AddUnitBonus(theUnit, BONUS_LIFE_REGEN, -.lf)
            endif
            
            if .str != 0 then
                call AddUnitBonus(theUnit, BONUS_STRENGTH, -.str)
            endif
            
            if .agi != 0 then
                call AddUnitBonus(theUnit, BONUS_AGILITY, -.agi)
            endif
            
            if .int != 0 then
                call AddUnitBonus(theUnit, BONUS_INTELLIGENCE, -.int)
            endif
            
            if .sr!= 0 then
                call AddUnitBonus(theUnit, BONUS_SIGHT_RANGE, -.sr)
            endif
        endmethod
    endmodule
endlibrary

