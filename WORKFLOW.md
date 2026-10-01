# AI-Workflow für FBF

Diese Anleitung zeigt, wie ein GitHub Ticket mit Codex oder Claude Code umgesetzt wird. Die gemeinsamen Regeln stehen in `AGENTS.md`. Neue Tickets folgen `.github/TICKET-STANDARD.md`.

**Ablauf ohne Änderung unter `src/` und ohne `.w3x`:** Ticket -> Branch -> PR -> Review -> Korrekturen -> erneutes Review -> Merge -> Branch cleanup -> Done

**Ablauf mit Änderung unter `src/` oder an einer `.w3x`:** Ticket -> Branch -> PR -> Review -> Korrekturen -> erneutes Review -> Stopp vor dem Merge -> Build und Spieltest durch einen Menschen -> gespeicherte Map prüfen und gegebenenfalls in denselben PR committen und pushen -> Review -> Merge -> Branch cleanup -> Done

1. **Ticket schreiben:** Ziel, Umfang, Grenzen, Akzeptanzkriterien und Prüfung müssen ohne zusätzlichen Chat verständlich sein. Entscheidungen zu Balance und Design gehören ins Ticket. Assignee, Label, Project und Project Status (`Todo`) werden als echte GitHub-Felder gesetzt.
2. **Umsetzung starten:** Starte den Agent im Hauptverzeichnis und nenne die Issue Nummer.
   - Codex: `$implement-ticket Implement issue #12`
   - Claude Code: `/implement-ticket 12`
3. **Branch und PR:** `implement-ticket` liest das Issue und seine Kommentare, erstellt einen Branch von `origin/master` und setzt das Issue im Project auf `In Progress`. Danach ändert es nur die nötigen Dateien, führt statische Prüfungen aus, committet, pusht und öffnet einen PR mit `Closes #12`. Jeder Commit zum Issue und der PR-Titel beginnen mit `[#12]`, etwa `[#12] Behebe Zielauswahl der Archmage-KI`. Ein Issue hat einen Branch und einen PR. Ohne neuen Auftrag geht es mit Schritt 4 weiter.
4. **Review und Korrekturen:** `implement-ticket` prüft den PR nach den Regeln von `review-pr`: Issue, Code, Kommentare, Review Threads und CI. Jeder Befund bekommt genau einen Schweregrad: `BLOCKER`, `ERROR`, `MAJOR` oder `MINOR`. Die Bedeutung steht in `AGENTS.md`.
   - `BLOCKER`, `ERROR` und `MAJOR` behebt der Agent auf demselben Branch und pusht die Korrektur. Danach prüft er den ganzen neuen Stand erneut. Neue `BLOCKER`, `ERROR` oder `MAJOR` blockieren wieder.
   - Braucht ein Befund eine Entscheidung zu Design, Balance oder Umfang oder eine Handlung eines Menschen, stoppt der Agent und stellt eine konkrete Frage.
   - `MINOR` steht im Review, blockiert aber nicht. Es wird im selben PR nur auf ausdrücklichen Wunsch behoben. Folge-Tickets entstehen dafür nicht von selbst.
5. **Änderungen am Spiel prüfen:** Dieser Schritt gilt nur, wenn der PR mindestens eine Datei unter `src/` oder eine `.w3x` ändert. Dann stoppt der Agent vor dem Merge und nennt den zu testenden Commit, den Build und die Testszenarien.
   - Der Agent setzt die zentrale Kennung `DEV_TEST_STAND` in `src/GameConfig/GameStart.vj` für das Issue zunächst auf `DEV #<issue> T01`. Braucht eine spätere Spielcode- oder Map-Änderung nach einer Testaufforderung einen neuen menschlichen Test, erhöht er `T<nn>` vor dem nächsten Test um eins. Reine Dokumentation, Kommentare und andere Änderungen, die den bestätigten Test nicht ungültig machen, erhöhen sie nicht. Die Kennung steht im Commit, bevor er zum Test auffordert.
   - Der Agent liest die Kennung aus `GameStart.vj` im zu testenden Commit und nennt in der Konsole `Teststand: DEV #<issue> T<nn>`, `Commit: <SHA>` und `Im Spiel muss beim Start exakt erscheinen: DEV #<issue> T<nn>`. Beide Ausgaben stammen aus derselben gelesenen Kennung.
   - Ein Mensch checkt den Branch aus, passt bei Bedarf das lokale Präfix in `src/imports.j` an und committet diese Anpassung nicht.
   - Er öffnet die aktuelle Entwicklungskarte `FBF_v<Version>_dev.w3x` im Warcraft III World Editor mit `Enable JassHelper` und `Enable vJASS`, speichert die Map und testet die genannten Szenarien im Spiel.
   - Wurden für den Test lokale Schalter wie `IS_DEBUG_MODE` geändert, stellt er sie für den endgültigen Build auf den vorgesehenen Wert zurück, speichert die Map erneut und prüft den betroffenen normalen Ablauf. Die lokale Umschaltung wird nicht committet.
   - Hat der PR die `.w3x` geändert, prüft er nach dem Speichern, dass die beabsichtigten Map-Daten erhalten sind.
   - Er prüft die sichtbare Kennung beim Start sowie die ungefähr zehn Sekunden lange Anzeige des gesamten Präsentationstexts. Er hält die sichtbare Kennung, Ergebnis und getesteten Commit im PR fest, etwa `DEV #12 T01 angezeigt; World-Editor-Build und Spieltest erfolgreich.` Eine andere oder ältere Kennung bestätigt den angeforderten Stand nicht. Agents können Build und Spieltest nicht selbst bestätigen.
   - Hat das Speichern die aktuelle Entwicklungskarte geändert, prüft `review-pr`, ob sie die abgenommene Map ist. Der Agent erfasst ihren SHA-256, prüft den lokalen Status und den Map-Diff auf fremde Änderungen, stagt ausschließlich ihren Pfad, committet und pusht sie auf denselben Issue-Branch. Die PR-Beschreibung nennt den getesteten Quellcode-Commit, den Map-SHA-256 und das Testergebnis. Editor-Backups, `src/imports.j`, lokale Testschalter und andere fremde Dateien bleiben uncommittet.
   - Der Agent prüft den neuen PR-Head erneut. Stimmen die committeten Map-Bytes mit der getesteten Datei überein und wurde der Spielcode seit dem Test nicht geändert, gilt die Abnahme weiter. Andernfalls ist ein neuer Build und Spieltest nötig.
   - Danach übernimmt `review-pr` den Merge: Codex mit `$review-pr <PR-Nummer>`, Claude Code mit `/review-pr <PR-Nummer>`.
   - Ändern spätere Commits den Spielcode oder die getesteten Map-Bytes, ist der Test für den neuen Stand erneut nötig.
