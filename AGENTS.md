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

**Zeilenenden:** `* text=auto` speichert Textdateien im Repository mit LF. Windows Checkouts mit `core.autocrlf=true` erhalten CRLF. Shell Skripte (`*.sh`) und awk Skripte (`*.awk`) haben immer LF. Erhalte die Zeilenenden einer Datei und mische LF und CRLF nicht.

## Änderungen sicher durchführen

- **Rawcodes und Order-Strings:** Object Data für Units, Abilities, Items und Buffs liegt nur in der `.w3x`. Der Code nutzt Rawcodes wie `'A07K'` und Order-Strings wie `"roar"`. Das Repository allein kann ihre Gültigkeit nicht bestätigen. Suche vor einer Änderung alle Verwendungen unter `src/`.
- **Hero AI:** Jede Datei `src/AI-Systems/HeroesAI/<Hero>AI.vj` wiederholt Spell IDs, Order-Strings, Radien und Cooldowns der Fähigkeiten unter `src/Heroes/<Hero>/`. Passe bei einer Änderung beide Seiten an.
- **Gemeinsame Bibliotheken:** Suche vor einer Änderung unter `src/Libraries/` oder an einem anderen gemeinsamen System alle Nutzer. Berücksichtige auch `optional` Anforderungen, Module und Textmacros.
- **Map Dateien:** Ein Agent ändert eine `.w3x` nur, wenn das Ticket ausdrücklich eine direkte Änderung der aktuellen Entwicklungskarte `FBF_v<Version>_dev.w3x` verlangt. Die Erlaubnis gilt dann für alle internen Bereiche der Map, etwa Object Data, Imports, Trigger- und Script-Daten, Terrain und Regionen. Der Agent folgt dabei dem Skill `safe-w3x-change`: Sicherung außerhalb des Repositorys, SHA-256 vorher und nachher, Vergleich aller internen Dateien vorher und nachher, Prüfung der Integritätsdaten und genaue Angaben im PR. Er rät keine Werte, Rawcodes, Pfade oder Binärstrukturen. Kann er einen internen Bereich nicht zuverlässig lesen und schreiben, stoppt er. Ohne diesen Auftrag im Ticket ändert kein Agent eine `.w3x`, sondern nennt nötige Änderungen im Editor für einen Menschen. Maps in `release/` und eine `Working copie` bleiben unverändert, außer ein eigenes Ticket verlangt die Änderung ausdrücklich.

Das Speichern der aktuellen Entwicklungskarte durch einen Menschen im World Editor ist der Build. Ändert dieser Build die `.w3x`, gehört die vom Menschen getestete Datei als Build-Ergebnis in denselben Issue-PR. Ein Agent darf die bereits gespeicherte Datei unverändert und mit ihrem ausdrücklichen Pfad stagen, committen und auf den Issue-Branch pushen. Das ist keine direkte Bearbeitung der Map durch den Agenten. Er prüft zuvor, dass die Datei vom Test stammt, hält ihren SHA-256 im PR fest und schließt lokale Testschalter wie `IS_DEBUG_MODE=true` sowie fremde Änderungen vom Commit aus. Ist der Zustand der Map oder der Testschalter unklar, klärt er ihn vor dem Commit. Für direkte Änderungen durch einen Agenten gilt weiterhin `safe-w3x-change`.

Der Skill `safe-vjass-change` enthält dazu eine Checkliste und statische Prüfungen. Für direkte Änderungen an der Map gilt `safe-w3x-change`.

## Tests und Ergebnisse

Es gibt keine automatischen Spieltests und kein Coverage Ziel. Ändert ein PR mindestens eine Datei unter `src/` oder eine `.w3x`, muss ein Mensch vor dem Merge die Map im Editor speichern und den betroffenen Helden, das System oder den Spielmodus testen. Bei einer geänderten `.w3x` prüft er außerdem, dass die beabsichtigten Map-Daten nach dem Speichern erhalten sind. Beschreibe Szenario und Ergebnis im Pull Request. `documentation/FBF-Website/tests/phpunit.xml` gehört nur zur archivierten PHP Website und testet die Map nicht.

