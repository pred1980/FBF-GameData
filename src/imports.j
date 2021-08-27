/* XE Libraries */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\XE\xepreload.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\XE\xebasic.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\XE\xecast.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\XE\xefx.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\XE\xedamage.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\XE\xecollider.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\XE\xemissile.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\XE\xedummy.j"

/* Libraries */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\InvulnerabilityDetector.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\LocalEffects.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\FriendlyAttackSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\AttackStatus.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\RegionalFog.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\OrderEvent.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\UnitFadeSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\StunSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\DamageOverTime.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\HealOverTime.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\JumpSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\RegisterPlayerUnitEvent.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\ClearItems.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\GetItemCost.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\ListModule.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\SpellSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\SpellEvent.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\SpellHelper.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\IndexerUtils.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\AbilityEvent.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\GetClosestWidget.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\GetFurthestWidget.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\DestructableLib.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\SimError.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\GroupUtils.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\TimerUtils.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\TerrainPathability.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\ARGB.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\TableBC.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\Table.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\MathFunctions.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\MiscFunctions.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\TextTag.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\GetPlayerNameColored.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\Multiboard.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\AutoIndex.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\UnitMaxState.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\BonusMod.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\UnitMaxStateBonuses.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\RegenBonuses.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\MovementBonus.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\UnitBonus.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\AutoFly.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\BezierMissiles.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\BoundSentinel.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\DamageEvent.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\DamageModifiers.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\IntuitiveBuffSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\Knockback.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\ModuleListModule.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\PassiveSpellSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\SoundTools.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\Stack.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\UnitStatus.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\ZUtils.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\HomeBase.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\RectUtils.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\RestoreMana.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\TimedEffect.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\DamageLog.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\GetUnitCollision.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\IsUnitChanneling.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\FieldOfView.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\Escort.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Libraries\WorldBounds.j"

/* Game Config */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GameConfig\GameConfig.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GameConfig\GameStart.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GameConfig\Game.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GameConfig\GameModules.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GameConfig\GameModes.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GameConfig\GameTypes.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GameConfig\GameSounds.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GameConfig\DefenseModes.j"

/* AI Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\AI-Creeps.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroAILearnset.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroAIItem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\PruneGroup.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\FitnessFunc.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\AI-Dummy-Missile.j"

//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\BehemotAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\NerubianWidowAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\IceAvatarAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\GhoulAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\MasterBansheeAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\DeathMarcherAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\SkeletonMageAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\MasterNecromancerAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\CryptLordAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\AbominationAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\DestroyerAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\DreadLordAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\DarkRangerAI.j"

//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\ArchmageAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\TaurenChieftainAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\PriestessOfTheMoonAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\NagaMatriarchAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\OrcishWarlockAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\FarseerAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\FirePandaAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\MountainGiantAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\CenariusAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\PaladinAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\RoyalKnightAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\BloodMageAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\OgreWarriorAI.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\HeroesAI\GiantTurtleAI.j"

/* Hero Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\HeroSystems\HeroPickInit.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\HeroSystems\HeroPickSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\HeroSystems\HeroPickMods.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\HeroSystems\HeroRepickSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\HeroSystems\HeroRespawnSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\HeroSystems\HeroStatsSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\HeroSystems\HeroWarning.j"

/* Item Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemSystems\UnitInventory.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemSystems\ItemShops.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemSystems\ItemRegister.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemSystems\Items.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemSystems\ItemStacking.j"

/* Item Abilities */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\AngerOfThrall.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\AuraOfRedemption.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\ConfusedSight.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\Crowbar.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\StormBolt.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\Infliction.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\LuckyRing.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\SeedOfLife.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\NetherCharge.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\RocketBoots.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\Entangle.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\CorruptedIcon.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\MetalHand.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\MidnightArmor.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\DemonicAmulet.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\SkullRod.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\ReflectionOfIllidan.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\TalismanOfTranslocation.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\HealingPotion.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ItemAbilities\ManaPotion.j"

