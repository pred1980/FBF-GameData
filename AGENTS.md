# Regeln für das Repository

Diese Datei enthält die gemeinsamen Regeln für alle Coding-Agents. Codex liest sie direkt; Claude Code bindet sie über `CLAUDE.md` ein. `CLAUDE.md` erklärt zusätzlich die Architektur. Lies vor größeren Änderungen am Spiel den passenden Abschnitt dort. Der Ablauf für Menschen steht in `WORKFLOW.md`.

## Projektaufbau

Dieses Repository enthält die Warcraft-III-Karte *Forsaken Bastion's Fall*.

Die aktuelle Entwicklungskarte liegt im Hauptverzeichnis und folgt dem
Namensschema `FBF_v<Version>_dev.w3x`. Sie ist die Map, die im aktuellen
World Editor bearbeitet, gespeichert und getestet wird. Ermittle die aktuelle
Version aus dem Dateinamen, zum Beispiel mit `ls FBF_v*_dev.w3x`. Trage sie
nicht fest in dauerhafte Dokumentation ein.

Zusätzlich kann im Hauptverzeichnis eine versionierte `Working copie` liegen.
Sie stammt aus dem früheren Entwicklungsablauf und wurde als Sicherheitskopie
verwendet, weil das Speichern einer Map im Editor früher zu beschädigten oder
nicht mehr weiter bearbeitbaren Ständen führen konnte.

Ob diese zusätzliche Sicherheitskopie mit dem heutigen World Editor noch nötig
ist, wurde noch nicht geprüft. Bis die heutige Backup- und Versionsstrategie
geklärt ist, darf eine solche Datei nicht gelöscht, ersetzt oder als
überflüssig behandelt werden.

In `release/` liegen ältere veröffentlichte `.w3x`-Versionen.

Der Spielcode besteht vor allem aus vJASS Dateien (`.vj`) unter `src/`. `src/Heroes/<Hero>/` enthält Fähigkeiten, `src/AI-Systems/` die Hero AI und Tower AI, und `src/Libraries/` gemeinsame Bibliotheken. `src/imports.j` ist die Liste der Dateien, die in die Map eingebunden werden. `src/TowerSystems/TowerIds.txt` ordnet Tower Rawcodes ihren Namen zu.

`documentation/` enthält ältere und ergänzende Materialien: Grafiken, Tabellen zu Helden, Fähigkeiten, Creeps und Towers, eine archivierte PHP Website und `FBF-ProjectFiles/FBF_TestMap/`. Diese Wurst Test Map gehört nicht zum Build. Ändere `documentation/` nur, wenn ein Ticket es verlangt. Neuer Spielcode gehört zum passenden System unter `src/`.

## Sprache

- Inhalte für Menschen stehen in einfachem Deutsch. Dazu gehören Dokumentation im Repository, GitHub Issues, Beschreibungen von Pull Requests, Reviews, Commit-Nachrichten und Zusammenfassungen von Agents.
- Prompts und Anweisungen für Maschinen, etwa in `SKILL.md` Dateien, dürfen in klarem, strukturiertem Englisch stehen, wenn das zuverlässiger ist.
- Übersetze keine technischen Bezeichner: Pfade, Dateinamen, Rawcodes wie `'A07K'`, Order-Strings wie `"roar"`, Befehle, APIs, Warcraft III Natives und Code-Symbole bleiben unverändert.
- Ändere bestehenden Quellcode nicht nur, um Kommentare zu übersetzen. Neue oder ohnehin geänderte Code-Kommentare schreibst du nach Möglichkeit in einfachem Deutsch.
- Wenn eine Datei nur ASCII enthalten darf, etwa eine neue `.vj` Datei, schreibe Umlaute als `ae`, `oe`, `ue` und `ss`. Deutscher Text darf das Encoding einer Datei nicht ändern; für Windows-1252 Dateien gilt der `iconv` Ablauf aus `safe-vjass-change`.

## Build und Prüfung

Es gibt keinen CLI Build für das ganze Repository und keine automatischen Tests für das Spiel. Erfinde oder empfehle dafür keine Befehle. Der geprüfte Ablauf ist:

1. Bearbeite den vJASS Code unter `src/`.
2. Trage jede neue `.vj` Datei in `src/imports.j` ein. Ohne diesen Eintrag wird sie nicht in die Map eingebunden.
3. Öffne `FBF_v<Version>_dev.w3x` im aktuellen Warcraft III World Editor. Dort sind JassHelper und pJASS enthalten. Aktiviere `Enable JassHelper` und `Enable vJASS` und speichere die Map. Das Speichern ist der eigentliche Build.
4. Starte die Map aus dem Editor und teste die Änderung in Warcraft III. Das ist die Prüfung im laufenden Spiel.

