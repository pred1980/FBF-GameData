scope Cleave initializer init
    /*
     * Description: The Abominations brutal strikes hit several units at once, a bonus percentage of the damage. 
                    Theres a small chance to stun or knockback weaker units.
     * Changelog: 
     *     	09.11.2013: Abgleich mit OE und der Exceltabelle
	 *     	22.03.2015: ATTACK_TYPE, DAMAGE_TYPE and WEAPON_TYPE specification
	 *		06.05.2015: Integrated SpellHelper for filtering
						Set struct members to private
     *
     */
    globals
        private constant integer SPELL_ID = 'A06M'
        private constant integer BUFF_ID = 'B00W'
        //Radius = Schaden x RADIUS_MULTIPLIER
        private constant real RADIUS_MULTIPLIER = 3.5
        //Einheiten deren HP unter dem WEAKNESS_FACTOR sind haben ne CHANCE gestunt
        //weggestoßen zu werden
        private constant integer WEAKNESS_FACTOR = 50
        
        //Chance für STUN oder KNOCK BACK
        private constant integer array CHANCE
        
		//prozentualer Schaden
        private constant integer array DAMAGE
        
		//STUN
        private constant string STUN_EFFECT = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        private constant string STUN_ATT_POINT = "overhead"
        private constant real STUN_DURATION = 1.5
        
		//KNOCK BACK
        private constant integer DISTANCE = 350
        private constant real KB_TIME = 0.75
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_NORMAL
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_METAL_HEAVY_CHOP
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set CHANCE[1] = 8
        set CHANCE[2] = 10
        set CHANCE[3] = 12
        set CHANCE[4] = 14
        set CHANCE[5] = 16
        
        set DAMAGE[1] = 60
        set DAMAGE[2] = 55
        set DAMAGE[3] = 50
        set DAMAGE[4] = 45
        set DAMAGE[5] = 40
    endfunction

    private struct Cleave
        private unit caster
        private integer level = 0
        private real damage
        private real radius
        private group targets
        private static thistype tempthis = 0
        
        private  static method group_filter_callback takes nothing returns boolean
			local unit u = GetFilterUnit()
			local boolean b = false
			
			if (SpellHelper.isValidEnemy(u, .tempthis.caster) and /*
			*/	IsUnitType(u, UNIT_TYPE_GROUND)) then
				set b = true
			endif
			
			set u = null
			
            return b
        endmethod
        
        private static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            local real x
            local real y
            local real ang
            local real dmg = (.tempthis.damage * DAMAGE[.tempthis.level]) / 100 
            
            //Damage
            if GetUnitState(u, UNIT_STATE_LIFE) > dmg then
                set DamageType = PHYSICAL
				call SpellHelper.damageTarget(.tempthis.caster, u, dmg, true, false, ATTACK_TYPE, DAMAGE_TYPE, WEAPON_TYPE)
            else
                call SetUnitExploded(u, true)
                call KillUnit(u) 
            endif
            //Ist es eine schwache Einheit?
            if GetUnitLifePercent(u) <= WEAKNESS_FACTOR and not IsUnitDead(u) then
                if GetRandomInt(1, 100) <= CHANCE[.tempthis.level] then
                    if GetRandomInt(0, 1) == 0 then
                        //Stun
                        call Stun_UnitEx(u, STUN_DURATION, false, STUN_EFFECT, STUN_ATT_POINT)
                    else
                        //Knockback
                        set x = GetUnitX(.tempthis.caster) - GetUnitX(u)
                        set y = GetUnitY(.tempthis.caster) - GetUnitY(u)
                        set ang = Atan2(y, x) - bj_PI
                        call Knockback.create(.tempthis.caster, u, DISTANCE, KB_TIME, ang, 0, "", "")
                    endif
                endif
            endif
            
            call GroupRemoveUnit(.tempthis.targets, u)
            if CountUnitsInGroup(.tempthis.targets) == 0 then
                call .tempthis.destroy()
            endif
            
            set u = null
        endmethod
		
		static method create takes unit attacker, real damage returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = attacker
            set .level = GetUnitAbilityLevel(.caster, SPELL_ID)
            set .damage = damage
            set .radius = .damage * RADIUS_MULTIPLIER
            set .targets = NewGroup()
            set .tempthis = this
            
            call GroupEnumUnitsInRange( .targets, GetUnitX(.caster), GetUnitY(.caster), .radius, function thistype.group_filter_callback )
            call ForGroup( .targets, function thistype.onDamageTarget )
            
            return this
        endmethod
        
        private method onDestroy takes nothing returns nothing
            call ReleaseGroup( .targets )
            set .targets = null
            set .caster = null
        endmethod
    endstruct
    
    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        if ( GetUnitAbilityLevel(damageSource, BUFF_ID) > 0 and IsUnitEnemy(damagedUnit, GetOwningPlayer(damageSource)) and DamageType == 0 ) then
            call Cleave.create(damageSource, damage)
        endif
    endfunction

    private function init takes nothing returns nothing
        call RegisterDamageResponse( Actions )
        call MainSetup()
        call Preload(STUN_EFFECT)
    endfunction

endscope