/* Tome Damage System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TomeDamageSystem\TomeDamageSystem.j"

/* Meteor System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\MeteorSystem\MeteorSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\MeteorSystem\MeteorSystemAutomizer.j"

/* XP-System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\XP-System\XPSystem.j"

/* Shield System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ShieldSystem\ShieldSystem.j"

/* Custom Aura System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomAuraSystem\CustomAura.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomAuraSystem\AuraTemplate.j"
//! -- Modules --
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomAuraSystem\CABuff.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomAuraSystem\CABonus.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomAuraSystem\CAIndex.j"
//! -- CABuff Requirements --
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomAuraSystem\CustomDummy.j"
//! -- CABonus Requirements --
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomAuraSystem\AbilityPreload.j"

/* Custom Bar System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomBarSystem\CustomBar.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CustomBarSystem\Documenation.j"

/* Kill Counter System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\KillCounterSystem\KillCounter.j"

/* Creep Round System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CreepRoundSystems\CreepSystemRounds.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CreepRoundSystems\CreepSystemUnits.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CreepRoundSystems\CreepSystemCore.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CreepRoundSystems\CreepRoundSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CreepRoundSystems\CreepSystemModule.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CreepRoundSystems\CreepConfigs.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CreepRoundSystems\RoundEndSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CreepRoundSystems\CustomCreepSystem.j"


/* Waypoint System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\WaypointSystem\AnaMoveSys.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\WaypointSystem\WayPointSystem.j"

/* Kill Streak System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\KillStreakSystem\KillStreakSystem.j"

/* Assist System*/
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AssistSystem\AssistSystem.j"

/* Player Stats */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\PlayerStats\PlayerStats.j"

/* Gold System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GoldSystem\GoldSystem.j"

/* Multiboard */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Multiboard\FBFMultiboard.j"

/* Tower Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\CommonAIimports.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\GetTowerCost.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\TowerSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\AI-Systems\AI-TowerBuilder.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\TowerConfig.j"

//! -- Common Towers --
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\CommonTowers\ZeroPoint.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\CommonTowers\HotCoals.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\CommonTowers\Tombstone.j"
//! -- Rare Towers --
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\RareTowers\ColdWrath.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\RareTowers\Ignite.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\RareTowers\CorpseExplosion.j"
//! -- Unique Towers --
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\UniqueTowers\FrostAttack.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\UniqueTowers\IceShard.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TowerSystems\UniqueTowers\UltimateFighter.j"

/* Forsaken Defense System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ForsakenDefenseSystem\ForsakenDefenseSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\ForsakenDefenseSystem\StandardDefenseMode.j"

/* Evaluation System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\EvaluationSystem\EvaluationSystem.j"

/* Teleport Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TeleportSystems\CoalitionTeleportSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TeleportSystems\ForsakenTeleportSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TeleportSystems\StoneOfTeleportation.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TeleportSystems\TeleportSystem.j"

/* Coalition Unit Shop Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\UnitShopSystems\UnitShopSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\UnitShopSystems\UnitSystem.j"

/* Unit Bounty System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\UnitBountySystem\UnitBountySystem.j"

/* Web System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\WebSystem\WebSystem.j"

/* Graveyard Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GraveyardSystems\SpikeTrap.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GraveyardSystems\SkeletonSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GraveyardSystems\GravestoneSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\GraveyardSystems\WormSystem.j"

/* Titan Devourer */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TitanDevourer\TitanDevourer.j"

/* Warden System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\WardenSystem\WardenSystem.j"

/* The Great Final */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TheGreatFinal\GreatFinalSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TheGreatFinal\KingMithasMode.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TheGreatFinal\DiabolicCountdown.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TheGreatFinal\HeartAura.j"

/* Brood Mother */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\BroodMotherSystems\BroodMotherSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\BroodMotherSystems\Eggshack.j"

/* Camera System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\CameraSystem\CameraSystem.j"

/* Usability System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\UsabilitySystem\UsabilitySystem.j"

/* Tutorial Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TutorialSystems\HeroTutorials.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\TutorialSystems\MiscTutorials.j"


/* Misc Systems */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\MiscSystems\DomeAura.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\MiscSystems\MagicImmunity.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\MiscSystems\DomeMagicImmunity.j"


/* Dialog System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\DialogSystem\DialogSystem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\DialogSystem\Dialog.j"

/* Wander System */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\WanderSystem\WanderSystem.j"

/* 
 * HEROES
 */

// import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\HerosWill.j"
 
/* Behemoth */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Behemoth\ExplosiveTantrum.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Behemoth\BeastStomper.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Behemoth\Roar.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Behemoth\AdrenalinRush.j"
 
/* Nerubian Widow */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\NerubianWidow\Adolescence.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\NerubianWidow\SpiderWeb.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\NerubianWidow\Sprint.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\NerubianWidow\WidowBite.j"

/* Ice Avatar */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\IceAvatar\IceTornado.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\IceAvatar\FreezingBreath.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\IceAvatar\FrostAura.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\IceAvatar\FogOfDeath.j"