`src/imports.j` enthält absolute Windows Pfade zu einem bestimmten Checkout. An einem anderen Ort muss das Pfadpräfix vor dem Build lokal angepasst werden. Committe diese lokale Anpassung nie. Das Skript `stage-imports-with-head-prefix.sh` aus `safe-vjass-change` stagt `src/imports.j` mit dem eingecheckten Präfix und lässt die lokale Arbeitskopie unverändert. Es bricht ohne Staging ab, wenn es keinen sicheren Stand bestimmen kann. Stelle die Einträge erst dann auf relative Pfade oder ein anderes Schema um, wenn das im aktuellen Editor nachweislich funktioniert.

`git status --short` zeigt Änderungen vor einem Commit. `git diff --check` findet Fehler bei Leerzeichen. `.gitattributes` leitet neue oder geänderte `*.psd` Dateien zu Git LFS. Die bereits vorhandenen PSD Dateien sind normale Git Blobs (`git lfs ls-files` zeigt keine Dateien). Für sie ist `git lfs pull` nicht nötig.

## Code-Stil und Dateiformat

Nutze `.vj` für vJASS Module und übernimm die Einrückung der jeweiligen Datei. Im bestehenden Code gibt es Tabs und Leerzeichen; formatiere andere Zeilen nicht nebenbei um. Halte dich an die vorhandenen Regeln für `scope`/`library`, `struct` und `private`. Nutze sprechende PascalCase Namen wie `HeroAIThreat.vj` oder `Cleave.vj`. Rawcodes und zugehörige Konstanten stehen nahe bei der Fähigkeit, die sie nutzt. Es gibt keinen Formatter oder Linter für das ganze Projekt. Bestehende Kommentare sind teils deutsch, teils englisch. Für neue Kommentare gilt der Abschnitt „Sprache“.

**Encoding:** Die meisten Quelldateien sind UTF-8 oder ASCII. Einige `.vj` Dateien mit deutschen Umlauten sind Windows-1252, etwa `src/GameConfig/GameConfig.vj`. Erhalte das Encoding jeder Datei. Edit Tools, die solche Dateien als UTF-8 lesen, beschädigen die Umlaute. Bearbeite sie über eine UTF-8 Kopie, wie in `safe-vjass-change` beschrieben. Neue `.vj` Dateien enthalten nur ASCII.

**Zeilenenden:** `* text=auto` speichert Textdateien im Repository mit LF. Windows Checkouts mit `core.autocrlf=true` erhalten CRLF. Shell Skripte (`*.sh`) haben immer LF. Erhalte die Zeilenenden einer Datei und mische LF und CRLF nicht.

## Änderungen sicher durchführen

- **Rawcodes und Order-Strings:** Object Data für Units, Abilities, Items und Buffs liegt nur in der `.w3x`. Der Code nutzt Rawcodes wie `'A07K'` und Order-Strings wie `"roar"`. Das Repository allein kann ihre Gültigkeit nicht bestätigen. Suche vor einer Änderung alle Verwendungen unter `src/`.
- **Hero AI:** Jede Datei `src/AI-Systems/HeroesAI/<Hero>AI.vj` wiederholt Spell IDs, Order-Strings, Radien und Cooldowns der Fähigkeiten unter `src/Heroes/<Hero>/`. Passe bei einer Änderung beide Seiten an.
- **Gemeinsame Bibliotheken:** Suche vor einer Änderung unter `src/Libraries/` oder an einem anderen gemeinsamen System alle Nutzer. Berücksichtige auch `optional` Anforderungen, Module und Textmacros.
- **Map Dateien:** Bearbeite, erzeuge, speichere, benenne oder lösche `.w3x` Dateien nie mit Tools. Nenne nötige Änderungen im Object Editor für einen Menschen.

Der Skill `safe-vjass-change` enthält dazu eine Checkliste und statische Prüfungen.

## Tests und Ergebnisse

Es gibt keine automatischen Spieltests und kein Coverage Ziel. Bei Änderungen am Spiel muss ein Mensch die Map im Editor speichern und den betroffenen Helden, das System oder den Spielmodus testen. Beschreibe Szenario und Ergebnis im Pull Request. `documentation/FBF-Website/tests/phpunit.xml` gehört nur zur archivierten PHP Website und testet die Map nicht.

Agents können die Map nicht nachweislich kompilieren oder starten. `git diff --check`, Suchen im Code und die Skripte aus `safe-vjass-change` beweisen weder einen erfolgreichen Build noch korrektes Verhalten im Spiel. Behaupte das nur, wenn ein Mensch das Speichern oder den Spieltest durchgeführt und das Ergebnis gemeldet hat. Sonst sage ausdrücklich, dass beides offen ist, und nenne das nötige Testszenario.

## Tickets und Agent-Workflow

