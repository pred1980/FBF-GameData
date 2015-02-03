scope TitanDevourer

	globals
		private constant integer SPELL_ID = 'A0AD'
        private constant integer BASE_DAMAGE = 12
        private constant real DAMAGE_MULTIPLIER = 6.5
        //Diese Faktoren beschreibt die Erh?hung der HP/Damage Werte je nach Spieleranzahl, im akt. Fall 5%
        private constant real HP_FACTOR = 0.10 //0.05
        private constant real DAMAGE_FACTOR = 0.12 //0.09
        
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
            private constant integer HP = 12000
            private constant integer DAMAGE = 285
            private constant real RADIUS = 380.0
		endglobals
        
        struct Titan
			static unit titan
            unit target
            static integer hp = 0
            static integer dmg = 0
            static thistype tempthis
            
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
				
				set .tempthis = this
				set t = null
				
				return this
			endmethod
            
            static method onDevourCond takes nothing returns boolean
                local unit u = GetFilterUnit()
                
                if (IsUnitEnemy(u, GetOwningPlayer(.tempthis.titan)) /*
                */  and IsUnitType(u, UNIT_TYPE_HERO) /*
                */  and not IsUnitDead(.tempthis.titan) /*
                */  and not IsUnitDead(u) /*
                */  and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) /*
                */  and not IsUnitType(u, UNIT_TYPE_MECHANICAL) /*
                */  and not Devour.isUnitDevoured()) /*
                */  and GetUnitAbilityLevel(u, 'Bvul') == 0 /* //standard Unverwundbarkeit
                */  and GetUnitAbilityLevel(u, 'B024') == 0 then //potion Unverwundbarkeit
                
                    return true
                endif
                
                return false
			endmethod
            
            static method onDevour takes nothing returns nothing
				local timer t = NewTimer()
                local real ang = 0.00
                
                set .tempthis.target = GetTriggerUnit()
                set ang = AngleBetweenCords(GetUnitX(.tempthis.titan), GetUnitY(.tempthis.titan), GetUnitX(.tempthis.target), GetUnitY(.tempthis.target))  
                
                call GroupAddUnit(isDevoured, .tempthis.target)
                call SetUnitAnimation(.tempthis.titan, "attack")
                call Stun_UnitEx(.tempthis.titan, TITAN_ATTACK_ANIMATION, false, "", "")
                call Stun_UnitEx(.tempthis.target, TITAN_ATTACK_ANIMATION, false, "", "")
                call SetUnitFacing(.tempthis.titan, ang)
                call TimerStart(t, TITAN_ATTACK_ANIMATION, false, function thistype.onDevourCreate)
			endmethod
            
            static method onDevourCreate takes nothing returns nothing
                local Devour d = 0
                
                call ReleaseTimer(GetExpiredTimer())
                call SetUnitPosition(.tempthis.target, GetUnitX(.tempthis.titan), GetUnitY(.tempthis.titan))
                set d = Devour.create(.tempthis.target, .tempthis.titan)
            endmethod
			
			method onDestroy takes nothing returns nothing
				set .titan = null
				set .target = null
			endmethod
            
            static method onInit takes nothing returns nothing
				set titanRect = gg_rct_Titan
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
            private constant real DAMAGER_PER_INTERVAL = 1.2
            
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
			static code onLoopFunc // Just to keep the code organized since it's a public resource
			CustomBar cb = 0
			ARGB left = 0
			ARGB right = 0
            fogmodifier visibibleArea
			
			static method create takes unit u1, unit u2 returns thistype
				local thistype this = thistype.allocate()
				local timer t = NewTimer()
				local integer lvl = GetUnitAbilityLevel(u2, SPELL_ID)
				
				set this.cast = u2
				set this.targ = u1
				set .visibibleArea = CreateFogModifierRectBJ( true, GetOwningPlayer(this.targ), FOG_OF_WAR_VISIBLE, titanRect )
                
                call Sound.runSoundOnUnit(SOUND_1, this.targ)
				call DestroyEffect(AddSpecialEffect(targetE, GetUnitX(GetSpellTargetUnit()),GetUnitY(GetSpellTargetUnit())))
				call GroupAddUnit(isDevouring, this.cast)
				
                call UnitAddAbility(this.targ, SPELL_ID)
				call SetUnitAbilityLevel(this.targ, SPELL_ID, 1)
                call IssueImmediateOrder( this.targ, "windwalk" )
                
                call ShowUnit(this.targ, false)
                call SetUnitPathing(this.targ, false)
				
				call SetTimerData(t,integer(this))
				call TimerStart(t, DAMAGER_PER_INTERVAL, true, thistype.onLoopFunc)
				
				set t = null
				
				call onInitBar(this.targ)
				
				return this
			endmethod
			
			static method onLoop takes nothing returns nothing
				local thistype this = thistype(GetTimerData(GetExpiredTimer()))
				local real damage = I2R(GetTitanDevourDamage())
                
                if GetWidgetLife(this.targ) > .405 and GetWidgetLife(this.cast) > .405 then
					if GetWidgetLife(this.targ) < damage then
						call SetWidgetLife(this.cast, GetWidgetLife(this.cast) + (damage - GetWidgetLife(this.targ)))
					else
                        call SetWidgetLife(this.cast, GetWidgetLife(this.cast) + damage)
					endif
                    set DamageType = PHYSICAL
                    call DamageUnitPhysical(this.cast, this.targ, damage)
                    call DestroyEffect(AddSpecialEffectTarget(exeE, this.cast, EFFECT_EXECUTION_POINT))
				else
					call this.destroy()
				endif
			endmethod
            
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
                set Devour.onLoopFunc = function Devour.onLoop
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