scope Items

    globals
        /*
         * Global Items for all Races
         */
        // ITEM_CLASS_BASIC: for all Potion Shops for all Races
        Item HEALING_POTION = 0
        Item MANA_POTION = 0
        Item HEALING_ELEXIR = 0
        Item MANA_ELEXIR = 0
        Item ANTI_MAGIC_POTION = 0
        Item INVULNERABILITY_POTION = 0
        Item POTION_OF_INVISIBILITY = 0
        Item SPEED_UP_POTION = 0
		Item TELEPORT_STONE = 0
		Item TALISMAN_OF_TRANSLOCATION = 0
        
        /*
         * Undead Items
         */
        //ITEM_CLASS_ADVANCED: Undead
        Item BONE_HELMET = 0
        Item BELT_OF_GIANT_STRENGTH = 0
        Item DARK_PLATES = 0
        Item PLATE_GLOVE = 0
        Item BLOOD_BLADE = 0
        Item SPIDER_BRACELET = 0
        Item TWIN_AXE = 0
        Item FRENZY_BOOTS = 0
        Item RUNIC_CHARM = 0
        Item CURSED_ROBE = 0
        Item UNHOLY_ICON = 0
        Item SKULL_ROD = 0
        
        //ITEM_CLASS_ANCIENT: Undead
        Item BLOOD_PLATE_ARMOR = 0
        Item DEMONIC_AMULET = 0
        Item METAL_HAND = 0
        Item CORRUPTED_ICON = 0
        Item SPEAR_OF_VENGEANCE = 0
        Item MORNING_STAR = 0
        Item MAGIC_AXE = 0
        Item RAVING_SWORD = 0
        Item ARCANE_FLARE = 0
        Item NECROMANCERS_ROBE = 0
        Item BONE_CHARM = 0
        Item TEMPEST_SKULL = 0
        
        /*
         * Nightelf Items
         */
        //ITEM_CLASS_ADVANCED: Nightelf
        Item BARK_SKIN = 0
        Item TREANT_ROOT = 0
        Item ANCIENT_SHIELD = 0
        Item REINFORCED_GLOVE = 0
        Item SURAMAR_BLADE = 0
        Item SUN_BOW = 0
        Item HUNTRESS_STEEL = 0
        Item SCOUT_BOOTS = 0
        Item BOUND_WISP = 0
        Item DRUID_STAFF = 0
        Item MOON_BLOSSOM = 0
        Item CYCLONE_WAND = 0
        
        //ITEM_CLASS_ANCIENT: Nightelf
        Item TWILIGHT_ARMOR = 0
        Item MOON_GUARD_ROBE = 0
        Item MIDNIGHT_ARMOR = 0
        Item CHIMERA_BOOTS = 0
        Item DAWN_BOW = 0
        Item EMERALD_SWORD = 0
        Item DEMONSLAYER = 0
        Item WARDEN_CHAKRAM = 0
        Item KEEPER_STAFF = 0
        Item EVERYOUNG_LEAF = 0
        Item DRUID_BOOTS = 0
        Item ANTI_MAGIC_STAFF = 0
        
        /*
         * Human Items
         */
        //ITEM_CLASS_ADVANCED: Human
        Item SILVERMOON_SHIELD = 0
        Item GUARDIAN_HELMET = 0
        Item CHAINMAIL = 0
        Item SUNRAY_BLOSSOM = 0
        Item DWARVEN_HAMMER = 0
        Item FENCING_SWORD = 0
        Item TIME_AMULET = 0
        Item BOOTS_OF_QUEL_THALAS = 0
        Item TIGERS_EYE = 0
        Item POINTY_HAT = 0
        Item ARCANE_CIRCLET = 0
        Item ANTI_MAGIC_WAND = 0
        
        //ITEM_CLASS_ANCIENT: Human
        Item KNIGHT_HELMET = 0
        Item LUCKY_RING = 0
        Item STORMWIND_SHIELD = 0
        Item HOLY_SHIELD = 0
        Item WAR_FLAIL = 0
        Item VOLCANO_HAMMER = 0
        Item CROWBAR = 0
        Item SEVEN_LEAGUE_BOOTS = 0
        Item GRYPHONS_EYE = 0
        Item RUNESTONE = 0
        Item FIRE_WAND = 0
        Item SEEING_STAFF = 0
        
        /*
         * Orc Items
         */
        //ITEM_CLASS_ADVANCED: Orc
        Item BLOOD_STONE = 0
        Item SPIKED_COLLAR = 0
        Item OGRIMMAR_SHIELD = 0
        Item DARKSPEAR_MASK = 0
        Item BLACKROCK_AXE = 0
        Item TROLL_DAGGER = 0
        Item MACE = 0
        Item CENTAUR_BOOTS = 0
        Item PIPE = 0
        Item SHAMAN_GLOVE = 0
        Item WARSONG_DRUMS = 0
        Item THUNDER_RING = 0
        
        //ITEM_CLASS_ANCIENT: Orc
        Item BLACKROCK_ARMOR = 0
        Item KODO_VEST = 0
        Item SHAMAN_HOOD = 0
        Item DEFENSIVE_CHARM = 0
        Item ASSASSINS_DAGGER = 0
        Item BROAD_AXE = 0
        Item LONGSWORD = 0
        Item KODO_BOOTS = 0
        Item STONE_AMULET = 0
        Item FRENZY_RING = 0
        Item TAUREN_TOTEM = 0
        Item DRAGON_RING = 0
        
    endglobals

	struct Items
	
		static method initialize takes nothing returns nothing
			/*
			 * Init Global Items for all Races
			 */
			 // ITEM_CLASS_BASIC
			set HEALING_POTION = Item.create('I000', GetItemGold('I000'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNgreenAApotionGS.blp")
			set MANA_POTION = Item.create('I001', GetItemGold('I001'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNblueAApotionGS.blp")
			set HEALING_ELEXIR = Item.create('I003', GetItemGold('I003'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNgreenJApotionGS.blp")
			set MANA_ELEXIR = Item.create('I01R', GetItemGold('I01R'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNblueJApotionGS.blp")
			set ANTI_MAGIC_POTION = Item.create('I004', GetItemGold('I004'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTN_CR_PandaP3.blp")
			set INVULNERABILITY_POTION = Item.create('I005', GetItemGold('I005'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNPoTN_Sanctity_Potion.blp")
			set POTION_OF_INVISIBILITY = Item.create('I002', GetItemGold('I002'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNPotionred.blp")
			set SPEED_UP_POTION = Item.create('I006', GetItemGold('I006'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNPoTN_Chill_Potion.blp")
			set TELEPORT_STONE = Item.create('I00L', GetItemGold('I00L'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNGem_Of_Teleportation.blp")
			set TALISMAN_OF_TRANSLOCATION = Item.create('I00K', GetItemGold('I00K'), ITEM_CLASS_BASIC, null, "ReplaceableTextures\\CommandButtons\\BTNWAmulet.blp")
			 
			
			/*
			 * Init Undead Items
			 */
			//ITEM_CLASS_ADVANCED: Undead
			set BONE_HELMET = Item.create('I00D', GetItemGold('I00D'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNFemale_Wormskull15.blp")
			set BELT_OF_GIANT_STRENGTH = Item.create('I00B', GetItemGold('I00B'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNXUnholyStrength.blp")
			set DARK_PLATES = Item.create('I008', GetItemGold('I008'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNShoudlers.blp")
			set PLATE_GLOVE = Item.create('I00E', GetItemGold('I00E'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNImprovedUnholyStrength.blp")
			set BLOOD_BLADE = Item.create('I007', GetItemGold('I007'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNButcher_Axe.blp")
			set SPIDER_BRACELET = Item.create('I00A', GetItemGold('I00A'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNSpiderSilkBroach.blp")
			set TWIN_AXE = Item.create('I00G', GetItemGold('I00G'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNBoneStaff.blp")
			set FRENZY_BOOTS = Item.create('I00I', GetItemGold('I00I'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNDemonicBoots.blp")
			set RUNIC_CHARM = Item.create('I00C', GetItemGold('I00C'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNicyamulet copy.blp")
			set CURSED_ROBE = Item.create('I009', GetItemGold('I009'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNFelRunedCloakII.blp")
			set UNHOLY_ICON = Item.create('I00H', GetItemGold('I00H'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNSympozium.blp")
			set SKULL_ROD = Item.create('I00F', GetItemGold('I00F'), ITEM_CLASS_ADVANCED, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNWalloftheSoulless1.blp")
			
			//ITEM_CLASS_ANCIENT: Undead
			set BLOOD_PLATE_ARMOR = Item.create('I012', GetItemGold('I012'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNXBelt.blp")
			set DEMONIC_AMULET = Item.create('I00P', GetItemGold('I00P'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNAncientAmulet.blp")
			set METAL_HAND = Item.create('I010', GetItemGold('I010'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNElectric_Hand.blp")
			set CORRUPTED_ICON = Item.create('I00V', GetItemGold('I00V'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNXVoodooStaff.blp")
			set SPEAR_OF_VENGEANCE = Item.create('I014', GetItemGold('I014'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNBloodstoneAmulet.blp")
			set MORNING_STAR = Item.create('I00Y', GetItemGold('I00Y'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNMorningStar.blp")
			set MAGIC_AXE = Item.create('I016', GetItemGold('I016'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNStrangeAxe.blp")
			set RAVING_SWORD = Item.create('I00J', GetItemGold('I00J'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNbloodsword.blp")
			set ARCANE_FLARE = Item.create('I00R', GetItemGold('I00R'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNDemonic Artifact.blp")
			set NECROMANCERS_ROBE = Item.create('I00M', GetItemGold('I00M'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNcape.blp")
			set BONE_CHARM = Item.create('I018', GetItemGold('I018'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNRestless_Wall.blp")
			set TEMPEST_SKULL = Item.create('I00N', GetItemGold('I00N'), ITEM_CLASS_ANCIENT, RACE_UNDEAD, "ReplaceableTextures\\CommandButtons\\BTNSkullSepter.blp")
			
			/*
			 * Init Nightelf Items
			 */
			//ITEM_CLASS_ADVANCED: Nightelf
			set BARK_SKIN = Item.create('I03G', GetItemGold('I03G'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNEntangle.blp")
			set TREANT_ROOT = Item.create('I03F', GetItemGold('I03F'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNNatureArmor.BLP")
			set ANCIENT_SHIELD = Item.create('I03D', GetItemGold('I03D'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNshield_icon2.blp")
			set REINFORCED_GLOVE = Item.create('I03I', GetItemGold('I03I'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNGlove.blp")
			set SURAMAR_BLADE = Item.create('I03C', GetItemGold('I03C'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNgreensword.blp")
			set SUN_BOW = Item.create('I03M', GetItemGold('I03M'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNTripleShot.blp")
			set HUNTRESS_STEEL = Item.create('I03L', GetItemGold('I03L'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNRaiderCleavingAttack.blp")
			set SCOUT_BOOTS = Item.create('I03N', GetItemGold('I03N'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNBootsOfElveskin.blp")
			set BOUND_WISP = Item.create('I03K', GetItemGold('I03K'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNMagicRune.blp")
			set DRUID_STAFF = Item.create('I03E', GetItemGold('I03E'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNMoonGuardStaff.blp")
			set MOON_BLOSSOM = Item.create('I03H', GetItemGold('I03H'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNMoon Flower.blp")
			set CYCLONE_WAND = Item.create('I03J', GetItemGold('I03J'), ITEM_CLASS_ADVANCED, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNWandOfCyclone.blp")
			
			//ITEM_CLASS_ANCIENT: Nightelf
			set TWILIGHT_ARMOR = Item.create('I03T', GetItemGold('I03T'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNAdvancedMoonArmor.blp")
			set MOON_GUARD_ROBE = Item.create('I03Y', GetItemGold('I03Y'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNXCloakOfLava.blp")
			set MIDNIGHT_ARMOR = Item.create('I03W', GetItemGold('I03W'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNAdvancedReinforcedHides.blp")
			set CHIMERA_BOOTS = Item.create('I044', GetItemGold('I044'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNArmorOfSpeed.BLP")
			set DAWN_BOW = Item.create('I03R', GetItemGold('I03R'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNMagicBow.blp")
			set EMERALD_SWORD = Item.create('I046', GetItemGold('I046'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNSnakeSword.blp")
			set DEMONSLAYER = Item.create('I04A', GetItemGold('I04A'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNSpell_Shadow_Fumble.blp")
			set WARDEN_CHAKRAM = Item.create('I042', GetItemGold('I042'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNWardenGlaive.blp")
			set KEEPER_STAFF = Item.create('I03V', GetItemGold('I03V'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNStaff.blp")
			set EVERYOUNG_LEAF = Item.create('I048', GetItemGold('I048'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNAthelas.BLP")
			set DRUID_BOOTS = Item.create('I040', GetItemGold('I040'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNSlowSpellGreen.blp")
			set ANTI_MAGIC_STAFF = Item.create('I03P', GetItemGold('I03P'), ITEM_CLASS_ANCIENT, RACE_NIGHTELF, "ReplaceableTextures\\CommandButtons\\BTNSpell_Nature_ManaRegenTotem.blp")
			
			/*
			 * Init Human Items
			 */
			//ITEM_CLASS_ADVANCED: Human
			set SILVERMOON_SHIELD = Item.create('I01A', GetItemGold('I01A'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNPShieldT4.blp")
			set GUARDIAN_HELMET = Item.create('I01D', GetItemGold('I01D'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNGoldenCrown.blp")
			set CHAINMAIL = Item.create('I01H', GetItemGold('I01H'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNChainmailArmor.blp")
			set SUNRAY_BLOSSOM = Item.create('I01K', GetItemGold('I01K'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNWormwood.blp")
			set DWARVEN_HAMMER = Item.create('I019', GetItemGold('I019'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNHammerofThor.blp")
			set FENCING_SWORD = Item.create('I01I', GetItemGold('I01I'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp")
			set TIME_AMULET = Item.create('I01G', GetItemGold('I01G'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNXGoldenAmulet.blp")
			set BOOTS_OF_QUEL_THALAS = Item.create('I01C', GetItemGold('I01C'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNXboots.blp")
			set TIGERS_EYE = Item.create('I01F', GetItemGold('I01F'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNRuby.BLP")
			set POINTY_HAT = Item.create('I01B', GetItemGold('I01B'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNViviHat.blp")
			set ARCANE_CIRCLET = Item.create('I01E', GetItemGold('I01E'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNAquamarineRing.blp")
			set ANTI_MAGIC_WAND = Item.create('I01J', GetItemGold('I01J'), ITEM_CLASS_ADVANCED, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNColdWard.blp")
			
			//ITEM_CLASS_ANCIENT: Human
			set KNIGHT_HELMET = Item.create('I027', GetItemGold('I027'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNHighHelm.blp")
			set LUCKY_RING = Item.create('I023', GetItemGold('I023'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNAmethystRing.blp")
			set STORMWIND_SHIELD = Item.create('I029', GetItemGold('I029'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNShieldHumanLionMark.BLP")
			set HOLY_SHIELD = Item.create('I01Q', GetItemGold('I01Q'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNCrusadershield.blp")
			set WAR_FLAIL = Item.create('I01T', GetItemGold('I01T'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNflail1.blp")
			set VOLCANO_HAMMER = Item.create('I01Z', GetItemGold('I01Z'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNXSulfuras.blp")
			set CROWBAR = Item.create('I025', GetItemGold('I025'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNCapitalistStick.blp")
			set SEVEN_LEAGUE_BOOTS = Item.create('I01O', GetItemGold('I01O'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp")
			set GRYPHONS_EYE = Item.create('I01X', GetItemGold('I01X'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNEmberShard.blp")
			set RUNESTONE = Item.create('I01V', GetItemGold('I01V'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNBrokenAmulet.blp")
			set FIRE_WAND = Item.create('I021', GetItemGold('I021'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNfireStaff.blp")
			set SEEING_STAFF = Item.create('I01M', GetItemGold('I01M'), ITEM_CLASS_ANCIENT, RACE_HUMAN, "ReplaceableTextures\\CommandButtons\\BTNWard_of_Sight.blp")
			
			/*
			 * Init Orc Items
			 */
			//ITEM_CLASS_ADVANCED: Orc
			set BLOOD_STONE = Item.create('I02I', GetItemGold('I02I'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNBloodDiamant.blp")
			set SPIKED_COLLAR = Item.create('I02L', GetItemGold('I02L'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNGromsRing.blp")
			set OGRIMMAR_SHIELD = Item.create('I02C', GetItemGold('I02C'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNArmorUPG1.blp")
			set DARKSPEAR_MASK = Item.create('I02J', GetItemGold('I02J'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNVoodooMask.blp")
			set BLACKROCK_AXE = Item.create('I02B', GetItemGold('I02B'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNA_SkullAxe.blp")
			set TROLL_DAGGER = Item.create('I02K', GetItemGold('I02K'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNDagger.blp")
			set MACE = Item.create('I02D', GetItemGold('I02D'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNAntiqueMace.blp")
			set CENTAUR_BOOTS = Item.create('I02E', GetItemGold('I02E'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNINV_Boots_08.blp")
			set PIPE = Item.create('I02M', GetItemGold('I02M'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNCalumet.BLP")
			set SHAMAN_GLOVE = Item.create('I02F', GetItemGold('I02F'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNShamanClaw.blp")
			set WARSONG_DRUMS = Item.create('I02H', GetItemGold('I02H'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNGaulishWarDrum.blp")
			set THUNDER_RING = Item.create('I02G', GetItemGold('I02G'), ITEM_CLASS_ADVANCED, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNMana_Ring.blp")
			
			//ITEM_CLASS_ANCIENT: Orc
			set BLACKROCK_ARMOR = Item.create('I030', GetItemGold('I030'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNKoboldArmor3.blp")
			set KODO_VEST = Item.create('I02Y', GetItemGold('I02Y'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNKodoVest.blp")
			set SHAMAN_HOOD = Item.create('I02W', GetItemGold('I02W'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNHoodOfCunning.blp")
			set DEFENSIVE_CHARM = Item.create('I032', GetItemGold('I032'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNLight_Medallion.blp")
			set ASSASSINS_DAGGER = Item.create('I02O', GetItemGold('I02O'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNAssassinsSpear.BLP")
			set BROAD_AXE = Item.create('I02S', GetItemGold('I02S'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNDarkForgeAxe.blp")
			set LONGSWORD = Item.create('I02Q', GetItemGold('I02Q'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNSaracen Attack.blp")
			set KODO_BOOTS = Item.create('I036', GetItemGold('I036'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNBoots.blp")
			set STONE_AMULET = Item.create('I034', GetItemGold('I034'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNRelicMedalion.blp")
			set FRENZY_RING = Item.create('I038', GetItemGold('I038'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNWhitePearl.blp")
			set TAUREN_TOTEM = Item.create('I02U', GetItemGold('I02U'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNEarthTotem.BLP")
			set DRAGON_RING = Item.create('I03A', GetItemGold('I03A'), ITEM_CLASS_ANCIENT, RACE_ORC, "ReplaceableTextures\\CommandButtons\\BTNRing_Of_Reckoning.blp")
		endmethod
	
	endstruct
	
endscope