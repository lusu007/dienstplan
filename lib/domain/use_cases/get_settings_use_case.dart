import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/data/repositories/settings_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';

class GetSettingsUseCase {
  final SettingsRepository _settingsRepository;

  GetSettingsUseCase(this._settingsRepository);

  Future<Settings?> execute() async {
    try {
      AppLogger.i('GetSettingsUseCase: Executing get settings');
      final settings = await _settingsRepository.getSettings();

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
