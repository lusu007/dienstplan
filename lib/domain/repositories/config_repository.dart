import 'package:dienstplan/domain/entities/duty_schedule_config.dart';

abstract class ConfigRepository {
  Future<List<DutyScheduleConfig>> getConfigs();
  Future<DutyScheduleConfig?> getDefaultConfig();
  Future<void> saveConfig(DutyScheduleConfig config);
}
