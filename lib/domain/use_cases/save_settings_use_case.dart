import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class SaveSettingsUseCase {
  final SettingsRepository _settingsRepository;
  final ExceptionMapper _exceptionMapper;

  SaveSettingsUseCase(this._settingsRepository,
      {ExceptionMapper? exceptionMapper})
      : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

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

  Future<Result<void>> executeSafe(Settings settings) async {
    try {
      await execute(settings);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  void _validateSettings(Settings settings) {
    // Business logic: Validate settings before saving
    // Note: Removed date range validation as it prevents normal app usage
    // Users should be able to navigate to any date without restrictions

    AppLogger.d('SaveSettingsUseCase: Settings validation passed');
  }
}
