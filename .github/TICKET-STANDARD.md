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

- **Assignee:** `pred1980`
- **Project:** `Forsaken Bastion's Fall`
- **Project Status:** bei einem neuen Ticket `Todo`, bei Beginn der Umsetzung `In Progress`, nach dem Merge `Done`
- **Labels:** nur wenn sie helfen; bevorzugt `bug`, `feature`, `documentation` oder `maintenance`
- **Milestone:** nur für ein geplantes Release
- **Relationships:** nur für echte Abhängigkeiten
- **Development:** Links entstehen durch den normalen Branch und PR Workflow
