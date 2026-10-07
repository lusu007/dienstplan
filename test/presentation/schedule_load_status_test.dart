import 'package:dienstplan/presentation/widgets/screens/calendar/components/schedule_load_status.dart';
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
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/day_schedules_list_panel.dart';

class _Broken extends ScheduleCoordinatorNotifier {
  @override
  Future<ScheduleUiState> build() async =>
      throw StateError('Audit loading failure');
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
void main() {
  testWidgets('async_error_shows_retry_instead_of_empty_day', (tester) async {
    await tester.pumpWidget(app(const DaySchedulesListPanel()));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(DaySchedulesListPanel));
    expect(find.text(AppLocalizations.of(ctx).noServicesForDay), findsNothing);
    expect(find.text(AppLocalizations.of(ctx).tryAgain), findsOneWidget);
  });
  testWidgets('loading_does_not_show_empty_day', (tester) async {
    await tester.pumpWidget(
      app(
        ScheduleLoadStatus(
          isLoading: true,
          errorMessage: null,
          hasVisibleSchedules: false,
          onRetry: () {},
          child: const Text('empty day'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('empty day'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testWidgets('state_error_preserves_matching_loaded_rows_and_allows_retry', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      app(
        ScheduleLoadStatus(
          isLoading: false,
          errorMessage: 'Aktualisierung fehlgeschlagen',
          hasVisibleSchedules: true,
          onRetry: () {
            retries++;
          },
          child: const Text('Frühdienst'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Frühdienst'), findsOneWidget);
    expect(find.text('Aktualisierung fehlgeschlagen'), findsOneWidget);
    await tester.tap(
      find.text(
        AppLocalizations.of(tester.element(find.byType(ScheduleLoadStatus)))
            .tryAgain,
      ),
    );
    expect(retries, 1);
  });
}
