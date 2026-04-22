import 'package:freezed_annotation/freezed_annotation.dart';

part 'personal_calendar_entry.freezed.dart';

enum PersonalCalendarEntryKind {
  appointment,
  personalDuty;

  String toStorage() {
    switch (this) {
      case PersonalCalendarEntryKind.appointment:
        return 'appointment';
      case PersonalCalendarEntryKind.personalDuty:
        return 'personal_duty';
    }
  }

  static PersonalCalendarEntryKind fromStorage(String value) {
    switch (value) {
      case 'personal_duty':
        return PersonalCalendarEntryKind.personalDuty;
      case 'appointment':
      default:
        return PersonalCalendarEntryKind.appointment;
    }
  }
}

@freezed
abstract class PersonalCalendarEntry with _$PersonalCalendarEntry {
  const factory PersonalCalendarEntry({
    required String id,
    required PersonalCalendarEntryKind kind,
    required String title,
    String? notes,
    required DateTime date,
    required bool isAllDay,
    int? startMinutesFromMidnight,
    int? endMinutesFromMidnight,
    required String dutyGroupName,
    required int createdAtMs,
    required int updatedAtMs,
  }) = _PersonalCalendarEntry;
}
