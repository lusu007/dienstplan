# UI-/UX-Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking. Hauptpaket umgesetzt; Abnahme und Grenzen stehen in `../validation/2026-10-07-ui-ux-audit-validation.md`.

**Goal:** Alle bestätigten UI-/UX-Befunde in getrennten, prüfbaren Änderungen beheben; Kalenderpunkt 7 nachrangig behandeln.

**Architecture:** Bestehende Riverpod-Notifiers, lokale SQLite-Daten und Glass-Komponenten weiterverwenden. Zustandsdarstellung an den echten Ladezustand koppeln, Formularlebenszyklen ausdrücklich steuern und Layouts an verfügbaren Platz anpassen. Keine allgemeine UI-Neuentwicklung.

**Tech Stack:** Flutter, Dart, Riverpod, Freezed, sqflite, bestehende Flutter-Widget-/Domain-Tests und Android-Geräteprüfung.

**Spec:** `docs/superpowers/specs/2026-10-07-ui-ux-audit-design.md`

## Global Constraints

- Flutter >=3.47.0 und Dart >=3.13.0; keine Abhängigkeitsupdates für diese Verbesserungen.
- Bestehende Glass-Komponenten und `docs/style_guide/` verwenden.
- In der Oberfläche konsequent „Dienst“, „Neuer Dienst“ und „Dienst bearbeiten“ verwenden; gespeicherte alte Einträge nicht löschen oder umklassifizieren.
- Helles/dunkles/System-Theme, große Schrift und Android-Zurück unterstützen. Schriftvergrößerung nicht ausschalten, um Überläufe zu verdecken.
- Vorhandene Provider-Lifecycle-Korrektur erhalten; Wiederholungen dürfen keine unbegrenzten Lade-/Invalidierungsschleifen verursachen.
- Bestehende Daten und Nutzereinstellungen erhalten. Kein Reset und kein Versand von Feedback bei der Geräteprüfung ohne ausdrücklichen Auftrag.
- Commits und PR-Titel im Conventional-Commit-Format, ohne Codex-Erwähnung.

## Review Focus

1. Fehler beim Planwechsel: keine alten Dienste unter dem neuen Plannamen; Wiederholen lädt die fehlgeschlagene Quelle tatsächlich neu (Aufgabe 1).
2. Nachtdienst am Monats-/Jahreswechsel: gespeicherter Endtag bleibt nach erneutem Öffnen richtig; lokale Kalendertage nicht mit 24 Stunden UTC verwechseln (Aufgabe 3).
3. Zurück/Außenklick/Wischen mit Tastatur oder offener Screenshot-Auswahl: kein stiller Entwurfsverlust, keine zurückbleibenden Overlays (Aufgaben 4 und 6).
4. Doppeltippen und asynchroner Fehler: genau ein Repository-Aufruf, genau eine Navigation; Entwurf bleibt bei Fehler erhalten (Aufgaben 4 und 7).
5. 320 Pixel Breite oder 740×360 mit Textskalierung 2,0: letzte Aktion bleibt erreichbar und beschriftet, auch nach Themewechsel (Aufgaben 2 und 5).

## Reihenfolge und Lieferpakete

| Reihenfolge | Aufgabe | Priorität | Abhängigkeit |
| --- | --- | --- | --- |
| 1 | Lade-/Fehlerzustände | Hoch | Bestehenden Lifecycle-Fix als Basis erhalten |
| 2 | Onboarding und Kalenderkopf | Hoch | Unabhängig |
| 3 | Datums-/Zeitauswahl und Nachtdienste | Hoch | Freie Enddatum-Auswahl gemäß Empfehlung |
| 4 | Dienstformular: Titel, Entwurfsschutz, Speichern | Hoch | 3 für finale Zeitfelder/Dirty-Vergleich |
| 5 | Feedback-Layout | Mittel | Unabhängig |
| 6 | Feedbackentwurf und Screenshot-Abbruch | Hoch/Mittel | 5 für finale Aufnahme-Aktionen |
| 7 | Zurücksetzen: laufende Aktion und Fehler | Hoch | Unabhängig |
| 8 | Bundesland-Hilfe und Datenschutztext | Mittel | 6 für endgültigen Screenshot-Ablauf |
| 9 | Kalenderpunkt 7 | Niedrig | Separates Folgepaket; nicht Abschlussblocker |
| 10 | Gesamtprüfung und Geräteabnahme | Pflicht | Jeweils fertiggestelltes Paket |

