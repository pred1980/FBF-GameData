# CLAUDE.md

Diese Datei hilft Claude Code bei der Arbeit an diesem Repository.

@AGENTS.md

`AGENTS.md` ist die zentrale Quelle für gemeinsame Regeln. Dort stehen der geprüfte Ablauf zum Bauen und Testen, die Regeln für Prüfberichte sowie die Vorgaben für Code und Commits. Diese Datei ergänzt nur Hinweise für Claude Code und den Aufbau des Spiels.

## Das Spiel

*Forsaken Bastion's Fall* (FBF) ist eine Warcraft-III-Karte. Sie verbindet Tower Defense mit Kämpfen zwischen Helden der **Forsaken** (Untote) und der **Coalition** (Menschen, Orks und Nachtelfen). Der Spielcode liegt überwiegend als vJASS (`.vj`) unter `src/`. `FBF_v0.4.9_dev.w3x` ist ein binäres MPQ-Archiv. Es enthält Gelände, Regionen (`gg_rct_*`) und Objektdaten.

## Einbindung beim Kompilieren

- `src/imports.j` bindet Dateien mit `//! import "<absolute path>"` ein. Abschnittskommentare ordnen die Einträge. Ergänze neue Dateien im passenden Abschnitt und in derselben Form. JassHelper ermittelt die Reihenfolge der Bibliotheken aus `requires`, `needs` und `uses`, auch mit `optional`. Die Position in `imports.j` bestimmt diese Reihenfolge nicht.
- Zwei `.vj`-Dateien sind derzeit nicht eingebunden und gehören daher nicht zur Karte: `Libraries/XE/BezierMissiles.vj` ist eine bytegleiche Kopie von `Libraries/BezierMissiles.vj`. `Libraries/CheckImmunity.vj` ist ein unfertiger Entwurf mit dem ungültigen Library-Namen `SpellHelper.restoreMana`.
- `.w3x`-Dateien sind binär. Bearbeite, erzeuge oder speichere sie nicht mit Agent-Werkzeugen.

## Code und Objektdaten

Objektdaten für Einheiten, Helden, Fähigkeiten, Gegenstände und Buffs liegen nur in der `.w3x`. Der Code nutzt vierstellige Rawcodes wie `'A07K'`, `'H00Y'` und `'u00R'` sowie Order-Strings wie `"roar"`. Oft stehen diese Werte als `private constant` im `globals`-Block einer Datei. Rawcodes lassen sich aus dem Repository allein nicht prüfen. Suche deshalb vor einer Änderung alle weiteren Verwendungen. `src/TowerSystems/TowerIds.txt` ordnet Turm-Rawcodes den Namen zu. Tabellen unter `documentation/FBF-ProjectFiles/` enthalten Entwurfsdaten zu Helden, Fähigkeiten, Creeps und Türmen.

## Start des Spiels

1. Das `onInit`-Modul in `GameConfig` ruft `GetHost()`, `GoldIncome.initialize()` und `GameStart.initialize()` auf.
2. `GameStart` zeigt Titel und Version an. Die Konstanten `NAME`, `VERSION` und `RELEASE_DATE` stehen dort. Danach ruft es `Game.initialize()` auf.
3. `Game` (`GameConfig/Game.vj`) erfasst Spieler, markiert Computerplätze in `Game.isBot[]`, setzt Bündnisse und registriert Ereignisse für Tod, Stufenaufstieg und Verlassen des Spiels. Danach öffnet es den Tutorial-Dialog.
4. Sobald alle Spieler den Dialog beantwortet haben, startet `GameModule.initialize()` (`GameConfig/GameModules.vj`) die Systeme: Multiboard, Gegenstände, Heldenwahl, Türme, Creep-KI (`KI`), Teleports, Verteidigungsmodus, Kamera und weitere. **Neue Systeme werden hier eingebunden.**
5. Wenn ein Bot seinen Helden erhält, verbindet `RunHeroAI(hero)` in `HeroSystems/HeroPickMods.vj` den Helden mit seiner KI.

