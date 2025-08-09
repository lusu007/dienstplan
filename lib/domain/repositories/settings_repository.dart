import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/failures/result.dart';

abstract class SettingsRepository {
  Future<Settings?> getSettings();
  Future<Result<Settings?>> getSettingsSafe();

  Future<void> saveSettings(Settings settings);
  Future<Result<void>> saveSettingsSafe(Settings settings);

  Future<void> clearSettings();
  Future<Result<void>> clearSettingsSafe();
}
