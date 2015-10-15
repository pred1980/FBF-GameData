scope UnitBountySystem

    /*
     * Hier einfach alle Einheiten erfassen, die einen Bounty Wert beim Kill
     * ausspielen sollen
     * INFO: In der HT DATA, sind in Spalte 0 alle Einheiten drin f?r die es Bounty beim Kill gibt
     *       w?hrend in Spalte 1 alle die Einheiten drin sind, für die es beim Kill kein Bounty gibt (z.b. ein Dummy)
     */
	globals
		//Human
		//Reformed Bandit
		private constant integer REFORMED_BANDIT_ID = 'n00R'
		
        //Orc
		//Aldarii General
		private constant integer ALDARII_GENERAL_ID = 'o00F'
		
        //Nightelf
		//Panther Rider
		private constant integer PANTHER_RIDER_ID = 'e00S'
		
        /*
         * Undead
         */
        //Hero: Nerubian Widow --> Abi: Adolescence
        private constant integer NERUBIAN_CHILD_ID = 'n00C'
		
        //Hero: Skeleton Mage --> Spawn Zombies
        private constant integer ZOMBIE_ID_0 = 'zom0'
        private constant integer ZOMBIE_ID_1 = 'zom1'
        private constant integer ZOMBIE_ID_2 = 'zom2'
        private constant integer ZOMBIE_ID_3 = 'zom3'
        private constant integer ZOMBIE_ID_4 = 'zom4'
        
        //Hero: Crypt Lord
        private constant integer GRUB1_ID = 'h013'
        private constant integer GRUB2_ID = 'h007'
        private constant integer GRUB3_ID = 'h00A'
        private constant integer GRUB4_ID = 'h00B'
        private constant integer GRUB5_ID = 'h00D'
        private constant integer COCOON_ID = 'h00E'
        private constant integer BEETLE1_ID = 'h00F'
        private constant integer BEETLE2_ID = 'h00H'
        private constant integer BEETLE3_ID = 'h00I'
        private constant integer BEETLE4_ID = 'h00J'
        private constant integer BEETLE5_ID = 'h00K'
        
        //Titan Devourer
        private constant integer TITAN_ID = 'e00C'
        
        //Graveyard Zombies
        private constant integer ZOMBIE_SMALL = 'n00D'
        private constant integer ZOMBIE_MEDIUM = 'n00E'
        private constant integer ZOMBIE_LARGE = 'n00F'
		private constant integer SKELETON_1 = 'u020'
		private constant integer SKELETON_2 = 'u022'
		private constant integer SKELETON_3 = 'u023'
		private constant integer SKELETON_4 = 'u024'
		private constant integer SKELETON_5 = 'u025'
		
        //Warden ( Warden System )
        private constant integer WARDEN_ID = 'u02A'
        
        //King Marco Mithas
        private constant integer KING_MARCO_MITHAS_SMALL = 'U02C'
        private constant integer KING_MARCO_MITHAS_MEDIUM = 'U02D'
        private constant integer KING_MARCO_MITHAS_LARGE = 'U02E'
        
        //Brood Mother + Childs
        private constant integer SPIDER_ID = 'n00G'
        private constant integer MALE_ID = 'n00I'
        private constant integer FEMALE_ID = 'n00H'
		
		//Archnathid (Scorpion)
		private constant integer ARCHNATHID_ID = 'n00L'
		
		//Roach
		private constant integer ROACH_ID = 'u00B'
        
        /********************************************
         *           E X C E P T I O N S            *
         ********************************************/
        private constant integer XE_DUMMY = 'e00J'
        private constant integer CD_UNIT_ID = 'h00R' //Custom Aura System
        private constant integer SPELL_DUMMY = 'e00E'
        
        //Human
		private constant integer PEASANT_ID = 'h00C'
        
        /*** Orc ***/
		private constant integer PEON_ID = 'o00G'
        private constant integer SHOCKWAVE_DUMMY_ID = 'u00C'
        private constant integer FIRE_TOTEM_ID = 'o001'
        
        //Dark Summoning
        private constant integer CHANNELING_DEMON_ID = 'n000'
        //Mana Ward
        private constant integer MANA_WARD_ID = 'o00D'
        
        /*** Nightelf ***/
        private constant integer WISP_ID = 'e002'
        
        //Revenge Owl
        private constant integer OWL_ID = 'h00T'
        private constant integer MISSILE_ID = 'h00U'
        private constant integer OWL_DUMMY_ID = 'h00V'
        private constant integer OWL_MISSILE_ID = 'h00V'
        private constant integer EFFECT_UNIT_ID = 'h00S'
        
        private constant integer MOON_ID = 'h017' //Moonlight
        
        /* Naga */
        private constant integer CRUCHING_WAVE_EFFECT_ID = 'u00E'
        
        //Web System
        private constant integer WEB_SMALL = 'e008'
        private constant integer WEB_MEDIUM = 'e00A'
        private constant integer WEB_LARGE = 'e00B'
        
        //Hero: Nerubian Widow
        //Abi: Adolescence
        private constant integer EGG_ID = 'o00R'
        //Abi: Spider Web
        private constant integer SPIDER_WEB = 'h016'
        
        //Hero: Ghoul
        //Flesh Wound
        private constant integer FLESH_WOUND_DUMMY_ID = 'e00F'
        
        //Hero: Ice Avatar
        private constant integer FREEZING_BREATH_DUMMY_ID = 'e00Q'
        
        //Hero: Death Marcher
        private constant integer SOUL_TRAP_DUMMY_ID = 'e00R'
        
        //Hero: Master Necromancer
        private constant integer NECROMANCY_DUMMY_ID = 'e00S'
        private constant integer MALICIOUS_CURSE_DUMMY_ID = 'e00T'
        
        //Hero: Destroyer
        private constant integer MIND_BURST_DUMMY_ID = 'e00U'
        private constant integer RELEASE_MANA_DUMMY_ID = 'e00V'
        
        //Hero: Dread Lord
        private constant integer VAMPIRE_BLOOD_DUMMY_ID = 'e00W'
        private constant integer PURIFY_DUMMY_ID = 'e00X'
        private constant integer SLEEPY_DUST_DUMMY_ID = 'e00Y'
        
        //Hero: Dark Ranger
        private constant integer CRIPPLING_ARROW_DUMMY_ID = 'e00Z'
        
        /*
         * Coalition
         */
         
        //Hero: Blood Mage
        private constant integer FIRE_STORM_DUMMY_ID = 'e010'
        
        private constant integer ACOLYTE_ID = 'u002'
        
        //Brood Mother's Egg
        private constant integer BM_EGG_ID = 'o00C'
		
		//Tower Ability "Corpse Explosion"
		private constant integer SKELETON_WARRIOR = 'uske'
        
        //Meteor System
        private constant integer METEOR_SYSTEM_DUMMY = 'e00O'
        
        /*
         * Items
         */
        private constant integer SHAMAN_HOOD_DUMMY_ID = 'e00G'
        private constant integer SEEING_STAFF_DUMMY_ID = 'e00H'
        private constant integer CROWBAR_DUMMY_ID = 'e00I'
        private constant integer NETHER_CHARGE_DUMMY_ID = 'e00L'
        private constant integer EVERYOUNG_LEAF_DUMMY_ID = 'e00M'
        private constant integer MOON_GUARD_ROBE_DUMMY_ID = 'e00N'
        
        //*********************\\
        private hashtable DATA = InitHashtable()
    endglobals

	struct Unit
        
        static method getBounty takes unit u returns integer
            return S2I(getDataFromString(LoadStr(DATA, 0, GetUnitTypeId(u)), GameType.getCurrentMode()))
        endmethod
        
        static method isExceptionUnit takes unit u returns boolean
            return LoadBoolean(DATA, 1, GetUnitTypeId(u))
        endmethod
    
    endstruct
	
	private function Actions takes nothing returns nothing
		//Speicher den Bounty Wert je nach GameType (GameConfig) in der Spalte 0
        //in der Reihe der Unit_Id
		
        //Nerubian Widow
        call SaveStr(DATA, 0, NERUBIAN_CHILD_ID, "3,")
        
        //Skeleton Mage
        call SaveStr(DATA, 0, ZOMBIE_ID_0, "2,")
        call SaveStr(DATA, 0, ZOMBIE_ID_1, "4,")
        call SaveStr(DATA, 0, ZOMBIE_ID_2, "6,")
        call SaveStr(DATA, 0, ZOMBIE_ID_3, "8,")
        call SaveStr(DATA, 0, ZOMBIE_ID_4, "10,")
        
        //Crypt Lord
        call SaveStr(DATA, 0, GRUB1_ID, "1,")
        call SaveStr(DATA, 0, GRUB2_ID, "2,")
        call SaveStr(DATA, 0, GRUB3_ID, "3,")
        call SaveStr(DATA, 0, GRUB4_ID, "4,")
        call SaveStr(DATA, 0, GRUB4_ID, "5,")
        call SaveStr(DATA, 0, COCOON_ID, "1,")
        call SaveStr(DATA, 0, BEETLE1_ID, "2,")
        call SaveStr(DATA, 0, BEETLE2_ID, "4,")
        call SaveStr(DATA, 0, BEETLE3_ID, "6,")
        call SaveStr(DATA, 0, BEETLE4_ID, "8,")
        call SaveStr(DATA, 0, BEETLE5_ID, "10,")
        
        //Titan Devourer
        call SaveStr(DATA, 0, TITAN_ID, "250,")
        
        //Graveyard Zombies
        call SaveStr(DATA, 0, ZOMBIE_SMALL, "3,")
        call SaveStr(DATA, 0, ZOMBIE_MEDIUM, "3,")
        call SaveStr(DATA, 0, ZOMBIE_LARGE, "9,")
		call SaveStr(DATA, 0, SKELETON_1, "1,")
		call SaveStr(DATA, 0, SKELETON_2, "2,")
		call SaveStr(DATA, 0, SKELETON_3, "3,")
		call SaveStr(DATA, 0, SKELETON_4, "4,")
		call SaveStr(DATA, 0, SKELETON_5, "5,")
        
        //Warden ( Warden System )
        call SaveStr(DATA, 0, WARDEN_ID, "75,")
        
        //King Marco Mithas
        call SaveStr(DATA, 0, KING_MARCO_MITHAS_SMALL, "200,")
        call SaveStr(DATA, 0, KING_MARCO_MITHAS_MEDIUM, "300,")
        call SaveStr(DATA, 0, KING_MARCO_MITHAS_LARGE, "400,")
        
        //Brood Mother + Childs
        call SaveStr(DATA, 0, SPIDER_ID, "250,")
        call SaveStr(DATA, 0, MALE_ID, "45,")
        call SaveStr(DATA, 0, FEMALE_ID, "45,")
		
		//Archnathid (Scorpion)
		call SaveStr(DATA, 0, ARCHNATHID_ID, "75,")
		
		//Roach
		call SaveStr(DATA, 0, ROACH_ID, "3,")
		
		//Reformed Bandit
		call SaveStr(DATA, 0, REFORMED_BANDIT_ID, "3,")
		
        //Aldarii General
		call SaveStr(DATA, 0, ALDARII_GENERAL_ID, "3,")
		
        //Panther Rider
		call SaveStr(DATA, 0, PANTHER_RIDER_ID, "3,")
		
        /*
         * Ausnahmen: Einheiten, wie Dummys, die gekillt werden aber keinen Bounty haben sollen nicht berücksichtigt
         *            werden! Ausnahmen kommen in Spalte 1
         */
        call SaveBoolean(DATA, 1, XE_DUMMY, true)
        call SaveBoolean(DATA, 1, ACOLYTE_ID, true)
        call SaveBoolean(DATA, 1, PEASANT_ID, true)
        call SaveBoolean(DATA, 1, PEON_ID, true)
        call SaveBoolean(DATA, 1, WISP_ID, true)
        call SaveBoolean(DATA, 1, WEB_SMALL, true)
        call SaveBoolean(DATA, 1, WEB_MEDIUM, true)
        call SaveBoolean(DATA, 1, WEB_LARGE, true)
        call SaveBoolean(DATA, 1, SPIDER_WEB, true)
        call SaveBoolean(DATA, 1, EGG_ID, true)
        call SaveBoolean(DATA, 1, BM_EGG_ID, true)
		call SaveBoolean(DATA, 1, SKELETON_WARRIOR, true)
        call SaveBoolean(DATA, 1, SHOCKWAVE_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, FIRE_TOTEM_ID, true)
        call SaveBoolean(DATA, 1, CD_UNIT_ID, true)
        call SaveBoolean(DATA, 1, SPELL_DUMMY, true)
        call SaveBoolean(DATA, 1, OWL_ID, true)
        call SaveBoolean(DATA, 1, MISSILE_ID, true)
        call SaveBoolean(DATA, 1, OWL_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, EFFECT_UNIT_ID, true)
        call SaveBoolean(DATA, 1, MOON_ID, true)
        call SaveBoolean(DATA, 1, CRUCHING_WAVE_EFFECT_ID, true)
        call SaveBoolean(DATA, 1, CHANNELING_DEMON_ID, true)
        call SaveBoolean(DATA, 1, MANA_WARD_ID, true)
        call SaveBoolean(DATA, 1, FLESH_WOUND_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, SHAMAN_HOOD_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, SEEING_STAFF_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, CROWBAR_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, NETHER_CHARGE_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, EVERYOUNG_LEAF_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, MOON_GUARD_ROBE_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, METEOR_SYSTEM_DUMMY, true)
        call SaveBoolean(DATA, 1, FREEZING_BREATH_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, SOUL_TRAP_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, NECROMANCY_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, MALICIOUS_CURSE_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, MIND_BURST_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, RELEASE_MANA_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, VAMPIRE_BLOOD_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, PURIFY_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, SLEEPY_DUST_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, CRIPPLING_ARROW_DUMMY_ID, true)
        call SaveBoolean(DATA, 1, FIRE_STORM_DUMMY_ID, true)
    
	endfunction
	
	struct UnitSystem
	
		static method initialize takes nothing returns nothing
			call Actions()
		endmethod
	
	endstruct
    
endscope