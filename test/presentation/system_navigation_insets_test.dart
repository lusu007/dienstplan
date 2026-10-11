import 'package:dienstplan/presentation/state/calendar/calendar_split_layout_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/day_schedules_list_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_ui_state.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/glass_action_bar.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/table_calendar.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final bottomInset in <double>[0, 24, 48]) {
    testWidgets('screen content clears a $bottomInset navigation inset', (
      tester,
    ) async {
      const contentKey = Key('content');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [partnerProvider.overrideWith(_Partner.new)],
          child: _host(
            bottomInset: bottomInset,
            child: const GlassScreenScaffold(
              title: 'Settings',
              child: SizedBox.expand(key: contentKey),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(contentKey)).bottom, 600 - bottomInset);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'calendar clears its action bar with a $bottomInset navigation inset',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 850));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              partnerProvider.overrideWith(_Partner.new),
              scheduleCoordinatorProvider.overrideWith(_Schedule.new),
              settingsProvider.overrideWith(_Settings.new),
              schoolHolidaysProvider.overrideWith(_Holidays.new),
            ],
            child: _host(
              bottomInset: bottomInset,
              child: const Scaffold(
                resizeToAvoidBottomInset: false,
                body: CalendarView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final calendarBottom = tester
            .getRect(find.byType(CalendarTable))
            .bottom;
        final fieldTop = tester
            .getRect(
              find.descendant(
                of: find.byType(GlassActionBar),
                matching: find.byType(TextField),
              ),
            )
            .top;
        expect(calendarBottom, lessThanOrEqualTo(fieldTop));
        expect(tester.takeException(), isNull);
        SharedPreferences.setMockInitialValues({});
        final container = ProviderScope.containerOf(
          tester.element(find.byType(CalendarView)),
        );
        await container
            .read(calendarSplitLayoutProvider.notifier)
            .setSplitLayout(true);
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.byType(DaySchedulesListPanel)).bottom,
          lessThanOrEqualTo(fieldTop),
        );
        expect(tester.takeException(), isNull);
      },
    );

    for (final shrinkToContent in [false, true]) {
      testWidgets(
        'modal sheet clears a $bottomInset navigation inset (shrink: $shrinkToContent)',
        (tester) async {
          await tester.pumpWidget(
            _host(
              bottomInset: bottomInset,
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => GlassBottomSheet(
                      shrinkToContent: shrinkToContent,
                      children: const [
                        SizedBox(height: 100, child: Text('Content')),
                      ],
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.byType(GlassDialogSurface)).bottom,
            lessThanOrEqualTo(600 - bottomInset),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Widget _host({required double bottomInset, required Widget child}) =>
    MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: EdgeInsets.only(bottom: bottomInset),
          viewPadding: EdgeInsets.only(bottom: bottomInset),
        ),
        child: child!,
      ),
      home: child,
    );

class _Partner extends PartnerNotifier {
  @override
  Future<PartnerUiState> build() async => PartnerUiState.initial();
}

class _Schedule extends ScheduleCoordinatorNotifier {
  @override
  Future<ScheduleUiState> build() async => ScheduleUiState.initial();
}

class _Settings extends SettingsNotifier {
  @override
  Future<SettingsUiState> build() async => SettingsUiState.initial();
}

class _Holidays extends SchoolHolidaysNotifier {
  @override
  Future<SchoolHolidaysUiState> build() async =>
      SchoolHolidaysUiState.initial();
}
