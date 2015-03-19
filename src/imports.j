/* Libraries */
//! import "src\Libraries\InvulnerabilityDetector.j"
//! import "src\Libraries\LocalEffects.j"
//! import "src\Libraries\FriendlyAttackSystem.j"
//! import "src\Libraries\AttackStatus.j"
//! import "src\Libraries\RegionalFog.j"
//! import "src\Libraries\OrderEvent.j"
//! import "src\Libraries\UnitFadeSystem.j"
//! import "src\Libraries\StunSystem.j"
//! import "src\Libraries\DamageOverTime.j"
//! import "src\Libraries\HealOverTime.j"
//! import "src\Libraries\JumpSystem.j"
//! import "src\Libraries\RegisterPlayerUnitEvent.j"
//! import "src\Libraries\ClearItems.j"
//! import "src\Libraries\GetItemCost.j"
//! import "src\Libraries\ListModule.j"
//! import "src\Libraries\SpellSystem.j"
//! import "src\Libraries\SpellEvent.j"
//! import "src\Libraries\IndexerUtils.j"
//! import "src\Libraries\AbilityEvent.j"
//! import "src\Libraries\GetClosestWidget.j"
//! import "src\Libraries\DestructableLib.j"
//! import "src\Libraries\SimError.j"
//! import "src\Libraries\GroupUtils.j"
//! import "src\Libraries\TimerUtils.j"
//! import "src\Libraries\TerrainPathability.j"
//! import "src\Libraries\ARGB.j"
//! import "src\Libraries\TableBC.j"
//! import "src\Libraries\Table.j"
//! import "src\Libraries\MathFunctions.j"
//! import "src\Libraries\MiscFunctions.j"
//! import "src\Libraries\TextTag.j"
//! import "src\Libraries\GetPlayerNameColored.j"
//! import "src\Libraries\Multiboard.j"
//! import "src\Libraries\AutoIndex.j"
//! import "src\Libraries\UnitMaxState.j"
//! import "src\Libraries\BonusMod.j"
//! import "src\Libraries\UnitMaxStateBonuses.j"
//! import "src\Libraries\RegenBonuses.j"
//! import "src\Libraries\MovementBonus.j"
//! import "src\Libraries\UnitBonus.j"
//! import "src\Libraries\AutoFly.j"
//! import "src\Libraries\BezierMissiles.j"
//! import "src\Libraries\BoundSentinel.j"
//! import "src\Libraries\DamageEvent.j"
//! import "src\Libraries\DamageModifiers.j"
//! import "src\Libraries\IntuitiveBuffSystem.j"
//! import "src\Libraries\Knockback.j"
//! import "src\Libraries\ModuleListModule.j"
//! import "src\Libraries\PassiveSpellSystem.j"
//! import "src\Libraries\SoundTools.j"
//! import "src\Libraries\Stack.j"
//! import "src\Libraries\UnitStatus.j"
//! import "src\Libraries\ZUtils.j"
//! import "src\Libraries\HomeBase.j"
//! import "src\Libraries\RectUtils.j"
//! import "src\Libraries\CheckImmunity.j"
//! import "src\Libraries\RestoreMana.j"

/* XE Libraries */
//! import "src\Libraries\XE\xepreload.j"
//! import "src\Libraries\XE\xebasic.j"
//! import "src\Libraries\XE\xecast.j"
//! import "src\Libraries\XE\xefx.j"
//! import "src\Libraries\XE\xedamage.j"
//! import "src\Libraries\XE\xecollider.j"
//! import "src\Libraries\XE\xemissile.j"
//! import "src\Libraries\XE\xedummy.j"

/* Game Config */
//! import "src\GameConfig\GameConfig.j"
//! import "src\GameConfig\GameStart.j"
//! import "src\GameConfig\Game.j"
//! import "src\GameConfig\GameModules.j"
//! import "src\GameConfig\GameModes.j"
//! import "src\GameConfig\GameTypes.j"
//! import "src\GameConfig\GameSounds.j"
//! import "src\GameConfig\DefenseModes.j"

