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
  });

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      calendarFormat: CalendarFormat.values.firstWhere(
        (format) => format.name == map['calendar_format'],
        orElse: () => CalendarFormat.month,
      ),
      language: map['language'] as String?,
      selectedDutyGroup: map['selected_duty_group'] as String?,
      myDutyGroup: map['my_duty_group'] as String?,
      activeConfigName: map['active_config_name'] as String?,
      themeMode: _parseThemeMode(map['theme_mode'] as String?),
      partnerConfigName: map['partner_config_name'] as String?,
      partnerDutyGroup: map['partner_duty_group'] as String?,
      partnerAccentColorValue: map['partner_accent_color'] as int?,
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
    );
  }

  @override
  String toString() {
    return 'Settings(calendarFormat: $calendarFormat, language: $language, selectedDutyGroup: $selectedDutyGroup, myDutyGroup: $myDutyGroup, activeConfigName: $activeConfigName, themeMode: ${themeMode?.name}, partnerConfigName: $partnerConfigName, partnerDutyGroup: $partnerDutyGroup, partnerAccentColorValue: $partnerAccentColorValue)';
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
        other.partnerAccentColorValue == partnerAccentColorValue;
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
        partnerAccentColorValue.hashCode;
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
