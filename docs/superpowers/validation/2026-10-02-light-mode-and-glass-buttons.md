# Light Mode und Glasbuttons — Abnahme vom 2026-10-02

## Arbeitsstand und Umfang

Branch `codex/calendar-entry-editor`, Basis `b3afc8e`, uncommitteter Arbeitsstand. Die vier vorher akzeptierten Kalender-/Styleguide-Änderungen sind erhalten. Kein Commit, Push oder Abhängigkeitsupgrade. `liquid_glass_widgets` bleibt 1.7.2.

Umgesetzt: Light-Kontrast und Auswahlmarker, Light-Modalfüllung, native Glasbuttons mit Rollen/Zuständen, Migration der Appaktionen, Öffnungsindikatoren, Ferien-Voraussetzung, ganztägige Light-Darstellung, Abbrechen beim Reset und responsive Debugwerte. Die Prüfung hat zusätzlich Light-Überläufe bei Jahresbereich, Neuigkeiten und Screenshot-Anhang korrigiert.

Der Dark Mode behält seine Flächen, Farbalgorithmen, Auswahlmarker und Inhaltslayouts. Die größeren Button-Touchziele haben zunächst die kompakte Dienstliste verschoben; adaptive Dark-Abstände erhalten jetzt die ursprüngliche Headerhöhe bei Faktor 1,0 und 1,3. Die Monatsnavigation und Kontakt-/Feedback-Menüreferenzen bleiben gemäß Plan zurückgestellt.

## Automatisierte Nachweise

- Ausgangsstand: 92 Tests bestanden.
- Integrierter Stand: **122 Tests bestanden** (`suite-installed-final.log`, finaler installierter Code).
- `flutter analyze --no-pub`: keine Findings, auch nach der letzten Ausrichtung (`analyze-alignment.log`).
- `git diff --check`: keine Whitespacefehler.
- ARM64-Dev-Debug-APK erfolgreich gebaut: `build/app/outputs/flutter-apk/app-arm64-v8a-dev-debug.apk`, passend zum S22 Ultra.

Regressionsfälle wurden vor den Änderungen beobachtet: helle Badges/Picker/Chips, Light-Modalfüllung und Theme-Wechsel, Ganztägig-Umschaltung, Ferien-Voraussetzung, Reset-Abbrechen, Dark-Headerhöhe, schmale Jahreswahl, native destruktive Füllung, Anhangstatus und Neuigkeiten-Dialog. Callback-, Loading-/Disabled-, Semantik-, Touchziel- und Umbruchprüfungen schützen die Buttonadapter. Test-Sentry und Test-Feedback laufen ausschließlich mit injizierten Stubs.

Die Termineingabetests verwenden 600 dp wegen der künstlich breiten Ahem-Glyphen der unveränderten Bibliothekschips; Smartphonebreiten werden zusätzlich nativ geprüft. Der neue schmale Jahrestest bildet einen Labelzustand ab, der ohne Marker passt und mit Marker überläuft; die echte Roboto-Darstellung wird am Gerät gegengeprüft.

## Kontrast und Oberflächen

Die Badgeprüfung wählt nach Alpha-Komposition Schwarz oder Weiß auf der tatsächlichen Füllung. Für die geprüften opaken Farben ergeben sich:

| Füllung | Kontrast |
| --- | ---: |
| Türkis `#00B89F` | 8,36:1 |
| Orange `#FF7A33` | 8,08:1 |
| Grün `#5FBF3A` | 9,00:1 |
| Gelb `#FFC933` | 13,65:1 |
| Grau `#B0BEC5` | 11,02:1 |
| Schwarz / Weiß | 21,00:1 |

Transparente und neutrale Außenmonat-Füllungen sind ebenfalls mit mindestens 4,5:1 geprüft. Dark-Außenmonat-Schrift nutzt weiter den ursprünglichen Akzent als Eingabe.

Light-Dialoginhalte haben `glassDialogContentAlphaLight = 0.90`, mit semantischer Surface-Farbe innerhalb der bestehenden Glasfläche. Sheet-Blur 4, Standardqualität und bestehende Öffnungsanimation bleiben erhalten. Am Gerät sind Hintergrundzeichen nicht mehr als störender Zweitinhalt lesbar. Die Theme-Auswahl aktualisiert sich in derselben Route.