/* Hero Systems */
//! import "src\HeroSystems\HeroPickInit.j"
//! import "src\HeroSystems\HeroPickSystem.j"
//! import "src\HeroSystems\HeroPickMods.j"
//! import "src\HeroSystems\HeroRepickSystem.j"
//! import "src\HeroSystems\HeroRespawnSystem.j"
//! import "src\HeroSystems\HeroStatsSystem.j"

/* Item Systems */
//! import "src\ItemSystems\UnitInventory.j"
//! import "src\ItemSystems\ItemShops.j"
//! import "src\ItemSystems\ItemRegister.j"
//! import "src\ItemSystems\Items.j"
//! import "src\ItemSystems\EasyItemStacknSplit.j"

/* Item Abilities */
//! import "src\ItemAbilities\AngerOfThrall.j"
//! import "src\ItemAbilities\AuraOfRedemption.j"
//! import "src\ItemAbilities\ConfusedSight.j"
//! import "src\ItemAbilities\Crowbar.j"
//! import "src\ItemAbilities\StormBolt.j"
//! import "src\ItemAbilities\Infliction.j"
//! import "src\ItemAbilities\LuckyRing.j"
//! import "src\ItemAbilities\SeedOfLife.j"
//! import "src\ItemAbilities\NetherCharge.j"
//! import "src\ItemAbilities\RocketBoots.j"
//! import "src\ItemAbilities\Entangle.j"
//! import "src\ItemAbilities\PoisonMarker.j"
//! import "src\ItemAbilities\CorruptedIcon.j"
//! import "src\ItemAbilities\MetalHand.j"
//! import "src\ItemAbilities\MidnightArmor.j"
//! import "src\ItemAbilities\DemonicAmulet.j"
//! import "src\ItemAbilities\SkullRod.j"

/* Tome Damage System */
//! import "src\TomeDamageSystem\TomeDamageSystem.j"

/* Meteor System */
//! import "src\MeteorSystem\MeteorSystem.j"
//! import "src\MeteorSystem\MeteorSystemAutomizer.j"

/* XP-System */
//! import "src\XP-System\XPSystem.j"

/* Shield System */
//! import "src\ShieldSystem\ShieldSystem.j"

/* Custom Aura System */
//! import "src\CustomAuraSystem\CustomAura.j"
//! import "src\CustomAuraSystem\AuraTemplate.j"
// -- Modules --
//! import "src\CustomAuraSystem\CABuff.j"
//! import "src\CustomAuraSystem\CABonus.j"
//! import "src\CustomAuraSystem\CAIndex.j"
// -- CABuff Requirements --
//! import "src\CustomAuraSystem\CustomDummy.j"
// -- CABonus Requirements --
//! import "src\CustomAuraSystem\AbilityPreload.j"

/* Custom Bar System */
//! import "src\CustomBarSystem\CustomBar.j"
// import "src\CustomBarSystem\Documenation.j"

/* Kill Counter System */
//! import "src\KillCounterSystem\KillCounter.j"

/* Creep Round System */
//! import "src\CreepRoundSystems\CreepSystemRounds.j"
//! import "src\CreepRoundSystems\CreepSystemUnits.j"
//! import "src\CreepRoundSystems\CreepSystemCore.j"
//! import "src\CreepRoundSystems\CreepRoundSystem.j"
//! import "src\CreepRoundSystems\CreepSystemModule.j"
//! import "src\CreepRoundSystems\CreepConfigs.j"

/* Waypoint System */
//! import "src\WaypointSystem\AnaMoveSys.j"
//! import "src\WaypointSystem\WayPointSystem.j"

/* Kill Streak System */
//! import "src\KillStreakSystem\KillStreakSystem.j"

/* Assist System*/
//! import "src\AssistSystem\AssistSystem.j"

/* Player Stats */
//! import "src\PlayerStats\PlayerStats.j"

