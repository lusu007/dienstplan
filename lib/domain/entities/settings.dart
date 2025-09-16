import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:table_calendar/table_calendar.dart';

part 'settings.freezed.dart';

enum ThemePreference { system, light, dark }

@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    required CalendarFormat calendarFormat,
    String? language,
    String? selectedDutyGroup,
    String? myDutyGroup,
    String? activeConfigName,
    ThemePreference? themePreference,
    // Partner duty group feature
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    // My accent color feature
    int? myAccentColorValue,
    // School holidays feature
    String? schoolHolidayStateCode,
    bool? showSchoolHolidays,
    DateTime? lastSchoolHolidayRefresh,
  }) = _Settings;

  const Settings._();
}
