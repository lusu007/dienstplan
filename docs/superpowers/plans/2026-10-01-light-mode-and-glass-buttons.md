# Light Mode und Glasbuttons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Die im Geräte-Audit gefundenen Light-Mode-Probleme beheben und Appbuttons auf der vorhandenen Glasbibliothek vereinheitlichen, während der Dark Mode außerhalb der Buttons erhalten bleibt.

**Architecture:** Bestehende gemeinsame Glasadapter und semantische Farb-Tokens erweitern. Kontrast- und Oberflächenkorrekturen werden nach Theme begrenzt; Buttonrollen und Interaktionszustände liegen zentral und werden anschließend in den Seiten verwendet. Kalenderdaten und Navigationslogik bleiben unverändert.

**Tech Stack:** Flutter/Dart, Riverpod, `liquid_glass_widgets: 1.7.2`, Flutter-Widgettests, Android-Geräteprüfung über ADB.

**Spec:** [Design und Umfang](../specs/2026-10-01-light-mode-and-glass-buttons-design.md)

**Status:** Umsetzung und Abnahme am 2026-10-02 abgeschlossen. Ergebnisse und Prüfgrenzen siehe [Abnahmebericht](../validation/2026-10-02-light-mode-and-glass-buttons.md) und [Ausführungsprotokoll](../validation/2026-10-02-light-mode-and-glass-buttons-progress.md).

## Global Constraints

- **Dark Mode bleibt außerhalb der neuen Buttons unverändert:** keine Änderung seiner Farben, Oberflächen, Auswahlmarkierungen, Layouts oder Kalendernavigation. Verbesserungen an diesen Bereichen greifen ausschließlich im Light Mode.
- `liquid_glass_widgets: 1.7.2` bleibt installiert; kein Bibliothekswechsel oder Upgrade für diese Arbeit.
- Beide Kalenderansichten, Tagesdetails, andere Dienstgruppen und die untere Eingabeleiste bleiben erhalten.
- Monat und Heute behalten die bereits abgestimmte Position und dieselbe adaptive sichtbare Höhe.
- Standard-Glasqualität, bestehende Sheet-Animationen und die verzögerte Aktivierung teurer Effekte bleiben erhalten.
- Kleine aktive Texte: Prüfziel mindestens 4,5:1 auf dem tatsächlich sichtbaren Hintergrund. Icon-Touchflächen: mindestens 48 × 48 logische Pixel.
- Bestehende uncommittete Änderungen an `glass_picker_controls.dart`, `calendar_header.dart`, `glass_action_bar.dart` und `docs/style_guide/patterns.md` erhalten und darauf aufbauen.
- Keine Datenlöschung, kein Feedbackversand und keine dauerhafte Änderung der Geräte-/App-Einstellungen bei der Abnahme. Keine Commits oder Veröffentlichung ohne gesonderten Auftrag.

## Review Focus

1. Helle Akzentfarben und neutrale Badges außerhalb des Monats: Light-Mode-Schrift bleibt lesbar; Dark-Mode-Farben bleiben identisch. Nachweis: Task 1.
2. Theme-Wechsel bei geöffnetem Theme-Sheet: keine zweite Route, kein verlorener Inhalt, korrekte Oberfläche für das aktuelle Theme. Nachweis: Task 2.
3. Laden, deaktivierte Aktionen und wiederholtes Tippen: kein unerlaubter Callback, keine doppelte Abdunklung. Nachweis: Tasks 3–4.
4. Größere Schrift, schmale Breite und Tastatur: adaptive Buttons und erreichbare Aktionen ohne Überlauf. Nachweis: Tasks 3 und 6.
5. Ganztägig ↔ Uhrzeit und Abbrechen einer destruktiven Bestätigung: keine Terminänderung oder Datenlöschung allein durch Darstellung bzw. Abbrechen. Nachweis: Task 5.

---

## Dateigrenzen und Zuständigkeiten

