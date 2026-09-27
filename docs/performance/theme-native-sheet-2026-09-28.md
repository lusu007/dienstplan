# Theme-Sheet: Bibliothekskomponente im Gerätevergleich

## Umfang

Begrenzter Prototyp: nur `ThemeModeBottomsheet` verwendet jetzt `liquid.GlassSheet.show()` statt `showModalBottomSheet()` mit `SelectionBottomsheet` / `GlassBottomSheet` / `GlassDialogSurface`. Auswahl-Callback und die vorhandenen nicht-refraktiven Auswahlkarten bleiben erhalten. Standard-Qualität ist explizit gesetzt; Blur entspricht dem Bottomsheet-Token (8). Eine neutrale Glastönung ersetzt die beim Öffnen festgehaltene Theme-Farbe, damit ein Theme-Wechsel bei offenem Sheet keine dunkle Fläche mit dunklem Text zurücklässt. Die Bibliothek übernimmt Handle, Safe Area, Scrollcontainer und Einfahranimation (350 ms, SlideTransition von unten). Kein zusätzlicher äußerer App-Glascontainer, keine eigene ScrollFadeMask.

Andere Sheets und Seiten wurden in diesem Versuch nicht umgestellt. Die bereits optimierten Settings-Routen bleiben ohne Seitenübergang; Sheet-Animationen bleiben aktiv.

## Messverfahren

Samsung S22 Ultra (SM-S908B), Android-Profilbuild dev/arm64, Impeller/Vulkan. A–B–A′–B′-Folge: alter Wrapper, erster Bibliotheks-Prototyp, alter Wrapper erneut, korrigierter Bibliotheks-Prototyp mit neutraler Tönung. Je Variante drei Prozessneustarts; nach Navigation Kalender → Settings → Darstellung jeweils erstes und zweites Öffnen der Theme-Auswahl, insgesamt 24 Öffnungen. Die Tönungskorrektur wurde nach der ersten Vergleichsserie durch einen manuellen Theme-Wechsel veranlasst. Nach jedem Öffnen 1,5 Sekunden VM-Timeline (Dart/Embedder/GC), danach Schließen über die Barriere. Keine Theme-Änderungen während der Messreihen. Zwischen den Serien wurde Hell → System manuell geprüft und System wiederhergestellt. Screenshots bestätigen den geöffneten Dialog und sichtbare Auswahltexte.

Rohdaten und APKs: `/tmp/theme-native-sheet/`. Die JSON-Zusammenfassung liegt neben diesem Bericht. Zeitwerte in Millisekunden; Tabellenwerte sind Mediane über jeweils drei Öffnungen. „Raster-Summe“ ist aufsummierte GPU-Rasterizer-Zeit im Messfenster, keine Öffnungsdauer.

| Variante | größte Raster-Zeit, erstes Öffnen | größte Raster-Zeit, Wiederöffnen | Raster-Summe, erstes Öffnen | Raster-Summe, Wiederöffnen |
|---|---:|---:|---:|---:|
| A: bisheriger Wrapper | 172,07 | 53,18 | 632,92 | 540,22 |
| B: GlassSheet, vor Tönungskorrektur | 132,81 | 45,17 | 581,39 | 476,06 |
| A′: Kontrolllauf alter Wrapper | 152,65 | 69,28 | 634,99 | 534,13 |
| B′: installierte Endfassung | 143,91 | 50,12 | 616,25 | 484,43 |

## Einordnung

Die installierte Endfassung zeigt etwas niedrigere typische Spitzen: 143,91 ms statt 152,65–172,07 ms in den beiden Serien mit altem Wrapper. Die aufsummierte Raster-Zeit sinkt beim Erstöffnen nur um etwa 3 %, beim Wiederöffnen um etwa 9–10 %. Das ist eine kleine Verbesserungstendenz, kein belastbarer Nachweis für eine spürbar flüssige Animation. Allerdings ist die Stichprobe klein, die Variantenreihenfolge nicht randomisiert und die Streuung hoch. Animationsdauer, Safe Area, Oberflächenform und internes Effektverhalten unterscheiden sich ebenfalls; dies ist ein Vergleich der vollständigen Komponenten, kein isolierter Nachweis für RepaintBoundary oder eine bestimmte Layer-Ursache.

Das Ruckeln ist nicht behoben: Auch die Endfassung erreicht beim Erstöffnen maximal 131–145 ms je Durchlauf. Der Hauptengpass bleibt in dieser Messung das Rendering; alle gemessenen UI-Frames liegen unter 16,7 ms. Ein breiter Umbau aller Sheets lässt sich als Performance-Fix daraus noch nicht begründen.

## Prüfung und weiterer Einsatz

Flutter-Analyse der geänderten Datei ohne Befunde. 14 bestehende Settings-Navigations- und Liquid-Glass-Regressionstests bestanden. Android-Profilbuild erfolgreich. Build meldet vorhandene KGP-Migrationshinweise für file_saver/sentry_flutter und einen Hinweis auf nicht eingebundene CupertinoIcons; in diesem Sheet werden Material-Icons verwendet.

Die Endfassung ist auf dem Handy installiert. Hell/System-Wechsel, sichtbare Auswahlmarkierung und Barrieren-Schließen wurden auf dem Gerät geprüft; System wurde wiederhergestellt. Der Prototyp bleibt auf die Theme-Auswahl beschränkt. Nächster sinnvoller Schritt ist eine gezielte Untersuchung der Raster-Arbeit während des Einfahrens, insbesondere der Hintergrund-Neuzeichnung und der Effekt-Layer. Standard-Qualität und die Einfahranimation bleiben Anforderungen.
