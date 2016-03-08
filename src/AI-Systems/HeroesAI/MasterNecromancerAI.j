scope MasterNecromancerAI
    globals
        private constant integer HERO_ID = 'U01Q'
		
		private HeroAI_Itemset array Itemsets	
        private group enumGroup = CreateGroup()
		
		/* Necromancy */
		private constant integer N_SPELL_ID = 'A05D'
		private constant string N_ORDER = "summonfactory"
		private constant real N_AOE = 600
		private constant real N_RADIUS = 250
		private timer N_Timer
		private real array N_Cooldown
		private integer array N_Chance
		private integer array N_Max_Corpse
		private integer array N_Max_Random_Loc

		/* XXX */
		private constant string XX_ORDER = "xxx"
		// Chance to cast ability
		private integer array XX_Chance		
		
		/* XXX */
		private constant string XY_ORDER = "xxx"
		// Chance to cast ability
		private integer array XY_Chance		

		/* XXX */
		private constant string XZ_ORDER = "xxx"
		// Chance to cast ability
		private integer array XZ_Chance	
    endglobals
	
	
	private function RandomPointCircle takes real x, real y, real d returns location
		local real cx = GetRandomReal(-d, d)
		local real ty = SquareRoot(d * d - cx * cx)
		
		return Location(x + cx, y + GetRandomReal(-ty, ty))
	endfunction
    
    private struct AI extends array
	
		private static method onCooldownEnd takes nothing returns nothing
			call ReleaseTimer(GetExpiredTimer())
		endmethod
	
		private static method corpseFilter takes nothing returns boolean
			return SpellHelper.isUnitDead(GetFilterUnit())
		endmethod
	
		private method doNecromancy takes nothing returns boolean
			local boolean abilityCasted = false
			local integer i = 0
			local real x
			local real y
			local location l
			
			loop
				exitwhen i >= N_Max_Random_Loc[.aiLevel]
				call ClearTextMessages()
				set l = RandomPointCircle(GetUnitX(.hero), GetUnitY(.hero), N_AOE) 
				set x = GetLocationX(l)
				set y = GetLocationY(l)
				call GroupEnumUnitsInRange(enumGroup, x, y, N_RADIUS, Filter(function thistype.corpseFilter))
				
				if (CountUnitsInGroup(enumGroup) <= N_Max_Corpse[.aiLevel]) then
					
					set abilityCasted = IssuePointOrder(.hero, N_ORDER, x, y)
					set i = N_Max_Random_Loc[.aiLevel]
				endif
				call GroupClear(enumGroup)
				set i = i + 1
			endloop
			
			call RemoveLocation(l)
			set l = null
			
			if (abilityCasted) then
				call TimerStart(N_Timer, N_Cooldown[GetUnitAbilityLevel(.hero, N_SPELL_ID)], false, null)
			endif
			
			return abilityCasted
		endmethod
        
        method assaultEnemy takes nothing returns nothing  
            local boolean abilityCasted = false
			
			/* Necromancy */
			call BJDebugMsg("timer: " + R2S(TimerGetRemaining(N_Timer)))
			if 	((GetRandomInt(0,100) <= N_Chance[.aiLevel]) and /*
			*/	(TimerGetRemaining(N_Timer) == 0.0)) then
				set abilityCasted = doNecromancy()
			endif

			if (not abilityCasted) then
				call .defaultAssaultEnemy()
			endif
        endmethod
        
        method onCreate takes nothing returns nothing
			// Learnset Syntax:
			// set RegisterHeroAISkill([UNIT-TYPE ID], [LEVEL OF HERO], SKILL ID)
			// Necromancy
			call RegisterHeroAISkill(HERO_ID, 1, 'A05D')
			call RegisterHeroAISkill(HERO_ID, 5, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 9, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 13, 'A05D') 
			call RegisterHeroAISkill(HERO_ID, 16, 'A05D') 
			// Malicious Curse
			call RegisterHeroAISkill(HERO_ID, 2, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 7, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 10, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 14, 'A064') 
			call RegisterHeroAISkill(HERO_ID, 17, 'A064') 
			// Despair
			call RegisterHeroAISkill(HERO_ID, 3, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 8, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 11, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 15, 'A068') 
			call RegisterHeroAISkill(HERO_ID, 19, 'A068') 
			// Dead Souls
			call RegisterHeroAISkill(HERO_ID, 6, 'A08Z')
			call RegisterHeroAISkill(HERO_ID, 12, 'A08Z')
			call RegisterHeroAISkill(HERO_ID, 18, 'A08Z')
			//Heroes Will
			call RegisterHeroAISkill(HERO_ID, 4, 'A021')
			
			
            // This is where you would define a custom item build
			set Itemsets[.aiLevel] = HeroAI_Itemset.create()
			
            if (.aiLevel == 0) then
				/* COMPUTER EASY */
				call Itemsets[0].addItem('u000', HEALING_POTION, 2)
				call Itemsets[0].addItem('u000', MANA_POTION, 1)
				call Itemsets[0].addItem('u001', DARK_PLATES, 1)
			elseif (.aiLevel == 1) then
				/* COMPUTER NORMAL */
				call Itemsets[1].addItem('u000', HEALING_POTION, 4)
				call Itemsets[1].addItem('u000', MANA_POTION, 2)
				call Itemsets[1].addItem('u001', DARK_PLATES, 1)
				call Itemsets[1].addItem('u001', BONE_HELMET, 1)
				call Itemsets[1].addItem('u003', DEMONIC_AMULET, 1)
			else
				/* COMPUTER INSANE */
				call Itemsets[2].addItem('u000', HEALING_POTION, 5)
				call Itemsets[2].addItem('u000', MANA_POTION, 3)
				call Itemsets[2].addItem('u001', DARK_PLATES, 1)
				call Itemsets[2].addItem('u001', BONE_HELMET, 1)
				call Itemsets[2].addItem('u003', ARCANE_FLARE, 1)
				call Itemsets[2].addItem('u003', NECROMANCERS_ROBE, 1)
			endif

			set .itemBuild = Itemsets[.aiLevel]
			
			/* Ability Setup */
			// Note: 0 == Computer easy (max. 60%) | 1 == Computer normal (max. 80%) | 2 == Computer insane (max. 100%)
			// Necromancy
			set N_Chance[0] = 20
			set N_Chance[1] = 30
			set N_Chance[2] = 40
			
			set N_Timer = NewTimer()
			set N_Cooldown[0] = 25.0
			set N_Cooldown[1] = 25.0
			set N_Cooldown[2] = 25.0
			set N_Cooldown[3] = 25.0
			set N_Cooldown[4] = 25.0
			
			set N_Max_Corpse[0] = 6
			set N_Max_Corpse[1] = 4
			set N_Max_Corpse[2] = 2
			
			set N_Max_Random_Loc[0] = 2
			set N_Max_Random_Loc[1] = 4
			set N_Max_Random_Loc[2] = 6
			
			// XXX
			set XX_Chance[0] = 10
			set XX_Chance[1] = 20
			set XX_Chance[2] = 20
			
			// XXX
			set XX_Chance[0] = 10
			set XX_Chance[1] = 20
			set XX_Chance[2] = 20
			
			// XXX
			set XX_Chance[0] = 10
			set XX_Chance[1] = 20
			set XX_Chance[2] = 20
        endmethod
        
        implement HeroAI     

    endstruct
	
	//! runtextmacro HeroAI_Register("HERO_ID")
endscope