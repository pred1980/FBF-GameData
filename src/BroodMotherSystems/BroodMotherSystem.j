scope BroodMotherSystem initializer init
	/*
	 * HP = HPmax * Player_Alliance/6 *(1 + factor * (6-Player_UD)) 
     * Diese Formel berechnet die HP/Damage Werte der Spiders je nach Spieleranzahl auf beiden Seiten. 
	 */
    globals
        private constant integer SPIDER_ID = 'n00G'
        private constant integer MALE_ID = 'n00I'
        private constant integer FEMALE_ID = 'n00H'
        private constant integer EGG_ID = 'o00C'
        private constant integer EGG_COUNT = 6
        private constant real FACING = 180.0
        private constant real X = -5590.8
        private constant real Y = 5027.6
        private constant real LIFE_FACTOR = 240.0 //every Xmin an egg splashs and a child comes out
        private constant integer CHANCE = 40 //40% to get a male child
        private constant string ORDER_ATTACKMOVE = "attack"
        
        //Brood Mother
        private constant integer HP = 20000
        private constant integer DAMAGE = 550
        private constant real LAYING_TIME = 300.0 //Wann legt die Brood Mother ein neues Ei?
        private constant real TARGET_TOLERANCE = 192.
		
        //Egg
        private constant integer EGG_HP = 400
        
        //Childs
        private real array eggLifeTime
        
        //Male/Female
        private constant integer MALE_HP = 7000
        private constant integer MALE_DAMAGE = 275
        private constant integer FEMALE_HP = 4500
        private constant integer FEMALE_DAMAGE = 195
        
        private rect broodPlace
        private string SOUND_1 = "Units\\Critters\\SpiderCrab\\CrabDeath1.wav"
        private string SOUND_2 = "Units\\Creeps\\Spider\\SpiderYes2.wav"
        private integer counter = 0
        
        //Dieser Faktoren beschreiben die Erhöhung der HP/Damage Werte je nach Spieleranzahl auf der Forsaken Seite
        private constant real HP_FACTOR = 0.08 //Prozentwert
        private constant real DAMAGE_FACTOR = 0.03 //Prozentwert
	endglobals
    
    private function ResetCounter takes nothing returns nothing
        set counter = 0
    endfunction
	
	private struct MoveData
		unit broodMother
		timer t
		real x = 0.00
		real y = 0.00
		real targetX = 0.00
		real targetY = 0.00
		boolean reached = false
		boolean stucked = false
		
		method onDestroy takes nothing returns nothing
			call ReleaseTimer(.t)
			set .t = null
			set .broodMother = null
		endmethod
		
		static method onMove takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			local string order = OrderId2String(GetUnitCurrentOrder(this.broodMother))
			local integer i = 0
			local integer max = 5
			local boolean b = false
			
			if this.x == GetUnitX(this.broodMother) or this.y == GetUnitY(this.broodMother) and order == null then
				set .stucked = true
			endif
			
			set this.x = GetUnitX(this.broodMother)
			set this.y = GetUnitY(this.broodMother)
			
			loop
				exitwhen (IsTerrainWalkable(this.targetX, this.targetY) and i < max) and not .stucked
				set this.targetX = GetRandomReal(GetRectMinX(broodPlace), GetRectMaxX(broodPlace))
				set this.targetY = GetRandomReal(GetRectMinY(broodPlace), GetRectMaxY(broodPlace))
				set i = i + 1
				set .stucked = false
			endloop
			
			if not this.reached or /*
			*/ order == null and /*
			*/ i != max and not /*
			*/ IsUnitDead(this.broodMother) then
				call IssuePointOrder(this.broodMother, ORDER_ATTACKMOVE, this.targetX, this.targetY)
			else
				call IssuePointOrder(this.broodMother, ORDER_ATTACKMOVE, X, Y)
				call this.destroy()
			endif
		endmethod
	endstruct
    
    struct BroodMother
        timer t
        static unit broodMother
        static integer hp = 0
        static integer dmg = 0
		static MoveData data
		
		private static method onUnitDeath takes nothing returns nothing
			if GetUnitTypeId(GetTriggerUnit()) == SPIDER_ID then
				call Usability.getTextMessage(0, 9, true, GetLocalPlayer(), true, 0.00)
				call TeleportSystem.create()
			endif
		endmethod
        
        //update HP+Damage if a player left game
        static method onUpdate takes nothing returns nothing
            if not IsUnitDead(.broodMother) then
                //get new hp+dmg
				set .hp = GetDynamicRatioValue(HP, HP_FACTOR)
                set .dmg = GetDynamicRatioValue(DAMAGE, DAMAGE_FACTOR)
                call SetUnitMaxState(.broodMother, UNIT_STATE_MAX_LIFE, .hp)
                call TDS.resetDamage(.broodMother)
				call TDS.addDamage(.broodMother, .dmg)
            endif
        endmethod

		private static method onCheckEvent takes nothing returns boolean
            return GetUnitTypeId(GetTriggerUnit()) == SPIDER_ID
        endmethod
        
        private static method onLayingEgg takes nothing returns nothing
            local Egg egg = 0
            local unit broodMother = GetTriggerUnit()
            
			//BroodMother hat das Ziel erreicht
			set .data.reached = true
            set egg = Egg.create(GetUnitX(broodMother), GetUnitY(broodMother))
            
			call IssuePointOrder(broodMother, ORDER_ATTACKMOVE, X, Y)
			
			set broodMother = null
        endmethod
		
		//Auf zur Brutstaette
        static method onMoveToHatchery takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local real x = GetRandomReal(GetRectMinX(broodPlace), GetRectMaxX(broodPlace))
            local real y = GetRandomReal(GetRectMinY(broodPlace), GetRectMaxY(broodPlace))
            local string order = OrderId2String(GetUnitCurrentOrder(this.broodMother))
            local trigger onReach
            local rect r
			
			loop
                exitwhen IsTerrainWalkable(x,y)
                set x = GetRandomReal(GetRectMinX(broodPlace), GetRectMaxX(broodPlace))
                set y = GetRandomReal(GetRectMinY(broodPlace), GetRectMaxY(broodPlace))
            endloop
            
            if order == null then
				//Speichere die notwendigen Daten in einem sep. struct
				//und prufe ob die BroodMother das Ziel erreicht hat
                set .data = MoveData.create()
				set .data.broodMother = this.broodMother
				set .data.targetX = x
				set .data.targetY = y
				set .data.x = GetUnitX(this.broodMother)
				set .data.y = GetUnitY(this.broodMother)
				set .data.t = NewTimer()
				call SetTimerData(.data.t, .data)
				call TimerStart(.data.t, 1.5, true, function MoveData.onMove)
			
                set onReach = CreateTrigger()
				
				set r = Rect(x, y, x + TARGET_TOLERANCE, y + TARGET_TOLERANCE)
                call TriggerRegisterEnterRectSimple(onReach, r)
                call TriggerAddCondition(onReach, Condition(function thistype.onCheckEvent))
                call TriggerAddAction(onReach, function thistype.onLayingEgg)
				set onReach = null
			endif
                    
        endmethod
		
		static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            local real x = 0.0
            local real y = 0.0
            
            set .hp = GetGameStartRatioValue(HP, HP_FACTOR)
            set .dmg = GetGameStartRatioValue(DAMAGE, DAMAGE_FACTOR)
            
            set .broodMother = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), SPIDER_ID, X, Y, FACING)
            call SetUnitMaxState(.broodMother, UNIT_STATE_MAX_LIFE, .hp)
            call SetUnitState(.broodMother, UNIT_STATE_LIFE, GetUnitState(.broodMother, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
            call TDS.addDamage(.broodMother, .dmg)
            
            set .t = NewTimer()
            call SetTimerData(.t, this )
            call TimerStart( .t, LAYING_TIME, true, function thistype.onMoveToHatchery )
			
			//on Death Event
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, null, function thistype.onUnitDeath)
            
            return this
        endmethod
        
        static method onInit takes nothing returns nothing
            local integer i = 0
            
            set broodPlace = gg_rct_BroodPlace
            
            loop
                exitwhen i >= EGG_COUNT
				set eggLifeTime[i] = I2R(i+1) * LIFE_FACTOR
                set i = i + 1
            endloop
        endmethod
    
    endstruct
    
    struct EggSystem
        Egg egg = 0
        
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            local real x = 0.0
            local real y = 0.0
            
            loop
                exitwhen i >= EGG_COUNT
                set x = GetRandomReal(GetRectMinX(broodPlace), GetRectMaxX(broodPlace))
                set y = GetRandomReal(GetRectMinY(broodPlace), GetRectMaxY(broodPlace))
                loop
                    exitwhen IsTerrainWalkable(x,y)
                    set x = GetRandomReal(GetRectMinX(broodPlace), GetRectMaxX(broodPlace))
                    set y = GetRandomReal(GetRectMinY(broodPlace), GetRectMaxY(broodPlace))
                endloop
                set .egg = Egg.create(x,y)
                set i = i + 1
            endloop
            
			return this
        endmethod
    
    endstruct
    
    struct Egg
        unit egg
        unit child
        static group childs
        real x = 0.00
        real y = 0.00
        boolean male = false
        static integer male_hp = 0
        static integer male_dmg = 0
        static integer female_hp = 0
        static integer female_dmg = 0
		
		method onDestroy takes nothing returns nothing
			set .egg = null
			set .child = null
		endmethod
		
		//update HP+Damage of all childs if a player left game
        static method onUpdate takes nothing returns nothing
            local unit u
            
            loop
                set u = FirstOfGroup(.childs) 
                exitwhen u == null 
                if not IsUnitDead(u) then
                    //Male
                    if GetUnitTypeId(u) == 'n00I' then
                        set .male_hp = GetDynamicRatioValue(MALE_HP, HP_FACTOR)
                        set .male_dmg = GetDynamicRatioValue(MALE_DAMAGE, DAMAGE_FACTOR)
                        call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, .male_hp)
						call TDS.resetDamage(u)
						call TDS.addDamage(u, .male_dmg)
                    endif
                    //Female
                    if GetUnitTypeId(u) == 'n00H' then
                        set .female_hp = GetDynamicRatioValue(MALE_HP, HP_FACTOR)
                        set .female_dmg = GetDynamicRatioValue(MALE_DAMAGE, DAMAGE_FACTOR)
                        call SetUnitMaxState(u, UNIT_STATE_MAX_LIFE, .female_hp)
						call TDS.resetDamage(u)
						call TDS.addDamage(u, .female_dmg)
                    endif
					call SetUnitState(u, UNIT_STATE_LIFE, GetUnitState(u, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
                endif
                call GroupRemoveUnit(.childs, u) 
            endloop
        endmethod
        
		static method onChildMove takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local rect r = WebAreas.getArea(GetRandomInt(0,2))
            local unit u = this.child
            local real x = GetRandomReal(GetRectMinX(r), GetRectMaxX(r))
            local real y = GetRandomReal(GetRectMinY(r), GetRectMaxY(r))
            local string order = OrderId2String(GetUnitCurrentOrder(u))
            
            if not IsUnitDead(u) then
                if order == null then
                    loop
                        exitwhen IsTerrainWalkable(x,y)
                        set x = GetRandomReal(GetRectMinX(r), GetRectMaxX(r))
                        set y = GetRandomReal(GetRectMinY(r), GetRectMaxY(r))
                    endloop
                    
                    call IssuePointOrder(u, ORDER_ATTACKMOVE, x, y)
                endif
            else
                call ReleaseTimer(GetExpiredTimer())
            endif
        endmethod
		
		static method onChildBorn takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local timer t = NewTimer()
            
            set .male_hp = GetDynamicRatioValue(MALE_HP, HP_FACTOR)
            set .male_dmg = GetDynamicRatioValue(MALE_DAMAGE, DAMAGE_FACTOR)
            set .female_hp = GetDynamicRatioValue(FEMALE_HP, HP_FACTOR)
            set .female_dmg = GetDynamicRatioValue(FEMALE_DAMAGE, DAMAGE_FACTOR)
            
            call ReleaseTimer(GetExpiredTimer())
            if this.male then
                set .child = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), MALE_ID, this.x, this.y, 375.0 )
                call SetUnitVertexColor( .child, PercentTo255(0.00), PercentTo255(0.00), PercentTo255(100.0), PercentTo255(100))
                call SetUnitMaxState(.child, UNIT_STATE_MAX_LIFE, male_hp)
                call TDS.addDamage(.child,  male_dmg)
            else
                set .child = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), FEMALE_ID, this.x, this.y, 375.0 )
                call SetUnitMaxState(.child, UNIT_STATE_MAX_LIFE, female_hp)
                call TDS.addDamage(.child, female_dmg)
            endif
			call Sound.runSoundAtPoint(SOUND_2, GetUnitX(.child), GetUnitY(.child), .0)
            call SetUnitState(.child, UNIT_STATE_LIFE, GetUnitState(.child, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
            call GroupAddUnit(this.childs, .child)
            
            call SetTimerData(t, this)
            call TimerStart(t, 3.5, true, function thistype.onChildMove)
            
            //Clean up
            call RemoveUnit(this.egg)
            set this.egg = null
        endmethod
        
        static method onHatch takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local timer t
			
			if not IsUnitDead(this.egg) then
				call SetUnitAnimation(this.egg, "death")
				call KillUnit(this.egg)
				call ReleaseTimer(GetExpiredTimer())
				call Sound.runSoundAtPoint(SOUND_1, GetUnitX(this.egg), GetUnitY(this.egg), .0)
				
				set t = NewTimer()
				call SetTimerData(t, this)
				call TimerStart(t, 1.90, false, function thistype.onChildBorn)
			else
				call this.destroy()
				call ReleaseTimer(GetExpiredTimer())
			endif
        endmethod
		
		static method create takes real x, real y returns thistype
            local thistype this = thistype.allocate()
            local timer t = NewTimer()
            
            set .egg = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), EGG_ID, x, y, FACING)
            call SetUnitMaxState(.egg, UNIT_STATE_MAX_LIFE, EGG_HP)
            call SetUnitState(.egg, UNIT_STATE_LIFE, GetUnitState(.egg, UNIT_STATE_MAX_LIFE) * RMaxBJ(0,100.0) * 0.01)
            call SetUnitPosition(.egg, GetUnitX(.egg), GetUnitY(.egg))
            if GetRandomInt(0, 100) <= CHANCE then
                set .male = true
                call SetUnitVertexColor( .egg, PercentTo255(25.00), PercentTo255(59.00), PercentTo255(95.0), PercentTo255(78.0)) 
            endif
            set .x = x
            set .y = y
            
			call SetTimerData(t, this )
            call TimerStart(t, eggLifeTime[counter], false, function thistype.onHatch)
            
            set counter = counter + 1
            if counter >= EGG_COUNT then
                call ResetCounter()
            endif
            
            return this
        endmethod
                
        static method onInit takes nothing returns nothing
            set .childs = NewGroup()
        endmethod
    
    endstruct
    
    private function init takes nothing returns nothing
        call Sound.preload(SOUND_1)
		call Sound.preload(SOUND_2)
    endfunction

endscope