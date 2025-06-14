import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/models/duty_schedule_config.dart';
import '../mocks/schedule_config_service_test.mocks.dart';

/// Unit tests for the ScheduleConfigService class.
///
/// Tests initial state and default config persistence with mocks.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScheduleConfigService service;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    service = ScheduleConfigService(mockPrefs);
  });

  /// Group of tests for ScheduleConfigService state and behavior.
  group('ScheduleConfigService', () {
    /// Verifies the initial state of the service is empty/null as expected.
    test('initial state is correct', () {
      expect(service.configs, []);
      expect(service.defaultConfig, null);
      expect(service.hasDefaultConfig, false);
    });

    /// Checks that setDefaultConfig updates the default config and persists it.
    test('setDefaultConfig updates default config', () async {
      // Arrange
      final testConfig = DutyScheduleConfig(
        version: '1.0.0',
        meta: Meta(
          name: 'Test Config',
          description: 'Test Description',
          startDate: DateTime(2024, 1, 1),
          startWeekDay: 'Monday',
          days: ['Monday', 'Tuesday'],
        ),
        dutyGroups: [],
        rhythms: {},
        dutyTypes: {},
      );
      when(mockPrefs.setString('default_config', testConfig.meta.name))
          .thenAnswer((_) async => true);
      // Act
      await service.setDefaultConfig(testConfig);
      // Assert
      expect(service.defaultConfig, testConfig);
      verify(mockPrefs.setString('default_config', testConfig.meta.name))
          .called(1);
    });
  });
}
