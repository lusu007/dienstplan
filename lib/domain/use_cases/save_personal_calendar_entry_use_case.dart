import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';

class SavePersonalCalendarEntryUseCase {
  final PersonalCalendarRepository _repository;

  SavePersonalCalendarEntryUseCase(this._repository);

  static const int _minutesPerDay = 24 * 60;

  Future<Result<void>> execute(PersonalCalendarEntry entry) async {
    final PersonalCalendarEntry normalized = entry.copyWith(
      title: entry.title.trim(),
    );
    final Result<void> validation = _validate(normalized);
    if (validation.isFailure) {
      return validation;
    }
    AppLogger.d(
      'SavePersonalCalendarEntryUseCase: upsert id=${normalized.id} kind=${normalized.kind}',
    );
    return _repository.upsert(normalized);
  }

  Result<void> _validate(PersonalCalendarEntry entry) {
    final String trimmedTitle = entry.title;
    if (trimmedTitle.isEmpty) {
      return Result.createFailure<void>(
        const ValidationFailure(
          technicalMessage: 'Personal entry title is empty',
          userMessageKey: 'personalEntryValidationTitle',
        ),
      );
    }
    if (entry.isAllDay) {
      return Result.success<void>(null);
    }
    final int? start = entry.startMinutesFromMidnight;
    final int? end = entry.endMinutesFromMidnight;
    if (start == null || end == null) {
      return Result.createFailure<void>(
        const ValidationFailure(
          technicalMessage: 'Personal entry times missing for timed entry',
          userMessageKey: 'personalEntryValidationTimes',
        ),
      );
    }
    if (start < 0 ||
        start >= _minutesPerDay ||
        end < 0 ||
        end >= _minutesPerDay) {
      return Result.createFailure<void>(
        const ValidationFailure(
          technicalMessage: 'Personal entry time out of range',
          userMessageKey: 'personalEntryValidationTimeRange',
        ),
      );
    }
    if (end <= start) {
      return Result.createFailure<void>(
        const ValidationFailure(
          technicalMessage: 'Personal entry end must be after start',
          userMessageKey: 'personalEntryValidationEndAfterStart',
        ),
      );
    }
    return Result.success<void>(null);
  }
}
