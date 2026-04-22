import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/domain/failures/result.dart';

class ResetSettingsUseCase {
  final SettingsRepository _settingsRepository;

  ResetSettingsUseCase(this._settingsRepository);

  Future<Result<void>> execute() async {
    AppLogger.d('ResetSettingsUseCase: Executing reset settings');
    final Result<void> clearResult = await _settingsRepository.clearSettings();
    if (clearResult.isFailure) {
      AppLogger.e(
        'ResetSettingsUseCase: Error resetting settings',
        clearResult.failure.cause ?? clearResult.failure,
        clearResult.failure.stackTrace,
      );
      return clearResult;
    }
    final Settings defaultSettings = _createDefaultSettings();
    final Result<void> saveResult = await _settingsRepository.saveSettings(
      defaultSettings,
    );
    if (saveResult.isFailure) {
      AppLogger.e(
        'ResetSettingsUseCase: Error resetting settings',
        saveResult.failure.cause ?? saveResult.failure,
        saveResult.failure.stackTrace,
      );
      return saveResult;
    }
    SettingsCache.updateCache(defaultSettings);
    AppLogger.d(
      'ResetSettingsUseCase: Settings reset to defaults successfully and cache updated',
    );
    return Result.success<void>(null);
  }

  Settings _createDefaultSettings() {
    return const Settings(
      selectedDutyGroup: null,
      myDutyGroup: null,
      themePreference: null,
      schoolHolidayStateCode: null,
      showSchoolHolidays: null,
    );
  }
}
