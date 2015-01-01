scope FrostAura initializer init
    /*
     * Description: He freezes the air around him, creating solid particles of ice that slows enemies 
                    within a 500 range around him and hinders their healing processes.
     * Last Update: 28.10.2013
     * Changelog: 
     *     28.10.2013: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A04Q'
        private constant integer SLOW_SPELL_ID = 'A04P'
        private constant integer CASTER_EFFECT_SPELL_ID = 'A04O'
        private constant real TIMER_INTERVAL = 0.20
        private real array LIFE_DEGENERATION
        private real array SPELL_RADIUS
        //Erklärung: Wenn eine Einheit innerhalb dieses Radius ist, wird direkt der volle Schaden ausgeteilt.
        private real array SPELL_FULL_DEGENERATION_THRESHOLD
    endglobals
    
    private function MainSetup takes nothing returns nothing
    
        set LIFE_DEGENERATION[0] = 5.00
        set LIFE_DEGENERATION[1] = 10.00
        set LIFE_DEGENERATION[2] = 15.00
        set LIFE_DEGENERATION[3] = 20.00
        set LIFE_DEGENERATION[4] = 25.00
    
        set SPELL_RADIUS[0] = 500.00
        set SPELL_RADIUS[1] = 500.00
        set SPELL_RADIUS[2] = 500.00
        set SPELL_RADIUS[3] = 500.00
        set SPELL_RADIUS[4] = 500.00

        set SPELL_FULL_DEGENERATION_THRESHOLD[0] = 100.00
        set SPELL_FULL_DEGENERATION_THRESHOLD[1] = 125.00
        set SPELL_FULL_DEGENERATION_THRESHOLD[2] = 150.00
        set SPELL_FULL_DEGENERATION_THRESHOLD[3] = 175.00
        set SPELL_FULL_DEGENERATION_THRESHOLD[4] = 200.00
    endfunction


    private struct Main
    
        static constant integer spellId = SPELL_ID
        static constant integer subSkillId = SLOW_SPELL_ID
        static constant integer spellType = SPELL_TYPE_SELF_CAST
        static constant boolean autoDestroy = false
        static constant boolean hasSubSkill = true
        static constant boolean adjustSubSkill = true
    
        static timer ticker = null
        static thistype temp = 0
        static boolexpr filter = null
        static HandleTable t = 0
        
        implement List
        
        static method targetFilter takes nothing returns boolean
            local unit u = GetFilterUnit()
            local real dx = GetUnitX(u) - GetUnitX(temp.caster)
            local real dy = GetUnitY(u) - GetUnitY(temp.caster)
            local real dist = SquareRoot(dx * dx + dy * dy)
            
            if not IsUnitDead(u) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(u, UNIT_TYPE_MECHANICAL) and IsUnitEnemy(u, GetOwningPlayer(temp.caster)) then
                if dist <= SPELL_FULL_DEGENERATION_THRESHOLD[temp.lvl] then
                    if GetUnitState(u, UNIT_STATE_LIFE) - (LIFE_DEGENERATION[temp.lvl] * TIMER_INTERVAL) <= 1.00 then
                        call SetUnitState(u, UNIT_STATE_LIFE, 1.00)
                    else
                        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_LIFE) - LIFE_DEGENERATION[temp.lvl] * TIMER_INTERVAL)
                    endif
                else
                    if GetUnitState(u, UNIT_STATE_LIFE) - ((LIFE_DEGENERATION[temp.lvl] * TIMER_INTERVAL) * (dist / SPELL_RADIUS[temp.lvl])) <= 1.00 then
                        call SetUnitState(u, UNIT_STATE_LIFE, 1.00)
                    else
                        call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_LIFE) - ((LIFE_DEGENERATION[temp.lvl] * TIMER_INTERVAL) * (1 - (dist / SPELL_RADIUS[temp.lvl]))))
                    endif
                endif
            endif
            
            set u = null
            return false
        endmethod
        
        static method periodic takes nothing returns nothing
            local thistype this = first
            
            loop
                exitwhen this == 0
                if not IsUnitType(caster, UNIT_TYPE_DEAD) then
                    set temp = this
                    call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(caster), GetUnitY(caster), SPELL_RADIUS[lvl], filter)
                endif    
                    
                set this = next
            endloop
        endmethod
        
        static method [] takes unit u returns thistype
            local thistype this = thistype(t[u])
            if this != 0 then
                set lvl = GetUnitAbilityLevel(caster, SPELL_ID) - 1
            else
                set this = allocate()
                set caster = u
                set lvl = GetUnitAbilityLevel(caster, SPELL_ID) - 1
                call UnitAddAbility(caster, CASTER_EFFECT_SPELL_ID)
                call UnitMakeAbilityPermanent(caster, true, CASTER_EFFECT_SPELL_ID)
                call listAdd()
                set t[u] = integer(this)
                            
                if count == 1 then
                    call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.periodic)
                endif
            endif
            return this
        endmethod
        
        //looks weird, but it works :D :D
        static method onLearn takes unit u returns nothing
            local integer this = u:thistype
        endmethod
        
        static method onSkill takes unit u returns nothing
            local integer this = u:thistype
        endmethod
        
        implement Spell
        
        static method onInit takes nothing returns nothing
            set ticker = CreateTimer()
            set t = HandleTable.create()
            set filter = Condition(function thistype.targetFilter)
            call MainSetup()
        endmethod
        
    endstruct
    
    private function init takes nothing returns nothing
        call XE_PreloadAbility(SLOW_SPELL_ID)
        call XE_PreloadAbility(CASTER_EFFECT_SPELL_ID)
    endfunction

endscope