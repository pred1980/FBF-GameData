scope HolyCross initializer init
    /*
     * Description: The Paladin creates a Holy Cross at the target location. Enemies that enter the Cross will be 
                    silenced for 2 seconds and will receive damage over time if they stay too long. Allies will receive 
                    less damage and an increased life regeneration. The cross lasts 7.5 seconds.
     * Last Update: 02.01.2014
     * Changelog: 
     *     02.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A08R'
        private constant real TIMER_INTERVAL = 0.05
        private real array SPELL_DURATION
    endglobals
    
    //Cross Options
    globals
        private constant string CHAIN_TYPE = "HWSB"
        private constant real CHAIN_HEIGHT = 35.00
        //Dieser Wert ist rein visuell. Wenn true, dann kreuzen sich die langen Ketten, was sehr schön aussieht, aber das Gebiet des Kreuzes nicht
        //sehr gut erkennen lässt. Ändern tut es an der Mechanik des Spells jedoch rein garnichts!
        private constant boolean CROSSED_CHAINS = true
        //Effect für die ganze Zeit
        private constant string CORNER_EFFECT_MODEL = "Abilities\\Spells\\Items\\PotionOfOmniscience\\CrystalBallCaster.mdl"
        private constant real CORNER_EFFECT_SIZE = 0.80
        private constant real CORNER_EFFECT_HEIGHT = 25.00
        //Effect nur beim erzeugen des Kreuzes
        private constant string CORNER_START_EFFECT_MODEL = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"
        private constant real CORNER_START_EFFECT_SIZE = 0.65
        private constant real CORNER_START_EFFECT_HEIGHT = 0.00
        
        private real array CROSS_LENGTH
        private real array CROSS_WIDTH
        private real array SILENCE_DURATION
        private real array DAMAGE_REDUCTION
        private real array HEAL_PER_SECOND
    endglobals
    
    //Damage Configuration
    globals
        private real array DAMAGE_PER_SECOND
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant integer DAMAGE_REDUCTION_PRIORITY  = 60
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set CROSS_LENGTH[0] = 250.00
        set CROSS_LENGTH[1] = 325.00
        set CROSS_LENGTH[2] = 400.00
        
        set CROSS_WIDTH[0] = 75.00
        set CROSS_WIDTH[1] = 100.00
        set CROSS_WIDTH[2] = 125.00
        
        set SPELL_DURATION[0] = 7.50
        set SPELL_DURATION[1] = 7.50
        set SPELL_DURATION[2] = 7.50
        
        set SILENCE_DURATION[0] = 2.00
        set SILENCE_DURATION[1] = 2.00
        set SILENCE_DURATION[2] = 2.00
        
        set DAMAGE_PER_SECOND[0] = 40.00
        set DAMAGE_PER_SECOND[1] = 60.00
        set DAMAGE_PER_SECOND[2] = 80.00
        
        set HEAL_PER_SECOND[0] = 25.00
        set HEAL_PER_SECOND[1] = 50.00
        set HEAL_PER_SECOND[2] = 75.00

        set DAMAGE_REDUCTION[0] = 0.10
        set DAMAGE_REDUCTION[1] = 0.20
        set DAMAGE_REDUCTION[2] = 0.30
    endfunction
    
    private keyword Main
    private keyword DamageReducer
    
    private struct DamageReducer extends DamageModifier
    
        delegate Main md = 0
    
        implement List
        
        method onDestroy takes nothing returns nothing
            call listRemove()
        endmethod
        
        static method get takes unit u, Main m returns thistype
            local thistype this = first
            loop
                exitwhen this == 0
                if target == u and md == m then
                    return this
                endif
                set this = next
            endloop
            return 0
        endmethod
        
        static method deleteFromCross takes Main m returns nothing
            local thistype this = first
            loop
                exitwhen this == 0
                if md == m then
                    call destroy()
                endif
                set this = next
            endloop
        endmethod
        
        method onDamageTaken takes unit source, real damage returns real
            return -damage * DAMAGE_REDUCTION[lvl]
        endmethod        
        
        static method create takes unit u, Main m returns thistype
            local thistype this = get(u, m)
            if this != 0 then
                return this
            endif
            set this = allocate(u, DAMAGE_REDUCTION_PRIORITY)
            set md = m
            call listAdd()
            return this
        endmethod    
    
    endstruct

    private struct Main
        static constant integer spellId = SPELL_ID
        static constant integer spellType = SPELL_TYPE_TARGET_GROUND
        static constant boolean autoDestroy = false
        
        static timer ticker = null
        static real array cornerEffectAngle[8]
        static rect tempRect = null
        static boolexpr filter = null
        static code checkModifier = null
        static thistype temp = 0
        static group tempGroup = null
        static delegate xedamage dmg = 0
        
        real array cornerX[8]
        real array cornerY[8]
        lightning array chain[8]
        region cross = null
        xefx array cornerfx[8]
        group lastTargets = null
        
        real time = 0.00
        
        implement List
        
        method onDestroy takes nothing returns nothing
            local integer i = 0
            call listRemove()
            
            loop
                exitwhen i >= 8
                call DestroyLightning(chain[i])
                if CORNER_EFFECT_MODEL != "" then
                    call cornerfx[i].destroy()
                endif
                set i = i + 1
            endloop
            
            call DamageReducer.deleteFromCross(this)
            
            if count <= 0 then
                call listRemove()
            endif
        endmethod
        
        static method enumFilter takes nothing returns boolean
            local unit u = GetFilterUnit()
            local thistype this = temp
            
            if not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(u, UNIT_TYPE_FLYING) and IsUnitInRegion(cross, u) then
                
                if IsUnitEnemy(u, GetOwningPlayer(caster)) then
                    call GroupAddUnit(tempGroup, u)
                    if not IsUnitInGroup(u, lastTargets) then
                        call SilenceUnitTimed(u, SILENCE_DURATION[lvl])
                    else
                        set DamageType = SPELL
                        call damageTarget(caster, u, DAMAGE_PER_SECOND[lvl] * TIMER_INTERVAL)
                    endif
                else
                    call GroupAddUnit(tempGroup, u)
                    if not IsUnitInGroup(u, lastTargets) then
                        call DamageReducer.create(u, this)
                    else
                        call SetUnitLife(u, GetUnitLife(u) + HEAL_PER_SECOND[lvl])
                    endif
                endif
            endif
            
            set u = null
            return false
        endmethod
        
        static method checkModifierEnum takes nothing returns nothing
            local unit u = GetEnumUnit()
            //Die Einheit muss ja mal in lastTargets gewesen sein.. wenn sie nun nicht mehr in der tempGroup ist, dann zerstört man den DamageReducer...
            if DamageReducer.get(u, temp) != 0 and not IsUnitInGroup(u, tempGroup) then
                call DamageReducer.get(u, temp).destroy()
            endif
            set u = null
        endmethod
        
        static method periodic takes nothing returns nothing
            local thistype this = first
            loop
                exitwhen this == 0
                set time = time + TIMER_INTERVAL
        
                if time >= SPELL_DURATION[lvl] then
                    call destroy()
                endif
                
                set temp = this
                call GroupClear(tempGroup)
                call GroupEnumUnitsInRange(ENUM_GROUP, x, y, CROSS_WIDTH[lvl] + CROSS_LENGTH[lvl], filter)
                call ForGroup(lastTargets, checkModifier)
                call GroupClear(lastTargets)
                call GroupAddGroup(tempGroup, lastTargets)
                
                set this = next
            endloop             
        endmethod
        
        method onCast takes nothing returns nothing
            local integer i = 0
            local xefx startfx = 0
        
            set lvl = lvl - 1
            
            //Top
            set cornerX[0] = x - CROSS_WIDTH[lvl]
            set cornerY[0] = y + CROSS_LENGTH[lvl]
            
            set cornerX[1] = x + CROSS_WIDTH[lvl]
            set cornerY[1] = y + CROSS_LENGTH[lvl]
            
            //Right
            set cornerX[2] = x + CROSS_LENGTH[lvl]
            set cornerY[2] = y + CROSS_WIDTH[lvl]
            
            set cornerX[3] = x + CROSS_LENGTH[lvl]
            set cornerY[3] = y - CROSS_WIDTH[lvl]
            
            //Bot
            set cornerX[4] = x + CROSS_WIDTH[lvl]
            set cornerY[4] = y - CROSS_LENGTH[lvl]
            
            set cornerX[5] = x - CROSS_WIDTH[lvl]
            set cornerY[5] = y - CROSS_LENGTH[lvl]
            
            //Left
            set cornerX[6] = x - CROSS_LENGTH[lvl]
            set cornerY[6] = y - CROSS_WIDTH[lvl]
            
            set cornerX[7] = x - CROSS_LENGTH[lvl]
            set cornerY[7] = y + CROSS_WIDTH[lvl]
            
            loop
                exitwhen i >= 8
                    if CORNER_START_EFFECT_MODEL != "" then
                        set startfx = xefx.create(cornerX[i], cornerY[i], cornerEffectAngle[i])
                        set startfx.fxpath = CORNER_START_EFFECT_MODEL
                        set startfx.scale = CORNER_START_EFFECT_SIZE
                        set startfx.z = CORNER_START_EFFECT_HEIGHT
                        call startfx.destroy()
                    endif
                        
                    if CORNER_EFFECT_MODEL != "" then
                        set cornerfx[i] = xefx.create(cornerX[i], cornerY[i], cornerEffectAngle[i])
                        set cornerfx[i].fxpath = CORNER_EFFECT_MODEL
                        set cornerfx[i].scale = CORNER_EFFECT_SIZE
                        set cornerfx[i].z = CORNER_EFFECT_HEIGHT
                    endif
                    
                    set i = i + 1
            endloop
            
            
            set chain[0] = AddLightningEx(CHAIN_TYPE, true, cornerX[0], cornerY[0], CHAIN_HEIGHT + GetTerrainZ(cornerX[0], cornerY[0]), cornerX[1], cornerY[1], CHAIN_HEIGHT + GetTerrainZ(cornerX[1], cornerY[1]))
            set chain[1] = AddLightningEx(CHAIN_TYPE, true, cornerX[4], cornerY[4], CHAIN_HEIGHT + GetTerrainZ(cornerX[4], cornerY[4]), cornerX[7], cornerY[7], CHAIN_HEIGHT + GetTerrainZ(cornerX[5], cornerY[5]))
            set chain[2] = AddLightningEx(CHAIN_TYPE, true, cornerX[2], cornerY[2], CHAIN_HEIGHT + GetTerrainZ(cornerX[2], cornerY[2]), cornerX[3], cornerY[3], CHAIN_HEIGHT + GetTerrainZ(cornerX[3], cornerY[3]))
            set chain[3] = AddLightningEx(CHAIN_TYPE, true, cornerX[6], cornerY[6], CHAIN_HEIGHT + GetTerrainZ(cornerX[6], cornerY[6]), cornerX[7], cornerY[7], CHAIN_HEIGHT + GetTerrainZ(cornerX[7], cornerY[7]))
            static if CROSSED_CHAINS then
                set chain[4] = AddLightningEx(CHAIN_TYPE, true, cornerX[1], cornerY[1], CHAIN_HEIGHT + GetTerrainZ(cornerX[1], cornerY[1]), cornerX[5], cornerY[5], CHAIN_HEIGHT + GetTerrainZ(cornerX[5], cornerY[5]))
                set chain[5] = AddLightningEx(CHAIN_TYPE, true, cornerX[4], cornerY[4], CHAIN_HEIGHT + GetTerrainZ(cornerX[4], cornerY[4]), cornerX[0], cornerY[0], CHAIN_HEIGHT + GetTerrainZ(cornerX[0], cornerY[0]))
                set chain[6] = AddLightningEx(CHAIN_TYPE, true, cornerX[7], cornerY[7], CHAIN_HEIGHT + GetTerrainZ(cornerX[7], cornerY[7]), cornerX[3], cornerY[3], CHAIN_HEIGHT + GetTerrainZ(cornerX[3], cornerY[3]))
                set chain[7] = AddLightningEx(CHAIN_TYPE, true, cornerX[2], cornerY[2], CHAIN_HEIGHT + GetTerrainZ(cornerX[2], cornerY[2]), cornerX[6], cornerY[6], CHAIN_HEIGHT + GetTerrainZ(cornerX[6], cornerY[6]))
            else
                set chain[4] = AddLightningEx(CHAIN_TYPE, true, cornerX[1], cornerY[1], CHAIN_HEIGHT + GetTerrainZ(cornerX[1], cornerY[1]), cornerX[4], cornerY[4], CHAIN_HEIGHT + GetTerrainZ(cornerX[4], cornerY[4]))
                set chain[5] = AddLightningEx(CHAIN_TYPE, true, cornerX[5], cornerY[5], CHAIN_HEIGHT + GetTerrainZ(cornerX[5], cornerY[5]), cornerX[0], cornerY[0], CHAIN_HEIGHT + GetTerrainZ(cornerX[0], cornerY[0]))
                set chain[6] = AddLightningEx(CHAIN_TYPE, true, cornerX[7], cornerY[7], CHAIN_HEIGHT + GetTerrainZ(cornerX[7], cornerY[7]), cornerX[2], cornerY[2], CHAIN_HEIGHT + GetTerrainZ(cornerX[2], cornerY[2]))
                set chain[7] = AddLightningEx(CHAIN_TYPE, true, cornerX[3], cornerY[3], CHAIN_HEIGHT + GetTerrainZ(cornerX[3], cornerY[3]), cornerX[6], cornerY[6], CHAIN_HEIGHT + GetTerrainZ(cornerX[6], cornerY[6]))
            endif
            
            set cross = CreateRegion()
            
            call SetRect(tempRect, x - CROSS_WIDTH[lvl], y - CROSS_LENGTH[lvl], x + CROSS_WIDTH[lvl], y + CROSS_LENGTH[lvl])
            call RegionAddRect(cross, tempRect)
            
            call SetRect(tempRect, x - CROSS_LENGTH[lvl], y - CROSS_WIDTH[lvl], x + CROSS_LENGTH[lvl], y + CROSS_WIDTH[lvl])
            call RegionAddRect(cross, tempRect)
            
            set lastTargets = NewGroup()
            
            call listAdd()
            if count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.periodic)
            endif
        endmethod      
        
        implement Spell
        
        private static method onInit takes nothing returns nothing
            set ticker = CreateTimer()
            set tempRect = Rect(0.00, 0.00, 0.00, 0.00)
            set filter = Condition(function thistype.enumFilter)
            set checkModifier = function thistype.checkModifierEnum
            set tempGroup = CreateGroup()
            set dmg = xedamage.create()
            set atype = ATTACK_TYPE
            set dtype = DAMAGE_TYPE
            
            set cornerEffectAngle[0] = 4.71
            set cornerEffectAngle[1] = 4.71
            set cornerEffectAngle[2] = 3.14
            set cornerEffectAngle[3] = 3.14
            set cornerEffectAngle[4] = 1.57
            set cornerEffectAngle[5] = 1.57
            set cornerEffectAngle[6] = 6.28
            set cornerEffectAngle[7] = 6.28
        endmethod
        
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call Preload(CORNER_EFFECT_MODEL)
        call Preload(CORNER_START_EFFECT_MODEL)
    endfunction

endscope