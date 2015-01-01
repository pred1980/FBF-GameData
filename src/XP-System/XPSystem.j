scope XPSystem

    globals
        private constant real INTERVAL = 1.0
        //Items | 0 = Item Id | 1 = Value | 2 = Buff Id
        private integer array ITEMS[4][3]
        private constant integer MAX_ITEMS = 4
    endglobals
    
    private function registerItems takes nothing returns nothing
        //Magix Axe
        set ITEMS[0][0] = 'I016'
        set ITEMS[0][1] = 32
        set ITEMS[0][2] = 0
        //Necromancer's Robe
        set ITEMS[1][0] = 'I00M'
        set ITEMS[1][1] = -10
        set ITEMS[1][2] = 'B02Y'
        //Keeper Staff
        set ITEMS[2][0] = 'I03V'
        set ITEMS[2][1] = 20
        set ITEMS[2][2] = 0
        //Keeper Staff
        set ITEMS[3][0] = 'I01V'
        set ITEMS[3][1] = 25
        set ITEMS[3][2] = 0
        //Keeper Staff
        set ITEMS[4][0] = 'I034'
        set ITEMS[4][1] = 18
        set ITEMS[4][2] = 0
    endfunction
    
    struct XPSystem
        static timer t
        static integer array xp
        static integer value
        
        static method create takes nothing returns XPSystem
            local XPSystem this = XPSystem.allocate()
            
            set .t = NewTimer()
            call TimerStart( .t, INTERVAL, true, function thistype.onLoop )
            
            return this
        endmethod
        
        static method onLoop takes nothing returns nothing
            local integer i = 0
            
            loop
                exitwhen i >= bj_MAX_PLAYERS
                if Game.isPlayerInGame(i) then
                    set .xp[i] = GetHeroXP(BaseMode.getPickedHero(i))
                endif
                set i = i + 1
            endloop
        endmethod
        
        public static method onDeath takes unit killer returns nothing
            local integer id = GetPlayerId(GetOwningPlayer(killer))
            local integer factor = 0
            //Falls es sich um einen Helden handelt...
            if IsUnitType(killer, UNIT_TYPE_HERO) then
                set factor = getItemFactor(killer)
                if (factor != -1) then
                    //Differenz ermitteln zw. dem grad aktuelle XP-Wert und dem vorherigen
                    set .value = GetHeroXP(killer) - .xp[id]
                    //XP-Differenz-Wert x Faktor berechnen
                    set .value = (.value * factor ) / 100
                    //zus?tzliche XP dem Held geben
                    call AddHeroXP(killer, .value, true)
                    //Loop-Wert manuell aktualisieren
                    set .xp[id] = GetHeroXP(killer)
                endif
            endif
            
        endmethod
        
        static method getItemFactor takes unit u returns integer
            local integer i = 0
            
            loop
                exitwhen i == MAX_ITEMS
                if UnitHasItemOfTypeBJ(u, ITEMS[i][0]) or GetUnitAbilityLevel(u, ITEMS[i][2]) > 0 then
                    return ITEMS[i][1]
                endif
                set i = i + 1
            endloop

            return -1
        endmethod
		
		static method initialize takes nothing returns nothing
			call registerItems()
			call thistype.create()
		endmethod
    
    endstruct
    
endscope