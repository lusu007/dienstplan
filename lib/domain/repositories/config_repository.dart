import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/failures/result.dart';

abstract class ConfigRepository {
  Future<List<DutyScheduleConfig>> getConfigs();
  Future<Result<List<DutyScheduleConfig>>> getConfigsSafe();

  Future<DutyScheduleConfig?> getDefaultConfig();
  Future<Result<DutyScheduleConfig?>> getDefaultConfigSafe();

  Future<void> saveConfig(DutyScheduleConfig config);
  Future<Result<void>> saveConfigSafe(DutyScheduleConfig config);

  Future<void> setDefaultConfig(DutyScheduleConfig config);
  Future<Result<void>> setDefaultConfigSafe(DutyScheduleConfig config);
}
