import 'package:dienstplan/data/daos/settings_dao.dart';
import 'package:dienstplan/domain/entities/settings.dart' as domain;
import 'package:dienstplan/data/models/settings.dart' as data;
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart'
    as domain_repo;
import 'package:flutter/material.dart';

class SettingsRepositoryImpl implements domain_repo.SettingsRepository {
  final SettingsDao _settingsDao;
  final ExceptionMapper _exceptionMapper;

  SettingsRepositoryImpl(this._settingsDao, {ExceptionMapper? exceptionMapper})
      : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

  @override
  Future<domain.Settings?> getSettings() async {
    try {
      AppLogger.i('SettingsRepository: Getting settings');
      final dataSettings = await _settingsDao.load();
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

  @override
  Future<Result<domain.Settings?>> getSettingsSafe() async {
    try {
      final settings = await getSettings();
      return Result.success<domain.Settings?>(settings);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<domain.Settings?>(failure);
    }
  }

  @override
  Future<void> saveSettings(domain.Settings settings) async {
    try {
      AppLogger.i('SettingsRepository: Saving settings');
      final dataSettings = _toDataSettings(settings);
      await _settingsDao.save(dataSettings);
      AppLogger.i('SettingsRepository: Successfully saved settings');
    } catch (e, stackTrace) {
      AppLogger.e('SettingsRepository: Error saving settings', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Result<void>> saveSettingsSafe(domain.Settings settings) async {
    try {
      await saveSettings(settings);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      final Failure failure = _exceptionMapper.mapToFailure(e, stackTrace);
      return Result.createFailure<void>(failure);
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      AppLogger.i('SettingsRepository: Clearing settings');
      await _settingsDao.clear();
      AppLogger.i('SettingsRepository: Successfully cleared settings');
    } catch (e, stackTrace) {
      AppLogger.e('SettingsRepository: Error clearing settings', e, stackTrace);
      rethrow;
    }
  }

  @override
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
      themePreference: _mapThemeModeToPreference(s.themeMode),
      partnerConfigName: s.partnerConfigName,
      partnerDutyGroup: s.partnerDutyGroup,
      partnerAccentColorValue: s.partnerAccentColorValue,
    );
  }

  data.Settings _toDataSettings(domain.Settings s) {
    return data.Settings(
      calendarFormat: s.calendarFormat,
      language: s.language,
      selectedDutyGroup: s.selectedDutyGroup,
      myDutyGroup: s.myDutyGroup,
      activeConfigName: s.activeConfigName,
      themeMode: _mapPreferenceToThemeMode(s.themePreference),
      partnerConfigName: s.partnerConfigName,
      partnerDutyGroup: s.partnerDutyGroup,
      partnerAccentColorValue: s.partnerAccentColorValue,
    );
  }

  ThemeMode? _mapPreferenceToThemeMode(domain.ThemePreference? pref) {
    switch (pref) {
      case domain.ThemePreference.system:
        return ThemeMode.system;
      case domain.ThemePreference.light:
        return ThemeMode.light;
      case domain.ThemePreference.dark:
        return ThemeMode.dark;
      default:
        return null;
    }
  }

  domain.ThemePreference? _mapThemeModeToPreference(ThemeMode? mode) {
    switch (mode) {
      case ThemeMode.system:
        return domain.ThemePreference.system;
      case ThemeMode.light:
        return domain.ThemePreference.light;
      case ThemeMode.dark:
        return domain.ThemePreference.dark;
      default:
        return null;
    }
  }
}
