import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:table_calendar/table_calendar.dart';

class ResetSettingsUseCase {
  final SettingsRepository _settingsRepository;

  ResetSettingsUseCase(this._settingsRepository);

  Future<void> execute() async {
    try {
      AppLogger.i('ResetSettingsUseCase: Executing reset settings');

      // Clear existing settings
      await _settingsRepository.clearSettings();

      // Create default settings
      final defaultSettings = _createDefaultSettings();

      // Save default settings
      await _settingsRepository.saveSettings(defaultSettings);

      AppLogger.i(
          'ResetSettingsUseCase: Settings reset to defaults successfully');
    } catch (e, stackTrace) {
      AppLogger.e(
          'ResetSettingsUseCase: Error resetting settings', e, stackTrace);
      rethrow;
    }
  }

  Settings _createDefaultSettings() {
    // Business logic: Create default settings
    final now = DateTime.now();

    return Settings(
      calendarFormat: CalendarFormat.month,
      focusedDay: now,
      selectedDay: now,
      selectedDutyGroup: null,
      preferredDutyGroup: null,
    );
  }
}
