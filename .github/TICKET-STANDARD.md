# FBF Ticket-Standard

Lies vor jedem neuen Ticket die aktuelle Version dieser Datei. Suche in offenen und geschlossenen GitHub Issues nach ähnlichen Aufgaben. Erstelle kein doppeltes Ticket. Schreibe Titel und Inhalt in einfachem Deutsch und lasse technische Bezeichner unverändert. Das Ticket muss genug Kontext enthalten, damit Codex oder Claude Code es ohne Wissen aus einem Chat umsetzen kann.

## Aufbau

### Ziel

Beschreibe das gewünschte Ergebnis.

### Umfang

Nenne die betroffenen Systeme, Dateien oder Verhaltensweisen.

### Nicht Teil

Nenne Änderungen, die ausdrücklich nicht dazugehören.

### Akzeptanzkriterien

Liste kurze, prüfbare Ergebnisse auf.

### Technische Hinweise (optional)

Nenne bekannte Pfade, Abhängigkeiten oder Einschränkungen, falls sie für die Umsetzung wichtig sind.

### Prüfung

Nenne die nötigen statischen Prüfungen. Bei Änderungen am Spiel gehören das Speichern im Warcraft III World Editor mit JassHelper und vJASS sowie ein konkreter Spieltest dazu. Ein Agent darf diese manuelle Prüfung nur als erledigt melden, wenn ein Mensch das Ergebnis bestätigt hat.

## GitHub-Metadaten

Neue Tickets bekommen echte GitHub-Felder:

- **Assignee:** `pred1980`
- **Project:** `Forsaken Bastion's Fall`
- **Status:** `Todo` → bei Umsetzung `In Progress` → nach Merge `Done`
- **Label:** passend `bug`, `feature`, `documentation` oder `maintenance`
- **Milestone:** nur bei geplantem Release
- **Relationships:** nur bei echten Abhängigkeiten

Angaben im Tickettext ersetzen diese Felder nicht.

Der Ersteller setzt alle Felder mit den verfügbaren GitHub-Werkzeugen. Kann
ChatGPT `Project` oder `Status` nicht direkt setzen, ist das Ticket noch nicht
vollständig angelegt. Dann müssen Codex oder Claude die fehlenden Felder über
`gh` / GitHub Projects v2 setzen.

Danach immer prüfen:

`gh issue view <n> --json assignees,labels,milestone,projectItems`

Erst wenn `projectItems` das Project `Forsaken Bastion's Fall` mit dem
erwarteten Status zeigt, gilt das Ticket als vollständig angelegt.

Für `gh project` muss einmalig der Scope `project` vorhanden sein:
`gh auth refresh -s project`.

### Felder setzen und prüfen

Der Agent, der das Ticket erstellt, setzt Assignee, Label, Project und Project Status selbst. Er nutzt dafür die verfügbaren und freigegebenen GitHub-Werkzeuge. Kann ein direkter Connector keine GitHub Projects v2 verwalten, nutzt er einen anderen freigegebenen Weg, etwa GitHub CLI (`gh`) oder die Projects v2 API. Nur wenn wirklich kein passendes Werkzeug verfügbar ist, meldet er die offene Aktion ausdrücklich, zum Beispiel: „Bitte Issue #12 im Project `Forsaken Bastion's Fall` auf `Todo` setzen.“

Mit GitHub CLI. Die Project-Befehle brauchen den Token-Scope `project` (`gh auth refresh -s project`).

```bash
gh issue create --title "<Titel>" --body-file <Datei> --assignee pred1980 --label <label>

# Nummer und ID des Projects
gh project list --owner pred1980 --format json --jq '.projects[] | select(.title | startswith("Forsaken Bastion")) | .number'
gh project view <number> --owner pred1980 --format json --jq .id

# Issue ins Project aufnehmen; gibt die Item ID zurück, auch wenn das Issue schon drin ist
gh project item-add <number> --owner pred1980 --url <issue-url> --format json --jq .id

# ID des Felds "Status" und seiner Optionen
gh project field-list <number> --owner pred1980 --format json --jq '.fields[] | select(.name == "Status") | {id, options}'

# Status setzen
gh project item-edit --id <item-id> --project-id <project-id> --field-id <status-field-id> --single-select-option-id <option-id>
```

Prüfe danach den tatsächlichen Stand auf GitHub:

```bash
gh issue view <n> --json assignees,labels,milestone,projectItems
```

`projectItems` muss `Forsaken Bastion's Fall` mit dem erwarteten Status zeigen. Mit denselben Befehlen setzt `implement-ticket` später `In Progress` und `review-pr` nach dem Merge `Done`.
