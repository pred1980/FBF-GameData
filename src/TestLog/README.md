# TestLog

`TestLog` schreibt Messwerte aus Spieltests in Dateien. Ein Mensch spielt einen Testfall, Claude oder ChatGPT wertet die Datei aus. Jeder Testfall endet mit **BESTANDEN**, **NICHT BESTANDEN** oder **NICHT BEURTEILBAR**, jeweils mit Begründung und Messwerten.

## Drei Ebenen

| Ebene | Inhalt | Lebensdauer |
|---|---|---|
| 1. Kern `TestLog.vj` | Zeilen, Testfälle, Kopfdaten, Dateiausgabe, Verlusterkennung | dauerhaft |
| 2. Beobachter `TestLog<Ereignis>.vj` | zeichnen zentrale Spielereignisse über vorhandene Schnittstellen auf | dauerhaft, nach Bedarf ergänzt |
| 3. Testfall-spezifisch | Testfälle mit Sollwerten in der PR-Beschreibung; Diagnosepunkte und Einstellungen im Code | nur im jeweiligen PR, vor dem Merge entfernt |

TestLog ist immer eingebunden und braucht keinen Schalter. Beobachter zeichnen nur während eines aktiven Testfalls auf. In normalen Spielen entsteht deshalb keine Datei.

## Ablauf eines Spieltests