/* Gold System */
//! import "src\GoldSystem\GoldSystem.j"

/* Multiboard */
//! import "src\Multiboard\FBFMultiboard.j"

/* Tower Systems */
//! import "src\TowerSystems\CommonAIimports.j"
//! import "src\TowerSystems\GetTowerCost.j"
//! import "src\TowerSystems\TowerSystem.j"
// -- Common Towers --
//! import "src\TowerSystems\CommonTowers\ZeroPoint.j"
//! import "src\TowerSystems\CommonTowers\HotCoals.j"
//! import "src\TowerSystems\CommonTowers\Tombstone.j"
// -- Rare Towers --
//! import "src\TowerSystems\RareTowers\ColdWrath.j"
//! import "src\TowerSystems\RareTowers\Ignite.j"
//! import "src\TowerSystems\RareTowers\CorpseExplosion.j"
// -- Unique Towers --
//! import "src\TowerSystems\UniqueTowers\FrostAttack.j"
//! import "src\TowerSystems\UniqueTowers\IceShard.j"
//! import "src\TowerSystems\UniqueTowers\UltimateFighter.j"

/* Forsaken Defense System */
//! import "src\ForsakenDefenseSystem\ForsakenDefenseSystem.j"
//! import "src\ForsakenDefenseSystem\StandardDefenseMode.j"

/* Evaluation System */
//! import "src\EvaluationSystem\EvaluationSystem.j"

/* Teleport Systems */
//! import "src\TeleportSystems\CoalitionTeleportSystem.j"
//! import "src\TeleportSystems\ForsakenTeleportSystem.j"
//! import "src\TeleportSystems\StoneOfTeleportation.j"
//! import "src\TeleportSystems\TeleportSystem.j"

/* Coalition Unit Shop Systems */
//! import "src\UnitShopSystems\CoalitionShopSystem.j"
//! import "src\UnitShopSystems\CoalitionUnitSystem.j"

/* Unit Bounty System */
//! import "src\UnitBountySystem\UnitBountySystem.j"

/* Web System */
//! import "src\WebSystem\WebSystem.j"

/* Graveyard Systems */
//! import "src\GraveyardSystems\SpikeTrap.j"
//! import "src\GraveyardSystems\SkeletonSystem.j"
//! import "src\GraveyardSystems\GravestoneSystem.j"
//! import "src\GraveyardSystems\WormSystem.j"

/* Titan Devourer */
//! import "src\TitanDevourer\TitanDevourer.j"

/* Warden System */
//! import "src\WardenSystem\WardenSystem.j"

/* The Great Final */
//! import "src\TheGreatFinal\GreatFinalSystem.j"
//! import "src\TheGreatFinal\KingMithasMode.j"
//! import "src\TheGreatFinal\DiabolicCountdown.j"
// import "src\TheGreatFinal\HeartAura.j"

/* Brood Mother */
//! import "src\BroodMotherSystems\BroodMotherSystem.j"
// import "src\BroodMotherSystems\Eggshack.j"

/* Weather System */
//! import "src\WeatherSystem\WeatherSystem.j"

/* Camera System */
//! import "src\CameraSystem\CameraSystem.j"

/* Usability System */
//! import "src\UsabilitySystem\UsabilitySystem.j"

/* Tutorial Systems */
//! import "src\TutorialSystems\HeroTutorials.j"
//! import "src\TutorialSystems\MiscTutorials.j"

/* Misc Systems */
//! import "src\MiscSystems\DomeAura.j"
// import "src\MiscSystems\MagicImmunity.j"
// import "src\MiscSystems\DomeMagicImmunity.j"

/* AI Systems */
//! import "src\AI-Systems\AI-Creeps.j"

/* Dialog System*/
//! import "src\DialogSystem\DialogSystem.j"
//! import "src\DialogSystem\Dialog.j"

/* ------------------------------- */

/* 
 * HEROES
 */
 
