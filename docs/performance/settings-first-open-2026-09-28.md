# Settings: Messung auf dem S22 Ultra

28.09.2026, ca. 00:15–00:19 Uhr, Europe/Berlin.

## Nachtrag: A/B-Test und umgesetzte Maßnahme

Der anschließende Test mit unveränderter Glasqualität verglich die ursprünglichen
50 Kategorieöffnungen mit 50 Öffnungen ohne Settings-Routenanimation und
20 weiteren Öffnungen nach Wiederherstellung der Originalversion. Der Median
der Raster-Maxima pro Öffnung sank von 132,94 auf 26,35 ms und stieg mit der
Originalversion wieder auf 129,70 ms. Die ersten Öffnungen ohne Animation
blieben teilweise teuer, etwa 77,03 ms bei App & Datenschutz.

Nach Freigabe ist der getestete Übergang nun für SettingsRoute und
SettingsCategoryRoute umgesetzt: CustomRoute mit noTransition und Dauer null
in beide Richtungen. Liquid Glass bleibt standard. Der Versuch isoliert den
gesamten Übergangspfad, nicht allein dessen Fade-Effekt. Detailartefakte der
A/B-Messung: `/tmp/settings-transition-ab-20260928/`.

Der folgende Bericht beschreibt die Baseline vor dieser Maßnahme.

## Ergebnis

Der dominante gemessene Engpass liegt in der Render-Pipeline. Zusätzliches
Vorladen von Settings-Daten ist für die untersuchten Öffnungen keine passende
Hauptmaßnahme. Wiederholtes Öffnen beseitigt die Raster-Spitzen nicht.

## Aufbau

- Samsung SM-S908B, 1440 × 3088, installierte dev/Profile-Version 0.17.4+1,
  Impeller/Vulkan, Liquid Glass standard. Keine Rendering-Einstellungen geändert.
- Fünf Prozess-Kaltstarts. Je Durchlauf alle fünf Kategorien einmal öffnen,
  zurück, erneut öffnen. Reihenfolge pro Durchlauf rotieren, sodass jede
  Kategorie einmal die erste nach dem Start ist. Insgesamt 50 Kategorieöffnungen
  und fünf Öffnungen der Übersicht. Kein Löschen von App- oder Treiber-Caches.
- Nach Start zwei Sekunden warten; nach jedem Navigationstap 1,3 Sekunden
  aufzeichnen; nach Rückkehr 0,9 Sekunden warten. Die Aufnahme beginnt vor dem
  Tap. Rücknavigation wird nicht in die Kategorieaufnahme einbezogen.
- VM-Timeline: Dart, Embedder, GC. `Frame` für UI und `GPURasterizer::Draw`
  für Raster-Thread-Abschnitte, gepaarte Begin/End-Ereignisse. Keine zusätzlichen
  Widget-Profiling-Flags. Screenshots zur Prüfung der Zielseiten nach der
  Timeline-Aufnahme im ersten Durchlauf.
- Alle 1.639 erfassten PlatformVsync-Budgets betragen rund 16,67 ms. Android
  meldet anschließend ebenfalls 60 Hz. Das ist keine 120-Hz-Messung.

## Ergebnisse der unveränderten App

Werte in ms. Angegeben ist jeweils der **Median der längsten gemessenen
Frame-Abschnitte pro Öffnung** aus fünf Durchläufen. Das ist weder eine
durchschnittliche Framezeit noch die gesamte Dauer des Seitenwechsels.

| Kategorie | UI erstes Öffnen | UI erneut | Raster erstes Öffnen | Raster erneut |
| --- | ---: | ---: | ---: | ---: |
| Mein Dienstplan | 17,60 | 9,29 | 147,47 | 126,05 |
| Partner Dienstplan | 11,89 | 11,98 | 136,34 | 120,14 |
| Darstellung | 10,21 | 11,34 | 116,45 | 124,57 |
| Ferien & Feiertage | 16,55 | 7,44 | 129,66 | 134,28 |
| App & Datenschutz | 22,70 | 16,89 | 162,58 | 152,35 |

Die Übersicht selbst erreicht einen Median der Raster-Maxima von 209,41 ms.

Über alle 50 Kategorieöffnungen:

- 902 UI- und 902 Raster-Abschnitte ausgewertet.
- UI: 15/902 (1,7 %) über 16,67 ms; keine über 50 ms.
- Raster: 211/902 (23,4 %) über 16,67 ms; 95 über 50 ms.
- Median der BUILD-Maxima pro Öffnung: 2,25 ms.

Diese Anteile beziehen sich auf erfasste Arbeitsabschnitte, nicht auf die
Prozentzahl tatsächlich verworfener Displayframes. Raster-Dauer ist ebenfalls
keine isolierte Messung der GPU-Ausführungszeit; sie kann Wartezeit enthalten.

