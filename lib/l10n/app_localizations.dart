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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Duty Schedule'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dutySchedule.
  ///
  /// In en, this message translates to:
  /// **'Duty Schedule'**
  String get dutySchedule;

  /// No description provided for @selectDutySchedule.
  ///
  /// In en, this message translates to:
  /// **'Select Duty Schedule'**
  String get selectDutySchedule;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noDutySchedules.
  ///
  /// In en, this message translates to:
  /// **'No duty schedules available'**
  String get noDutySchedules;

  /// No description provided for @createNewDutySchedule.
  ///
  /// In en, this message translates to:
  /// **'Create New Duty Schedule'**
  String get createNewDutySchedule;

  /// No description provided for @dutyScheduleName.
  ///
  /// In en, this message translates to:
  /// **'Duty Schedule Name'**
  String get dutyScheduleName;

  /// No description provided for @dutyScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get dutyScheduleDescription;

  /// No description provided for @dutyScheduleStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get dutyScheduleStartDate;

  /// No description provided for @dutyScheduleStartWeekDay.
  ///
  /// In en, this message translates to:
  /// **'Start Week Day'**
  String get dutyScheduleStartWeekDay;

  /// No description provided for @dutyScheduleDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get dutyScheduleDays;

  /// No description provided for @dutyScheduleDutyTypes.
  ///
  /// In en, this message translates to:
  /// **'Duty Types'**
  String get dutyScheduleDutyTypes;

  /// No description provided for @dutyScheduleRhythms.
  ///
  /// In en, this message translates to:
  /// **'Rhythms'**
  String get dutyScheduleRhythms;

  /// No description provided for @dutyScheduleGroups.
  ///
  /// In en, this message translates to:
  /// **'Duty Groups'**
  String get dutyScheduleGroups;

  /// No description provided for @dutyTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get dutyTypeLabel;

  /// No description provided for @dutyTypeStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get dutyTypeStartTime;

  /// No description provided for @dutyTypeEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get dutyTypeEndTime;

  /// No description provided for @dutyTypeAllDay.
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get dutyTypeAllDay;

  /// No description provided for @rhythmLengthWeeks.
  ///
  /// In en, this message translates to:
  /// **'Length in Weeks'**
  String get rhythmLengthWeeks;

  /// No description provided for @rhythmPattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get rhythmPattern;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get groupName;

  /// No description provided for @groupRhythm.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get groupRhythm;

  /// No description provided for @groupOffsetWeeks.
  ///
  /// In en, this message translates to:
  /// **'Offset in Weeks'**
  String get groupOffsetWeeks;

  /// No description provided for @firstTimeSetup.
  ///
  /// In en, this message translates to:
  /// **'First Time Setup'**
  String get firstTimeSetup;

  /// No description provided for @selectDefaultDutySchedule.
  ///
  /// In en, this message translates to:
  /// **'Select Default Duty Schedule'**
  String get selectDefaultDutySchedule;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select a default duty schedule.'**
  String get welcomeMessage;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @settingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings'**
  String get settingsSaveError;

  /// No description provided for @dutyScheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Duty schedule saved'**
  String get dutyScheduleSaved;

  /// No description provided for @dutyScheduleSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving duty schedule'**
  String get dutyScheduleSaveError;

  /// No description provided for @dutyScheduleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Duty schedule deleted'**
  String get dutyScheduleDeleted;

  /// No description provided for @dutyScheduleDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting duty schedule'**
  String get dutyScheduleDeleteError;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this duty schedule?'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @calendarFormat.
  ///
  /// In en, this message translates to:
  /// **'Calendar Format'**
  String get calendarFormat;

  /// No description provided for @calendarFormatMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarFormatMonth;

  /// No description provided for @calendarFormatTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'Two Weeks'**
  String get calendarFormatTwoWeeks;

  /// No description provided for @calendarFormatWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendarFormatWeek;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// No description provided for @resetDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all data? This cannot be undone.'**
  String get resetDataConfirmation;

  /// No description provided for @resetDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data has been reset'**
  String get resetDataSuccess;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @servicesOnDate.
  ///
  /// In en, this message translates to:
  /// **'on {date}'**
  String servicesOnDate(String date);

  /// No description provided for @noServicesForDay.
  ///
  /// In en, this message translates to:
  /// **'No services for this day'**
  String get noServicesForDay;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;
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
