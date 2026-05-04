import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleIndex', () {
    test('hasDataForRange is false after clear and for unknown config', () {
      final ScheduleIndex index = ScheduleIndex.withSchedules(<Schedule>[
        Schedule(
          date: DateTime(2026, 5, 4),
          service: 'Frueh',
          dutyGroupId: 'a',
          dutyTypeId: 'F',
          dutyGroupName: 'A',
          configName: 'main',
        ),
      ]);

      expect(
        index.hasDataForRange(
          'other',
          DateTime(2026, 5, 4),
          DateTime(2026, 5, 4),
        ),
        isFalse,
      );

      index.clear();

      expect(
        index.hasDataForRange(
          'main',
          DateTime(2026, 5, 4),
          DateTime(2026, 5, 4),
        ),
        isFalse,
      );
    });
  });
}
