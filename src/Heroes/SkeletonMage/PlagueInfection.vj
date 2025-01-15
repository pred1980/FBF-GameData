scope PlagueInfection initializer init
    /*
     * Description: The curse afflicts the targeted unit with a deadly disease, dealing damage and 
                    slowing its movement speed. Whenever the unit dies under these effects, 
                    it will infect up to 10 more units. Units that survived the plague, cant be affected again.
     * Changelog: 
     *     	03.11.2013: Abgleich mit OE und der Exceltabelle
	 *		29.04.2015: Integrated SpellHelper for filtering
     *
     */
    globals
        private constant integer SPELL_ID = 'A054'
        private constant integer BUFF_PLACER_ID = 'A055'
        private constant integer BUFF_ID = 'B00K'
        private constant real TIMER_INTERVAL = 0.25
        //Sollte ein Vielfaches von TIMER_INTERVAL sein, sonst wirds ungenau
        private constant real DAMAGE_INTERVAL = 0.25
        //Der Multiplikator für weitere Infizierte Einheiten (0.75 = 75% Schaden)
        private constant real SECONDARY_INFECTION_FACTOR = 0.75
        private constant integer MAX_INFECTIONS = 10
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_SLOW_POISON
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
        private real array PLAGUE_DAMAGE
        private real array PLAGUE_DURATION
        private real array PLAGUE_INFECTION_RANGE
        private real array PLAGUE_MOVESPEED_SLOW
    endglobals
        
    private function MainSetup takes nothing returns nothing
        set PLAGUE_DAMAGE[0] = 10
        set PLAGUE_DAMAGE[1] = 20
        set PLAGUE_DAMAGE[2] = 30
        set PLAGUE_DAMAGE[3] = 40
        set PLAGUE_DAMAGE[4] = 50
        
        set PLAGUE_DURATION[0] = 8
        set PLAGUE_DURATION[1] = 8
        set PLAGUE_DURATION[2] = 8
        set PLAGUE_DURATION[3] = 8
        set PLAGUE_DURATION[4] = 8
        
        set PLAGUE_INFECTION_RANGE[0] = 100
        set PLAGUE_INFECTION_RANGE[1] = 150
        set PLAGUE_INFECTION_RANGE[2] = 200
        set PLAGUE_INFECTION_RANGE[3] = 250
        set PLAGUE_INFECTION_RANGE[4] = 300
        
        //Werte sind in Prozent anzugeben!
        set PLAGUE_MOVESPEED_SLOW[0] = 0.11
        set PLAGUE_MOVESPEED_SLOW[1] = 0.22
        set PLAGUE_MOVESPEED_SLOW[2] = 0.33
        set PLAGUE_MOVESPEED_SLOW[3] = 0.44
        set PLAGUE_MOVESPEED_SLOW[4] = 0.55
    endfunction

    private struct Main
        static constant integer spellId = SPELL_ID
        static constant boolean autoDestroy = false
        static constant integer spellType = SPELL_TYPE_TARGET_UNIT
        
        dbuff array buffs[MAX_INFECTIONS]
        real array damage[MAX_INFECTIONS]
        real array counter[MAX_INFECTIONS]
        integer array damageIndex[MAX_INFECTIONS]
        
        integer activeBuffs = 0
        integer targetCount = 0
        group targetsHit = null  
        
        static thistype temp = 0
        static real oldDamage = 0.00
        
        static boolexpr unitFilter = null
        static integer buffType = 0
        static code doInfection = null
        static delegate xedamage dmg = 0
        
        //Frag mich nicht, wieso ich die brauche, mach sie weg und der Spell wird um TIMER_INTERVAL langsamer!
        static constant real counterDebuger = 0.001
        
        method onDestroy takes nothing returns nothing
            call ReleaseGroup(targetsHit)
        endmethod
        
        method getBuffIndex takes dbuff whichBuff returns integer
            local integer i = targetCount
            loop
                exitwhen i < 0
                if buffs[i] == whichBuff then
                    return i
                endif
                set i = i - 1
            endloop
            return -1
        endmethod
        
        static method unitFilterMethod takes nothing returns boolean
            local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidEnemy(u, temp.caster) and not /*
			*/	IsUnitInGroup(u, temp.targetsHit)) then
                set b = true
            endif
			
			set u = null
			
            return b
        endmethod
        
        static method doInfectionEnum takes nothing returns nothing
            local unit u = GetEnumUnit()
            local thistype this = temp
            
			if targetCount < MAX_INFECTIONS then
                set buffs[targetCount] = UnitAddBuff(caster, u, buffType, PLAGUE_DURATION[lvl], lvl + 1)
                set buffs[targetCount].data = integer(this)
                set damage[targetCount] = oldDamage * SECONDARY_INFECTION_FACTOR
                set counter[targetCount] = 0.00
                set targetCount = targetCount + 1
                
                set activeBuffs = activeBuffs + 1
                call GroupAddUnit(targetsHit, u)
            endif
			
            set u = null
        endmethod
        
        method infectUnits takes integer index returns nothing
            if targetCount < MAX_INFECTIONS then
                set temp = this
                set oldDamage = damage[index]
                call GroupRefresh(ENUM_GROUP)
                call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(buffs[index].target), GetUnitY(buffs[index].target), PLAGUE_INFECTION_RANGE[lvl], unitFilter)
                call ForGroup(ENUM_GROUP, doInfection)
            endif
        endmethod
        
        
        static method onBuffEnd takes nothing returns nothing
            local thistype this = thistype(GetEventBuff().data)
            local integer index = getBuffIndex(GetEventBuff())
            
			set activeBuffs = activeBuffs - 1
            if IsUnitType(buffs[index].target, UNIT_TYPE_DEAD) then
                call infectUnits(index)
            endif
            if activeBuffs <= 0 then
                call destroy()
            endif
        endmethod
        
        static method periodicActions takes nothing returns nothing
            local thistype this = thistype(GetEventBuff().data)
            local integer index = getBuffIndex(GetEventBuff())
            
			set counter[index] = counter[index] + TIMER_INTERVAL
            if DAMAGE_INTERVAL - counterDebuger <= counter[index] then
                set DamageType = SPELL
                call damageTarget(caster, buffs[index].target, damage[index] * DAMAGE_INTERVAL)
                set counter[index] = 0.00
            endif
        endmethod
        
        
        method onCast takes nothing returns nothing
            set lvl = lvl - 1
            
            set buffs[targetCount] = UnitAddBuff(caster, target, buffType, PLAGUE_DURATION[lvl], lvl + 1)
            set buffs[targetCount].data = integer(this)
            set damage[targetCount] = PLAGUE_DAMAGE[lvl]
            set counter[targetCount] = 0.00
            set damageIndex[targetCount] = 0
            set targetCount = targetCount + 1
            
            set activeBuffs = activeBuffs + 1
            set targetsHit = NewGroup()
            call GroupAddUnit(targetsHit, target)
        endmethod
        
        private static method onInit takes nothing returns nothing
            call MainSetup()
            set buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, TIMER_INTERVAL, true, false,0, thistype.periodicActions, thistype.onBuffEnd)
            set dmg = xedamage.create()
            set unitFilter = Condition(function thistype.unitFilterMethod)
            set doInfection = function thistype.doInfectionEnum
            set atype = ATTACK_TYPE
            set dtype = DAMAGE_TYPE
			set wtype = WEAPON_TYPE
            call XE_PreloadAbility(BUFF_PLACER_ID)
        endmethod
        
        implement Spell
    endstruct
    
    private function init takes nothing returns nothing
        call XE_PreloadAbility(BUFF_PLACER_ID)
    endfunction
endscope