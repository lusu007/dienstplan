// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Duty Schedule';

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
  String get dutySchedule => 'Duty Schedule';

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
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get noDutySchedules => 'No duty schedules available';

  @override
  String get createNewDutySchedule => 'Create New Duty Schedule';

  @override
  String get dutyScheduleName => 'Duty Schedule Name';

  @override
  String get dutyScheduleDescription => 'Description';

  @override
  String get dutyScheduleStartDate => 'Start Date';

  @override
  String get dutyScheduleStartWeekDay => 'Start Week Day';

  @override
  String get dutyScheduleDays => 'Days';

  @override
  String get dutyScheduleDutyTypes => 'Duty Types';

  @override
  String get dutyScheduleRhythms => 'Rhythms';

  @override
  String get dutyScheduleGroups => 'Duty Groups';

  @override
  String get dutyTypeLabel => 'Label';

  @override
  String get dutyTypeStartTime => 'Start Time';

  @override
  String get dutyTypeEndTime => 'End Time';

  @override
  String get dutyTypeAllDay => 'All Day';

  @override
  String get rhythmLengthWeeks => 'Length in Weeks';

  @override
  String get rhythmPattern => 'Pattern';

  @override
  String get groupName => 'Name';

  @override
  String get groupRhythm => 'Rhythm';

  @override
  String get groupOffsetWeeks => 'Offset in Weeks';

  @override
  String get firstTimeSetup => 'First Time Setup';

  @override
  String get selectDefaultDutySchedule => 'Select Default Duty Schedule';

  @override
  String get continueButton => 'Continue';

  @override
  String get welcome => 'Hello! 👋';

  @override
  String get welcomeMessage =>
      'Let\'s set up your duty schedule. Therefore choose your duty schedule.';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsSaveError => 'Error saving settings';

  @override
  String get dutyScheduleSaved => 'Duty schedule saved';

  @override
  String get dutyScheduleSaveError => 'Error saving duty schedule';

  @override
  String get dutyScheduleDeleted => 'Duty schedule deleted';

  @override
  String get dutyScheduleDeleteError => 'Error deleting duty schedule';

  @override
  String get confirmDelete =>
      'Are you sure you want to delete this duty schedule?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get calendarFormat => 'Calendar Format';

  @override
  String get calendarFormatMonth => 'Month';

  @override
  String get calendarFormatTwoWeeks => 'Two Weeks';

  @override
  String get calendarFormatWeek => 'Week';

  @override
  String get resetData => 'Reset App';

  @override
  String get resetDataWarning => '⚠️ All data will be permanently deleted';

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
  String get allDay => 'All day';

  @override
  String get licenses => 'Licenses';

  @override
  String get footer => 'Info';

  @override
  String get copyright => 'Copyright';

  @override
  String get version => 'Version';

  @override
  String get author => 'Author';

  @override
  String get previousPeriod => 'Previous period';

  @override
  String get nextPeriod => 'Next period';

  @override
  String get today => 'Today';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'Dienstplan is a simple and efficient app for managing police duty schedules. It provides an overview of your shifts, supports offline access, and offers a duty group view optimized for police officers.';

  @override
  String get aboutDisclaimer =>
      'This app is not an official product of any authority or government agency. Dienstplan App is an unofficial tool developed independently and is not affiliated with the police or any government entity.';

  @override
  String get disclaimerLong =>
      'This application is not an official product of any government authority or agency. The Dienstplan App has been developed independently and is not officially affiliated with the police or any government entity.\n\nThe data used in this application originates from publicly accessible information materials of the police unions GdP (Gewerkschaft der Polizei) and DPolG (Deutsche Polizeigewerkschaft). Only publicly available information has been utilized. No internal or confidential agency data has been published or processed without authorization.\n\nThis application is intended for private use only and makes no claim to the completeness or accuracy of the information provided.';

  @override
  String get selectDutyGroup => 'Which duty group are you in?';

  @override
  String get selectDutyGroupMessage =>
      'Select your duty group so we can show you the right information.';

  @override
  String get back => 'Back';

  @override
  String get errorSavingDefaultConfig => 'Error saving default configuration';

  @override
  String get myDutyGroup => 'My Duty Group';

  @override
  String get selectMyDutyGroup => 'Select My Duty Group';

  @override
  String get myDutyGroupDescription =>
      'This duty group will be used for future functionality';

  @override
  String get noMyDutyGroup => 'No duty group selected';

  @override
  String get noDutyGroup => 'No duty group';

  @override
  String get noMyDutyGroupDescription =>
      'No duty group abbreviations will be shown on the calendar';

  @override
  String get general => 'General';

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
  String get darkModeNotAvailableYet => 'Dark mode is not implemented yet';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get myDutyGroupResetNotice =>
      'Your duty group was reset because it is not available in the new schedule.';

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
  String get shareApp => 'Share App';

  @override
  String get shareAppDescription => 'Recommend the app to colleagues';

  @override
  String get shareAppTitle => 'Duty Schedule App Recommendation';

  @override
  String shareAppMessage(String appStoreUrl, String playStoreUrl) {
    return 'Hey! 👋\n\nI found this great Duty Schedule App that makes viewing duty schedules super easy for police officers. You should check it out! 📱\n\nApp Store: $appStoreUrl\nPlay Store: $playStoreUrl\n\nHope you like it! 🚔';
  }

  @override
  String get shareAppSubject => 'Duty Schedule App Recommendation';

  @override
  String get shareAppError => 'Error sharing app';

  @override
  String get shareAppSuccess => 'Share sheet opened';

  @override
  String get shareAppFallback => 'App store link shared';

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
}
