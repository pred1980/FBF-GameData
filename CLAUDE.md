# CLAUDE.md

Diese Datei hilft Claude Code bei der Arbeit in diesem Repository.

@AGENTS.md

`AGENTS.md` ist die gemeinsame Quelle für Repository-Regeln: Build, Spieltests, sichere Änderungen, Tickets, Code-Stil und Commits. Diese Datei ergänzt nur Hinweise für Claude Code und erklärt den Aufbau des Spielcodes.

## Hinweise für Claude Code

- `/implement-ticket <n>`, `/review-pr <n>` und `/safe-vjass-change` sind Wrapper unter `.claude/skills/`. Die maßgeblichen Skills liegen unter `.agents/skills/`. Bearbeite die maßgeblichen Dateien, nicht die Wrapper.
- Die Tools Edit und Write lesen Dateien als UTF-8. Bei Windows-1252 ersetzen sie Umlaute durch U+FFFD und speichern danach UTF-8. Das wurde mit `src/GameConfig/GameConfig.vj` geprüft. Nutze für solche Dateien den `iconv` Ablauf aus `safe-vjass-change`. Das Edit Tool erhält CRLF Zeilenenden.

## Das Projekt

Forsaken Bastion's Fall (FBF) ist eine Warcraft III Custom Map. Sie verbindet Tower Defense mit AoS Hero PvP zwischen zwei Fraktionen: den **Forsaken** (Undead Spieler) und der **Coalition** (Human, Orc und Night Elf Spieler). Der Spielcode liegt hauptsächlich als vJASS (`.vj`) unter `src/`. `FBF_v0.4.9_dev.w3x` ist ein binäres MPQ Archiv mit Terrain, Regionen (`gg_rct_*`) und Object Data.

## Dateien beim Build

- `src/imports.j` listet jede eingebundene Datei als `//! import "<absolute path>"`, geordnet nach Abschnitten. Füge neue Dateien im passenden Abschnitt hinzu. JassHelper bestimmt die Reihenfolge der Libraries aus `requires`/`needs`/`uses`, auch mit `optional`, und nicht aus der Reihenfolge in `imports.j`.
- Zwei `.vj` Dateien sind derzeit nicht eingebunden und gehören daher nicht zur Map: `Libraries/XE/BezierMissiles.vj` ist eine bytegleiche Kopie der eingebundenen `Libraries/BezierMissiles.vj`. `Libraries/CheckImmunity.vj` ist ein unfertiger Stub mit dem ungültigen Library Namen `SpellHelper.restoreMana`.

## Code und Object Data

Object Data für Units, Heroes, Abilities, Items und Buffs liegt nur in der `.w3x`. Code verweist darauf mit vierstelligen Rawcodes wie `'A07K'`, `'H00Y'` und `'u00R'` sowie Order-Strings wie `"roar"`. Diese Werte stehen als `private constant` im `globals` Block der jeweiligen Datei. Prüfe vor einer Änderung alle anderen Verwendungen im Repository. `src/TowerSystems/TowerIds.txt` ordnet Tower Rawcodes ihren Namen zu. Design-Daten zu Helden, Fähigkeiten, Creeps und Towers stehen in Tabellen unter `documentation/FBF-ProjectFiles/`.

## Startablauf

1. Das `onInit` Modul in `GameConfig` ruft `GetHost()`, `GoldIncome.initialize()` und `GameStart.initialize()` auf.
2. `GameStart` zeigt Titel und Version an. Die Konstanten `NAME`, `VERSION` und `RELEASE_DATE` liegen dort. Danach ruft es `Game.initialize()` auf.
3. `Game` (`GameConfig/Game.vj`) sammelt die Spieler, markiert Computerplätze in `Game.isBot[]`, setzt Allianzen, registriert Death, Level-up und Leave Events und öffnet den Tutorial Dialog.
4. Sobald alle Spieler den Dialog beantwortet haben (`DialogSystem/Dialog.vj`), startet `GameModule.initialize()` (`GameConfig/GameModules.vj`) die Systeme: Multiboard, Items, Hero Pick, Towers, Creep AI (`KI`), Teleports, Defense Mode, Kamera und weitere. Neue Systeme werden hier eingebunden.
5. Wenn in `HeroSystems/HeroPickMods.vj` ein Bot Hero erstellt wird, verbindet `RunHeroAI(hero)` ihn mit der Hero AI.

