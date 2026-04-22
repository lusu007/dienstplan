import 'package:flutter_test/flutter_test.dart';
import 'package:dienstplan/core/constants/personal_calendar_constants.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/domain/services/personal_entry_schedule_mapper.dart';

void main() {
  group('PersonalEntryScheduleMapper', () {
    test('toSchedule maps fields and flags', () {
      final PersonalCalendarEntry entry = PersonalCalendarEntry(
        id: 'id-1',
        kind: PersonalCalendarEntryKind.appointment,
        title: 'Team meeting',
        notes: 'Bring docs',
        date: DateTime.utc(2026, 4, 10),
        isAllDay: false,
        startMinutesFromMidnight: 9 * 60 + 30,
        endMinutesFromMidnight: 10 * 60 + 15,
        dutyGroupName: 'Alpha',
        createdAtMs: 100,
        updatedAtMs: 200,
      );
      final Schedule s = PersonalEntryScheduleMapper.toSchedule(entry);
      expect(s.configName, kPersonalScheduleConfigName);
      expect(s.isUserDefined, isTrue);
      expect(s.personalEntryId, 'id-1');
      expect(s.dutyTypeId, 'id-1');
      expect(s.service, 'Team meeting');
      expect(s.dutyGroupName, 'Alpha');
      expect(s.dutyGroupId, '${kPersonalDutyGroupIdPrefix}id-1');
      expect(s.isAllDay, isFalse);
      expect(s.startMinutesFromMidnight, 9 * 60 + 30);
      expect(s.endMinutesFromMidnight, 10 * 60 + 15);
      expect(s.personalNotes, 'Bring docs');
      expect(s.personalCreatedAtMs, 100);
      expect(s.personalUpdatedAtMs, 200);
      expect(s.personalEntryKind, PersonalCalendarEntryKind.appointment);
    });

    test('entryFromSchedule round-trips core fields', () {
      final Schedule s = Schedule(
        date: DateTime.utc(2026, 5, 1),
        service: 'Dienst',
        dutyGroupId: '${kPersonalDutyGroupIdPrefix}x',
        dutyTypeId: 'x',
        dutyGroupName: 'Privat',
        configName: kPersonalScheduleConfigName,
        isAllDay: true,
        isUserDefined: true,
        personalEntryId: 'x',
        personalEntryKind: PersonalCalendarEntryKind.personalDuty,
        personalNotes: 'n',
        personalCreatedAtMs: 1,
        personalUpdatedAtMs: 2,
      );
      final PersonalCalendarEntry e = PersonalEntryScheduleMapper.entryFromSchedule(s);
      expect(e.id, 'x');
      expect(e.title, 'Dienst');
      expect(e.kind, PersonalCalendarEntryKind.personalDuty);
      expect(e.notes, 'n');
      expect(e.dutyGroupName, 'Privat');
      expect(e.createdAtMs, 1);
      expect(e.updatedAtMs, 2);
    });
  });
}
