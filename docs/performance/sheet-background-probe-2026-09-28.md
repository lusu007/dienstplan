# Bottomsheet: Hintergrund, Tipp-Effekt und Blur

## Fragestellung und Grenzen

Temporäre Diagnose auf dem Samsung S22 Ultra (SM-S908B), dev/arm64-Profilbuild, Impeller/Vulkan. Ausgangspunkt ist die zuvor umgestellte Theme-Auswahl mit `GlassSheet.show()`, explizitem Standard-Modus und aktiver 350-ms-Einfahranimation. Kein dauerhafter UI-Umbau in dieser Untersuchung.

Drei Prozessneustarts pro Variante; pro Start jeweils erstes und zweites Öffnen nach Kalender → Settings → Darstellung. Je Öffnung 1,5 Sekunden VM-Timeline mit Dart/Embedder/GC, anschließend Schließen über die Barriere. Werte sind Millisekunden, aggregiert als Median der drei Öffnungen. Raster-Summe ist aufsummierte `GPURasterizer::Draw`-Zeit, nicht die Dauer bis zum sichtbaren Sheet. Die Raster-Spitze ist der größte Draw je Öffnung, danach Median über die Durchläufe. Rohdaten, Screenshots und Diagnose-APKs unter `/tmp/sheet-background-probe/`.

Varianten:

- A: vollständige Settings-Seite, normaler Tipp-Effekt, Sheet-Blur 8.
- B: dieselbe Sheet-Komponente vor einer statischen einfarbigen Seite; Auslösung durch GestureDetector ohne Ink. Diese Variante ändert sowohl Hintergrund als auch Trigger-Effekt.
- C: vollständige Settings-Seite; nur in der Darstellungskategorie `NoSplash` und transparente Highlight-/Splash-Farben. Sheet-Animation und Blur bleiben erhalten.
- D: vollständige Settings-Seite und normaler Tipp-Effekt; nur Sheet-Blur auf 0. Der Standard-Modus und die Einfahranimation bleiben aktiv. In der Bibliothek entfällt dadurch der kombinierte Backdrop-Filter aus Blur und Sättigung; außerdem wird der von Blur abhängige Interaktions-Glow-Zweig nicht aufgebaut. Dies isoliert den Filterpfad, nicht ausschließlich die Gauß-Berechnung.
- A′: abschließender Kontrolllauf mit wiederhergestellter Ausgangsversion.

## Ergebnisse

| Variante | Raster-Spitze erstes Öffnen | Raster-Spitze Wiederöffnen | Raster-Summe erstes Öffnen | Raster-Summe Wiederöffnen |
|---|---:|---:|---:|---:|
| A: normal | 144,67 | 48,02 | 576,37 | 439,75 |
| B: einfacher Hintergrund | 137,49 | 56,25 | 376,15 | 316,78 |
| C: ohne Tipp-Effekt | 127,70 | 52,45 | 401,99 | 350,02 |
| D: Blur 0 | 70,59 | 25,00 | 394,36 | 338,29 |
| A′: Kontrolle | 123,35 | 45,08 | 612,36 | 472,11 |

## Interpretation

Der einfache Hintergrund reduziert die aufsummierte Raster-Arbeit um etwa 35 % beim Erstöffnen, beseitigt aber die große Spitze nicht. Bereits ohne Tipp-Effekt auf der ansonsten unveränderten Seite sinkt die Summe um etwa 30 %; die typische Zahl gezeichneter Raster-Frames fällt von 24 auf 11. Damit erklärt die zusätzliche Animation der auslösenden Zeile einen erheblichen Teil der Arbeit. Das ist kein Beleg, dass der ganze Hintergrund bei jedem Frame vollständig neu gezeichnet wird. Eine solche Aussage würde separate Paint-Instrumentierung erfordern.

Der deutlichste Unterschied bei den Einzelbildern entsteht im Blur-0-Vergleich: ungefähr halbierte Spitzen gegenüber A. Dies grenzt den Backdrop-Filter-/Compositing-Pfad als wichtigen Engpass ein. Auch dann verbleiben langsame Frames; ein alleiniger Verursacher ist nicht nachgewiesen. RepaintBoundaries oder ein genereller GlassScaffold-Umbau sind durch diese Untersuchung noch nicht als Lösung bestätigt.

Der Kontrolllauf mit wiederhergestellter Ausgangsversion zeigt typische Spitzen von 123.35 ms beim Erstöffnen und 45.08 ms beim Wiederöffnen. Der Filter-Vergleich bleibt damit auffällig, die Erstöffnungs-Spitzen streuen jedoch erheblich.

Die Varianten wurden nacheinander statt randomisiert gemessen; die Stichprobe ist klein und GPU-/Temperaturzustand wurde nicht kontrolliert. Die Summen berücksichtigen auch unterschiedlich viele gezeichnete Frames. Eine kleinere Raster-Summe allein bedeutet deshalb nicht automatisch eine flüssigere Einfahranimation.

## Folgerung

Eine dauerhafte Entfernung des Hintergrunds oder der Einfahranimation ist nicht angezeigt. Sinnvoll ist eine gezielte Optimierung des Backdrop-Filter-Pfads mit Standard-Qualität, gefolgt von einem erneuten Gerätevergleich. Parallel lässt sich prüfen, ob bei Sheet-Auslösern die auslaufende Ink-Animation vermieden werden kann, ohne die Bedienrückmeldung zu verschlechtern. Vor einer gemeinsamen Änderung aller Sheets muss der Effekt zusätzlich beim Termin-Sheet bestätigt werden.

Alle temporären Source-Änderungen sind anhand der exakten Sicherungen zurückgenommen (Bytevergleich erfolgreich). Die Ausgangs-APK wurde erfolgreich installiert; anschließend wurde A′ auf dieser Version gemessen. Auch die APK im Build-Verzeichnis ist wieder die Ausgangsversion. Keine Tests neu angelegt, da alle Änderungen rein diagnostisch und vollständig zurückgenommen sind; alle drei Diagnose-Profilbuilds waren erfolgreich. Der bestehende Theme-Sheet-Prototyp und die früheren Settings-Routenoptimierungen bleiben erhalten.
