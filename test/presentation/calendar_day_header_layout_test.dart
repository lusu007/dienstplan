import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_ui_state.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/calendar_view/day_schedules_list_panel.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/schedules_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _Holidays extends SchoolHolidaysNotifier {
  @override
  Future<SchoolHolidaysUiState> build() async =>
      SchoolHolidaysUiState.initial();
}

class _Settings extends SettingsNotifier {
  @override
  Future<SettingsUiState> build() async => SettingsUiState.initial();
}

class _Schedule extends ScheduleCoordinatorNotifier {
  @override
  Future<ScheduleUiState> build() async =>
      ScheduleUiState.initial().copyWith(selectedDay: DateTime(2026, 10, 2));
  @override
  Future<void> setSelectedDay(DateTime? day) async {}
}

void main() {
  testWidgets('Light today label is readable on its translucent sheet badge', (
    tester,
  ) async {
    await initializeDateFormatting('de');
    final theme = ThemeData.light();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(_Settings.new),
          schoolHolidaysProvider.overrideWith(_Holidays.new),
          scheduleCoordinatorProvider.overrideWith(_Schedule.new),
        ],
        child: MaterialApp(
          theme: theme,
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SchedulesBottomSheet(day: DateTime.now())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final label = find.text('Heute');
    final text = tester.widget<Text>(label);
    final badge = tester
        .widgetList<Container>(
          find.ancestor(of: label, matching: find.byType(Container)),
        )
        .firstWhere(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).color != null,
        );
    final fill = Color.alphaBlend(
      (badge.decoration! as BoxDecoration).color!,
      theme.colorScheme.surface,
    );
    final fg = Color.alphaBlend(text.style!.color!, fill);
    final a = fg.computeLuminance(), b = fill.computeLuminance();
    expect(
      ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
      greaterThanOrEqualTo(4.5),
    );
    expect(tester.takeException(), isNull);
  });
  for (final scale in [1.0, 1.3]) {
    testWidgets(
      'dark day header keeps its original height with 48dp targets at $scale',
      (tester) async {
        await initializeDateFormatting('de');
        final theme = ThemeData.dark();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsProvider.overrideWith(_Settings.new),
              schoolHolidaysProvider.overrideWith(_Holidays.new),
              scheduleCoordinatorProvider.overrideWith(_Schedule.new),
            ],
            child: MaterialApp(
              theme: theme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: const DaySchedulesListPanel(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final panel = tester.element(find.byType(DaySchedulesListPanel));
        final header = find
            .descendant(
              of: find.byType(DaySchedulesListPanel),
              matching: find.byType(RepaintBoundary),
            )
            .first;
        final painter = TextPainter(
          text: TextSpan(
            text: '2',
            style: theme.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
          textScaler: TextScaler.linear(scale),
        )..layout();
        final oldRow = painter.height > 36 ? painter.height : 36;
        painter.dispose();
        expect(tester.getSize(header).height, closeTo(oldRow + 16, .01));
        for (final target in find.byType(AppGlassIconButton).evaluate()) {
          expect(
            tester.getSize(find.byWidget(target.widget)).height,
            greaterThanOrEqualTo(48),
          );
        }
        expect(panel.mounted, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
