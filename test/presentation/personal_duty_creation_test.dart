import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';
import 'package:dienstplan/domain/use_cases/save_personal_calendar_entry_use_case.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _UnavailableRepository implements PersonalCalendarRepository {
  PersonalCalendarEntry? submittedEntry;

  @override
  Future<Result<void>> upsert(PersonalCalendarEntry entry) async {
    submittedEntry = entry;
    return Result.createFailure<void>(
      const StorageFailure(technicalMessage: 'Storage unavailable'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('new personal entries are duties without a kind selector', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await initializeDateFormatting('de');
    final repository = _UnavailableRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savePersonalCalendarEntryUseCaseProvider.overrideWith(
            (ref) async => SavePersonalCalendarEntryUseCase(repository),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PersonalCalendarEntrySheet(
              day: DateTime(2026, 10, 7),
              existingSchedule: null,
              dutyGroupNameForNew: 'Meine Dienste',
              initialTitle: 'Spätdienst',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GlassFilterChip), findsNothing);
    expect(find.text('Neuer Dienst'), findsOneWidget);
    await tester.ensureVisible(find.text('Speichern'));
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(
      repository.submittedEntry?.kind,
      PersonalCalendarEntryKind.personalDuty,
    );
    expect(repository.submittedEntry?.title, 'Spätdienst');
    expect(repository.submittedEntry?.date, DateTime.utc(2026, 10, 7));
  });
}
