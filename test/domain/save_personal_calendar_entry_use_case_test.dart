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
    test('calendar boundaries preserve explicit end dates', () async {
      final repo = _FakeRepo();
      final useCase = SavePersonalCalendarEntryUseCase(repo);
      for (final days in [
        (DateTime.utc(2026, 12, 31), DateTime.utc(2027, 1, 1)),
        (DateTime.utc(2028, 2, 28), DateTime.utc(2028, 2, 29)),
        (DateTime.utc(2026, 3, 28), DateTime.utc(2026, 3, 29)),
        (DateTime.utc(2026, 10, 24), DateTime.utc(2026, 10, 25)),
      ]) {
        final entry = _base(
          isAllDay: false,
          start: 1320,
          end: 360,
        ).copyWith(date: days.$1, endDate: days.$2);
        expect((await useCase.execute(entry)).isSuccess, isTrue);
        expect(repo.lastUpsert?.date, days.$1);
        expect(repo.lastUpsert?.endDate, days.$2);
      }
    });
    test('persists overnight and multiday end dates', () async {
      final repo = _FakeRepo();
      final useCase = SavePersonalCalendarEntryUseCase(repo);
      for (final endDate in [
        DateTime.utc(2026, 1, 2),
        DateTime.utc(2026, 1, 5),
      ]) {
        final entry = _base(
          isAllDay: false,
          start: 22 * 60,
          end: 6 * 60,
        ).copyWith(endDate: endDate);
        expect((await useCase.execute(entry)).isSuccess, isTrue);
        expect(repo.lastUpsert?.endDate, endDate);
      }
    });
    test('rejects an explicit end date before the start date', () async {
      final repo = _FakeRepo();
      final entry = _base(
        isAllDay: false,
        start: 8 * 60,
        end: 16 * 60,
      ).copyWith(endDate: DateTime.utc(2025, 12, 31));
      expect(
        (await SavePersonalCalendarEntryUseCase(repo).execute(entry)).isFailure,
        isTrue,
      );
      expect(repo.lastUpsert, isNull);
    });
    test('same time on explicitly different dates is valid', () async {
      final repo = _FakeRepo();
      final entry = _base(
        isAllDay: false,
        start: 600,
        end: 600,
      ).copyWith(endDate: DateTime.utc(2026, 1, 2));
      expect(
        (await SavePersonalCalendarEntryUseCase(repo).execute(entry)).isSuccess,
        isTrue,
      );
    });
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
