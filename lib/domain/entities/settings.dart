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
  }) = _Settings;

  const Settings._();
}
