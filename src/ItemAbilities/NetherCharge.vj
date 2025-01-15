scope NetherCharge initializer init
	/*
	 * Item: Nether Charge
	 */ 
    globals
        private constant integer ITEM_ID = 'I03P'//spell ID of nether charge
        private constant integer BANISH_ID = 'A02I'//spell ID of the banish spell
        private constant integer DUMMY_ID = 'e00L' //Dummy to add the Buff on the Target
        private constant integer DUMMY_SPELL_ID = 'A02G' // Nether Charge Spell
        private constant integer BUFF_ID = 'B000'//ID of the nether charge buff
        private constant integer B_BUFF_ID = 'B001'//ID of the phase out buff
        
        private constant string chargeEffect = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"//effect that appears when a unit is hit by the spell
        private constant string dmgEffect = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"//effect that appears when a unit is damaged
        private constant string lightSfx = "CLPB"//model path of the lightning effects
        
        private constant real radius = 350.0 //radius of the discharges
        private constant real radiusInc = 50.0 //radius increment per level
        private constant real damage = 75.0 //damage of the lightning bolts
        private constant real damageInc = 25.0 //damage increment per level
        
        private constant real dt = 1.5//timer between each pulse
        private constant real lt = 0.3//duration of each lightning effect
        
        private constant boolean L_checkVis = false//false if you don't want the lightning effects to be affected by fog, true otherwise
        
        private constant integer CHANCE = 10
    endglobals
    
    private function setupDamageOptions takes xedamage d returns nothing
        //setup of the damage options
        set d.dtype = DAMAGE_TYPE_MAGIC    //deals magic damage
        set d.atype = ATTACK_TYPE_NORMAL   //normal attack type
        
        set d.damageEnemies = true     //hits enemies
        set d.damageAllies  = false    //doesn't hit allies
        set d.damageNeutral = true     //hits neutral units
        set d.damageSelf    = false    //doesn't hit self
        set d.exception = UNIT_TYPE_STRUCTURE    //doesn't hit structures
        set d.damageTrees = false
        call d.useSpecialEffect(dmgEffect, "origin")
    endfunction

    globals
        private xedamage damageOptions
        private group unitGrp
        private group EG
        private boolexpr b
    endglobals
    
    private struct Data
        static group isAffected
        static integer index = 0
    
        unit caster
        unit target
        boolean hasbuff = false
        
        private static method onInit takes nothing returns nothing
            set Data.isAffected = CreateGroup()
        endmethod
        
        static method create takes unit c, unit t returns Data
            local Data D = Data.allocate()
            set D.caster = c
            set D.target = t
            call GroupAddUnit(Data.isAffected, t)
            if integer(D) > Data.index then
                set Data.index = integer(D)
            endif
            return D
        endmethod
        
        method onDestroy takes nothing returns nothing
            call GroupRemoveUnit(Data.isAffected, .target)
            set .hasbuff = false
            if integer(this) == Data.index then
                set Data.index = Data.index - 1
            endif
        endmethod
        
        static method SetCaster takes unit caster, unit target returns nothing
            local integer i = 0
            local Data D
            loop
                exitwhen i > Data.index
                set D = Data(i)
                if D.target == target and D.hasbuff then
                    set D.caster = caster
                    return
                endif
                set i = i + 1
            endloop
        endmethod
    endstruct
    
    private struct LData
        lightning sfx
    endstruct
    
    private function LDestroy takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local LData LD = LData(GetTimerData(t))
        call DestroyLightning(LD.sfx)
        call ReleaseTimer(t)
        call LD.destroy()
        set t = null
    endfunction
    
    private function TimedLightning takes string codeName, boolean checkVis, location loc1, real z1, location loc2, real z2, real timeout returns nothing
        local real x1 = GetLocationX(loc1)
        local real y1 = GetLocationY(loc1)
        local real x2 = GetLocationX(loc2)
        local real y2 = GetLocationY(loc2)
        local timer t = NewTimer()
        local LData LD = LData.create()
        set LD.sfx = AddLightningEx(codeName, checkVis, x1, y1, z1, x2, y2, z2)
        call SetTimerData(t, integer(LD))
        call TimerStart(t, timeout, true, function LDestroy)
        set t = null
    endfunction
    
    private function targets takes nothing returns boolean
        local unit target = GetFilterUnit()
        return (GetWidgetLife(target) > 0.405) and (IsUnitType(target, UNIT_TYPE_STRUCTURE) == false) and (IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) == false) and (IsUnitType(target, UNIT_TYPE_MECHANICAL) == false)
    endfunction
    
    private function Loop takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local xecast xc = xecast.createA()
        local real GUx
        local real GUy
        local integer GC = 0
        local unit GU
        local Data D = Data(GetTimerData(t))
        local real Damage = damage + (damageInc * (GetHeroLevel(D.caster)))
        local real Radius = radius + (radiusInc * (GetHeroLevel(D.caster)))
        if not D.hasbuff and GetUnitAbilityLevel(D.target, BUFF_ID) > 0 then
            set D.hasbuff = true
        endif
        if D.hasbuff and GetUnitAbilityLevel(D.target, BUFF_ID) > 0 then
            call GroupEnumUnitsInRange(unitGrp, GetUnitX(D.target), GetUnitY(D.target), Radius, b)
            loop
                set GU = FirstOfGroup(unitGrp)
                exitwhen (GU == null)
                call GroupRemoveUnit(unitGrp, GU)
                if IsUnitEnemy(GU, GetOwningPlayer(D.caster)) then
                    set GC = GC + 1
                    call GroupAddUnit(EG, GU)
                endif
            endloop
            if GC > 1 then
                call damageOptions.damageAOE(D.caster, GetUnitX(D.target), GetUnitY(D.target), Radius, Damage)
                loop
                    set GU = FirstOfGroup(EG)
                    exitwhen (GU == null)
                    call GroupRemoveUnit(EG, GU)
                    call xc.destroy()
                    call TimedLightning(lightSfx, L_checkVis, GetUnitLoc(D.target), 50.0, GetUnitLoc(GU), 50.0, lt)
                endloop
                if GetUnitAbilityLevel(D.target, B_BUFF_ID) > 0 then
                    call UnitRemoveAbility(D.target, B_BUFF_ID)
                endif
            else
                set xc.abilityid = BANISH_ID
                set xc.level = GetHeroLevel(D.caster)
                set xc.orderstring = "banish"
                set xc.owningplayer = GetOwningPlayer(D.caster)
                call xc.castOnTarget(D.target)
            endif
        endif
        if D.hasbuff and GetUnitAbilityLevel(D.target, BUFF_ID) < 1 then
            call D.destroy()
            call ReleaseTimer(t)
        endif
        set GU = null
        set t = null
    endfunction
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local unit u = damageSource
        local unit tar = damagedUnit
        local Data D
        local timer t
        local unit dummy
        if ( UnitHasItemOfTypeBJ(u, ITEM_ID) and IsPlayerEnemy(GetOwningPlayer(damageSource), GetOwningPlayer(damagedUnit)) and GetRandomInt(0, 100) <= CHANCE and DamageType == 0) then
            if not IsUnitInGroup(tar, Data.isAffected) then
                set dummy = CreateUnit( GetOwningPlayer(damageSource), DUMMY_ID, GetUnitX( tar ), GetUnitY( tar ), 0 )
                call UnitAddAbility( dummy, DUMMY_SPELL_ID )
                call SetUnitAbilityLevel( dummy, DUMMY_SPELL_ID, 1 )
                call UnitApplyTimedLife( dummy, 'BTLF', 1 )
               
                call IssueTargetOrder( dummy, "cripple", tar )
                set D = Data.create(u, tar)
                set t = NewTimer()
                call SetTimerData(t, integer(D))
                call TimerStart(t, dt, true, function Loop)
            else
                call Data.SetCaster(u, tar)
            endif
            set t = null
            call DestroyEffect(AddSpecialEffectTarget(chargeEffect, tar, "origin"))
        endif
        set tar = null
        set u = null
        set dummy = null
    endfunction
        
    private function init takes nothing returns nothing
        local trigger trg = CreateTrigger()
        call XE_PreloadAbility(BANISH_ID)
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(chargeEffect)
        call Preload(dmgEffect)
        call Preload(lightSfx)
        call RegisterDamageResponse( Actions )
        set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)
        set unitGrp = CreateGroup()
        set EG = CreateGroup()
        set b = Condition(function targets)
    endfunction
    
endscope