Exemplarisch `r0-app-first`: 163,79 ms in `GPURasterizer::Draw`, davon ein
überlappender `SurfaceFrame::Encode`-Abschnitt von 162,42 ms. Im selben Trace
sind lange `Canvas::saveLayer`- und `DestroyImage`-Abschnitte sowie
`SceneDisplayLag` sichtbar. Verschachtelte Zeiten dürfen nicht addiert werden.
Das grenzt den Engpass auf die Render-Pipeline ein, beweist aber noch nicht,
welche einzelne Glasfläche oder welcher Treiberpfad ihn verursacht.

## Separate Datenmessung

Eine temporäre Diagnoseversion ergänzt einen Riverpod-Observer mit
Timeline-Markierungen und eine Zeitspanne um `_settingsDao.load()` in
`SettingsRepositoryImpl.getSettings()`. Keine Einstellungswerte werden geloggt.
Ein zusätzlicher Prozess-Kaltstart, anschließend jede Kategorie zweimal öffnen.
Diese Messreihe ist nicht in den obigen Performance-Zahlen enthalten.

- Positivkontrolle beim Start: ein Settings-Datenbankzugriff, 89,91 ms;
  174 Provider-Ereignisse im Startup-Trace. Instrumentierung ist aktiv.
- Übersicht und alle zehn Kategorieöffnungen: **0 Settings-Datenbankzugriffe**.
- Dienstplan, Partner, Darstellung und Ferien: **0 Provider-Lifecycle- oder
  Update-Ereignisse** innerhalb der jeweiligen Öffnungsfenster.
- App & Datenschutz: `sentryStateProvider` wird bei beiden Öffnungen neu erzeugt.
  Loading → Data nach 14,759 ms bzw. 12,084 ms. Das misst die gesamte Zeit bis
  zur Zustandsbereitstellung einschließlich Scheduling, nicht CPU-Rechenzeit.
  Der Sentry-Service selbst wird dabei nicht neu aufgebaut.

Die Messung zählt gezielt Settings-DB-Zugriffe, nicht sämtliche Datenbank- oder
Netzwerkoperationen der App. Sie ist kein allgemeiner Nachweis „kein Netzwerk“.
Für die untersuchten Settings-Öffnungen zeigt sie keine erneute Initialisierung
der übrigen beobachteten Datenquellen.

## Konsequenz für das Konzept

1. **Rendering vor Data-Prefetch priorisieren.** Die Ansicht ruckelt auch dann,
   wenn die beobachteten Settings-Datenquellen keinerlei Aktivität zeigen.
2. Als nächsten isolierten Versuch Übergänge mit überlappenden Glas-/Hintergrund-
   Layern untersuchen, beispielsweise testweise ohne Routenanimation. Gleiche
   Messreihe und unveränderte Glasqualität verwenden; erst danach entscheiden,
   ob ein gemeinsamer Settings-Rahmen den Aufwand ausreichend reduziert.
3. Render-Layer und Ressourcenwechsel mit Impeller-Traces weiter eingrenzen;
   Repaint-Grenzen oder gemeinsame Layer nur nach positivem A/B-Ergebnis behalten.
4. Datenschutzzustand synchron aus dem initialisierten Service bereitstellen,
   dabei reaktiv halten. Das kann den kurzen Loading-Wechsel sparen, erklärt
   aber nicht allein die Raster-Spitzen von über 150 ms.

Kein Performance-Fix ist Bestandteil dieser Messung. Die Instrumentierung wurde
aus den Quellen entfernt; die ursprüngliche APK ist wieder erfolgreich installiert.

## Grenzen und Artefakte

Gemessen wurde mit den aktuellen Daten, dunklem Theme und dem vorhandenen
Gerätezustand. Keine separate Offline-/120-Hz-/Release-Messung. Keine präzise
Messung „Tap bis korrekter sichtbarer Inhalt“ oder der thermischen Entwicklung.
Fünf Durchläufe pro Fall beschreiben diese Reproduktion, keine allgemeine
Performance-Garantie. Ein kausaler Glas-/Transitions-A/B-Test steht noch aus.

- Einzelwerte: `settings-first-open-2026-09-28-summary.json` neben diesem Bericht.
- Rohdaten und Skripte dieser Sitzung: `/tmp/settings-perf-20260928/`.
  `measure.py`, `analyze.py`, `r*-*.json`; Datenprobe unter `data-probe/`.
- Original-APK SHA-256:
  `3bdd2d574bc880e5512169fb936450d158315decb8315b19979eca9e17f28f98`.
- Diagnose-APK SHA-256:
  `f4273a2bff037b7282e9e70a9cb84ca328e5633444976a71dbadbab668eff457`.
