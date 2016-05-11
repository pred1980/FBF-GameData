scope HeroPickInit
    
    globals
        private constant integer MAX_HEROES = 27
        private constant integer ACOLYTE_ID = 'u002'
        private constant integer PEON_ID = 'o00G'
        private constant integer PEASANT_ID = 'h00C'
        private constant integer WISP_ID = 'e002'
        private constant boolean ABILITY_PRELOAD = true
        private unit array HERO_PICK_UNIT[9]
        
        // Hero Pick
        private rect array HERO_PICK_RECT[MAX_HEROES]
        private real array HERO_PICK_FACING[MAX_HEROES]
        private rect array HERO_PICK_RANDOM_RECT[2]
        private rect array HERO_RACE_START_RECT[4]
    
        private integer array HEROES[MAX_HEROES]
        private integer array HERO_ABILITIES[MAX_HEROES][4]
        
        // Hero Revive
        private real array HERO_REPICK_RECT[MAX_HEROES][2]
        
        //0 = Acolyte
        //1 = Peon, Wisp, Peasant ( Starten alle von der selben Position )
        private real array PICK_UNIT_START_POS_X[2]
        private real array PICK_UNIT_START_POS_Y[2]
        
        /*
         * Globale Vars für das Disablen der Hero Abilities
         */
        // Orderid wenn der Held selected ist
        private constant integer CHOOSE_HERO_ORDER_ID = 1747988528 
        private group selectableHeroes
        private unit hero = null
        private trigger orders = CreateTrigger()
        private trigger setup = CreateTrigger()
        
    endglobals
    
    /*
     * PUBLIC FUNCTIONS
     */
    
    function GET_MAX_HEROES takes nothing returns integer
        return MAX_HEROES
    endfunction
    
    function GET_HERO_PICK_RECT takes integer index returns rect
        return HERO_PICK_RECT[index]
    endfunction
    
    function GET_HERO_REPICK_RECT_X takes integer heroID returns real
        return HERO_REPICK_RECT[heroID][0]
    endfunction
    
    function GET_HERO_REPICK_RECT_Y takes integer heroID returns real
        return HERO_REPICK_RECT[heroID][1]
    endfunction
    
    function GET_HERO_PICK_RANDOM_RECT takes integer index returns rect
        return HERO_PICK_RANDOM_RECT[index]
    endfunction
    
    function GET_HERO takes integer index returns integer
        return HEROES[index]
    endfunction
    
    function GET_HERO_PICK_FACING takes integer index returns real
        return HERO_PICK_FACING[index]
    endfunction
    
    function GET_HERO_ABILITY takes integer heroIndex, integer abiIndex returns integer
        return HERO_ABILITIES[heroIndex][abiIndex]
    endfunction
    
    function CREATE_HERO_PICK_UNIT takes integer id returns nothing
        local unit u
        local race r = GetPlayerRace(Player(id))
       
        if r == RACE_UNDEAD then
            set u = CreateUnit(Player(id), ACOLYTE_ID, PICK_UNIT_START_POS_X[0], PICK_UNIT_START_POS_Y[0], 0)
        elseif r == RACE_ORC then
            set u = CreateUnit(Player(id), PEON_ID, PICK_UNIT_START_POS_X[1], PICK_UNIT_START_POS_Y[1], 0)
        elseif r == RACE_HUMAN then
            set u = CreateUnit(Player(id), PEASANT_ID, PICK_UNIT_START_POS_X[1], PICK_UNIT_START_POS_Y[1], 0)
        else
            set u = CreateUnit(Player(id), WISP_ID, PICK_UNIT_START_POS_X[1], PICK_UNIT_START_POS_Y[1], 0)
        endif
        
        //save Hero Pick Unit for Player
        set HERO_PICK_UNIT[id] = u
        
        call SelectUnitByPlayer(u, true, Player(id))
        //call CinematicFadeBJ( bj_CINEFADETYPE_FADEIN, 1.70, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0 )
        call PanCameraToTimedForPlayer( Player(id), GetUnitX(u), GetUnitY(u), 0 )
        
        set u = null
    endfunction
    
    //Returns the Hero Pick Unit for the Player
    function GET_HERO_PICK_UNIT takes integer id returns unit
        return HERO_PICK_UNIT[id]
    endfunction
    
    function GET_HERO_RACE_START_RECT takes race r returns rect
        local integer index = 0
        
        if r == RACE_UNDEAD then
            set index = 0
        elseif r == RACE_HUMAN then
            set index = 1
        elseif r == RACE_ORC then
            set index = 2
        else
            set index = 3
        endif
    
        return HERO_RACE_START_RECT[index]
    endfunction
    
    //Gibt die Start-Position des Helden zur?ck, nach dem er ausgew?hlt wurde
    //abh?ngig von der Spielerrasse
    
    /*
     * MAIN SETUP
     */
    private function MainSetup takes nothing returns nothing
        
        /*
         * Hero IDs
         */
        //Undead Heroes...
        set HEROES[0] = 'U01N' //Behemot
        set HEROES[1] = 'U01O' //Nerubian Widow 
        set HEROES[2] = 'U004' //Ice Avatar
        set HEROES[3] = 'U00A' //Ghoul
        set HEROES[4] = 'U01S' //Master Banshee
        set HEROES[5] = 'U019' //Death Marcher
        set HEROES[6] = 'U01P' //Skeleton Mage
        set HEROES[7] = 'U01Q' //Master Necromancer
        set HEROES[8] = 'U01U' //Crypt Lord
        set HEROES[9] = 'H00G' //Abomination
        set HEROES[10] = 'H009' //Destroyer
        set HEROES[11] = 'U01X' //Dread Lord
        set HEROES[23] = 'N00J' //Dark Ranger
        
        //Infidel Heroes
        set HEROES[12] = 'H00Y' //Archmage
        set HEROES[13] = 'O00K' //Tauren Chieftain
        set HEROES[14] = 'E00P' //Priestess of the Moon
        set HEROES[15] = 'N00K' //Naga Matriarch
        set HEROES[16] = 'O000' //Orcish Warlock
        set HEROES[17] = 'O005' //Farseer
        set HEROES[18] = 'E009' //Fire Panda
        set HEROES[19] = 'H01B' //Mountain Giant
        set HEROES[20] = 'E00K' //Cenarius
        set HEROES[21] = 'H01Q' //Paladin
        set HEROES[22] = 'H008' //Royal Knight
        set HEROES[24] = 'H01S' //Blood Mage
        set HEROES[25] = 'H01C' //Ogre Warrior
        set HEROES[26] = 'H002' //Giant Turtle
        
        /*
         * Unit Facing
         */
        //Undead Heroes...
        set HERO_PICK_FACING[0] = 275.00 //Behemot
        set HERO_PICK_FACING[1] = 275.00 //Nerubian Widow
        set HERO_PICK_FACING[2] = 275.00 //Ice Avatar
        set HERO_PICK_FACING[3] = 275.00 //Ghoul
        set HERO_PICK_FACING[4] = 0.00   //Master Banshee
        set HERO_PICK_FACING[5] = 0.00   //Death Marcher
        set HERO_PICK_FACING[6] = 180.00 //Skeleton Mage
        set HERO_PICK_FACING[7] = 180.00 //Master Necromancer
        set HERO_PICK_FACING[8] = 180.00 //Crypt Lord
        set HERO_PICK_FACING[9] = 180.00 //Abomination
        set HERO_PICK_FACING[10] = 90.00 //Destroyer
        set HERO_PICK_FACING[11] = 90.00 //Dread Lord
        set HERO_PICK_FACING[23] = 90.00 //Dark Ranger
        
        //Infidel Heroes
        set HERO_PICK_FACING[12] = 275.00
        set HERO_PICK_FACING[13] = 275.00
        set HERO_PICK_FACING[14] = 275.00
        set HERO_PICK_FACING[15] = 275.00
        set HERO_PICK_FACING[16] = 275.00
        set HERO_PICK_FACING[17] = 275.00
        set HERO_PICK_FACING[18] = 275.00
        set HERO_PICK_FACING[19] = 275.00
        set HERO_PICK_FACING[20] = 275.00
        set HERO_PICK_FACING[21] = 90.00
        set HERO_PICK_FACING[22] = 90.00
        set HERO_PICK_FACING[24] = 90.00
        set HERO_PICK_FACING[25] = 90.00
        set HERO_PICK_FACING[26] = 90.00
        
        /*
         * Start Positionen der Helden nach dem
         * sie ausgewählt wurden, heisst in der
         * jeweiligen Basis des Spielers
         */
        
        set HERO_RACE_START_RECT[0] = gg_rct_UndeadHeroMainBase
        set HERO_RACE_START_RECT[1] = gg_rct_HumanHeroMainBase
        set HERO_RACE_START_RECT[2] = gg_rct_OrcHeroMainBase
        set HERO_RACE_START_RECT[3] = gg_rct_NightelfHeroMainBase
        
        /*
         * Random Circle
         */
        //Undead Random Circle
        set HERO_PICK_RANDOM_RECT[0]  = gg_rct_HeroRandom01
        set HERO_PICK_RANDOM_RECT[1]  = gg_rct_HeroRandom02
        
        //Behemot
        //Circle
        set HERO_PICK_RECT[0]  = gg_rct_HeroPick1
        //save Revive Position (x/y)
        set HERO_REPICK_RECT[0][0] = GetRectCenterX(gg_rct_HeroRevive1)
        set HERO_REPICK_RECT[0][1] = GetRectCenterY(gg_rct_HeroRevive1)
        //Abilities
        set HERO_ABILITIES[0][0] = 'A05J' //Explosive Tantrum
        set HERO_ABILITIES[0][1] = 'A00D' //Beast Stomp
        set HERO_ABILITIES[0][2] = 'A07B' //Roar
        set HERO_ABILITIES[0][3] = 'A02L' //Adrenaline Rush
        
        //Nerubian Widow
        set HERO_PICK_RECT[1]  = gg_rct_HeroPick2
        set HERO_REPICK_RECT[1][0] = GetRectCenterX(gg_rct_HeroRevive2)
        set HERO_REPICK_RECT[1][1] = GetRectCenterY(gg_rct_HeroRevive2)
        set HERO_ABILITIES[1][0] = 'A004' //Adolescence
        set HERO_ABILITIES[1][1] = 'A005' //Spider Web
        set HERO_ABILITIES[1][2] = 'A024' //Sprint
        set HERO_ABILITIES[1][3] = 'A003' //Widow Bite
        
        //Ice Avatar
        set HERO_PICK_RECT[2]  = gg_rct_HeroPick3
        set HERO_REPICK_RECT[2][0] = GetRectCenterX(gg_rct_HeroRevive3)
        set HERO_REPICK_RECT[2][1] = GetRectCenterY(gg_rct_HeroRevive3)
        set HERO_ABILITIES[2][0] = 'A04J' //Ice Tornado
        set HERO_ABILITIES[2][1] = 'A0AF' //Freezing Breath
        set HERO_ABILITIES[2][2] = 'A04Q' //Frost Aura
        set HERO_ABILITIES[2][3] = 'A04M' //Fog of Death
        
        //Ghoul
        set HERO_PICK_RECT[3]  = gg_rct_HeroPick4
        set HERO_REPICK_RECT[3][0] = GetRectCenterX(gg_rct_HeroRevive4)
        set HERO_REPICK_RECT[3][1] = GetRectCenterY(gg_rct_HeroRevive4)
        set HERO_ABILITIES[3][0] = 'A04N' //Claws Attack
        set HERO_ABILITIES[3][1] = 'A04R' //Cannibalize
        set HERO_ABILITIES[3][2] = 'A04T' //Flesh Wound
        set HERO_ABILITIES[3][3] = 'A04U' //Rage
        
        //Master Banshee
        set HERO_PICK_RECT[4]  = gg_rct_HeroPick5
        set HERO_REPICK_RECT[4][0] = GetRectCenterX(gg_rct_HeroRevive5)
        set HERO_REPICK_RECT[4][1] = GetRectCenterY(gg_rct_HeroRevive5)
        set HERO_ABILITIES[4][0] = 'A04V' //Dark Obedience
        set HERO_ABILITIES[4][1] = 'A04W' //Spirit Burn
        set HERO_ABILITIES[4][2] = 'A04S' //Cursed Soul
        set HERO_ABILITIES[4][3] = 'A04Y' //Barrage
        
        //Death Marcher
        set HERO_PICK_RECT[5]  = gg_rct_HeroPick6
        set HERO_REPICK_RECT[5][0] = GetRectCenterX(gg_rct_HeroRevive6)
        set HERO_REPICK_RECT[5][1] = GetRectCenterY(gg_rct_HeroRevive6)
        set HERO_ABILITIES[5][0] = 'A04Z' //Death Pact
        set HERO_ABILITIES[5][1] = 'A00I' //Soul Trap
        set HERO_ABILITIES[5][2] = 'A04X' //Mana Concentration
        set HERO_ABILITIES[5][3] = 'A053' //Boiling Blood
        
        //Skeleton Mage
        set HERO_PICK_RECT[6]  = gg_rct_HeroPick7
        set HERO_REPICK_RECT[6][0] = GetRectCenterX(gg_rct_HeroRevive7)
        set HERO_REPICK_RECT[6][1] = GetRectCenterY(gg_rct_HeroRevive7)
        set HERO_ABILITIES[6][0] = 'A054' //Plague Infection
        set HERO_ABILITIES[6][1] = 'A056' //Soul Extraction
        set HERO_ABILITIES[6][2] = 'A058' //Spawn Zombies
        set HERO_ABILITIES[6][3] = 'A05B' //Call of the Damned
        
        //Master Necromancer
        set HERO_PICK_RECT[7]  = gg_rct_HeroPick8
        set HERO_REPICK_RECT[7][0] = GetRectCenterX(gg_rct_HeroRevive8)
        set HERO_REPICK_RECT[7][1] = GetRectCenterY(gg_rct_HeroRevive8)
        set HERO_ABILITIES[7][0] = 'A05D' //Necromancy
        set HERO_ABILITIES[7][1] = 'A09N' //Malicious Curse
        set HERO_ABILITIES[7][2] = 'A068' //Despair
        set HERO_ABILITIES[7][3] = 'A08Z' //Dead Souls
        
        //Crypt Lord
        set HERO_PICK_RECT[8]  = gg_rct_HeroPick9
        set HERO_REPICK_RECT[8][0] = GetRectCenterX(gg_rct_HeroRevive9)
        set HERO_REPICK_RECT[8][1] = GetRectCenterY(gg_rct_HeroRevive9)
        set HERO_ABILITIES[8][0] = 'A06A' //Burrow Strike
        set HERO_ABILITIES[8][1] = 'A06E' //Burrow Move
        set HERO_ABILITIES[8][2] = 'A06F' //Carrion Swarm
        set HERO_ABILITIES[8][3] = 'A06H' //Metamorphosis
        
        //Abomination
        set HERO_PICK_RECT[9]  = gg_rct_HeroPick10
        set HERO_REPICK_RECT[9][0] = GetRectCenterX(gg_rct_HeroRevive10)
        set HERO_REPICK_RECT[9][1] = GetRectCenterY(gg_rct_HeroRevive10)
        set HERO_ABILITIES[9][0] = 'A064' //Cleave
        set HERO_ABILITIES[9][1] = 'A06M' //Consume himself
        set HERO_ABILITIES[9][2] = 'A06G' //Plague Cloud
        set HERO_ABILITIES[9][3] = 'A06L' //Snack
        
        //Destroyer
        set HERO_PICK_RECT[10]  = gg_rct_HeroPick11
        set HERO_REPICK_RECT[10][0] = GetRectCenterX(gg_rct_HeroRevive11)
        set HERO_REPICK_RECT[10][1] = GetRectCenterY(gg_rct_HeroRevive11)
        set HERO_ABILITIES[10][0] = 'A06N' //Arcane Swap
        set HERO_ABILITIES[10][1] = 'A06O' //Mind Burst
        set HERO_ABILITIES[10][2] = 'A06R' //Mana Steal
        set HERO_ABILITIES[10][3] = 'A06Q' //Release Mana
        
        //Dread Lord
        set HERO_PICK_RECT[11]  = gg_rct_HeroPick12
        set HERO_REPICK_RECT[11][0] = GetRectCenterX(gg_rct_HeroRevive12)
        set HERO_REPICK_RECT[11][1] = GetRectCenterY(gg_rct_HeroRevive12)
        set HERO_ABILITIES[11][0] = 'A06V' //Vampire Blood
        set HERO_ABILITIES[11][1] = 'A0B2' //Purify
        set HERO_ABILITIES[11][2] = 'A06T' //Sleepy Dust
        set HERO_ABILITIES[11][3] = 'A06Z' //Night Dome
        
        //Archmage
        set HERO_PICK_RECT[12]  = gg_rct_HeroPick14
        set HERO_REPICK_RECT[12][0] = GetRectCenterX(gg_rct_HeroRevive14)
        set HERO_REPICK_RECT[12][1] = GetRectCenterY(gg_rct_HeroRevive14)
        set HERO_ABILITIES[12][0] = 'A076' //Holy Chain
        set HERO_ABILITIES[12][1] = 'A07N' //Trappy Swap
        set HERO_ABILITIES[12][2] = 'A07M' //Refreshing Aura
        set HERO_ABILITIES[12][3] = 'A07K' //Fireworks
        
        //Tauren Chieftain
        set HERO_PICK_RECT[13]  = gg_rct_HeroPick15
        set HERO_REPICK_RECT[13][0] = GetRectCenterX(gg_rct_HeroRevive15)
        set HERO_REPICK_RECT[13][1] = GetRectCenterY(gg_rct_HeroRevive15)
        set HERO_ABILITIES[13][0] = 'A078' //Fire Totem
        set HERO_ABILITIES[13][1] = 'A079' //Stomp Blaster
        set HERO_ABILITIES[13][2] = 'A08M' //Fervor
        set HERO_ABILITIES[13][3] = 'A07C' //Shockwave
        
        //Priestess of the Moon
        set HERO_PICK_RECT[14]  = gg_rct_HeroPick16
        set HERO_REPICK_RECT[14][0] = GetRectCenterX(gg_rct_HeroRevive16)
        set HERO_REPICK_RECT[14][1] = GetRectCenterY(gg_rct_HeroRevive16)
        set HERO_ABILITIES[14][0] = 'A0B5' //Life Vortex
        set HERO_ABILITIES[14][1] = 'A07F' //Moon Light
        set HERO_ABILITIES[14][2] = 'A07G' //Night Aura
        set HERO_ABILITIES[14][3] = 'A07H' //Revenge Owl
        
        //Naga Matriarch
        set HERO_PICK_RECT[15]  = gg_rct_HeroPick17
        set HERO_REPICK_RECT[15][0] = GetRectCenterX(gg_rct_HeroRevive17)
        set HERO_REPICK_RECT[15][1] = GetRectCenterY(gg_rct_HeroRevive17)
        set HERO_ABILITIES[15][0] = 'A07O' //Tidal Shield
        set HERO_ABILITIES[15][1] = 'A07P' //Impaling Spine
        set HERO_ABILITIES[15][2] = 'A07R' //Crushing Wave
        set HERO_ABILITIES[15][3] = 'A07S' //Maelstrom
        
        //Orcish Warlock
        set HERO_PICK_RECT[16]  = gg_rct_HeroPick18
        set HERO_REPICK_RECT[16][0] = GetRectCenterX(gg_rct_HeroRevive18)
        set HERO_REPICK_RECT[16][1] = GetRectCenterY(gg_rct_HeroRevive18)
        set HERO_ABILITIES[16][0] = 'A07T' //Thunderbolt
        set HERO_ABILITIES[16][1] = 'A07U' //Spirit Link
        set HERO_ABILITIES[16][2] = 'A07W' //Mana Ward
        set HERO_ABILITIES[16][3] = 'A07Y' //Dark Summoning
        
        //Farseer
        set HERO_PICK_RECT[17]  = gg_rct_HeroPick19
        set HERO_REPICK_RECT[17][0] = GetRectCenterX(gg_rct_HeroRevive19)
        set HERO_REPICK_RECT[17][1] = GetRectCenterY(gg_rct_HeroRevive19)
        set HERO_ABILITIES[17][0] = 'A09D' //Lightning Balls
        set HERO_ABILITIES[17][1] = 'A09E' //Volty Crush
        set HERO_ABILITIES[17][2] = 'A09G' //Reflective Shield
        set HERO_ABILITIES[17][3] = 'A09J' //Spirit Arrows
        
        //Fire Panda
        set HERO_PICK_RECT[18]  = gg_rct_HeroPick20
        set HERO_REPICK_RECT[18][0] = GetRectCenterX(gg_rct_HeroRevive20)
        set HERO_REPICK_RECT[18][1] = GetRectCenterY(gg_rct_HeroRevive20)
        set HERO_ABILITIES[18][0] = 'A08S' //Hack'n Slash
        set HERO_ABILITIES[18][1] = 'A08X' //High Jump
        set HERO_ABILITIES[18][2] = 'A08Y' //Bladethrow
        set HERO_ABILITIES[18][3] = 'A08U' //Art of Fire
        
        //Mountain Giant
        set HERO_PICK_RECT[19]  = gg_rct_HeroPick21
        set HERO_REPICK_RECT[19][0] = GetRectCenterX(gg_rct_HeroRevive21)
        set HERO_REPICK_RECT[19][1] = GetRectCenterY(gg_rct_HeroRevive21)
        set HERO_ABILITIES[19][0] = 'A097' //Crag
        set HERO_ABILITIES[19][1] = 'A098' //Hurl Boulder
        set HERO_ABILITIES[19][2] = 'A099' //Craggy Exterior
        set HERO_ABILITIES[19][3] = 'A09B' //Endurance
        
        //Cenarius
        set HERO_PICK_RECT[20]  = gg_rct_HeroPick22
        set HERO_REPICK_RECT[20][0] = GetRectCenterX(gg_rct_HeroRevive22)
        set HERO_REPICK_RECT[20][1] = GetRectCenterY(gg_rct_HeroRevive22)
        set HERO_ABILITIES[20][0] = 'A08D' //Natural Sphere
        set HERO_ABILITIES[20][1] = 'A08F' //Magic Seed
        set HERO_ABILITIES[20][2] = 'A08G' //Pollen Aura
        set HERO_ABILITIES[20][3] = 'A08J' //Leaf Storm
        
        //Paladin
        set HERO_PICK_RECT[21]  = gg_rct_HeroPick23
        set HERO_REPICK_RECT[21][0] = GetRectCenterX(gg_rct_HeroRevive23)
        set HERO_REPICK_RECT[21][1] = GetRectCenterY(gg_rct_HeroRevive23)
        set HERO_ABILITIES[21][0] = 'A08K' //God's Seal
        set HERO_ABILITIES[21][1] = 'A08O' //Star Impact
        set HERO_ABILITIES[21][2] = 'A08P' //Holy Strike
        set HERO_ABILITIES[21][3] = 'A08R' //Holy Cross
        
        //Royal Knight
        set HERO_PICK_RECT[22]  = gg_rct_HeroPick24
        set HERO_REPICK_RECT[22][0] = GetRectCenterX(gg_rct_HeroRevive24)
        set HERO_REPICK_RECT[22][1] = GetRectCenterY(gg_rct_HeroRevive24)
        set HERO_ABILITIES[22][0] = 'A080' //Battle Fury
        set HERO_ABILITIES[22][1] = 'A08A' //Shattering Javelin
        set HERO_ABILITIES[22][2] = 'A081' //Animal War Training
        set HERO_ABILITIES[22][3] = '0000' //Charge
        
        //Dark Ranger
        set HERO_PICK_RECT[23]  = gg_rct_HeroPick13
        set HERO_REPICK_RECT[23][0] = GetRectCenterX(gg_rct_HeroRevive13)
        set HERO_REPICK_RECT[23][1] = GetRectCenterY(gg_rct_HeroRevive13)
        set HERO_ABILITIES[23][0] = 'A071' //Ghost Form
        set HERO_ABILITIES[23][1] = 'A072' //Crippling Arrow
        set HERO_ABILITIES[23][2] = 'A06X' //Snipe
        set HERO_ABILITIES[23][3] = 'A0B4' //Coup de Grace
        
        //Blood Mage
        set HERO_PICK_RECT[24]  = gg_rct_HeroPick25
        set HERO_REPICK_RECT[24][0] = GetRectCenterX(gg_rct_HeroRevive25)
        set HERO_REPICK_RECT[24][1] = GetRectCenterY(gg_rct_HeroRevive25)
        set HERO_ABILITIES[24][0] = 'A091' //Fire Blast
        set HERO_ABILITIES[24][1] = 'A094' //Boon and Bane
        set HERO_ABILITIES[24][2] = 'A092' //Burning Skin
        set HERO_ABILITIES[24][3] = 'A096' //Fire Storm
        
        //Ogre Warrior
        set HERO_PICK_RECT[25]  = gg_rct_HeroPick26
        set HERO_REPICK_RECT[25][0] = GetRectCenterX(gg_rct_HeroRevive26)
        set HERO_REPICK_RECT[25][1] = GetRectCenterY(gg_rct_HeroRevive26)
        set HERO_ABILITIES[25][0] = 'A09H' //Axe Throw
        set HERO_ABILITIES[25][1] = 'A09K' //Decapitate
        set HERO_ABILITIES[25][2] = 'A09I' //Might Swing
        set HERO_ABILITIES[25][3] = 'A09M' //Consumption
        
        //Giant Turtle
        set HERO_PICK_RECT[26]  = gg_rct_HeroPick27
        set HERO_REPICK_RECT[26][0] = GetRectCenterX(gg_rct_HeroRevive27)
        set HERO_REPICK_RECT[26][1] = GetRectCenterY(gg_rct_HeroRevive27)
        set HERO_ABILITIES[26][0] = 'A082' //Surf
        set HERO_ABILITIES[26][1] = 'A083' //Fountain Blast
        set HERO_ABILITIES[26][2] = 'A086' //Scaled Shell
        set HERO_ABILITIES[26][3] = 'A087' //Aqua Shield
		
        /*
         * Start Positions for Acolyts, Peons & Co.
         */
        set PICK_UNIT_START_POS_X[0] =  GetRectCenterX(gg_rct_UDHeroPickStart)
        set PICK_UNIT_START_POS_Y[0] =  GetRectCenterY(gg_rct_UDHeroPickStart)
        set PICK_UNIT_START_POS_X[1] =  GetRectCenterX(gg_rct_INFHeroPickStart)
        set PICK_UNIT_START_POS_Y[1] =  GetRectCenterY(gg_rct_INFHeroPickStart)
    endfunction
    
    //Abilities to be preloaded...
    private function AbilityPreload takes nothing returns nothing
        local integer i = 0
        local integer j = 0
        
        loop
            exitwhen i > MAX_HEROES
            loop
                exitwhen j > 3
                call  XE_PreloadAbility( GET_HERO_ABILITY(i,j) )
                set j = j + 1
            endloop
            set i = i + 1
            set j = 0
        endloop
    endfunction
    
    private function filter takes nothing returns boolean
        return IsUnitType(GetFilterUnit(), UNIT_TYPE_HERO) and GetOwningPlayer(GetFilterUnit()) == Player(PLAYER_NEUTRAL_PASSIVE)
    endfunction
    
    private function callback takes nothing returns nothing
        call SetUnitLifePercentBJ(  GetEnumUnit(), 100 )
        call SetUnitManaPercentBJ(  GetEnumUnit(), 100 )
    endfunction
    
    //Setzt HP+Mana der ausw?hlbaren Helden auf 100%
    private function ResetHpAndMana takes nothing returns nothing
        local group g = NewGroup()
        
        call GroupEnumUnitsInRect(g, GetPlayableMapRect(), function filter)
        call ForGroup( g, function callback )
        call ReleaseGroup(g)
    endfunction
    
    private function Cleaner takes nothing returns nothing
        call ClearTextMessages()
        loop
            set hero = FirstOfGroup(selectableHeroes)
            exitwhen hero == null
            call GroupRemoveUnit(selectableHeroes, hero)
        endloop
    
        call ReleaseGroup(selectableHeroes)
        set selectableHeroes = null
    endfunction
    
    private function StopOrders takes nothing returns nothing
        local integer id = GetIssuedOrderId()
        
        set hero = GetTriggerUnit()
        if id == 851972 or id == CHOOSE_HERO_ORDER_ID then
            return
        endif
        
        call DisableTrigger(orders)
        call PauseUnit( hero, true)
        call IssueImmediateOrder( hero, "stop" )
        call PauseUnit( hero, false) 
        call EnableTrigger(orders)
    endfunction
    
    private function FilterHeroes takes nothing returns boolean
        return IsUnitType(GetFilterUnit() , UNIT_TYPE_HERO)
    endfunction
    
    private function SetupHeroes takes nothing returns nothing
        set hero = GetEnumUnit()
        call UnitRemoveAbility(hero, 'Amov')
        call UnitAddAbility(hero, 'Abun')
        call UnitAddAbility(hero,'Asud') 
        call SetUnitInvulnerable(hero, true)  
        
        call TriggerRegisterUnitEvent( orders, hero, EVENT_UNIT_ISSUED_TARGET_ORDER )
        call TriggerRegisterUnitEvent( orders, hero, EVENT_UNIT_ISSUED_POINT_ORDER )
        call TriggerRegisterUnitEvent( orders, hero, EVENT_UNIT_ISSUED_ORDER ) 
    endfunction
    
    private function InitDisableAbilities takes unit u returns nothing
        local integer i = 0
        
        set selectableHeroes = NewGroup()
        if u == null then
            call GroupEnumUnitsOfPlayer(selectableHeroes, Player(15), Condition(function FilterHeroes))
        else
            call GroupAddUnit(selectableHeroes, u)
        endif
        
        call TriggerAddAction(orders, function StopOrders)
        call ForGroup(selectableHeroes, function SetupHeroes)
        
        /* Diese Schleife nicht entfernen, sonst sind die F?higkeiten bei den Auswahl Helden nicht da */
        loop
            exitwhen i >= bj_MAX_PLAYERS
            if Game.isPlayerInGame(i) then
                call SetPlayerAlliance(Player(PLAYER_NEUTRAL_PASSIVE), Player(i), ALLIANCE_SHARED_CONTROL, true)
                //call SetPlayerAlliance(Player(15),Player(i), ALLIANCE_SHARED_VISION,false)
            endif
            set i = i + 1
        endloop
        
        call Cleaner()
    endfunction
    
    function DISABLE_ABILITIES_FOR_HERO takes unit u returns nothing
        call InitDisableAbilities(u)
    endfunction
    
    private function Initialize takes nothing returns nothing
        // Ability Preload
        static if ABILITY_PRELOAD then
            call AbilityPreload()
        endif
    endfunction
    
    private function Actions takes nothing returns nothing
         call MainSetup()
         call ResetHpAndMana()
         call Initialize()
         call InitDisableAbilities(null)
    endfunction
	
	struct HeroPickInit
	
		static method initialize takes nothing returns nothing
			call Actions()
		endmethod
	
	endstruct

endscope
