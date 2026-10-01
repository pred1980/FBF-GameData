# Performance-Log

Der Logger ist normalerweise aus. Im Spiel schaltet `-perflog` ihn für den eigenen Spieler ein; derselbe Befehl stoppt ihn und schreibt die letzten Messwerte. Alle 10 Spielsekunden entsteht eine Zeile. Nach jeweils sechs Zeilen wird die aktuelle Datei neu geschrieben. Nach 60 Messzeilen beginnt eine neue Datei, damit das Schreiben nicht mit der Spiellänge immer teurer wird.

Für einen Vergleichstest schaltet `-perfwander` die Wander-Befehle der Forsaken-Verteidiger aus und mit demselben Befehl wieder ein. Bereits laufende Wander-Befehle werden beim Ausschalten gestoppt. Die Timer laufen weiter und räumen tote Einheiten weiterhin auf. Lane-Creeps und ihre Wegpunkte bleiben davon unberührt.

`-perflane` hält die Bewegung der registrierten Lane-Creeps an und setzt sie mit erneuter Eingabe fort. Neue Creeps spawnen währenddessen weiter, erhalten aber erst nach dem Fortsetzen einen Wegpunktbefehl. Während der Pause läuft die Wegpunktprüfung nicht. Dieser Schalter dient nur dazu, den FPS-Effekt von Bewegung und Wegpunktprüfung im selben Spiel zu vergleichen.

Warcraft III speichert die Dateien lokal unter `Dokumente\Warcraft III\CustomMapData` als `FBF-performance-p<Spielernummer>-<Dateinummer>.txt`. Bei einem neuen Spiel können Dateien mit gleichem Namen überschrieben werden. Für einen Vergleich die Dateien daher nach dem Test sichern. Die erzeugte Textdatei enthält auch JASS-Rahmentext; die Messzeilen stehen darin als `call Preload("...")`.

Die Spalten sind durch Semikolon getrennt:

| Spalte | Bedeutung |
| --- | --- |
| `seconds` | Sekunden seit der ersten Aktivierung des Loggers in dieser Partie |
| `round` | aktuelle Creep-Runde |
| `creeps_alive` | lebende Creeps aus der vorhandenen Rundenzählung |
| `defenders_registered` | Einheiten in der Gruppe der Forsaken-Verteidiger |
| `defender_wander_paused` | `1`, wenn `-perfwander` die Wander-Befehle der Verteidiger anhält; sonst `0` |
| `lane_paused` | `1`, wenn `-perflane` die Lane-Bewegung anhält; sonst `0` |
| `wave_created` | neu erzeugte Creep-Welleneinheiten seit der letzten Zeile |
| `defense_created` | neu erzeugte Forsaken-Verteidiger seit der letzten Zeile |
| `way_registered` | Einheiten in der Gruppe des Wegpunktsystems |
| `way_seen` | davon bei der Stichprobe tatsächlich durchlaufen |
| `way_inactive` | davon tot oder bereits entfernt |
| `way_checks` | Wegpunkt-Prüfungen seit der letzten Zeile |
| `way_next` | Aufrufe von `moveNext` seit der letzten Zeile |
| `way_events` | ereignisbedingte Neuordnungen seit der letzten Zeile |
| `camera_x`, `camera_y` | lokale Kameraposition des Spielers |

Die FPS-Anzeige ist aus vJASS nicht auslesbar. FPS müssen parallel im Spiel beobachtet oder extern aufgezeichnet werden. Die Datei wird auf dem Rechner des Spielers geschrieben, der `-perflog` eingibt. Die Dateiausgabe verwendet `PreloadGenStart`, `Preload` und `PreloadGenEnd`; ob sie mit der gerade installierten Warcraft-III-Version funktioniert, muss im Editor-Spieltest geprüft werden.
