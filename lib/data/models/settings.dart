import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

class Settings {
  final CalendarFormat calendarFormat;
  final String? language;
  final String? selectedDutyGroup;
  final String? myDutyGroup;
  final String? activeConfigName;
  final ThemeMode? themeMode;
  // Partner duty group
  final String? partnerConfigName;
  final String? partnerDutyGroup;
  final int? partnerAccentColorValue;
  final int? myAccentColorValue;
  // School holidays
  final String? schoolHolidayStateCode;
  final bool? showSchoolHolidays;
  final DateTime? lastSchoolHolidayRefresh;
  final int? holidayAccentColorValue;

  const Settings({
    required this.calendarFormat,
    this.language,
    this.selectedDutyGroup,
    this.myDutyGroup,
    this.activeConfigName,
    this.themeMode,
    this.partnerConfigName,
    this.partnerDutyGroup,
    this.partnerAccentColorValue,
    this.myAccentColorValue,
    this.schoolHolidayStateCode,
    this.showSchoolHolidays,
    this.lastSchoolHolidayRefresh,
    this.holidayAccentColorValue,
  });

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      calendarFormat: CalendarFormat.values.firstWhere(
        (format) => format.name == map['calendar_format'],
        orElse: () => CalendarFormat.month,
      ),
      language: _safeStringCast(map['language']),
      selectedDutyGroup: _safeStringCast(map['selected_duty_group']),
      myDutyGroup: _safeStringCast(map['my_duty_group']),
      activeConfigName: _safeStringCast(map['active_config_name']),
      themeMode: _parseThemeMode(_safeStringCast(map['theme_mode'])),
      partnerConfigName: _safeStringCast(map['partner_config_name']),
      partnerDutyGroup: _safeStringCast(map['partner_duty_group']),
      partnerAccentColorValue: _safeIntCast(map['partner_accent_color']),
      myAccentColorValue: _safeIntCast(map['my_accent_color']),
      schoolHolidayStateCode: _safeStringCast(map['school_holiday_state_code']),
      showSchoolHolidays: _safeBoolCast(map['show_school_holidays']),
      lastSchoolHolidayRefresh: _safeDateTimeCast(
        map['last_school_holiday_refresh'],
      ),
      holidayAccentColorValue: _safeIntCast(map['holiday_accent_color']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calendar_format': calendarFormat.name,
      if (language != null) 'language': language,
      if (selectedDutyGroup != null) 'selected_duty_group': selectedDutyGroup,
      if (myDutyGroup != null) 'my_duty_group': myDutyGroup,
      if (activeConfigName != null) 'active_config_name': activeConfigName,
      if (themeMode != null) 'theme_mode': themeMode!.name,
      if (partnerConfigName != null) 'partner_config_name': partnerConfigName,
      if (partnerDutyGroup != null) 'partner_duty_group': partnerDutyGroup,
      if (partnerAccentColorValue != null)
        'partner_accent_color': partnerAccentColorValue,
      if (myAccentColorValue != null) 'my_accent_color': myAccentColorValue,
      if (schoolHolidayStateCode != null)
        'school_holiday_state_code': schoolHolidayStateCode,
      if (showSchoolHolidays != null)
        'show_school_holidays': showSchoolHolidays == true ? 1 : 0,
      if (lastSchoolHolidayRefresh != null)
        'last_school_holiday_refresh': lastSchoolHolidayRefresh!
            .toIso8601String(),
      if (holidayAccentColorValue != null)
        'holiday_accent_color': holidayAccentColorValue,
    };
  }

  Settings copyWith({
    CalendarFormat? calendarFormat,
    String? language,
    String? selectedDutyGroup,
    String? myDutyGroup,
    String? activeConfigName,
    ThemeMode? themeMode,
    String? partnerConfigName,
    String? partnerDutyGroup,
    int? partnerAccentColorValue,
    int? myAccentColorValue,
    String? schoolHolidayStateCode,
    bool? showSchoolHolidays,
    DateTime? lastSchoolHolidayRefresh,
    int? holidayAccentColorValue,
  }) {
    return Settings(
      calendarFormat: calendarFormat ?? this.calendarFormat,
      language: language ?? this.language,
      selectedDutyGroup: selectedDutyGroup ?? this.selectedDutyGroup,
      myDutyGroup: myDutyGroup ?? this.myDutyGroup,
      activeConfigName: activeConfigName ?? this.activeConfigName,
      themeMode: themeMode ?? this.themeMode,
      partnerConfigName: partnerConfigName ?? this.partnerConfigName,
      partnerDutyGroup: partnerDutyGroup ?? this.partnerDutyGroup,
      partnerAccentColorValue:
          partnerAccentColorValue ?? this.partnerAccentColorValue,
      myAccentColorValue: myAccentColorValue ?? this.myAccentColorValue,
      schoolHolidayStateCode:
          schoolHolidayStateCode ?? this.schoolHolidayStateCode,
      showSchoolHolidays: showSchoolHolidays ?? this.showSchoolHolidays,
      lastSchoolHolidayRefresh:
          lastSchoolHolidayRefresh ?? this.lastSchoolHolidayRefresh,
      holidayAccentColorValue:
          holidayAccentColorValue ?? this.holidayAccentColorValue,
    );
  }

  @override
  String toString() {
    return 'Settings(calendarFormat: $calendarFormat, language: $language, selectedDutyGroup: $selectedDutyGroup, myDutyGroup: $myDutyGroup, activeConfigName: $activeConfigName, themeMode: ${themeMode?.name}, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue, myAccentColorValue: $myAccentColorValue, schoolHolidayStateCode: $schoolHolidayStateCode, showSchoolHolidays: $showSchoolHolidays, lastSchoolHolidayRefresh: $lastSchoolHolidayRefresh, holidayAccentColorValue: $holidayAccentColorValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.calendarFormat == calendarFormat &&
        other.language == language &&
        other.selectedDutyGroup == selectedDutyGroup &&
        other.myDutyGroup == myDutyGroup &&
        other.activeConfigName == activeConfigName &&
        other.themeMode == themeMode &&
        other.partnerConfigName == partnerConfigName &&
        other.partnerDutyGroup == partnerDutyGroup &&
        other.partnerAccentColorValue == partnerAccentColorValue &&
        other.myAccentColorValue == myAccentColorValue &&
        other.schoolHolidayStateCode == schoolHolidayStateCode &&
        other.showSchoolHolidays == showSchoolHolidays &&
        other.holidayAccentColorValue == holidayAccentColorValue;
  }

  @override
  int get hashCode {
    return calendarFormat.hashCode ^
        language.hashCode ^
        selectedDutyGroup.hashCode ^
        myDutyGroup.hashCode ^
        activeConfigName.hashCode ^
        themeMode.hashCode ^
        partnerConfigName.hashCode ^
        partnerDutyGroup.hashCode ^
        partnerAccentColorValue.hashCode ^
        myAccentColorValue.hashCode ^
        schoolHolidayStateCode.hashCode ^
        showSchoolHolidays.hashCode ^
        holidayAccentColorValue.hashCode;
  }

  static String? _safeStringCast(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static int? _safeIntCast(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  static bool? _safeBoolCast(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      if (value == '1' || value.toLowerCase() == 'true') return true;
      if (value == '0' || value.toLowerCase() == 'false') return false;
    }
    return null;
  }

  static DateTime? _safeDateTimeCast(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static ThemeMode? _parseThemeMode(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return null;
    }
  }
}
