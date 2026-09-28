# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@AGENTS.md

`AGENTS.md`, imported above, is the single source for the verified build and playtest workflow, the rules for reporting verification, and the coding and commit conventions. This file adds how the code fits together.

## What this is

Forsaken Bastion's Fall (FBF) is a Warcraft III custom map that combines tower defense with AoS-style hero PvP between two factions: the **Forsaken** (Undead players) and the **Coalition** (Human, Orc and Night Elf players). Gameplay code lives in `src/`, primarily as vJASS (`.vj` files). The map `FBF_v0.4.9_dev.w3x` is a binary MPQ archive that holds the terrain, the regions (`gg_rct_*`) and all object data.

## Compile model

- `src/imports.j` lists every compiled file as `//! import "<absolute path>"`, grouped under section comments; add new entries in the same form under the matching section. JassHelper works out library order from `requires`/`needs`/`uses` (including `optional`), not from the position in `imports.j`.
- Two `.vj` files are currently not imported and so are not part of the map: `Libraries/XE/BezierMissiles.vj`, a byte-identical copy of the imported `Libraries/BezierMissiles.vj`, and `Libraries/CheckImmunity.vj`, an unfinished stub with the invalid library name `SpellHelper.restoreMana`.
- The `.w3x` files are binary. Never edit, regenerate or re-save them with tools.

## Code and object data

Object data (units, heroes, abilities, items, buffs) exists only inside the `.w3x`. Code refers to it through four-character raw codes (`'A07K'`, `'H00Y'`, `'u00R'`) and order strings (`"roar"`). These are declared as `private constant`s in each file's `globals` block. A raw code cannot be verified from the repo, so before changing one, grep for every other file that uses it. `src/TowerSystems/TowerIds.txt` maps tower raw codes to tower names. Design data (hero stats, skill descriptions, creep and tower tables) is in spreadsheets under `documentation/FBF-ProjectFiles/`.

## Startup flow

1. The `onInit` module in `GameConfig` calls `GetHost()`, `GoldIncome.initialize()` and `GameStart.initialize()`.
2. `GameStart` shows the title and version texts (the `NAME`, `VERSION` and `RELEASE_DATE` constants live here), then calls `Game.initialize()`.
3. `Game` (`GameConfig/Game.vj`) collects the players, marks computer slots in `Game.isBot[]`, sets alliances, registers the death, level-up and leave events, then opens the tutorial dialog.
4. Once every player has answered the dialog (`DialogSystem/Dialog.vj`), `GameModule.initialize()` (`GameConfig/GameModules.vj`) starts every subsystem: multiboard, items, hero pick, towers, creep AI (`KI`), teleports, defense mode, camera and so on. **A new system is wired in here.**
5. When a bot's hero is created in `HeroSystems/HeroPickMods.vj`, `RunHeroAI(hero)` attaches the hero AI.

The creep players are Neutral Extra and Neutral Victim. They are allied with the Forsaken and with the Coalition respectively, and `Game.initialize` renames them "The Forsaken" and "The Coalition". Game modes, game types and defense modes are `struct … extends array` tables filled in `onInit` (`GameConfig/GameModes.vj`, `GameTypes.vj`, `DefenseModes.vj`). `IS_DEBUG_MODE` in `GameConfig/GameConfig.vj` turns on test shortcuts across systems, such as a fixed random hero, short hero-pick and round timers, and debug messages.

## Hero abilities

Each ability is one scope in `src/Heroes/<Hero>/<Ability>.vj`, usually declared as `scope <Ability> initializer init`. It contains:

- a header comment with a description and a dated changelog;
- a `globals` block of `private constant` settings (`SPELL_ID`, `DUMMY_SPELL`, `ORDER_ID`, effect paths, radii);
- `private constant function`s for level scaling;
- a `private struct` that holds the state of one cast.

Common building blocks are the xe libraries (`xedamage`, `xecast`, `xefx`, `xemissile`), `TimerUtils` (`NewTimer`/`ReleaseTimer`/`GetTimerData`), `RegisterPlayerUnitEvent`, `SpellHelper.isValidEnemy` and `ENUM_GROUP` from `GroupUtils`. Before an ability deals damage it sets the global `DamageType` (`PHYSICAL`/`SPELL`/`PHYSICAL_AND_SPELL`, defined in `Libraries/DamageEvent.vj`), and systems like `DamageOverTime` read it. Item abilities in `src/ItemAbilities/` follow the same pattern.

## Hero AI

`src/AI-Systems/HeroAI.vj` (library `HeroAI`) defines `module HeroAI`, a periodic state machine with the states engaged, go shop, run away, go teleport and idle. It tracks nearby allies and enemies, buys items and learns skills. `HeroAIPriority`, `HeroAIThreat` and `HeroAIEventResponse` are pulled in with `implement optional`. `HeroAILearnset.vj` and `HeroAIItem.vj` are textmacros expanded inside `HeroAI.vj`. `src/AI-Systems/README.md` documents the design in German.

Each hero's AI lives in `src/AI-Systems/HeroesAI/<Hero>AI.vj`:

- It is a `scope <Hero>AI` containing a `private struct AI extends array`. The struct holds the ability-casting logic and fills the learnsets, itemsets and per-difficulty arrays in `onInit`. It ends with `implement HeroAI`.
- After the struct comes `//! runtextmacro HeroAI_Register("HERO_ID")`. A hero with no registered AI falls back to `DefaultHeroAI`.
- Difficulty arrays are indexed by `aiLevel`: 0 = easy, 1 = normal, 2 = insane. Cooldown arrays are indexed by ability level − 1.
- The AI file repeats the ability's `SPELL_ID`, order string and radii. For example, `F_RADIUS` in the Archmage AI mirrors `RAIN_AOE` in `Fireworks.vj`. **If you change an ability's raw code, order string or area, change the matching `<Hero>AI.vj` too.** Several ability changelogs record order IDs being changed "for AI System".

The tower-building AI is `AI-Systems/AI-TowerBuilder.vj` (`TowerBuildAI`, `TowerAIEventListener`). Its weighted build lists per AI level are in `TowerSystems/TowerConfig.vj`. The creep AI is `AI-Systems/AI-Creeps.vj` (`struct KI`).
