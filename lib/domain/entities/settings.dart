import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

enum ThemePreference { system, light, dark }

@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    String? language,
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
    bool? showOtherDutyGroupsInCompactList,
    DateTime? lastSchoolHolidayRefresh,
    int? holidayAccentColorValue,
  }) = _Settings;

  const Settings._();

  /// Defaults when creating the first persisted settings row.
  factory Settings.withDefaults({
    String? language,
    ThemePreference? themePreference,
    String? activeConfigName,
    String? myDutyGroup,
    int? holidayAccentColorValue,
  }) => Settings(
    language: language,
    themePreference: themePreference ?? ThemePreference.system,
    activeConfigName: activeConfigName,
    myDutyGroup: myDutyGroup,
    holidayAccentColorValue: holidayAccentColorValue,
    schoolHolidayStateCode: null,
    showSchoolHolidays: null,
    showOtherDutyGroupsInCompactList: false,
  );
}
