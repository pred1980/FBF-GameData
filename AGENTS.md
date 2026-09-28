# Regeln für dieses Repository

## Projektaufbau

Dieses Repository enthält die Warcraft-III-Karte *Forsaken Bastion's Fall*. `FBF_v0.4.9_dev.w3x` im Hauptverzeichnis ist die aktuelle Entwicklungskarte. Sie wurde im aktuellen World Editor geöffnet und gespielt. Im Hauptverzeichnis liegt auch `FBF_v0.4.9_dev - Working copie.w3x`. `release/` enthält ältere `.w3x`-Versionen.

Der Spielcode liegt vor allem als vJASS (`.vj`) unter `src/`. Beispiele sind Fähigkeiten unter `src/Heroes/<Hero>/`, Helden- und Turm-KI unter `src/AI-Systems/` und gemeinsame Bibliotheken unter `src/Libraries/`. `src/imports.j` legt fest, welche Dateien in die Karte eingebunden werden. Unter `documentation/` liegen ältere Bilder, Projektdaten, eine archivierte Website und eine getrennte Testkarte. Neuer Spielcode gehört zum passenden System unter `src/`.

## Sprache

Schreibe menschenlesbare Projektinhalte in einfachem Deutsch. Das gilt für Dokumentation, GitHub Issues, Pull-Request-Beschreibungen, Reviews, Commit-Nachrichten, Agent-Zusammenfassungen und Antworten. Maschinenlesbare Agent-Anweisungen und Prompts dürfen in klarem, strukturiertem Englisch bleiben, wenn das zuverlässiger ist. Übersetze keine technischen Bezeichner oder festen Warcraft-III-Werte. Dazu gehören Namen von Funktionen, Structs, Libraries, Variablen, Dateien und Pfaden, Rawcodes wie `'A07K'`, Order-Strings wie `"roar"`, Warcraft-III-Natives, API-Namen und Befehle. Ändere bestehenden Quellcode nicht allein, um Kommentare zu übersetzen. Schreibe neue oder bearbeitete Code-Kommentare möglichst in einfachem Deutsch.

## Bauen und Testen

Für die Karte gibt es keinen geprüften Build-Befehl für die Kommandozeile und keine automatische Test-Suite für das Spiel. Erfinde keine solchen Befehle. Der geprüfte Ablauf ist:

1. Bearbeite den vJASS-Code unter `src/`.
2. Prüfe, ob jede neue `.vj`-Datei in `src/imports.j` steht. Ohne diesen Eintrag wird die Datei nicht in die Karte eingebunden.
3. Öffne `FBF_v0.4.9_dev.w3x` im aktuellen Warcraft III World Editor. Er enthält JassHelper und pJASS. Aktiviere `Enable JassHelper` und `Enable vJASS` und speichere die Karte. Dabei wird sie kompiliert.
4. Starte die Karte aus dem Editor und teste die Änderung in Warcraft III.

`src/imports.j` enthält absolute Windows-Pfade zu einem bestimmten Checkout. An einem anderen Ort müssen die Pfadpräfixe vor dem Kompilieren lokal angepasst werden. Nimm diese lokale Anpassung nicht in einen fremden Commit auf. Stelle die Einträge nicht auf relative Pfade oder ein anderes Verfahren um, solange dies nicht im aktuellen Editor geprüft wurde.

`git status --short` zeigt Änderungen vor einem Commit. `git diff --check` findet Fehler bei Leerzeichen. Die vorhandenen `.psd`-Dateien sind normale Git-Dateien; für sie ist `git lfs pull` nicht nötig. Die Regel in `.gitattributes` für `*.psd` gilt für neue oder geänderte PSD-Dateien.

## Schreibweise und Dateiformat

Verwende `.vj` für vJASS-Module und übernimm die Einrückung der jeweiligen Datei. Bestehender Code mischt Tabulatoren und Leerzeichen. Formatiere keine fremden Zeilen um. Halte dich an die vorhandenen Regeln für `scope`, `library`, `struct` und `private`. Verwende aussagekräftige Dateinamen wie `HeroAIThreat.vj` oder `Cleave.vj`. Belasse Warcraft-Objekt-IDs und zugehörige Konstanten bei der betreffenden Fähigkeit. Es gibt keinen Formatter oder Linter für das ganze Projekt.

Git speichert die Textdateien durch `* text=auto` mit LF. Unter Windows kann `core.autocrlf=true` sie im Arbeitsverzeichnis als CRLF auschecken. Behalte beim Bearbeiten die vorhandenen Zeilenenden einer Datei bei und vermeide Änderungen allein an Zeilenenden. Mische LF und CRLF nicht. Die meisten Quelldateien sind UTF-8 oder ASCII. Einige `.vj`-Dateien enthalten deutsche Umlaute in Windows-1252, zum Beispiel `src/GameConfig/GameConfig.vj`. Behalte die Kodierung jeder Datei bei.

## Änderungen sicher prüfen

- **Rawcodes und Order-Strings:** Objektdaten liegen nur in der `.w3x`. Bevor du einen Rawcode oder Order-String änderst, suche alle Verwendungen unter `src/`.
- **Helden-KI:** Dateien unter `src/AI-Systems/HeroesAI/` wiederholen Werte aus Fähigkeiten unter `src/Heroes/`, etwa Spell-IDs, Order-Strings, Radien und Abklingzeiten. Passe beide Seiten gemeinsam an.
- **Gemeinsame Bibliotheken:** Suche vor einer Änderung unter `src/Libraries/` nach allen Nutzern, auch nach `optional`-Abhängigkeiten, Modulen und Textmacros.
- **Kartendateien:** Bearbeite, erzeuge oder speichere `.w3x`-Dateien nicht mit Agent-Werkzeugen. Nenne nötige Änderungen im Object Editor für einen Menschen.

## Prüfung und Berichte

Es gibt keine automatische Test-Suite für das Spiel und kein Ziel für Testabdeckung. Bei Änderungen am Spiel muss ein Mensch die Karte im Editor speichern und den betroffenen Helden, das System oder den Spielmodus in Warcraft III testen. Beschreibe Ablauf und Ergebnis im Pull Request. Die archivierte Website besitzt unter `documentation/FBF-Website/tests/phpunit.xml` eigene PHP-Tests; sie testen die Karte nicht.

Agents können die Karte derzeit nicht nachweislich kompilieren oder im Spiel testen. Statische Prüfungen wie `git diff --check` beweisen weder das Kompilieren noch das Verhalten im Spiel. Behaupte beides nur, wenn ein Mensch das Speichern im Editor oder den Spieltest durchgeführt und das Ergebnis gemeldet hat. Sonst sage ausdrücklich, dass Kompilieren oder Spieltest noch fehlen, und nenne den genauen Testfall.

## Commits und Pull Requests

Schreibe kurze, genaue Commit-Nachrichten in einfachem Deutsch. Sie sollen die geänderte Funktion oder Datei benennen. Fasse im Pull Request die Änderung zusammen, nenne das Ergebnis von Kompilieren und Spieltest oder sage, dass beides noch fehlt, und verlinke das Issue. Füge bei sichtbaren Änderungen am Spiel oder an Bildern einen Screenshot oder kurzen Clip hinzu. Committe keine Editor-Backups und keine fremden erzeugten Kartendateien.
