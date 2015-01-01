scope MightySwing initializer init
    /*
     * Description: The Ogre Warrior attacks with great might, causing his attacks to damage nearby enemies 
                    in addition to his main target. The further the enemy is away from the Ogre the less damage it takes.
     * Last Update: 09.01.2014
     * Changelog: 
     *     09.01.2014: Abgleich mit OE und der Exceltabelle
     */
    private keyword MightySwing
    
    globals
        private constant integer SPELL_ID = 'A09I'
        
        private integer array SPLASH_BONUS
        private integer array SPLASH_RADIUS
        private integer array SPLASH_REDUCER
        
		private MightySwing array spellForUnit
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set SPLASH_BONUS[1] = 15
        set SPLASH_BONUS[2] = 30
        set SPLASH_BONUS[3] = 45
        set SPLASH_BONUS[4] = 60
        set SPLASH_BONUS[5] = 75
        
        set SPLASH_REDUCER[0] = 0
        set SPLASH_REDUCER[1] = 3
        set SPLASH_REDUCER[2] = 6
        set SPLASH_REDUCER[3] = 9
        set SPLASH_REDUCER[4] = 12
    
        set SPLASH_RADIUS[0] = 150
        set SPLASH_RADIUS[1] = 175
        set SPLASH_RADIUS[2] = 200
        set SPLASH_RADIUS[3] = 225
        set SPLASH_RADIUS[4] = 250
    endfunction
    
    private struct MightySwing
        unit attacker
        integer level = 0
        real damage = 0.00
        group targets
        static thistype tempthis
        
		static method getForUnit takes unit u returns thistype
			return spellForUnit[GetUnitId(u)]
		endmethod
		
        static method create takes unit damageSource returns thistype
            local thistype this = thistype.allocate()
            
            set .attacker = damageSource
        	set .level =  GetUnitAbilityLevel(damageSource, SPELL_ID)
			set .targets = NewGroup()
			set .tempthis = this
			set spellForUnit[GetUnitId(damageSource)] = this
            
            return this
        endmethod
		
		method onAttack takes unit damageSource, unit damagedUnit, real damage returns nothing
            set .tempthis.damage = damage
            call GroupEnumUnitsInRange(.targets, GetUnitX(damageSource), GetUnitY(damageSource), SPLASH_RADIUS[4], function thistype.group_filter_callback)
            call GroupRemoveUnit(.targets, damagedUnit)
            call ForGroup(.targets, function thistype.onDamageTarget)
		endmethod
		
	    static method group_filter_callback takes nothing returns boolean
            return IsUnitEnemy( GetFilterUnit(), GetOwningPlayer( .tempthis.attacker ) ) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) and IsUnitType(GetFilterUnit(), UNIT_TYPE_GROUND) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL)
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            local integer i = 0
            local real cX = GetUnitX(.tempthis.attacker)
            local real cY = GetUnitY(.tempthis.attacker)
            local real tX = GetUnitX(u)
            local real tY = GetUnitY(u)
            local real distance = DistanceBetweenCords(cX, cY, tX, tY)
            local real damage = 0.00
            local integer maxIndex = 5
            
            loop
                exitwhen i > 4
                    if distance <= SPLASH_RADIUS[i] then
                        set damage = (.tempthis.damage * (SPLASH_BONUS[.tempthis.level] - SPLASH_REDUCER[i])) / 100
                        set DamageType = SPELL
                        call UnitDamageTarget(.tempthis.attacker, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNKNOWN, WEAPON_TYPE_WHOKNOWS)
                        call GroupRemoveUnit(.tempthis.targets, u)
                        set i = maxIndex
                    endif
                set i = i + 1
            endloop  
            
            set u = null
            if CountUnitsInGroup(.tempthis.targets) == 0 then
                call GroupRefresh(.tempthis.targets)
            endif
        endmethod
		
		method onLevelUp takes unit damageSource returns nothing
            set .level =  GetUnitAbilityLevel(damageSource, SPELL_ID)
		endmethod
        
    endstruct

    private function Actions takes unit damagedUnit, unit damageSource, real damage returns nothing
        local MightySwing ms = 0
        
        if ( GetUnitAbilityLevel(damageSource, SPELL_ID) > 0 and DamageType == PHYSICAL ) then
			set ms = MightySwing.getForUnit(damageSource)
			if ms == null then
				set ms = MightySwing.create( damageSource )
			else
				call ms.onAttack( damageSource, damagedUnit, damage )
			endif
        endif
    endfunction
    
    private function onLearnSkill takes nothing returns nothing
        local MightySwing ms = 0
        local unit u = GetTriggerUnit()
        
        set ms = MightySwing.getForUnit(u)
        if( GetLearnedSkill() == SPELL_ID )then
            if ms == null then
                set ms = MightySwing.create(u)
            else
                call ms.onLevelUp(u)
            endif
        endif
        
        set u = null
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_HERO_SKILL )
        call TriggerAddAction( t, function onLearnSkill )
        
        call RegisterDamageResponse( Actions )
        call MainSetup()
        
        set t = null
    endfunction

endscope