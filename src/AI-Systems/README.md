# Dokumentation der Hero-KI

## Inhaltsverzeichnis

1. Einleitung
    - Überblick über die Hero-KI
    - Ziele der KI

2. Struktur und Module
    - 2.1 HeroAI.vj (Grundlegende Mechaniken)
    - 2.2 HeroAIItem.vj (Item-Management)
    - 2.3 HeroAIPriority.vj (Zielpriorisierung)
    - 2.4 HeroAIThreat.vj (Bedrohungsbewertung)
    - 2.5 HeroAIEventResponse.vj (Ereignisreaktionen)

3. Funktionsweise
    - 3.1 Entscheidungsfindung und Priorisierung
    - 3.2 Bedrohungslogik und Fluchtentscheidungen
    - 3.3 Interaktion mit Items und Inventar
    - 3.4 Dynamische Ereignisreaktionen

4. Technische Details
    - 4.1 Globale Konstanten und Konfigurationen
    - 4.2 Timer- und Schleifensteuerung
    - 4.3 Abhängigkeiten und externe Module

5. Anpassungsmöglichkeiten
    - Zielpriorisierung
    - Bedrohungsbewertung
    - Item-Logik
    - Ereignisreaktionen

6. Limitierungen der Hero-KI

7. Erweiterungsvorschläge

8. Fazit und nächste Schritte

---

## 1. Einleitung

Die Hero-KI ist ein Framework, das speziell für die Steuerung von Helden in Warcraft-III-Karten entwickelt wurde. Sie ermöglicht es Helden, autonom und strategisch auf die sich dynamisch verändernden Spielsituationen zu reagieren. Dank ihres modularen Designs ist sie flexibel anpassbar und erlaubt die Integration neuer Funktionen.

### Ziele der KI:
- **Autonomie:** Helden handeln unabhängig ohne Spielersteuerung.
- **Flexibilität:** Anpassbar an unterschiedliche Kartenanforderungen.
- **Strategie:** Intelligentes Verhalten basierend auf Faktoren wie Bedrohungen, Ressourcen und Zielen.

---

## 2. Struktur und Module

### 2.1 HeroAI.vj (Grundlegende Mechaniken)

Dieses Modul steuert die grundlegenden Funktionen der Hero-KI. Es definiert die Sichtweite, Bewegungslogik und die Zustände des Helden.
- **Sichtweite:** Definiert, wie weit der Held Feinde und Ziele wahrnehmen kann.
- **Bewegung:** Die Heldenposition wird basierend auf Zielen und Gefahren optimiert.
- **Zustände:** Wechseln dynamisch zwischen Kampf, Flucht und anderen Szenarien.

Erweiterung: Die Bewegungslogik berücksichtigt Hindernisse und Gelände, wodurch Helden sicher und effizient navigieren.

---

### 2.2 HeroAIItem.vj (Item-Management)

Das Item-Management-Modul ermöglicht eine intelligente Verwaltung von Ressourcen:
- Automatische Käufe von benötigten Items wie Heiltränken.
- Verkaufslogik, um Platz im Inventar zu schaffen.
- Nutzung von Items basierend auf Schwellenwerten, z. B. Gesundheit oder Mana.

Erweiterung: Die KI priorisiert wichtige Items basierend auf den aktuellen Bedürfnissen des Helden.

---

### 2.3 HeroAIPriority.vj (Zielpriorisierung)

Dieses Modul bewertet Ziele nach ihrer Relevanz:
- **Leben:** Gegner mit wenig Leben werden bevorzugt, um sie schnell auszuschalten.
- **Entfernung:** Nähere Ziele werden priorisiert.
- **Gefahr:** Starke Gegner werden höher priorisiert, um größeren Schaden zu verhindern.

Erweiterung: Die Zielbewertung kann durch situationsbedingte Anpassungen verfeinert werden, z. B. Fokus auf Ziele mit Buffs.

---

### 2.4 HeroAIThreat.vj (Bedrohungsbewertung)

Dieses Modul analysiert die Bedrohungssituation:
- Gesamtbedrohung durch Feinde wird berechnet.
- Überschreitet die Bedrohung einen Schwellenwert, wechselt der Held in den Fluchtmodus.

