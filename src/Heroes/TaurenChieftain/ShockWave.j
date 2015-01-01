scope ShockWave initializer init
    /*
     * Description: After 3 seconds, the Tauren Chieftain sends out a shockwave that knocks all enemies it hits back, 
                    dealing high damage to them and slowing them for 5 seconds. The closer an enemy is to the center 
                    of the wave, the higher is the damage it takes.
     * Last Update: 07.01.2014
     * Changelog: 
     *     07.01.2014: Abgleich mit OE und der Exceltabelle
     *
     */
    globals
        private constant integer SPELL_ID = 'A07C'
        private constant integer DUMMY_ID = 'u00C'
        private constant integer DUMMY_SPELL_ID = 'A07D'
        private constant real BASE_DISTANCE = 1000
        private constant real AOE = 200
        
        private constant real INTERVAL = 1./32.
        private constant real SPEED = 30
        private constant real KNOCK_DISTANCE = 200
        private constant real BASE_DAMAGE = 150
        private constant real DAMAGE_PER_LEVEL = 200
        private constant real FULL_DAM_AOE = 80
        private constant real TQ_DAM_AOE = 120
        private constant real HALF_DAM_AOE = 170
        
        private string SOUND = "Abilities\\Spells\\Orc\\Shockwave\\Shockwave.wav"
    endglobals

    private struct ShockWave
        unit dummy
        unit caster
        real distance
        real x
        real y
        real angle
        real damage
        group hit
        group gr
        timer t
        static thistype tempthis
        
        method onDestroy takes nothing returns nothing
            call ReleaseTimer(.t)
            set .t = null
            call KillUnit(.dummy)
            call RemoveUnit(.dummy)
            set .dummy = null
            set .caster = null
            call ReleaseGroup(.hit)
            call ReleaseGroup(.gr)
            set .hit = null
            set .gr = null
        endmethod
        
        static method group_filter_callback takes nothing returns boolean
            return IsUnitEnemy( GetFilterUnit(), GetOwningPlayer( .tempthis.caster ) ) and not /*
            */     IsUnitDead(GetFilterUnit()) and not /*
            */     IsUnitType(GetFilterUnit(), UNIT_TYPE_MAGIC_IMMUNE) and not /*
            */     IsUnitType(GetFilterUnit(), UNIT_TYPE_MECHANICAL)
        endmethod
        
        static method onDamageTarget takes nothing returns nothing
            local unit u = GetEnumUnit()
            local real ux
            local real uy
            local real dam
            local real dis
            
            set ux = GetUnitX(u)
            set uy = GetUnitY(u)
            set dis = DistanceBetweenCords(tempthis.x, tempthis.y, ux, uy)
            if (GetAngleDifferenceDegree(AddAngle(tempthis.angle,-90),AngleBetweenCords(tempthis.x, tempthis.y, ux, uy))<30 or GetAngleDifferenceDegree(AddAngle(tempthis.angle, 90), AngleBetweenCords(tempthis.x, tempthis.y, ux, uy))<30 or dis < FULL_DAM_AOE) and not(IsUnitInGroup(u,tempthis.hit)) then
                call GroupAddUnit(tempthis.hit, u)
                if dis < FULL_DAM_AOE then
                    set dam = tempthis.damage
                elseif dis < TQ_DAM_AOE then
                    set dam = tempthis.damage * 3./4.
                elseif dis < HALF_DAM_AOE then
                    set dam = tempthis.damage*1./2.
                else
                    set dam = tempthis.damage*1./4.
                endif
                call CastDummySpellTarget(tempthis.caster, u, DUMMY_SPELL_ID, 1, "slow", 5)
                call Knockback.create(tempthis.caster, u, KNOCK_DISTANCE, 1.5, AngleBetweenCords(tempthis.x,tempthis.y,GetUnitX(u),GetUnitY(u))*bj_DEGTORAD, 0, "", "")
                set DamageType = SPELL
                call UnitDamageTarget(tempthis.caster, u, dam, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNKNOWN, WEAPON_TYPE_WHOKNOWS)
            endif
            call GroupRemoveUnit(tempthis.gr,u)
            set u = null
        endmethod
        
        static method onShockwave takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            set this.x = this.x + SPEED * Cos(this.angle * bj_DEGTORAD)
            set this.y = this.y + SPEED * Sin(this.angle * bj_DEGTORAD)
            
            if RectContainsCoords(bj_mapInitialPlayableArea, this.x, this.y) and this.distance > 0 then
                set this.distance = this.distance - SPEED
                call SetUnitX(this.dummy, this.x)
                call SetUnitY(this.dummy, this.y)
                
                call GroupEnumUnitsInRange( .gr, this.x, this.y, AOE, function thistype.group_filter_callback )
                call ForGroup( .gr, function thistype.onDamageTarget )
            else
                call this.destroy()
            endif
        endmethod
        
        static method create takes unit caster returns thistype
            local thistype this = thistype.allocate()
            
            set .caster = caster
            set .x = GetUnitX(.caster)
            set .y = GetUnitY(.caster)
            set .gr = NewGroup()
            set .hit = NewGroup()
            set .distance = BASE_DISTANCE
            set .damage = BASE_DAMAGE + DAMAGE_PER_LEVEL * I2R(GetUnitAbilityLevel(.caster, SPELL_ID))
            set .angle = GetUnitFacing(.caster)//AngleBetweenCords(x,y,GetSpellTargetX(),GetSpellTargetY())
            set .dummy = CreateUnit(GetOwningPlayer(.caster), DUMMY_ID, .x, .y, .angle)
            set .tempthis = this
            
            call Sound.runSoundOnUnit(SOUND, .caster)
            set .t = NewTimer()
            call SetTimerData(.t, this)
            call TimerStart(.t, INTERVAL, true, function thistype.onShockwave)
            
            return this
        endmethod
       
        static method onInit takes nothing returns nothing
            set thistype.tempthis = 0
			call Sound.preload(SOUND)
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        local ShockWave sw = 0
        
        if( GetSpellAbilityId() == SPELL_ID )then
            set sw = ShockWave.create( GetTriggerUnit() )
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        
        call TriggerRegisterAnyUnitEventBJ( t, EVENT_PLAYER_UNIT_SPELL_FINISH )
        call TriggerAddAction( t, function Actions )
        call XE_PreloadAbility(DUMMY_SPELL_ID)
        
        set t = null
    endfunction

endscope