| Bereich | Dateien | Verantwortung |
| --- | --- | --- |
| Kontrast | `lib/core/constants/calendar_day_surface_tokens.dart`; `lib/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart`; `lib/presentation/widgets/common/glass_picker_controls.dart`; `lib/presentation/widgets/common/glass_filter_chip.dart`; `lib/presentation/widgets/screens/settings/components/bottomsheets/color_selection_card.dart`; `lib/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart` | Tatsächliche Badge-Farbe, Light-Mode-Text und Auswahlmarker |
| Modale Oberfläche | `lib/core/constants/glass_tokens.dart`; `lib/presentation/widgets/common/glass_dialog_surface.dart`; `lib/presentation/widgets/common/glass_bottom_sheet.dart`; `lib/presentation/widgets/screens/settings/components/bottomsheets/theme_mode_bottomsheet.dart` | Gemeinsame Light-Mode-Inhaltsdeckkraft, Theme-Sheet-Ausnahme |
| Buttonbasis | `lib/presentation/widgets/common/glass_button_surface.dart`; neu `lib/presentation/widgets/common/app_glass_button.dart`; neu `lib/presentation/widgets/common/app_glass_icon_button.dart` | Bibliotheksstil, Rollen, Zustände, Icon-Touchflächen |
| Buttonaufrufer | Task 4 | Rollenzuordnung ohne Geschäftslogikänderung |
| Kleine UX-Korrekturen | Task 5 | Einstellungsindikatoren, Hilfstext, ganztägige Darstellung, Debug-Abstand, Abbrechen |
| Dokumentation und Abnahme | `docs/style_guide/components.md`; `docs/style_guide/patterns.md`; neuer Abnahmebericht in `docs/superpowers/validation/` | Theme-Grenze, Buttonverwendung, Gerätebelege |

## Reihenfolge

Tasks 1 und 2 beheben die größten Lesbarkeitsprobleme. Task 3 stellt die gemeinsame Buttonbasis bereit; Task 4 nutzt sie in den Seiten. Task 5 erledigt die kleineren UX-Funde. Task 6 prüft das Gesamtbild und schützt den bestehenden Dark Mode. Pro Task entsteht ein separat überprüfbarer Stand; die tatsächliche Glasdarstellung wird jeweils zusätzlich am Gerät angesehen.

### Task 1: Light-Mode-Kontraste und Auswahlzustände

**Files:** Kontrast-Dateien aus der Tabelle.
**Test:** Neu `test/core/calendar_day_badge_contrast_test.dart`; erweitern `test/presentation/glass_picker_tile_test.dart` und `test/presentation/glass_filter_chip_test.dart`.

**Interfaces:**
- Erweitern: `Color calendarDayBadgeForegroundColor(Color badgeBackground, {Brightness brightness = Brightness.light, Color? backdropColor})`.
- Aufrufer übergeben die effektive Badge-Füllung, `Theme.of(context).brightness` und bei Transparenz den effektiven Hintergrund. Im Dark Mode bleibt der bisherige Algorithmus erhalten.
- Öffentliche Konstruktoren von `GlassPickerTile`, `GlassFilterChip` und `ColorSelectionCard` bleiben kompatibel.

- [x] Regressionsfälle hinzufügen: Türkis `#00B89F`, Orange `#FF7A33`, Grün `#5FBF3A`, Gelb `#FFC933`, Grau `#B0BEC5`, Schwarz, Weiß und transparente neutrale Außenmonat-Füllungen. Erwartung im Light Mode: kontrastreichere helle/dunkle Schrift nach Alpha-Komposition; mindestens 4,5:1 auf den geprüften Füllungen. Dark-Mode-Ergebnisse vor der Änderung erfassen und identisch erwarten.
- [x] Neue Fälle vor dem Fix ausführen: `flutter test test/core/calendar_day_badge_contrast_test.dart test/presentation/glass_picker_tile_test.dart test/presentation/glass_filter_chip_test.dart`. Erwartung: die bisherigen hellen Badge-/Picker-Fälle zeigen den Fehler.
- [x] Im Light Mode `_getBadgeDecoration` und `_getBadgeTextStyle` auf dieselbe effektive Badge-Farbe beziehen. Neutrale Außenmonat-Badges dürfen dort ihre Schriftfarbe nicht mehr aus dem ursprünglichen Partnerakzent ableiten. Im Dark Mode auch den bisherigen Aufruf mit ursprünglichem Akzent erhalten: Ein unveränderter Algorithmus mit verändertem Eingabewert wäre bereits eine unerlaubte Farbänderung.
- [x] Nur im Light Mode die Picker-/Farb-/Theme-Auswahl mit lesbarer Beschriftung und zusätzlichem sichtbarem Marker darstellen; bestehende Dark-Mode-Zweige und Geometrie erhalten. An tatsächlicher Komposition prüfen, nicht nur an `ColorScheme.primary`.
- [x] Zieltests erneut ausführen, anschließend auf dem Gerät große Monatsansicht, Außenmonat-Tage, Monats-/Jahreswahl, Farbwahl und Theme-Auswahl vergleichen. Ergebnis: lesbare Kürzel und eindeutige Auswahl ohne Dark-Mode-Abweichungen.