Ein reviewbarer Commit pro Aufgabe; Hauptpaket und Punkt 7 vorzugsweise getrennte PRs. Keine Veröffentlichung allein durch Erstellung dieses Plans.

## Vorgehen je Aufgabe

Tests prüfen sichtbares Verhalten oder externe Aufrufe, keine privaten Implementierungsdetails. Die angegebenen Regressionstests zuerst ergänzen und mit dem angegebenen Befehl rot nachweisen; nach Umsetzung denselben Befehl grün prüfen. Bei reinen Textkorrekturen keine Tests hinzufügen, die bloß die Formulierung kopieren. Ein Commit erfolgt erst nach grüner relevanter Prüfung und `git diff --check`.

### Aufgabe 1: Echte Lade-, Leer- und Fehlerzustände

**Ändern:**
- `lib/presentation/state/schedule/schedule_coordinator_notifier.dart`
- `lib/presentation/widgets/screens/calendar/calendar_view/day_schedules_list_panel.dart`
- `lib/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart`
- `lib/presentation/widgets/screens/calendar/components/schedules_bottom_sheet.dart`
- `lib/presentation/widgets/screens/settings/sections/settings_schedule_block.dart`
- `lib/core/l10n/app_de.arb`

**Neue gemeinsame Darstellung:** `lib/presentation/widgets/screens/calendar/components/schedule_load_status.dart` mit `ScheduleLoadStatus({required bool isLoading, required String? errorMessage, required bool hasVisibleSchedules, required VoidCallback onRetry})`. Sie zeigt Fortschritt bzw. Fehlermeldung mit Wiederholen; nur erfolgreicher Leerzustand geht an die bisherige leere Dienstliste.

**Schnittstelle:** `Future<void> retryFailedLoad()` am vorhandenen ScheduleCoordinatorNotifier. Die Methode erneuert die tatsächlich fehlgeschlagenen Abhängigkeiten und den benötigten aktuellen Datumsbereich. AsyncError und `ScheduleUiState.error` berücksichtigen; eigene/Partnerfehler auseinanderhalten. Plan-/Datumswechsel begrenzt laufende Ergebnisse auf den angefragten Kontext.

- [x] Regressionen in neuem `test/presentation/schedule_load_status_test.dart`: `loading_does_not_show_empty_day`, `async_error_shows_retry`, `state_error_preserves_matching_loaded_rows`, `retry_recovers_failed_source`, `plan_switch_does_not_show_previous_plan`, `partner_error_preserves_own_duties`. Assertions: kein „keine Dienste“ bei Fehler/Laden; Wiederholen vorhanden; Quelle erneut aufgerufen; anschließend erwarteter neuer Dienst sichtbar.
- [x] Rot nachweisen: `flutter test test/presentation/schedule_load_status_test.dart`.
- [x] Zustandsdarstellung und Wiederholungsweg implementieren; bestehende gemeinsame Fehlerkomponenten nur verwenden, wenn sie selbst nicht von erfolgreicher Sprach-/Datenladung abhängen. Automatisches Ensure nicht bei jedem Fehler-Render erneut auslösen.
- [x] Grün prüfen: obiger Befehl plus `flutter test test/presentation/state/schedule_coordinator_lifecycle_test.dart test/presentation/state/schedule_data_notifier_test.dart`.
- [x] Commit: `fix(calendar): distinguish loading errors from empty days`.

### Aufgabe 2: Layout bei großer Schrift und Querformat