Agents können die Map nicht nachweislich kompilieren oder starten. `git diff --check`, Suchen im Code und die Skripte aus `safe-vjass-change` beweisen weder einen erfolgreichen Build noch korrektes Verhalten im Spiel. Behaupte das nur, wenn ein Mensch das Speichern oder den Spieltest durchgeführt und das Ergebnis gemeldet hat. Sonst sage ausdrücklich, dass beides offen ist, und nenne das nötige Testszenario.

Für jeden angeforderten menschlichen Spieltest steht die sichtbare Kennung einmalig in `src/GameConfig/GameStart.vj` als `DEV_TEST_STAND` im Format `DEV #<issue> T<nn>`. Das Issue beginnt bei `T01`. Erhöhe die Nummer erst, wenn nach einem bereits angeforderten Teststand eine neue Änderung einen erneuten Build und Spieltest erfordert. Dokumentation, Kommentare und andere Änderungen ohne Einfluss auf den bestätigten Spieltest erhöhen sie nicht. Committe den zu testenden Quellcode einschließlich Kennung vor der Testaufforderung. Lies die Kennung aus `GameStart.vj` im zu testenden Commit und nenne sie zusammen mit dessen SHA; leite sie nicht aus Erinnerung oder einer zweiten Definition ab. Im Spiel muss dieselbe Zeile exakt erscheinen. Eine Meldung mit anderer oder älterer Kennung bestätigt den angeforderten Stand nicht. Der Mensch nennt die sichtbare Kennung und den getesteten Commit im PR.

## Tickets und Agent-Workflow

- Jedes neue GitHub Ticket muss `.github/TICKET-STANDARD.md` folgen.
- Ein Issue bekommt einen Branch und einen Pull Request. Erstelle den Branch von `origin/master` als `<type>/issue-<n>-<short-slug>` mit `feature`, `fix`, `docs` oder `chore`. Committe nie auf `master`.
- Bei einem Auftrag zur Umsetzung darf ein Agent auf dem Issue Branch committen, pushen und einen PR gegen `master` mit `Closes #<n>` öffnen. Danach setzt `implement-ticket` den Ablauf mit `review-pr` fort: Review, Korrektur von `BLOCKER`, `ERROR` und `MAJOR`, erneutes Review des neuen Stands und Merge. Braucht ein Befund eine Entscheidung zu Design, Balance oder Umfang, behebt der Agent ihn nicht selbst. Er stoppt und stellt eine konkrete Frage.
- Ändert der PR mindestens eine Datei unter `src/` oder eine `.w3x`, stoppt der Agent vor dem Merge. Gemerged wird erst, wenn ein Mensch den Build im World Editor und den Spieltest bestätigt hat. Bei einem nachträglichen Commit der exakt getesteten, unveränderten Editor-Map genügt die Zuordnung des getesteten Quellcode-Commits und des Map-SHA-256 zum neuen PR-Head; das Committen allein erfordert keinen neuen Spieltest. Ändern spätere Commits den Spielcode oder die getesteten Map-Bytes, ist der Test für den neuen Stand erneut nötig. Ändert der PR weder eine Datei unter `src/` noch eine `.w3x`, ist der Warcraft-III-Test kein Merge-Gate.
- Kein Agent pusht auf `master`, aktiviert Auto-Merge oder umgeht Branch Protection. `review-pr` genehmigt und merged erst, wenn alle nötigen Prüfungen erfüllt sind. Lehnt GitHub die Freigabe nur ab, weil Autor und Reviewer derselbe Account sind, steht das Review als PR-Kommentar. Das allein blockiert den Merge nicht. Verlangen Branch Protection oder Repository-Regeln eine Freigabe durch einen anderen Account, bleibt sie Pflicht.
- Verwirf, stashe oder committe keine fremden lokalen Änderungen. Stage nur ausdrücklich genannte Pfade.
- Der Project Status im Project `Forsaken Bastion's Fall` folgt dem Ablauf: `Todo` für ein neues Ticket, `In Progress` bei Beginn der Umsetzung, `Done` nach dem Merge. Die Befehle stehen in `.github/TICKET-STANDARD.md`. Kann ein Agent den Status nicht setzen, nennt er die offene Aktion ausdrücklich.
- Nach dem Merge löscht `review-pr` den Branch des PRs, wenn das sicher ist. `master` wird nie gelöscht. Lokale Änderungen werden nie verworfen.
- Ein Review ordnet jeden Befund genau einem von vier Schweregraden zu:
  - `BLOCKER`: Der Merge ist unsicher oder nicht möglich.
  - `ERROR`: Ein Fehler ist bestätigt oder ein Akzeptanzkriterium ist nicht erfüllt.
  - `MAJOR`: Ein wesentliches Problem bei Korrektheit, Architektur, Umfang oder Wartbarkeit.
  - `MINOR`: Eine kleine Verbesserung, eine Stilfrage, eine Formulierung oder eine andere unkritische Auffälligkeit.

  `BLOCKER`, `ERROR` und `MAJOR` müssen vor dem Merge behoben sein, auch wenn sie erst bei einer erneuten Review auffallen. `MINOR` wird im Review dokumentiert und blockiert den Merge nicht. Ein Agent behebt `MINOR` im selben PR nur auf ausdrücklichen Wunsch und legt dafür keine Folge-Tickets an. Die Einzelheiten stehen in `review-pr`.
