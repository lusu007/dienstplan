import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/failures/result.dart';

abstract class PersonalCalendarRepository {
  Future<Result<List<PersonalCalendarEntry>>> listBetween({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Result<void>> upsert(PersonalCalendarEntry entry);

  Future<Result<void>> deleteById(String id);

  Future<Result<void>> deleteAll();
}
