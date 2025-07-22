import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/data/repositories/settings_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';

class SaveSettingsUseCase {
  final SettingsRepository _settingsRepository;

  SaveSettingsUseCase(this._settingsRepository);

  Future<void> execute(Settings settings) async {
    try {
      AppLogger.i('SaveSettingsUseCase: Executing save settings: $settings');

      // Business logic: Validate settings
      _validateSettings(settings);

      await _settingsRepository.saveSettings(settings);

      // Update cache with new settings
      SettingsCache.updateCache(settings);

      AppLogger.i(
          'SaveSettingsUseCase: Settings saved successfully and cache updated');
    } catch (e, stackTrace) {
      AppLogger.e('SaveSettingsUseCase: Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  void _validateSettings(Settings settings) {
    // Business logic: Validate settings before saving

    // Validate that focused day and selected day are not in the distant past/future
    final now = DateTime.now();
    const maxDateDifference = Duration(days: 365 * 10); // 10 years

    if (settings.focusedDay.difference(now).abs() > maxDateDifference) {
      throw ArgumentError('Focused day is too far from current date');
    }

    if (settings.selectedDay.difference(now).abs() > maxDateDifference) {
      throw ArgumentError('Selected day is too far from current date');
    }

    AppLogger.d('SaveSettingsUseCase: Settings validation passed');
  }
}
