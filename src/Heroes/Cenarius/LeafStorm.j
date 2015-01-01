scope LeafStorm initializer init
    /*
     * Description: Cenarius starts to channel and creates a Leaf Storm moving from her in the target direction. 
                    The storm deals damage to every enemy that is trapped inside of it and slowly drags them in 
                    the target direction.
     * Last Update: 08.01.2014
     * Changelog: 
     *     08.01.2014: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A08J'
        private constant real TIMER_INTERVAL = 0.05
    endglobals
    
    //Storm Options
    globals
        private constant damagetype STORM_DAMAGE_TYPE = DAMAGE_TYPE_COLD
        private constant attacktype STORM_ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant string STORM_EFFECT_MODEL = "Models\\LeafStorm.mdl"
        private constant real STORM_EFFECT_MODEL_HEIGHT = 60.00
        private real array STORM_RADIUS
        private real array STORM_EFFECT_MODEL_SIZE
        private real array STORM_DAMAGE_PER_SECOND
        private real array STORM_PUSH_PER_SECOND
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set STORM_RADIUS[0] = 500.00
        set STORM_RADIUS[1] = 600.00
        set STORM_RADIUS[2] = 700.00
        
        set STORM_EFFECT_MODEL_SIZE[0] = 1.33
        set STORM_EFFECT_MODEL_SIZE[1] = 1.67
        set STORM_EFFECT_MODEL_SIZE[2] = 2.00
        
        set STORM_DAMAGE_PER_SECOND[0] = 100.00
        set STORM_DAMAGE_PER_SECOND[1] = 150.00
        set STORM_DAMAGE_PER_SECOND[2] = 200.00
        
        set STORM_PUSH_PER_SECOND[0] = 66.67
        set STORM_PUSH_PER_SECOND[1] = 133.33
        set STORM_PUSH_PER_SECOND[2] = 200.00
    endfunction
    
    private struct Main
        unit caster = null
        integer lvl = 0
        real tx = 0.00
        real ty = 0.00
        real angle = 0.00
        real cos = 0.00
        real sin = 0.00
        xefx storm = 0
        
        static timer ticker = null
        static delegate xedamage damage = 0
        static boolexpr filter = null
        static thistype temp = 0
        static HandleTable t = 0
        
        implement List
        
        static method targetFilter takes nothing returns boolean
            local unit u = GetFilterUnit()
            
            if not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not IsUnitType(u, UNIT_TYPE_MECHANICAL) and IsUnitEnemy(u, GetOwningPlayer(temp.caster)) then
                set DamageType = 1
                call damageTarget(temp.caster, u, STORM_DAMAGE_PER_SECOND[temp.lvl] * TIMER_INTERVAL)
                call SetUnitX(u, GetUnitX(u) + (STORM_PUSH_PER_SECOND[temp.lvl] * TIMER_INTERVAL) * temp.cos)
                call SetUnitY(u, GetUnitY(u) + (STORM_PUSH_PER_SECOND[temp.lvl] * TIMER_INTERVAL) * temp.sin)
            endif
            
            set u = null
            return false
        endmethod
        
        static method periodic takes nothing returns nothing
            local thistype this = first
            loop
                exitwhen this == 0
                
                set temp = this
                call GroupEnumUnitsInRange(ENUM_GROUP, tx, ty, STORM_RADIUS[lvl], filter)
                
                set this = next
            endloop
            
            if count <= 0 then
                call PauseTimer(ticker)
            endif
        endmethod
                
                
        method onDestroy takes nothing returns nothing
        
            call listRemove()
            call t.flush(caster)
            
            if STORM_EFFECT_MODEL != "" then
                call storm.destroy()
            endif
            
            if count <= 0 then
                call PauseTimer(ticker)
            endif
        
        endmethod
                
        static method create takes nothing returns thistype
            local thistype this = thistype(t[SpellEvent.CastingUnit])
            if this != 0 then
                call destroy()
            endif
            set this = allocate()
            set caster = SpellEvent.CastingUnit
            set lvl = GetUnitAbilityLevel(caster, SPELL_ID) - 1
            set tx = SpellEvent.TargetX
            set ty = SpellEvent.TargetY
            set angle = Atan2(ty - GetUnitY(caster), tx - GetUnitX(caster))
            set cos = Cos(angle)        
            set sin = Sin(angle)
            set t[caster] = integer(this)
            call listAdd()
            if STORM_EFFECT_MODEL != "" then
                set storm = xefx.create(tx, ty, angle)
                set storm.fxpath = STORM_EFFECT_MODEL
                set storm.z = STORM_EFFECT_MODEL_HEIGHT
                set storm.scale = STORM_EFFECT_MODEL_SIZE[lvl]
            endif
            
            if count == 1 then
                call TimerStart(ticker, TIMER_INTERVAL, true, function thistype.periodic)
            endif
            return this
        endmethod
    
    
        private static method channelStart takes nothing returns nothing
            call create()
        endmethod
        
        private static method channelEnd takes nothing returns nothing
            if t[SpellEvent.CastingUnit] != 0 then
                call thistype(t[SpellEvent.CastingUnit]).destroy()
            endif
        endmethod
        
        private static method onInit takes nothing returns nothing
        
            call RegisterSpellEffectResponse(SPELL_ID, channelStart)
            call RegisterSpellEndCastResponse(SPELL_ID, channelEnd)
            
            set ticker = CreateTimer()
            set filter = Condition(function thistype.targetFilter)
            set t = HandleTable.create()
            
            set damage = xedamage.create()
            set dtype = STORM_DAMAGE_TYPE
            set atype = STORM_ATTACK_TYPE
            
        endmethod
    endstruct
    
    private function init takes nothing returns nothing
        call MainSetup()
        call Preload(STORM_EFFECT_MODEL)
    endfunction
    
endscope