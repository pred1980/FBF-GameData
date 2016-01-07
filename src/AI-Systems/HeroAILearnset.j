//! textmacro HeroAILearnset
	globals
		// The level at which the hero learns all of its skills
		private constant integer MAX_HERO_LVL = 30
		
		private Learnset learnsetInfo
	endglobals
	
	private function onLearnSkillsConditions takes nothing returns boolean
		return GetOwningPlayer(GetTriggerUnit()) != Player(PLAYER_NEUTRAL_PASSIVE)
	endfunction
	
	private function onLearnSkillsActions takes nothing returns nothing
        local unit u = GetTriggerUnit() 
        local integer typeId = GetUnitTypeId(u)
		
		call SelectHeroSkill(u, learnsetInfo[GetUnitLevel(u)][typeId])
		
		set u = null
	endfunction

	struct Learnset
		private static TableArray info
        
        method operator [] takes integer lvl returns Table
            return .info[lvl - 1]
        endmethod
		
		static method create takes nothing returns thistype
			set .info = TableArray[MAX_HERO_LVL]
			
			return 1
		endmethod
		
		static method onInit takes nothing returns nothing            
            set learnsetInfo = thistype.create()

			call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function onLearnSkillsConditions, function onLearnSkillsActions)
        endmethod
	endstruct
	
	function RegisterHeroAISkill takes integer unitTypeId, integer level, integer spellId returns nothing
    	set learnsetInfo[level][unitTypeId] = spellId
    endfunction

//! endtextmacro