import 'package:dienstplan/data/models/duty_schedule_config.dart';

abstract class ScheduleConfigServiceInterface {
  Future<void> initialize();

  // Config operations
  List<DutyScheduleConfig> get configs;
  DutyScheduleConfig? get defaultConfig;
  Future<void> saveConfig(DutyScheduleConfig config);
  Future<void> setDefaultConfig(DutyScheduleConfig config);
  Future<void> markSetupCompleted();
  Future<void> resetSetup();
  Future<bool> isSetupCompleted();
}
