import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';

class GetConfigsUseCase {
  final ConfigRepository _configRepository;

  GetConfigsUseCase(this._configRepository);

  Future<List<DutyScheduleConfig>> execute() async {
    try {
      AppLogger.i('GetConfigsUseCase: Executing get configs');
      final configs = await _configRepository.getConfigs();

      AppLogger.i('GetConfigsUseCase: Retrieved ${configs.length} configs');

      // Business logic: Sort configs by name for consistent ordering
      configs.sort((a, b) => a.name.compareTo(b.name));

      return configs;
    } catch (e, stackTrace) {
      AppLogger.e('GetConfigsUseCase: Error getting configs', e, stackTrace);
      rethrow;
    }
  }
}
