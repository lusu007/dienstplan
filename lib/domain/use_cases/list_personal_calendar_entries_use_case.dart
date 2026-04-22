import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';

class ListPersonalCalendarEntriesUseCase {
  final PersonalCalendarRepository _repository;

  ListPersonalCalendarEntriesUseCase(this._repository);

  Future<Result<List<PersonalCalendarEntry>>> executeBetween({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    AppLogger.d(
      'ListPersonalCalendarEntriesUseCase: range $startDate .. $endDate',
    );
    return _repository.listBetween(startDate: startDate, endDate: endDate);
  }
}
