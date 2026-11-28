import '../support/app_test_builder.dart';

import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';

import 'package:dienstplan/core/constants/prefs_keys.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/l10n/app_localizations_delegates.dart';
import 'package:dienstplan/data/services/whats_new_service.dart';
import 'package:dienstplan/presentation/widgets/common/whats_new_host.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Partner extends PartnerNotifier {
  @override
  Future<PartnerUiState> build() async => PartnerUiState.initial();
}

Future<SharedPreferences> mountHost(
  WidgetTester tester, {
  String? previous,
  String current = '0.20.0',
  String build = '4014',
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1000, 1600);
  addTearDown(tester.view.reset);
  PackageInfo.setMockInitialValues(
    appName: 'Dienstplan',
    packageName: 'test',
    version: current,
    buildNumber: build,
    buildSignature: '',
  );
  SharedPreferences.setMockInitialValues({
    kPrefsKeyWhatsNewAcknowledgedVersion: ?previous,
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        partnerProvider.overrideWith(_Partner.new),
        whatsNewServiceProvider.overrideWith(
          (ref) async => WhatsNewService(prefs),
        ),
      ],
      child: MaterialApp(
        builder: appTestBuilder(),
        locale: const Locale('de'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const WhatsNewHost(child: Scaffold(body: Text('Home'))),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return prefs;
}

void main() {
  testWidgets(
    'skipped releases show earlier features alongside current changes',
    (tester) async {
      final prefs = await mountHost(tester, previous: '0.17.0+12');
      expect(find.text('Eigene Dienste über Mitternacht'), findsOneWidget);
      expect(find.text('Flüssiger Tageswechsel'), findsOneWidget);
      expect(
        prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion),
        '0.17.0+12',
      );
      await tester.tap(find.text('Alles klar'));
      await tester.pumpAndSettle();
      expect(
        prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion),
        '0.20.0+4014',
      );
    },
  );
  testWidgets('first install records baseline without interrupting', (
    tester,
  ) async {
    final prefs = await mountHost(tester);
    expect(find.text('Das ist neu für dich'), findsNothing);
    expect(
      prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion),
      '0.20.0+4014',
    );
  });
  testWidgets('maintenance-only update silently advances baseline', (
    tester,
  ) async {
    final prefs = await mountHost(
      tester,
      previous: '0.19.0+1',
      current: '0.19.1',
    );
    expect(find.text('Das ist neu für dich'), findsNothing);
    expect(
      prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion),
      '0.19.1+4014',
    );
  });
  testWidgets('build-only change does not reopen notes', (tester) async {
    final prefs = await mountHost(
      tester,
      previous: '0.19.0+1',
      current: '0.19.0',
    );
    expect(find.text('Das ist neu für dich'), findsNothing);
    expect(prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion), '0.19.0+1');
  });
  testWidgets('downgrade preserves newer baseline', (tester) async {
    final prefs = await mountHost(
      tester,
      previous: '0.20.0+1',
      current: '0.19.0',
    );
    expect(find.text('Das ist neu für dich'), findsNothing);
    expect(prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion), '0.20.0+1');
  });
  testWidgets('invalid legacy preference is repaired without a popup', (
    tester,
  ) async {
    final prefs = await mountHost(tester, previous: 'broken');
    expect(find.text('Das ist neu für dich'), findsNothing);
    expect(
      prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion),
      '0.20.0+4014',
    );
  });
  testWidgets(
    'opening history keeps summary unacknowledged until returning and dismissing',
    (tester) async {
      final prefs = await mountHost(tester, previous: '0.19.2+1');
      await tester.tap(find.text('Alle Änderungen'));
      await tester.pumpAndSettle();
      expect(find.text('Version 0.20.0'), findsOneWidget);
      expect(find.text('iOS 15 erforderlich'), findsOneWidget);
      expect(prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion), '0.19.2+1');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Alles klar'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion),
        '0.20.0+4014',
      );
      // A new host after restarting must not present the same update again.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            partnerProvider.overrideWith(_Partner.new),
            whatsNewServiceProvider.overrideWith(
              (ref) async => WhatsNewService(prefs),
            ),
          ],
          child: MaterialApp(
            builder: appTestBuilder(),
            locale: const Locale('de'),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const WhatsNewHost(child: Scaffold(body: Text('Home'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Das ist neu für dich'), findsNothing);
    },
  );
}
