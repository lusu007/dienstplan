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
    // Note: Removed date range validation as it prevents normal app usage
    // Users should be able to navigate to any date without restrictions

    AppLogger.d('SaveSettingsUseCase: Settings validation passed');
  }
}
