import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';
import 'package:dienstplan/domain/entities/personal_calendar_entry.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/use_cases/save_personal_calendar_entry_use_case.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/glass_action_bar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_ui_state.dart';

class _Broken extends ScheduleCoordinatorNotifier {
  @override
  Future<void> syncScheduleDataFromProvider() async {}
  @override
  Future<ScheduleUiState> build() async => ScheduleUiState.initial();
}

class _Settings extends SettingsNotifier {
  @override
  Future<SettingsUiState> build() async => SettingsUiState.initial();
}

class _Partner extends PartnerNotifier {
  @override
  Future<PartnerUiState> build() async => PartnerUiState.initial();
}

class _Holidays extends SchoolHolidaysNotifier {
  @override
  Future<SchoolHolidaysUiState> build() async =>
      SchoolHolidaysUiState.initial();
}

Widget app(Widget child) => ProviderScope(
  overrides: [
    savePersonalCalendarEntryUseCaseProvider.overrideWith(
      (ref) async => SavePersonalCalendarEntryUseCase(_Repo()),
    ),
    scheduleDataProvider.overrideWith(_Data.new),
    scheduleCoordinatorProvider.overrideWith(_Broken.new),
    settingsProvider.overrideWith(_Settings.new),
    partnerProvider.overrideWith(_Partner.new),
    schoolHolidaysProvider.overrideWith(_Holidays.new),
  ],
  child: MaterialApp(
    locale: const Locale('de'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

class _Repo implements PersonalCalendarRepository {
  @override
  Future<Result<void>> upsert(PersonalCalendarEntry entry) async =>
      Result.success(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Data extends ScheduleDataNotifier {
  @override
  Future<ScheduleDataUiState> build() async => ScheduleDataUiState.initial();
  @override
  Future<void> refreshPersonalCalendarEntries() async {}
}

void main() {
  testWidgets('quick title clears only after successful save', (tester) async {
    tester.view.physicalSize = const Size(600, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(
        const Align(alignment: Alignment.bottomCenter, child: GlassActionBar()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Fortbildung');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Speichern'));
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalCalendarEntrySheet), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });
  testWidgets(
    'barrier dismiss confirms dirty entry and preserves quick title',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          const Align(
            alignment: Alignment.bottomCenter,
            child: GlassActionBar(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Fortbildung');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      final title = find
          .descendant(
            of: find.byType(PersonalCalendarEntrySheet),
            matching: find.byType(TextField),
          )
          .first;
      await tester.enterText(title, 'Verändert');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Änderungen verwerfen?'), findsOneWidget);
      await tester.tap(find.text('Weiter bearbeiten'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(title).controller!.text, 'Verändert');
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verwerfen'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalCalendarEntrySheet), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Fortbildung',
      );
    },
  );

  for (final usePlus in [true, false]) {
    testWidgets(
      'quick title preserved through ${usePlus ? "plus" : "keyboard"} and cancellation',
      (tester) async {
        tester.view.physicalSize = const Size(600, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          app(
            const Align(
              alignment: Alignment.bottomCenter,
              child: GlassActionBar(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Fortbildung');
        if (usePlus) {
          await tester.tap(find.byIcon(Icons.add_rounded));
        } else {
          await tester.testTextInput.receiveAction(TextInputAction.done);
        }
        await tester.pumpAndSettle();
        final title = find
            .descendant(
              of: find.byType(PersonalCalendarEntrySheet),
              matching: find.byType(TextField),
            )
            .first;
        expect(tester.widget<TextField>(title).controller!.text, 'Fortbildung');
        Navigator.of(tester.element(title)).pop();
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Fortbildung',
        );
      },
    );
  }
}
