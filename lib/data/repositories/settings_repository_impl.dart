import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/data/models/settings.dart' as data;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:table_calendar/table_calendar.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final DatabaseService _databaseService;

  SettingsRepositoryImpl(this._databaseService);

  @override
  Future<Settings?> getSettings() async {
    try {
      AppLogger.i('SettingsRepositoryImpl: Getting settings');
      final dataSettings = await _databaseService.loadSettings();

      if (dataSettings != null) {
        final domainSettings = _toDomainSettings(dataSettings);
        AppLogger.i(
            'SettingsRepositoryImpl: Retrieved settings: $domainSettings');
        return domainSettings;
      } else {
        AppLogger.i('SettingsRepositoryImpl: No settings found');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsRepositoryImpl: Error getting settings', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    try {
      AppLogger.i('SettingsRepositoryImpl: Saving settings: $settings');
      final dataSettings = _toDataSettings(settings);
      await _databaseService.saveSettings(dataSettings);
      AppLogger.i('SettingsRepositoryImpl: Settings saved successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsRepositoryImpl: Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      AppLogger.i('SettingsRepositoryImpl: Clearing settings');
      // Note: DatabaseService doesn't have a clearSettings method,
      // so we'll save empty/default settings instead
      final defaultSettings = data.Settings(
        calendarFormat: CalendarFormat.month,
        focusedDay: DateTime.now(),
        selectedDay: DateTime.now(),
        selectedDutyGroup: null,
        preferredDutyGroup: null,
      );
      await _databaseService.saveSettings(defaultSettings);
      AppLogger.i('SettingsRepositoryImpl: Settings cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
          'SettingsRepositoryImpl: Error clearing settings', e, stackTrace);
      rethrow;
    }
  }

  // Mapping helpers - direct mapping since both use CalendarFormat
  Settings _toDomainSettings(data.Settings s) {
    print(
        'DEBUG SettingsRepositoryImpl: Converting data settings to domain settings');
    print('  Data settings: $s');
    print('  activeConfigName: ${s.activeConfigName}');

    final domainSettings = Settings(
      calendarFormat: s.calendarFormat,
      focusedDay: s.focusedDay,
      selectedDay: s.selectedDay,
      selectedDutyGroup: s.selectedDutyGroup,
      preferredDutyGroup: s.preferredDutyGroup,
      activeConfigName: s.activeConfigName,
    );

    print('  Domain settings: $domainSettings');
    print('  Domain activeConfigName: ${domainSettings.activeConfigName}');

    return domainSettings;
  }

  data.Settings _toDataSettings(Settings s) {
    print(
        'DEBUG SettingsRepositoryImpl: Converting domain settings to data settings');
    print('  Domain settings: $s');
    print('  activeConfigName: ${s.activeConfigName}');

    final dataSettings = data.Settings(
      calendarFormat: s.calendarFormat,
      focusedDay: s.focusedDay,
      selectedDay: s.selectedDay,
      selectedDutyGroup: s.selectedDutyGroup,
      preferredDutyGroup: s.preferredDutyGroup,
      activeConfigName: s.activeConfigName,
    );

    print('  Data settings: $dataSettings');
    print('  Data activeConfigName: ${dataSettings.activeConfigName}');

    return dataSettings;
  }
}
