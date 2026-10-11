import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_ui_state.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/schedules_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _day = DateTime(2026, 10, 15);

class _Schedules extends ScheduleCoordinatorNotifier {
  @override
  Future<ScheduleUiState> build() async => ScheduleUiState.initial().copyWith(
    activeConfigName: 'Test',
    preferredDutyGroup: 'Gruppe 1',
    schedules: [
      Schedule(
        date: _day,
        service: 'Spätdienst',
        dutyGroupId: '1',
        dutyTypeId: 'late',
        dutyGroupName: 'Gruppe 1',
        configName: 'Test',
      ),
    ],
  );
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

void main() {
  testWidgets('service sheet defers list fade during opening and closing', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scheduleCoordinatorProvider.overrideWith(_Schedules.new),
          settingsProvider.overrideWith(_Settings.new),
          schoolHolidaysProvider.overrideWith(_Holidays.new),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (c, ref, _) {
              ref.watch(scheduleCoordinatorProvider);
              ref.watch(settingsProvider);
              ref.watch(schoolHolidaysProvider);
              context = c;
              return const Scaffold(body: Text('Calendar'));
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    SchedulesBottomSheet.show(context, _day);
    await tester.pump();
    final masks = find.descendant(
      of: find.byType(SchedulesBottomSheet),
      matching: find.byType(ShaderMask),
    );
    expect(masks, findsNothing);
    expect(find.text('Spätdienst'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(masks, findsOneWidget);
    expect(find.text('Spätdienst'), findsOneWidget);
    Navigator.of(context).pop();
    await tester.pump();
    expect(masks, findsNothing);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
