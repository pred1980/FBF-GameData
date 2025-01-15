scope WidowBite initializer init
    /*
     * Description: The Widow strikes an enemy with her deadly fangs, injecting lethal posion to the victim. 
                    The grim venom paralyzes and cripples the unit, until it finally causes a massive amount of damage on it.
     * Changelog: 
     *     	27.10.2013: Abgleich mit OE und der Exceltabelle
	 *     	27.04.2015: Integrated RegisterPlayerUnitEvent
     *
     */
    globals
        private constant integer SPELL_ID = 'A003'
        private constant integer DUMMY_SPELL_ID = 'A000'
        private constant real MAX_TIME = 40.0
        private constant real START_DAMAGE = 50
        private constant real DAMAGE_PER_LEVEL = 45
        private constant real DIMENSION = 500
        
        //DOT
        private constant real DOT_TIME = 5.00
        private constant string EFFECT = "Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl"
        private constant string ATT_POINT = "origin"
		
		// Dealt damage configuration
        private constant attacktype ATTACK_TYPE = ATTACK_TYPE_NORMAL
        private constant damagetype DAMAGE_TYPE = DAMAGE_TYPE_SLOW_POISON
        private constant weapontype WEAPON_TYPE = WEAPON_TYPE_WHOKNOWS
    endglobals

    private struct WidowBite
        private unit caster
        private unit target
        private real time = 0.00
        private real x = 0.00
        private real y = 0.00
        private real colorVal = 100.0
        private real damage
        private boolean array progress[4]
        private timer t
        private rect r
		
		method onDestroy takes nothing returns nothing
            call UnitRemoveAbility(.target, DUMMY_SPELL_ID)
            call SetUnitVertexColor(.target, PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(100))
            set .caster = null
            set .target = null
            call ReleaseTimer( .t )
            set .t = null
            set .r = null
        endmethod

        static method onPeriodic takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.time = this.time + 1.0
            set this.colorVal = this.colorVal - 2.0
            call SetUnitVertexColor(this.target, PercentTo255(this.colorVal), PercentTo255(100), PercentTo255(this.colorVal), PercentTo255(100))
            //progress Statue 1
            if this.time <= 10 and .progress[0] == false then
                set .progress[0] = true
                call UnitAddAbility( this.target, DUMMY_SPELL_ID )
                call SetUnitAbilityLevel( this.target, DUMMY_SPELL_ID, 1 )
            endif
            //progress Statue 2
            if (this.time > 10 and this.time <= 20) and .progress[1] == false then
                set .progress[1] = true
                call SetUnitAbilityLevel( this.target, DUMMY_SPELL_ID, 2 )
            endif
            //progress Statue 3
            if (this.time > 20 and this.time <= 30) and .progress[2] == false then
                if ( this.time == 21) then
                    call SetUnitAbilityLevel( this.target, DUMMY_SPELL_ID, 3 )
                endif
                if ( this.time == 27) then
                    set .progress[2] = true
                endif
                set .r = Rect( GetUnitX(this.target) - DIMENSION, GetUnitY(this.target) - DIMENSION, GetUnitX(this.target) + DIMENSION, GetUnitY(this.target) + DIMENSION )
                set .x = GetRandomReal( GetRectMinX(r), GetRectMaxX(r) )
                set .y = GetRandomReal( GetRectMinY(r), GetRectMaxY(r) )
                call IssuePointOrder( this.target, "attack", .x, .y )
            endif
            //progress Statue 4
            if (this.time > 30 and this.time <= MAX_TIME) and .progress[3] == false then
                if (this.time == 31 and not IsUnitInvulnerable(this.target))  then
                    call SetUnitAbilityLevel( this.target, DUMMY_SPELL_ID, 4 )
					set damage = (START_DAMAGE + (GetUnitAbilityLevel(this.caster, SPELL_ID) * DAMAGE_PER_LEVEL)) * DOT_TIME
                    set DamageType = PHYSICAL
					call DOT.start(this.caster , this.target , damage , DOT_TIME , ATTACK_TYPE , DAMAGE_TYPE , EFFECT , ATT_POINT)
                endif
                if ( this.time == 37) then
                    set .progress[3] = true
                endif
                set .r = Rect( GetUnitX(this.target) - DIMENSION, GetUnitY(this.target) - DIMENSION, GetUnitX(this.target) + DIMENSION, GetUnitY(this.target) + DIMENSION )
                set .x = GetRandomReal( GetRectMinX(r), GetRectMaxX(r) )
                set .y = GetRandomReal( GetRectMinY(r), GetRectMaxY(r) )
                call IssuePointOrder( this.target, "attack" , .x, .y )
            endif
            if this.time > MAX_TIME then
                call this.destroy()
            endif
        endmethod
        
        static method create takes unit caster, unit target returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .target = target
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, 1.0, true, function thistype.onPeriodic)
            
            return this
        endmethod
        
    endstruct

    private function Actions takes nothing returns nothing
        call WidowBite.create( GetTriggerUnit(), GetSpellTargetUnit() )
    endfunction
	
	private function Condtions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
	endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Condtions, function Actions)
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        call Preload(EFFECT)
    endfunction

endscope