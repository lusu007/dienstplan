import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/data/repositories/settings_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';

class GetSettingsUseCase {
  final SettingsRepository _settingsRepository;

  GetSettingsUseCase(this._settingsRepository);

  Future<Settings?> execute() async {
    try {
      AppLogger.i('GetSettingsUseCase: Executing get settings');

      // Use cache to avoid multiple database queries
      final settings = await SettingsCache.getSettings(() async {
        return await _settingsRepository.getSettings();
      });

      if (settings != null) {
        AppLogger.i('GetSettingsUseCase: Retrieved settings: $settings');
      } else {
        AppLogger.i('GetSettingsUseCase: No settings found, returning null');
      }

      return settings;
    } catch (e, stackTrace) {
      AppLogger.e('GetSettingsUseCase: Error getting settings', e, stackTrace);
      rethrow;
    }
  }
}