- `implement-ticket` beschreibt die Umsetzung, die PR Vorlage und den automatischen Ablauf bis zum Merge. `review-pr` beschreibt Review, Schweregrade, Freigabe, Merge und das Aufräumen danach.

Die Skills nutzen das Agent Skills Format (`SKILL.md`). Die maßgeblichen Dateien liegen unter `.agents/skills/<name>/`; Codex findet sie dort. `.claude/skills/<name>/SKILL.md` enthält schlanke Wrapper für Claude Code. Bearbeite nur die maßgebliche Datei. `name` und `description` im Wrapper müssen mit ihr übereinstimmen.

## Commits und Pull Requests

Commit-Nachrichten verwenden einfaches Deutsch. Gehört ein Commit zu einem Issue, beginnt die erste Zeile mit dem Präfix `[#<n>]` und einem Leerzeichen. `<n>` ist die Nummer des Issues. Das gilt für jeden Commit zum Issue, auch für spätere Korrektur- und Review-Commits. Nach dem Präfix folgt ein kurzer Betreff: Beginne ihn mit einem klaren Verb und beschreibe konkret die Änderung. Setze keinen Punkt ans Ende. Vermeide vage Betreffzeilen wie `Update`, `Changes`, `Fix stuff` oder `WIP`. Präfixe wie `feat:`, `fix:` oder `docs:` sind nicht nötig. Technische Bezeichner bleiben unverändert. `Refs #<n>` im Commit-Body bleibt; das Präfix ersetzt diese Verknüpfung nicht. Die Regel gilt für neue Commits. Bestehende Commits auf `master` werden nicht umgeschrieben.

Gute Beispiele:

- `[#3] Ergänze gemeinsamen Agent-Workflow`
- `[#3] Dokumentiere Ticket-Standard`
- `[#21] Behebe Zielauswahl der Archmage-KI`
- `[#22] Prüfe Rawcodes der Turm-Upgrades`

Der Titel eines Pull Requests zu einem Issue beginnt mit demselben Präfix, zum Beispiel `[#10] Ergänze Ticketnummern in Commit-Betreffzeilen`. Die Beschreibung enthält weiterhin `Closes #<n>`. Erzeugt der Merge einen neuen Commit (Merge-Commit oder Squash), beginnt dessen Betreff ebenfalls mit `[#<n>]` und nicht mit dem GitHub-Standard `Merge pull request #...`. Ein Rebase-Merge erzeugt keinen neuen Commit. Dann tragen die einzelnen Commits das Präfix schon, und es entsteht kein zusätzlicher Commit nur für das Präfix.

Fasse im Pull Request die Änderung zusammen. Nenne Ergebnisse für Build und Spieltest oder sage, dass sie noch offen sind. Verlinke das Issue. Bei sichtbaren Änderungen an Spiel oder Grafiken füge Screenshots oder einen kurzen Clip hinzu. Committe keine Editor Backups, Sicherungskopien, temporären Maps oder fremde erzeugte Map Dateien. Stage eine direkt geänderte oder nach der menschlichen Abnahme gespeicherte Entwicklungskarte nur mit ihrem ausdrücklichen Pfad.

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