6. **Merge:** Sind nur noch `MINOR` oder keine Befunde offen und alle nötigen Prüfungen erfüllt, merged der Agent den PR nach `master`.
   - Erzeugt der Merge einen neuen Commit, setzt der Agent dessen Betreff auf `[#12] <Betreff>` statt auf `Merge pull request #...`. Ein Rebase-Merge übernimmt die schon benannten Commits ohne zusätzlichen Commit.
   - Lehnt GitHub die Freigabe nur ab, weil Autor und Reviewer derselbe Account sind, steht das Review als PR-Kommentar. Das allein blockiert den Merge nicht.
   - Eine Freigabe, die Branch Protection oder Repository-Regeln verlangen, bleibt Pflicht.
   - `review-pr` lässt sich auch einzeln aufrufen, etwa für PRs anderer Personen oder nach dem Spieltest. Dann gibt es Rückmeldung, ändert aber ohne ausdrücklichen Wunsch keine Dateien des PRs.
7. **Branch cleanup und Done:** Nach dem Merge setzt `review-pr` das Issue im Project auf `Done`. Es löscht den Branch des PRs auf GitHub und lokal, wenn das sicher ist, entfernt eigene temporäre Worktrees und aktualisiert das lokale `master` nur per Fast-Forward. `master` wird nie gelöscht, und lokale Änderungen werden nie verworfen. Was es nicht sicher aufräumen kann, lässt es stehen und nennt den Grund.

Agents bearbeiten die Entwicklungskarte `FBF_v<Version>_dev.w3x` direkt nur, wenn das Ticket eine direkte Map-Änderung ausdrücklich verlangt. Dann folgen sie `safe-w3x-change`. Eine bereits vom Menschen im World Editor gespeicherte und getestete Karte dürfen sie als Build-Ergebnis unverändert in den Issue-PR übernehmen. Maps in `release/` und eine `Working copie` bleiben ohne eigenes Ticket unverändert. Kein Workflow pusht auf `master` oder aktiviert Auto-Merge.

## Dateien und Skills

| Pfad | Zweck |
| --- | --- |
| `AGENTS.md` | Gemeinsame Regeln für Codex und Claude Code |
| `CLAUDE.md` | Bindet `AGENTS.md` ein und erklärt die Architektur |
| `.agents/skills/<name>/SKILL.md` | Maßgebliche Skills für Codex |
| `.claude/skills/<name>/SKILL.md` | Schlanke Wrapper für Claude Code |

`implement-ticket` führt vom Issue über Review und Korrekturen bis zum Merge. Bei Änderungen unter `src/` oder an einer `.w3x` stoppt es vor dem Merge für den Spieltest. `review-pr` prüft, merged nach den Freigaben und räumt danach auf. `safe-w3x-change` beschreibt direkte Änderungen an der Entwicklungskarte: Sicherung, Hashes, Vergleich der internen Dateien, Prüfung der Integritätsdaten und Angaben im PR. `safe-vjass-change` enthält die Checkliste für Änderungen an `.vj` und `src/imports.j` und zwei Skripte: `check-vjass-change.sh` für die statischen Prüfungen und `stage-imports-with-head-prefix.sh`, das `src/imports.j` mit dem eingecheckten Präfix stagt. Beide lösen Importpfade mit `resolve-imports.awk` auf. Die Skripte brauchen Git Bash. Bearbeite Skills unter `.agents/skills/` und passe Wrapper nur an, wenn sich `name` oder `description` ändert. Wrapper sind nötig, weil Symlinks auf dem aktuellen Windows Rechner ohne `core.symlinks` als Textdateien ausgecheckt werden.

`src/imports.j` nutzt absolute lokale Pfade. Es gibt keinen bestätigten portablen Ersatz für JassHelper. Es gibt auch keinen CLI Build oder automatischen Spieltest. Statische Prüfungen können fehlende Imports, beschädigtes Encoding, falsche Zeilenenden, Änderungen an Map Dateien und Leerzeichenfehler finden. Sie beweisen keinen erfolgreichen Build und kein korrektes Verhalten im Spiel.

## Externe Quellen

HiveWorkshop ist eine zusätzliche Quelle für Recherche zu Warcraft III, fertigen Systemen, Modellen, Icons und Tools. Die Regeln dazu stehen in `AGENTS.md` im Abschnitt „Community und externe Quellen“. Übernommene Quellen und Autoren werden im Ticket oder PR genannt.