/* Behemoth */
//! import "src\Heroes\Behemoth\ExplosivTantrum.j"
//! import "src\Heroes\Behemoth\BeastStomper.j"
//! import "src\Heroes\Behemoth\AdrenalinRush.j"
 
/* Nerubian Widow */
//! import "src\Heroes\NerubianWidow\Adolescence.j"
//! import "src\Heroes\NerubianWidow\SpiderWeb.j"
//! import "src\Heroes\NerubianWidow\Sprint.j"
//! import "src\Heroes\NerubianWidow\WidowBite.j"

/* Ice Avatar */
//! import "src\Heroes\IceAvatar\IceTornado.j"
//! import "src\Heroes\IceAvatar\FreezingBreath.j"
//! import "src\Heroes\IceAvatar\FrostAura.j"
//! import "src\Heroes\IceAvatar\FogOfDeath.j"

/* Ghoul */
//! import "src\Heroes\Ghoul\ClawsAttack.j"
//! import "src\Heroes\Ghoul\FleshWound.j"
//! import "src\Heroes\Ghoul\Rage.j"

/* Master Banshee */
//! import "src\Heroes\MasterBanshee\DarkObedience.j"
//! import "src\Heroes\MasterBanshee\SpiritBurn.j"
//! import "src\Heroes\MasterBanshee\CursedSoul.j"
//! import "src\Heroes\MasterBanshee\Barrage.j"

/* Death Marcher */
//! import "src\Heroes\DeathMarcher\DeathPact.j"
//! import "src\Heroes\DeathMarcher\SoulTrap.j"
//! import "src\Heroes\DeathMarcher\ManaConcentration.j"
//! import "src\Heroes\DeathMarcher\BoilingBlood.j"

/* Skeleton Mage */
//! import "src\Heroes\SkeletonMage\SkeletonMageSpells.j"
//! import "src\Heroes\SkeletonMage\PlagueInfection.j"

/* Master Necromancer */
//! import "src\Heroes\MasterNecromancer\Necromancy.j"
//! import "src\Heroes\MasterNecromancer\MaliciousCurse.j"
//! import "src\Heroes\MasterNecromancer\Despair.j"
//! import "src\Heroes\MasterNecromancer\DeadSouls.j"

/* Crypt Lord */
//! import "src\Heroes\CryptLord\BurrowStrike.j"
//! import "src\Heroes\CryptLord\CryptLordSpells.j"

/* Abomination */
//! import "src\Heroes\Abomination\Cleave.j"
//! import "src\Heroes\Abomination\ConsumeHimself.j"
//! import "src\Heroes\Abomination\PlagueCloud.j"
//! import "src\Heroes\Abomination\Snack.j"

/* Destroyer */
//! import "src\Heroes\Destroyer\ArcaneSwap.j"
//! import "src\Heroes\Destroyer\MindBurst.j"
//! import "src\Heroes\Destroyer\ManaSteal.j"
//! import "src\Heroes\Destroyer\ReleaseMana.j"

/* Dread Lord */
//! import "src\Heroes\DreadLord\VampireBlood.j"
//! import "src\Heroes\DreadLord\Purify.j"
//! import "src\Heroes\DreadLord\SleepyDust.j"
//! import "src\Heroes\DreadLord\NightDome.j"

/* Dark Ranger */
// Ghost Form"
//! import "src\Heroes\DarkRanger\CripplingArrow.j"
//! import "src\Heroes\DarkRanger\Snipe.j"
//! import "src\Heroes\DarkRanger\CoupDeGrace.j"

/* Archmage */
//! import "src\Heroes\Archmage\HolyChains.j"
//! import "src\Heroes\Archmage\TrappySwap.j"
//! import "src\Heroes\Archmage\RefreshingAura.j"
//! import "src\Heroes\Archmage\Fireworks.j"