Am nativen Light-Zurücksetzen-Button hatte der erste Stand 3,572:1: Schrift RGB(186,26,26), Füllung RGB(225,182,187). Der Light-Text verwendet deshalb `onErrorContainer`; Dark verwendet weiter `error`. Final nativ gemessen: RGB(147,0,10) auf derselben Füllung = **5,172:1**. Der Regressionstest prüft die tatsächlich beobachtete Füllung.

## Geräteprüfung

Samsung S22 Ultra, ADB `R3CT609DD1V`, 1440 × 3088 physische Pixel, Dichte 600 (= 384 dp Breite). Vorübergehend Dichte 720 (= 320 dp), Schriftfaktoren 1,0 und 1,3. Gerät über USBIPD `2-6` wieder an WSL angeschlossen.

Geprüfte Light-Seiten und Interaktionen:

- Kalender in großer und kompakter Ansicht sowie Tagesdetails; Monat und Jahr einschließlich 320 dp/Faktor 1,3.
- Neuer ganztägiger Termin: Uhrzeit im Light Mode ausgeblendet; Umschaltung und Werterhalt zusätzlich im Widgettest.
- Alle fünf Einstellungskategorien; eigene/Partner-Konfiguration, Gruppen-/Farbwahl, Export-Sheet.
- Ferien aktiviert ohne Bundesland: erklärender Hilfstext; Bundesland-Sheet geöffnet, danach Ferien wieder deaktiviert.
- Reset-Bestätigung mit sichtbarem Abbrechen; Abbrechen schließt, kein Reset.
- Neuigkeiten, About, Haftungsausschluss, Datenschutz und Lizenzen.
- Feedback mit Faktor 1,3/Tastatur: Aktionen durch Scrollen erreichbar; Screenshot lokal angehängt, kein Versand.
- Setup-Schritte 1–5 mit Faktor 1,3: Auswahl nur im flüchtigen Setupzustand, Abschluss nicht gedrückt.
- Debug mit Faktor 1,3; kein Sentry-Test auf dem Gerät ausgelöst.

Interaktionszustände während asynchroner Arbeit werden gezielt in Widgettests geprüft. Ein echter Feedback-/Sentryversand, Exportimport oder Setupabschluss gehört nicht zur Geräteabnahme, weil dabei Daten oder externe Zustände verändert würden. Shader-Performance wurde visuell beurteilt, nicht als FPS-Benchmark gemessen.

## Unabhängiges Review

Ein frischer Read-only-Reviewer hat keine kritischen Probleme und ein wichtiges Problem gefunden: zusätzliches Light-Häkchen überfüllt schmale Jahreszellen. Der Fall wurde reproduziert und korrigiert; bei Platzmangel steht der Marker über der unverkleinerten Jahreszahl. Weitere Gerätefunde wurden mit gezielten Regressionen behoben. Keine Implementierung delegiert.

## Belege

Lokale, temporäre Logs/Screenshots: `/tmp/dienstplan-ui-2026-10-02/`. Nur tatsächlich betrachtete Aufnahmen zählen: `*-checked`, `*-real`, `*-loaded` und unten aufgeführte finale Bilder. Frühe Aufnahmen während Installations-/Routewechseln sind teilweise falsch benannt und ausdrücklich keine Abnahmebelege. Die finalen Bildvergleiche schließen Statusleiste und neue Buttons aus. Keine Gerätescreenshots mit Benachrichtigungen im Repository gespeichert.


## Finaler Dark-Vergleich und Wiederherstellung

Bei identischen Daten/Tag/Schrift/Viewport haben diese Ausschnitte **maximale Kanalabweichung 0, Mittelwert 0 und 0 veränderte Pixel** gegenüber den Referenzen:

