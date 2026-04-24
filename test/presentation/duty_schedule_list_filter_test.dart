import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('filterDutySchedulesForDisplay', () {
    final DateTime day = DateTime.utc(2026, 4, 24);

    Schedule schedule({
      required String service,
      required String configName,
      required String dutyGroupName,
      bool isUserDefined = false,
    }) {
      return Schedule(
        date: day,
        service: service,
        dutyGroupId: dutyGroupName,
        dutyTypeId: service,
        dutyGroupName: dutyGroupName,
        configName: configName,
        isUserDefined: isUserDefined,
      );
    }

    test(
      'keeps all official schedules in non-compact lists without active config',
      () {
        final List<Schedule> schedules = <Schedule>[
          schedule(service: 'Own early', configName: 'A', dutyGroupName: 'B'),
          schedule(service: 'Other late', configName: 'C', dutyGroupName: 'D'),
        ];

        final List<Schedule> filtered = filterDutySchedulesForDisplay(
          schedules: schedules,
          visualStyle: DutyListVisualStyle.glass,
          activeConfigName: null,
          myDutyGroupName: 'B',
          partnerConfigName: null,
          partnerDutyGroupName: null,
          isPartnerVisible: false,
          showOtherDutyGroupsInCompactList: false,
        );

        expect(filtered.map((Schedule s) => s.service), <String>[
          'Own early',
          'Other late',
        ]);
      },
    );

    test('filters non-compact official schedules by active config only', () {
      final Schedule userEntry = schedule(
        service: 'Private',
        configName: '',
        dutyGroupName: '',
        isUserDefined: true,
      );
      final List<Schedule> schedules = <Schedule>[
        userEntry,
        schedule(service: 'Own early', configName: 'A', dutyGroupName: 'B'),
        schedule(service: 'Other active', configName: 'A', dutyGroupName: 'C'),
        schedule(service: 'Other config', configName: 'C', dutyGroupName: 'D'),
      ];

      final List<Schedule> filtered = filterDutySchedulesForDisplay(
        schedules: schedules,
        visualStyle: DutyListVisualStyle.glass,
        activeConfigName: 'A',
        myDutyGroupName: 'B',
        partnerConfigName: null,
        partnerDutyGroupName: null,
        isPartnerVisible: false,
        showOtherDutyGroupsInCompactList: false,
      );

      expect(filtered.map((Schedule s) => s.service), <String>[
        'Private',
        'Own early',
        'Other active',
      ]);
    });
  });
}