**Ändern:** `lib/presentation/screens/setup_screen.dart`, `lib/presentation/widgets/screens/setup/components/step_header.dart`, `lib/presentation/widgets/screens/setup/components/setup_step_wrapper.dart`, alle fünf Dateien unter `lib/presentation/widgets/screens/setup/steps/`, `lib/presentation/widgets/screens/calendar/components/calendar_header.dart`.

**Schnittstellen:** Bestehende Widget-Konstruktoren behalten. Kalenderkopf erhält flexible Titelbreite und eine Mindesthöhe statt starrer Höhe. Setup-Inhalt einschließlich großer Überschriften kann scrollen; Vor/Zurück bleibt erreichbar. Keine unbounded Expanded-Kinder in ScrollViews und keine gekappte Schriftvergrößerung.

- [x] Neues `test/presentation/ui_ux_layout_matrix_test.dart`: Kalenderkopf und alle fünf Setup-Schritte bei Light/Dark, 320×640/740×360, Skalierung 1/1,5/2. Assertions: `tester.takeException() == null`; nach erforderlichem Scrollen letzte Auswahl und Weiter/Zurück sichtbar und bedienbar; Auswahl bleibt nach Größen-/Themewechsel erhalten. Temporäres Auditgerüst aus `/tmp/dienstplan-ui-ux-audit/layout_audit.dart` kann lokal als Vorlage dienen, ist keine notwendige Projektabhängigkeit.
- [x] Rot nachweisen: `flutter test test/presentation/ui_ux_layout_matrix_test.dart`.
- [x] Flexible/scrollbare Layouts implementieren; Touchflächen ≥48 logische Pixel; lange Namen und Partner-Schritte einbeziehen.
- [x] Grün prüfen: obiger Befehl plus `flutter test test/presentation/setup_completion_test.dart test/presentation/setup_filter_clear_button_test.dart test/presentation/calendar_day_header_layout_test.dart`.
- [x] Commit: `fix(ui): keep setup and calendar controls accessible with large text`.

### Aufgabe 3: Dienstbeginn und Dienstende verständlich erfassen

**Empfohlene Entscheidung:** Enddatum frei über mehrere Tage wählbar. Die UX zeigt Datum und Uhrzeit von Beginn/Ende, automatische Folgetag-Vorbelegung und explizite manuelle Auswahl. Normale Dienste brauchen keine zusätzlichen Pflichtschritte; ungültige Kombinationen erklären statt still korrigieren.

**Ändern:** `lib/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart`, `lib/domain/use_cases/save_personal_calendar_entry_use_case.dart`, `lib/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart`, `lib/core/l10n/app_de.arb`.

**Speichervertrag:** `DateTime? endDate` in `PersonalCalendarEntry` und `Schedule` ergänzen, `end_date_ymd` in SQLite schreiben und durch den Mapper weiterreichen. Neue zeitgebundene Dienste speichern stets das gewählte Enddatum; beim Erzeugen eines alten Modellobjekts ohne Enddatum bleibt das bisherige Datum der Fallback. Alte zeitgebundene Einträge ohne Enddatum behalten denselben Endtag; ganztägige Einträge bleiben unverändert. Explizite Enddaten dürfen nicht anhand der Uhrzeit überschrieben werden.

**Zusätzliche Dateien:** `lib/domain/entities/personal_calendar_entry.dart`, `lib/domain/entities/schedule.dart`, `lib/domain/services/personal_entry_schedule_mapper.dart`, `lib/data/daos/personal_calendar_entries_dao.dart`, `lib/data/services/database_service.dart`, `lib/core/constants/database_constants.dart` (Version 19→20 nur nach Abgleich des Ausführungsstandes). Vollständige Freezed-Regeneration. Migration ergänzt nullable Spalte sowohl bei Neuinstallation als auch Upgrade; kein Tabellen-Neuanlegen mit Datenverlust.

