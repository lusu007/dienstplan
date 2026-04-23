import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';

class DeletePersonalCalendarEntryUseCase {
  final PersonalCalendarRepository _repository;

  DeletePersonalCalendarEntryUseCase(this._repository);

  Future<Result<void>> execute(String id) async {
    AppLogger.d('DeletePersonalCalendarEntryUseCase: id=$id');
    return _repository.deleteById(id);
  }
}
