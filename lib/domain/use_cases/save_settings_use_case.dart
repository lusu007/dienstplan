import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/domain/use_cases/get_settings_use_case.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/domain/failures/result.dart';

class SaveSettingsUseCase {
  final SettingsRepository _settingsRepository;
  final GetSettingsUseCase _getSettingsUseCase;

  SaveSettingsUseCase(this._settingsRepository, this._getSettingsUseCase);

  Future<Result<void>> execute(Settings settings) async {
    AppLogger.d('SaveSettingsUseCase: Executing save settings: $settings');
    final Result<void> saveResult = await _settingsRepository.saveSettings(
      settings,
    );
    if (saveResult.isFailure) {
      AppLogger.e(
        'SaveSettingsUseCase: Error saving settings',
        saveResult.failure.cause ?? saveResult.failure,
        saveResult.failure.stackTrace,
      );
      return saveResult;
    }
    SettingsCache.updateCache(settings);
    AppLogger.d(
      'SaveSettingsUseCase: Settings saved successfully and cache updated',
    );
    return Result.success<void>(null);
  }

  /// Load current settings (via cache), merge with [build], then save.
  Future<Result<void>> upsert(
    Settings Function(Settings? current) build,
  ) async {
    final Result<Settings?> currentResult = await _getSettingsUseCase.execute();
    if (currentResult.isFailure) {
      return Result.createFailure<void>(currentResult.failure);
    }
    final Settings next = build(currentResult.valueIfSuccess);
    return execute(next);
  }

  /// Persists when a settings row exists. Success `true` if written, `false` if no row.
  Future<Result<bool>> patchExistingIfPresent(
    Settings Function(Settings current) patch,
  ) async {
    final Result<Settings?> currentResult = await _getSettingsUseCase.execute();
    if (currentResult.isFailure) {
      return Result.createFailure<bool>(currentResult.failure);
    }
    final Settings? current = currentResult.valueIfSuccess;
    if (current == null) {
      return Result.success<bool>(false);
    }
    final Result<void> saveResult = await execute(patch(current));
    if (saveResult.isFailure) {
      return Result.createFailure<bool>(saveResult.failure);
    }
    return Result.success<bool>(true);
  }
}
