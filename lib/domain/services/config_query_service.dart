import 'package:dienstplan/domain/entities/duty_schedule_config.dart';

class ConfigQueryService {
  const ConfigQueryService();

  List<String> extractDutyGroups(
    List<DutyScheduleConfig> configs,
    String? activeName,
  ) {
    if (activeName == null) {
      return const <String>[];
    }
    final DutyScheduleConfig? active = selectActiveConfig(configs, activeName);
    if (active == null) {
      return const <String>[];
    }
    return active.dutyGroups.map((g) => g.name).toList(growable: false);
  }

  DutyScheduleConfig? selectActiveConfig(
    List<DutyScheduleConfig> configs,
    String? activeName,
  ) {
    if (configs.isEmpty) {
      return null;
    }
    if (activeName == null || activeName.isEmpty) {
      return configs.first;
    }
    for (final DutyScheduleConfig c in configs) {
      if (c.name == activeName) {
        return c;
      }
    }
    return configs.first;
  }
}
