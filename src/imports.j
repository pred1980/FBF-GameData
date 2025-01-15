/* XE Libraries */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\XE\xepreload.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\XE\xebasic.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\XE\xecast.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\XE\xefx.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\XE\xedamage.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\XE\xecollider.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\XE\xemissile.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\XE\xedummy.j"

/* Libraries */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\InvulnerabilityDetector.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\LocalEffects.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\FriendlyAttackSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\AttackStatus.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\RegionalFog.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\OrderEvent.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\UnitFadeSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\StunSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\DamageOverTime.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\HealOverTime.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\JumpSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\RegisterPlayerUnitEvent.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\ClearItems.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\GetItemCost.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\ListModule.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\SpellSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\SpellEvent.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\SpellHelper.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\IndexerUtils.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\AbilityEvent.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\GetClosestWidget.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\GetFurthestWidget.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\DestructableLib.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\SimError.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\GroupUtils.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\TimerUtils.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\TerrainPathability.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\ARGB.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\TableBC.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\Table.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\MathFunctions.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\MiscFunctions.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\TextTag.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\GetPlayerNameColored.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\Multiboard.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\AutoIndex.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\UnitMaxState.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\BonusMod.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\UnitMaxStateBonuses.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\RegenBonuses.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\MovementBonus.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\UnitBonus.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\AutoFly.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\BezierMissiles.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\BoundSentinel.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\DamageEvent.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\DamageModifiers.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\IntuitiveBuffSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\Knockback.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\ModuleListModule.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\PassiveSpellSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\SoundTools.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\Stack.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\UnitStatus.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\ZUtils.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\HomeBase.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\RectUtils.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\RestoreMana.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\TimedEffect.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\DamageLog.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\GetUnitCollision.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\IsUnitChanneling.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\FieldOfView.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\Escort.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Libraries\WorldBounds.j"

/* Game Config */
//! import "C:\Users\patri\IdeaProjects\FBF\src\GameConfig\GameConfig.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GameConfig\GameStart.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GameConfig\Game.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GameConfig\GameModules.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GameConfig\GameModes.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GameConfig\GameTypes.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GameConfig\GameSounds.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GameConfig\DefenseModes.j"

/* AI Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\AI-Creeps.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroAIPriority.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroAIThreat.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroAIEventResponse.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\AIPlayerDifficultySettings.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroAILearnset.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroAIItem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\PruneGroup.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\FitnessFunc.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\AI-Dummy-Missile.j"

//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\BehemotAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\NerubianWidowAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\IceAvatarAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\GhoulAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\MasterBansheeAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\DeathMarcherAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\SkeletonMageAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\MasterNecromancerAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\CryptLordAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\AbominationAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\DestroyerAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\DreadLordAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\DarkRangerAI.j"

//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\ArchmageAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\TaurenChieftainAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\PriestessOfTheMoonAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\NagaMatriarchAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\OrcishWarlockAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\FarseerAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\FirePandaAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\MountainGiantAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\CenariusAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\PaladinAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\RoyalKnightAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\BloodMageAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\OgreWarriorAI.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\HeroesAI\GiantTurtleAI.j"

/* Hero Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\HeroSystems\HeroPickInit.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\HeroSystems\HeroPickSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\HeroSystems\HeroPickMods.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\HeroSystems\HeroRepickSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\HeroSystems\HeroRespawnSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\HeroSystems\HeroStatsSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\HeroSystems\HeroWarning.j"

/* Item Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemSystems\UnitInventory.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemSystems\ItemShops.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemSystems\ItemRegister.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemSystems\Items.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemSystems\ItemStacking.j"

/* Item Abilities */
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\AngerOfThrall.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\AuraOfRedemption.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\ConfusedSight.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\Crowbar.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\StormBolt.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\Infliction.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\LuckyRing.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\SeedOfLife.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\NetherCharge.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\RocketBoots.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\Entangle.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\CorruptedIcon.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\MetalHand.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\MidnightArmor.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\DemonicAmulet.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\SkullRod.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\ReflectionOfIllidan.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\TalismanOfTranslocation.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\HealingPotion.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ItemAbilities\ManaPotion.j"