### Task 2: Light-Mode-Dialogflächen stabilisieren

**Files:** Modale Oberflächen aus der Tabelle; falls nötig ein interner Parameter in `lib/presentation/widgets/common/app_glass_surface.dart` statt globaler Rendereränderung.
**Test:** `test/presentation/glass_bottom_sheet_performance_test.dart`; `test/presentation/liquid_glass_migration_test.dart`; neu `test/presentation/theme_mode_bottomsheet_test.dart`.

**Interfaces:** Öffentliche APIs von `GlassDialogSurface` und `GlassBottomSheet` sowie `ThemeModeBottomsheet.show(BuildContext context, WidgetRef ref)` bleiben erhalten. Die Theme-Sheet-Oberfläche reagiert innerhalb derselben Route auf das aktuelle Theme.

- [x] Dark-Mode-Ausgangswerte für Dialog-Tint, Blur, Materialaufbau und Theme-Sheet erfassen. Bestehende Tests für eine gemeinsame Glasoberfläche, nicht refraktive Kinder und erhaltenes Material während der Öffnung beibehalten.
- [x] Einen Regressionstest für Theme-Wechsel im geöffneten Sheet ergänzen: Auswahl bleibt bedienbar, dieselbe Modalroute bleibt offen, die Oberfläche folgt Light/Dark/System. Vor Umsetzung ausführen und Ausgangsverhalten dokumentieren.
- [x] Ausschließlich Light-Mode-Inhalte der gemeinsamen Modaloberfläche mit einer stärker deckenden semantischen Surface-Farbe hinterlegen. Die Deckkraft am Gerät so abstimmen, dass dahinterliegende Zeichen nicht mehr als lesbarer Zweitinhalt durchscheinen; den geprüften Wert als Light-Token dokumentieren. Blur `4` für Bottom Sheets, Standardqualität, Außenkontur und Übergang beibehalten.
- [x] Die Light-Mode-Korrektur auch auf das bisher eigene `liquid.GlassSheet` der Theme-Auswahl anwenden. Dessen Dark-Mode-Aufbau und Einstellungen erhalten; beim Wechsel keine Route austauschen und keine zweite refraktive Ebene hinzufügen.
- [x] `flutter test test/presentation/glass_bottom_sheet_performance_test.dart test/presentation/liquid_glass_migration_test.dart test/presentation/theme_mode_bottomsheet_test.dart` ausführen. Am Gerät erste und wiederholte Öffnung von Dienstplan-, Gruppen-, Farb-, Bundesland-, Export-, Datum-/Jahr-, Tages- und Termineingabe-Sheets prüfen. Shader-Lesbarkeit und Animation nicht aus Widgettests ableiten.

### Task 3: Bibliotheksbuttons zentral anpassen

**Files:** Buttonbasis aus der Tabelle; `lib/core/constants/glass_tokens.dart`; `docs/style_guide/components.md`.
**Test:** Erweitern `test/presentation/liquid_glass_migration_test.dart`; neu `test/presentation/app_glass_button_test.dart`.

**Interfaces:**
- `GlassButtonSurface` erhält optional `liquid.GlassButtonStyle style = liquid.GlassButtonStyle.filled`; bestehende Aufrufer bleiben kompatibel.
- Neu `enum AppGlassButtonRole { primary, secondary, quiet, destructive }`.
- Neu `AppGlassButton`: `required Widget child`, `required VoidCallback? onPressed`, `AppGlassButtonRole role = AppGlassButtonRole.secondary`, `bool isLoading = false`, `bool enabled = true`, `bool fullWidth = false`, `double? height`. Nutzt `GlassButtonSurface`; Rollen bestimmen Bibliotheksstil und semantische Farben zentral.
- Neu `AppGlassIconButton`: `required IconData icon`, `required VoidCallback? onPressed`, `required String tooltip`, `double size = 48`, `double iconSize = 22`, `bool isSelected = false`, `Color? foregroundColor`. Nutzt `liquid.GlassIconButton` mit App-Theme und stabiler Kontur; für benötigte abweichende Form einen optionalen Bibliotheks-Shape-Parameter verwenden.

