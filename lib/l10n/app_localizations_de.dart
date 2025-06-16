// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Dienstplan';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'Englisch';

  @override
  String get dutySchedule => 'Dienstplan';

  @override
  String get selectDutySchedule => 'Dienstplan auswählen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get loading => 'Laden...';

  @override
  String get noDutySchedules => 'Keine Dienstpläne verfügbar';

  @override
  String get createNewDutySchedule => 'Neuen Dienstplan erstellen';

  @override
  String get dutyScheduleName => 'Name des Dienstplans';

  @override
  String get dutyScheduleDescription => 'Beschreibung';

  @override
  String get dutyScheduleStartDate => 'Startdatum';

  @override
  String get dutyScheduleStartWeekDay => 'Startwochentag';

  @override
  String get dutyScheduleDays => 'Tage';

  @override
  String get dutyScheduleDutyTypes => 'Diensttypen';

  @override
  String get dutyScheduleRhythms => 'Rhythmen';

  @override
  String get dutyScheduleGroups => 'Dienstgruppen';

  @override
  String get dutyTypeLabel => 'Bezeichnung';

  @override
  String get dutyTypeStartTime => 'Startzeit';

  @override
  String get dutyTypeEndTime => 'Endzeit';

  @override
  String get dutyTypeAllDay => 'Ganztägig';

  @override
  String get rhythmLengthWeeks => 'Länge in Wochen';

  @override
  String get rhythmPattern => 'Muster';

  @override
  String get groupName => 'Name';

  @override
  String get groupRhythm => 'Rhythmus';

  @override
  String get groupOffsetWeeks => 'Versatz in Wochen';

  @override
  String get firstTimeSetup => 'Erste Einrichtung';

  @override
  String get selectDefaultDutySchedule => 'Standard-Dienstplan auswählen';

  @override
  String get continueButton => 'Weiter';

  @override
  String get welcome => 'Willkommen';

  @override
  String get welcomeMessage =>
      'Bitte wählen Sie einen Standard-Dienstplan aus.';

  @override
  String get settingsSaved => 'Einstellungen gespeichert';

  @override
  String get settingsSaveError => 'Fehler beim Speichern der Einstellungen';

  @override
  String get dutyScheduleSaved => 'Dienstplan gespeichert';

  @override
  String get dutyScheduleSaveError => 'Fehler beim Speichern des Dienstplans';

  @override
  String get dutyScheduleDeleted => 'Dienstplan gelöscht';

  @override
  String get dutyScheduleDeleteError => 'Fehler beim Löschen des Dienstplans';

  @override
  String get confirmDelete => 'Möchten Sie diesen Dienstplan wirklich löschen?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get calendarFormat => 'Kalenderformat';

  @override
  String get calendarFormatMonth => 'Monat';

  @override
  String get calendarFormatTwoWeeks => 'Zwei Wochen';

  @override
  String get calendarFormatWeek => 'Woche';

  @override
  String get resetData => 'Daten zurücksetzen';

  @override
  String get resetDataConfirmation =>
      'Möchten Sie wirklich alle Daten zurücksetzen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get resetDataSuccess => 'Daten wurden zurückgesetzt';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get services => 'Dienste';

  @override
  String servicesOnDate(String date) {
    return 'am $date';
  }

  @override
  String get noServicesForDay => 'Keine Dienste für diesen Tag';

  @override
  String get allDay => 'Ganztägig';

  @override
  String get licenses => 'Lizenzen';
}
