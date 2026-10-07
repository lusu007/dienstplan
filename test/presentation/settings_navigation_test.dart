import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_category.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/appearance_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/school_holidays_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/app_section.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/screens/settings_screen.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

Widget host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('navigation hints are light-only and preserve custom trailing', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: Column(
              children: [
                NavigationCard(icon: Icons.person, title: 'Open', onTap: () {}),
                NavigationCard(
                  icon: Icons.person,
                  title: 'Custom',
                  onTap: () {},
                  trailing: const Icon(Icons.palette),
                ),
                const NavigationCard(
                  icon: Icons.person,
                  title: 'Disabled',
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byIcon(Icons.chevron_right_rounded),
        brightness == Brightness.light ? findsOneWidget : findsNothing,
      );
      expect(find.byIcon(Icons.palette), findsOneWidget);
    }
  });
  testWidgets(
    'missing federal state explains disabled holiday actions in both themes',
    (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              schoolHolidaysProvider.overrideWith(_EnabledHolidays.new),
              settingsProvider.overrideWith(_Settings.new),
            ],
            child: MaterialApp(
              theme: ThemeData(brightness: brightness),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: SingleChildScrollView(child: SchoolHolidaysSection()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Zuerst Bundesland auswählen'),
          findsNWidgets(2),
        );
      }
    },
  );
  testWidgets('settings overview does not load feature providers', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'Dienstplan',
      packageName: 'test',
      version: '1',
      buildNumber: '1',
      buildSignature: '',
    );
    // Only the shared backdrop needs the existing accent-color provider.
    final container = ProviderContainer.test(
      overrides: [partnerProvider.overrideWith(_Partner.new)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: host(const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationCard), findsNWidgets(5));
    expect(find.byType(Switch), findsNothing);
    expect(container.exists(scheduleCoordinatorProvider), isFalse);
    expect(container.exists(settingsProvider), isFalse);
    expect(container.exists(schoolHolidaysProvider), isFalse);
    expect(container.exists(sentryStateProvider), isFalse);
  });

  testWidgets('category routes isolate contents and return to the overview', (
    tester,
  ) async {
    final router = AppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(_Settings.new),
          scheduleCoordinatorProvider.overrideWith(_Schedule.new),
          schoolHolidaysProvider.overrideWith(_Holidays.new),
          sentryStateProvider.overrideWith(
            (ref) async =>
                const SentryState(isEnabled: false, isReplayEnabled: false),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router.config(
            deepLinkBuilder: (_) => const DeepLink([SettingsRoute()]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ScheduleSection), findsNothing);
    expect(find.byType(AppearanceSection), findsNothing);
    for (final category in SettingsCategory.values) {
      final link = find.byKey(ValueKey('settings_${category.name}'));
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(router.current.name, SettingsCategoryRoute.name);
      // A viewport-wide ShaderMask hides glass group contents on Impeller.
      expect(find.byType(ShaderMask), findsNothing);
      switch (category) {
        case SettingsCategory.schedule:
        case SettingsCategory.partner:
          final section = tester.widget<ScheduleSection>(
            find.byType(ScheduleSection),
          );
          expect(section.partner, category == SettingsCategory.partner);
          expect(
            find.byType(NavigationCard),
            findsNWidgets(section.partner ? 3 : 4),
          );
        case SettingsCategory.appearance:
          expect(find.byType(AppearanceSection), findsOneWidget);
          expect(find.byType(AppSection), findsNothing);
        case SettingsCategory.holidays:
          expect(find.byType(SchoolHolidaysSection), findsOneWidget);
        case SettingsCategory.app:
          expect(find.byType(AppSection), findsOneWidget);
          expect(find.byType(AppearanceSection), findsNothing);
      }
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(router.current.name, SettingsRoute.name);
      expect(find.byKey(const ValueKey('settings_schedule')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('a settings group shares its surface and keeps row actions', (
    tester,
  ) async {
    var selected = '';
    await tester.pumpWidget(
      host(
        SettingsSection(
          title: 'Gruppe',
          cards: [
            NavigationCard(
              icon: Icons.person,
              title: 'Erste',
              onTap: () => selected = 'first',
            ),
            NavigationCard(
              icon: Icons.group,
              title: 'Zweite',
              onTap: () => selected = 'second',
            ),
          ],
        ),
      ),
    );
    expect(find.byType(AppGlassSurface), findsOneWidget);
    await tester.tap(find.text('Zweite'));
    expect(selected, 'second');
    await tester.tap(find.text('Erste'));
    expect(selected, 'first');
  });
}

class _Settings extends SettingsNotifier {
  @override
  Future<SettingsUiState> build() async => SettingsUiState.initial();
}

class _Schedule extends ScheduleCoordinatorNotifier {
  @override
  Future<ScheduleUiState> build() async => ScheduleUiState.initial();
}

class _Holidays extends SchoolHolidaysNotifier {
  @override
  Future<SchoolHolidaysUiState> build() async =>
      SchoolHolidaysUiState.initial();
}

class _Partner extends PartnerNotifier {
  @override
  Future<PartnerUiState> build() async => PartnerUiState.initial();
}

class _EnabledHolidays extends SchoolHolidaysNotifier {
  @override
  Future<SchoolHolidaysUiState> build() async =>
      SchoolHolidaysUiState.initial().copyWith(isEnabled: true);
}
