import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/models/duty_schedule_config.dart';
import '../mocks/schedule_provider_test.mocks.dart';

/// Unit tests for the ScheduleProvider class.
///
/// Tests initial state, date selection, and config switching with mocks.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late TestableScheduleProvider provider;
  late MockScheduleConfigService mockConfigService;

  setUp(() {
    mockConfigService = MockScheduleConfigService();
    provider = TestableScheduleProvider(mockConfigService);
  });

  /// Group of tests for ScheduleProvider state and behavior.
  group('ScheduleProvider', () {
    /// Verifies the initial state of the provider is empty/null as expected.
    test('initial state is correct', () {
      expect(provider.configs, []);
      expect(provider.activeConfig, null);
      expect(provider.dutyGroups, []);
      expect(provider.selectedDutyGroup, null);
      expect(provider.selectedDay, null);
      expect(provider.schedules, []);
    });

    /// Checks that setSelectedDate updates the selectedDay property.
    test('setSelectedDate updates selectedDay', () async {
      final testDate = DateTime(2024, 1, 1);
      await provider.setSelectedDate(testDate);
      expect(provider.selectedDay, testDate);
    });

    /// Checks that setActiveConfig updates activeConfig and triggers schedule generation.
    test('setActiveConfig updates activeConfig and generates schedules',
        () async {
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
      when(mockConfigService.generateSchedulesForConfig(any))
          .thenAnswer((_) async => []);
      await provider.setActiveConfig(testConfig);
      expect(provider.activeConfig, testConfig);
      verify(mockConfigService.generateSchedulesForConfig(testConfig))
          .called(1);
    });
  });
}

/// Testable subclass of ScheduleProvider that overrides DB and settings methods for isolation in tests.
class TestableScheduleProvider extends ScheduleProvider {
  TestableScheduleProvider(ScheduleConfigService configService)
      : super(configService);

  @override
  Future<void> loadSchedules() async {
    // Do nothing
  }

  @override
  Future<void> saveSchedules() async {
    // Do nothing
  }
}