**Validierung:** Ende muss tatsächlich nach Beginn liegen; ungültige Zeiten erklären, statt Wheel-Werte still zurückzustellen. Lokale Kalendertage mit Datumskomponenten berechnen. Manuelle Endtagwahl bleibt bei nachträglicher Uhrzeitänderung erhalten. Bei Starttagänderung widersprüchliches Ende sichtbar markieren, nicht heimlich verschieben. Dienst in der Liste weiterhin unter seinem Starttag mit eindeutigem Ende anzeigen. Bestehender Export generiert offizielle Dienste; persönliche Dienste in den Export aufzunehmen wäre ein eigener Umfang und wird hier nicht beiläufig ergänzt.

- [x] Erweitern: `test/domain/save_personal_calendar_entry_use_case_test.dart`, `test/domain/personal_entry_schedule_mapper_test.dart`, `test/presentation/personal_calendar_entry_sheet_test.dart`. Fälle: 08–16 am selben Tag; 22–06 mit Folgetag; gleiche Zeit am selben Tag ungültig; manuelles Enddatum bleibt; Wechsel 31.12.→01.01. und 28.02.→29.02.2028; lokale Sommerzeitgrenze ohne verschobenen Kalendertag. Assertions: gespeicherte Werte, erneut geöffnete Felder und Listenanzeige stimmen überein; Fehlereingabe bleibt editierbar.
- [x] Zusätzlich: neues `test/data/personal_calendar_entries_migration_test.dart` mit alter Datenbank v19 und frischer Installation: alte IDs/Titel/Zeitwerte erhalten; neuer mehrtägiger Dienst über DAO schreiben/lesen; explizite gleiche Uhrzeiten an verschiedenen Tagen gültig.
- [x] Rot nachweisen: `flutter test test/domain/save_personal_calendar_entry_use_case_test.dart test/domain/personal_entry_schedule_mapper_test.dart test/presentation/personal_calendar_entry_sheet_test.dart` plus `flutter test test/data/personal_calendar_entries_migration_test.dart`.
- [x] Freie Enddatum-Auswahl und Migration implementieren, Hilfstexte lokalisieren; bestehendes 5-Minuten-Raster erhalten. `flutter gen-l10n`; `dart run build_runner build` vollständig, ohne Build-Filter.
- [x] Dieselben Tests grün prüfen; auf dem Handy Tagesdienst, Nachtdienst, manuelle Endtagwahl und erneutes Öffnen durchspielen.
- [x] Commit: `feat(duties): support overnight shifts with clear start and end dates`.

### Aufgabe 4: Dienstentwurf, Schnelleingabe und Speichern

**Ändern:** `lib/presentation/widgets/screens/calendar/components/glass_action_bar.dart`, `lib/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart`, Aufrufer der Sheet-Funktion in Tagespanel/BottomSheet/Dienstliste, `lib/core/l10n/app_de.arb`.

**Schnittstelle:** Neues `enum PersonalEntrySheetResult { saved, deleted, discarded }` in der Sheet-Datei. `Future<PersonalEntrySheetResult?> showPersonalCalendarEntrySheet({required BuildContext context, required WidgetRef ref, required DateTime day, Schedule? existingSchedule, String? initialTitle})`. Plus und Tastatur teilen den Einstieg; Titelcontroller erst bei `saved` leeren. Dirty-Vergleich berücksichtigt Titel, Notizen, Ganztägig, Start- und Enddatum/-zeit aus Aufgabe 3. Eine gemeinsame lokale Schließroutine steuert alle Dismiss-Wege, nicht nur PopScope.

- [x] Neues `test/presentation/glass_action_bar_entry_test.dart`: Plus/IME mit „Fortbildung“ öffnen denselben vorbefüllten Titel; Abbruch erhält Eingabe; Erfolg leert sie. Bestehendes `test/presentation/personal_calendar_entry_sheet_test.dart` erweitern: unverändert direkt schließen; verändert bei Back, Schließen, Außenklick, Wischen bestätigen; „Weiter bearbeiten“ erhält alle Werte; Doppeltipp während Completer offen → genau ein upsert; Fehler → kein Pop, Eingabe erhalten, erneut speicherbar.
- [x] Rot nachweisen: `flutter test test/presentation/glass_action_bar_entry_test.dart test/presentation/personal_calendar_entry_sheet_test.dart`.
- [x] Resultatvertrag, Dirty-Guard und lokale Busy-Anzeige implementieren. Während Speicherung Aktionen sperren, bei Fehler freigeben; Erfolg schließt genau einmal. Bestätigte Löschung liefert `deleted`; erfolgreicher Save umgeht Verwerfen-Abfrage.
- [x] Dieselben Tests und `flutter test test/presentation/personal_entry_feedback_test.dart` grün prüfen.
- [x] Commit: `fix(duties): preserve drafts and prevent repeated saves`.

