import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/screens/contact_feedback_screen.dart';
import 'package:dienstplan/presentation/screens/settings_screen.dart';
import 'package:dienstplan/presentation/screens/disclaimer_screen.dart';
import 'package:dienstplan/presentation/screens/privacy_policy_screen.dart';
import 'package:dienstplan/presentation/screens/setup_screen.dart';
import 'package:dienstplan/presentation/state/setup/setup_notifier.dart';
import 'package:dienstplan/presentation/state/setup/setup_ui_state.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_header.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_group.dart';
import 'package:dienstplan/domain/entities/meta.dart';

class AuditCoordinator extends ScheduleCoordinatorNotifier {
  @override
  Future<ScheduleUiState> build() async =>
      ScheduleUiState.initial().copyWith(focusedDay: DateTime(2026, 10, 7));
}

int auditStep = 1;
final auditConfig = DutyScheduleConfig(
  version: '1',
  meta: Meta(
    name: 'Audit Dienstplan',
    description: 'Testplan',
    startDate: DateTime(2026),
    startWeekDay: 'Monday',
    days: const [],
  ),
  dutyTypes: const {},
  dutyTypeOrder: const [],
  rhythms: const {},
  dutyGroups: const [
    DutyGroup(id: '1', name: 'Gruppe 1', rhythm: '1', offsetWeeks: 0),
  ],
);

class AuditPartner extends PartnerNotifier {
  @override
  Future<PartnerUiState> build() async => PartnerUiState.initial();
}

class AuditSetup extends SetupNotifier {
  @override
  Future<SetupUiState> build() async => SetupUiState.initial().copyWith(
    isLoading: false,
    currentStep: auditStep,
    selectedConfig: auditConfig,
    selectedPartnerConfig: auditConfig,
    selectedDutyGroup: "Gruppe 1",
    configs: [auditConfig],
    filteredConfigs: [auditConfig],
  );
}

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      for (final size in [const Size(320, 640), const Size(740, 360)]) {
        for (final screen in [
          'setup1',
          'setup2',
          'setup3',
          'setup4',
          'setup5',
          'header',
        ]) {
          testWidgets('audit $screen dark=$dark scale=$scale size=$size', (
            tester,
          ) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            if (screen == 'privacy') {
              rootBundle.clear();
              await tester.runAsync(
                () => rootBundle.loadString('assets/legal/datenschutz.md'),
              );
            }
            auditStep = screen.startsWith('setup')
                ? int.parse(screen.substring(5))
                : 1;
            final container = ProviderContainer(
              overrides: [
                setupProvider.overrideWith(AuditSetup.new),
                partnerProvider.overrideWith(AuditPartner.new),
                scheduleCoordinatorProvider.overrideWith(AuditCoordinator.new),
              ],
            );
            addTearDown(container.dispose);
            final theme = container.read(
              dark ? appDarkThemeProvider : appThemeProvider,
            );
            final Widget child = switch (screen) {
              'feedback' => ContactFeedbackScreen(
                initialScreenshot: SentryAttachment.fromScreenshotData(
                  Uint8List.fromList(_transparentPng),
                ),
              ),
              'settings' => const SettingsScreen(),
              'disclaimer' => const DisclaimerScreen(),
              'privacy' => const PrivacyPolicyScreen(),
              'header' => const Scaffold(body: CalendarHeader()),
              _ => const SetupScreen(),
            };
            await tester.pumpWidget(
              UncontrolledProviderScope(
                container: container,
                child: MaterialApp(
                  theme: theme,
                  locale: const Locale('de'),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,
                  builder: (context, child) => AppGlassTheme(
                    child: MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: TextScaler.linear(scale)),
                      child: child!,
                    ),
                  ),
                  home: child,
                ),
              ),
            );
            if (screen == 'privacy')
              await tester.runAsync(() async {
                await Future<void>.delayed(const Duration(milliseconds: 100));
              });
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }
}

const List<int> _transparentPng = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
