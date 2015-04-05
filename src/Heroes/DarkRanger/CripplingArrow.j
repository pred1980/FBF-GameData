scope CripplingArrow initializer Init
    /*
     * Description: Gabrielle shoots a poisoned arrow that slows down the targeted unit. 
                    It deals bonus damage if the target is already affected by an arrow.
     * Changelog: 
     *     24.11.2013: Abgleich mit OE und der Exceltabelle
	 *	   28.03.2014: Missile Speed um 15% erhoeht
	 *     29.03.2015: Integrated RegisterPlayerUnitEvent
	                   Integrated SpellHelper for damaging
     */
    globals
        private constant integer SPELL_ID = 'A0AJ'
        private constant string MAIN_MODEL = "Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruptionMissile.mdl"
        private constant real MAIN_SCALE = 1.0
        private constant real SPEED = 900.0
        private constant real ACCELERATION = 650.0
        private constant real MAX_SPEED = 1100.0
        private constant real MAX_DISTANCE = 1500.0
        
        private constant integer DUMMY_ID = 'e00Z'
        private constant integer CRIPPLE_ID = 'A073'
        private constant integer BUFF_ID = 'B013'
        private constant integer BASE_DAMAGE = 0
        private constant integer DAMAGE_PER_LEVEL = 75
        private constant real MULTIPLIER = 1.5    
        
        //Stun Effect
        private constant string STUN_EFFECT = ""
        private constant string STUN_ATT_POINT = ""
        private constant real STUN_DURATION = 0.5
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_PIERCE
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_POISON
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
        
        private xedamage damageOptions
    endglobals
  
    private function setupDamageOptions takes xedamage d returns nothing
       set d.dtype = DAMAGE_TYPE
       set d.atype = ATTACK_TYPE
	   set d.wtype = WEAPON_TYPE
	   
       set d.exception = UNIT_TYPE_STRUCTURE 
    endfunction

    private struct CripplingArrow extends xecollider 
        unit caster
        integer level
        real dist = 0.00
        real maxDist = MAX_DISTANCE
        
        static method create takes real x, real y, real ang, unit caster returns thistype
            local CripplingArrow this = CripplingArrow.allocate(x, y, ang)
            
            set this.fxpath = MAIN_MODEL
            set this.scale = MAIN_SCALE
            set this.caster = caster 
            set this.level = GetUnitAbilityLevel(caster, SPELL_ID)
            set this.speed = SPEED
            set this.acceleration = ACCELERATION
            set this.maxSpeed = MAX_SPEED

            return this
        endmethod
       
        method onUnitHit takes unit hitunit returns nothing
            local unit u
            
            if (damageOptions.allowedTarget(this.caster, hitunit )) then
                set DamageType = PHYSICAL
                
                if GetUnitAbilityLevel(hitunit, BUFF_ID) > 0 then
					call SpellHelper.damageTarget(this.caster, hitunit, MULTIPLIER *(BASE_DAMAGE + this.level * DAMAGE_PER_LEVEL), true, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                else
					call SpellHelper.damageTarget(this.caster, hitunit, BASE_DAMAGE + this.level * DAMAGE_PER_LEVEL, true, true, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
                endif
                
                set u = CreateUnit(GetOwningPlayer(this.caster), DUMMY_ID, GetUnitX(hitunit), GetUnitY(hitunit), 0)
                call UnitAddAbility(u, CRIPPLE_ID)
                call SetUnitAbilityLevel(u, CRIPPLE_ID, this.level)
                call IssueTargetOrder(u, "cripple", hitunit)
                call UnitApplyTimedLife(u, 'BHwe', 2.0)
                
                //stun to break channel spells
                call Stun_UnitEx(hitunit, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
                
                call this.terminate()
            endif
        endmethod

        method loopControl takes nothing returns nothing
            set this.dist = this.dist + this.speed * XE_ANIMATION_PERIOD
            if (this.dist >= this.maxDist) or not IsTerrainWalkable(this.x, this.y) then
                call this.terminate()
            endif
        endmethod
        
        method onDestroy takes nothing returns nothing
            set this.caster = null
        endmethod

   endstruct

    private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
    endfunction

    private function Actions takes nothing returns nothing
        local unit caster = GetTriggerUnit()
        local real x = GetSpellTargetX()
        local real y = GetSpellTargetY()
        local real ang = AngleBetweenCords(GetUnitX(caster), GetUnitY(caster), x, y) * bj_DEGTORAD
        
        call CripplingArrow.create(GetUnitX(caster), GetUnitY(caster), ang, caster)

        set caster = null
    endfunction

  
    private function Init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		
		set damageOptions = xedamage.create()
        call setupDamageOptions(damageOptions)

        call Preload(MAIN_MODEL)
    endfunction
endscope