### Aufgabe 5: Feedback-Anhang in beiden Themes responsiv

**Ändern:** `lib/presentation/screens/contact_feedback_screen.dart`.

**Schnittstelle:** Bestehende Feedback-/Screenshot-Daten unverändert. Anhangdarstellung wählt Row/Wrap/Column anhand Platz und Textgröße, ohne Light-only-Bedingung; Vorschau, Bezeichnung und Entfernen bleiben erreichbar.

- [x] `test/presentation/contact_feedback_screen_test.dart` um dieselbe 12-Kombinationen-Matrix je Anhanganzeige wie Aufgabe 2 erweitern. Assertions: keine Layoutausnahme; Entfernen auffindbar/bedienbar; Anhang danach entfernt; Themewechsel mit Anhang und geöffneter Tastatur verliert keinen Text.
- [x] Rot nachweisen: `flutter test test/presentation/contact_feedback_screen_test.dart`.
- [x] Responsive Anhangdarstellung mit bestehenden Buttons implementieren.
- [x] Denselben Test grün prüfen und Anhang Light/Dark auf dem Handy ansehen.
- [x] Commit: `fix(feedback): make screenshot attachments responsive in dark mode`.

### Aufgabe 6: Feedbackentwurf und Screenshot-Auswahl schützen

**Ändern:** `lib/presentation/screens/contact_feedback_screen.dart`, `lib/core/config/contact_feedback_copy.dart`.

**Schnittstellen:** Bestehendes `ContactFeedbackDraft` erhalten; `ContactFeedbackScreenshotCoordinator.start({required BuildContext context, required ContactFeedbackDraft draft, SentryAttachment? initialScreenshot})` um bisherigen Anhang erweitern. Abbruch räumt Overlay auf und öffnet Feedback mit ursprünglichem Entwurf/Anhang. Interner Transfer zur Aufnahme darf den Dirty-Guard gezielt umgehen; normaler Back nicht.

- [x] `test/presentation/contact_feedback_screen_test.dart` erweitern: Dirty-Back→Abfrage; sauberer Back direkt; Weiter bearbeiten erhält Text; Screenshot-Abbruch erhält Text/alten Anhang; Aufnahmefehler erhält alten Anhang und zeigt Erklärung; Erfolg ersetzt genau einmal; Mehrfachtipp führt zu einer Aufnahme/Navigation; Abbruch/System-Back und Route-Ende hinterlassen kein Overlay.
- [x] Rot nachweisen: `flutter test test/presentation/contact_feedback_screen_test.dart`.
- [x] Entwurfsschutz und erklärten Aufnahmemodus mit „Aufnehmen“/„Abbrechen“ implementieren; Overlay-Lebenszyklus und Busy-/Mounted-Prüfungen an einer Stelle steuern.
- [x] Denselben Test grün prüfen; Ablauf auf dem Handy bis Abbruch/Entwurfrückkehr, ohne Feedback zu senden.
- [x] Commit: `fix(feedback): preserve drafts and allow screenshot cancellation`.

### Aufgabe 7: Zurücksetzen als einmalige, nachvollziehbare Aktion

**Ändern:** `lib/presentation/widgets/screens/settings/components/bottomsheets/reset_bottomsheet.dart`.

**Schnittstelle:** Bestehender öffentlicher Sheet-Einstieg bleibt; Stateful/Consumer-Inhalt besitzt lokalen Busy-/Fehlerzustand. Benötigte Provider-Abhängigkeiten vor await erfassen. Erst nach erfolgreichem Abschluss sämtlicher Schritte zum Setup navigieren; teilweise fehlgeschlagener Reset darf keinen Erfolg vortäuschen. Keine vollständige Atomarität zwischen SQLite und Preferences behaupten.

