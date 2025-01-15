library PlayerStats/* v 1.0.0.0
**********************************************************************************
*
*   Player Stats
*   ¯¯¯¯¯¯¯¯¯¯¯¯
*   By looking_for_help aka eey
*
*   Use this system to manage the player statistics on your map. The system 
*   provides methods to get a players gold used per round or total as well as
*   how many items he has buyed or sold.
*
**********************************************************************************
*
*   System API
*   ¯¯¯¯¯¯¯¯¯¯
*   static method getPlayerGold takes player p, integer round returns integer
*       - Use this method to get a players total earned gold per round. Pass
*         zero (or ALL_ROUNDS) to get it from all rounds.
*
*   static method getPlayerWood takes player p, integer round returns integer
*       - Same as getPlayerGold but for wood.
*
*   static method getPlayerBuyedItems takes player p returns integer
*       - Returns the total number of buyed items of a player.
*
*   static method getPlayerSoldItems takes player p returns integer
*       - Returns the total number of sold items of a player.
**
*********************************************************************************/

    globals
        private hashtable h
        private constant integer WOOD_OFFSET = 12
        private constant integer DEATH_OFFSET = 24
    endglobals
    
    struct PlayerStats extends array
    
        static method getPlayerGold takes player p, integer round returns integer
            local integer i = 1
            local integer tempGold = 0
            
            if round > 0 then
                return LoadInteger(h, GetPlayerId(p), RoundSystem.actualRound)
            else
                loop
                    exitwhen i > RoundSystem.actualRound
                    set tempGold = tempGold + LoadInteger(h, GetPlayerId(p), i)
                    set i = i + 1
                endloop
                return tempGold
            endif
        endmethod
        
        static method getPlayerWood takes player p, integer round returns integer
            local integer i = 1
            local integer tempWood = 0
            
            if round > 0 then
                return LoadInteger(h, GetPlayerId(p) + WOOD_OFFSET, RoundSystem.actualRound)
            else
                loop
                    exitwhen i > RoundSystem.actualRound
                    set tempWood = tempWood + LoadInteger(h, GetPlayerId(p), i)
                    set i = i + 1
                endloop
                return tempWood
            endif
        endmethod
        
        static method getPlayerBuyedItems takes player p returns integer
            return LoadInteger(h, GetHandleId(p), 0)
        endmethod
        
        static method getPlayerSoldItems takes player p returns integer
            return LoadInteger(h, GetHandleId(p), 1)
        endmethod
        
        static method getPlayerAllDeaths takes player p returns integer
            local integer i = 0
            local integer count = 0
            
            loop
                exitwhen i > RoundSystem.actualRound
                set count = count + LoadInteger(h, GetPlayerId(p) + DEATH_OFFSET, i)
                set i = i + 1
            endloop
            return count
        endmethod
        
        static method getPlayerDeathPerRound takes player p returns integer
            return LoadInteger(h, GetPlayerId(p) + DEATH_OFFSET, RoundSystem.actualRound)
        endmethod
        
        static method setPlayerDeath takes player p returns nothing
            call SaveInteger(h, GetPlayerId(p) + DEATH_OFFSET, RoundSystem.actualRound, getPlayerDeathPerRound(p) + 1)
        endmethod
        
        static method resetPlayerDeath takes player p returns nothing
            call SaveInteger(h, GetPlayerId(p) + DEATH_OFFSET, RoundSystem.actualRound, 0)
        endmethod
        
        static method updateResourceLog takes nothing returns nothing
            local player p 
            local integer id = 0
            local integer i = 0
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) then
                    set p = Player(i)
                    set id = GetPlayerId(p)
                    call SaveInteger(h, id, RoundSystem.actualRound, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD))
                    call SaveInteger(h, id + WOOD_OFFSET, RoundSystem.actualRound, GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER))
                endif
                set i = i + 1
            endloop
            set p = null
        endmethod
    endstruct
    
    private module Inits
        private static method onBuy takes nothing returns nothing
            local integer id = GetHandleId(GetOwningPlayer(GetTriggerUnit()))
            call SaveInteger(h, id, 0, LoadInteger(h, id, 0) + 1)
        endmethod
        
        private static method onSell takes nothing returns nothing
            local integer id = GetHandleId(GetOwningPlayer(GetTriggerUnit()))
            call SaveInteger(h, id, 1, LoadInteger(h, id, 1) + 1)
        endmethod
    
        private static method onGoldChange takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            call SaveInteger(h, id, RoundSystem.actualRound, LoadInteger(h, id, RoundSystem.actualRound) + GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD))
            set p = null
        endmethod

        private static method onWoodChange takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p) + WOOD_OFFSET
            call SaveInteger(h, id, RoundSystem.actualRound, LoadInteger(h, id, RoundSystem.actualRound) + GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER))
            set p = null
        endmethod
        
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local trigger t1 = CreateTrigger()
            local trigger t2 = CreateTrigger()
            //local trigger t3 = CreateTrigger()
            //local trigger t4 = CreateTrigger()
            local code c1 = function thistype.onSell
            local code c2 = function thistype.onBuy
            //local code c3 = function thistype.onGoldChange
            //local code c4 = function thistype.onWoodChange
            
            set h = InitHashtable()
            loop
                exitwhen i > bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) then
                    call TriggerRegisterPlayerUnitEvent(t1, Player(i), EVENT_PLAYER_UNIT_SELL_ITEM, null)
                    call TriggerRegisterPlayerUnitEvent(t2, Player(i), EVENT_PLAYER_UNIT_PICKUP_ITEM, null)
                    //call TriggerRegisterPlayerStateEvent(t3, Player(i), PLAYER_STATE_RESOURCE_GOLD, NOT_EQUAL, -1.0)
                    //call TriggerRegisterPlayerStateEvent(t4, Player(i), PLAYER_STATE_RESOURCE_LUMBER, NOT_EQUAL, -1.0)
                endif
                set i = i + 1
            endloop
            
            call TriggerAddCondition(t1, Filter(c1))
            call TriggerAddCondition(t2, Filter(c2))
            //call TriggerAddCondition(t3, Filter(c3))
            //call TriggerAddCondition(t4, Filter(c4))
            set t1 = null
            set t2 = null
            //set t3 = null
            //set t4 = null
            set c1 = null
            set c2 = null
            //set c3 = null
            //set c4 = null
        endmethod
    endmodule
    
    private struct Init extends array
        implement Inits
    endstruct
endlibrary