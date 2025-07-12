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
  String get welcome => 'Welcome';

  @override
  String get welcomeMessage => 'Please select a default duty schedule.';

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
  String get resetData => 'Reset Data';

  @override
  String get resetDataConfirmation =>
      'Are you sure you want to reset all data? This cannot be undone.';

  @override
  String get resetDataSuccess => 'Data has been reset';

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
  String get selectDutyGroup => 'Select Your Duty Group';

  @override
  String get selectDutyGroupMessage => 'Choose the duty group you belong to:';

  @override
  String get back => 'Back';

  @override
  String get errorSavingDefaultConfig => 'Error saving default configuration';

  @override
  String get preferredDutyGroup => 'Preferred Duty Group';

  @override
  String get selectPreferredDutyGroup => 'Select Preferred Duty Group';

  @override
  String get preferredDutyGroupDescription =>
      'This duty group will be used for future functionality';

  @override
  String get noPreferredDutyGroup => 'No preferred duty group set';

  @override
  String get noPreferredDutyGroupDescription =>
      'No duty group abbreviations will be shown on the calendar';

  @override
  String get general => 'General';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get preferredDutyGroupResetNotice =>
      'Preferred duty group was reset because it is not available in the new schedule.';

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
}
