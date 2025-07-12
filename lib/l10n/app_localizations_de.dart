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
  String get close => 'Schließen';

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
  String get welcomeMessage => 'Bitte wähle einen Standard-Dienstplan aus.';

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
  String get confirmDelete => 'Möchtest du diesen Dienstplan wirklich löschen?';

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
      'Möchtest du wirklich alle Daten zurücksetzen? Dies kann nicht rückgängig gemacht werden.';

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

  @override
  String get previousPeriod => 'Vorheriger Zeitraum';

  @override
  String get nextPeriod => 'Nächster Zeitraum';

  @override
  String get today => 'Heute';

  @override
  String get about => 'Über';

  @override
  String get aboutDescription =>
      'Dienstplan ist eine einfache und effiziente App zur Verwaltung von Polizei-Dienstplänen. Sie bietet dir einen Überblick über deine Schichten, unterstützt Offline-Zugriff und bietet eine Dienstgruppen-Ansicht, die für Polizeibeamte optimiert ist.';

  @override
  String get aboutDisclaimer =>
      'Diese App ist kein offizielles Produkt einer Behörde oder staatlichen Einrichtung. Die Dienstplan App ist ein inoffizielles Hilfsmittel, das unabhängig entwickelt wurde und steht in keinerlei Verbindung zur Polizei oder anderen staatlichen Stellen.';

  @override
  String get disclaimerLong =>
      'Diese Anwendung ist kein offizielles Produkt einer Behörde oder Regierungseinrichtung. Die Dienstplan App wurde unabhängig entwickelt und steht in keiner offiziellen Verbindung zur Polizei oder anderen staatlichen Stellen.\n\nDie in dieser Anwendung verwendeten Daten stammen aus öffentlich zugänglichen Informationsmaterialien der Polizeigewerkschaften GdP (Gewerkschaft der Polizei) und DPolG (Deutsche Polizeigewerkschaft). Es wurden ausschließlich öffentlich verfügbare Informationen verwendet. Keine behördeninternen oder vertraulichen Daten wurden unbefugt veröffentlicht oder verarbeitet.\n\nDiese Anwendung dient ausschließlich der privaten Nutzung und erhebt keinen Anspruch auf Vollständigkeit oder Richtigkeit der bereitgestellten Informationen.';

  @override
  String get selectDutyGroup => 'Wähle deine Dienstgruppe';

  @override
  String get selectDutyGroupMessage =>
      'Wähle die Dienstgruppe, zu der du gehörst:';

  @override
  String get back => 'Zurück';

  @override
  String get errorSavingDefaultConfig =>
      'Fehler beim Speichern der Standard-Konfiguration';

  @override
  String get preferredDutyGroup => 'Bevorzugte Dienstgruppe';

  @override
  String get selectPreferredDutyGroup => 'Bevorzugte Dienstgruppe auswählen';

  @override
  String get preferredDutyGroupDescription =>
      'Diese Dienstgruppe wird für zukünftige Funktionen verwendet';

  @override
  String get noPreferredDutyGroup => 'Keine bevorzugte Dienstgruppe gesetzt';

  @override
  String get noPreferredDutyGroupDescription =>
      'Es werden keine Dienstgruppen-Abkürzungen im Kalender angezeigt';

  @override
  String get general => 'Allgemein';

  @override
  String get legal => 'Rechtliches';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get disclaimer => 'Haftungsausschluss';

  @override
  String get preferredDutyGroupResetNotice =>
      'Die bevorzugte Dienstgruppe wurde zurückgesetzt, da sie im neuen Dienstplan nicht verfügbar ist.';

  @override
  String get sentryAnalytics => 'Analysen & Fehlerberichte';

  @override
  String get sentryAnalyticsDescription =>
      'Hilf bei der Verbesserung der App durch das Senden anonymisierter Nutzungsdaten und Fehlerberichte';

  @override
  String get sentryReplay => 'Sitzungsaufzeichnung';

  @override
  String get sentryReplayDescription =>
      'Nutzereingaben aufzeichnen, um bei der Fehlerbehebung zu helfen (nur wenn Analysen aktiviert sind)';

  @override
  String get privacy => 'Datenschutz';
}
