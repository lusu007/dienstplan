# Bottomsheet-Optimierung

## Übernommene Änderung

- Gemeinsamer Bottomsheet-Blur von 8 auf 4 reduziert. Die Oberfläche bleibt unscharf, wirkt aber etwas klarer. Standard-Render-Modus und Einfahranimation bleiben erhalten.
- Settings-Zeilen, die ein Sheet öffnen, verwenden `modalTrigger: true`. Dadurch entfallen Ink-Splash und auslaufendes Press-Highlight hinter dem Sheet. InkWell, Aktivierungslogik, deaktivierter Zustand, Fokus und Semantik bleiben bestehen. Andere Karten behalten ihre Tipp-Rückmeldung.
- Gilt für Theme, eigene/Partner-Dienstplanung, Export, Bundesland, Ferienfarbe und Reset. Die Theme-Auswahl bleibt bei der zuvor eingeführten Bibliotheks-Sheet-Komponente.

Ein versuchter Umbau auf einen separaten nativen BackdropFilter unter dem Bibliotheksmaterial wurde nach dem Gerätevergleich vollständig verworfen: kein überzeugender Vorteil beim Termin-Sheet und schlechtere Theme-Spitzen. Es bleiben keine zusätzlichen Filter-Wrapper oder Änderungen am Bibliothekscode zurück.

## Gerätevergleich

Samsung S22 Ultra, Android-Profilbuild dev/arm64, Impeller/Vulkan. Je Variante drei Prozessneustarts, zuerst Termin-Sheet, dann Theme-Sheet, jeweils erstes und zweites Öffnen. 1,5 Sekunden Timeline pro Öffnung, Dart/Embedder/GC. Mediane über drei Öffnungen; Raster-Spitze ist das Maximum je Öffnung, danach Median. Raster-Summe ist aufsummierte Draw-Zeit, keine Öffnungsdauer.

| Messung | Ausgang: Raster-Spitze | Blur 4: Raster-Spitze | Ausgang: Raster-Summe | Blur 4: Raster-Summe |
|---|---:|---:|---:|---:|
| Termin, erstes Öffnen | 100,68 ms | 75,69 ms | 445,18 ms | 415,55 ms |
| Termin, wiederholt | 86,81 ms | 61,24 ms | 340,50 ms | 303,30 ms |
| Theme, erstes Öffnen | 114,95 ms | 120,01 ms | 572,10 ms | 368,44 ms |
| Theme, wiederholt | 53,78 ms | 45,88 ms | 476,17 ms | 307,13 ms |

Der anschließende Kontrolllauf mit der Ausgangs-APK ergibt:

| Messung | Kontrolle: Raster-Spitze | Kontrolle: Raster-Summe |
|---|---:|---:|
| Termin, erstes Öffnen | 65,54 ms | 383,40 ms |
| Termin, wiederholt | 78,15 ms | 326,56 ms |
| Theme, erstes Öffnen | 89,70 ms | 507,29 ms |
| Theme, wiederholt | 57,68 ms | 441,44 ms |

Damit ist die anfänglich beobachtete Erstöffnungs-Verbesserung **nicht belastbar bestätigt**. Die Endfassung mit Blur 4 liegt beim ersten Öffnen über dem späteren Kontrolllauf. Ein Vorteil bleibt beim Wiederöffnen des Termin-Sheets (61,24 statt 78,15–86,81 ms) und bei der aufsummierten Theme-Raster-Arbeit (ungefähr 27–36 % weniger). Diese Einschränkung ist wichtiger als der günstigere anfängliche Vergleich.

Die Verbesserung ist begrenzt: beim Termin-Sheet niedrigere Spitzen beim Wiederöffnen, beim Theme-Sheet vor allem etwa 35 % weniger Raster-Arbeit durch weniger zusätzliche Animation. Die erste Theme-Spitze ist nicht verbessert. Auch die neue Variante verfehlt weiterhin das 16,7-ms-Budget. Kleine Stichprobe, nicht randomisierte Reihenfolge, Temperaturzustand nicht kontrolliert. Die Messung belegt keine vollständig flüssigen Sheets und erlaubt keine isolierte Attribution aller Unterschiede auf die Blur-Stärke, da beim Theme gleichzeitig der Ink-Effekt entfällt.

Rohdaten, Screenshots und APKs: `/tmp/sheet-filter-optimization/`. Die verworfene Variante liegt unter `optimized`, die übernommene Kernänderung unter `blur4`. Der spätere Endbuild erweitert die Ink-Policy auf die übrigen Settings-Sheet-Auslöser.

## Prüfung

Statische Analyse ohne Befunde. 17 bestehende Bottomsheet-, Liquid-Glass- und Settings-Navigationstests bestanden. Darunter Prüfungen auf Inhalt während der Einfahranimation, stabile Material-Identität, Auswahl-Aktionen, Dialogergebnisse und verschachtelte nicht-refraktive Bedienelemente. Screenshots des Termin- und Theme-Sheets geprüft. Profilbuild erfolgreich; bekannte Build-Hinweise betreffen KGP-Migration und CupertinoIcons.

## Installierte Endfassung

Endbuild erfolgreich auf dem Gerät installiert (SHA-256 `0cd8a93d6edb45499f7a554783b07f3e6bc2521ea4475d665a3ca6a27deacf7e`). Anschließender Smoke-Test: Termin-, Theme-, Gruppen-, Farb- und Konfigurations-Sheet jeweils geöffnet, geschlossen und wieder geöffnet; Screenshots auf sichtbare Inhalte geprüft. Keine Auswahlwerte geändert und keine Termine gespeichert. Dieser einzelne Smoke-Lauf dient der Funktionsprüfung, nicht als zusätzliche kontrollierte Performance-Serie. Eine eingehende Systembenachrichtigung während dieses Laufs ist ein weiterer Grund, dessen Zeitwerte nicht für Performance-Aussagen zu verwenden.
