import 'package:table_calendar/table_calendar.dart';

class Settings {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final String? language;
  final String? selectedDutyGroup;
  final String? preferredDutyGroup;
  final String? activeConfigName;

  const Settings({
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    this.language,
    this.selectedDutyGroup,
    this.preferredDutyGroup,
    this.activeConfigName,
  });

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      calendarFormat: CalendarFormat.values.firstWhere(
        (format) => format.toString() == map['calendar_format'],
        orElse: () => CalendarFormat.month,
      ),
      focusedDay: DateTime.parse(map['focused_day'] as String),
      selectedDay: DateTime.parse(map['selected_day'] as String),
      language: map['language'] as String?,
      selectedDutyGroup: map['selected_duty_group'] as String?,
      preferredDutyGroup: map['preferred_duty_group'] as String?,
      activeConfigName: map['active_config_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calendar_format': calendarFormat.toString(),
      'focused_day': focusedDay.toIso8601String(),
      'selected_day': selectedDay.toIso8601String(),
      if (language != null) 'language': language,
      if (selectedDutyGroup != null) 'selected_duty_group': selectedDutyGroup,
      if (preferredDutyGroup != null)
        'preferred_duty_group': preferredDutyGroup,
      if (activeConfigName != null) 'active_config_name': activeConfigName,
    };
  }

  Settings copyWith({
    CalendarFormat? calendarFormat,
    DateTime? focusedDay,
    DateTime? selectedDay,
    String? language,
    String? selectedDutyGroup,
    String? preferredDutyGroup,
    String? activeConfigName,
  }) {
    return Settings(
      calendarFormat: calendarFormat ?? this.calendarFormat,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      language: language ?? this.language,
      selectedDutyGroup: selectedDutyGroup ?? this.selectedDutyGroup,
      preferredDutyGroup: preferredDutyGroup ?? this.preferredDutyGroup,
      activeConfigName: activeConfigName ?? this.activeConfigName,
    );
  }
}
