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
  String get generatingSchedules => 'Generating schedules...';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'Dienstplan is a simple and efficient app for managing police duty schedules. It provides an overview of your shifts, supports offline access, and offers a duty group view optimized for police officers.';
}
