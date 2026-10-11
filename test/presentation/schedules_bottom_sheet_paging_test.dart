import 'dart:async';

import 'package:dienstplan/presentation/widgets/common/app_glass_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_sheet_backdrop.dart'
    show GlassSheetScope;

import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/schedules_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final day = DateTime(2026, 10, 15);

class _Schedules extends ScheduleCoordinatorNotifier {
  _Schedules({this.extraRows = 0});
  final int extraRows;
  final selected = <DateTime>[];
  Completer<void>? gate;
  @override
  Future<ScheduleUiState> build() async => ScheduleUiState.initial().copyWith(
    selectedDay: day,
    focusedDay: day,
    activeConfigName: 'Test',
    preferredDutyGroup: 'Gruppe 1',
    schedules: [
      for (var i = -1; i <= 1; i++)
        Schedule(
          date: DateTime(2026, 10, 15 + i),
          service: 'Dienst $i',
          dutyGroupId: '1',
          dutyTypeId: '$i',
          dutyGroupName: 'Gruppe 1',
          configName: 'Test',
        ),
      for (var i = 0; i < extraRows; i++)
        Schedule(
          date: day,
          service: 'Extra $i',
          dutyGroupId: '1',
          dutyTypeId: 'extra-$i',
          dutyGroupName: 'Gruppe 1',
          configName: 'Test',
        ),
    ],
  );
  @override
  Future<void> setSelectedDay(DateTime? value) async {
    if (value != null) selected.add(value);
    state = AsyncData(state.requireValue.copyWith(selectedDay: value));
  }

  @override
  Future<void> setFocusedDay(DateTime value) async {
    state = AsyncData(state.requireValue.copyWith(focusedDay: value));
  }