/* Ghoul */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Ghoul\ClawsAttack.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Ghoul\FleshWound.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Ghoul\Cannibalize.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Ghoul\Rage.j"

/* Master Banshee */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MasterBanshee\DarkObedience.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MasterBanshee\SpiritBurn.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MasterBanshee\CursedSoul.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MasterBanshee\Barrage.j"

/* Death Marcher */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DeathMarcher\DeathPact.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DeathMarcher\SoulTrap.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DeathMarcher\ManaConcentration.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DeathMarcher\BoilingBlood.j"

/* Skeleton Mage */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\SkeletonMage\SkeletonMageSpells.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\SkeletonMage\PlagueInfection.j"

/* Master Necromancer */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MasterNecromancer\Necromancy.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MasterNecromancer\MaliciousCurse.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MasterNecromancer\Despair.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MasterNecromancer\DeadSouls.j"

/* Crypt Lord */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\CryptLord\BurrowStrike.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\CryptLord\CryptLordSpells.j"

/* Abomination */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Abomination\Cleave.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Abomination\ConsumeHimself.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Abomination\PlagueCloud.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Abomination\Snack.j"

/* Destroyer */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Destroyer\ArcaneSwap.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Destroyer\MindBurst.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Destroyer\ManaSteal.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Destroyer\ReleaseMana.j"

/* Dread Lord */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DreadLord\VampireBlood.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DreadLord\Purify.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DreadLord\SleepyDust.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DreadLord\NightDome.j"

/* Dark Ranger */
//! Ghost Form"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DarkRanger\CripplingArrow.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DarkRanger\Snipe.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\DarkRanger\CoupDeGrace.j"

/* Archmage */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Archmage\HolyChains.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Archmage\TrappySwap.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Archmage\RefreshingAura.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Archmage\Fireworks.j"

/* Tauren Chieftain */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\TaurenChieftain\FireTotem.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\TaurenChieftain\StompBlaster.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\TaurenChieftain\Fervor.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\TaurenChieftain\ShockWave.j"

/* Priestess of the Moon */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\PriestessOfTheMoon\LifeVortex.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\PriestessOfTheMoon\Moonlight.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\PriestessOfTheMoon\NightAura.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\PriestessOfTheMoon\RevengeOwl.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\PriestessOfTheMoon\EvasionAura.j"

/* Naga Matriarch */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\NagaMatriarch\TidalShield.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\NagaMatriarch\ImpalingSpine.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\NagaMatriarch\CrushingWave.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\NagaMatriarch\Maelstrom.j"

/* Orcish Warlock */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\OrcishWarlock\Thunderbolt.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\OrcishWarlock\SpiritLink.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\OrcishWarlock\ManaWard.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\OrcishWarlock\DarkSummoning.j"

/* Royal Knight */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\RoyalKnight\BattleFury.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\RoyalKnight\ShatteringJavelin.j"
//! Animal War Training
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\RoyalKnight\Charge.j"

/* Giant Turtle */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\GiantTurtle\Wave.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\GiantTurtle\AquaShield.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\GiantTurtle\ScaledShell.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\GiantTurtle\FountainBlast.j"

/* Cenarius */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Cenarius\CenariusMain.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Cenarius\NaturalSphere.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Cenarius\MagicSeed.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Cenarius\PollenAura.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Cenarius\LeafStorm.j"

/* Paladin */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Paladin\GodsSeal.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Paladin\StarImpact.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Paladin\HolyStrike.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Paladin\HolyCross.j"

/* Fire Panda */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\FirePanda\HacknSlash.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\FirePanda\HighJump.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\FirePanda\BladeThrow.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\FirePanda\ArtOfFire.j"

/* Blood Mage */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\BloodMage\Fireblast.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\BloodMage\BoonAndBane.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\BloodMage\BurningSkin.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\BloodMage\FireStorm.j"

/* Mountain Giant */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MountainGiant\Crag.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MountainGiant\HurlBoulder.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MountainGiant\CraggyExterior.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\MountainGiant\Endurance.j"

/* Farseer */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Farseer\LightningBalls.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Farseer\VoltyCrush.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Farseer\ReflectiveShield.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\Farseer\SpiritArrows.j"

/* Ogre Warrior */
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\OgreWarrior\AxeThrow.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\OgreWarrior\Decapitate.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\OgreWarrior\MightySwing.j"
//! import "C:\Users\ppuls\Desktop\Forsaken Bastion's Fall\FBF-GameData\src\Heroes\OgreWarrior\Consumption.j"