/* Tome Damage System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\TomeDamageSystem\TomeDamageSystem.j"

/* Meteor System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\MeteorSystem\MeteorSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\MeteorSystem\MeteorSystemAutomizer.j"

/* XP-System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\XP-System\XPSystem.j"

/* Shield System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\ShieldSystem\ShieldSystem.j"

/* Custom Aura System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomAuraSystem\CustomAura.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomAuraSystem\AuraTemplate.j"
//! -- Modules --
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomAuraSystem\CABuff.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomAuraSystem\CABonus.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomAuraSystem\CAIndex.j"
//! -- CABuff Requirements --
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomAuraSystem\CustomDummy.j"
//! -- CABonus Requirements --
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomAuraSystem\AbilityPreload.j"

/* Custom Bar System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomBarSystem\CustomBar.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CustomBarSystem\Documenation.j"

/* Kill Counter System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\KillCounterSystem\KillCounter.j"

/* Creep Round System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\CreepRoundSystems\CreepSystemRounds.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CreepRoundSystems\CreepSystemUnits.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CreepRoundSystems\CreepSystemCore.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CreepRoundSystems\CreepRoundSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CreepRoundSystems\CreepSystemModule.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CreepRoundSystems\CreepConfigs.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CreepRoundSystems\RoundEndSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\CreepRoundSystems\CustomCreepSystem.j"


/* Waypoint System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\WaypointSystem\AnaMoveSys.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\WaypointSystem\WayPointSystem.j"

/* Kill Streak System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\KillStreakSystem\KillStreakSystem.j"

/* Assist System*/
//! import "C:\Users\patri\IdeaProjects\FBF\src\AssistSystem\AssistSystem.j"

/* Player Stats */
//! import "C:\Users\patri\IdeaProjects\FBF\src\PlayerStats\PlayerStats.j"

/* Gold System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\GoldSystem\GoldSystem.j"

/* Multiboard */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Multiboard\FBFMultiboard.j"

/* Tower Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\CommonAIimports.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\GetTowerCost.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\TowerSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\AI-Systems\AI-TowerBuilder.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\TowerConfig.j"

//! -- Common Towers --
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\CommonTowers\ZeroPoint.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\CommonTowers\HotCoals.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\CommonTowers\Tombstone.j"
//! -- Rare Towers --
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\RareTowers\ColdWrath.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\RareTowers\Ignite.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\RareTowers\CorpseExplosion.j"
//! -- Unique Towers --
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\UniqueTowers\FrostAttack.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\UniqueTowers\IceShard.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TowerSystems\UniqueTowers\UltimateFighter.j"

/* Forsaken Defense System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\ForsakenDefenseSystem\ForsakenDefenseSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\ForsakenDefenseSystem\StandardDefenseMode.j"

/* Evaluation System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\EvaluationSystem\EvaluationSystem.j"

/* Teleport Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\TeleportSystems\CoalitionTeleportSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TeleportSystems\ForsakenTeleportSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TeleportSystems\StoneOfTeleportation.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TeleportSystems\TeleportSystem.j"

/* Coalition Unit Shop Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\UnitShopSystems\UnitShopSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\UnitShopSystems\UnitSystem.j"

/* Unit Bounty System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\UnitBountySystem\UnitBountySystem.j"

/* Web System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\WebSystem\WebSystem.j"

/* Graveyard Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\GraveyardSystems\SpikeTrap.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GraveyardSystems\SkeletonSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GraveyardSystems\GravestoneSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\GraveyardSystems\WormSystem.j"

/* Titan Devourer */
//! import "C:\Users\patri\IdeaProjects\FBF\src\TitanDevourer\TitanDevourer.j"

/* Warden System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\WardenSystem\WardenSystem.j"

/* The Great Final */
//! import "C:\Users\patri\IdeaProjects\FBF\src\TheGreatFinal\GreatFinalSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TheGreatFinal\KingMithasMode.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TheGreatFinal\DiabolicCountdown.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TheGreatFinal\HeartAura.j"

/* Brood Mother */
//! import "C:\Users\patri\IdeaProjects\FBF\src\BroodMotherSystems\BroodMotherSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\BroodMotherSystems\Eggshack.j"

/* Camera System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\CameraSystem\CameraSystem.j"

/* Usability System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\UsabilitySystem\UsabilitySystem.j"

/* Tutorial Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\TutorialSystems\HeroTutorials.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\TutorialSystems\MiscTutorials.j"


/* Misc Systems */
//! import "C:\Users\patri\IdeaProjects\FBF\src\MiscSystems\DomeAura.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\MiscSystems\MagicImmunity.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\MiscSystems\DomeMagicImmunity.j"


/* Dialog System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\DialogSystem\DialogSystem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\DialogSystem\Dialog.j"

/* Wander System */
//! import "C:\Users\patri\IdeaProjects\FBF\src\WanderSystem\WanderSystem.j"

/* 
 * HEROES
 */

// import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\HerosWill.j"
 
/* Behemoth */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Behemoth\ExplosiveTantrum.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Behemoth\BeastStomper.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Behemoth\Roar.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Behemoth\AdrenalinRush.j"
 
/* Nerubian Widow */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\NerubianWidow\Adolescence.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\NerubianWidow\SpiderWeb.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\NerubianWidow\Sprint.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\NerubianWidow\WidowBite.j"

