library CreepRoundSystem /* v 1.1.0.0
**********************************************************************************
*
*   CreepRound Management System
*   By looking_for_help aka eey
*
*   Use this system to manage your map specific rounds, e.g. for creep waves.
*   On default the system starts a new round after a certain time span but it
*   also allows you to define your own conditions when to start a new round.
*
**********************************************************************************
*                                                                                *
* Requirements */ uses PlayerStats, SoundTools, MiscFunctions                   /* 
*                                                                                *
********************************************************************************** 
*
*   System API
*   readonly static real nextRoundTime
*       - In this variable, the remaining time before a new round starts is stored.
*
*   readonly static integer actualRound
*       - In this variable the actual round is stored.
*
*   private module CreepRoundSystemConfig
*       - In this config module you can configure the following three methods. Add
*         this module to the system like described in the example. If you don't
*         implement any module to the system, it will use a template module and
*         stay in round 1 forever.
*   
*   static method startSystem takes nothing returns nothing
*       - Use this method to start the system.
*
*   static method OnRoundStartingTick takes nothing returns nothing
*       - This method gets fired every second before a new round is started. You
*         can output a countdown for the incoming next round here. 
*        
*   static method OnRoundStart takes nothing returns nothing
*       - This method gets fired when a new round starts. Put the code you want
*         to execute when starting a new round here.
*
*   static method OnRoundRunningTick takes nothing returns nothing
*       - This method gets fired every second when a current round is running.
*         You can output here for example a countdown when the round will end.
*        
*   static method OnRoundFinished takes nothing returns nothing
*       - This method gets fired when a round is finished and beginns to decay.
*         Compare the example in this testmap.
*
*   static method StartNextRound takes nothing returns boolean
*       - Here you can specify your own conditions when to start a new round,
*         for example if only a few units are left on the map. To start a new
*         round, let the function return true, otherwise false.
*
*********************************************************************************/

    globals
        /*************************************************************************
        *   Customizable globals
        *************************************************************************/
        
        // How long to wait before a new round starts?
        private constant real START_TIME_BEFORE_ROUND = 5
        
        // Do you want to automatically start a new round after some time?
        private constant boolean AUTO_START_NEW_ROUND_TIMED = false
        
        // If you auto start a new round after some time, how long is the round?
        private constant real NEW_ROUND_TIMEOUT = 5
        
        /*************************************************************************
        *   End of customizable globals
        *************************************************************************/
        
        constant integer ALL_ROUNDS = 0
        
        private string SOUND_1 = "Sound\\Ambient\\DoodadEffects\\TheHornOfCenarius.wav"
		private string SOUND_2 = "Sound\\Ambient\\DoodadEffects\\WarlockAppears.wav"
        private integer count = 0
		
		private group g = CreateGroup()
    endglobals
    
    module CreepRoundSystemConfig
        static method OnRoundStartingTick takes nothing returns nothing
        endmethod
        
        static method OnRoundStart takes nothing returns nothing
        endmethod
        
        static method OnRoundFinishingTick takes nothing returns nothing
        endmethod
        
        static method OnRoundFinished takes nothing returns nothing
        endmethod
        
        static method StartNextRound takes nothing returns boolean
            return false
        endmethod
    endmodule
    
    //! runtextmacro optional IMPLEMENT_CONFIG_MODULE("CreepRoundSystemConfig")
    
    struct RoundSystem extends array
        
        implement optional CreepRoundSystemConfig

        readonly static integer tickCounter = 0
        readonly static integer tickRound = 0
        readonly static real nextRoundTime = START_TIME_BEFORE_ROUND - tickCounter
        readonly static real actualRoundTime = NEW_ROUND_TIMEOUT - tickRound
        readonly static integer actualRound = 0 // Muss 0 sein, sonst gehen z.b. keine Hero Abilities mehr
        
        static timerdialog tiDialog
        static timer creepCountTimer = CreateTimer()
        readonly static integer creepCount = 0
        
        private static method creepGroupFilter takes nothing returns boolean
            local unit u = GetFilterUnit()
			
            if GetUnitTypeId(u) != 'e011' and /*
			*/ GetUnitTypeId(u) != 'e012' and not /*
			*/ IsUnitDead(u) and not /*
			*/ IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                set .creepCount = .creepCount + 1
            endif
            
            set u = null
            return false
        endmethod
    
        //Zaehlt die Creeps wenn eine Runde gestartet ist
        private static method countCreeps takes nothing returns nothing
            set .creepCount = 0
            call GroupEnumUnitsOfPlayer(g, Player(bj_PLAYER_NEUTRAL_VICTIM), Filter(function thistype.creepGroupFilter))
            call FBFMultiboard.onUpdateAttackers(.creepCount)
			call FBFMultiboard.onUpdateDefenders(ForsakenUnits.getCount())
            
            //Wenn es die letzte Runde ist und alle Creeps tot sind, dann beendet das Spiel
            if (actualRound == RoundType.getRounds()) and (.creepCount == 0) then
                set Game.forsakenHaveWon = true
                call Game.onGameOver()
            endif
            
            if StartNextRound() then
                call TimerStart(GetExpiredTimer(), 1.0, true, function thistype.onRoundFinishingTimer)
            endif
        endmethod
        
        private static method onRoundFinishingTimer takes nothing returns nothing
            if tickRound >= NEW_ROUND_TIMEOUT then
                set tickRound = 0
                call RoundSystem.startNewRound()
                call PauseTimer(GetExpiredTimer())
                
                set actualRoundTime = NEW_ROUND_TIMEOUT
                call OnRoundFinished()
				call Sound.runSound(SOUND_2)
				return
            endif
            
            call OnRoundFinishingTick()
            set tickRound = tickRound + 1
            set actualRoundTime = NEW_ROUND_TIMEOUT - tickRound
        endmethod
    
        private static method onRoundStartTimerEnd takes nothing returns nothing
            set actualRound = actualRound + 1
            /*
             * Update Round Config
             * Info: Je nach dem wie viele Forsaken Spieler im Spiel sind werden entsprechend nur eine gewissen Anzahl
             *       an Creep Units pro Lane gespawnt. Das soll verhinden, dass zu viele Units im Spiel sind,
             *       was das Spiel grad im AoS Teil unspielbar macht.
             */
            call RoundType.updateRoundConfig()
            
            //Los gehts :)
            call OnRoundStart()
            call TimerStart(.creepCountTimer, 1.0, true, function thistype.countCreeps)
            call PlayerStats.updateResourceLog()
            
            call DestroyTimerDialog(.tiDialog)
            set .tiDialog = null
            call DestroyTimer(GetExpiredTimer())
            
            call Sound.runSound(SOUND_1)
            
            //Update Undead Defense System (Weight/Sigam)
            call DefenseCalc.update()
        endmethod
        
        static method startNewRound takes nothing returns nothing
            local timer t = CreateTimer()
            
            set .tiDialog = CreateTimerDialog(t)
            call TimerStart(t, RoundType.getRoundTimer(), false, function RoundSystem.onRoundStartTimerEnd)
            call TimerDialogSetTitle(.tiDialog, "Round " + I2S(actualRound + 1) + ":")
            call TimerDialogDisplay(.tiDialog, true)
            
            //Update Multiboard
            call FBFMultiboard.onUpdateRound((actualRound + 1))
            
            set t = null
        endmethod
        
        static method startSystem takes nothing returns nothing
            call RoundSystem.startNewRound()
        endmethod
        
    endstruct
    
    private module Inits 
        private static method onInit takes nothing returns nothing 
            call PlayerStats.updateResourceLog()
            call Sound.preload(SOUND_1)
			call Sound.preload(SOUND_2)
        endmethod 
    endmodule
    
    private struct Init extends array 
        implement Inits 
    endstruct
    
endlibrary