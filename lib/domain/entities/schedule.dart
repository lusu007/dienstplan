import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';

part 'schedule.freezed.dart';

@freezed
abstract class Schedule with _$Schedule {
  const factory Schedule({
    required DateTime date,
    required String service,
    required String dutyGroupId,
    required String dutyTypeId,
    required String dutyGroupName,
    required String configName,
    @Default(false) bool isAllDay,
    @Default(false) bool isUserDefined,
    String? personalEntryId,
    PersonalCalendarEntryKind? personalEntryKind,
    int? startMinutesFromMidnight,
    int? endMinutesFromMidnight,
    String? personalNotes,
    int? personalCreatedAtMs,
    int? personalUpdatedAtMs,
  }) = _Schedule;

  const Schedule._();
}
