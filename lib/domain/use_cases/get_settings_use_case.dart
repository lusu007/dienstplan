import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/domain/failures/result.dart';

class GetSettingsUseCase {
  final SettingsRepository _settingsRepository;

  GetSettingsUseCase(this._settingsRepository);

  Future<Result<Settings?>> execute() async {
    AppLogger.d('GetSettingsUseCase: Executing get settings');
    final Result<Settings?> result = await SettingsCache.getSettings(() async {
      return _settingsRepository.getSettings();
    });
    if (result.isFailure) {
      AppLogger.e(
        'GetSettingsUseCase: Error getting settings',
        result.failure.cause ?? result.failure,
        result.failure.stackTrace,
      );
      return result;
    }
    final Settings? settings = result.valueIfSuccess;
    if (settings != null) {
      AppLogger.d('GetSettingsUseCase: Retrieved settings: $settings');
    } else {
      AppLogger.d('GetSettingsUseCase: No settings found, returning null');
    }
    return result;
  }
}
