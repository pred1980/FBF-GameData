scope TitanDevourer
	/*
	 * Changelog: 
			29.04.2015: Integrated SpellHelper for damaging and filtering
	*
	*/
	
	globals
		private constant integer SPELL_ID = 'A0AD'
        private constant integer BASE_DAMAGE = 100
        private constant real DAMAGE_MULTIPLIER = 6.5
        //Diese Faktoren beschreibt die Erhöhung der HP/Damage Werte je nach Spieleranzahl, im akt. Fall 5%
        private constant real HP_FACTOR = 0.00 //Prozentwert
        private constant real DAMAGE_FACTOR = 0.00 //Prozentwert
		
		//DOT
        private constant real DOT_TIME = 10.0
        private constant string EFFECT = "Abilities\\Spells\\NightElf\\TargetArtLumber\\TargetArtLumber.mdl"
        private constant string ATT_POINT = "origin"
        
        private rect titanRect
        private group isDevoured
	endglobals
	
    private function GetTitanDevourDamage takes nothing returns integer
        return BASE_DAMAGE + R2I((DAMAGE_MULTIPLIER * I2R(RoundSystem.actualRound)))
    endfunction
    
	scope TitanDevourer

		globals
            private constant integer TITAN_ID = 'e00C'
            private constant real TITAN_ATTACK_ANIMATION = 0.967
            private constant integer HP = 20000
            private constant integer DAMAGE = 650
            private constant real RADIUS = 380.0
			private constant real DELAY = 60 //Time before a target devoured again
		endglobals
        
        struct Titan
			private tatic unit titan
            private unit target
			private static group g
            private static integer hp = 0
            private static integer dmg = 0
            private static thistype tempthis
			
			method onDestroy takes nothing returns nothing
				set .titan = null
				set .target = null
			endmethod
			
			private static method onUnitDeath takes nothing returns nothing
				if GetUnitTypeId(GetTriggerUnit()) == TITAN_ID then
					call Usability.getTextMessage(0, 9, true, GetLocalPlayer(), true, 0.00)
					call TeleportSystem.create()
				endif
			endmethod
            
            //update HP+Damage if a player left game
            static method onUpdate takes nothing returns nothing
                if not IsUnitDead(.titan) then
                    //get new hp+dmg
                    set .hp = GetDynamicRatioValue(HP, HP_FACTOR)
                    set .dmg = GetDynamicRatioValue(DAMAGE, DAMAGE_FACTOR)
                    call SetUnitMaxState(.titan, UNIT_STATE_MAX_LIFE, .hp)
                    call TDS.resetDamage(.titan)
					call TDS.addDamage(.titan, .dmg)
                endif
            endmethod
			
            private static method onDevourCond takes nothing returns boolean
                local unit u = GetFilterUnit()
				local boolean b = false
                
				if (SpellHelper.isValidEnemy(u, .tempthis.titan) and /*
				*/  IsUnitType(u, UNIT_TYPE_HERO) and not /*
				*/  SpellHelper.isUnitDead(.tempthis.titan) and not /*
				*/ 	IsUnitInGroup(u, g) and not /*
				*/  Devour.isUnitDevoured() and /*
				*/  GetUnitAbilityLevel(u, 'Bvul') == 0 and /* //standard Unverwundbarkeit
				*/  and GetUnitAbilityLevel(u, 'B024') == 0) then //potion Unverwundbarkeit
					set b = true
                endif
                
				set u = null
				
                return b
			endmethod
			
			static method onRemoveTargetFromGroup takes nothing returns nothing
				call GroupRemoveUnit(g, .tempthis.target)
			endmethod
            
            static method onDevour takes nothing returns nothing
				local real ang = 0.00
                
                set .tempthis.target = GetTriggerUnit()
                set ang = AngleBetweenCords(GetUnitX(.tempthis.titan), GetUnitY(.tempthis.titan), GetUnitX(.tempthis.target), GetUnitY(.tempthis.target))  
                
				call GroupAddUnit(g, .tempthis.target)
                call GroupAddUnit(isDevoured, .tempthis.target)
                call SetUnitAnimation(.tempthis.titan, "attack")
                call Stun_UnitEx(.tempthis.titan, TITAN_ATTACK_ANIMATION, false, "", "")
                call Stun_UnitEx(.tempthis.target, TITAN_ATTACK_ANIMATION, false, "", "")
                call SetUnitFacing(.tempthis.titan, ang)
                call TimerStart(NewTimer(), TITAN_ATTACK_ANIMATION, false, function thistype.onDevourCreate)
				call TimerStart(NewTimer(), DELAY, false, function thistype.onRemoveTargetFromGroup)
			endmethod
            
            static method onDevourCreate takes nothing returns nothing
                local Devour d = 0
                
                call ReleaseTimer(GetExpiredTimer())
                call SetUnitPosition(.tempthis.target, GetUnitX(.tempthis.titan), GetUnitY(.tempthis.titan))
                set d = Devour.create(.tempthis.target, .tempthis.titan)
            endmethod
			
			static method create takes nothing returns thistype
				local thistype this = thistype.allocate()
				local trigger t = CreateTrigger()
				
				set .titan = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), TITAN_ID, GetRectCenterX(titanRect), GetRectCenterY(titanRect), 180.00)
				set .target = null
                
                set .hp = GetGameStartRatioValue(HP, HP_FACTOR)
                set .dmg = GetGameStartRatioValue(DAMAGE, DAMAGE_FACTOR)
                
                call SetUnitMaxState(.titan, UNIT_STATE_MAX_LIFE, .hp)
                call SetUnitState(.titan, UNIT_STATE_LIFE, GetUnitState(.titan, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
                call TDS.addDamage(.titan, .dmg)
                
                call TriggerRegisterUnitInRangeSimple( t, RADIUS, .titan)
				call TriggerAddCondition(t, Condition(function thistype.onDevourCond))
                call TriggerAddAction(t, function thistype.onDevour)
				
				//on Death Event
				call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, null, function thistype.onUnitDeath)
				
				set .tempthis = this
				set t = null
				
				return this
			endmethod
			
			static method onInit takes nothing returns nothing
				set titanRect = gg_rct_Titan
				set g = NewGroup()
			endmethod
		
		endstruct
		
	endscope
	
	/**********************************
	 *  D E V O U R    A B I L I T Y  *
	 * ********************************/
	
	scope Devour

		globals
            private constant boolean KILL_IF_CASTER_DIES = false
			private constant string EFFECT_EXECUTION_POINT = "chest"
			private constant string EFFECT_FINISH_POINT = "origin"
			private constant real CORPSE_DROP_RANGE = 25.
            private constant real DAMAGER_PER_INTERVAL = 1.0
			private constant real MAX_INTERVAL = 10.0
			
			// Dealt damage configuration
			private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
			private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
			private constant weapontype WEAPON_TYPE = WEAPON_TYPE_METAL_HEAVY_BASH
            
            private string SOUND_1 = "Units\\Orc\\KotoBeast.wav"
            private group isDevouring
			private string targetE
			private string exeE
			private string finishE
		endglobals
		
		private function setLifePer takes CustomBar cb returns nothing
			set cb.txtBar.percentage = GetUnitStatePercent(cb.target, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE)
		endfunction
		
		private function showCheck takes player owner, player cur returns boolean
			return IsPlayerAlly(owner, cur) or owner == cur
		endfunction

		struct Devour
			unit cast
			unit targ
			real time = 0.00
			CustomBar cb = 0
			ARGB left = 0
			ARGB right = 0
            fogmodifier visibibleArea
			
			method onDestroy takes nothing returns nothing
				if KILL_IF_CASTER_DIES and not IsUnitDead(.targ) then
					call KillUnit(.targ)
				endif
				call GroupRemoveUnit(isDevouring, .cast)
                
                call UnitRemoveAbility(.targ, SPELL_ID)
                call UnitAddAbility(.targ, SPELL_ID)
                call ShowUnit(.targ, true)
				call GroupRemoveUnit(isDevoured, .targ)  
				call DestroyEffect(AddSpecialEffectTarget(finishE, .targ, EFFECT_FINISH_POINT))
                call ReleaseTimer(GetExpiredTimer())
                call .cb.destroy()
                call SetUnitPathing(.targ, true)
                call DestroyFogModifier(.visibibleArea)
			endmethod
			
			static method create takes unit u1, unit u2 returns thistype
				local thistype this = thistype.allocate()
				local timer t = NewTimer()
				local integer lvl = GetUnitAbilityLevel(u2, SPELL_ID)
				
				set this.cast = u2
				set this.targ = u1
				set .visibibleArea = CreateFogModifierRectBJ(true, GetOwningPlayer(this.targ), FOG_OF_WAR_VISIBLE, titanRect)
                
                call Sound.runSoundOnUnit(SOUND_1, this.targ)
				call DestroyEffect(AddSpecialEffect(targetE, GetUnitX(GetSpellTargetUnit()),GetUnitY(GetSpellTargetUnit())))
				call GroupAddUnit(isDevouring, this.cast)
				
                call UnitAddAbility(this.targ, SPELL_ID)
				call SetUnitAbilityLevel(this.targ, SPELL_ID, 1)
                call IssueImmediateOrder( this.targ, "windwalk" )
                
                call ShowUnit(this.targ, false)
                call SetUnitPathing(this.targ, false)
				
				call SetTimerData(t,integer(this))
				call TimerStart(t, DAMAGER_PER_INTERVAL, true, thistype.onLoop)
				
				set t = null
				
				call onInitBar(this.targ)
				
				return this
			endmethod
			
			static method onLoop takes nothing returns nothing
				local thistype this = thistype(GetTimerData(GetExpiredTimer()))
				local real damage = I2R(GetTitanDevourDamage())
                
                if ((GetWidgetLife(this.targ) > .405 and GetWidgetLife(this.cast) > .405) or time < MAX_INTERVAL) then
					if GetWidgetLife(this.targ) < damage then
						call SetWidgetLife(this.cast, GetWidgetLife(this.cast) + (damage - GetWidgetLife(this.targ)))
					else
                        call SetWidgetLife(this.cast, GetWidgetLife(this.cast) + damage)
					endif
                    set DamageType = PHYSICAL
					call SpellHelper.damageTarget(this.cast, this.targ, damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                    call DestroyEffect(AddSpecialEffectTarget(exeE, this.cast, EFFECT_EXECUTION_POINT))
				else
					call this.destroy()
				endif
				
				set time = time + 1.0
			endmethod
            
			method onInitBar takes unit target returns nothing
				set .left = ARGB.create(255, 8, 74, 16)
				set .right = ARGB.create(255, 214, 255, 230)
				
				set .cb = CustomBar.create(target, CustomBar_iChange.setLifePer)
				
				set .cb.txtTag.offsetX = -92.
				set .cb.txtTag.offsetY = -32.
				
				call .cb.txtBar.addGradient(left, right, 1, 25)
				
				call .cb.Show(bj_FORCE_ALL_PLAYERS, CustomBar_iShow.showCheck)
				
				call .cb.showCB()
			endmethod
            
            static method isUnitDevoured takes nothing returns boolean
                return CountUnitsInGroup(isDevoured) > 0
            endmethod
			
            static method onInit takes nothing returns nothing
                set isDevouring = NewGroup()
                set isDevoured = NewGroup()
                set targetE = GetAbilityEffectById(SPELL_ID,EFFECT_TYPE_AREA_EFFECT,0)
                
                call Preload(targetE)
                set exeE = GetAbilityEffectById(SPELL_ID,EFFECT_TYPE_EFFECT,0)
                
                call Preload(exeE)
                set finishE = GetAbilityEffectById(SPELL_ID,EFFECT_TYPE_SPECIAL,0)
                
                call Preload(finishE)
                call Sound.preload(SOUND_1)
            endmethod
        endstruct
	endscope
endscope