import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_schedule_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDayScheduleLookup', () {
    test(
      'returns day-specific duty and personal schedules without callers scanning all schedules',
      () {
        final DateTime targetDay = DateTime(2026, 5, 4);
        final CalendarDayScheduleLookup lookup =
            CalendarDayScheduleLookup(<Schedule>[
              Schedule(
                date: targetDay,
                service: 'Frueh',
                dutyGroupId: 'a',
                dutyTypeId: 'F',
                dutyGroupName: 'A',
                configName: 'main',
              ),
              Schedule(
                date: targetDay,
                service: 'Spaet',
                dutyGroupId: 'b',
                dutyTypeId: 'S',
                dutyGroupName: 'B',
                configName: 'main',
              ),
              Schedule(
                date: targetDay,
                service: 'Partner',
                dutyGroupId: 'p',
                dutyTypeId: 'P',
                dutyGroupName: 'P',
                configName: 'partner',
              ),
              Schedule(
                date: targetDay,
                service: 'Later appointment',
                dutyGroupId: 'personal',
                dutyTypeId: 'personal',
                dutyGroupName: 'Personal',
                configName: 'personal',
                isUserDefined: true,
                personalEntryId: 'later',
                startMinutesFromMidnight: 720,
              ),
              Schedule(
                date: targetDay,
                service: 'Earlier appointment',
                dutyGroupId: 'personal',
                dutyTypeId: 'personal',
                dutyGroupName: 'Personal',
                configName: 'personal',
                isUserDefined: true,
                personalEntryId: 'earlier',
                startMinutesFromMidnight: 480,
              ),
              Schedule(
                date: DateTime(2026, 5, 5),
                service: 'Wrong day',
                dutyGroupId: 'a',
                dutyTypeId: 'N',
                dutyGroupName: 'A',
                configName: 'main',
              ),
            ]);

        expect(
          lookup
              .firstOfficialSchedule(
                day: targetDay,
                configName: 'main',
                dutyGroupName: 'B',
              )
              ?.dutyTypeId,
          'S',
        );
        expect(
          lookup
              .firstOfficialSchedule(
                day: targetDay,
                configName: 'partner',
                dutyGroupName: 'P',
              )
              ?.dutyTypeId,
          'P',
        );
        expect(
          lookup.personalSchedulesForDay(targetDay).map((s) => s.service),
          <String>['Earlier appointment', 'Later appointment'],
        );
        expect(lookup.signatureForMonth(DateTime(2026, 5, 1)), isNonZero);
      },
    );

    test(
      'signatureForMonth changes when a user-defined entry time changes',
      () {
        final DateTime day = DateTime(2026, 6, 10);
        Schedule personal({required int startMinutes}) {
          return Schedule(
            date: day,
            service: 'Appt',
            dutyGroupId: 'personal',
            dutyTypeId: 'personal',
            dutyGroupName: 'Personal',
            configName: 'personal',
            isUserDefined: true,
            personalEntryId: 'same-id',
            startMinutesFromMidnight: startMinutes,
          );
        }

        final int earlier = CalendarDayScheduleLookup(<Schedule>[
          personal(startMinutes: 480),
        ]).signatureForMonth(day);
        final int later = CalendarDayScheduleLookup(<Schedule>[
          personal(startMinutes: 720),
        ]).signatureForMonth(day);
        expect(earlier, isNot(later));
      },
    );
  });
}
