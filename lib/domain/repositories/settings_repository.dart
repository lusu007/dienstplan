import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/failures/result.dart';

abstract class SettingsRepository {
  Future<Result<Settings?>> getSettings();

  Future<Result<void>> saveSettings(Settings settings);

  Future<Result<void>> clearSettings();
}
