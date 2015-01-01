library KillCounter /* v 1.2.0.0
**********************************************************************************
*
*   Kill Counter System
*   By looking_for_help aka eey
*   
*   Use this system to get a units or player specific kills. The system can 
*   differentiate between kills done by physical damage or spell damage as long
*   as you implemented such a differentiation into the damage detection engine.
*
********************************************************************************** 
*
*   Requirements
*   */ uses DamageEvent /*  by Anitarf
*
**********************************************************************************
*
*   System API
*   method getUnitUnitKills takes unit u, integer damageType, integer round returns integer
*       - Use this function to get a units total kills of normal units. You can specify
*         the damageType and the round as you like.
*
*   method getUnitHeroKills takes unit u, integer damageType, integer round returns integer
*       - Use this function to get a units total hero kills.
*
*   method getUnitKills takes unit u, integer damageType, integer round returns integer
*       - Use this function to get a units total kills of heros and normal units.
*
*
*   method getPlayerUnitKills takes player p, integer damageType, integer round returns integer
*       - Use this function to get a players total kills of normal units.
*
*   method getPlayerHeroKills takes player p, integer damageType, integer round returns integer
*       - Use this function to get a players total hero kills.
*
*   method getPlayerKills takes player p, integer damageType, integer round returns integer
*       - Use this function to get a players total kills of heros and normal units.
*
*
*   method getCreepUnitKills takes integer damageType, integer round returns integer
*       - Use this function to get all kills of normal units from creeps.
*
*   method getCreepHeroKills takes integer damageType, integer round returns integer
*       - Use this function to get all hero kills from creeps. 
*
*   method getCreepKills takes integer damageType, integer round returns integer
*       - Use this function to get all normal unit and hero kills from creeps.
*
*
*   method getAllPlayerUnitKills takes integer damageType, integer round returns integer
*       - Use this function to get all kills of normal units from all players excluding
*         creeps.
*
*   method getAllPlayerHeroKills takes integer damageType, integer round returns integer
*       - Use this function to get all hero kills from all players excluding creeps.
*         
*   method getAllPlayerKills takes integer damageType, integer round returns integer
*       - Use this function to get all normal unit and hero kills from all players 
*         excluding creeps.
*
*
*   method getPlayerTowerKills takes player p, integer damageType, integer round returns integer
*       - Use this function to get a players kills done by towers.
*
*   method getAllPlayerTowerKills takes integer damageType, integer round returns integer
*       - Use this function to get the kills done by towers of all players.
*
*********************************************************************************/

    globals
        /************************************************************************
        *   Customizable globals
        *************************************************************************/
        
        // Do you want the system to count teamkills?
        private constant boolean COUNT_TEAMKILLS = true

        /************************************************************************
        *   End of customizable globals
        *************************************************************************/
        
        private hashtable h
    endglobals
    
    private function OnDamage takes unit damagedUnit, unit damageSource, real damage returns nothing
        local player sourcePlayer = GetOwningPlayer(damageSource)
        local integer playerId = GetHandleId(sourcePlayer)
        local integer unitId = GetHandleId(damageSource)
        local integer n = KillCounter.getN()
        local integer offset = 0

        if GetWidgetLife(damagedUnit) - damage < UNIT_MIN_LIFE then
            if IsUnitType(damagedUnit, UNIT_TYPE_HERO) then
                set offset = 2
            endif
        
            if (not IsUnitEnemy(damagedUnit, sourcePlayer) and COUNT_TEAMKILLS == true) or /*
             */(IsUnitEnemy(damagedUnit, sourcePlayer)) then
                set offset = n*RoundSystem.actualRound - n + offset

                if DamageType == PHYSICAL then
                    call SaveInteger(h, playerId, PHYSICAL + offset, LoadInteger(h, playerId, PHYSICAL + offset) + 1)
                    call SaveInteger(h, unitId, PHYSICAL + offset, LoadInteger(h, unitId, PHYSICAL + offset) + 1)
                    if IsUnitType(damageSource, UNIT_TYPE_STRUCTURE) then
                        call SaveInteger(h, GetPlayerId(sourcePlayer), PHYSICAL + offset, LoadInteger(h, GetPlayerId(sourcePlayer), PHYSICAL + offset) + 1)
                    endif
                else
                    call SaveInteger(h, playerId, SPELL + offset, LoadInteger(h, playerId, SPELL + offset) + 1)
                    call SaveInteger(h, unitId, SPELL + offset, LoadInteger(h, unitId, SPELL + offset) + 1)
                    if IsUnitType(damageSource, UNIT_TYPE_STRUCTURE) then
                        call SaveInteger(h, GetPlayerId(sourcePlayer), SPELL + offset, LoadInteger(h, GetPlayerId(sourcePlayer), SPELL + offset) + 1)
                    endif
                endif
            endif
        endif
        
        set sourcePlayer = null
    endfunction
    
    struct KillCounter extends array

        readonly static integer n = 4
        
        static method getN takes nothing returns integer
            return n
        endmethod

        //! textmacro getUnitKillCount takes IDENTIFIER, IDENT_TYPE
        static method get$IDENTIFIER$UnitKills takes $IDENT_TYPE$ t, integer damageType, integer round returns integer
            local integer counter = 0
            local integer index = 1
            if round > 0 then
                if damageType < 2 then
                    return LoadInteger(h, GetHandleId(t), damageType + n*round - n)
                endif
                return LoadInteger(h, GetHandleId(t), n*round - n) + LoadInteger(h, GetHandleId(t), n*round - n + 1)
            else
                loop
                    exitwhen index > RoundSystem.actualRound
                    if damageType < 2 then
						set counter = counter + LoadInteger(h, GetHandleId(t), damageType + n*index - n)
                    else
						set counter = counter + LoadInteger(h, GetHandleId(t), n*index - n) + LoadInteger(h, GetHandleId(t), n*index - n + 1)
                    endif
                    set index = index + 1
                endloop
            endif
            return counter
        endmethod
        //! endtextmacro
        
        //! textmacro getHeroKillCount takes IDENTIFIER, IDENT_TYPE
        static method get$IDENTIFIER$HeroKills takes $IDENT_TYPE$ t, integer damageType, integer round returns integer
            local integer counter = 0
            local integer index = 1
            if round > 0 then
                if damageType < 2 then
                    return LoadInteger(h, GetHandleId(t), damageType + n*round - n + 2)
                endif
                return LoadInteger(h, GetHandleId(t), n*round - n + 2) + LoadInteger(h, GetHandleId(t), n*round - n + 3)
            else
                loop
                    exitwhen index > RoundSystem.actualRound
                    if damageType < 2 then
                        set counter = counter + LoadInteger(h, GetHandleId(t), damageType + n*index - n + 2)
                    else
                        set counter = counter + LoadInteger(h, GetHandleId(t), n*index - n + 2) + LoadInteger(h, GetHandleId(t), n*index - n + 3)
                    endif
                set index = index + 1
                endloop
            endif
            return counter
        endmethod
        //! endtextmacro
        
        //! textmacro getBothKillCount takes IDENTIFIER, IDENT_TYPE
        static method get$IDENTIFIER$Kills takes $IDENT_TYPE$ t, integer damageType, integer round returns integer
            return get$IDENTIFIER$UnitKills(t, damageType, round) + get$IDENTIFIER$HeroKills(t, damageType, round)
        endmethod
        //! endtextmacro
        
        //! textmacro getGroupKillCount takes FROM_IDENT, IDENTIFIER, START_INDEX, END_INDEX
        static method get$FROM_IDENT$$IDENTIFIER$Kills takes integer damageType, integer round returns integer
            local integer killCounter = 0
            local integer index = $START_INDEX$
            
            loop
                exitwhen index > $END_INDEX$
                set killCounter = killCounter + getPlayer$IDENTIFIER$Kills(Player(index), damageType, round)
                set index = index + 1
            endloop
            return killCounter
        endmethod
        //! endtextmacro
    
        static method getPlayerTowerKills takes player p, integer damageType, integer round returns integer
            local integer counter = 0
            local integer index = 1
            local integer id = GetPlayerId(p)
            
            if round > 0 then
                if damageType < 2 then
                    return LoadInteger(h, id, damageType + n*round - n)
                endif
                return LoadInteger(h, id, n*round - n) + LoadInteger(h, id, n*round - n + 1)
            else
                loop
                    exitwhen index > RoundSystem.actualRound
                    if damageType < 2 then
                        set counter = counter + LoadInteger(h, id, damageType + n*index - n)
                    else
                        set counter = counter + LoadInteger(h, id, n*index - n) + LoadInteger(h, id, n*index - n + 1)
                    endif
                set index = index + 1
                endloop
            endif
            return counter
        endmethod
    
        //! runtextmacro getUnitKillCount("Unit", "unit")
        //! runtextmacro getHeroKillCount("Unit", "unit")
        //! runtextmacro getBothKillCount("Unit", "unit")
        //! runtextmacro getUnitKillCount("Player", "player")
        //! runtextmacro getHeroKillCount("Player", "player")
        //! runtextmacro getBothKillCount("Player", "player")
        //! runtextmacro getGroupKillCount("Creep", "Unit", "12", "15")
        //! runtextmacro getGroupKillCount("Creep", "Hero", "12", "15")
        //! runtextmacro getGroupKillCount("AllPlayer", "Unit", "0", "11")
        //! runtextmacro getGroupKillCount("AllPlayer", "Hero", "0", "11")
        //! runtextmacro getGroupKillCount("AllPlayer", "Tower", "0", "11")
        
    endstruct

    private module Init
        private static method onInit takes nothing returns nothing
            set h = InitHashtable()
            call RegisterDamageResponse(OnDamage)
        endmethod
    endmodule
    
    private struct Inits extends array
        implement Init
    endstruct
endlibrary