  @override
  Future<void> selectFocusedDay({
    required DateTime selectedDay,
    required DateTime focusedDay,
  }) async {
    selected.add(selectedDay);
    final pending = gate;
    gate = null;
    if (pending != null) await pending.future;
    state = AsyncData(
      state.requireValue.copyWith(
        selectedDay: selectedDay,
        focusedDay: focusedDay,
      ),
    );
  }
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

Future<_Schedules> _open(
  WidgetTester tester, {
  DateTime? initialDay,
  bool reducedMotion = false,
  int extraRows = 0,
  bool preparedBackground = false,
}) async {
  final schedules = _Schedules(extraRows: extraRows);
  late BuildContext context;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scheduleCoordinatorProvider.overrideWith(() => schedules),
        settingsProvider.overrideWith(_Settings.new),
        schoolHolidaysProvider.overrideWith(_Holidays.new),
      ],
      child: MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: reducedMotion),
          child: preparedBackground ? AppGlassSheetHost(child: child!) : child!,
        ),
        home: Consumer(
          builder: (c, ref, _) {
            if (!preparedBackground) context = c;
            final selection = ref
                .watch(scheduleCoordinatorProvider)
                .value
                ?.selectedDay;
            ref.watch(settingsProvider);
            ref.watch(schoolHolidaysProvider);
            final scaffold = Scaffold(
              body: Text(
                preparedBackground
                    ? 'Calendar selected ${selection?.day}'
                    : 'Calendar',
              ),
            );
            return preparedBackground
                ? AppGlassSheetScene(
                    child: Builder(
                      builder: (c) {
                        context = c;
                        return scaffold;
                      },
                    ),
                  )
                : scaffold;
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (preparedBackground) {
    expect(
      await tester.runAsync(() => AppGlassSheetHost.prepare(context)),
      isTrue,
    );
  }
  SchedulesBottomSheet.show(context, initialDay ?? day);
  await tester.pumpAndSettle();
  return schedules;
}

void main() {
  testWidgets('quick reversals refresh only the latest settled backdrop', (
    tester,
  ) async {
    await _open(tester, preparedBackground: true);
    final session = GlassSheetScope.maybeOf(
      tester.element(find.byType(SchedulesBottomSheet)),
    )!;
    final capture = session.captureScene!;
    var captures = 0;
    session.captureScene = (ratio) {
      captures++;
      return capture(ratio);
    };
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Nächster Tag'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(captures, 0);
      await tester.tap(find.byTooltip('Vorheriger Tag'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
    });
    expect(captures, 1);
    expect(
      find.text('Calendar selected 15', skipOffstage: false),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'calendar selection stays visible behind the open prepared sheet',
    (tester) async {
      await _open(tester, preparedBackground: true);
      expect(
        find.text('Calendar selected 15', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.byType(RawImage), findsWidgets);
      final original = tester
          .widget<RawImage>(find.byType(RawImage).first)
          .image;
      await tester.runAsync(() async {
        await tester.drag(find.text('Dienst 0'), const Offset(-600, 0));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();
      });
      expect(
        tester.widget<RawImage>(find.byType(RawImage).first).image,
        isNot(same(original)),
      );
      expect(
        find.text('Calendar selected 16', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Dienst 1'), findsOneWidget);
      expect(find.byType(SchedulesBottomSheet), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.byTooltip('Vorheriger Tag'));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();
      });
      expect(
        find.text('Calendar selected 15', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.byType(SchedulesBottomSheet), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'day content follows finger while glass and actions remain fixed',
    (tester) async {
      final schedules = await _open(tester);
      final card = find.text('Dienst 0');
      final cardBefore = tester.getCenter(card);
      final dateBefore = tester.getCenter(find.text('15'));
      final surfaceBefore = tester.getRect(find.byType(GlassDialogSurface));
      final action = find.byTooltip(
        AppLocalizations.of(tester.element(card)).addPersonalEntryTooltip,
      );
      final actionBefore = tester.getCenter(action);
      final gesture = await tester.startGesture(cardBefore);
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(-120, 0));
      await tester.pump();
      expect(tester.getCenter(card).dx, lessThan(cardBefore.dx - 80));
      expect(
        tester.getCenter(find.text('15')).dx - dateBefore.dx,
        closeTo(tester.getCenter(card).dx - cardBefore.dx, 1),
      );
      expect(
        tester
            .widget<GlassIconToggleChip>(find.byType(GlassIconToggleChip).first)
            .isEnabled,
        isFalse,
      );
      expect(tester.getRect(find.byType(GlassDialogSurface)), surfaceBefore);
      expect(tester.getCenter(action), actionBefore);
      expect(find.byType(ShaderMask), findsNothing);
      expect(schedules.selected, isEmpty);
      await gesture.moveBy(const Offset(-450, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(schedules.selected.last, DateTime(2026, 10, 16));
      expect(find.text('Dienst 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'short slow drag returns to the same day and vertical drag does not page',
    (tester) async {
      final schedules = await _open(tester);
      final before = tester.getCenter(find.text('Dienst 0'));
      final gesture = await tester.startGesture(before);
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(-35, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('Dienst 0')), before);
      expect(schedules.selected, isEmpty);
      await tester.drag(find.text('Dienst 0'), const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(schedules.selected, isEmpty);
      expect(find.text('Dienst 0'), findsOneWidget);
    },
  );
  testWidgets(
    'arrows cross month boundaries and reduced motion changes immediately',
    (tester) async {
      final schedules = await _open(
        tester,
        initialDay: DateTime(2026, 10, 31),
        reducedMotion: true,
      );
      await tester.tap(find.byTooltip('Nächster Tag'));
      await tester.pump();
      expect(schedules.selected.last, DateTime(2026, 11, 1));
      await tester.tap(find.byTooltip('Vorheriger Tag'));
      await tester.pump();
      expect(schedules.selected.last, DateTime(2026, 10, 31));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('rapid reversal leaves calendar on the day actually displayed', (
    tester,
  ) async {
    final schedules = await _open(tester);
    await tester.tap(find.byTooltip('Nächster Tag'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byTooltip('Vorheriger Tag'));
    await tester.pumpAndSettle();
    expect(schedules.selected.isEmpty ? day : schedules.selected.last, day);
    expect(find.text('Dienst 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('narrow sheet with large text retains readable controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _open(tester, initialDay: DateTime.now());
    expect(find.byTooltip('Nächster Tag'), findsOneWidget);
    expect(find.byTooltip('Vorheriger Tag'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'latest settled day is preserved when closing during month loading',
    (tester) async {
      final schedules = await _open(tester);
      final gate = Completer<void>();
      schedules.gate = gate;
      await tester.tap(find.byTooltip('Nächster Tag'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Vorheriger Tag'));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(SchedulesBottomSheet));
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      gate.complete();
      await tester.pumpAndSettle();
      expect(schedules.selected.last, day);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('vertical scroll position survives canceled horizontal paging', (
    tester,
  ) async {
    final schedules = await _open(tester, extraRows: 25);
    await tester.drag(find.text('Dienst 0'), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(schedules.selected, isEmpty);
    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(SchedulesBottomSheet),
            matching: find.byType(Scrollable),
          )
          .last,
    );
    final offset = scrollable.position.pixels;
    expect(offset, greaterThan(100));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await gesture.moveBy(const Offset(-30, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(scrollable.mounted, isTrue);
    expect(scrollable.position.pixels, closeTo(offset, 1));
    expect(schedules.selected, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