Die Creep-Spieler heißen Neutral Extra und Neutral Victim. Sie sind mit den Forsaken beziehungsweise der Coalition verbündet. `Game.initialize` benennt sie in `"The Forsaken"` und `"The Coalition"` um. Spielmodi, Spieltypen und Verteidigungsmodi sind Tabellen mit `struct … extends array`. Sie werden in `onInit` gefüllt (`GameConfig/GameModes.vj`, `GameTypes.vj`, `DefenseModes.vj`). `IS_DEBUG_MODE` in `GameConfig/GameConfig.vj` aktiviert Testhilfen. Dazu gehören ein fest gewählter Zufallsheld, kurze Zeiten für Heldenwahl und Runden sowie Debug-Meldungen.

## Fähigkeiten der Helden

Jede Fähigkeit hat meist einen eigenen `scope` unter `src/Heroes/<Hero>/<Ability>.vj`, oft mit `scope <Ability> initializer init`. Eine solche Datei enthält meist:

- einen Kopfkommentar mit Beschreibung und datierten Änderungen;
- einen `globals`-Block mit `private constant`-Werten wie `SPELL_ID`, `DUMMY_SPELL`, `ORDER_ID`, Effektpfaden und Radien;
- `private constant function`-Funktionen für Werte je Fähigkeitsstufe;
- einen `private struct` für den Zustand eines Einsatzes.

Häufig genutzte Bausteine sind die xe-Bibliotheken (`xedamage`, `xecast`, `xefx`, `xemissile`), `TimerUtils` (`NewTimer`, `ReleaseTimer`, `GetTimerData`), `RegisterPlayerUnitEvent`, `SpellHelper.isValidEnemy` und `ENUM_GROUP` aus `GroupUtils`. Vor Schaden setzt eine Fähigkeit die globale Variable `DamageType` auf `PHYSICAL`, `SPELL` oder `PHYSICAL_AND_SPELL`. Diese Werte stehen in `Libraries/DamageEvent.vj`. Systeme wie `DamageOverTime` lesen sie. Fähigkeiten für Gegenstände unter `src/ItemAbilities/` folgen einem ähnlichen Aufbau.

## Helden-KI

`src/AI-Systems/HeroAI.vj` (Library `HeroAI`) definiert `module HeroAI`. Die KI wechselt regelmäßig zwischen `STATE_ENGAGED` (Kampf), `STATE_GO_SHOP` (Einkauf), `STATE_RUN_AWAY` (Flucht), `STATE_GO_TELEPORT` (Teleport) und `STATE_IDLE` (Leerlauf). Sie erfasst nahe Verbündete und Gegner, kauft Gegenstände und lernt Fähigkeiten. `HeroAIPriority`, `HeroAIThreat` und `HeroAIEventResponse` werden mit `implement optional` eingebunden. Die Textmacros `HeroAILearnset.vj` und `HeroAIItem.vj` werden in `HeroAI.vj` eingesetzt. `src/AI-Systems/README.md` beschreibt die KI auf Deutsch.

Die KI eines Helden liegt unter `src/AI-Systems/HeroesAI/<Hero>AI.vj`:

- Ein `scope <Hero>AI` enthält einen `private struct AI extends array`. Der Struct steuert Fähigkeiten und füllt in `onInit` die Listen für gelernte Fähigkeiten, Gegenstände und Schwierigkeitsgrade. Am Ende steht `implement HeroAI`.
- Danach folgt `//! runtextmacro HeroAI_Register("HERO_ID")`. Ohne registrierte KI nutzt ein Held `DefaultHeroAI`.
- Die Arrays für Schwierigkeitsgrade nutzen `aiLevel`: 0 = `easy` (leicht), 1 = `normal`, 2 = `insane` (sehr schwer). Die Arrays für Abklingzeiten nutzen die Fähigkeitsstufe minus 1 als Index.
- Die KI-Datei wiederholt `SPELL_ID`, Order-String und Radien der Fähigkeit. Beispielsweise entspricht `F_RADIUS` in der Archmage-KI dem Wert `RAIN_AOE` in `Fireworks.vj`. **Wenn du Rawcode, Order-String oder Radius einer Fähigkeit änderst, passe auch die passende `<Hero>AI.vj` an.** Mehrere Änderungsprotokolle nennen Order-IDs, die für das KI-System geändert wurden.

Die Turmbau-KI liegt in `AI-Systems/AI-TowerBuilder.vj` (`TowerBuildAI`, `TowerAIEventListener`). Die gewichteten Baulisten je Schwierigkeitsgrad stehen in `TowerSystems/TowerConfig.vj`. Die Creep-KI liegt in `AI-Systems/AI-Creeps.vj` (`struct KI`).
