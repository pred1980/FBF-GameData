# AI-Workflow für FBF

Diese Anleitung zeigt, wie ein GitHub Ticket mit Codex oder Claude Code umgesetzt wird. Die gemeinsamen Regeln stehen in `AGENTS.md`. Neue Tickets folgen `.github/TICKET-STANDARD.md`.

**Ablauf:** Ticket -> implement-ticket -> PR -> review-pr -> master

1. **Ticket schreiben:** Ziel, Umfang, Grenzen, Akzeptanzkriterien und Prüfung müssen ohne zusätzlichen Chat verständlich sein. Entscheidungen zu Balance und Design gehören ins Ticket.
2. **Umsetzung starten:** Starte den Agent im Hauptverzeichnis und nenne die Issue Nummer.
   - Codex: `$implement-ticket Implement issue #12`
   - Claude Code: `/implement-ticket 12`
3. **PR erstellen:** `implement-ticket` liest das Issue und seine Kommentare, erstellt einen Branch von `origin/master`, ändert nur die nötigen Dateien, führt statische Prüfungen aus, committet, pusht und öffnet einen PR mit `Closes #12`. Ein Issue hat einen Branch und einen PR. Der Agent merged oder genehmigt den eigenen PR nicht.
4. **Änderungen am Spiel prüfen:** Ein Mensch checkt den Branch aus, passt bei Bedarf das lokale Präfix in `src/imports.j` an und committet diese Anpassung nicht. Er öffnet `FBF_v0.4.9_dev.w3x` im Warcraft III World Editor mit `Enable JassHelper` und `Enable vJASS`, speichert die Map und testet die genannten Szenarien im Spiel. Ergebnisse werden im PR festgehalten. Agents können Build und Spieltest nicht selbst bestätigen. Für reine Dokumentations- oder Tool Änderungen ohne Einfluss auf das Spiel ist dieser Test nicht nötig.
5. **PR prüfen:** `review-pr` prüft Issue, Code, Kommentare, Review Threads und CI. Es lässt den PR bei offenen Punkten stehen und gibt konkrete Rückmeldung. Nach allen nötigen Prüfungen kann es einen fertigen PR nach `master` mergen.
   - Codex: `$review-pr <PR-Nummer>`
   - Claude Code: `/review-pr <PR-Nummer>`

Agents ändern keine `.w3x` Dateien. Nötige Änderungen im Object Editor stehen im PR für einen Menschen. Kein Workflow pusht auf `master` oder aktiviert Auto-Merge.

## Dateien und Skills

| Pfad | Zweck |
| --- | --- |
| `AGENTS.md` | Gemeinsame Regeln für Codex und Claude Code |
| `CLAUDE.md` | Bindet `AGENTS.md` ein und erklärt die Architektur |
| `.agents/skills/<name>/SKILL.md` | Maßgebliche Skills für Codex |
| `.claude/skills/<name>/SKILL.md` | Schlanke Wrapper für Claude Code |

`implement-ticket` führt vom Issue zum PR. `review-pr` prüft und merged nach den Freigaben. `safe-vjass-change` enthält die Checkliste und statische Skripte für Änderungen an `.vj` und `src/imports.j`; die Skripte brauchen Git Bash. Bearbeite Skills unter `.agents/skills/` und passe Wrapper nur an, wenn sich `name` oder `description` ändert. Wrapper sind nötig, weil Symlinks auf dem aktuellen Windows Rechner ohne `core.symlinks` als Textdateien ausgecheckt werden.

`src/imports.j` nutzt absolute lokale Pfade. Es gibt keinen bestätigten portablen Ersatz für JassHelper. Es gibt auch keinen CLI Build oder automatischen Spieltest. Statische Prüfungen können fehlende Imports, beschädigtes Encoding, falsche Zeilenenden, Änderungen an Map Dateien und Leerzeichenfehler finden. Sie beweisen keinen erfolgreichen Build und kein korrektes Verhalten im Spiel.
