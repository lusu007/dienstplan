import 'package:dienstplan/data/services/database_service.dart';
import 'package:dienstplan/domain/entities/settings.dart' as domain;
import 'package:dienstplan/data/models/settings.dart' as data;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';

class SettingsRepository {
  final DatabaseService _databaseService;
  final ExceptionMapper _exceptionMapper;

  SettingsRepository(this._databaseService, {ExceptionMapper? exceptionMapper})
      : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

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

  Future<Result<domain.Settings?>> getSettingsSafe() async {
    try {
      final settings = await getSettings();
      return Result.success<domain.Settings?>(settings);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<domain.Settings?>(failure);
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

  Future<Result<void>> saveSettingsSafe(domain.Settings settings) async {
    try {
      await saveSettings(settings);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
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

  Future<Result<void>> clearSettingsSafe() async {
    try {
      await clearSettings();
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  domain.Settings _toDomainSettings(data.Settings s) {
    return domain.Settings(
      calendarFormat: s.calendarFormat,
      language: s.language,
      selectedDutyGroup: s.selectedDutyGroup,
      myDutyGroup: s.myDutyGroup,
      activeConfigName: s.activeConfigName,
    );
  }

  data.Settings _toDataSettings(domain.Settings s) {
    return data.Settings(
      calendarFormat: s.calendarFormat,
      language: s.language,
      selectedDutyGroup: s.selectedDutyGroup,
      myDutyGroup: s.myDutyGroup,
      activeConfigName: s.activeConfigName,
    );
  }
}