Erweiterung: Die Bedrohungslogik kann erweitert werden, um Gruppenverhalten zu berücksichtigen, z. B. Flucht bei Überzahl.

---

### 2.5 HeroAIEventResponse.vj (Ereignisreaktionen)

Helden reagieren dynamisch auf Spielereignisse wie Angriffe oder Zauber.
- Ereignisse werden priorisiert, um chaotisches Verhalten zu vermeiden.
- Erweiterungen ermöglichen die Integration spezifischer Ereignisse wie Quest-Ziele oder spezielle Boss-Aktionen.

---

## 3. Funktionsweise

### 3.1 Entscheidungsfindung und Priorisierung

Die Entscheidungslogik kombiniert Zielpriorisierung und Bedrohungsbewertung, um Aktionen zu planen. Dabei kommunizieren Module nahtlos miteinander, um eine kohärente Handlung zu ermöglichen.

---

### 3.2 Bedrohungslogik und Fluchtentscheidungen

Die Bedrohungsbewertung stellt sicher, dass Helden nicht in aussichtslose Kämpfe verwickelt werden. Eine abgestufte Bedrohungslogik kann helfen, unterschiedliche Fluchtszenarien zu handhaben, z. B. defensive Rückzüge oder Gruppenflucht.

---

### 3.3 Interaktion mit Items und Inventar

Das Inventarmanagement optimiert den Ressourceneinsatz. Erweiterungen könnten eine komplexere Kauflogik für fortgeschrittene Items integrieren.

---

### 3.4 Dynamische Ereignisreaktionen

Die KI passt sich in Echtzeit an unerwartete Ereignisse an. Ein zukünftiger Schwerpunkt könnte die Erweiterung von Ereignisreaktionen auf komplexe Mechaniken wie Gebietskontrolle sein.

---

## 4. Technische Details

### 4.1 Globale Konstanten und Konfigurationen

Globale Konstanten steuern grundlegende Verhaltensparameter. Anpassbare Werte ermöglichen die Feineinstellung der KI für unterschiedliche Karten.

---

### 4.2 Timer- und Schleifensteuerung

Effiziente Timer- und Schleifenmechanismen stellen sicher, dass Aktionen regelmäßig und ressourcenschonend ausgeführt werden.

---

### 4.3 Abhängigkeiten und externe Module

Externe Module wie **PruneGroup** und **FitnessFunc** erweitern die Funktionalität der Hero-KI. Sie ermöglichen erweiterte Logik zur Zielbewertung und Filterung.

---

## 5. Anpassungsmöglichkeiten

- **Zielpriorisierung:** Anpassung der Gewichtungen für spezifische Ziele.
- **Bedrohungsbewertung:** Feineinstellung des Schwellenwertes für Flucht oder Verteidigung.
- **Item-Logik:** Integration neuer Items und spezialisierter Nutzungsregeln.
- **Ereignisreaktionen:** Hinzufügen neuer, komplexer Szenarien.

---

## 6. Limitierungen der Hero-KI

- **Koordination:** Derzeit keine Unterstützung für koordinierte Teamtaktiken.
- **Ressourcenintensität:** Große Karten mit vielen Helden können die Performance belasten.
- **Spezifische Anpassungen:** Aktuell ist die KI nur bedingt für Szenarien mit sehr individuellen Mechaniken geeignet.

---

## 7. Erweiterungsvorschläge

- **Lernalgorithmen:** Integration maschinellen Lernens, um das Verhalten der KI dynamisch zu verbessern.
- **Teamkommunikation:** Helden könnten untereinander kommunizieren, um koordinierte Aktionen auszuführen.
- **Erweiterte Ereignislogik:** Unterstützung für komplexe Szenarien wie Bosskämpfe oder Quests.

---

## 8. Fazit und nächste Schritte

Die Hero-KI bietet eine solide Grundlage für autonomes Heldenverhalten, ist jedoch ausbaufähig. Mit gezielten Erweiterungen und Optimierungen kann sie an nahezu jede Spielsituation angepasst werden.

### Nächste Schritte:
- **Tests:** Umfassende Testszenarien zur Validierung der KI.
- **Optimierungen:** Feintuning für spezifische Kartenszenarien.
- **Erweiterungen:** Integration neuer Module für fortgeschrittene Funktionen.  
