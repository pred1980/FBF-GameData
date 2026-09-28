# AI-Workflow für FBF

Diese Anleitung zeigt, wie ein GitHub Ticket mit Codex oder Claude Code umgesetzt wird. Die gemeinsamen Regeln stehen in `AGENTS.md`. Neue Tickets folgen `.github/TICKET-STANDARD.md`.

**Ablauf:** Ticket -> Branch -> PR -> Review -> Merge -> Branch cleanup -> Done

1. **Ticket schreiben:** Ziel, Umfang, Grenzen, Akzeptanzkriterien und Prüfung müssen ohne zusätzlichen Chat verständlich sein. Entscheidungen zu Balance und Design gehören ins Ticket. Assignee, Label, Project und Project Status (`Todo`) werden als echte GitHub-Felder gesetzt.
2. **Umsetzung starten:** Starte den Agent im Hauptverzeichnis und nenne die Issue Nummer.
   - Codex: `$implement-ticket Implement issue #12`
   - Claude Code: `/implement-ticket 12`
3. **Branch und PR:** `implement-ticket` liest das Issue und seine Kommentare, erstellt einen Branch von `origin/master` und setzt das Issue im Project auf `In Progress`. Danach ändert es nur die nötigen Dateien, führt statische Prüfungen aus, committet, pusht und öffnet einen PR mit `Closes #12`. Ein Issue hat einen Branch und einen PR. Der Agent merged oder genehmigt den eigenen PR nicht.
4. **Änderungen am Spiel prüfen:** Ein Mensch checkt den Branch aus, passt bei Bedarf das lokale Präfix in `src/imports.j` an und committet diese Anpassung nicht. Er öffnet die aktuelle Entwicklungskarte `FBF_v<Version>_dev.w3x` im Warcraft III World Editor mit `Enable JassHelper` und `Enable vJASS`, speichert die Map und testet die genannten Szenarien im Spiel. Ergebnisse werden im PR festgehalten. Agents können Build und Spieltest nicht selbst bestätigen. Für reine Dokumentations- oder Tool Änderungen ohne Einfluss auf das Spiel ist dieser Test nicht nötig.
5. **Review und Merge:** `review-pr` prüft Issue, Code, Kommentare, Review Threads und CI.
   - Codex: `$review-pr <PR-Nummer>`
   - Claude Code: `/review-pr <PR-Nummer>`

   Jeder Befund bekommt genau einen Schweregrad: `BLOCKER`, `ERROR`, `MAJOR` oder `MINOR`. Die Bedeutung steht in `AGENTS.md`.
   - Ist ein `BLOCKER`, `ERROR` oder `MAJOR` offen, bleibt der PR offen. `review-pr` nennt, was den Befund behebt.
   - `MINOR` steht im Review, blockiert aber nicht. Es wird im selben PR nur auf ausdrücklichen Wunsch behoben. Folge-Tickets entstehen dafür nicht von selbst.
   - Nach Korrekturen prüft eine erneute Review den ganzen neuen Stand. Neue `BLOCKER`, `ERROR` oder `MAJOR` blockieren wieder.
   - Sind nur noch `MINOR` offen und alle nötigen Prüfungen erfüllt, kann `review-pr` den PR nach `master` mergen.
6. **Branch cleanup und Done:** Nach dem Merge setzt `review-pr` das Issue im Project auf `Done`. Es löscht den Branch des PRs auf GitHub und lokal, wenn das sicher ist, entfernt eigene temporäre Worktrees und aktualisiert das lokale `master` nur per Fast-Forward. `master` wird nie gelöscht, und lokale Änderungen werden nie verworfen. Was es nicht sicher aufräumen kann, lässt es stehen und nennt den Grund.

Agents ändern keine `.w3x` Dateien. Nötige Änderungen im Object Editor stehen im PR für einen Menschen. Kein Workflow pusht auf `master` oder aktiviert Auto-Merge.

## Dateien und Skills

| Pfad | Zweck |
| --- | --- |
| `AGENTS.md` | Gemeinsame Regeln für Codex und Claude Code |
| `CLAUDE.md` | Bindet `AGENTS.md` ein und erklärt die Architektur |
| `.agents/skills/<name>/SKILL.md` | Maßgebliche Skills für Codex |
| `.claude/skills/<name>/SKILL.md` | Schlanke Wrapper für Claude Code |

`implement-ticket` führt vom Issue zum PR. `review-pr` prüft, merged nach den Freigaben und räumt danach auf. `safe-vjass-change` enthält die Checkliste für Änderungen an `.vj` und `src/imports.j` und zwei Skripte: `check-vjass-change.sh` für die statischen Prüfungen und `stage-imports-with-head-prefix.sh`, das `src/imports.j` mit dem eingecheckten Präfix stagt. Beide lösen Importpfade mit `resolve-imports.awk` auf. Die Skripte brauchen Git Bash. Bearbeite Skills unter `.agents/skills/` und passe Wrapper nur an, wenn sich `name` oder `description` ändert. Wrapper sind nötig, weil Symlinks auf dem aktuellen Windows Rechner ohne `core.symlinks` als Textdateien ausgecheckt werden.

`src/imports.j` nutzt absolute lokale Pfade. Es gibt keinen bestätigten portablen Ersatz für JassHelper. Es gibt auch keinen CLI Build oder automatischen Spieltest. Statische Prüfungen können fehlende Imports, beschädigtes Encoding, falsche Zeilenenden, Änderungen an Map Dateien und Leerzeichenfehler finden. Sie beweisen keinen erfolgreichen Build und kein korrektes Verhalten im Spiel.

## Externe Quellen

HiveWorkshop ist eine zusätzliche Quelle für Recherche zu Warcraft III, fertigen Systemen, Modellen, Icons und Tools. Die Regeln dazu stehen in `AGENTS.md` im Abschnitt „Community und externe Quellen“. Übernommene Quellen und Autoren werden im Ticket oder PR genannt.