- [x] Verhaltensprüfungen schreiben: Callback genau einmal bei Aktivierung, nie bei deaktiviert/laden; Ladeindikator bleibt sichtbar; Tooltip/Semantik vorhanden; Touchziel mindestens 48 × 48; Text bei Faktor 1,3 und langer Beschriftung ohne Abschneiden. Vor Implementierung ausführen.
- [x] Stilparameter in der bestehenden Basis ergänzen. Den passiven Pfad bei deaktiviert/laden erhalten, damit die Bibliotheks-Opacity von 0,5 nicht zusätzlich auf Spinner und bestehende App-Opacity angewandt wird.
- [x] Textbutton-Adapter implementieren: primary → prominent, secondary → filled, quiet → transparent, destructive → semantische Fehlerfarbe. Light-Mode-Text gegen reale Füllung prüfen. Dark-Mode-Farben am bestehenden Look ausrichten; keine Änderung der globalen Theme-/Surface-Tokens für diesen Zweck.
- [x] Icon-Adapter implementieren. Die bestehende appseitige Kontur erhalten; erzwungene globale Stretch-/Glow-Änderungen vermeiden. Falls eine kompakte sichtbare Fläche erhalten bleiben soll, eine mindestens 48-dp-Touchfläche ohne Überlagerung angrenzender Ziele bereitstellen.
- [x] `flutter test test/presentation/app_glass_button_test.dart test/presentation/liquid_glass_migration_test.dart` ausführen. Beide Themes und die Standard-Glasqualität prüfen; Rollen und Lade-/Disabled-Verwendung im Style Guide dokumentieren.

### Task 4: Buttons auf allen Seiten vereinheitlichen

**Modify:**
- `lib/presentation/widgets/common/glass_picker_controls.dart`, `glass_filter_chip.dart`, `error_display.dart`, `whats_new_host.dart`.
- `lib/presentation/widgets/screens/calendar/components/calendar_header.dart`, `glass_action_bar.dart`, `schedules_bottom_sheet.dart`, `personal_calendar_entry_sheet.dart`.
- `lib/presentation/widgets/screens/setup/action_button.dart`, `setup_back_button.dart`, `components/police_authority_filter_chips.dart`, `steps/config_selection_step_component.dart`, `steps/partner_config_step_component.dart`.
- `lib/presentation/widgets/screens/settings/components/dialogs/app_dialog.dart`, `components/bottomsheets/reset_bottomsheet.dart`, `sections/settings_schedule_block.dart`.
- `lib/presentation/screens/contact_feedback_screen.dart`, `debug_screen.dart`.

**Test:** `test/presentation/contact_feedback_screen_test.dart`, `whats_new_dialog_test.dart`, `calendar_split_layout_test.dart`, `calendar_year_picker_layout_test.dart`, `debug_screen_test.dart` und Buttontests aus Task 3.
**Interfaces:** Nutzt die Adapter aus Task 3; bestehende Callbacks, Validierung, Route-Ergebnisse und Speicher-/Sendeabläufe bleiben erhalten. Filterchips bleiben semantisch Auswahlkomponenten, keine Umwandlung zu gewöhnlichen CTA-Buttons.

