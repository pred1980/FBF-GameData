scope Fervor initializer init
    /*
     * Description: By using his mental power, the Tauren Chieftain increases the attack speed based on the number 
                    of allied units in his range.
     * Changelog: 
     *     	07.01.2014: Abgleich mit OE und der Exceltabelle
	 *		30.04.2015: Integrated SpellHelper for filtering
	 *		06.05.2016: Simplified filter
	 *		07.05.2016: Removed Aura and recoded Ability
     *
     */
    globals
        private constant integer SPELL_ID = 'A08M'
        private constant integer BUFF_PLACER_ID = 'A07A'
        private constant integer BUFF_ID = 'B014'
		private constant real RADIUS = 800
		private constant real DURATION = 12.0
		// Percent Value
		private integer array MAX_ATTACK_SPEED
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set MAX_ATTACK_SPEED[1] = 10
        set MAX_ATTACK_SPEED[2] = 15
        set MAX_ATTACK_SPEED[3] = 20
        set MAX_ATTACK_SPEED[4] = 25
        set MAX_ATTACK_SPEED[5] = 30
    endfunction
	
	private struct FervorData
		private unit target
		private static integer buffType = 0
		private dbuff buff = 0
		
		method onDestroy takes nothing returns nothing
			call RemoveUnitBonus(.target, BONUS_ATTACK_SPEED)
			set .target = null
		endmethod
		
		static method create takes unit caster, unit target, integer level, integer amount returns thistype
            local thistype this = thistype.allocate()
			local integer bonusAttackSpeed = 0
			
			set .target = target
			set bonusAttackSpeed = R2I(GetMin(amount, MAX_ATTACK_SPEED[level])) / 100
			set UnitAddBuff(caster, .target, .buffType, DURATION, level).data = this
			call AddUnitBonus(.target, BONUS_ATTACK_SPEED, bonusAttackSpeed)

            return this
		endmethod
		
		static method onBuffEnd takes nothing returns nothing
			call thistype(GetEventBuff().data).destroy()
        endmethod
		
		static method onInit takes nothing returns nothing
			set .buffType = DefineBuffType(BUFF_PLACER_ID, BUFF_ID, 0, false, true, 0, 0, thistype.onBuffEnd)
		endmethod
	endstruct
	
	private struct Fervor
		private unit caster
		private static thistype tempthis = 0
		
		method onDestroy takes nothing returns nothing
			set .caster = null
		endmethod
		
		private static method Fervor_Filter takes nothing returns boolean
			return SpellHelper.isValidAlly(GetFilterUnit(), tempthis.caster)
		endmethod
	
		static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
			local unit target
			local integer amount = 0
			local integer level = 0
            
			set .caster = caster
            set level = GetUnitAbilityLevel(.caster, SPELL_ID)
			set .tempthis = this
			
			call GroupClear(ENUM_GROUP)
			call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(.caster), GetUnitY(.caster), RADIUS, Filter(function thistype.Fervor_Filter))
			call GroupAddUnit(ENUM_GROUP, .caster)
			
			set amount = CountUnitsInGroup(ENUM_GROUP)
			loop
				set target = FirstOfGroup(ENUM_GROUP)
				exitwhen (target == null)
				call FervorData.create(.caster, target, level, amount)
				call GroupRemoveUnit(ENUM_GROUP, target)
			endloop

			set target = null
			call .destroy()
			
            return this
        endmethod

	endstruct
	
	private function Actions takes nothing returns nothing
        call Fervor.create(GetTriggerUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
	
	private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		call MainSetup()
	endfunction
	
endscope