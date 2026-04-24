import 'package:flutter_test/flutter_test.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';
import 'package:dienstplan/domain/use_cases/save_personal_calendar_entry_use_case.dart';

class _FakeRepo implements PersonalCalendarRepository {
  PersonalCalendarEntry? lastUpsert;

  @override
  Future<Result<void>> deleteById(String id) async {
    return Result.success<void>(null);
  }

  @override
  Future<Result<void>> deleteAll() async {
    return Result.success<void>(null);
  }

  @override
  Future<Result<List<PersonalCalendarEntry>>> listBetween({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return Result.success<List<PersonalCalendarEntry>>(const []);
  }

  @override
  Future<Result<void>> upsert(PersonalCalendarEntry entry) async {
    lastUpsert = entry;
    return Result.success<void>(null);
  }
}

PersonalCalendarEntry _base({
  required bool isAllDay,
  int? start,
  int? end,
  String title = 'Ok',
}) {
  return PersonalCalendarEntry(
    id: '1',
    kind: PersonalCalendarEntryKind.appointment,
    title: title,
    notes: null,
    date: DateTime.utc(2026, 1, 1),
    isAllDay: isAllDay,
    startMinutesFromMidnight: start,
    endMinutesFromMidnight: end,
    dutyGroupName: 'G',
    createdAtMs: 0,
    updatedAtMs: 0,
  );
}

void main() {
  group('SavePersonalCalendarEntryUseCase', () {
    test('rejects empty title', () async {
      final _FakeRepo repo = _FakeRepo();
      final SavePersonalCalendarEntryUseCase uc =
          SavePersonalCalendarEntryUseCase(repo);
      final Result<void> r = await uc.execute(
        _base(isAllDay: true, title: '   '),
      );
      expect(r.isFailure, isTrue);
      expect(repo.lastUpsert, isNull);
    });

    test('rejects timed entry without times', () async {
      final _FakeRepo repo = _FakeRepo();
      final SavePersonalCalendarEntryUseCase uc =
          SavePersonalCalendarEntryUseCase(repo);
      final Result<void> r = await uc.execute(
        _base(isAllDay: false, start: null, end: 100),
      );
      expect(r.isFailure, isTrue);
    });

    test('rejects end before start', () async {
      final _FakeRepo repo = _FakeRepo();
      final SavePersonalCalendarEntryUseCase uc =
          SavePersonalCalendarEntryUseCase(repo);
      final Result<void> r = await uc.execute(
        _base(isAllDay: false, start: 600, end: 500),
      );
      expect(r.isFailure, isTrue);
    });

    test('rejects timed entry ending at 24:00', () async {
      final _FakeRepo repo = _FakeRepo();
      final SavePersonalCalendarEntryUseCase uc =
          SavePersonalCalendarEntryUseCase(repo);
      final Result<void> r = await uc.execute(
        _base(isAllDay: false, start: 1380, end: 1440),
      );
      expect(r.isFailure, isTrue);
      expect(repo.lastUpsert, isNull);
    });

    test('persists valid timed entry', () async {
      final _FakeRepo repo = _FakeRepo();
      final SavePersonalCalendarEntryUseCase uc =
          SavePersonalCalendarEntryUseCase(repo);
      final Result<void> r = await uc.execute(
        _base(isAllDay: false, start: 480, end: 540),
      );
      expect(r.isSuccess, isTrue);
      expect(repo.lastUpsert?.startMinutesFromMidnight, 480);
      expect(repo.lastUpsert?.endMinutesFromMidnight, 540);
    });
  });
}
