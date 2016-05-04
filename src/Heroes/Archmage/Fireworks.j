scope Fireworks initializer init
    /*
     * Description: The Last Archmage casts his ultimate spell, a massive explosion of colourful sparks that damage 
                    and blind his enemies.
     * Changelog: 
     *     	04.12.2013: Abgleich mit OE und der Exceltabelle
	 *     	25.03.2015: Changed ATTACK_TYPE from Spells to Magic | Code refactoring
	 *     	26.03.2015: Integrated RegisterPlayerUnitEvent
	 *		03.05.2016: Changed ORDER_ID for AI System
     */
    globals
        private constant integer SPELL_ID = 'A07K'
        private constant integer DUMMY_SPELL = 'A07L'
        private constant string ORDER_ID = "roar"
        private constant string DUMMY_ORDER = "drunkenhaze"
        private constant string FX = "Abilities\\Spells\\Human\\Flare\\FlareTarget.mdl"
        private constant real AOE = 175.
        private constant real RAIN_AOE = 700.
        private constant real INTERVAL = 0.3
        private constant real SCALE = 1.0
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_UNIVERSAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
		
		private xedamage xed
        private xecast cast
    endglobals

    private constant function GetDamage takes integer lvl returns real
        return 50. + 50. * lvl //deals 100/150/200 damage
    endfunction
    
    //damage filter
    private function DamageOptions takes xedamage spellDamage returns nothing
        set spellDamage.dtype = DAMAGE_TYPE
        set spellDamage.atype = ATTACK_TYPE
		set spellDamage.wtype = WEAPON_TYPE
        set spellDamage.exception = UNIT_TYPE_STRUCTURE
        set spellDamage.visibleOnly = true
        set spellDamage.damageAllies = false       
    endfunction

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
		static thistype tempthis
        
        private method onDestroy takes nothing returns nothing
			set .caster = null
            call ReleaseTimer(.t)
            call GroupRefresh(ENUM_GROUP)
            /*if (.fx != null) then
                call .fx.destroy()
            endif*/
        endmethod
		
		static method enumFilter takes nothing returns boolean
			local thistype this = thistype.tempthis

			return SpellHelper.isValidEnemy(GetFilterUnit(), this.caster)
        endmethod
        
        method createSparks takes real x, real y returns nothing
            if (.fx != null) then
                call .fx.destroy()
                
                call GroupEnumUnitsInRange(ENUM_GROUP,x,y,AOE, Filter(function thistype.enumFilter))
                set cast.owningplayer = GetOwningPlayer(.caster)
                set cast.level=.lvl
                //the unit group will get cleaned after calling this function
                call cast.castOnGroup(ENUM_GROUP)
                call GroupEnumUnitsInRange(ENUM_GROUP,x,y,AOE, Filter(function thistype.enumFilter))
                
				set DamageType = SPELL
				//the unit group will get cleaned after calling this function
                call xed.damageGroup(.caster,ENUM_GROUP,GetDamage(.lvl))
            endif
            set .fx = xefx.create(x,y,0)
            set .fx.fxpath = FX
            set .fx.scale = SCALE
        endmethod
		
		static method create takes unit c, timer t returns thistype
            local thistype this = thistype.allocate()
            set this.caster = c
            set this.t = t
            set this.lvl = GetUnitAbilityLevel(c, SPELL_ID)
			set thistype.tempthis = this

            return this
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
        
		//check the caster still casting or not
        if GetUnitCurrentOrder(f.caster) == OrderId(ORDER_ID) then 
            call f.createSparks(x,y)
        else
            call f.destroy()
        endif
    
        set t=null
    endfunction
    
    private function Actions takes nothing returns nothing
        local timer t = NewTimer()
        local Fireworks f
		
		set f = Fireworks.create(GetSpellAbilityUnit(), t)
		call SetTimerData(t, integer(f))
		call TimerStart(t, INTERVAL, true, function Shower)
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
	endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		
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