- Jedes neue GitHub Ticket muss `.github/TICKET-STANDARD.md` folgen.
- Ein Issue bekommt einen Branch und einen Pull Request. Erstelle den Branch von `origin/master` als `<type>/issue-<n>-<short-slug>` mit `feature`, `fix`, `docs` oder `chore`. Committe nie auf `master`.
- Bei einem Auftrag zur Umsetzung darf ein Agent auf dem Issue Branch committen, pushen und einen PR gegen `master` mit `Closes #<n>` öffnen. `implement-ticket` merged nie, pusht nie auf `master`, aktiviert kein Auto-Merge und genehmigt den eigenen PR nicht. `review-pr` darf erst nach Review und allen nötigen Prüfungen genehmigen und mergen.
- Verwirf, stashe oder committe keine fremden lokalen Änderungen. Stage nur ausdrücklich genannte Pfade.
- Der Project Status im Project `Forsaken Bastion's Fall` folgt dem Ablauf: `Todo` für ein neues Ticket, `In Progress` bei Beginn der Umsetzung, `Done` nach dem Merge. Die Befehle stehen in `.github/TICKET-STANDARD.md`. Kann ein Agent den Status nicht setzen, nennt er die offene Aktion ausdrücklich.
- Nach dem Merge löscht `review-pr` den Branch des PRs, wenn das sicher ist. `master` wird nie gelöscht. Lokale Änderungen werden nie verworfen.
- `implement-ticket` beschreibt die Umsetzung und die PR Vorlage. `review-pr` beschreibt Review, Freigabe, Merge und das Aufräumen danach.

Die Skills nutzen das Agent Skills Format (`SKILL.md`). Die maßgeblichen Dateien liegen unter `.agents/skills/<name>/`; Codex findet sie dort. `.claude/skills/<name>/SKILL.md` enthält schlanke Wrapper für Claude Code. Bearbeite nur die maßgebliche Datei. `name` und `description` im Wrapper müssen mit ihr übereinstimmen.

## Commits und Pull Requests

Commit-Nachrichten verwenden einfaches Deutsch. Beginne die kurze erste Zeile mit einem klaren Verb und beschreibe konkret die Änderung. Setze keinen Punkt ans Ende. Vermeide vage Betreffzeilen wie `Update`, `Changes`, `Fix stuff` oder `WIP`. Präfixe wie `feat:`, `fix:` oder `docs:` sind nicht nötig. Technische Bezeichner bleiben unverändert. Die Ticketnummer muss nicht im Commit-Betreff stehen.

Gute Beispiele:

- `Ergänze gemeinsamen Agent-Workflow`
- `Dokumentiere Ticket-Standard`
- `Behebe Zielauswahl der Archmage-KI`
- `Prüfe Rawcodes der Turm-Upgrades`

Fasse im Pull Request die Änderung zusammen. Nenne Ergebnisse für Build und Spieltest oder sage, dass sie noch offen sind. Verlinke das Issue. Bei sichtbaren Änderungen an Spiel oder Grafiken füge Screenshots oder einen kurzen Clip hinzu. Committe keine Editor Backups oder fremde erzeugte Map Dateien.

## Community und externe Quellen

Forsaken Bastion's Fall ist auch auf HiveWorkshop veröffentlicht:

- Projektseite: `https://www.hiveworkshop.com/threads/forsaken-bastions-fall.248608/`
- Ressourcen: `https://www.hiveworkshop.com/resources/`
- Forum: `https://www.hiveworkshop.com/forums/`

HiveWorkshop darf bei der Weiterentwicklung als zusätzliche Recherchequelle genutzt
werden. Dort können Agents nach bestehenden Warcraft-III-Systemen, Modellen,
Skins, Icons, Sounds, Tools und bekannten Lösungen für technische Probleme suchen.

Bei Problemen gilt:

1. Zuerst den bestehenden FBF-Code und die Projektdokumentation prüfen.
2. Danach vorhandene Warcraft-III-APIs und bekannte technische Quellen prüfen.
3. Wenn die Lösung weiterhin unklar ist, gezielt auf HiveWorkshop nach ähnlichen
   Problemen, Systemen oder Diskussionen suchen.

Externe Ressourcen oder Code nicht ungeprüft übernehmen. Vor einer Verwendung prüfen:

- passt die Lösung zur aktuellen Warcraft-III-Version und zu vJASS/JassHelper?
- gibt es bekannte Abhängigkeiten?
- welche Lizenz oder Nutzungsbedingungen gelten?
- ist eine Nennung des Autors erforderlich?
- kollidiert die Lösung mit bestehenden FBF-Systemen?

Wenn eine externe Ressource tatsächlich in FBF übernommen wird, Quelle und Autor
im Ticket oder Pull Request dokumentieren.