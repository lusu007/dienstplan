import 'dart:async';

import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';
import 'package:dienstplan/domain/services/personal_entry_schedule_mapper.dart';
import 'package:dienstplan/domain/use_cases/delete_personal_calendar_entry_use_case.dart';
import 'package:dienstplan/domain/use_cases/save_personal_calendar_entry_use_case.dart';
import 'package:dienstplan/presentation/widgets/common/app_snack_bar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// The real use cases perform validation; only persistence is replaced.
class _UnavailableRepository implements PersonalCalendarRepository {
  Completer<void>? saving;
  int saves = 0;
  @override
  Future<Result<void>> upsert(PersonalCalendarEntry entry) async {
    saves++;
    await saving?.future;
    return Result.createFailure(
      const StorageFailure(technicalMessage: 'Unavailable'),
    );
  }

  @override
  Future<Result<void>> deleteById(String id) async => Result.createFailure(
    const StorageFailure(technicalMessage: 'Unavailable'),
  );

  @override
  Future<Result<void>> deleteAll() => throw UnimplementedError();

  @override
  Future<Result<List<PersonalCalendarEntry>>> listBetween({
    required DateTime startDate,
    required DateTime endDate,
  }) => throw UnimplementedError();
}

Future<void> _openEditor(
  WidgetTester tester, {
  required bool dark,
  bool editing = false,
  _UnavailableRepository? repository,
}) async {
  tester.view.physicalSize = const Size(600, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await initializeDateFormatting('de');
  final repo = repository ?? _UnavailableRepository();
  final container = ProviderContainer.test(
    overrides: [
      savePersonalCalendarEntryUseCaseProvider.overrideWith(
        (ref) async => SavePersonalCalendarEntryUseCase(repo),
      ),
      deletePersonalCalendarEntryUseCaseProvider.overrideWith(
        (ref) async => DeletePersonalCalendarEntryUseCase(repo),
      ),
    ],
  );
  final entry = PersonalCalendarEntry(
    id: 'existing',
    kind: PersonalCalendarEntryKind.appointment,
    title: 'Arzttermin',
    notes: 'Unterlagen mitnehmen',
    date: DateTime.utc(2026, 10, 5),
    isAllDay: true,
    dutyGroupName: 'Privat',
    createdAtMs: 0,
    updatedAtMs: 0,
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: container.read(dark ? appDarkThemeProvider : appThemeProvider),
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) => PersonalCalendarEntrySheet(
                  day: DateTime(2026, 10, 5),
                  existingSchedule: editing
                      ? PersonalEntryScheduleMapper.toSchedule(entry)
                      : null,
                  dutyGroupNameForNew: 'Privat',
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('double save executes once and failure keeps draft', (
    tester,
  ) async {
    final repo = _UnavailableRepository()..saving = Completer<void>();
    await _openEditor(tester, dark: false, editing: true, repository: repo);
    await tester.ensureVisible(find.text('Speichern'));
    await tester.tap(find.text('Speichern'));
    await tester.pump();
    await tester.tap(find.text('Speichern'), warnIfMissed: false);
    await tester.pump();
    expect(repo.saves, 1);
    repo.saving!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(PersonalCalendarEntrySheet), findsOneWidget);
    expect(find.text('Arzttermin'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets('missing title stays visible in open editor (dark: $dark)', (
      tester,
    ) async {
      await _openEditor(tester, dark: dark);
      await tester.ensureVisible(find.text('Speichern'));
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();
      final sheet = find.byType(PersonalCalendarEntrySheet);
      expect(sheet, findsOneWidget);
      expect(
        find.descendant(
          of: sheet,
          matching: find.text('Bitte gib eine Dienstbezeichnung ein.'),
        ),
        findsOneWidget,
      );
      expect(find.byType(AppSnackBar), findsNothing);
      expect(
        find.text('Bitte gib eine Dienstbezeichnung ein.').hitTestable(),
        findsOneWidget,
      );
      final field = find.byType(TextField).first;
      await tester.enterText(field, '  ');
      await tester.pumpAndSettle();
      expect(
        find.text('Bitte gib eine Dienstbezeichnung ein.'),
        findsOneWidget,
      );
      await tester.enterText(field, 'Arzttermin');
      await tester.pumpAndSettle();
      expect(find.text('Bitte gib eine Dienstbezeichnung ein.'), findsNothing);
      expect(tester.widget<TextField>(field).controller!.text, 'Arzttermin');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'save failure stays in editor and preserves draft (dark: $dark)',
      (tester) async {
        await _openEditor(tester, dark: dark, editing: true);
        await tester.ensureVisible(find.text('Speichern'));
        await tester.tap(find.text('Speichern'));
        await tester.pumpAndSettle();
        final sheet = find.byType(PersonalCalendarEntrySheet);
        expect(
          find.descendant(
            of: sheet,
            matching: find.text(
              'Beim Speichern ist ein Fehler aufgetreten. Bitte versuch es noch einmal.',
            ),
          ),
          findsOneWidget,
        );
        expect(find.byType(AppSnackBar), findsNothing);
        expect(
          find
              .text(
                'Beim Speichern ist ein Fehler aufgetreten. Bitte versuch es noch einmal.',
              )
              .hitTestable(),
          findsOneWidget,
        );
        final fields = tester
            .widgetList<TextField>(find.byType(TextField))
            .toList();
        expect(fields[0].controller!.text, 'Arzttermin');
        expect(fields[1].controller!.text, 'Unterlagen mitnehmen');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'delete failure returns to editor with visible error (dark: $dark)',
      (tester) async {
        await _openEditor(tester, dark: dark, editing: true);
        await tester.tap(find.byTooltip('Dienst löschen'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dienst löschen'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(PersonalCalendarEntrySheet),
            matching: find.text(
              'Beim Speichern ist ein Fehler aufgetreten. Bitte versuch es noch einmal.',
            ),
          ),
          findsOneWidget,
        );
        expect(find.byType(AppSnackBar), findsNothing);
        expect(
          find
              .text(
                'Beim Speichern ist ein Fehler aufgetreten. Bitte versuch es noch einmal.',
              )
              .hitTestable(),
          findsOneWidget,
        );
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          'Arzttermin',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
