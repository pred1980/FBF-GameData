scope Fireworks initializer init
    /*
     * Description: The Last Archmage casts his ultimate spell, a massive explosion of colourful sparks that damage 
                    and blind his enemies.
     * Last Update: 04.12.2013
     * Changelog: 
     *     04.12.2013: Abgleich mit OE und der Exceltabelle
     */
    globals
        private constant integer SPELL_ID = 'A07K' //fireworks ability rawcode
        private constant integer DUMMY_SPELL = 'A07L' //fireworks dummy ability rawcode
        private constant string ORDER_ID = "dispel" //fireworks order string
        private constant string DUMMY_ORDER = "drunkenhaze"
        private constant string FX = "Abilities\\Spells\\Human\\Flare\\FlareTarget.mdl" //spell effect
        private constant real AOE = 175. //aoe for missiles
        private constant real RAIN_AOE = 700. //rain radius
        private constant real INTERVAL = 0.3 //how often new missiles are created
        private constant real SCALE = 1.0 //missile scale
    endglobals

    private function IsUnitAlive takes nothing returns boolean
        return not IsUnitDead(GetFilterUnit())
    endfunction
    
    private constant function GetDamage takes integer lvl returns real
        return 50. + 50. * lvl //deals 100/150/200 damage
    endfunction
    
    //damage filter
    private function DamageOptions takes xedamage spellDamage returns nothing
        set spellDamage.dtype = DAMAGE_TYPE_UNIVERSAL
        set spellDamage.atype = ATTACK_TYPE_NORMAL
        set spellDamage.exception = UNIT_TYPE_STRUCTURE
        set spellDamage.visibleOnly = true
        set spellDamage.damageAllies = false       
    endfunction

    globals
        private xedamage xed
        private xecast cast
        private boolexpr b
    endglobals
    
    //set xecast
    private function SetDummy takes xecast DummySpell returns nothing 
        set DummySpell.abilityid = DUMMY_SPELL
        set DummySpell.orderstring = DUMMY_ORDER  
    endfunction
    
    private struct Fireworks
        unit caster
        timer t
        xefx fx
        integer lvl = 0
        
        static method create takes unit c, timer t returns thistype
            local thistype d = thistype.allocate()
            set d.caster = c
            set d.t = t
            set d.lvl = GetUnitAbilityLevel(c, SPELL_ID)
        
            return d
        endmethod
        
        method createSparks takes real x, real y returns nothing
            if (.fx != null) then
                call .fx.destroy()
                
                call GroupEnumUnitsInRange(ENUM_GROUP,x,y,AOE,b)
                set cast.owningplayer = GetOwningPlayer(.caster)
                set cast.level=.lvl
                //the unit group will get cleaned after calling this function
                call cast.castOnGroup(ENUM_GROUP)
                call GroupEnumUnitsInRange(ENUM_GROUP,x,y,AOE,b)
                //the unit group will get cleaned after calling this function
                call xed.damageGroup(.caster,ENUM_GROUP,GetDamage(.lvl))
            endif
            set .fx = xefx.create(x,y,0)
            set .fx.fxpath = FX
            set .fx.scale = SCALE
        endmethod
        
        private method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
            call GroupRefresh(ENUM_GROUP)
            /*if (.fx != null) then
                call .fx.destroy()
            endif*/
        endmethod
    endstruct

    private function Shower takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local Fireworks f = Fireworks(GetTimerData(t))
        local real an = GetRandomReal ( 1 , 360 )
        local real dis = GetRandomReal ( 1 , RAIN_AOE )
        local real rad = an * bj_PI/180
        local real x = GetUnitX (f.caster) + dis * Cos ( rad )
        local real y = GetUnitY (f.caster) + dis * Sin ( rad )
        
        if GetUnitCurrentOrder(f.caster) == OrderId(ORDER_ID) then //check the caster still casting or not
            call f.createSparks(x,y)
        else
            call f.destroy()
        endif
    
        set t=null
    endfunction
    
    private function SpellEffect takes nothing returns nothing
        local timer t
        local Fireworks f
    
        if GetSpellAbilityId() == SPELL_ID then
            set t = NewTimer()
            set f = Fireworks.create(GetSpellAbilityUnit(),t)
            call SetTimerData(t, integer(f))
            call TimerStart(t, INTERVAL,true, function Shower)
        endif
    
        set t = null
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(t,function SpellEffect)
        
        set b = Condition(function IsUnitAlive)
        
        //init xedamage
        set xed = xedamage.create()
        call DamageOptions(xed)
        
        //init xecast
        set cast = xecast.create()  
        call SetDummy(cast)
        
        //preload dummy ability
        call XE_PreloadAbility(DUMMY_SPELL)
        call Preload(FX)
    endfunction
endscope