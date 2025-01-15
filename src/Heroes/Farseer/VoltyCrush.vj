scope VoltyCrush initializer init
    /*
     * Description: The Farseer casts a magical curse at the target unit which causes a powerful explosion 
                    after 2s/2.5s/3s/3.5s/4s and damaging nearby enemy units.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
	 *     19.03.2015: Optimized Spell-Event-Handling (Conditions/Actions)
	 *     06.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for filtering and damaging
     */
    globals
        private constant integer SPELL_ID = 'A09E'
        private constant integer BUFF_SPELL_ID = 'A09F'
        private constant integer BUFF_ID = 'B01Y'
        private constant string TICK_FX = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdl"
        private constant string EXPLODE_FX = "Models\\LightningNova.mdx"
        private constant string TARGET_FX = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
        private constant string MAIN_TARGET_FX = "Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl"
        private constant string TICK_AP = "chest"
        private constant string EXPLODE_AP = "origin"
        private constant string TARGET_AP = "chest"
        private constant string MAIN_TARGET_AP = "origin"
        private constant real TICK = 0.50
        private constant boolean ExUponDeath = false
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_LIGHTNING
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
        private Table VoltyTab
        private real array EXPLODE_DELAY
        private real array EXPLODE_RADIUS
        private real array TICK_DAMAGE
        private real array EXPLODE_TARGET_DAMAGE
        private real array EXPLODE_AOE_DAMAGE
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set VoltyTab = Table.create()
    
        set EXPLODE_DELAY[1] = 2.00
        set EXPLODE_DELAY[2] = 2.50
        set EXPLODE_DELAY[3] = 3.00
        set EXPLODE_DELAY[4] = 3.50
        set EXPLODE_DELAY[5] = 4.00
        
        set EXPLODE_RADIUS[1] = 250.00
        set EXPLODE_RADIUS[2] = 250.00
        set EXPLODE_RADIUS[3] = 250.00
        set EXPLODE_RADIUS[4] = 250.00
        set EXPLODE_RADIUS[5] = 250.00
        
        set TICK_DAMAGE[1] = 5.00
        set TICK_DAMAGE[2] = 10.00
        set TICK_DAMAGE[3] = 15.00
        set TICK_DAMAGE[4] = 20.00
        set TICK_DAMAGE[5] = 25.00
        
        set EXPLODE_TARGET_DAMAGE[1] = 75.00
        set EXPLODE_TARGET_DAMAGE[2] = 125.00
        set EXPLODE_TARGET_DAMAGE[3] = 175.00
        set EXPLODE_TARGET_DAMAGE[4] = 225.00
        set EXPLODE_TARGET_DAMAGE[5] = 275.00
        
        set EXPLODE_AOE_DAMAGE[1] = 40.00
        set EXPLODE_AOE_DAMAGE[2] = 80.00
        set EXPLODE_AOE_DAMAGE[3] = 120.00
        set EXPLODE_AOE_DAMAGE[4] = 160.00
        set EXPLODE_AOE_DAMAGE[5] = 200.00
    endfunction
    
    private struct VoltyStruct
        static thistype data
        static thistype datab
        static group dgroup
        unit target
        unit caster
        player owner
        integer level
        real time
        effect sfx
		
		method onDestroy takes nothing returns nothing
            call UnitRemoveAbility(.target, BUFF_SPELL_ID)
            call UnitRemoveAbility(.target, BUFF_ID)
            call DestroyEffect(.sfx)
            set .sfx = null
            call ReleaseGroup( .dgroup )
            set .dgroup = null
            set .caster = null
            set .target = null
        endmethod
        
        //This method runs when a curse finishes and checks if the unit has other instances of the spell, if none it removes the buff
        method RemoveBuff takes nothing returns nothing
            if VoltyTab[GetHandleId(this.target)] == 0 then
                call this.destroy()
            endif
        endmethod
        
        //This method is for dealing the damage into the unit
        method OnHit takes unit fu returns nothing
            set DamageType = SPELL
            if fu != this.target then
                call DestroyEffect(AddSpecialEffectTarget(TARGET_FX, fu, TARGET_AP))
				call SpellHelper.damageTarget(this.caster, fu, EXPLODE_AOE_DAMAGE[this.level], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            else
				call SpellHelper.damageTarget(this.caster, fu, EXPLODE_TARGET_DAMAGE[this.level], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            endif
        endmethod
        
        //The filter for the group pick, I merged the actions to the group filter for better performance
        static method OnHitFilter takes nothing returns boolean
            local unit u = GetFilterUnit()
			
			if (SpellHelper.isValidEnemy(u, datab.caster)) then
				call datab.OnHit(u)
            endif
			
            set u = null
			
            return false
        endmethod
        
        //the method run when the timer reaches 0.00 or when the target dies
        method OnExplode takes boolean dead returns nothing
            //This checks if the unit is dead and whether death is registered as a cause of explosion
            if not (dead and not ExUponDeath) then
                call GroupEnumUnitsInRange(thistype.dgroup, GetUnitX(this.target), GetUnitY(this.target), EXPLODE_RADIUS[this.level], Condition(function thistype.OnHitFilter) )
                call DestroyEffect(AddSpecialEffectTarget(EXPLODE_FX, this.target, EXPLODE_AP))
            endif
        endmethod
        
        //The method which is run after each interval
        private static method Refresh takes nothing returns nothing
            local boolean dead = false
            set datab = GetTimerData(GetExpiredTimer())
            set datab.time = datab.time - TICK
            set dead = GetWidgetLife(datab.target) < .405
            
            call DestroyEffect(AddSpecialEffectTarget(TICK_FX, datab.target, TICK_AP))
            set DamageType = SPELL
			call SpellHelper.damageTarget(datab.caster, datab.target, TICK_DAMAGE[datab.level], false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            
            if datab.time <= 0.00 or dead then
                set VoltyTab[GetHandleId(datab.target)] = VoltyTab[GetHandleId(datab.target)] - 1
                call datab.OnExplode(dead)
                call datab.RemoveBuff()
                call ReleaseTimer(GetExpiredTimer())
            endif
        endmethod
        
        //The method run when the spell VoltyCrush is used
        static method create takes unit caster, unit target returns thistype
            local timer t = NewTimer()
            
			set data = thistype.allocate()
            set data.target = target
            set data.level = GetUnitAbilityLevel(caster, SPELL_ID)
            set data.owner = GetOwningPlayer(caster)
            set data.caster = caster
            set data.time = EXPLODE_DELAY[data.level]
            set data.sfx = AddSpecialEffectTarget(MAIN_TARGET_FX, target, MAIN_TARGET_AP)
            set .dgroup = NewGroup()
            call UnitAddAbility(target, BUFF_SPELL_ID)
            call SetTimerData(t, data)
            call TimerStart(t, TICK, true, function thistype.Refresh) 
            set VoltyTab[GetHandleId(target)] = VoltyTab[GetHandleId(target)] + 1
            set t = null
            
			return data
        endmethod

    endstruct
    
    private function Actions takes nothing returns nothing
        call VoltyStruct.create(GetTriggerUnit(), GetSpellTargetUnit())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction
    
    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
        call MainSetup()
        call XE_PreloadAbility(BUFF_SPELL_ID)
        call Preload(TICK_FX)
        call Preload(EXPLODE_FX)
        call Preload(TARGET_FX)
        call Preload(MAIN_TARGET_FX)
    endfunction
    
endscope