/* Tauren Chieftain */
//! import "src\Heroes\TaurenChieftain\FireTotem.j"
//! import "src\Heroes\TaurenChieftain\StompBlaster.j"
//! import "src\Heroes\TaurenChieftain\Fervor.j"
//! import "src\Heroes\TaurenChieftain\ShockWave.j"

/* Priestess of the Moon */
//! import "src\Heroes\PriestessOfTheMoon\LifeVortex.j"
//! import "src\Heroes\PriestessOfTheMoon\Moonlight.j"
//! import "src\Heroes\PriestessOfTheMoon\NightAura.j"
//! import "src\Heroes\PriestessOfTheMoon\RevengeOwl.j"

/* Naga Matriarch */
//! import "src\Heroes\NagaMatriarch\TidalShield.j"
//! import "src\Heroes\NagaMatriarch\ImpalingSpine.j"
//! import "src\Heroes\NagaMatriarch\CrushingWave.j"
//! import "src\Heroes\NagaMatriarch\Maelstrom.j"

/* Orcish Warlock */
//! import "src\Heroes\OrcishWarlock\Thunderbolt.j"
//! import "src\Heroes\OrcishWarlock\SpiritLink.j"
//! import "src\Heroes\OrcishWarlock\ManaWard.j"
//! import "src\Heroes\OrcishWarlock\DarkSummoning.j"

/* Royal Knight */
//! import "src\Heroes\RoyalKnight\BattleFury.j"
//! import "src\Heroes\RoyalKnight\ShatteringJavelin.j"
// Animal War Training
//! import "src\Heroes\RoyalKnight\Charge.j"

/* Giant Turtle */
//! import "src\Heroes\GiantTurtle\Wave.j"
//! import "src\Heroes\GiantTurtle\AquaShield.j"
//! import "src\Heroes\GiantTurtle\ScaledShell.j"
//! import "src\Heroes\GiantTurtle\FountainBlast.j"

/* Cenarius */
//! import "src\Heroes\Cenarius\CenariusMain.j"
//! import "src\Heroes\Cenarius\NaturalSphere.j"
//! import "src\Heroes\Cenarius\MagicSeed.j"
//! import "src\Heroes\Cenarius\PollenAura.j"
//! import "src\Heroes\Cenarius\LeafStorm.j"

/* Paladin */
//! import "src\Heroes\Paladin\GodsSeal.j"
//! import "src\Heroes\Paladin\StarImpact.j"
//! import "src\Heroes\Paladin\HolyStrike.j"
//! import "src\Heroes\Paladin\HolyCross.j"

/* Fire Panda */
//! import "src\Heroes\FirePanda\HacknSlash.j"
//! import "src\Heroes\FirePanda\HighJump.j"
//! import "src\Heroes\FirePanda\BladeThrow.j"
//! import "src\Heroes\FirePanda\ArtOfFire.j"

/* Blood Mage */
//! import "src\Heroes\BloodMage\Fireblast.j"
//! import "src\Heroes\BloodMage\BoonAndBane.j"
//! import "src\Heroes\BloodMage\BurningSkin.j"
//! import "src\Heroes\BloodMage\FireStorm.j"

/* Mountain Giant */
//! import "src\Heroes\MountainGiant\Crag.j"
//! import "src\Heroes\MountainGiant\HurlBoulder.j"
//! import "src\Heroes\MountainGiant\CraggyExterior.j"
//! import "src\Heroes\MountainGiant\Endurance.j"

/* Farseer */
//! import "src\Heroes\Farseer\LightningBalls.j"
//! import "src\Heroes\Farseer\VoltyCrush.j"
//! import "src\Heroes\Farseer\ReflectiveShield.j"
//! import "src\Heroes\Farseer\SpiritArrows.j"

/* Ogre Warrior */
//! import "src\Heroes\OgreWarrior\AxeThrow.j"
//! import "src\Heroes\OgreWarrior\Decapitate.j"
//! import "src\Heroes\OgreWarrior\MightySwing.j"
//! import "src\Heroes\OgreWarrior\Consumption.j"