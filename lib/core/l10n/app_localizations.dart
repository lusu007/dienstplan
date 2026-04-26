import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// Title for the settings screen
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// Title for duty schedule in settings
  ///
  /// In de, this message translates to:
  /// **'Mein Dienstplan'**
  String get myDutySchedule;

  /// Save button text
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// Cancel button text
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// Close button text
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// Delete button text
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// Add button text
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// Error message title
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get error;

  /// Success message title
  ///
  /// In de, this message translates to:
  /// **'Erfolg'**
  String get success;

  /// Message shown when no duty schedules are available
  ///
  /// In de, this message translates to:
  /// **'Keine Dienstpläne verfügbar'**
  String get noDutySchedules;

  /// Continue button text
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get continueButton;

  /// Welcome message title
  ///
  /// In de, this message translates to:
  /// **'Hallo! 👋'**
  String get welcome;

  /// Welcome message text
  ///
  /// In de, this message translates to:
  /// **'Lass uns deinen Dienstplan einrichten. Wähle dafür deinen Dienstplan aus.'**
  String get welcomeMessage;

  /// Reset app button text
  ///
  /// In de, this message translates to:
  /// **'App zurücksetzen'**
  String get resetData;

  /// Confirmation message for reset app action
  ///
  /// In de, this message translates to:
  /// **'Möchtest du wirklich die App zurücksetzen? Dies kann nicht rückgängig gemacht werden.'**
  String get resetDataConfirmation;

  /// Success message after reset app action
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen hat geklappt. Du kannst die App neu einrichten.'**
  String get resetDataSuccess;

  /// Reset button text
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get reset;

  /// Message shown when no services are available for a day
  ///
  /// In de, this message translates to:
  /// **'Keine Dienste für diesen Tag'**
  String get noServicesForDay;

  /// Title for licenses page
  ///
  /// In de, this message translates to:
  /// **'Lizenzen'**
  String get licenses;

  /// Message shown when no licenses are available
  ///
  /// In de, this message translates to:
  /// **'Keine Lizenzen verfügbar.'**
  String get licensesEmptyState;

  /// Message shown when loading licenses fails
  ///
  /// In de, this message translates to:
  /// **'Lizenzen konnten gerade nicht geladen werden. Bitte versuch es später noch einmal.'**
  String get licensesLoadError;

  /// Version label
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get version;

  /// Title for disclaimer option
  ///
  /// In de, this message translates to:
  /// **'Haftungsausschluss'**
  String get disclaimer;

  /// Tooltip for the today button
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get today;

  /// Titel für Partner Dienstgruppe Einstellung
  ///
  /// In de, this message translates to:
  /// **'Partner Dienstgruppe'**
  String get partnerDutyGroup;

  /// Abschnittstitel für Partner-Dienstplan-Einstellungen
  ///
  /// In de, this message translates to:
  /// **'Partner Dienstplan'**
  String get partnerDutySchedule;

  /// Angezeigt, wenn keine Partner Dienstgruppe gewählt ist
  ///
  /// In de, this message translates to:
  /// **'Keine Partner-Dienstgruppe ausgewählt'**
  String get noPartnerGroup;

  /// Option um keinen Dienstplan zu wählen
  ///
  /// In de, this message translates to:
  /// **'Kein Dienstplan ausgewählt'**
  String get noDutySchedule;

  /// Nachricht, die angezeigt wird, wenn kein Partner Dienstplan ausgewählt ist
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle zuerst einen Partner Dienstplan aus'**
  String get selectPartnerDutyScheduleFirst;

  /// Nachricht, die angezeigt wird, wenn kein Dienstplan ausgewählt ist
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle zuerst einen Dienstplan aus'**
  String get selectMyDutyScheduleFirst;

  /// Fehlermeldung beim Löschen des aktiven Dienstplans
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen des aktiven Dienstplans'**
  String get errorClearingActiveConfig;

  /// Fehlermeldung beim Setzen des aktiven Dienstplans
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Setzen des aktiven Dienstplans'**
  String get errorSettingActiveConfig;

  /// Titel für Akzentfarbe
  ///
  /// In de, this message translates to:
  /// **'Partner Akzentfarbe'**
  String get accentColor;

  /// Titel für meine Akzentfarbe
  ///
  /// In de, this message translates to:
  /// **'Meine Akzentfarbe'**
  String get myAccentColor;

  /// Akzentfarbe Blau
  ///
  /// In de, this message translates to:
  /// **'Blau'**
  String get accentPrimaryBlue;

  /// Akzentfarbe Orange
  ///
  /// In de, this message translates to:
  /// **'Orange'**
  String get accentWarmOrange;

  /// Farbname Pink
  ///
  /// In de, this message translates to:
  /// **'Pink'**
  String get accentPink;

  /// Akzentfarbe Lila
  ///
  /// In de, this message translates to:
  /// **'Lila'**
  String get accentViolet;

  /// Akzentfarbe Grün
  ///
  /// In de, this message translates to:
  /// **'Grün'**
  String get accentFreshGreen;

  /// Akzentfarbe Türkis
  ///
  /// In de, this message translates to:
  /// **'Türkis'**
  String get accentTurquoiseGreen;

  /// Akzentfarbe Gelb
  ///
  /// In de, this message translates to:
  /// **'Gelb'**
  String get accentSunnyYellow;

  /// Farbname Rot
  ///
  /// In de, this message translates to:
  /// **'Rot'**
  String get accentRed;

  /// Akzentfarbe Grau
  ///
  /// In de, this message translates to:
  /// **'Grau'**
  String get accentLightGrey;

  /// Titel für die Ferien-Akzentfarbe-Einstellung
  ///
  /// In de, this message translates to:
  /// **'Ferien-Akzentfarbe'**
  String get holidayAccentColor;

  /// Title for the about dialog
  ///
  /// In de, this message translates to:
  /// **'Über'**
  String get about;

  /// Description text shown in the about dialog
  ///
  /// In de, this message translates to:
  /// **'Dienstplan ist eine einfache und effiziente App zur Verwaltung von Polizei-Dienstplänen. Sie bietet dir einen Überblick über deine Schichten, unterstützt Offline-Zugriff und bietet eine Dienstgruppen-Ansicht, die für Polizeibeamte optimiert ist.'**
  String get aboutDescription;

  /// Disclaimer text shown in the about dialog
  ///
  /// In de, this message translates to:
  /// **'Diese App ist kein offizielles Produkt einer Behörde oder staatlichen Einrichtung. Die Dienstplan App ist ein inoffizielles Hilfsmittel, das unabhängig entwickelt wurde und steht in keinerlei Verbindung zur Polizei oder anderen staatlichen Stellen.'**
  String get aboutDisclaimer;

  /// Title for the credits section
  ///
  /// In de, this message translates to:
  /// **'Danksagungen'**
  String get credits;

  /// Credits text for Mehr-Schulferien.de
  ///
  /// In de, this message translates to:
  /// **'Schulferien- und Feiertagsdaten werden von Mehr-Schulferien.de bereitgestellt. Vielen Dank für die kostenlose API und die großartige Arbeit!'**
  String get mehrSchulferienCredits;

  /// Link text to visit mehr-schulferien.de
  ///
  /// In de, this message translates to:
  /// **'Mehr-Schulferien.de besuchen'**
  String get visitMehrSchulferien;

  /// Full disclaimer text for the disclaimer popup
  ///
  /// In de, this message translates to:
  /// **'Diese Anwendung ist kein offizielles Produkt einer Behörde oder Regierungseinrichtung. Die Dienstplan App wurde unabhängig entwickelt und steht in keiner offiziellen Verbindung zur Polizei oder anderen staatlichen Stellen.\n\nDie in dieser Anwendung verwendeten Daten stammen aus öffentlich zugänglichen Informationsmaterialien der Polizeigewerkschaften GdP (Gewerkschaft der Polizei) und DPolG (Deutsche Polizeigewerkschaft). Es wurden ausschließlich öffentlich verfügbare Informationen verwendet. Keine behördeninternen oder vertraulichen Daten wurden unbefugt veröffentlicht oder verarbeitet.\n\nDiese Anwendung dient ausschließlich der privaten Nutzung und erhebt keinen Anspruch auf Vollständigkeit oder Richtigkeit der bereitgestellten Informationen.'**
  String get disclaimerLong;

  /// Message for duty group selection step
  ///
  /// In de, this message translates to:
  /// **'Wähle deine Dienstgruppe aus, damit wir dir die richtigen Informationen anzeigen können.'**
  String get selectDutyGroupMessage;

  /// Message when user already has a duty group set
  ///
  /// In de, this message translates to:
  /// **'Du kannst deine Dienstgruppe hier ändern oder beibehalten.'**
  String get myDutyGroupMessage;

  /// Back button text
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get back;

  /// Label for my duty group setting
  ///
  /// In de, this message translates to:
  /// **'Meine Dienstgruppe'**
  String get myDutyGroup;

  /// Title for my duty group selection dialog
  ///
  /// In de, this message translates to:
  /// **'Meine Dienstgruppe auswählen'**
  String get selectMyDutyGroup;

  /// Text shown when no my duty group is selected
  ///
  /// In de, this message translates to:
  /// **'Keine Dienstgruppe ausgewählt'**
  String get noMyDutyGroup;

  /// Text for no duty group option in selection dialogs
  ///
  /// In de, this message translates to:
  /// **'Keine Dienstgruppe'**
  String get noDutyGroup;

  /// Title for schedule settings section
  ///
  /// In de, this message translates to:
  /// **'Dienstplan'**
  String get schedule;

  /// Title for general app settings section
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get app;

  /// Label for theme mode selector
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get themeMode;

  /// Light theme option
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeModeLight;

  /// Dark theme option
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeModeDark;

  /// System theme option
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// Beschreibungstext für den Design-Auswahlschritt
  ///
  /// In de, this message translates to:
  /// **'Wähle, wie die App aussehen soll. Du kannst das jederzeit in den Einstellungen ändern.'**
  String get themeModeDescription;

  /// Title for legal section
  ///
  /// In de, this message translates to:
  /// **'Rechtliches'**
  String get legal;

  /// Title for privacy policy option
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get privacyPolicy;

  /// Title for Sentry analytics and error reporting setting
  ///
  /// In de, this message translates to:
  /// **'Analysen & Fehlerberichte'**
  String get sentryAnalytics;

  /// Description for Sentry analytics setting
  ///
  /// In de, this message translates to:
  /// **'Hilf bei der Verbesserung der App durch das Senden anonymisierter Nutzungsdaten und Fehlerberichte'**
  String get sentryAnalyticsDescription;

  /// Title for Sentry session replay setting
  ///
  /// In de, this message translates to:
  /// **'Sitzungsaufzeichnung'**
  String get sentryReplay;

  /// Description for Sentry session replay setting
  ///
  /// In de, this message translates to:
  /// **'Du erlaubst uns, Eingaben aufzuzeichnen, damit wir Fehler besser finden (nur wenn Analysen an sind)'**
  String get sentryReplayDescription;

  /// Title for privacy settings section
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get privacy;

  /// Label for showing all items (no filter)
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get all;

  /// Titel für die Kalenderexport-Option
  ///
  /// In de, this message translates to:
  /// **'Kalender exportieren'**
  String get exportCalendar;

  /// Beschreibung für die Kalenderexport-Option
  ///
  /// In de, this message translates to:
  /// **'Exportiere Diensteinträge als .ics-Kalenderdatei'**
  String get exportCalendarDescription;

  /// Beschriftung für das Export-Startdatum
  ///
  /// In de, this message translates to:
  /// **'Startdatum'**
  String get exportCalendarStartDate;

  /// Beschriftung für das Export-Enddatum
  ///
  /// In de, this message translates to:
  /// **'Enddatum'**
  String get exportCalendarEndDate;

  /// Beschriftung für das Einschließen des Partnerdienstplans
  ///
  /// In de, this message translates to:
  /// **'Partnerdienstplan einschließen'**
  String get exportCalendarIncludePartner;

  /// Beschreibung für das Einschließen des Partnerdienstplans
  ///
  /// In de, this message translates to:
  /// **'Deine konfigurierte Partner-Dienstgruppe wird mit in die Datei aufgenommen'**
  String get exportCalendarIncludePartnerDescription;

  /// Kurzes Präfix vor Partner-Terminen im ICS-Export (vor dem Doppelpunkt)
  ///
  /// In de, this message translates to:
  /// **'Partner'**
  String get exportCalendarPartnerSummaryPrefix;

  /// Aktion: ICS-Datei teilen
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get exportCalendarActionShare;

  /// Untertitel für die Teilen-Aktion
  ///
  /// In de, this message translates to:
  /// **'Über andere Apps versenden'**
  String get exportCalendarActionShareSubtitle;

  /// Aktion: ICS-Datei speichern
  ///
  /// In de, this message translates to:
  /// **'Auf dem Gerät speichern'**
  String get exportCalendarActionSave;

  /// Untertitel für die Speichern-Aktion
  ///
  /// In de, this message translates to:
  /// **'In Downloads oder gewähltem Ordner sichern'**
  String get exportCalendarActionSaveSubtitle;

  /// Aktion: ICS mit externer App öffnen
  ///
  /// In de, this message translates to:
  /// **'Mit Kalender-App öffnen'**
  String get exportCalendarActionOpen;

  /// Untertitel für die Öffnen-Aktion
  ///
  /// In de, this message translates to:
  /// **'Direkt in die Kalender-App importieren'**
  String get exportCalendarActionOpenSubtitle;

  /// Kurzbeschriftung Teilen in der Export-Aktionszeile (Overflow vermeiden)
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get exportCalendarActionRowShare;

  /// Kurzbeschriftung Speichern in der Export-Aktionszeile
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get exportCalendarActionRowSave;

  /// Kurzbeschriftung Kalender öffnen in der Export-Aktionszeile
  ///
  /// In de, this message translates to:
  /// **'In Kalender'**
  String get exportCalendarActionRowOpen;

  /// Erfolg nach Teilen
  ///
  /// In de, this message translates to:
  /// **'Kalenderdatei geteilt'**
  String get exportCalendarShareSuccess;

  /// Erfolg nach Speichern
  ///
  /// In de, this message translates to:
  /// **'Kalenderdatei gespeichert'**
  String get exportCalendarSaveSuccess;

  /// Erfolg nach Öffnen mit externer App
  ///
  /// In de, this message translates to:
  /// **'Kalenderdatei geöffnet'**
  String get exportCalendarOpenSuccess;

  /// Nutzer hat den Speichern-Dialog abgebrochen
  ///
  /// In de, this message translates to:
  /// **'Speichern abgebrochen.'**
  String get exportCalendarSaveCancelled;

  /// Kein Handler für ICS-Dateien
  ///
  /// In de, this message translates to:
  /// **'Keine passende App zum Öffnen dieser Datei gefunden.'**
  String get exportCalendarOpenNoApp;

  /// Generischer Fehler beim Öffnen der ICS-Datei
  ///
  /// In de, this message translates to:
  /// **'Die Datei ließ sich nicht öffnen. Bitte versuch es noch einmal.'**
  String get exportCalendarOpenFailed;

  /// Betreff für den geteilten Kalenderexport
  ///
  /// In de, this message translates to:
  /// **'Dienstplan Kalenderexport'**
  String get exportCalendarSubject;

  /// Freigabetext für den Kalenderexport
  ///
  /// In de, this message translates to:
  /// **'Importiere diese Datei in deine Kalender-App.'**
  String get exportCalendarShareText;

  /// Validierungsmeldung für einen ungültigen Exportzeitraum
  ///
  /// In de, this message translates to:
  /// **'Wähle ein Startdatum, das nicht nach dem Enddatum liegt.'**
  String get exportCalendarInvalidRange;

  /// Validierungsmeldung, wenn kein aktiver Dienstplan konfiguriert ist
  ///
  /// In de, this message translates to:
  /// **'Wähle zuerst deinen Dienstplan aus, bevor du exportierst.'**
  String get exportCalendarNoActiveSchedule;

  /// Meldung, wenn der Partnerexport nicht verfügbar ist
  ///
  /// In de, this message translates to:
  /// **'Konfiguriere einen Partnerdienstplan und eine Dienstgruppe, um diese Option zu aktivieren.'**
  String get exportCalendarPartnerUnavailable;

  /// Meldung, wenn keine Kalendereinträge für den Export verfügbar sind
  ///
  /// In de, this message translates to:
  /// **'In diesem Zeitraum gibt es keine Einträge zum Exportieren. Probier einen anderen Zeitraum.'**
  String get exportCalendarEmpty;

  /// Meldung, wenn der Kalenderexport fehlschlägt
  ///
  /// In de, this message translates to:
  /// **'Kalenderexport hat nicht geklappt. Bitte versuch es noch einmal.'**
  String get exportCalendarError;

  /// Title for share app option
  ///
  /// In de, this message translates to:
  /// **'App weiterempfehlen'**
  String get shareApp;

  /// Description for share app option
  ///
  /// In de, this message translates to:
  /// **'Empfehle die App deinen Kolleginnen und Kollegen'**
  String get shareAppDescription;

  /// Message template for sharing the app
  ///
  /// In de, this message translates to:
  /// **'Hey! 👋\n\nIch habe diese tolle Dienstplan App gefunden, die das Anzeigen von Dienstplänen für Polizeibeamte super einfach macht. Du solltest sie dir mal anschauen! 📱\n\nApp Store: {appStoreUrl}\nPlay Store: {playStoreUrl}\n\nHoffe, sie gefällt dir! 🚔'**
  String shareAppMessage(String appStoreUrl, String playStoreUrl);

  /// Subject for share app email
  ///
  /// In de, this message translates to:
  /// **'Dienstplan App Empfehlung'**
  String get shareAppSubject;

  /// Error message when sharing app fails
  ///
  /// In de, this message translates to:
  /// **'Teilen hat nicht geklappt. Bitte versuch es noch einmal.'**
  String get shareAppError;

  /// Message for the share image (without links)
  ///
  /// In de, this message translates to:
  /// **'Ich habe diese tolle Dienstplan App gefunden, die das Anzeigen von Dienstplänen für Polizeibeamte super einfach macht. Du solltest sie dir mal anschauen! 📱\n\nHoffe, sie gefällt dir! 🚔'**
  String get shareAppImageMessage;

  /// Title for other settings section
  ///
  /// In de, this message translates to:
  /// **'Weiteres'**
  String get other;

  /// Title for contact option
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get contact;

  /// Description for contact option
  ///
  /// In de, this message translates to:
  /// **'Kontaktiere uns'**
  String get contactDescription;

  /// Allgemeine Validierungsfehlermeldung
  ///
  /// In de, this message translates to:
  /// **'Das passt so nicht – bitte prüf deine Eingabe.'**
  String get genericValidationError;

  /// Allgemeine Nicht-gefunden-Fehlermeldung
  ///
  /// In de, this message translates to:
  /// **'Das haben wir nicht gefunden.'**
  String get genericNotFoundError;

  /// Allgemeine Netzwerk-Fehlermeldung
  ///
  /// In de, this message translates to:
  /// **'Netzwerkfehler. Bitte überprüfe deine Verbindung.'**
  String get genericNetworkError;

  /// Allgemeine Timeout-Fehlermeldung
  ///
  /// In de, this message translates to:
  /// **'Das dauert zu lange. Bitte versuch es noch einmal.'**
  String get genericTimeoutError;

  /// Allgemeine Speicher-Fehlermeldung
  ///
  /// In de, this message translates to:
  /// **'Beim Speichern ist ein Fehler aufgetreten. Bitte versuch es noch einmal.'**
  String get genericStorageError;

  /// Allgemeine Serialisierungs-Fehlermeldung
  ///
  /// In de, this message translates to:
  /// **'Die Daten konnten nicht verarbeitet werden. Bitte versuch es noch einmal.'**
  String get genericSerializationError;

  /// Allgemeine unbekannte Fehlermeldung
  ///
  /// In de, this message translates to:
  /// **'Etwas ist schiefgelaufen. Bitte versuch es noch einmal.'**
  String get genericUnknownError;

  /// Title for contribute option
  ///
  /// In de, this message translates to:
  /// **'Beitragen'**
  String get contribute;

  /// Description for contribute option
  ///
  /// In de, this message translates to:
  /// **'Hilf bei der Entwicklung der App'**
  String get contributeDescription;

  /// Message about loving open source software
  ///
  /// In de, this message translates to:
  /// **'Wir ❤️ Open Source'**
  String get weLoveOss;

  /// Title for partner setup step
  ///
  /// In de, this message translates to:
  /// **'Partner Dienstplan'**
  String get partnerSetupTitle;

  /// Description for partner setup step
  ///
  /// In de, this message translates to:
  /// **'Optional: Richte den Dienstplan deines Partners ein, um auch dessen Dienste anzuzeigen.'**
  String get partnerSetupDescription;

  /// Skip button for optional partner setup
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get skipPartnerSetup;

  /// Message for partner duty group selection
  ///
  /// In de, this message translates to:
  /// **'Wähle die Dienstgruppe deines Partners aus.'**
  String get selectPartnerDutyGroupMessage;

  /// Benachrichtigungsnachricht für einzelne Dienstplan-Aktualisierung
  ///
  /// In de, this message translates to:
  /// **'Dienstplan \"{configName}\" wurde aktualisiert (Version {oldVersion} → {newVersion}). Alle Dienste werden neu generiert.'**
  String scheduleUpdateNotification(
    String configName,
    String oldVersion,
    String newVersion,
  );

  /// Benachrichtigungsnachricht für mehrere Dienstplan-Aktualisierungen
  ///
  /// In de, this message translates to:
  /// **'Mehrere Dienstpläne wurden aktualisiert: {configNames}. Alle Dienste werden neu generiert.'**
  String multipleScheduleUpdatesNotification(String configNames);

  /// Label for police authority filter section
  ///
  /// In de, this message translates to:
  /// **'Nach Behörde filtern'**
  String get filterByPoliceAuthority;

  /// Button text to clear all filters
  ///
  /// In de, this message translates to:
  /// **'Alle löschen'**
  String get clearAll;

  /// Title for school holidays and public holidays section
  ///
  /// In de, this message translates to:
  /// **'Ferien & Feiertage'**
  String get schoolHolidays;

  /// Label for showing school holidays and public holidays toggle
  ///
  /// In de, this message translates to:
  /// **'Ferien & Feiertage anzeigen'**
  String get showSchoolHolidays;

  /// Loading text
  ///
  /// In de, this message translates to:
  /// **'Lädt...'**
  String get loading;

  /// Error message when loading fails
  ///
  /// In de, this message translates to:
  /// **'Laden klappt gerade nicht. Bitte versuch es noch einmal.'**
  String get errorLoading;

  /// Enabled status text
  ///
  /// In de, this message translates to:
  /// **'Aktiviert'**
  String get enabled;

  /// Disabled status text
  ///
  /// In de, this message translates to:
  /// **'Deaktiviert'**
  String get disabled;

  /// Label for federal state selection
  ///
  /// In de, this message translates to:
  /// **'Bundesland'**
  String get federalState;

  /// Text when no federal state is selected
  ///
  /// In de, this message translates to:
  /// **'Kein Bundesland ausgewählt'**
  String get noFederalStateSelected;

  /// Label for refreshing holiday data
  ///
  /// In de, this message translates to:
  /// **'Feriendaten aktualisieren'**
  String get refreshHolidayData;

  /// Last updated time text
  ///
  /// In de, this message translates to:
  /// **'Zuletzt aktualisiert: {time}'**
  String lastUpdated(String time);

  /// Text when data has not been updated yet
  ///
  /// In de, this message translates to:
  /// **'Noch nicht aktualisiert'**
  String get notUpdatedYet;

  /// Text for very recent time
  ///
  /// In de, this message translates to:
  /// **'Gerade eben'**
  String get justNow;

  /// Text for minutes ago
  ///
  /// In de, this message translates to:
  /// **'Vor {minutes} Minuten'**
  String minutesAgo(int minutes);

  /// Text for hours ago
  ///
  /// In de, this message translates to:
  /// **'Vor {hours} Stunden'**
  String hoursAgo(int hours);

  /// Text for days ago
  ///
  /// In de, this message translates to:
  /// **'Vor {days} Tagen'**
  String daysAgo(int days);

  /// Title for federal state selection dialog
  ///
  /// In de, this message translates to:
  /// **'Bundesland auswählen'**
  String get selectFederalState;

  /// Message shown when no holiday data is available for a specific year
  ///
  /// In de, this message translates to:
  /// **'Für {year} haben wir keine Feriendaten.'**
  String noHolidayDataForYear(int year);

  /// Label for vacation/regular holidays
  ///
  /// In de, this message translates to:
  /// **'Ferien'**
  String get vacation;

  /// Label for public holidays
  ///
  /// In de, this message translates to:
  /// **'Feiertag'**
  String get publicHoliday;

  /// Label for movable holidays
  ///
  /// In de, this message translates to:
  /// **'Beweglich'**
  String get movableHoliday;

  /// Tooltip for adding a personal calendar entry
  ///
  /// In de, this message translates to:
  /// **'Eigenen Termin oder Dienst eintragen'**
  String get addPersonalEntryTooltip;

  /// Hint for quick-add appointment field; {date} is a short calendar date
  ///
  /// In de, this message translates to:
  /// **'Termin am {date} hinzuf.'**
  String personalEntryQuickTitleHint(String date);

  /// Accessibility label for quick-add appointment field
  ///
  /// In de, this message translates to:
  /// **'Termin am {date} hinzufügen. Titel tippen, dann Fertig.'**
  String personalEntryQuickTitleSemanticLabel(String date);

  /// Title for new personal calendar entry sheet
  ///
  /// In de, this message translates to:
  /// **'Neuer Termin'**
  String get personalEntrySheetTitleNew;

  /// Title for editing a personal calendar entry
  ///
  /// In de, this message translates to:
  /// **'Eintrag bearbeiten'**
  String get personalEntrySheetTitleEdit;

  /// Label for appointment kind
  ///
  /// In de, this message translates to:
  /// **'Termin'**
  String get personalEntryKindAppointment;

  /// Label for personal duty kind
  ///
  /// In de, this message translates to:
  /// **'Eigener Dienst'**
  String get personalEntryKindDuty;

  /// Label for personal entry date picker
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get personalEntryDateLabel;

  /// Label for personal entry title field
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get personalEntryTitleLabel;

  /// Label for optional notes
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get personalEntryNotesLabel;

  /// Label for all-day toggle
  ///
  /// In de, this message translates to:
  /// **'Ganztägig'**
  String get personalEntryAllDayLabel;

  /// Label for start time
  ///
  /// In de, this message translates to:
  /// **'Beginn'**
  String get personalEntryStartTime;

  /// Snackbar after saving personal entry
  ///
  /// In de, this message translates to:
  /// **'Eintrag gespeichert'**
  String get personalEntrySaved;

  /// Snackbar after deleting personal entry
  ///
  /// In de, this message translates to:
  /// **'Eintrag gelöscht'**
  String get personalEntryDeleted;

  /// Validation: empty title
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Titel ein.'**
  String get personalEntryValidationTitle;

  /// Validation: missing times for timed entry
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle Start- und Endzeit.'**
  String get personalEntryValidationTimes;

  /// Validation: time out of range
  ///
  /// In de, this message translates to:
  /// **'Diese Uhrzeit geht nicht – probier eine andere.'**
  String get personalEntryValidationTimeRange;

  /// Validation: end before start
  ///
  /// In de, this message translates to:
  /// **'Die Endzeit muss nach dem Beginn liegen.'**
  String get personalEntryValidationEndAfterStart;

  /// Tooltip for compact schedule list header toggle to show other duty groups
  ///
  /// In de, this message translates to:
  /// **'Andere Dienstgruppen anzeigen'**
  String get compactListShowOtherDutyGroupsTooltip;

  /// Tooltip for compact schedule list header toggle to hide other duty groups
  ///
  /// In de, this message translates to:
  /// **'Andere Dienstgruppen ausblenden'**
  String get compactListHideOtherDutyGroupsTooltip;

  /// Recovery action label for error states
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get tryAgain;

  /// Title for the setup-load failure screen
  ///
  /// In de, this message translates to:
  /// **'Die Einrichtung lässt sich gerade nicht laden'**
  String get setupFailedTitle;

  /// Title for the confirmation dialog before deleting a personal calendar entry
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen?'**
  String get deletePersonalEntryConfirmationTitle;

  /// Body for the personal entry delete confirmation dialog
  ///
  /// In de, this message translates to:
  /// **'Der Eintrag wird aus deinem Kalender entfernt. Diese Aktion kann nicht rückgängig gemacht werden.'**
  String get deletePersonalEntryConfirmationMessage;

  /// Empty state title in the setup config selection step when filters return no results
  ///
  /// In de, this message translates to:
  /// **'Keine Dienstpläne passen zum Filter'**
  String get configSelectionEmptyTitle;

  /// Empty state body in the setup config selection step
  ///
  /// In de, this message translates to:
  /// **'Passe den Behördenfilter an oder setz ihn zurück – dann siehst du mehr Dienstpläne.'**
  String get configSelectionEmptyMessage;

  /// Empty state message when a config has no duty groups
  ///
  /// In de, this message translates to:
  /// **'Für diesen Dienstplan gibt es leider keine Dienstgruppen zum Auswählen.'**
  String get dutyGroupSelectionEmptyMessage;

  /// Title for the post-update what's new dialog
  ///
  /// In de, this message translates to:
  /// **'Das ist neu für dich'**
  String get whatsNewTitle;

  /// Release highlights for the what's new dialog; update each release
  ///
  /// In de, this message translates to:
  /// **'Hier die wichtigsten Änderungen für dich:\n\n• Klares, modernes Glass-Design – die App wirkt aufgeräumter\n• Du kannst jetzt eigene Termine und Dienste im Kalender eintragen – wir bauen das weiter aus\n• Kalender und Tagesansicht sind feiner abgestimmt\n• Stabilere Bedienung und kleinere Korrekturen\n\nViel Erfolg im Dienst – und komm heile nach Hause. Bei Fragen oder Feedback erreichst du uns unter „Kontakt“ in der App.'**
  String get whatsNewBody;

  /// Primary button to dismiss the what's new dialog
  ///
  /// In de, this message translates to:
  /// **'Alles klar'**
  String get whatsNewGotIt;

  /// Settings General: title to reopen the what's new dialog
  ///
  /// In de, this message translates to:
  /// **'Was ist neu für dich?'**
  String get settingsWhatsNewShowAgain;

  /// Subtitle for the settings what's new entry
  ///
  /// In de, this message translates to:
  /// **'Sieh dir die Hinweise zum Update noch einmal an'**
  String get settingsWhatsNewShowAgainSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
