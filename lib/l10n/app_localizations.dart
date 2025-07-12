import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Duty Schedule'**
  String get appTitle;

  /// Title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Title for duty schedule
  ///
  /// In en, this message translates to:
  /// **'Duty Schedule'**
  String get dutySchedule;

  /// Title for duty schedule selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Duty Schedule'**
  String get selectDutySchedule;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Error message title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Message shown when no duty schedules are available
  ///
  /// In en, this message translates to:
  /// **'No duty schedules available'**
  String get noDutySchedules;

  /// Title for creating a new duty schedule
  ///
  /// In en, this message translates to:
  /// **'Create New Duty Schedule'**
  String get createNewDutySchedule;

  /// Label for duty schedule name field
  ///
  /// In en, this message translates to:
  /// **'Duty Schedule Name'**
  String get dutyScheduleName;

  /// Label for duty schedule description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get dutyScheduleDescription;

  /// Label for duty schedule start date field
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get dutyScheduleStartDate;

  /// Label for duty schedule start week day field
  ///
  /// In en, this message translates to:
  /// **'Start Week Day'**
  String get dutyScheduleStartWeekDay;

  /// Label for duty schedule days field
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get dutyScheduleDays;

  /// Label for duty schedule duty types field
  ///
  /// In en, this message translates to:
  /// **'Duty Types'**
  String get dutyScheduleDutyTypes;

  /// Label for duty schedule rhythms field
  ///
  /// In en, this message translates to:
  /// **'Rhythms'**
  String get dutyScheduleRhythms;

  /// Label for duty schedule groups field
  ///
  /// In en, this message translates to:
  /// **'Duty Groups'**
  String get dutyScheduleGroups;

  /// Label for duty type name field
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get dutyTypeLabel;

  /// Label for duty type start time field
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get dutyTypeStartTime;

  /// Label for duty type end time field
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get dutyTypeEndTime;

  /// Label for duty type all day checkbox
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get dutyTypeAllDay;

  /// Label for rhythm length in weeks field
  ///
  /// In en, this message translates to:
  /// **'Length in Weeks'**
  String get rhythmLengthWeeks;

  /// Label for rhythm pattern field
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get rhythmPattern;

  /// Label for group name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get groupName;

  /// Label for group rhythm field
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get groupRhythm;

  /// Label for group offset in weeks field
  ///
  /// In en, this message translates to:
  /// **'Offset in Weeks'**
  String get groupOffsetWeeks;

  /// Title for first time setup screen
  ///
  /// In en, this message translates to:
  /// **'First Time Setup'**
  String get firstTimeSetup;

  /// Title for selecting default duty schedule
  ///
  /// In en, this message translates to:
  /// **'Select Default Duty Schedule'**
  String get selectDefaultDutySchedule;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Welcome message title
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Welcome message text
  ///
  /// In en, this message translates to:
  /// **'Please select a default duty schedule.'**
  String get welcomeMessage;

  /// Message shown when settings are saved successfully
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// Error message when settings save fails
  ///
  /// In en, this message translates to:
  /// **'Error saving settings'**
  String get settingsSaveError;

  /// Message shown when duty schedule is saved successfully
  ///
  /// In en, this message translates to:
  /// **'Duty schedule saved'**
  String get dutyScheduleSaved;

  /// Error message when duty schedule save fails
  ///
  /// In en, this message translates to:
  /// **'Error saving duty schedule'**
  String get dutyScheduleSaveError;

  /// Message shown when duty schedule is deleted successfully
  ///
  /// In en, this message translates to:
  /// **'Duty schedule deleted'**
  String get dutyScheduleDeleted;

  /// Error message when duty schedule deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting duty schedule'**
  String get dutyScheduleDeleteError;

  /// Confirmation message for deleting a duty schedule
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this duty schedule?'**
  String get confirmDelete;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Label for calendar format selection
  ///
  /// In en, this message translates to:
  /// **'Calendar Format'**
  String get calendarFormat;

  /// Label for month view in calendar format selector
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarFormatMonth;

  /// Label for two weeks view in calendar format selector
  ///
  /// In en, this message translates to:
  /// **'Two Weeks'**
  String get calendarFormatTwoWeeks;

  /// Label for week view in calendar format selector
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendarFormatWeek;

  /// Title for reset data option
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// Confirmation message for resetting data
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all data? This cannot be undone.'**
  String get resetDataConfirmation;

  /// Message shown when data is reset successfully
  ///
  /// In en, this message translates to:
  /// **'Data has been reset'**
  String get resetDataSuccess;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Title for services screen
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// Services on specific date
  ///
  /// In en, this message translates to:
  /// **'on {date}'**
  String servicesOnDate(String date);

  /// Message shown when no services are available for a day
  ///
  /// In en, this message translates to:
  /// **'No services for this day'**
  String get noServicesForDay;

  /// Label for all-day service
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// Title for the licenses screen
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Tooltip for the previous period navigation button
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriod;

  /// Tooltip for the next period navigation button
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriod;

  /// Tooltip for the today button
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Title for the about dialog
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Description text shown in the about dialog
  ///
  /// In en, this message translates to:
  /// **'Dienstplan is a simple and efficient app for managing police duty schedules. It provides an overview of your shifts, supports offline access, and offers a duty group view optimized for police officers.'**
  String get aboutDescription;

  /// Disclaimer text shown in the about dialog
  ///
  /// In en, this message translates to:
  /// **'This app is not an official product of any authority or government agency. Dienstplan App is an unofficial tool developed independently and is not affiliated with the police or any government entity.'**
  String get aboutDisclaimer;

  /// Full disclaimer text for the disclaimer popup
  ///
  /// In en, this message translates to:
  /// **'This application is not an official product of any government authority or agency. The Dienstplan App has been developed independently and is not officially affiliated with the police or any government entity.\n\nThe data used in this application originates from publicly accessible information materials of the police unions GdP (Gewerkschaft der Polizei) and DPolG (Deutsche Polizeigewerkschaft). Only publicly available information has been utilized. No internal or confidential agency data has been published or processed without authorization.\n\nThis application is intended for private use only and makes no claim to the completeness or accuracy of the information provided.'**
  String get disclaimerLong;

  /// Title for duty group selection step
  ///
  /// In en, this message translates to:
  /// **'Select Your Duty Group'**
  String get selectDutyGroup;

  /// Message for duty group selection step
  ///
  /// In en, this message translates to:
  /// **'Choose the duty group you belong to:'**
  String get selectDutyGroupMessage;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Error message when saving default configuration fails
  ///
  /// In en, this message translates to:
  /// **'Error saving default configuration'**
  String get errorSavingDefaultConfig;

  /// Label for preferred duty group setting
  ///
  /// In en, this message translates to:
  /// **'Preferred Duty Group'**
  String get preferredDutyGroup;

  /// Title for preferred duty group selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Preferred Duty Group'**
  String get selectPreferredDutyGroup;

  /// Description for preferred duty group setting
  ///
  /// In en, this message translates to:
  /// **'This duty group will be used for future functionality'**
  String get preferredDutyGroupDescription;

  /// Text shown when no preferred duty group is selected
  ///
  /// In en, this message translates to:
  /// **'No preferred duty group set'**
  String get noPreferredDutyGroup;

  /// Description for no preferred duty group option
  ///
  /// In en, this message translates to:
  /// **'No duty group abbreviations will be shown on the calendar'**
  String get noPreferredDutyGroupDescription;

  /// Title for general settings section
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Title for legal section
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// Title for privacy policy option
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Title for disclaimer option
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// Notice when the preferred duty group is reset on schedule change
  ///
  /// In en, this message translates to:
  /// **'Preferred duty group was reset because it is not available in the new schedule.'**
  String get preferredDutyGroupResetNotice;

  /// Title for Sentry analytics and error reporting setting
  ///
  /// In en, this message translates to:
  /// **'Analytics & Error Reporting'**
  String get sentryAnalytics;

  /// Description for Sentry analytics setting
  ///
  /// In en, this message translates to:
  /// **'Help improve the app by sending anonymous usage data and error reports'**
  String get sentryAnalyticsDescription;

  /// Title for Sentry session replay setting
  ///
  /// In en, this message translates to:
  /// **'Session Replay'**
  String get sentryReplay;

  /// Description for Sentry session replay setting
  ///
  /// In en, this message translates to:
  /// **'Record user interactions to help debug issues (only when analytics is enabled)'**
  String get sentryReplayDescription;

  /// Title for privacy settings section
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
