import 'package:dienstplan/domain/entities/duty_schedule_config.dart';

class ConfigFilterUtils {
  /// Extracts unique police authorities from a list of duty schedule configurations
  static Set<String> extractAvailableAuthorities(
    List<DutyScheduleConfig> configs,
  ) {
    return configs
        .map((config) => config.meta.policeAuthority)
        .where((authority) => authority != null)
        .cast<String>()
        .toSet();
  }

  /// Filters configurations by selected police authorities
  /// If no authorities are selected, returns all configurations
  static List<DutyScheduleConfig> filterConfigsByAuthorities(
    List<DutyScheduleConfig> configs,
    Set<String> selectedAuthorities,
  ) {
    if (selectedAuthorities.isEmpty) {
      return configs;
    }

    return configs
        .where(
          (config) =>
              config.meta.policeAuthority != null &&
              selectedAuthorities.contains(config.meta.policeAuthority),
        )
        .toList();
  }
}
