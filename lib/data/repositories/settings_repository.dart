import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/domain/entities/settings.dart' as domain;
import 'package:dienstplan/data/models/settings.dart' as data;
import 'package:dienstplan/core/utils/logger.dart';

class SettingsRepository {
  final DatabaseService _databaseService;

  SettingsRepository(this._databaseService);

  Future<domain.Settings?> getSettings() async {
    try {
      AppLogger.i('SettingsRepository: Getting settings');
      final dataSettings = await _databaseService.loadSettings();
      if (dataSettings == null) {
        AppLogger.i('SettingsRepository: No settings found');
        return null;
      }
      AppLogger.i('SettingsRepository: Retrieved settings');
      return _toDomainSettings(dataSettings);
    } catch (e, stackTrace) {
      AppLogger.e('SettingsRepository: Error getting settings', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveSettings(domain.Settings settings) async {
    try {
      AppLogger.i('SettingsRepository: Saving settings');
      final dataSettings = _toDataSettings(settings);
      await _databaseService.saveSettings(dataSettings);
      AppLogger.i('SettingsRepository: Successfully saved settings');
    } catch (e, stackTrace) {
      AppLogger.e('SettingsRepository: Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearSettings() async {
    try {
      AppLogger.i('SettingsRepository: Clearing settings');
      await _databaseService.clearSettings();
      AppLogger.i('SettingsRepository: Successfully cleared settings');
    } catch (e, stackTrace) {
      AppLogger.e('SettingsRepository: Error clearing settings', e, stackTrace);
      rethrow;
    }
  }

  domain.Settings _toDomainSettings(data.Settings s) {
    return domain.Settings(
      calendarFormat: s.calendarFormat,
      focusedDay: s.focusedDay,
      selectedDay: s.selectedDay,
      selectedDutyGroup: s.selectedDutyGroup,
      myDutyGroup: s.myDutyGroup,
      activeConfigName: s.activeConfigName,
    );
  }

  data.Settings _toDataSettings(domain.Settings s) {
    return data.Settings(
      calendarFormat: s.calendarFormat,
      focusedDay: s.focusedDay,
      selectedDay: s.selectedDay,
      selectedDutyGroup: s.selectedDutyGroup,
      myDutyGroup: s.myDutyGroup,
      activeConfigName: s.activeConfigName,
    );
  }
}
