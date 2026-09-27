# Konzept: Settings-Unterseiten ohne Ruckeln beim ersten Öffnen

Stand: 28.09.2026. Grundlage: Quellcodeanalyse, noch keine neue Laufzeitmessung.

Nachtrag: Die [Gerätemessung vom 28.09.2026](performance/settings-first-open-2026-09-28.md)
zeigt dominante Raster-Spitzen bei bereits verfügbaren Settings-Daten. Daher
zuerst Render-Übergänge untersuchen; pauschales Data-Prefetch zurückstellen.

## Ziel und Rahmen

Die erste Navigation in jede Settings-Kategorie soll flüssig sein und sofort
korrekte, vorhandene Werte anzeigen. Liquid Glass bleibt auf `GlassQuality.standard`.
Der Fix gegen verschwundene Texte bleibt erhalten: keine ScrollFadeMask in den
Settings-Scaffolds. Kategorien, Aktionen und Footer bleiben bestehen.

## Befund

| Bereich | Aktueller Datenpfad | Bedeutung |
| --- | --- | --- |
| Darstellung | `settingsProvider` | Bereits im AppInitializer geladen und von MyApp beobachtet; normalerweise kein neuer Ladevorgang beim Öffnen. |
| Eigener/Partner-Dienstplan | `scheduleCoordinatorProvider` | Keep-alive, im Kalender bereits verwendet; Settings hängen trotzdem am gesamten aggregierten Kalenderzustand. |
| Ferien | `schoolHolidaysProvider` und `settingsProvider` | Ferien-Provider ist keep-alive, bei aktivierten Ferien vorgewärmt und im Kalender verwendet. Einstellungen und Ferieninhalte sind im selben Zustand gekoppelt. |
| App & Datenschutz | überwiegend statische Zeilen, `sentryStateProvider` | Sentry-Service ist bereits initialisiert und keep-alive. Der kurzlebige Future-Provider erzeugt daraus nur zwei boolesche Werte; ein Loading-Zwischenzustand ist möglich. |
| Alle Unterseiten | eigener `GlassScreenScaffold` | Jede Route erzeugt Hintergrund, Glas-Header und Inhalt neu. Ob Build, Rasterisierung oder Übergang dominieren, ist noch zu messen. |

`GetSettingsUseCase` verwendet bereits `SettingsCache` mit TTL und Zusammenführung
gleichzeitiger Leseanfragen. Ein weiterer Cache oder längere TTL ist deshalb nicht
der erste Ansatz. Die Auto-Dispose-Deklaration von `settingsProvider` allein ist
kein Beleg für wiederholtes Laden: MyApp hält eine aktive Subscription.

## 1. Erst Ursache messen

Auf dem S22 Ultra im Profile-Modus denselben Ablauf vor und nach jeder Maßnahme
aufzeichnen: App-Kaltstart, Kalender bereit, Settings-Übersicht, Kategorie öffnen,
zurück, Kategorie erneut öffnen. Jede Kategorie auch als erste Kategorie nach
einem neuen Kaltstart prüfen; Reihenfolge wechseln. Mindestens fünf Durchläufe
pro Kategorie und Zustand, ohne zwischenzeitliche Datenänderungen.

Erheben:

- Zeit vom Tippen bis zum ersten Frame mit korrekten Einstellungen; Ende der
  vorgesehenen Navigationstransition separat markieren.
- UI- und Raster-Framezeiten sowie Frames über dem Budget der tatsächlich
  aktiven Bildwiederholrate; 60 Hz und 120 Hz getrennt betrachten.
- Starts/Abschluss der Provider, Repository-Lesezugriffe, Netzwerkzugriffe,
  Loading→Data-Wechsel und Rebuilds von Seite und MyApp.
- Vergleich mit bereits geladenen Daten, um Renderaufwand isolieren zu können.

Entscheidung: Daten sind vor Navigation bereit + teure Rasterframes → Rendering
bearbeiten. Neue Ladevorgänge → Datenpfad bearbeiten. Häufige Builds bei bereits
vorhandenen Daten → Subscriptions verkleinern. Gemischte Ursachen einzeln messen.
Keine pauschale Diagnose „Shader-Kompilierung“ ohne Trace.

## 2. Schlanke Zustände für Settings

Die Kategorien erhalten kleine, abgeleitete Zustände aus vorhandenen Quellen:
eigener Dienstplan (Konfiguration, Gruppe, Farbe), Partner, Darstellung,
Ferieneinstellungen und Datenschutz. Vorhandene Quellen bleiben maßgeblich;
keine zweite Kopie aller Einstellungen mit separater Invalidierungslogik.

