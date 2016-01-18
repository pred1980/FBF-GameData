scope Adolescence initializer init
    /*
     * Description: The Nerubian Widow lays eggs that spawn spiderlings. Growing up, 
                    these sworn companions support the Widow in teaching her enemies the real meaning of Arachnophobia.
     * Changelog: 
     *     	27.10.2013: Abgleich mit OE und der Exceltabelle
	 *     	27.04.2015: Integrated RegisterPlayerUnitEvent
	 *		17.10.2015: Code optimization
						Changed TimerUtils to standard Timer (CreateTimer())
     */
    globals
        private constant integer SPELL_ID = 'A004'
        private constant integer EGG_ID = 'o00R'
        private constant integer CHILD_ID = 'n00C'
        private constant integer DUMMY_INVENTAR_ID = 'AInv'
        private constant real HATCHING_TIME = 4.5
		private constant real CRY_TIME = 2.1
        private constant real LIFE_TIME = 85
        private constant real TIMER_INTERVAL = 1.0
        private constant real START_SIZE = 0.15
        
        private integer array DAMAGE_PER_SECOND
        private real array START_HP
        private real array HP_PER_SECONDS
     
        private string SOUND_1 = "Units\\Critters\\SpiderCrab\\CrabDeath1.wav"
        private string SOUND_2 = "Units\\Creeps\\Spider\\SpiderYes2.wav"
    endglobals
    
    private function MainSetup takes nothing returns nothing
        set DAMAGE_PER_SECOND[1] = 1
        set DAMAGE_PER_SECOND[2] = 2
        set DAMAGE_PER_SECOND[3] = 3
        set DAMAGE_PER_SECOND[4] = 4
        set DAMAGE_PER_SECOND[5] = 5
        
        set START_HP[1] = 150.0
        set START_HP[2] = 175.0
        set START_HP[3] = 200.0
        set START_HP[4] = 225.0
        set START_HP[5] = 250.0
        
        set HP_PER_SECONDS[1] = 5.0
        set HP_PER_SECONDS[2] = 6.0
        set HP_PER_SECONDS[3] = 7.0
        set HP_PER_SECONDS[4] = 8.0
        set HP_PER_SECONDS[5] = 9.0
    endfunction

    private struct Adolescence
		private player p
		private integer pid
		private unit caster
        private unit egg
        private unit child
        private real size = 0.00
		private integer level = 0
		
		method onDestroy takes nothing returns nothing
            set .caster = null
            set .egg = null
            set .child = null
        endmethod
        
        static method onGrowUp takes nothing returns nothing
			local timer t = GetExpiredTimer()
            local thistype this = GetTimerData(t)
            
            if not (SpellHelper.isUnitDead(this.child)) then
                set this.size = this.size + 0.01
                call SetUnitScale(this.child, (START_SIZE + this.size), (START_SIZE + this.size), (START_SIZE + this.size))
                call AddUnitMaxState(this.child, UNIT_STATE_MAX_LIFE, HP_PER_SECONDS[this.level])
                call TDS.addDamage(this.child, DAMAGE_PER_SECOND[this.level])
            else
				//Release Timer
				call PauseTimer(t)
				call DestroyTimer(t)
				set t = null
                call this.destroy()
            endif
        endmethod
        
        static method onBornChild takes nothing returns nothing
			local timer t = GetExpiredTimer()
            local thistype this = GetTimerData(t)
            
            set this.child = CreateUnit( this.p, CHILD_ID, GetUnitX(this.egg), GetUnitY(this.egg), 0 )
            call Sound.runSoundOnUnit(SOUND_2, this.child)
            call UnitApplyTimedLife(this.child, 'BTLF', LIFE_TIME)
            call SetUnitScale(this.child, START_SIZE, START_SIZE, START_SIZE)
            call SetUnitVertexColor(this.child, PercentTo255(GetRandomReal(1.00, 100.00)), PercentTo255(GetRandomReal(1.00, 100.00)), PercentTo255(GetRandomReal(1.00, 100.00)), PercentTo255(100))
            call UnitAddAbility(this.child, DUMMY_INVENTAR_ID )
            call SetUnitMaxState(this.child, UNIT_STATE_MAX_LIFE, START_HP[this.level])
            
            call SetTimerData(t, this )
            call TimerStart(t, TIMER_INTERVAL, true, function thistype.onGrowUp)
			
			// add to Escort System (only for Bots)
			//if (Game.isBot[this.pid]) then
				call Escort.addUnit(this.caster, this.child)
			//endif
            
			set t = null
            endmethod
        
        static method onEgg takes nothing returns nothing
			local timer t = GetExpiredTimer()
            local thistype this = GetTimerData(t)
            
            call Sound.runSoundOnUnit(SOUND_1, this.egg)
            
            call SetTimerData(t, this )
            call TimerStart(t, CRY_TIME, false, function thistype.onBornChild)
			
			set t = null
        endmethod
        
        static method create takes unit caster, real tx, real ty returns thistype
            local thistype this = thistype.allocate()
			local timer t = CreateTimer()
            
			set .caster = caster
			set .p = GetOwningPlayer(.caster)
			set .pid = GetPlayerId(.p)
			set .level = GetUnitAbilityLevel(this.caster, SPELL_ID)
            set .egg = CreateUnit(p, EGG_ID, tx, ty, 0)
            call UnitApplyTimedLife(.egg, 'BTLF', HATCHING_TIME)
            
            call SetTimerData(t, this )
            call TimerStart(t, HATCHING_TIME, false, function thistype.onEgg )
        
            return this
        endmethod
    endstruct

    private function Actions takes nothing returns nothing
        call Adolescence.create(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY())
    endfunction
	
	private function Conditions takes nothing returns boolean
		return GetSpellAbilityId() == SPELL_ID
	endfunction

    private function init takes nothing returns nothing
        call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function Conditions, function Actions)
		call MainSetup()
		call Sound.preload(SOUND_1)
		call Sound.preload(SOUND_2)
    endfunction
endscope