import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/repositories/config_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';

class GetConfigsUseCase {
  final ConfigRepository _configRepository;

  GetConfigsUseCase(this._configRepository);

  Future<Result<List<DutyScheduleConfig>>> execute() async {
    AppLogger.d('GetConfigsUseCase: Executing get configs');
    final Result<List<DutyScheduleConfig>> result = await _configRepository
        .getConfigs();
    if (result.isFailure) {
      AppLogger.e(
        'GetConfigsUseCase: Error getting configs',
        result.failure.cause ?? result.failure,
        result.failure.stackTrace,
      );
      return result;
    }
    final List<DutyScheduleConfig> configs = List<DutyScheduleConfig>.from(
      result.value,
    );
    configs.sort(
      (DutyScheduleConfig a, DutyScheduleConfig b) => a.name.compareTo(b.name),
    );
    AppLogger.d('GetConfigsUseCase: Retrieved ${configs.length} configs');
    return Result.success<List<DutyScheduleConfig>>(configs);
  }
}
