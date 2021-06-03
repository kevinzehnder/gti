# Projektarbeit GTI

## Teammitglieder

- Müller, Tobias *tobias.mueller@students.ffhs.ch*
- Jenni, Marc *marc.jenni1@students.ffhs.ch*
- Zehnder, Kevin *kevin.zehnder@students.ffhs.ch*

## Absicht und Ziele

Die Ziele sind weitgehend von der Aufgabenstellung vorgegeben:

1. Erweitern des PI3 (Raspberry Pi 3) um eine LED-Komponente
2. Implementieren einer Assembler-Routine (Bare-Metal-Ansatz), welche die LED ansteuert und damit ein SOS-Signal regelmässig wiederkehrend erzeugt

Als zusätzliche Erweiterung beschränken wir uns auf folgenden Punkt:

- Akustische Ausgabe des Morsesignals

## Beschreibung der Aufgabe

In der Aufgabe geht es darum anhand von ARM Assembly ein wiederkehrendes Morsesignal zu programmieren. Uns stehen dazu ein PI3 und einige elektronischen Bauteile wie LEDs und Widerstände zur Verfügung, welche uns erlauben das Resultat visuell darzustellen.

## Planung des Vorgehens und des Arbeitsfortschritts

Da keiner von uns Erfahrung hat mit hardwarenahe Programmierung, wäre es sich von Vorteil, wenn jeder eigenständig mindestens die Aufgaben bezüglich des "JOHNNY Simulators" durchgearbeitet hat, um ein grundlegendes Verständnis für schwierigere Sachverhalte zu haben.

Wir haben uns für die **Variante 1 FASMARM** entschieden, da diese im Moodle besser dokumentiert ist und das Setup im Vergleich zur Alternative einen deutlich unkomplizierteren Eindruck macht. Wir konnten das Beispiel mit der blinkenden LED am GPIO 24 bereits selber compilieren und haben es auf dem PI3 zum laufen gebracht.
Das Ziel wäre es jetzt also den Code im *kernel7.asm* so anzupassen, dass die LED ein Morsesignal erzeugt. Um auch andere Signale als das SOS-Signal wiederzugeben werden wir das Signal-Pattern in einer Konstante zu Beginn des Programms definieren. Wenn man also ein anderes Signal ausgeben möchte, muss man nur den Wert der Konstante anpassen.

Wir werden ein GitLab-Repository verwenden, um besser zusammenarbeiten zu können und um den Code zu versionieren.

Da wir das Morsesignal auch akustisch ausgeben möchten, müssten wir noch einen simplen 5V-Buzzer beschaffen.

## Milestones und Delivery

### PVA-1 (19.08.2019)

- Kick-off zur Projektarbeit GTI
- Organisation der Gruppen
- Start der Disposition

Anmerkung: Bereits erledigt zum Zeitpunkt der Abgabe der Disposition.

### PVA-2 (16.09.2019)

- Abgabe der Disposition "Projektarbeit GTI"
- Genehmigung der Disposition durch Dozierenden

### PVA-3 (14.10.2019)

- **Verstehen der Assembly Beispiele im Moodle**
- **Erste eigene Versuche mit ARM Assembly**

### PVA-4 (11.11.2019)

- **Code: Aufgabenstellung weitgehend fertig**
- **Bericht anfangen**

### PVA-5 (09.12.2019)

- **Bericht fertig**
- **Falls nötig noch Korrekturen am Code**
- Präsentation "Projektarbeit GTI"

### Prüfungssession

- Abgabe des Bericht "Projektarbeit GTI"

## Literaturverzeichnis

Alles vorgegebene ist der Aufgabenstellung im Moodle entnommen: <https://moodle.ffhs.ch/mod/page/view.php?id=3242402>
