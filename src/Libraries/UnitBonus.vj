library UnitBonus requires BonusMod, optional UnitMaxStateBonuses, optional MovementBonus, optional UnitStats

    //! textmacro UnitBonuses___make takes Type, Name
    struct $Name$Bonus
    
        readonly integer applied = 0
        readonly unit owner = null
        integer max = 0
        integer min = 0
        
        //Creates a now Bonus of this type using the Bonus Max and Min Values
        //Store this struct, because it wont be attached to the owner 
        static method create takes unit whichUnit returns thistype
            local thistype this = allocate()
            set owner = whichUnit
            set min = BONUS_$Type$.minBonus 
            set max = BONUS_$Type$.maxBonus
            return this
        endmethod
        
        //Creates a now Bonus of this type for the given unit using the saving the max and min values
        //Store this struct, because it wont be attached to the owner 
        static method createEx takes unit whichUnit, integer maxValue, integer minValue returns thistype
            local thistype this = allocate()
            set owner = whichUnit
            set max = maxValue
            set min = minValue
            return this
        endmethod
        
        //Adds the bonus by the given value.
        //Returns the final bonus added to the unit.
        method add takes integer value returns integer
            local integer old = GetUnitBonus(owner, BONUS_$Type$)
            local integer added = 0
            //debug call ClearTextMessages()
            //debug call BJDebugMsg("---- " + GetUnitName(owner) + " Unit Bonus ($Name$) ----")
            //debug call BJDebugMsg("Given $Name$: " + I2S(value))
            if (applied == max and value > 0) or (applied == min and value < 0) then
                //debug call BJDebugMsg("Total $Name$ already is at min or max.")
                return 0
            endif
            if applied + value > max and value > 0 then
                //debug call BJDebugMsg("Resulting $Name$ (" + I2S(applied + value) + ") ist greater than " + I2S(max) + ".")
                //debug call BJDebugMsg("Reducing $Name$ from " + I2S(value) + " to " + I2S(applied + value - max) + ".")
                set value = value - (applied + value - max)
            elseif applied + value < min and value < 0 then
                //debug call BJDebugMsg("Resulting $Name$ (" + I2S(applied + value) + ") ist smaller than " + I2S(max) + ".")
                //debug call BJDebugMsg("Increasing $Name$ from " + I2S(value) + " to " + I2S(value - (applied + value - min)) + ".")
                set value = value - (applied + value - min)
            endif
            //debug call BJDebugMsg("Trying to add " + I2S(value) + " $Name$ to " + GetUnitName(owner) + ".")
            call AddUnitBonus(owner, BONUS_$Type$, value)
            set added = GetUnitBonus(owner, BONUS_$Type$) - old
            //debug call BJDebugMsg("Succesfull added " + I2S(added) + " $Name$ to " + GetUnitName(owner))
            set applied = applied + added
            //debug call BJDebugMsg("Total added $Name$: " + I2S(applied))
            return added
        endmethod
        
        
        //Removes all applied boni to this unit of this instance
        //If destroyAfter is true, the struct will be destroyed after the removal of the boni
        method remove takes boolean destroyAfter returns nothing
            //debug call BJDebugMsg("Removing " + I2S(applied) + " $Name$ from " + GetUnitName(owner) + ".")
            call AddUnitBonus(owner, BONUS_$Type$, -applied)
            if destroyAfter then
                call destroy()
            else
                set applied = 0
            endif
        endmethod
        
    endstruct
    
    //! endtextmacro 
    
    
    //Basic Boni
    //! runtextmacro UnitBonuses___make("DAMAGE", "Damage")
    //! runtextmacro UnitBonuses___make("ARMOR", "Armor")
    //! runtextmacro UnitBonuses___make("ATTACK_SPEED", "Attackspeed")
    //! runtextmacro UnitBonuses___make("MANA_REGEN_PERCENT", "ManaRegPerc")
    //! runtextmacro UnitBonuses___make("LIFE_REGEN", "LifeReg")
    
    
    //Hero Boni
    //! runtextmacro UnitBonuses___make("STRENGTH", "Str")
    //! runtextmacro UnitBonuses___make("AGILITY", "Agi")
    //! runtextmacro UnitBonuses___make("INTELLIGENCE", "Int")

    //Life/Mana Boni
    
        static if LIBRARY_UnitMaxStateBonuses then
        
            //Life
            //! runtextmacro UnitBonuses___make("LIFE", "Life")
            
            //Mana
            //! runtextmacro UnitBonuses___make("MANA", "Mana")   
            
        endif
        
        
    //LifePerc/ManaConst Boni
        static if LIBRARY_RegenBonuses then
        
        
            //Life-Perc-Regen
            //! runtextmacro UnitBonuses___make("LIFE_REGEN_PERCENT", "LifeRegPerc")
            
            //Mana-Regen
            //! runtextmacro UnitBonuses___make("MANA_REGEN", "ManaReg")  
            
        endif
            
            
    
endlibrary