1. **Vorbereitung (Agent):**
   - Der Agent analysiert die Fähigkeit oder das System und schreibt die Testfälle nach der [Vorlage](#testfall-vorlage) in die PR-Beschreibung.
   - Er prüft, welche Beobachter reichen. Nur wo Informationen fehlen, ergänzt er Diagnosepunkte oder Einstellungen wie verfolgte Buffs.
   - Danach fordert er wie üblich einen Teststand an.
2. **Spieltest (Mensch):**
   - Map speichern und starten.
   - Vor jedem Testfall `-test <ID>` eingeben, zum Beispiel `-test M3`. Den Fall spielen, dann `-test end`.
   - Bei Bedarf eine Notiz mit `-mark <Text>` setzen.
3. **Dateien:** Sie liegen unter `Dokumente\Warcraft III\CustomMapData\` als `FBF-testlog-<Sitzung>-p<Spieler>-<Teil>.txt`. Claude liest sie mit Erlaubnis direkt, oder der Mensch fügt sie in den PR ein.
4. **Auswertung (Agent):** nach den [Auswerteregeln](#auswerteregeln), mit dem Ergebnis im PR.

## Chatbefehle

Nur aktiv, wenn `SYSTEM_TEST_LOG_COMMANDS` in `src/GameConfig/SystemConfig.vj` `true` ist.

| Befehl | Wirkung |
|---|---|
| `-test <ID>` | Beginnt den Testfall `<ID>`; ein laufender Fall endet vorher. Die ID besteht aus Buchstaben und Ziffern ohne Leerzeichen. |
| `-test end` | Beendet den aktiven Testfall. |
| `-mark <Text>` | Schreibt eine Notiz und speichert sofort. |
| `-logtest` | Selbsttest, dauert etwa 5 Sekunden; am besten in einem eigenen Testfall, z. B. `-test L2`. |

## Dateien

- **Teile:** Ein Teil hat höchstens 100 Zeilen. Danach beginnt der nächste Teil (`001`, `002`, …).
- **Schreiben:**
  - Der offene Teil wird höchstens einmal pro Sekunde neu geschrieben, und nur, wenn neue Zeilen da sind.
  - `-test` und `-mark` schreiben sofort.
  - Geschlossene Teile werden nie wieder geschrieben.
  - Warcraft III kann an eine Datei nichts anhängen, deshalb wird immer der ganze offene Teil geschrieben.
- **Aufbau:** Die Datei ist ein Skript der Preload-Funktion von Warcraft III. Jede Logzeile steht darin als `call Preload( "<Zeile>" )`. Zum Auswerten nur den Text zwischen den Anführungszeichen lesen, Teil für Teil in aufsteigender Reihenfolge.

## Format (Version 1)

Jeder Teil beginnt mit zwei Kopfzeilen:

```
#FBFLOG;format=1;stand=<DEV_TEST_STAND>;version=<Kartenversion>;session=<Sitzung>;player=p<N>;part=<Teil>
#cols=seq;time;case;channel;event;key=value
```

Danach folgen Datenzeilen:

```
<seq>;<time>;<case>;<channel>;<event>[;<key>=<value>]...
```

| Spalte | Bedeutung |
|---|---|
| `seq` | Fortlaufende Nummer je Sitzung, ab 1. Auch verworfene Zeilen verbrauchen eine Nummer. |
| `time` | Spielzeit in Sekunden seit Kartenstart, drei Nachkommastellen. |
| `case` | Aktive Testfall-ID oder `-`. |
| `channel` | System oder Beobachter, z. B. `dmg` oder `godsseal`. |
| `event` | Ereignis im Kanal, z. B. `hit`. |

- **Folgezeilen:** Eine Zeile über 240 Zeichen läuft auf Folgezeilen `+<seq>;<Rest>` weiter. Der Rest wird ohne Trennzeichen an die Zeile mit derselben `seq` angehängt. Eine Zeile wird nie auf zwei Teile verteilt.
- **Werte:**
  - Zahlen mit Punkt und drei Nachkommastellen.
  - Wahrheitswerte als `1` oder `0`.
  - Einheiten als `Name#HandleId(p<N>)`. Die HandleId bezeichnet eine Einheit während eines Spiels eindeutig. `p<N>` ist der Besitzer, gezählt ab 1. `none` steht für keine Einheit.
  - Rawcodes mit vier Zeichen, z. B. `A094`. `none` steht für 0, `?` für ein Zeichen außerhalb von A–Z, a–z und 0–9.
  - In Texten wird `"` zu `'`, `\` zu `/`, `;` zu `,` und ein Zeilenumbruch zu einem Leerzeichen.
  - Ein Wert enthält nie `;`. Der Schlüssel endet am ersten `=`.
- **Stabilität:**
  - Feste Spalten behalten Reihenfolge und Bedeutung.
  - Neue Informationen kommen nur als neue Schlüssel hinzu.
  - Fehlt ein Schlüssel, wurde der Wert nicht erfasst; das ist nicht dasselbe wie 0.
  - Wer die Bedeutung eines Felds oder die festen Spalten ändert, erhöht `format`.
  - Auswerter ignorieren unbekannte Schlüssel und Kanäle.

### Reservierte Kanäle

| Kanal;Ereignis | Bedeutung | Schlüssel |
|---|---|---|
| `run;case` | Testfall beginnt | `id`, `stand` |
| `run;case_end` | Testfall endet | `id` |
| `chat;mark` | Notiz aus dem Chat | `player`, `text` |
| `log;drop` | Zeilen wurden verworfen | `reason`, `count`, bei `rate` zusätzlich `first_seq` und `last_seq` |
| `log;stop` | Der Logger hat aufgehört | `reason=max_parts` |
| `selftest;…` | Selbsttest | – |
| `dmg;hit`, `kill;death`, `cast;effect` | Beobachter | siehe unten |

Diagnosepunkte nutzen eigene Kanäle mit dem Kurznamen der Fähigkeit oder des Systems, z. B. `godsseal;break`.

## Beobachter

Ein Beobachter zeichnet nur bei aktivem Testfall auf und nur, wenn eine **relevante Einheit** beteiligt ist. Relevant sind:

- Helden,
- Einheiten menschlicher Spieler (`MAP_CONTROL_USER`),
- Einheiten, die Testcode mit `TestLog.watch(u)` markiert hat.

### `dmg;hit` – Schaden (`TestLogDamage.vj`)

Quelle ist `RegisterDamageResponse`. Die Zeile entsteht 0,05 s nach dem Treffer, `time` ist also Trefferzeit + 0,05 s. Die Reihenfolge der `seq` entspricht der Reihenfolge der Treffer.

| Schlüssel | Bedeutung |
|---|---|
| `src`, `tgt` | Quelle und Ziel |
| `src_type`, `tgt_type` | Typ-Rawcode |
| `src_hero`, `tgt_hero`, `src_bld`, `tgt_bld` | Held bzw. Gebäude |
| `rel` | Ziel aus Sicht der Quelle: `enemy`, `ally`, `self`, `neutral` oder `none` |
| `final` | Schaden nach Rüstung und Modifiern, so wie ihn die Schadensreaktionen erhalten |
| `dtype` | FBF-`DamageType`: 0 `PHYSICAL`, 1 `SPELL`, 2 `PHYSICAL_AND_SPELL` |
| `hp_before` | LP des Ziels beim Treffer, vor dem Abzug |
| `hp_after` | LP des Ziels 0,05 s später |
| `hp_loss` | `hp_before - hp_after`; enthält auch Regeneration und weiteren Schaden in diesen 0,05 s |
| `killed` | Ziel ist 0,05 s später tot |
| `src_<buff>`, `tgt_<buff>` | Stufe verfolgter Buffs beim Treffer (0 = nicht vorhanden) |
| `tgt_after_<buff>` | Stufe verfolgter Buffs am Ziel 0,05 s später |

Den Schaden vor den Modifiern gibt es in Version 1 noch nicht. Er braucht die Phasen der Bribe Damage Engine aus #31.

### `kill;death` – Tod (`TestLogKill.vj`)

Quelle ist `EVENT_PLAYER_UNIT_DEATH`. Die Zähler werden nach allen Reaktionen auf den Tod gelesen.

| Schlüssel | Bedeutung |
|---|---|
| `victim`, `killer` | Opfer und Täter (`none` ohne Täter) |
| `victim_type`, `killer_type` | Typ-Rawcode |
| `victim_hero`, `killer_hero`, `victim_bld`, `killer_bld` | Held bzw. Gebäude |
| `rel` | Opfer aus Sicht des Täters |
| `owner` | Besitzer des Täters, `p<N>` |
| `mb_hk`, `mb_ck`, `mb_tk` | Zähler dieses Spielers nach dem Tod, mit denselben Formeln wie die Multiboard-Spalten HK, CK und TK |

### `cast;effect` – Zauber (`TestLogCast.vj`)

Quelle ist `EVENT_PLAYER_UNIT_SPELL_EFFECT`. Auch Dummy-Einheiten relevanter Spieler erscheinen.

| Schlüssel | Bedeutung |
|---|---|
| `caster` | Zauberer |
| `abil`, `lvl` | Fähigkeit als Rawcode und ihre Stufe |
| `tgt`, `rel` | Zieleinheit (`none` bei Bodenziel) und ihre Beziehung zum Zauberer |
| `x`, `y` | Zielpunkt |

## Testcode: Diagnosepunkte und Einstellungen

| Aufruf | Zweck |
|---|---|
| `TestLog.row(channel, event)` … `.write()` | Zeile schreiben; dazwischen `addUnit`, `addId`, `addReal`, `addInt`, `addFlag`, `addText` |
| `TestLog.trackBuff('<Rawcode>', "<name>")` | Buff verfolgen, höchstens 8; erscheint bei `dmg;hit` |
| `TestLog.watch(u)` / `TestLog.unwatch(u)` | Einheit für die Beobachter relevant machen |
| `TestLog.beginCase(id)` / `TestLog.endCase()` | Testfall aus Code steuern |
| `TestLog.flushNow()` | Sofort schreiben |
| `TestLog.isCaseActive()`, `TestLog.relation(a, b)`, `TestLog.buffFields(prefix, u)` | Hilfen für Beobachter |

Beispiel für einen Diagnosepunkt:

```
call TestLog.row("godsseal", "break").addUnit("tgt", .target).addReal("absorbed", absorbed).write()
```

Regeln:

- Diagnosepunkte nur dort, wo Beobachter nicht reichen. Den Grund im PR nennen.
- Kanal ist der Kurzname der Fähigkeit oder des Systems, Ereignis ein kurzes Wort, Schlüssel in `snake_case`.
- Ereignisse loggen, keine Timer-Ticks. Bei Flächenschaden lieber eine zusammenfassende Zeile.
- Nie innerhalb eines `GetLocalPlayer`-Blocks aufrufen.
- Eine Library, die loggt, braucht vorübergehend `requires TestLog`; ein Scope braucht nichts.
- **Vor dem Merge entfernen.** Diese Suche muss leer sein:

  ```
  git grep -n -E "TestLog\.(row|trackBuff|watch|unwatch|beginCase|endCase|flushNow)" -- src ':!src/TestLog'
  ```

  `TestLog.setStand` in `GameStart.vj` bleibt.

## Grenzen und Verluste

| Grenze | Folge |
|---|---|
| Mehr als 100 Zeilen pro Spielsekunde | überzählige Zeilen werden verworfen, danach `log;drop;reason=rate` |
| Zeile mit `row` begonnen, aber nicht mit `write` abgeschlossen (32 Slots) | `log;drop;reason=slot` |
| 100 Teile pro Sitzung | `log;stop;reason=max_parts`, danach nichts mehr; Warnung auf dem Bildschirm |
| Zeile über 1200 Zeichen | gekürzt, mit `truncated=1` |
| Absturz oder Beenden | bis zu 1 s ohne `-mark` oder `-test end` geht verloren |

Eine Lücke in `seq` ohne passende `log;drop`-Zeile ist ein unerklärter Verlust, zum Beispiel durch einen Absturz.

Die Zeilengrenze von 240 Zeichen ist vorsichtig gewählt. `-logtest` schreibt Testzeilen verschiedener Länge (`selftest;probe`, jede endet auf `END<len>`). Daran zeigt sich, ab welcher Länge Warcraft III kürzt.

## Multiplayer

- Jeder Rechner schreibt eigene Dateien; `p<N>` im Namen ist der lokale Spieler.
- Der Zustand des Loggers ändert sich nur über Abläufe, die auf allen Rechnern gleich laufen. Zufall wird nur bei der Initialisierung gezogen.
- Lokal sind nur der Spieler im Dateinamen und in der Kopfzeile sowie das Schreiben auf die eigene Platte.
- TestLog liest keine Dateien. Nichts aus einer Datei wirkt auf das Spiel.

## Testfall-Vorlage

Jeder Testfall steht so in der PR-Beschreibung:

```markdown
### <ID> – <Kurztitel>
- **Ziel:** <was laut Beschreibung gelten soll>
- **Vorbereitung:** <Held, Stufe, Modus, Gegner/Verbündete; nötige Diagnosepunkte oder verfolgte Buffs>
- **Ablauf:** `-test <ID>`, <Aktionen>, `-test end`
- **Sollwerte:**
  - S1: <Formel mit Toleranz, z. B. `hp_loss = final ± 0,1` für jede `dmg;hit`-Zeile mit `tgt_bb >= 1`>
- **Pflichtbeobachtungen:**
  - P1: <z. B. mindestens 3 Treffer mit aktivem Effekt>
  - P2: <Sonderfall, z. B. ein Treffer, der ohne Effekt tödlich wäre>
- **Verboten:**
  - V1: <z. B. `dmg;hit` mit `rel=ally` von diesem Zauber>
- **Datenquellen:** <Kanäle und Schlüssel>
```

## Auswerteregeln

Jedes Kriterium (S, P, V) bekommt ein Teilergebnis:

- **NICHT BESTANDEN:** Ein Messwert widerspricht einem Sollwert außerhalb der Toleranz, oder ein verbotenes Ereignis tritt auf. Beleg mit `seq`.
- **NICHT BEURTEILBAR:** Eines der folgenden trifft zu:
  - Eine Pflichtbeobachtung oder ein Sonderfall fehlt oder ist zu selten.
  - Ein benötigtes Feld fehlt.
  - Im Zeitraum des Falls gibt es Verluste: `log;drop`, `log;stop` oder unerklärte Lücken in `seq`.
  - Die Zuordnung ist mehrdeutig.
  - Ein Sollwert hängt an Object-Editor-Daten, die weder im Repo noch im Log stehen.
- **BESTANDEN:** Alle Pflichtbeobachtungen liegen vor, alle Messwerte liegen innerhalb der Toleranz, und kein verbotenes Ereignis tritt auf.

Das Ergebnis eines Falls ist das schlechteste Teilergebnis, in der Rangfolge NICHT BESTANDEN, dann NICHT BEURTEILBAR, dann BESTANDEN. Nicht Beobachtetes gilt nie als bestanden. Ein belegter Widerspruch ergibt NICHT BESTANDEN, auch wenn andere Daten fehlen.

Vor der Auswertung prüfen:

- `stand` in der Kopfzeile ist der angeforderte Teststand.
- Für jeden Fall gibt es `run;case` und `run;case_end`.
- `seq` ist lückenlos, oder jede Lücke ist durch `log;drop` erklärt.

Ausgabe:

- eine Tabelle `Fall | Ergebnis | Begründung | Messwerte (mit seq)`;
- die ausgewerteten Dateien mit Sitzung, Teilen und `stand`.

## Erweitern

- **Neuer Beobachter:**
  - Er kommt als neue Datei `src/TestLog/TestLog<Ereignis>.vj` mit `requires TestLog` und der genutzten Schnittstelle.
  - Er zeichnet nur bei `TestLog.isCaseActive()` und für relevante Einheiten auf und hat einen eigenen Kanal.
  - Seine Felder stehen in dieser README, sein Import im Abschnitt `/* Test Log */` von `src/imports.j`.
- **Neuer Feldtyp:** eine neue Methode `add<Typ>` im Kern; das Format bleibt Version 1.
- **Erst bei konkretem Bedarf:** Buff-Start und -Ende, Heilung, Items, Befehle/KI, Geschosse, Gold/XP, Schaden vor den Modifiern, ein Auswerteskript, Umzug des `PerformanceLog` aus #30.