- [x] `test/presentation/reset_bottomsheet_test.dart` erweitern: Doppeltipp bei offenem Completer → eine Löschung/ein Reset; Busy sichtbar und Schließen gesperrt; Repository- oder Einstellungsfehler → Erklärung, keine Setup-Navigation, retry möglich; Erfolg → einmal Setup. Alles mit Fakes, ohne persönliche Gerätedaten zu löschen.
- [x] Rot nachweisen: `flutter test test/presentation/reset_bottomsheet_test.dart`.
- [x] Busy-Guard, vollständige Fehlerbehandlung und einmalige Navigation implementieren.
- [x] Denselben Test grün prüfen; Dialogdarstellung/Abbrechen am Handy kontrollieren, echten Reset nicht ausführen.
- [x] Commit: `fix(settings): guard reset actions and expose failures`.

### Aufgabe 8: Erklärungen und Datenschutz konsistent halten

**Ändern:** `lib/presentation/widgets/screens/settings/sections/school_holidays_section.dart`, `assets/legal/datenschutz.md`; bei tatsächlich nötiger Angleichung `lib/presentation/widgets/screens/settings/sections/privacy_section.dart`, `lib/core/config/contact_feedback_copy.dart`, `lib/core/l10n/app_de.arb`.

**Schnittstelle:** Keine neue Persistenz/Übermittlung. Bundesland-Hilfe an fehlende Auswahl statt Theme koppeln. Tatsächliche Datenübermittlung anhand `lib/data/services/contact_feedback_service.dart` und aktueller Telemetrieeinstellungen beschreiben; freiwillige Name-/E-Mail-Felder, Nachricht und Screenshot korrekt unterscheiden.

- [x] Neues `test/presentation/school_holidays_section_test.dart`: fehlendes Bundesland→gleiche hilfreiche Erklärung Light/Dark; nach Auswahl Erklärung weg und Aktion erreichbar.
- [x] Rot nachweisen: `flutter test test/presentation/school_holidays_section_test.dart`.
- [x] Hint korrigieren; widersprüchliche Datenschutzpassage durch Beschreibung des tatsächlichen Datenflusses ersetzen; Stand aktualisieren. Keine pauschalen Datenschutz-/Anonymitätszusicherungen erfinden.
- [x] Test grün prüfen; Feedbackformular, Datenschutzansicht und Privatsphäre-Einstellungen auf inhaltliche Übereinstimmung prüfen. Rechtschreibung und Renderdarstellung manuell prüfen, keine Wortlaut-Mirrortests.
- [x] Commit: `fix(settings): clarify holiday setup and feedback privacy`.

### Aufgabe 9: Kalenderpunkt 7 als nachrangiges Folgepaket

**Ändern:** `lib/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart`, `lib/presentation/widgets/screens/calendar/components/memoized_calendar_day.dart`, `lib/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart`, `lib/presentation/state/calendar/calendar_split_layout_notifier.dart`, `lib/core/l10n/app_de.arb`.

**Schnittstellen:** Tageswidget erhält eine lokalisierte vollständige Semantikbeschreibung aus den vorhandenen Renderdaten. Vorhandene TableCalendar-Selektion weiterverwenden, keine doppelte Tap-Aktion. Sichtbarer Ansichtsumschalter schreibt dieselbe Präferenz wie die vorhandene Geste.

