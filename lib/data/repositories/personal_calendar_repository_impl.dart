import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/data/daos/personal_calendar_entries_dao.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';

class PersonalCalendarRepositoryImpl implements PersonalCalendarRepository {
  final PersonalCalendarEntriesDao _dao;
  final ExceptionMapper _exceptionMapper;

  PersonalCalendarRepositoryImpl(this._dao, {ExceptionMapper? exceptionMapper})
    : _exceptionMapper = exceptionMapper ?? const ExceptionMapper();

  @override
  Future<Result<List<PersonalCalendarEntry>>> listBetween({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final List<PersonalCalendarEntry> list = await _dao.loadBetween(
        startDate: startDate,
        endDate: endDate,
      );
      return Result.success<List<PersonalCalendarEntry>>(list);
    } catch (e, stackTrace) {
      AppLogger.e(
        'PersonalCalendarRepositoryImpl: listBetween failed',
        e,
        stackTrace,
      );
      return Result.createFailure<List<PersonalCalendarEntry>>(
        _exceptionMapper.mapToFailure(e, stackTrace),
      );
    }
  }

  @override
  Future<Result<void>> upsert(PersonalCalendarEntry entry) async {
    try {
      await _dao.upsert(entry);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      AppLogger.e(
        'PersonalCalendarRepositoryImpl: upsert failed (id=${entry.id})',
        e,
        stackTrace,
      );
      return Result.createFailure<void>(
        _exceptionMapper.mapToFailure(e, stackTrace),
      );
    }
  }

  @override
  Future<Result<void>> deleteById(String id) async {
    try {
      await _dao.deleteById(id);
      return Result.success<void>(null);
    } catch (e, stackTrace) {
      AppLogger.e(
        'PersonalCalendarRepositoryImpl: deleteById failed (id=$id)',
        e,
        stackTrace,
      );
      return Result.createFailure<void>(
        _exceptionMapper.mapToFailure(e, stackTrace),
      );
    }
  }
}
