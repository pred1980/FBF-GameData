# AI-Workflow für FBF

Diese Anleitung zeigt, wie ein GitHub Ticket mit Codex oder Claude Code umgesetzt wird. Die gemeinsamen Regeln stehen in `AGENTS.md`. Neue Tickets folgen `.github/TICKET-STANDARD.md`.

**Ablauf ohne Änderung unter `src/` und ohne `.w3x`:** Ticket -> Branch -> PR -> Review -> Korrekturen -> erneutes Review -> Merge -> Branch cleanup -> Done

**Ablauf mit Änderung unter `src/` oder an einer `.w3x`:** Ticket -> Branch -> PR -> Review -> Korrekturen -> erneutes Review -> Stopp vor dem Merge -> Build und Spieltest durch einen Menschen -> Merge -> Branch cleanup -> Done

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
   - Ein Mensch checkt den Branch aus, passt bei Bedarf das lokale Präfix in `src/imports.j` an und committet diese Anpassung nicht.
   - Er öffnet die aktuelle Entwicklungskarte `FBF_v<Version>_dev.w3x` im Warcraft III World Editor mit `Enable JassHelper` und `Enable vJASS`, speichert die Map und testet die genannten Szenarien im Spiel.
   - Hat der PR die `.w3x` geändert, prüft er nach dem Speichern, dass die beabsichtigten Map-Daten erhalten sind.
   - Er hält Ergebnis und getesteten Commit im PR fest. Agents können Build und Spieltest nicht selbst bestätigen.
   - Danach übernimmt `review-pr` den Merge: Codex mit `$review-pr <PR-Nummer>`, Claude Code mit `/review-pr <PR-Nummer>`.
   - Ändern spätere Commits wieder Dateien unter `src/` oder eine `.w3x`, ist der Test für den neuen Stand erneut nötig.
6. **Merge:** Sind nur noch `MINOR` oder keine Befunde offen und alle nötigen Prüfungen erfüllt, merged der Agent den PR nach `master`.
   - Erzeugt der Merge einen neuen Commit, setzt der Agent dessen Betreff auf `[#12] <Betreff>` statt auf `Merge pull request #...`. Ein Rebase-Merge übernimmt die schon benannten Commits ohne zusätzlichen Commit.
   - Lehnt GitHub die Freigabe nur ab, weil Autor und Reviewer derselbe Account sind, steht das Review als PR-Kommentar. Das allein blockiert den Merge nicht.
   - Eine Freigabe, die Branch Protection oder Repository-Regeln verlangen, bleibt Pflicht.
   - `review-pr` lässt sich auch einzeln aufrufen, etwa für PRs anderer Personen oder nach dem Spieltest. Dann gibt es Rückmeldung, ändert aber ohne ausdrücklichen Wunsch keine Dateien des PRs.
7. **Branch cleanup und Done:** Nach dem Merge setzt `review-pr` das Issue im Project auf `Done`. Es löscht den Branch des PRs auf GitHub und lokal, wenn das sicher ist, entfernt eigene temporäre Worktrees und aktualisiert das lokale `master` nur per Fast-Forward. `master` wird nie gelöscht, und lokale Änderungen werden nie verworfen. Was es nicht sicher aufräumen kann, lässt es stehen und nennt den Grund.

Agents ändern die Entwicklungskarte `FBF_v<Version>_dev.w3x` nur, wenn das Ticket eine direkte Map-Änderung ausdrücklich verlangt. Dann folgen sie `safe-w3x-change`. Sonst stehen nötige Änderungen im Editor im PR für einen Menschen. Maps in `release/` und eine `Working copie` bleiben ohne eigenes Ticket unverändert. Kein Workflow pusht auf `master` oder aktiviert Auto-Merge.

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
