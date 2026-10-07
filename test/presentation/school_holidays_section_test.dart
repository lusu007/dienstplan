import 'package:dienstplan/presentation/widgets/screens/settings/sections/school_holidays_section.dart';
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
      SchoolHolidaysUiState.initial().copyWith(isEnabled: true);
}

Widget app(Widget child, bool dark) => ProviderScope(
  overrides: [
    scheduleCoordinatorProvider.overrideWith(_Broken.new),
    settingsProvider.overrideWith(_Settings.new),
    partnerProvider.overrideWith(_Partner.new),
    schoolHolidaysProvider.overrideWith(_Holidays.new),
  ],
  child: MaterialApp(
    theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
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
  for (final dark in [false, true]) {
    testWidgets(
      'missing state explains disabled holiday actions in dark=$dark',
      (tester) async {
        await tester.pumpWidget(
          app(
            const SingleChildScrollView(child: SchoolHolidaysSection()),
            dark,
          ),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(SchoolHolidaysSection)),
        );
        expect(find.text(l10n.selectFederalStateFirst), findsNWidgets(2));
      },
    );
  }
}
