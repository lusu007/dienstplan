import 'package:table_calendar/table_calendar.dart';

class Settings {
  final CalendarFormat calendarFormat;
  final String? language;
  final String? selectedDutyGroup;
  final String? myDutyGroup;
  final String? activeConfigName;

  const Settings({
    required this.calendarFormat,
    this.language,
    this.selectedDutyGroup,
    this.myDutyGroup,
    this.activeConfigName,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calendar_format': calendarFormat.name,
      if (language != null) 'language': language,
      if (selectedDutyGroup != null) 'selected_duty_group': selectedDutyGroup,
      if (myDutyGroup != null) 'my_duty_group': myDutyGroup,
      if (activeConfigName != null) 'active_config_name': activeConfigName,
    };
  }

  Settings copyWith({
    CalendarFormat? calendarFormat,
    String? language,
    String? selectedDutyGroup,
    String? myDutyGroup,
    String? activeConfigName,
  }) {
    return Settings(
      calendarFormat: calendarFormat ?? this.calendarFormat,
      language: language ?? this.language,
      selectedDutyGroup: selectedDutyGroup ?? this.selectedDutyGroup,
      myDutyGroup: myDutyGroup ?? this.myDutyGroup,
      activeConfigName: activeConfigName ?? this.activeConfigName,
    );
  }

  @override
  String toString() {
    return 'Settings(calendarFormat: $calendarFormat, language: $language, selectedDutyGroup: $selectedDutyGroup, myDutyGroup: $myDutyGroup, activeConfigName: $activeConfigName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.calendarFormat == calendarFormat &&
        other.language == language &&
        other.selectedDutyGroup == selectedDutyGroup &&
        other.myDutyGroup == myDutyGroup &&
        other.activeConfigName == activeConfigName;
  }

  @override
  int get hashCode {
    return calendarFormat.hashCode ^
        language.hashCode ^
        selectedDutyGroup.hashCode ^
        myDutyGroup.hashCode ^
        activeConfigName.hashCode;
  }
}