/* Ice Avatar */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\IceAvatar\IceTornado.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\IceAvatar\FreezingBreath.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\IceAvatar\FrostAura.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\IceAvatar\FogOfDeath.j"

/* Ghoul */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Ghoul\ClawsAttack.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Ghoul\FleshWound.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Ghoul\Cannibalize.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Ghoul\Rage.j"

/* Master Banshee */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MasterBanshee\DarkObedience.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MasterBanshee\SpiritBurn.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MasterBanshee\CursedSoul.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MasterBanshee\Barrage.j"

/* Death Marcher */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DeathMarcher\DeathPact.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DeathMarcher\SoulTrap.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DeathMarcher\ManaConcentration.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DeathMarcher\BoilingBlood.j"

/* Skeleton Mage */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\SkeletonMage\SkeletonMageSpells.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\SkeletonMage\PlagueInfection.j"

/* Master Necromancer */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MasterNecromancer\Necromancy.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MasterNecromancer\MaliciousCurse.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MasterNecromancer\Despair.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MasterNecromancer\DeadSouls.j"

/* Crypt Lord */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\CryptLord\BurrowStrike.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\CryptLord\CryptLordSpells.j"

/* Abomination */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Abomination\Cleave.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Abomination\ConsumeHimself.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Abomination\PlagueCloud.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Abomination\Snack.j"

/* Destroyer */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Destroyer\ArcaneSwap.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Destroyer\MindBurst.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Destroyer\ManaSteal.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Destroyer\ReleaseMana.j"

/* Dread Lord */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DreadLord\VampireBlood.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DreadLord\Purify.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DreadLord\SleepyDust.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DreadLord\NightDome.j"

/* Dark Ranger */
//! Ghost Form"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DarkRanger\CripplingArrow.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DarkRanger\Snipe.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\DarkRanger\CoupDeGrace.j"

/* Archmage */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Archmage\HolyChains.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Archmage\TrappySwap.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Archmage\RefreshingAura.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Archmage\Fireworks.j"

/* Tauren Chieftain */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\TaurenChieftain\FireTotem.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\TaurenChieftain\StompBlaster.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\TaurenChieftain\Fervor.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\TaurenChieftain\ShockWave.j"

/* Priestess of the Moon */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\PriestessOfTheMoon\LifeVortex.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\PriestessOfTheMoon\Moonlight.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\PriestessOfTheMoon\NightAura.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\PriestessOfTheMoon\RevengeOwl.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\PriestessOfTheMoon\EvasionAura.j"

/* Naga Matriarch */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\NagaMatriarch\TidalShield.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\NagaMatriarch\ImpalingSpine.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\NagaMatriarch\CrushingWave.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\NagaMatriarch\Maelstrom.j"

/* Orcish Warlock */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\OrcishWarlock\Thunderbolt.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\OrcishWarlock\SpiritLink.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\OrcishWarlock\ManaWard.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\OrcishWarlock\DarkSummoning.j"

/* Royal Knight */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\RoyalKnight\BattleFury.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\RoyalKnight\ShatteringJavelin.j"
//! Animal War Training
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\RoyalKnight\Charge.j"

/* Giant Turtle */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\GiantTurtle\Wave.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\GiantTurtle\AquaShield.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\GiantTurtle\ScaledShell.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\GiantTurtle\FountainBlast.j"

/* Cenarius */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Cenarius\CenariusMain.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Cenarius\NaturalSphere.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Cenarius\MagicSeed.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Cenarius\PollenAura.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Cenarius\LeafStorm.j"

/* Paladin */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Paladin\GodsSeal.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Paladin\StarImpact.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Paladin\HolyStrike.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Paladin\HolyCross.j"

/* Fire Panda */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\FirePanda\HacknSlash.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\FirePanda\HighJump.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\FirePanda\BladeThrow.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\FirePanda\ArtOfFire.j"

/* Blood Mage */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\BloodMage\Fireblast.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\BloodMage\BoonAndBane.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\BloodMage\BurningSkin.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\BloodMage\FireStorm.j"

/* Mountain Giant */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MountainGiant\Crag.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MountainGiant\HurlBoulder.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MountainGiant\CraggyExterior.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\MountainGiant\Endurance.j"

/* Farseer */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Farseer\LightningBalls.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Farseer\VoltyCrush.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Farseer\ReflectiveShield.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\Farseer\SpiritArrows.j"

/* Ogre Warrior */
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\OgreWarrior\AxeThrow.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\OgreWarrior\Decapitate.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\OgreWarrior\MightySwing.j"
//! import "C:\Users\patri\IdeaProjects\FBF\src\Heroes\OgreWarrior\Consumption.j"