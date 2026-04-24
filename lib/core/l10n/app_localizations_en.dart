// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get dutySchedule => 'My Duty Schedule';

  @override
  String get myDutySchedule => 'My Duty Schedule';

  @override
  String get selectDutySchedule => 'Select Duty Schedule';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get noDutySchedules => 'No duty schedules available';

  @override
  String get continueButton => 'Continue';

  @override
  String get welcome => 'Hello! 👋';

  @override
  String get welcomeMessage =>
      'Let\'s set up your duty schedule. Therefore choose your duty schedule.';

  @override
  String get resetData => 'Reset App';

  @override
  String get resetDataConfirmation =>
      'Are you sure you want to reset the app? This cannot be undone.';

  @override
  String get resetDataSuccess => 'App has been reset successfully';

  @override
  String get reset => 'Reset';

  @override
  String get services => 'Services';

  @override
  String servicesOnDate(String date) {
    return 'on $date';
  }

  @override
  String get noServicesForDay => 'No services for this day';

  @override
  String get licenses => 'Licenses';

  @override
  String get version => 'Version';

  @override
  String get previousPeriod => 'Previous period';

  @override
  String get nextPeriod => 'Next period';

  @override
  String get today => 'Today';

  @override
  String get partnerDutyGroup => 'Partner Duty Group';

  @override
  String get partnerDutySchedule => 'Partner Duty Schedule';

  @override
  String get noPartnerGroup => 'No partner duty group selected';

  @override
  String get accentColor => 'Partner Accent Color';

  @override
  String get myAccentColor => 'My Accent Color';

  @override
  String get accentPrimaryBlue => 'Blue';

  @override
  String get accentWarmOrange => 'Orange';

  @override
  String get accentPink => 'Pink';

  @override
  String get accentViolet => 'Purple';

  @override
  String get accentFreshGreen => 'Green';

  @override
  String get accentTurquoiseGreen => 'Teal';

  @override
  String get accentSunnyYellow => 'Yellow';

  @override
  String get accentRed => 'Red';

  @override
  String get accentLightGrey => 'Gray';

  @override
  String get holidayAccentColor => 'Holiday Accent Color';

  @override
  String get noDutySchedule => 'No duty schedule';

  @override
  String get selectPartnerDutyGroup => 'Select Partner Duty Group';

  @override
  String get selectPartnerDutyScheduleFirst =>
      'Please select a partner duty schedule first';

  @override
  String get selectMyDutyScheduleFirst => 'Please select a duty schedule first';

  @override
  String get errorClearingActiveConfig => 'Error clearing active config';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'Dienstplan is a simple and efficient app for managing police duty schedules. It provides an overview of your shifts, supports offline access, and offers a duty group view optimized for police officers.';

  @override
  String get aboutDisclaimer =>
      'This app is not an official product of any authority or government agency. Dienstplan App is an unofficial tool developed independently and is not affiliated with the police or any government entity.';

  @override
  String get credits => 'Credits';

  @override
  String get mehrSchulferienCredits =>
      'School holiday and public holiday data is provided by Mehr-Schulferien.de. Thank you for the free API and great work!';

  @override
  String get visitMehrSchulferien => 'Visit Mehr-Schulferien.de';

  @override
  String get disclaimerLong =>
      'This application is not an official product of any government authority or agency. The Dienstplan App has been developed independently and is not officially affiliated with the police or any government entity.\n\nThe data used in this application originates from publicly accessible information materials of the police unions GdP (Gewerkschaft der Polizei) and DPolG (Deutsche Polizeigewerkschaft). Only publicly available information has been utilized. No internal or confidential agency data has been published or processed without authorization.\n\nThis application is intended for private use only and makes no claim to the completeness or accuracy of the information provided.';

  @override
  String get selectDutyGroup => 'Which duty group are you in?';

  @override
  String get selectDutyGroupMessage =>
      'Select your duty group so we can show you the right information.';

  @override
  String get myDutyGroupMessage =>
      'You can change or keep your duty group here.';

  @override
  String get back => 'Back';

  @override
  String get myDutyGroup => 'My Duty Group';

  @override
  String get selectMyDutyGroup => 'Select My Duty Group';

  @override
  String get noMyDutyGroup => 'No duty group selected';

  @override
  String get noDutyGroup => 'No duty group';

  @override
  String get noMyDutyGroupDescription =>
      'No duty group abbreviations will be shown on the calendar';

  @override
  String get schedule => 'Schedule';

  @override
  String get app => 'General';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeDescription =>
      'Choose how the app should look. You can change this at any time in Settings.';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get sentryAnalytics => 'Analytics & Error Reporting';

  @override
  String get sentryAnalyticsDescription =>
      'Help improve the app by sending anonymous usage data and error reports';

  @override
  String get sentryReplay => 'Session Replay';

  @override
  String get sentryReplayDescription =>
      'Record user interactions to help debug issues (only when analytics is enabled)';

  @override
  String get privacy => 'Privacy';

  @override
  String get filteredBy => 'Filtered by';

  @override
  String get all => 'All';

  @override
  String get exportCalendar => 'Export Calendar';

  @override
  String get exportCalendarDescription =>
      'Export duty entries as an .ics calendar file';

  @override
  String get exportCalendarStartDate => 'Start date';

  @override
  String get exportCalendarEndDate => 'End date';

  @override
  String get exportCalendarIncludePartner => 'Include partner schedule';

  @override
  String get exportCalendarIncludePartnerDescription =>
      'Add the configured partner duty group to the export';

  @override
  String get exportCalendarPartnerSummaryPrefix => 'Partner';

  @override
  String get exportCalendarIncludeHolidays => 'Include holidays';

  @override
  String get exportCalendarIncludeHolidaysDescription =>
      'Add configured school holidays to the export';

  @override
  String get exportCalendarButton => 'Continue';

  @override
  String get exportCalendarActionShare => 'Share';

  @override
  String get exportCalendarActionShareSubtitle => 'Send via other apps';

  @override
  String get exportCalendarActionSave => 'Save to device';

  @override
  String get exportCalendarActionSaveSubtitle =>
      'Save to Downloads or a chosen folder';

  @override
  String get exportCalendarActionOpen => 'Open with calendar app';

  @override
  String get exportCalendarActionOpenSubtitle =>
      'Import directly into your calendar app';

  @override
  String get exportCalendarActionRowShare => 'Share';

  @override
  String get exportCalendarActionRowSave => 'Save';

  @override
  String get exportCalendarActionRowOpen => 'Open';

  @override
  String get exportCalendarBackButton => 'Back to configuration';

  @override
  String get exportCalendarShareSuccess => 'Calendar file shared';

  @override
  String get exportCalendarSaveSuccess => 'Calendar file saved';

  @override
  String get exportCalendarOpenSuccess => 'Calendar file opened';

  @override
  String get exportCalendarSaveCancelled => 'Save cancelled.';

  @override
  String get exportCalendarOpenNoApp => 'No app found to open this file.';

  @override
  String get exportCalendarOpenFailed => 'Could not open the file.';

  @override
  String get exportCalendarSubject => 'Duty schedule calendar export';

  @override
  String get exportCalendarShareText =>
      'Import this file into your calendar app.';

  @override
  String get exportCalendarInvalidRange =>
      'The start date must be before or equal to the end date.';

  @override
  String get exportCalendarNoActiveSchedule =>
      'Select your duty schedule before exporting.';

  @override
  String get exportCalendarPartnerUnavailable =>
      'Configure a partner schedule and duty group to enable this option.';

  @override
  String get exportCalendarHolidayUnavailable =>
      'Configure school holidays to enable this option.';

  @override
  String get exportCalendarEmpty =>
      'No calendar entries were found for the selected range.';

  @override
  String get exportCalendarError => 'Calendar export failed.';

  @override
  String exportCalendarSuccess(int entryCount) {
    return '$entryCount calendar entries exported';
  }

  @override
  String get shareApp => 'Share App';

  @override
  String get shareAppDescription => 'Recommend the app to colleagues';

  @override
  String shareAppMessage(String appStoreUrl, String playStoreUrl) {
    return 'Hey! 👋\n\nI found this great Duty Schedule App that makes viewing duty schedules super easy for police officers. You should check it out! 📱\n\nApp Store: $appStoreUrl\nPlay Store: $playStoreUrl\n\nHope you like it! 🚔';
  }

  @override
  String get shareAppSubject => 'Duty Schedule App Recommendation';

  @override
  String get shareAppError => 'Error sharing app';

  @override
  String get shareAppImageMessage =>
      'I found this great Duty Schedule App that makes viewing duty schedules super easy for police officers. You should check it out! 📱\n\nHope you like it! 🚔';

  @override
  String get other => 'Other';

  @override
  String get contact => 'Contact';

  @override
  String get contactDescription => 'Get in touch with us';

  @override
  String get genericValidationError => 'Invalid input';

  @override
  String get genericNotFoundError => 'Requested item was not found';

  @override
  String get genericConflictError => 'Conflict occurred';

  @override
  String get genericUnauthorizedError => 'You are not authorized';

  @override
  String get genericForbiddenError => 'Access is forbidden';

  @override
  String get genericNetworkError =>
      'Network error. Please check your connection.';

  @override
  String get genericTimeoutError => 'The operation timed out';

  @override
  String get genericStorageError => 'Storage error occurred';

  @override
  String get genericSerializationError => 'Data processing error';

  @override
  String get genericCancellationError => 'The operation was cancelled';

  @override
  String get genericUnknownError => 'An unknown error occurred';

  @override
  String get contribute => 'Contribute';

  @override
  String get contributeDescription => 'Help with app development';

  @override
  String get weLoveOss => 'We ❤️ Open Source';

  @override
  String get partnerSetupTitle => 'Partner Duty Schedule';

  @override
  String get partnerSetupDescription =>
      'Optional: Set up your partner\'s duty schedule to also display their duties.';

  @override
  String get skipPartnerSetup => 'Skip';

  @override
  String get selectPartnerConfig => 'Select Partner Duty Schedule';

  @override
  String get selectPartnerConfigMessage =>
      'Select your partner\'s duty schedule.';

  @override
  String get noPartnerConfig => 'No Partner Duty Schedule';

  @override
  String get noPartnerConfigDescription =>
      'No partner duty schedule will be displayed';

  @override
  String get selectPartnerDutyGroupMessage =>
      'Select your partner\'s duty group.';

  @override
  String scheduleUpdateNotification(
    String configName,
    String oldVersion,
    String newVersion,
  ) {
    return 'Duty schedule \"$configName\" has been updated (Version $oldVersion → $newVersion). All services will be regenerated.';
  }

  @override
  String multipleScheduleUpdatesNotification(String configNames) {
    return 'Multiple duty schedules have been updated: $configNames. All services will be regenerated.';
  }

  @override
  String get filterByPoliceAuthority => 'Filter by Authority';

  @override
  String get clearAll => 'Clear All';

  @override
  String get schoolHolidays => 'Holidays & Public Holidays';

  @override
  String get showSchoolHolidays => 'Show Holidays & Public Holidays';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoading => 'Error loading';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get federalState => 'Federal State';

  @override
  String get noFederalStateSelected => 'No federal state selected';

  @override
  String get refreshHolidayData => 'Refresh Holiday Data';

  @override
  String lastUpdated(String time) {
    return 'Last updated: $time';
  }

  @override
  String get notUpdatedYet => 'Not updated yet';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get selectFederalState => 'Select Federal State';

  @override
  String noHolidayDataForYear(int year) {
    return 'No holiday data available for year $year';
  }

  @override
  String get vacation => 'Vacation';

  @override
  String get publicHoliday => 'Public Holiday';

  @override
  String get movableHoliday => 'Movable';

  @override
  String get holidayTypesInfo => 'Shows school holidays and public holidays';

  @override
  String get addPersonalEntryTooltip => 'Add personal appointment or duty';

  @override
  String personalEntryQuickTitleHint(String date) {
    return 'Add appt. on $date';
  }

  @override
  String personalEntryQuickTitleSemanticLabel(String date) {
    return 'Add appointment on $date. Type a title, then Done.';
  }

  @override
  String get personalEntrySheetTitleNew => 'New entry';

  @override
  String get personalEntrySheetTitleEdit => 'Edit entry';

  @override
  String get personalEntryKindAppointment => 'Appointment';

  @override
  String get personalEntryKindDuty => 'Own duty';

  @override
  String get personalEntryDateLabel => 'Date';

  @override
  String get personalEntryTitleLabel => 'Title';

  @override
  String get personalEntryNotesLabel => 'Notes (optional)';

  @override
  String get personalEntryAllDayLabel => 'All day';

  @override
  String get personalEntryStartTime => 'Start';

  @override
  String get personalEntryEndTime => 'End';

  @override
  String get personalEntrySaved => 'Entry saved';

  @override
  String get personalEntryDeleted => 'Entry deleted';

  @override
  String get personalEntryValidationTitle => 'Please enter a title.';

  @override
  String get personalEntryValidationTimes => 'Please pick start and end time.';

  @override
  String get personalEntryValidationTimeRange => 'Invalid time of day.';

  @override
  String get personalEntryValidationEndAfterStart =>
      'End time must be after start time.';

  @override
  String get compactListShowOtherDutyGroupsTooltip => 'Show other duty groups';

  @override
  String get compactListHideOtherDutyGroupsTooltip => 'Hide other duty groups';
}
