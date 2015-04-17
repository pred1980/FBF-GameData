scope HacknSlash initializer init
    /*
     * Description: The Fire Panda starts multiple attacks to random enemies, dealing damage to each. 
                    After returning to the start point, his attackspeed is increased.
     * Changelog: 
     *      09.01.2014: Abgleich mit OE und der Exceltabelle
	 *      28.02.2014: Damage Werte von 60/90/120/150/180 auf 50/80/110/140/170 reduziert
	                   TARGET_DAMAGE_REDUCER von 10% auf 15% erhöht
	 *      19.03.2015: Added Conditions to the "filter method" in the main struct
	 *		06.04.2015: Integrated SpellHelper for filtering and damaging	 
     */
    globals
        private constant integer SPELL_ID = 'A08S'
        private constant integer ATTACKSPEED_BONUS_BUFF_PLACER_ID = 'A08T'
        private constant integer ATTACKSPEED_BONUS_BUFF_ID = 'B01S'
        private constant real TIMER_INTERVAL = 0.05
        private constant real SLASH_INTERVAL = 0.25
        private constant real TARGET_DETECTION_RANGE = 350.00
        private constant real TARGET_DAMAGE_DISTANCE = 50.00
        //Reduziert den Damage des nächsten Targets um weitere X-Prozent
        private constant real TARGET_DAMAGE_REDUCER = 15.00
        private constant string ATTACK_ANIMATION_ORDER = "attack"
        private constant integer CASTER_ALPHA = 125
        private constant string BLINK_EFFECT = "Models\\HacknSlashCasterBlink.mdl"
        private constant string BLINK_EFFECT_ATTACH = "origin"
        private constant string SLASH_DAMAGE_EFFECT = "Objects\\Spawnmodels\\Human\\HumanBlood\\BloodElfSpellThiefBlood.mdl"
        private constant string SLASH_DAMAGE_EFFECT_ATTACH = "origin"
        
		// Dealt damage configuration
		private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
		private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_FIRE
		private constant weapontype WEAPON_TYPE = WEAPON_TYPE_METAL_LIGHT_SLICE
        
        private integer array MAX_TARGETS
        private real array STRIKE_DAMAGE
        private real array ATTACKSPEED_BONUS_DURATION
    endglobals

    private function MainSetup takes nothing returns nothing
        set MAX_TARGETS[0] = 3
        set MAX_TARGETS[1] = 4
        set MAX_TARGETS[2] = 5
        set MAX_TARGETS[3] = 6
        set MAX_TARGETS[4] = 7
        
        set STRIKE_DAMAGE[0] = 50
        set STRIKE_DAMAGE[1] = 80
        set STRIKE_DAMAGE[2] = 110
        set STRIKE_DAMAGE[3] = 140
        set STRIKE_DAMAGE[4] = 170
        
        set ATTACKSPEED_BONUS_DURATION[0] = 5.00
        set ATTACKSPEED_BONUS_DURATION[1] = 6.00
        set ATTACKSPEED_BONUS_DURATION[2] = 7.00
        set ATTACKSPEED_BONUS_DURATION[3] = 8.00
        set ATTACKSPEED_BONUS_DURATION[4] = 9.00
    endfunction
    
    private struct AttackspeedBonus
    
        static thistype temp = 0
        static integer buffType = 0
    
        dbuff buff = 0
    
        static method onBuffEnd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            if b.isExpired then
                call thistype(b.data).destroy()
            endif
        endmethod

        static method onBuffAdd takes nothing returns nothing
            local dbuff b = GetEventBuff()
            local thistype this = 0
            
            if b.isRefreshed then
                //Destroying old data
                call thistype(b.data).destroy()
            endif
            
            set this = allocate()
            set b.data = integer(this)
            set buff = b
        endmethod
        
        static method generate takes unit caster, integer level returns nothing
            call UnitAddBuff(caster, caster, buffType, ATTACKSPEED_BONUS_DURATION[level], level + 1)
        endmethod
        
        static method onInit takes nothing returns nothing
            set buffType = DefineBuffType(ATTACKSPEED_BONUS_BUFF_PLACER_ID, ATTACKSPEED_BONUS_BUFF_ID, 0.00, false, true, thistype.onBuffAdd, 0, thistype.onBuffEnd)
        endmethod
    endstruct
    
    private struct Main
        static integer spellId = SPELL_ID
        static boolean autoDestroy = false
        static integer spellType = SPELL_TYPE_TARGET_UNIT
        
        static delegate xedamage dmg
        static thistype temp = 0
        static timer ticker = null
        static boolexpr groupFilter = null
        
        boolean returnToStart = false
        boolean onlyOneTarget = false 
        integer targetCount = 0
        real counter = 0.00
        real dmgRed = 0.00
        boolean enhanced = false
        
        real startX = 0.00 
        real startY = 0.00
        real startAngle = 0.00
        
        implement List
        
        method onDestroy takes nothing returns nothing
            call DisableUnit(caster, false)
            call SetUnitPathing(caster, true)
            call SetUnitVertexColor(caster, 255, 255, 255, 255)
            call SetUnitX(caster, startX)
            call SetUnitY(caster, startY)
            call SetUnitFacing(caster, startAngle)
            if not IsUnitType(caster, UNIT_TYPE_DEAD) then
                call AttackspeedBonus.generate(caster, lvl)
            endif
            call listRemove()
            if count == 0 then
                call PauseTimer(ticker)
            endif
        endmethod
        
        private static method filter takes nothing returns boolean
			return SpellHelper.isValidEnemy(GetFilterUnit(), temp.caster) 
        endmethod
        
        method getTarget takes nothing returns nothing
            set temp = this
            call GroupEnumUnitsInArea(ENUM_GROUP, GetUnitX(target), GetUnitY(target), TARGET_DETECTION_RANGE, groupFilter)
            if CountUnitsInGroup(ENUM_GROUP) == 1 then
                set onlyOneTarget = true
            endif
            set target = GroupPickRandomUnit(ENUM_GROUP)
        endmethod

        method slash takes nothing returns nothing
            local real a = GetRandomReal(0.00, 2 * bj_PI) 
            local real rx = GetUnitX(target) + TARGET_DAMAGE_DISTANCE * Cos(a)
            local real ry = GetUnitY(target) + TARGET_DAMAGE_DISTANCE * Sin(a)
            
            if targetCount >= MAX_TARGETS[lvl] or onlyOneTarget then
                set returnToStart = true
            endif
            
            if not returnToStart then
                call SetUnitX(caster, rx)
                call SetUnitY(caster, ry)
                call SetUnitFacing(caster, Atan2(GetUnitY(target) - GetUnitY(caster), GetUnitX(target)  - GetUnitX(caster)) * bj_RADTODEG)
                call SetUnitAnimation(caster, ATTACK_ANIMATION_ORDER)
                call DestroyEffect(AddSpecialEffectTarget(BLINK_EFFECT, caster, BLINK_EFFECT_ATTACH))
                
				set DamageType = PHYSICAL
				call SpellHelper.damageTarget(caster, target, STRIKE_DAMAGE[lvl] - (STRIKE_DAMAGE[lvl] * dmgRed / 100), true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                
				set dmgRed = dmgRed + TARGET_DAMAGE_REDUCER
                if enhanced then
                    call ArtOfFire_IgniteUnit(caster, target)
                endif
            endif
            
            set targetCount = targetCount + 1
        endmethod
            
        
        static method onLoop takes nothing returns nothing
            local thistype this = first
            local boolean flag = true
            
            loop
                exitwhen this == 0
                if IsUnitType(caster, UNIT_TYPE_DEAD) then
                    call destroy()
                    set flag = false
                else
                    set counter = counter + TIMER_INTERVAL
                endif
                    
                if flag and counter >= SLASH_INTERVAL then
                    if not returnToStart then
                        call getTarget()
                        if target == null then
                            call destroy()
                            set flag = false
                        else
                            call slash()
                        endif
                    else
                        call destroy()
                        set flag = false
                    endif
                    set counter = 0.00
                endif
            
                set flag = true
                set this = next
            endloop
        endmethod
            
        
        method onCast takes nothing returns nothing
            set startX = GetUnitX(caster)
            set startY = GetUnitY(caster)
            set startAngle = GetUnitFacing(caster)
            set lvl = lvl - 1
            call SetUnitPathing(caster, false)
            call SetUnitVertexColor(caster, 255, 255, 255, CASTER_ALPHA)
            call DisableUnit(caster, true)
            if ArtOfFire_GetLevel(caster) > 0 then
                set enhanced = true
            endif
            call listAdd()
            call slash()
            if count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.onLoop)
            endif
        endmethod
                
        implement Spell
        
        
        static method onInit takes nothing returns nothing
            set ticker = CreateTimer()
            set dmg = xedamage.create()
            set atype = ATTACK_TYPE
            set dtype = DAMAGE_TYPE
			set wtype = WEAPON_TYPE
			
            if SLASH_DAMAGE_EFFECT != "" then
                call useSpecialEffect(SLASH_DAMAGE_EFFECT, SLASH_DAMAGE_EFFECT_ATTACH)
            endif
			
            set groupFilter = Condition(function thistype.filter)
        endmethod
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call XE_PreloadAbility(ATTACKSPEED_BONUS_BUFF_PLACER_ID)
        call Preload(BLINK_EFFECT)
        call Preload(SLASH_DAMAGE_EFFECT)
    endfunction
    
endscope