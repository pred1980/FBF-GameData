scope MindBurst initializer Init
    /*
     * Description: The Mana Eater casts out two magical bolts towards a target. They deal damage and leave a mana 
                    draining debuff. If the target has mana, some of it will be transfered to Gundagar.
     * Changelog: 
     *     12.11.2013: Abgleich mit OE und der Exceltabelle
	 *     19.03.2015: Coderefactoring
	 *     04.04.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for filtering and damaging
     */
    globals
        //Rawcodes
        private constant integer SPELL_ID = 'A06O'
        private constant integer DUMMY_ID = 'h00L'  
        private constant integer CAST_DUMMY_ID = 'e00U'
        private constant integer DUMMY_SPELL_ID = 'A06S'

        //Spell Related Constants
        //Order ID of the Spell(Mind Burst Buff Effect) effect whih should last after being hit
        private constant string EffectOrderID = "rejuvination"
        //Defines how fast the missiles are
        private constant real MissileSpeed = 10   
        //How fast the execution is
        private constant real TimerPeriod = 0.0275
        //Defines the missiles basic height (they spin arround this) should be bigger 
        //than SpinStarRadius that they do not touch the ground
        private constant real MissileHeight = 80
        // Sets the spin radius when they are created , why moving it decreases (look below)
        private constant real SpinStartRadius = 70
        // Sets the spin radius the missiles got at the end
        private constant real SpinEndRadius = 8
        // While moving missiles change their scale , this is their start scale (look below)
        private constant real StartScale = 0.95
        // This is the missiles end scale 
        private constant real EndScale = 0.2 
        // The rate the missiles spin
        private constant real SpinRate = 0.375
        //The additional range for hitting a target , the real range will be the current Spinradius + 
        //This value (this case its 110 at the start and 60 at the end)
        private constant real AdditionalDamageRange = 50
        // The Distance the missiled being released infront of the caster
        private constant real ReleaseDistance = 20.00          
        
        //Effects
        private constant string  DamageEffect  = "Abilities\\Weapons\\WingedSerpentMissile\\WingedSerpentMissile.mdl" 
        private constant string  HealEffect = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"                     
        private constant string  MissilesDeath = "Abilities\\Spells\\Orc\\LightningBolt\\LightningBoltMissile.mdl" 
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_MAGIC
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_SONIC
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS

        //System Variables , Do not change
        private timer t = CreateTimer()
        private unit Dummy = null
        private group ENUM_GROUP = CreateGroup()
    endglobals

    ///////////////////////////////////Defining most relevant Values////////////////////////////////////////////////

    private constant function MissileRangePerLevel takes real level returns real
        // The range the missiles reach per level
        return 550 + 225 * level
    endfunction
        
    private constant function StolenManaPerLevel takes integer level returns real
        // Amount of mana stolen directly and transfered to the caster
        return 5.0 + 5.0 * level
    endfunction    
        
    private constant function DamagePerLevel takes integer level returns real
        //Amount of damage dealt when a unit is hit
        return 30.00 + level * 20.00
    endfunction

    private function ManaDrainCondition takes unit a  returns boolean
        return (GetUnitState(a,UNIT_STATE_MANA) > 0.0)
    endfunction

    private struct Missiles
        static integer Index = 0
        static Missiles array Data 
        unit array missiles [2] // The 2 missiles
        real angle
        real x 
        real y
        real a
        unit caster
        group DamagedUnits // group to avoid damaging a unit twice
        real rangeleft
        integer level
        static method create takes nothing returns Missiles
            local Missiles data = Missiles.allocate()
            set Missiles.Data[Missiles.Index] = data
            set Missiles.Index = Missiles.Index + 1
            return data
        endmethod
    endstruct

    ////////////////////////////////Main script// Do not edit unless you understand it////////////////////////////////

    private function callback takes nothing returns nothing
        local Missiles data
        local integer i = 0
        local real x = 0.00
        local real y = 0.00
        local real z = 0
        local integer a = 0
        local unit b = null
        local unit dummy = null
        local real radius
        local real scale 
        
        // looping through all structs
        loop
            exitwhen i >= Missiles.Index
            set data = Missiles.Data[i]
            set a = 0      
            set z = data.rangeleft / MissileRangePerLevel(data.level)
            set scale = EndScale+(StartScale-EndScale)*z
            set radius = SpinEndRadius+(SpinStartRadius-SpinEndRadius)*z
            
            // Moving the missiles and setting their scale ect. depending on the left range
            call SetUnitX(data.missiles[0], data.x + MissileSpeed * Cos(data.angle) + Cos(data.angle+1.5708) * Cos(data.a) * radius)
            call SetUnitY(data.missiles[0], data.y + MissileSpeed * Sin(data.angle) + Sin(data.angle+1.5708) * Cos(data.a) * radius)
            call SetUnitFlyHeight(data.missiles[0], MissileHeight + Cos(data.a+1.5708) * radius, 1000)
            call SetUnitScale(data.missiles[0],scale,scale,scale)
            call SetUnitX(data.missiles[1], data.x + MissileSpeed * Cos(data.angle) + Cos(data.angle+1.5708) * Cos(data.a+3.14159) * radius)
            call SetUnitY(data.missiles[1], data.y + MissileSpeed * Sin(data.angle) + Sin(data.angle+1.5708) * Cos(data.a+3.14159) * radius)
            call SetUnitFlyHeight(data.missiles[1], MissileHeight + Cos(data.a-1.5708) * radius, 1000)
            call SetUnitScale(data.missiles[1],scale,scale,scale)
            set data.x = data.x + MissileSpeed * Cos(data.angle)
            set data.y = data.y + MissileSpeed * Sin(data.angle)
            set data.a = data.a + SpinRate
            set data.rangeleft = data.rangeleft - MissileSpeed
            set a = 0
            // looping through all units in range
            call GroupEnumUnitsInRange(ENUM_GROUP, data.x, data.y,radius + AdditionalDamageRange, null) 
            loop
                set b = FirstOfGroup(ENUM_GROUP)
                exitwhen b == null
                call GroupRemoveUnit(ENUM_GROUP,b)
                //checking if they are alrady damaged
				if SpellHelper.isValidEnemy(b, data.caster) then
					if IsUnitInGroup(b, data.DamagedUnits) == false then
						//damaging + casting buff
						call GroupAddUnit(data.DamagedUnits, b)
						
						set DamageType = SPELL
						call SpellHelper.damageTarget(data.caster, b, DamagePerLevel(data.level), false, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
						
						call DestroyEffect(AddSpecialEffectTarget(DamageEffect, b, "chest") )
						call SetUnitX(Dummy,GetUnitX(b))
						call SetUnitY(Dummy,GetUnitY(b))
						call SetUnitAbilityLevel(Dummy,DUMMY_SPELL_ID,data.level)
						call IssueTargetOrder( Dummy,  EffectOrderID,b )
						// Checking if unit has mana to steal it
						if ManaDrainCondition(b) then
							call DestroyEffect(AddSpecialEffectTarget(HealEffect, data.caster, "origin") )
							if (GetUnitState(b,UNIT_STATE_MANA) > StolenManaPerLevel(data.level)) then
								call SetUnitState(b, UNIT_STATE_MANA,GetUnitState(b,UNIT_STATE_MANA)-StolenManaPerLevel(data.level))
								call SetUnitState(data.caster, UNIT_STATE_MANA,GetUnitState(data.caster,UNIT_STATE_MANA)+StolenManaPerLevel(data.level))
							else
								call SetUnitState(data.caster, UNIT_STATE_MANA,GetUnitState(data.caster,UNIT_STATE_MANA)+GetUnitState(b,UNIT_STATE_MANA))
								call SetUnitState(b, UNIT_STATE_MANA,0)
							endif
						endif
					endif
				endif
            endloop
            call GroupClear(ENUM_GROUP)
            
            // Checking if the missiles reached their end point
            if data.rangeleft < 0 then
                call DestroyEffect(AddSpecialEffect(MissilesDeath,data.x,data.y) )
                // destryoing the missiles
                call RemoveUnit(data.missiles[0])
                set data.missiles[0] = null
                call RemoveUnit(data.missiles[1])
                set data.missiles[1] = null
                call DestroyGroup(data.DamagedUnits)
                set data.DamagedUnits = null
                set data.caster = null
                call Missiles.destroy(data)
                set Missiles.Data[i] = Missiles.Data[Missiles.Index - 1]
                set i = i - 1
                set Missiles.Index = Missiles.Index - 1
            endif
            set i = i + 1
        endloop
        set b = null
        set dummy = null
        
    endfunction

    private function Actions takes nothing returns nothing
        local integer i = Missiles.Index
        local unit caster = GetTriggerUnit()
        local integer level = GetUnitAbilityLevel(caster, SPELL_ID)
        local real angle = Atan2(GetLocationY(GetSpellTargetLoc()) - GetUnitY(caster), GetLocationX(GetSpellTargetLoc()) - GetUnitX(caster))
        local real x = GetUnitX(caster) + ReleaseDistance * Cos(angle)
        local real y = GetUnitY(caster) + ReleaseDistance * Sin(angle)
        local real distance = Distance(GetLocationX(GetSpellTargetLoc()), GetLocationY(GetSpellTargetLoc()), GetUnitX(caster), GetUnitY(caster))
        
        // Creating the Struct
        call Missiles.create()
        set Missiles.Data[i].caster = caster
        set Missiles.Data[i].angle = angle
        set Missiles.Data[i].rangeleft = distance
        set Missiles.Data[i].level = level
        set Missiles.Data[i].x = x
        set Missiles.Data[i].y = y
        set Missiles.Data[i].DamagedUnits = CreateGroup()
        set Missiles.Data[i].missiles[0] = CreateUnit(GetOwningPlayer(caster), DUMMY_ID , x , y , angle * 57.296)
        set Missiles.Data[i].missiles[1] = CreateUnit(GetOwningPlayer(caster), DUMMY_ID , x , y , angle * 57.296)
        if Missiles.Data[i].Index == 1 then
            call TimerStart(t, TimerPeriod, true, function callback)
        endif
		
        set caster = null
    endfunction
	
	private function Conditions takes nothing returns boolean
        return GetSpellAbilityId() == SPELL_ID 
    endfunction

    //===========================================================================
    private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
        
        set Dummy = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),CAST_DUMMY_ID,0,0,0)
        call UnitAddAbility(Dummy,DUMMY_SPELL_ID)
        
        //Preloading
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(DamageEffect) 
        call Preload(HealEffect)
        call Preload(MissilesDeath)
    endfunction

endscope