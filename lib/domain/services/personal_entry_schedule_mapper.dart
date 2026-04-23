import 'package:dienstplan/core/constants/personal_calendar_constants.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/entities/schedule.dart';

/// Maps persisted personal entries to [Schedule] rows for the shared UI pipeline.
class PersonalEntryScheduleMapper {
  static Schedule toSchedule(PersonalCalendarEntry entry) {
    final String dutyTypeId = entry.id;
    return Schedule(
      date: entry.date,
      service: entry.title,
      dutyGroupId: '$kPersonalDutyGroupIdPrefix${entry.id}',
      dutyTypeId: dutyTypeId,
      dutyGroupName: entry.dutyGroupName,
      configName: kPersonalScheduleConfigName,
      isAllDay: entry.isAllDay,
      isUserDefined: true,
      personalEntryId: entry.id,
      personalEntryKind: entry.kind,
      startMinutesFromMidnight: entry.startMinutesFromMidnight,
      endMinutesFromMidnight: entry.endMinutesFromMidnight,
      personalNotes: entry.notes,
      personalCreatedAtMs: entry.createdAtMs,
      personalUpdatedAtMs: entry.updatedAtMs,
    );
  }

  /// Rebuilds a domain entry from a merged [Schedule] row (e.g. when opening the editor).
  static PersonalCalendarEntry entryFromSchedule(Schedule schedule) {
    final String id = schedule.personalEntryId ?? schedule.dutyTypeId;
    final PersonalCalendarEntryKind kind =
        schedule.personalEntryKind ?? PersonalCalendarEntryKind.appointment;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    return PersonalCalendarEntry(
      id: id,
      kind: kind,
      title: schedule.service,
      notes: schedule.personalNotes,
      date: schedule.date,
      isAllDay: schedule.isAllDay,
      startMinutesFromMidnight: schedule.startMinutesFromMidnight,
      endMinutesFromMidnight: schedule.endMinutesFromMidnight,
      dutyGroupName: schedule.dutyGroupName,
      createdAtMs: schedule.personalCreatedAtMs ?? nowMs,
      updatedAtMs: schedule.personalUpdatedAtMs ?? nowMs,
    );
  }
}