Die Creep Spieler sind Neutral Extra und Neutral Victim. Sie sind mit den Forsaken beziehungsweise der Coalition verbündet. `Game.initialize` benennt sie in "The Forsaken" und "The Coalition" um. Game Modes, Game Types und Defense Modes sind `struct ... extends array` Tabellen. Sie werden in `onInit` gefüllt (`GameConfig/GameModes.vj`, `GameTypes.vj`, `DefenseModes.vj`). `IS_DEBUG_MODE` in `GameConfig/GameConfig.vj` aktiviert Testhilfen wie einen festen zufälligen Hero, kurze Hero Pick und Runden Timer sowie Debug Meldungen.

## Hero Fähigkeiten

Jede Fähigkeit hat meist einen eigenen `scope` in `src/Heroes/<Hero>/<Ability>.vj`, oft als `scope <Ability> initializer init`. Er enthält:

- einen Kopfkommentar mit Beschreibung und datiertem Changelog;
- einen `globals` Block mit `private constant` Werten (`SPELL_ID`, `DUMMY_SPELL`, `ORDER_ID`, Effektpfade, Radien);
- `private constant function` für Werte je Level;
- einen `private struct` für den Zustand eines Casts.

Häufig genutzte Bausteine sind die xe Libraries (`xedamage`, `xecast`, `xefx`, `xemissile`), `TimerUtils` (`NewTimer`/`ReleaseTimer`/`GetTimerData`), `RegisterPlayerUnitEvent`, `SpellHelper.isValidEnemy` und `ENUM_GROUP` aus `GroupUtils`. Vor Schaden setzt eine Fähigkeit das globale `DamageType` (`PHYSICAL`/`SPELL`/`PHYSICAL_AND_SPELL`, definiert in `Libraries/DamageEvent.vj`). Systeme wie `DamageOverTime` lesen diesen Wert. Item Fähigkeiten unter `src/ItemAbilities/` folgen demselben Muster.

## Hero AI

`src/AI-Systems/HeroAI.vj` (Library `HeroAI`) definiert `module HeroAI`. Diese Zustandsmaschine läuft regelmäßig und kennt die Zustände engaged, go shop, run away, go teleport und idle. Sie erfasst nahe Verbündete und Gegner, kauft Items und lernt Fähigkeiten. `HeroAIPriority`, `HeroAIThreat` und `HeroAIEventResponse` werden mit `implement optional` eingebunden. Die Textmacros `HeroAILearnset.vj` und `HeroAIItem.vj` werden in `HeroAI.vj` erweitert. `src/AI-Systems/README.md` erklärt das Design auf Deutsch.

Die AI eines Heroes steht in `src/AI-Systems/HeroesAI/<Hero>AI.vj`; beim Behemoth heißt die Datei `BehemotAI.vj`:

- Ein `scope <Hero>AI` enthält einen `private struct AI extends array`. Er enthält die Logik für Fähigkeiten und füllt Learnsets, Itemsets und Arrays je Schwierigkeitsgrad in `onInit`. Am Ende steht `implement HeroAI`.
- Danach folgt `//! runtextmacro HeroAI_Register("HERO_ID")`. Ohne registrierte AI wird `DefaultHeroAI` genutzt.
- Die Arrays für Schwierigkeitsgrade nutzen `aiLevel`: 0 = easy, 1 = normal, 2 = insane. Cooldown Arrays nutzen Ability Level minus 1 als Index.
- Die AI Datei wiederholt `SPELL_ID`, Order-String und Radien der Fähigkeit. Zum Beispiel entspricht `F_RADIUS` in der Archmage AI dem Wert `RAIN_AOE` in `Fireworks.vj`. Einige Changelogs der Fähigkeiten nennen geänderte Order IDs "for AI System". Passe bei Änderungen beide Seiten an.

Die Tower AI steht in `AI-Systems/AI-TowerBuilder.vj` (`TowerBuildAI`, `TowerAIEventListener`). Gewichtete Baulisten je AI Level stehen in `TowerSystems/TowerConfig.vj`. Die Creep AI steht in `AI-Systems/AI-Creeps.vj` (`struct KI`).