| Bereich | Finales Bild | Ausschnitt (physische Pixel) |
| --- | --- | --- |
| Große Kalenderansicht | `dark-full-final.png` | (0,655)–(1440,2728) |
| Monatsselektor | `dark-full-final.png` | (309,310)–(921,490) |
| Kompaktes Kalenderraster | `dark-compact-final.png` | (0,655)–(1440,1660) |
| Datumsüberschrift ohne Buttons | `dark-compact-final.png` | (0,1660)–(930,1855) |
| Kompakte Dienstliste | `dark-compact-final.png` | (0,1945)–(1440,2728) |
| Theme-Sheet | `theme-dark-final.png` | (0,1810)–(1440,3032) |
| Darstellungskarten hinter Theme-Sheet | `theme-dark-final.png` | (0,385)–(1440,1700) |
| Farbauswahl | `dark-color-final.png` | (0,1205)–(1440,3032) |

Die Dark-Termineingabe behält insbesondere die bisherige ganztägige Uhrzeit und ihre Elementpositionen. Für die komplette transparente Terminfläche wird keine Pixelidentität behauptet: neue Kalenderbuttons im Hintergrund beeinflussen deren Komposition. Der Kalender und die Modalaufbauten selbst sind separat gegengeprüft.

Andere Dienstgruppen nativ ein- und wieder ausgeblendet: Zusatzgruppen erscheinen, Originalzustand mit eigenen/Partnerdiensten bleibt erhalten. Endstand `restored-final.png`: kompakt, 2. Oktober 2026, andere Gruppen ausgeblendet. App-Theme wieder **System**, Android-Nightmode **yes**, Schrift **1.0**, physische Dichte **600 ohne Override**. Ferienanzeige wieder deaktiviert; Dienstpläne, Gruppen und Akzentfarben erhalten. Kein Termin gespeichert, kein Reset/Export/Feedbackversand und kein Setupabschluss.

Letzter Build inklusive Debugausrichtung: `build-installed-final.log`; installiert über komprimierten ADB-Push und `pm install -r`, beide erfolgreich. Die temporäre Installationsdatei auf dem Gerät wurde entfernt. Enge finale Light-Gerätebelege: `light-year-final-320-130.png` (vollständiger Jahresbereich, sichtbarer Auswahlmarker) und `light-whatsnew-final-narrow.png` (scrollbarer Inhalt, sichtbare Bestätigung). Große Schrift/Tastatur in der Termineingabe: `light-entry-save-keyboard-large.png`, Speichern vollständig oberhalb der Tastatur durch Scrollen erreichbar.

Die engen Light-Korrekturen verändern den bestehenden Dark-Aufbau bewusst nicht. Die Abnahme ist keine Aussage, dass jeder bisherige Dark-Dialog bei 320 dp und großer Schrift neu gestaltet oder umfassend korrigiert wurde.


### Nachprüfung: dunkle Ränder im hellen Design-Sheet

Die erste Light-Prüfung hat den Griffbereich und den unteren Abstand übersehen: Nur der Inhalt hatte eine helle Materialfüllung. `GlassSheet.show()` baute die äußere Glasfläche mit eingefrorenen Einstellungen. Das war sowohl beim hellen Öffnen als auch nach dem Designwechsel als dunkles Band sichtbar.

`ThemeModeBottomsheet` baut nun die gesamte native `GlassSheet` innerhalb derselben Dialogroute reaktiv. Die helle semantische Surface-Tönung mit Alpha 0.90 liegt auf der vollständigen Glasfläche; der Inhalt ist transparent. Standardqualität, Blur 4, Safe Area, Abstände, 350-ms-Slide-Animation und Schließen per Außen-Tap/Griff/Wischgeste bleiben erhalten. Dark erhält die bisherigen ungetönten Einstellungen.

Nachweis auf dem S22 Ultra: `theme-shell-light-fixed.png` und `theme-shell-switch-light-fixed.png` zeigen die durchgehend helle Fläche einschließlich Griff und Footer. `theme-shell-system-fixed.png` stimmt mit `theme-dark-final.png` sowohl im gesamten Sheet-Rechteck (0,1810)–(1440,3032) als auch hinter dem Sheet (0,385)–(1440,1700) pixelgenau überein. Der Regressionstest prüft jetzt die äußere Tönung, Wechsel ohne Routenersatz und Drag-/Barrier-Dismissal. Gesamtsuite: 122 bestanden; `flutter analyze --no-pub`: keine Befunde. Korrigierte APK gebaut und erfolgreich mit Datenerhalt installiert.