- [x] Aktuelle Buttonaufrufer mit `rg -n 'ElevatedButton|OutlinedButton|TextButton|IconButton|GlassButtonSurface' lib/presentation` abgleichen. Rollenliste pro Aktion erstellen; etwaige Standardcontrols in nativen Pickern ausdrücklich ausnehmen.
- [x] Kalender-/Picker-/Toolbar-Icons über den gemeinsamen Icon-Adapter führen. Heute übernimmt weiterhin `glassPickerTriggerHeight(context)`; Monatswahl und Heute behalten ihre bisherige Platzierung. Untere Leiste bleibt Eingabe plus Plus.
- [x] Primäre Aktionen und verbleibende Standardbuttons auf Rollenadapter umstellen: Setup-Weiter, Speichern, Feedback-Absenden, Anhang, Retry, Dialogaktionen und Debugaktionen. Vorhandene bereits glasbasierte Buttons mit derselben Rollenpalette vereinheitlichen, ohne lokale Farbrezepte zu ergänzen.
- [x] Bestehende Verhaltensprüfungen ausführen: `flutter test test/presentation/contact_feedback_screen_test.dart test/presentation/whats_new_dialog_test.dart test/presentation/calendar_split_layout_test.dart test/presentation/calendar_year_picker_layout_test.dart test/presentation/debug_screen_test.dart test/presentation/app_glass_button_test.dart test/presentation/liquid_glass_migration_test.dart`.
- [x] Im Light und Dark Mode normale, gedrückte, deaktivierte und ladende Zustände ansehen. Kein Feedback senden und kein Reset auslösen. Bei Tastatur und Faktor 1,3 bleiben Speichern/Absenden erreichbar; Änderungen außerhalb der Buttons sind im Dark Mode unzulässig.

### Task 5: Kleinere Light-Mode-UX-Funde beheben

**Modify:** `lib/presentation/widgets/common/cards/navigation_card.dart`; `lib/presentation/widgets/screens/settings/sections/school_holidays_section.dart`; `lib/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart`; `lib/presentation/widgets/screens/settings/components/bottomsheets/reset_bottomsheet.dart`; `lib/presentation/screens/debug_screen.dart`; `lib/core/l10n/app_de.arb` für neue erforderliche Labels.
**Test:** `test/presentation/settings_navigation_test.dart`, `debug_screen_test.dart`; neu `test/presentation/personal_calendar_entry_sheet_test.dart`, `reset_bottomsheet_test.dart` nur für die relevanten Interaktionen.

**Interfaces:** `NavigationCard` bleibt kompatibel; ein Default-Öffnungsindikator ergänzt ausschließlich aktive Light-Mode-Zeilen ohne bestehendes Trailing. Die bestehenden Termin-/Reset-APIs und Datenmodelle bleiben erhalten.

- [x] Im Light Mode bei bedienbaren Einstellungszeilen ohne Trailing einen dezenten Öffnungsindikator zeigen. Farbvorschauen, Theme-Icon, Schalter und deaktivierte Zeilen beibehalten; Dark-Mode-Zeilen bleiben geometrisch identisch zum Ausgangsstand.
- [x] Nur im Light Mode bei aktivierten Ferien und fehlendem Bundesland den Grund „Zuerst Bundesland auswählen“ anzeigen. Keine Änderung von Enable-Bedingungen oder Ferien-Ladelogik. Neue Labels über ARB und `flutter gen-l10n` erzeugen; generierte Dateien nicht separat bearbeiten.
- [x] Test für Ganztägig → Uhrzeit → Ganztägig schreiben: im Light Mode keine nutzlos ausgegraute Uhrzeit im Ganztägig-Zustand; beim Wechsel zurück wird die bisherige Zeit nicht durch die Darstellungsänderung gelöscht. Im Dark Mode bleiben Zeitanzeige und Layout bestehen.
- [x] Nur die Light-Mode-Zeitanzeige entsprechend ausblenden; keine Änderungen an Normalisierung/Speichern oder dem Ganztägig-Datenmodell.
- [x] Zurücksetzen-Sheet mit zurückhaltendem „Abbrechen“-Button ergänzen. Test: Abbrechen schließt das Sheet und ruft keinen destruktiven Dienst auf. Dies ist eine erlaubte Buttonänderung in beiden Themes; die bestehende Reset-Aktion bleibt unverändert.
- [x] Debug-Label/Wert nur im Light Mode mit festem Mindestabstand und responsivem Umbruch darstellen. Auf schmaler Breite und bei Faktor 1,3 prüfen; keine Daten-/Debugfunktionen ändern.
- [x] `flutter test test/presentation/settings_navigation_test.dart test/presentation/debug_screen_test.dart test/presentation/personal_calendar_entry_sheet_test.dart test/presentation/reset_bottomsheet_test.dart` ausführen. Die kleinen visuellen Korrekturen zusätzlich am Gerät prüfen; keine Tests schreiben, die nur Padding-Konstanten kopieren.

