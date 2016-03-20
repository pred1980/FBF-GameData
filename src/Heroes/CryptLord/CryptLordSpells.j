library CryptLordSpells initializer init requires AutoIndex, MiscFunctions, TimerUtils, GroupUtils, DamageEvent
     /*
     * Burrow Move
     * -----------
     * Description: Dominus and all his minions burrow for a limited time, after which, if there is a unit in the target area, 
                    they will come out of the earth close to it, else they will unburrow at the Crypt Lords position.
     * Changelog: 
     *     	06.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	29.03.2015: Integrated RegisterPlayerUnitEvent
     *
     */
     
     /*
     * Carrion Swarm
     * -----------
     * Description: His giant horn allows Dominus to inject his spawn into a unit. If the unit dies within the next 5 seconds, 
                    a Grub will spawn out of the corpse. There only can be a limited amount of grubs and beetles at the same time.
     * Changelog: 
     *     	06.11.2013: Abgleich mit OE und der Exceltabelle
	 *	   	08.02.2015: Decreased max. swarms from 3/5/7/9/11 to 3/4/5/6/7
	 *     	29.03.2015: Integrated RegisterPlayerUnitEvent
						Integrated SpellHelper filtering
	 *		23.11.2015: Decreased max. swarms from 3/4/5/6/7 to max. 4 per level
	 *		16.03.2016: Added Escort System for AI
     *
     */
     
     /*
     * Metamorphosis
     * -----------
     * Description: Gives your Grubs the ability to develop into the more powerful Carrion Beetles over 1 minute. 
                    They deal double damage and have more hp.
     * Changelog: 
     * 		06.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	29.03.2015: Integrated RegisterPlayerUnitEvent
	 *		18.08.2015: Bugfix (wrong beetle to a grub)
						Bugfix (wrong position for cocoons after a round end teleport)
	 *		18.03.2016: Added beetles and grubs to the escort system (only for AI)
     *
     */
    globals
        private constant integer SWARM_ID = 'A06F' // Carrion Swarm
        private constant integer BURROW_ID = 'A06E' // Burrow Move
        private constant integer MORPH_ID = 'A06H' // Metamorphosis
        private constant integer MORPH_ID_GRUB = 'A06I'
        
        private constant integer GRUB1_ID = 'h013'
        private constant integer GRUB2_ID = 'h007'
        private constant integer GRUB3_ID = 'h00A'
        private constant integer GRUB4_ID = 'h00B'
        private constant integer GRUB5_ID = 'h00D'
        private constant integer COCOON_ID = 'h00E'
        private constant integer BEETLE1_ID = 'h00F'
        private constant integer BEETLE2_ID = 'h00H'
        private constant integer BEETLE3_ID = 'h00I'
        private constant integer BEETLE4_ID = 'h00J'
        private constant integer BEETLE5_ID = 'h00K'
        
        private constant string START_MORPH_EFFECT = "Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl"
        private constant string FINISH_MORPH_EFFECT = "Objects\\Spawnmodels\\NightElf\\EntBirthTarget\\EntBirthTarget.mdl"
        private constant string START_BURROW_EFFECT = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private constant string FINISH_BURROW_EFFECT = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        
        private constant integer MAX_SWARM_BASE = 4
        private constant integer MAX_SWARM_PER_LEVEL = 0
        private constant real INFECTION_DURATION = 5.
        private constant real MORPH_DURATION = 60.
        private constant real BURROW_BASE_DURATION = 7.
        private constant real BURROW_LEVEL_REDUCTION = 1.
        private constant real BURROW_AOE = 200.
        
        private integer array stackCount
        private unit lord = null
        private player lordOwner = null
        private group grubs = CreateGroup()
        private group beetles = CreateGroup()
        private group cocoons = CreateGroup()
        private group morphing = CreateGroup()
        private integer swarmCount = 0
        private boolean morphLearned = false
        private integer array BEETLE_ID
        private integer array GRUB_ID
        
        private real tempX = 0.00
        private real tempY = 0.00
    endglobals

    private function IsCocoon takes unit u returns boolean
        return IsUnitInGroup(u,cocoons)
    endfunction

    private function IsGrub takes unit u returns boolean
        return IsUnitInGroup(u,grubs)
    endfunction

    private function IsBeetle takes unit u returns boolean
        return IsUnitInGroup(u,beetles)
    endfunction

    private function IsCarrion takes unit u returns boolean
        return IsGrub(u) or IsBeetle(u)
    endfunction
    
    private function infectUnit takes unit victim returns nothing
        local integer uid = GetUnitId(victim)
        set stackCount[uid] = stackCount[uid] + 1
        call Wait(INFECTION_DURATION)
        if victim == null then
            set stackCount[uid] = 0
        else
            set stackCount[uid] = stackCount[uid] - 1
        endif
    endfunction

    function CarrionSwarmAttack takes unit damagedUnit, unit damageSource, real damage returns nothing
        if damageSource == lord and SpellHelper.isValidEnemy(damagedUnit, damageSource) and DamageType == PHYSICAL then
            call infectUnit.execute(damagedUnit)
        endif
    endfunction
    
    private function AddMorphAbility takes nothing returns nothing
        call UnitAddAbility(GetEnumUnit(),MORPH_ID_GRUB)
    endfunction
    
    private struct saveCocoon
        unit cocoon
        real x
        real y
        
        private method onDestroy takes nothing returns nothing
            set this.cocoon = null
        endmethod
    endstruct
    
    private function eMorph takes unit cocoon, real x, real y returns nothing
        local unit b
		
		call GroupRemoveUnit(cocoons,cocoon)
        call RemoveUnit(cocoon)
		call DestroyEffect(AddSpecialEffect(FINISH_MORPH_EFFECT, x, y))
        set b = CreateUnit(lordOwner, BEETLE_ID[GetUnitAbilityLevel(lord,SWARM_ID)], x, y, GetRandomReal(0,360))
		call GroupAddUnit(beetles, b)
		
		// add to Escort System (only for Bots)
		if (Game.isBot[GetPlayerId(lordOwner)]) then
			call Escort.addUnit(lord, b)
		endif
		
		set b = null
    endfunction
    
    private function morph_callback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local saveCocoon sc = GetTimerData(t)
        
		//Get new x/y pos before eMorph
		set sc.x = GetUnitX(sc.cocoon)
        set sc.y = GetUnitY(sc.cocoon)
		
		call ReleaseTimer(t)
        if IsCocoon(sc.cocoon) then
            call eMorph.execute(sc.cocoon,sc.x,sc.y)
        endif
        call sc.destroy()
    endfunction
    
    private function MorphUnit takes unit grub returns nothing
        local timer t = NewTimer()
        local saveCocoon sc = saveCocoon.create()
        
        set sc.x = GetUnitX(grub)
        set sc.y = GetUnitY(grub)
        call GroupRemoveUnit(grubs,grub)
        call RemoveUnit(grub)
		call DestroyEffect(AddSpecialEffect(START_MORPH_EFFECT, sc.x, sc.y))
        set sc.cocoon = CreateUnit(lordOwner,COCOON_ID,sc.x,sc.y,GetRandomReal(0,360))
        call GroupAddUnit(cocoons,sc.cocoon)
        call SetTimerData(t,sc)
        call TimerStart(t,MORPH_DURATION,false,function morph_callback)
    endfunction
    
    private function startMorph takes nothing returns nothing
        local unit u = GetEnumUnit()
		
		call DestroyEffect(AddSpecialEffect(START_BURROW_EFFECT, GetUnitX(u), GetUnitY(u)))
        call UnitDisableAttack(u)
		call ShowUnit(u,false)
        set u = null
    endfunction
    
    private function finishMorph takes nothing returns nothing
        local unit u = GetEnumUnit()
		
		if (IsTerrainWalkable(tempX,tempY)) then
			call DestroyEffect(AddSpecialEffect(FINISH_BURROW_EFFECT, tempX, tempY))
        	call SetUnitX(u,tempX)
			call SetUnitY(u,tempY)
        endif
		
		call ShowUnit(u,true)
		call UnitEnableAttack(u)
        
		set u = null
    endfunction
    
    private function BurrowMove takes nothing returns nothing
        local group gr = NewGroup()
        local unit u
        local real x = GetSpellTargetX()
        local real y = GetSpellTargetY()
		local real duration = BURROW_BASE_DURATION - BURROW_LEVEL_REDUCTION * I2R(GetUnitAbilityLevel(lord, BURROW_ID))
        
        set tempX = GetUnitX(lord)
        set tempY = GetUnitY(lord)
        call GroupAddGroup(grubs,morphing)
        call GroupAddGroup(beetles,morphing)
        call GroupAddUnit(morphing,lord)
        call ForGroup(morphing,function startMorph)
        //Duration (6,5,4,3,2 seconds)
		call Wait(duration)
        call GroupEnumUnitsInRange(gr,x,y,BURROW_AOE,BOOLEXPR_TRUE)
        loop
            set u = GroupPickRandomUnit(gr)
            exitwhen u == null or not(IsCarrion(u) or lord == u or IsUnitDead(u))
            call GroupRemoveUnit(gr,u)
			set u = null
        endloop
        
        if u != null then
            set tempX = GetUnitX(u)
            set tempY = GetUnitY(u)
        endif
        
        call ForGroup(morphing,function finishMorph)
        call SelectGroupForPlayerBJ(morphing,lordOwner)
        call PanCameraToTimedForPlayer(lordOwner,tempX,tempY,0.)
        call GroupClear(morphing)
        
        call ReleaseGroup(gr)
        set u = null
    endfunction
    
    private function Conditions takes nothing returns boolean
        local integer abilID = GetSpellAbilityId()
		
        if abilID == MORPH_ID_GRUB then
            call MorphUnit(GetTriggerUnit())
        elseif abilID == BURROW_ID then
            call BurrowMove.execute()
        endif
		
        return false
    endfunction
	
	private function DeathConditions takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local unit grub
        
        if IsGrub(u) then
            call GroupRemoveUnit(grubs,u)
            set swarmCount = swarmCount - 1
        elseif IsCocoon(u) then
            call GroupRemoveUnit(cocoons,u)
            set swarmCount = swarmCount - 1
        elseif IsBeetle(u) then
            call GroupRemoveUnit(beetles,u)
            set swarmCount = swarmCount - 1
        elseif GetUnitAbilityLevel(lord,SWARM_ID) > 0 and stackCount[GetUnitId(u)] > 0 and swarmCount < MAX_SWARM_PER_LEVEL * GetUnitAbilityLevel(lord,SWARM_ID) + MAX_SWARM_BASE then
            set grub = CreateUnit(lordOwner, GRUB_ID[GetUnitAbilityLevel(lord,SWARM_ID)], GetUnitX(u), GetUnitY(u), GetRandomReal(0,360))
            set swarmCount = swarmCount + 1
            call SelectUnitAddForPlayer(grub,lordOwner)
            if morphLearned then
                call UnitAddAbility(grub,MORPH_ID_GRUB)
            endif
			
			// add to Escort System (only for Bots)
			if (Game.isBot[GetPlayerId(lordOwner)]) then
				call Escort.addUnit(lord, grub)
			endif
			
            call GroupAddUnit(grubs,grub)
			set grub = null
        endif
        set u = null
        return false
    endfunction
	
	private function LearnConditions takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local integer lid = GetLearnedSkill()
        if (lid == BURROW_ID or lid == SWARM_ID) and lord == null then
            set lord = GetTriggerUnit()
            set lordOwner = GetOwningPlayer(lord)
        elseif lid == MORPH_ID and not(morphLearned) then
            set morphLearned = true
            call ForGroup(grubs,function AddMorphAbility)
        endif
        return false
    endfunction
	
    private function init takes nothing returns nothing
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function DeathConditions, null)
		call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function LearnConditions, null)
		call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, null)
        
        set BEETLE_ID[1] = BEETLE1_ID
        set BEETLE_ID[2] = BEETLE2_ID
        set BEETLE_ID[3] = BEETLE3_ID
        set BEETLE_ID[4] = BEETLE4_ID
        set BEETLE_ID[5] = BEETLE5_ID
        set GRUB_ID[1] = GRUB1_ID
        set GRUB_ID[2] = GRUB2_ID
        set GRUB_ID[3] = GRUB3_ID
        set GRUB_ID[4] = GRUB4_ID
        set GRUB_ID[5] = GRUB5_ID
        
        call XE_PreloadAbility(MORPH_ID_GRUB)
        call Preload(START_MORPH_EFFECT)
        call Preload(FINISH_MORPH_EFFECT)
        call Preload(START_BURROW_EFFECT)
        call Preload(FINISH_BURROW_EFFECT)
        
        call RegisterDamageResponse(CarrionSwarmAttack)
    endfunction
    
endlibrary