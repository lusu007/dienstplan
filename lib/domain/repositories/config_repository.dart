import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/failures/result.dart';

abstract class ConfigRepository {
  Future<Result<List<DutyScheduleConfig>>> getConfigs();

  Future<Result<DutyScheduleConfig?>> getDefaultConfig();

  Future<Result<void>> saveConfig(DutyScheduleConfig config);

  Future<Result<void>> setDefaultConfig(DutyScheduleConfig config);
}