### Task 6: Gesamtprüfung und Dark-Mode-Schutz

**Files:** `docs/style_guide/patterns.md`; neu `docs/superpowers/validation/2026-10-02-light-mode-and-glass-buttons.md`.
**Interfaces:** Keine neuen Produkt-APIs. Bericht enthält überprüfte Revision/Arbeitsstand, Geräte-/Theme-/Schrifteinstellungen, echte Ergebnisse und verbleibende Einschränkungen.

- [x] **Diesen Referenzschritt vor Task 1 ausführen:** Referenzscreens im Dark Mode aufnehmen: beide Kalenderansichten, Einstellungen, Theme-/Farb-/Termin-Sheet. Für den späteren Vergleich dieselben Daten, ausgewählten Tage, Scrollpositionen und Schriftgrößen verwenden. Keine Benachrichtigungen oder persönlichen Angaben in geteilte Belege übernehmen.
- [x] Nach der Integration `flutter analyze` und `flutter test` ausführen. Erwartung: keine Analysefehler, alle vorhandenen und hinzugefügten Tests erfolgreich. Nur bei neuen Fehlern oder Änderungen erneut breiter testen.
- [x] `flutter build apk --debug --flavor dev` ausführen. Auf dem S22 Ultra mit `/home/lukas/Android/Sdk/platform-tools/adb -s R3CT609DD1V install -r build/app/outputs/flutter-apk/app-dev-debug.apk` installieren; Appdaten erhalten.
- [x] Light-Mode-Matrix prüfen: beide Kalenderansichten, Tagesdetails/Filter, Monat/Jahr, Termin ganztägig/mit Uhrzeit, alle fünf Einstellungskategorien und ihre Picker, Export, Reset-Bestätigung mit Abbrechen, About, Disclaimer, Datenschutz, Lizenzen, Feedback mit Tastatur/Anhang, Was ist neu, alle Setup-Schritte und Debug. Setup nicht abschließen, wenn dadurch die vorhandene Konfiguration ersetzt würde.
- [x] Faktor 1,0 und 1,3 sowie schmale Layouts prüfen. Große Schrift darf Monate, Buttons und Speichern/Absenden nicht abschneiden. Lange Dienstplannamen, aktive/deaktivierte Ferienaktionen und den Theme-Wechsel bei geöffnetem Sheet einbeziehen.
- [x] Dark-Mode-Screens gegen die Referenzen vergleichen. Außerhalb neuer Buttons müssen Farben, Glasflächen, Auswahlzustände, Layout und Kalenderverhalten erhalten sein; Abweichungen vor Abnahme beheben.
- [x] Style Guide und Abnahmebericht aktualisieren: gemessene Kontrastfälle, festgelegter Light-Dialog-Token, überprüfte Screens, bestätigte Zustände und etwaige Restprobleme. Geräteeinstellungen und Appkonfiguration anschließend auf den Ausgangsstand zurückstellen.

## Zurückgestellte Folgeentscheidungen

Die Monatsnavigation und die Menüreferenzen „Kontakt“/„Feedback“ aus Abschnitt 5 der Spec sind bewusst keine Umsetzungstasks dieses Plans. Sie benötigen eine eigene Entscheidung über Änderungen, die beide Themes betreffen. Dafür weder den Dark Mode unbemerkt ändern noch nach Theme unterschiedliche Kalenderdatenlogik oder Datenschutztexte einführen.

## Ausführungsvorschlag

Die Umsetzung ist nach Nutzerwunsch für den 2026-10-02 vorgesehen. Empfehlung: in dieser Sitzung taskweise umsetzen, da die meisten Änderungen an denselben Glasadaptern hängen und von einer konsistenten Geräteprüfung profitieren. Beim Wiedereinstieg zuerst aktuellen Arbeitsstand und Geräteverbindung prüfen, dann die Dark-Mode-Referenzen aufnehmen und Tasks 1–6 abarbeiten. Keine automatische Delegation oder Veröffentlichung.

Plan-Selbstprüfung: Alle aktiven Spec-Anforderungen sind Tasks zugeordnet; die fünf Review-Fälle haben gezielte Nachweise. Schnittstellen sind zwischen Tasks konsistent. Der Schutz des Dark Mode ist eine Abnahmebedingung und nicht nur ein Hinweis.
