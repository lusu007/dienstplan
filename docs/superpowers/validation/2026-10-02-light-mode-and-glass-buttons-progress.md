# Ausführungsprotokoll — Plan: docs/superpowers/plans/2026-10-01-light-mode-and-glass-buttons.md

- Ausgangsstand: Branch `codex/calendar-entry-editor`, vier vorher abgestimmte Kalender-/Styleguide-Änderungen plus Plan/Spec erhalten. Ausgangsdiff in `/tmp/dienstplan-ui-2026-10-02/before.patch` gesichert.
- Arbeitsentscheidung: Den bestehenden Feature-Branch fortsetzen, damit die bereits akzeptierten uncommitteten Änderungen in derselben App bleiben; keine Commits oder zusätzliche Worktrees. Vorgaben der Sitzung haben Vorrang vor automatischen Skill-Commit-/Worktree-Schritten.
- Umgebung: Sandbox-Shellstart liefert ENOENT; Shellbefehle außerhalb der defekten Sandbox funktionieren. USB-Gerät `2-6` nach erneutem Attach in WSL erreichbar; ADB `R3CT609DD1V`.
- Baseline: `flutter test` — 92 Tests bestanden.
- Schnittstellenprüfung: Task 3 erzeugt Buttonadapter für Task 4; Task 5 nutzt sie für Abbrechen. Task 1 und 2 betreffen gemeinsame Light-Mode-Oberflächen; Dark-Mode-Zweige bleiben erhalten. Keine widersprüchlichen konsumierten Typen.
- Präzisierung: Theme-Auswahlmarker liegt tatsächlich in `common/cards/selection_card.dart`, nicht in `generic_bottomsheet.dart`; dort wird die Light-Mode-Korrektur implementiert.

- Tasks 1–5 implementiert, Geräteabnahme noch offen. Light-Kontrastregressionen zuerst beobachtet (helle Badges, Picker und Filterchip), danach gezielt 14 Tests grün. Dark-Außenmonat-Foreground als exakter Bestand geprüft.
- Task 2: Light-Flächen mit 0,90 Surface-Inhaltsdeckkraft; Dark-Zweig bleibt identisch. Theme-Wechsel behält dieselbe Route; Performance-/Migrationstests bestehen.
- Tasks 3–4: Native GlassButton-/GlassIconButton-Adapter mit Rollen, vollständigen Touchflächen und nicht abdunkelnden Ladezuständen. Bestehende Callbacks und Formularvalidierung erhalten.
- Task 5: Neue Regressionsfälle für Öffnungsindikatoren, deaktivierte Ferienaktionen, Ganztägig-Umschaltung und Abbrechen ohne Lesen destruktiver Dienste zuerst fehlgeschlagen, danach bestanden.
- Prüfentscheidung: Die funktionalen Termineingabe-Tests verwenden 600 dp, weil der Testfont Ahem in der unveränderten nativen Chip-Implementierung künstlich breite Glyphen erzeugt; Smartphonebreite und 1,3-fache Schrift werden am Gerät beurteilt. Kein Dark-Mode-Chip-Layout allein wegen dieses Testfont-Artefakts verändern.
- Gesamtstand: `flutter test --no-pub` — 115 Tests bestanden. `flutter analyze --no-pub` — keine Findings. Dev-Debug-APK erfolgreich gebaut; bestehende Plugin-Kotlin-Migrationswarnung von file_saver/sentry_flutter dokumentiert, kein Abhängigkeitsupgrade im UI-Auftrag.

- Native Dark-Monatsansicht: Kalenderbereich, Monatsselektor und Hintergrund pixelidentisch zum Ausgangsstand (maximale Kanalabweichung 0). Kompakte Liste hatte durch 48-dp-Targets zunächst 12 dp Versatz; Regressionstest reproduziert bei Faktor 1,0/1,3 und adaptive Dark-Abstände korrigiert. Beide Tests grün.
- Nach der Korrektur: 117 Tests bestanden, Analyse ohne Findings, Dev-Debug-APK erneut erfolgreich gebaut. Abschließende Geräteprüfung und unabhängiges Read-only-Review laufen.

