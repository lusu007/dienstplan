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
    Locale('en'),
  ];

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
  /// **'My Duty Schedule'**
  String get dutySchedule;

  /// Title for duty schedule in settings
  ///
  /// In en, this message translates to:
  /// **'My Duty Schedule'**
  String get myDutySchedule;

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

  /// Message shown when no duty schedules are available
  ///
  /// In en, this message translates to:
  /// **'No duty schedules available'**
  String get noDutySchedules;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Welcome message title
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get welcome;

  /// Welcome message text
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your duty schedule. Therefore choose your duty schedule.'**
  String get welcomeMessage;

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

  /// Reset app button text
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get resetData;

  /// Confirmation message for reset app action
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the app? This cannot be undone.'**
  String get resetDataConfirmation;

  /// Success message after reset app action
  ///
  /// In en, this message translates to:
  /// **'App has been reset successfully'**
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

  /// Title for licenses page
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

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

  /// Title for partner duty group setting
  ///
  /// In en, this message translates to:
  /// **'Partner Duty Group'**
  String get partnerDutyGroup;

  /// Section title for partner duty schedule settings
  ///
  /// In en, this message translates to:
  /// **'Partner Duty Schedule'**
  String get partnerDutySchedule;

  /// Shown when no partner group is selected
  ///
  /// In en, this message translates to:
  /// **'No partner group'**
  String get noPartnerGroup;

  /// Generic accent color title
  ///
  /// In en, this message translates to:
  /// **'Partner Accent Color'**
  String get accentColor;

  /// Title for my accent color
  ///
  /// In en, this message translates to:
  /// **'My Accent Color'**
  String get myAccentColor;

  /// Primary blue accent color
  ///
  /// In en, this message translates to:
  /// **'Primary Blue'**
  String get accentPrimaryBlue;

  /// Warm orange accent color
  ///
  /// In en, this message translates to:
  /// **'Warm Orange'**
  String get accentWarmOrange;

  /// Pink color name
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get accentPink;

  /// Violet accent color
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get accentViolet;

  /// Fresh green accent color
  ///
  /// In en, this message translates to:
  /// **'Fresh Green'**
  String get accentFreshGreen;

  /// Turquoise green accent color
  ///
  /// In en, this message translates to:
  /// **'Turquoise Green'**
  String get accentTurquoiseGreen;

  /// Sunny yellow accent color
  ///
  /// In en, this message translates to:
  /// **'Sunny Yellow'**
  String get accentSunnyYellow;

  /// Red color name
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get accentRed;

  /// Light grey accent color
  ///
  /// In en, this message translates to:
  /// **'Light Grey'**
  String get accentLightGrey;

  /// Title for holiday accent color setting
  ///
  /// In en, this message translates to:
  /// **'Holiday Accent Color'**
  String get holidayAccentColor;

  /// Option to select no duty schedule
  ///
  /// In en, this message translates to:
  /// **'No duty schedule'**
  String get noDutySchedule;

  /// Title for selecting partner duty group
  ///
  /// In en, this message translates to:
  /// **'Select Partner Duty Group'**
  String get selectPartnerDutyGroup;

  /// Message shown when no partner duty schedule is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a partner duty schedule first'**
  String get selectPartnerDutyScheduleFirst;

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
  /// **'Which duty group are you in?'**
  String get selectDutyGroup;

  /// Message for duty group selection step
  ///
  /// In en, this message translates to:
  /// **'Select your duty group so we can show you the right information.'**
  String get selectDutyGroupMessage;

  /// Message when user already has a duty group set
  ///
  /// In en, this message translates to:
  /// **'You can change or keep your duty group here.'**
  String get myDutyGroupMessage;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Label for my duty group setting
  ///
  /// In en, this message translates to:
  /// **'My Duty Group'**
  String get myDutyGroup;

  /// Title for my duty group selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select My Duty Group'**
  String get selectMyDutyGroup;

  /// Text shown when no my duty group is selected
  ///
  /// In en, this message translates to:
  /// **'No duty group selected'**
  String get noMyDutyGroup;

  /// Text for no duty group option in selection dialogs
  ///
  /// In en, this message translates to:
  /// **'No duty group'**
  String get noDutyGroup;

  /// Description for no my duty group option
  ///
  /// In en, this message translates to:
  /// **'No duty group abbreviations will be shown on the calendar'**
  String get noMyDutyGroupDescription;

  /// Title for schedule settings section
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Title for general app settings section
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get app;

  /// Label for theme mode selector
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// Description text for theme selection step
  ///
  /// In en, this message translates to:
  /// **'Choose how the app should look. You can change this at any time in Settings.'**
  String get themeModeDescription;

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

  /// Label for filter status text
  ///
  /// In en, this message translates to:
  /// **'Filtered by'**
  String get filteredBy;

  /// Label for showing all items (no filter)
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Title for share app option
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// Description for share app option
  ///
  /// In en, this message translates to:
  /// **'Recommend the app to colleagues'**
  String get shareAppDescription;

  /// Message template for sharing the app
  ///
  /// In en, this message translates to:
  /// **'Hey! 👋\n\nI found this great Duty Schedule App that makes viewing duty schedules super easy for police officers. You should check it out! 📱\n\nApp Store: {appStoreUrl}\nPlay Store: {playStoreUrl}\n\nHope you like it! 🚔'**
  String shareAppMessage(String appStoreUrl, String playStoreUrl);

  /// Subject for share app email
  ///
  /// In en, this message translates to:
  /// **'Duty Schedule App Recommendation'**
  String get shareAppSubject;

  /// Error message when sharing app fails
  ///
  /// In en, this message translates to:
  /// **'Error sharing app'**
  String get shareAppError;

  /// Message for the share image (without links)
  ///
  /// In en, this message translates to:
  /// **'I found this great Duty Schedule App that makes viewing duty schedules super easy for police officers. You should check it out! 📱\n\nHope you like it! 🚔'**
  String get shareAppImageMessage;

  /// Title for other settings section
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Title for contact option
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Description for contact option
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us'**
  String get contactDescription;

  /// Generic validation error message
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get genericValidationError;

  /// Generic not found error message
  ///
  /// In en, this message translates to:
  /// **'Requested item was not found'**
  String get genericNotFoundError;

  /// Generic conflict error message
  ///
  /// In en, this message translates to:
  /// **'Conflict occurred'**
  String get genericConflictError;

  /// Generic unauthorized error message
  ///
  /// In en, this message translates to:
  /// **'You are not authorized'**
  String get genericUnauthorizedError;

  /// Generic forbidden error message
  ///
  /// In en, this message translates to:
  /// **'Access is forbidden'**
  String get genericForbiddenError;

  /// Generic network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get genericNetworkError;

  /// Generic timeout error message
  ///
  /// In en, this message translates to:
  /// **'The operation timed out'**
  String get genericTimeoutError;

  /// Generic storage error message
  ///
  /// In en, this message translates to:
  /// **'Storage error occurred'**
  String get genericStorageError;

  /// Generic serialization error message
  ///
  /// In en, this message translates to:
  /// **'Data processing error'**
  String get genericSerializationError;

  /// Generic cancellation error message
  ///
  /// In en, this message translates to:
  /// **'The operation was cancelled'**
  String get genericCancellationError;

  /// Generic unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get genericUnknownError;

  /// Title for contribute option
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// Description for contribute option
  ///
  /// In en, this message translates to:
  /// **'Help with app development'**
  String get contributeDescription;

  /// Message about loving open source software
  ///
  /// In en, this message translates to:
  /// **'We ❤️ Open Source'**
  String get weLoveOss;

  /// Title for partner setup step
  ///
  /// In en, this message translates to:
  /// **'Partner Duty Schedule'**
  String get partnerSetupTitle;

  /// Description for partner setup step
  ///
  /// In en, this message translates to:
  /// **'Optional: Set up your partner\'s duty schedule to also display their duties.'**
  String get partnerSetupDescription;

  /// Skip button for optional partner setup
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipPartnerSetup;

  /// Title for partner config selection
  ///
  /// In en, this message translates to:
  /// **'Select Partner Duty Schedule'**
  String get selectPartnerConfig;

  /// Message for partner config selection
  ///
  /// In en, this message translates to:
  /// **'Select your partner\'s duty schedule.'**
  String get selectPartnerConfigMessage;

  /// Option to not set a partner config
  ///
  /// In en, this message translates to:
  /// **'No Partner Duty Schedule'**
  String get noPartnerConfig;

  /// Description for no partner config option
  ///
  /// In en, this message translates to:
  /// **'No partner duty schedule will be displayed'**
  String get noPartnerConfigDescription;

  /// Message for partner duty group selection
  ///
  /// In en, this message translates to:
  /// **'Select your partner\'s duty group.'**
  String get selectPartnerDutyGroupMessage;

  /// Notification message for single schedule update
  ///
  /// In en, this message translates to:
  /// **'Duty schedule \"{configName}\" has been updated (Version {oldVersion} → {newVersion}). All services will be regenerated.'**
  String scheduleUpdateNotification(
    String configName,
    String oldVersion,
    String newVersion,
  );

  /// Notification message for multiple schedule updates
  ///
  /// In en, this message translates to:
  /// **'Multiple duty schedules have been updated: {configNames}. All services will be regenerated.'**
  String multipleScheduleUpdatesNotification(String configNames);

  /// Label for police authority filter section
  ///
  /// In en, this message translates to:
  /// **'Filter by Authority'**
  String get filterByPoliceAuthority;

  /// Button text to clear all filters
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;
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
    'that was used.',
  );
}