- [ ] Neues `test/presentation/calendar_day_accessibility_test.dart`: kompakter Tag mit eigenen/Partner-Diensten und persönlichem Titel nennt alle Informationen im Semantics-Baum; Datum/Heute/Auswahl stimmen; mindestens Dienstkürzel visuell sichtbar. `test/presentation/calendar_split_layout_test.dart` erweitern: sichtbarer Toggle umschaltbar; Präferenz nach Neustart erhalten; Geste bleibt nutzbar; große Schrift ohne Overflow.
- [ ] Rot nachweisen: `flutter test test/presentation/calendar_day_accessibility_test.dart test/presentation/calendar_split_layout_test.dart`.
- [ ] Kürzel, Semantik und Umschalter ergänzen; kleine vorhandene Tagesflächen nicht durch unpassende mehrzeilige Volltitel überladen.
- [ ] Dieselben Tests plus `flutter test test/core/calendar_day_badge_contrast_test.dart test/presentation/calendar_day_builders_test.dart` grün prüfen; TalkBack auf dem Handy kontrollieren.
- [ ] Commit: `feat(calendar): improve compact duty labels and view switching`.

### Aufgabe 10: Gesamtprüfung, Handy und reviewbarer Abschluss

**Erstellen:** `docs/superpowers/validation/2026-10-07-ui-ux-audit-validation.md` mit geprüftem Commit, Build, Testbefehlen, Matrix, Bildern und verbleibenden Grenzen. Datum bei späterer tatsächlicher Ausführung entsprechend aktualisieren.

- [x] Bei generierten Änderungen `flutter gen-l10n` und vollständiges `dart run build_runner build` ausführen; Diff auf unerwartete Löschungen prüfen.
- [x] `flutter analyze`, `flutter test`, `git diff --check`: alle erfolgreich. Vorhandene Provider-Lifecycle-Regression muss weiter bestehen.
- [x] Reale Android-Prüfung: Kalender, Schnelleingabe, gespeicherter/wiedergeöffneter Nachtdienst, Entwurf-Abbruch, Feedback-Aufnahme-Abbruch, Reset-Dialog/Abbrechen und Light/Dark/System mit großer Schrift und Tastatur. Setup ohne Datenreset und Querformat über die Widgetmatrix; das Handy ist durch die vorhandene App-Regel im Hochformat gesperrt. Grenzen im Abnahmebericht.
- [x] „Das ist neu für dich“-Dialog in Light/Dark, Einstellungen und Formularnavigation am Gerät kontrollieren; Screenshots dokumentieren. Bestehende Tests für Einstellungen und rechtliche Ansichten mitlaufen lassen. Exportversand und TalkBack bleiben außerhalb der Geräte-Abnahme.
- [x] Testdaten ausschließlich anhand ihrer neu erzeugten IDs entfernen; Theme-/Ansichtspräferenzen auf Ausgangswerte zurückstellen. Kein Feedback versenden und keinen echten Reset ausführen.
- [x] Spec-Abdeckung prüfen: Audit 1–6, 8 und Zusatz A–C sind Hauptpaket-Abnahmekriterien; Punkt 7 bleibt ausdrücklich nachrangig. Wenn 9 noch aussteht, entsprechend dokumentieren, statt „alles behoben“ zu behaupten.
- [x] Nach tatsächlicher Implementierung reviewbare PR(s) im Conventional-Commit-Format erstellen/aktualisieren, ohne Codex-Erwähnung. Beschreibung: Problem, neues sichtbares Verhalten, Checks und relevante Grenzen. PR(s) am Chat anhängen.

## Selbstprüfung des Plans

- [x] Alle acht Hauptbefunde und drei Zusatzbefunde haben zuständige Aufgaben.
- [x] Punkt 7 ist auf ausdrücklichen Wunsch niedriger priorisiert und unabhängig lieferbar.
- [x] Gemeinsame Sheet-Resultate und Screenshot-Transferverträge sind benannt.
- [x] Alle fünf Review-Focus-Bedingungen sind konkreten Regressionen zugeordnet.
- [x] Planung verändert keine App-, Geräte- oder Nutzerdaten.
- [x] Endtag-Empfehlung nach Nutzerdiskussion festgelegt: freie Datumswahl mit automatischer Vorbelegung und persistiertem Enddatum; Aufgabe 3 enthält eine Speicherstrategie.

Hauptpaket geliefert in [PR #438](https://github.com/lusu007/dienstplan/pull/438). Aufgabe 9 bleibt als eigenständiges Folgepaket offen.