- Zunächst `select` auf wirklich dargestellte Werte anwenden. Die gesamte
  Kalenderaggregation darf keine Settings-Rebuilds bei Datums- oder
  Termindatenänderungen auslösen.
- Dienstplan-Anzeige anschließend, falls sinnvoll, direkt aus Config-/Partner-
  und Settings-Quellen ableiten. Anzeige und Freigabe der Aktionen müssen dabei
  dieselben fachlichen Regeln behalten. Exportdaten erst beim Export laden.
- MyApp nur die für die App-Hülle relevanten Settings beobachten lassen:
  insbesondere Theme und relevanten Initialisierungs-/Fehlerstatus. Andere
  Settings-Änderungen sollen keinen Neuaufbau der gesamten App auslösen.
- Datenschutzwerte als reaktiven, synchron lesbaren Zustand des bereits
  initialisierten Services bereitstellen. Umschalten, Reset und Fehler müssen
  diesen Zustand aktualisieren; kein einmaliger Snapshot, der später veraltet.

Erwartung: weniger unnötige Builds und Loading-Wechsel. Eine Wirkung auf das
anfängliche Ruckeln ist erst durch Vergleichsmessung bestätigt.

## 3. Einstellungen unabhängig von Inhaltsdaten anzeigen

Ferien-Schalter, Bundesland und Farbe sollen aus den gespeicherten Einstellungen
sofort verfügbar sein, auch wenn Ferieninhalte noch geladen werden. Nur der
Aktualisierungsstatus hängt an der Datenabfrage. Kalender und Ferien-Repository
behalten ihre bestehenden Caches; keine neue Netzwerkanfrage durch Navigation.

Beim Aktualisieren vorhandene Werte sichtbar halten. Lade-/Fehleranzeige nur an
betroffenen Zeilen, mit stabiler Höhe. Noch unbekannte Werte nicht als echte
Standardwerte darstellen und keine Aktionen auf falschen Defaults ermöglichen.

Speicherzugriffe aktualisieren nach Erfolg die maßgebliche Datenquelle; bei
optimistischen Änderungen Fehler sichtbar machen und nötigenfalls zurückrollen.
Tests decken Änderungen über Settings, Kalender und Reset ab.

## 4. Rendering gezielt verbessern, wenn die Messung es bestätigt

Alle Seiten verwenden denselben Scaffold-Typ, aber jeweils eine neue Instanz.
Als nächsten Schritt einen gemeinsamen Settings-Rahmen mit dauerhaftem
Hintergrund und Header prüfen, in dem nur Titel und Kategorieinhalt wechseln.
Routing, System-Zurück, Deep Links und Scrollpositionen müssen dabei erhalten
bleiben. Das ist ein separater struktureller Schritt, kein vorausgesetzter Fix.

Vorher kleinere A/B-Versuche: Repaint-Grenzen um den statischen Hintergrund und
Prüfung der Renderarbeit während überlappender Routenanimationen. Zusätzliche
Layer nur behalten, wenn sie messbar helfen und keinen relevanten Speicher- oder
Raster-Mehraufwand verursachen. Keine versteckt gerenderten Unterseiten und
kein Offstage-Warmup als Standardlösung.

## Reihenfolge und Abnahme

1. Baseline aufnehmen und dominierenden Aufwand benennen.
2. Kleine Daten-/Subscription-Verbesserungen passend zum Befund umsetzen.
3. Ferienkonfiguration entkoppeln, falls deren Ladepfad die Anzeige blockiert.
4. Bei verbleibenden Render-Spitzen gemeinsamen Rahmen untersuchen.

Ziel: vorhandene Settings im ersten Inhaltsframe; keine allein durch Navigation
ausgelösten Datenbank-/Netzwerkzugriffe bei bereits geladenem Zustand. Als
Performance-Ziel mindestens 95 % der Übergangsframes innerhalb des jeweiligen
Framebudgets und keine reproduzierbare Pause über 50 ms. UI- und Rasterwerte
separat berichten; Ziele sind noch keine gemessenen Ergebnisse.

Zusätzlich prüfen: Änderungen nach Zurücknavigation korrekt, Offline-Modus,
Hell/Dunkel, große Schrift, System-Zurück, keine verschwundenen Texte. Kleine
Provider-Tests für Aktualisierung und Rebuild-Isolation plus Navigationstests;
Performance-Abnahme auf dem Gerät. Kein zusätzlicher blockierender App-Start
durch pauschales Vorladen aller Settings-Unterseiten.