- Unabhängiges Read-only-Review: keine kritischen Findings; ein wichtiges Finding zur Light-Jahreswahl bei 320 dp/Faktor 1,3. Neues Testbeispiel reproduziert den horizontalen Überlauf. Marker bei Platzmangel oberhalb der unverkleinerten Jahreszahl angeordnet, Dark unverändert. Zieltest danach grün; vollständige Suite 118 Tests bestanden. Zwei Const-Lint-Hinweise im neuen Test anschließend korrigiert; erneute Analyse ohne Findings.
- Native Light-Auswahlseiten (eigener/Partnerplan, Gruppen, Farben, Export, Bundesland) und Ferien-Voraussetzung geöffnet. Ferienanzeige nur temporär eingeschaltet und danach wieder deaktiviert; kein Bundesland gesetzt. Kein Export, Reset oder Versand ausgelöst.

- Geräte-Kontrastmessung des Light-Zurücksetzen-Buttons: Schrift (186,26,26), Füllung (225,182,187), Verhältnis 3,572:1. Neuer Regressionstest zunächst rot; Light-Foreground auf `onErrorContainer` korrigiert, Dark-Foreground bleibt `error`. Danach 119 Tests bestanden, Analyse ohne Findings, APK erfolgreich gebaut.

- Feedback mit Faktor 1,3 und Tastatur: beide Formularaktionen durch Scrollen erreichbar. Screenshot lokal angehängt, kein Versand. Anhang-Status wurde neben dem breiteren Entfernen-Button mitten im Wort umbrochen; Light-Anordnung bei schmaler Breite/großer Schrift auf zwei Zeilen umgestellt. Regression reproduziert, danach Entfernen ohne Versand bestanden. Dark-Row unverändert.
- Aktueller Code: 120 Tests bestanden, Analyse ohne Findings. ARM64-Dev-Debug-APK erfolgreich gebaut (96 MB statt universeller 197 MB); letzte Installation ohne Streaming läuft.
- Setup-Schritte 1–5 mit Faktor 1,3 nativ geöffnet. Nur flüchtige Auswahl geändert; Schritt 5 nicht abgeschlossen, kein vorhandener Dienstplan ersetzt.

- Enge Geräteprüfung: 320 dp / Faktor 1,3. Ausgewählte Jahrestile sind lesbar; zusätzlich bestehenden Überlauf im Jahresbereich-Trigger und im langen Neuigkeiten-Dialog gefunden. Jeweils rot reproduziert. Light-Pill passt den vollständigen numerischen Bereich an den verfügbaren Platz an, ohne Dark-Geometrieänderung; Light-Dialog gibt Scrollinhalt einen begrenzten flexiblen Bereich, Aktion bleibt sichtbar. Zieltests grün; abschließender Gesamtcheck läuft.

- Final nativ: Light-Jahresbereich und Neuigkeiten bei 320 dp/Faktor 1,3 ohne Überlauf. Resettext 5,172:1 auf gemessener Füllung. Beide Light-Kalender, Tagesdetails, Datum und Uhrzeitdarstellung; Speichern bei Faktor 1,3 durch Scrollen über Tastatur erreichbar.
- Dark-Referenzen: großer Kalender, Monat, kompaktes Raster/Datumsheader/Dienstliste, Theme-Sheet, Darstellungskarten und Farbwahl mit Kanalabweichung 0. Andere Gruppen ein/aus getestet, Originalzustand wiederhergestellt.
- App-Theme System, Nightmode yes, Schrift 1.0, Dichte 600 ohne Override, kompakt/2. Oktober und andere Gruppen aus. Keine gespeicherten Termine, Datenlöschung, Versand oder abgeschlossener Setupwechsel. Finale APK inklusive Debugausrichtung installiert; temporäre Installationsdatei entfernt.
- Abschlussbericht: `2026-10-02-light-mode-and-glass-buttons.md`. Keine Commits oder Veröffentlichung.
