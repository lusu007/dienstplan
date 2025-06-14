import 'package:flutter_test/flutter_test.dart';
import 'package:dienstplan/models/schedule.dart';

/// Unit tests for the Schedule model.
///
/// Tests serialization and deserialization from/to map.
void main() {
  /// Group of tests for Schedule model serialization.
  group('Schedule', () {
    /// Verifies that a Schedule can be created from a map.
    test('creates Schedule from map', () {
      // Arrange
      final map = {
        'date': '2024-01-01T00:00:00.000Z',
        'service': 'test_service',
        'duty_group_id': 'group1',
        'duty_type_id': 'type1',
        'duty_group_name': 'Test Group',
        'config_name': 'test_config',
        'is_all_day': 1,
      };

      // Act
      final schedule = Schedule.fromMap(map);

      // Assert
      expect(schedule.date, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(schedule.service, 'test_service');
      expect(schedule.dutyGroupId, 'group1');
      expect(schedule.dutyTypeId, 'type1');
      expect(schedule.dutyGroupName, 'Test Group');
      expect(schedule.configName, 'test_config');
      expect(schedule.isAllDay, true);
    });

    /// Verifies that a Schedule can be converted to a map.
    test('converts Schedule to map', () {
      // Arrange
      final schedule = Schedule(
        date: DateTime.parse('2024-01-01T00:00:00.000Z'),
        service: 'test_service',
        dutyGroupId: 'group1',
        dutyTypeId: 'type1',
        dutyGroupName: 'Test Group',
        configName: 'test_config',
        isAllDay: true,
      );

      // Act
      final map = schedule.toMap();

      // Assert
      expect(map['date'], '2024-01-01T00:00:00.000Z');
      expect(map['service'], 'test_service');
      expect(map['duty_group_id'], 'group1');
      expect(map['duty_type_id'], 'type1');
      expect(map['duty_group_name'], 'Test Group');
      expect(map['config_name'], 'test_config');
      expect(map['is_all_day'], 1);
    });
  });
}
