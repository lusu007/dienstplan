import '../support/app_test_builder.dart';

import 'package:dienstplan/presentation/widgets/common/glass_card.dart';

import 'package:dienstplan/core/di/riverpod_providers.dart';

import 'package:dienstplan/core/constants/prefs_keys.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/l10n/app_localizations_delegates.dart';
import 'package:dienstplan/presentation/screens/release_history_screen.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/whats_new_host.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/app_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Partner extends PartnerNotifier {
  @override
  Future<PartnerUiState> build() async => PartnerUiState.initial();
}

Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  ThemeData? theme,
  double scale = 1,
  EdgeInsets padding = EdgeInsets.zero,
}) => ProviderScope(
  overrides: [partnerProvider.overrideWith(_Partner.new)],
  child: MaterialApp(
    builder: appTestBuilder(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale), padding: padding),
        child: child!,
      ),
    ),
    theme: theme ?? ThemeData(brightness: brightness),
    locale: const Locale('de'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

void main() {
  setUp(
    () => PackageInfo.setMockInitialValues(
      appName: 'Dienstplan',
      packageName: 'test',
      version: '0.20.0',
      buildNumber: '4014',
      buildSignature: '',
    ),
  );

  testWidgets(
    'settings opens full offline history without acknowledging unseen changes',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        kPrefsKeyWhatsNewAcknowledgedVersion: '0.17.0+12',
      });
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(host(const AppSection()));
      await tester.tap(find.text('Was ist neu für dich?'));
      await tester.pumpAndSettle();
      expect(find.text('Alle Änderungen'), findsOneWidget);
      expect(find.text('VERSION 0.20.0'), findsOneWidget);
      expect(find.text('iOS 15 erforderlich'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('VERSION 0.0.2'),
        800,
        maxScrolls: 100,
      );
      expect(find.text('VERSION 0.0.2').hitTestable(), findsOneWidget);
      expect(
        prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion),
        '0.17.0+12',
      );
      await tester.tap(find.byTooltip('Zurück'));
      await tester.pumpAndSettle();
      expect(find.text('Was ist neu für dich?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '0.4 maintenance history displays one version range with concise distinct rows',
    (tester) async {
      await tester.pumpWidget(
        host(const ReleaseHistoryScreen(currentVersion: '0.4.41')),
      );
      await tester.pumpAndSettle();
      expect(find.text('VERSIONEN 0.4.0–0.4.41'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(GlassCardGroup).first,
          matching: find.text('Wartungsupdate'),
        ),
        findsOneWidget,
      );
      expect(find.text('iOS-Version vorbereitet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('history excludes catalogue releases newer than installed app', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const ReleaseHistoryScreen(currentVersion: '0.19.0+12')),
    );
    await tester.pumpAndSettle();
    expect(find.text('VERSION 0.19.0'), findsOneWidget);
    expect(find.text('VERSION 0.20.0'), findsNothing);
    expect(find.text('Alle Änderungen im Blick'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'compact landscape with system insets and double text keeps highlights and actions reachable',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(640, 320);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showWhatsNewDialog(context),
              child: const Text('Open'),
            ),
          ),
          brightness: Brightness.dark,
          scale: 2,
          padding: const EdgeInsets.symmetric(vertical: 24),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Alles klar').hitTestable(), findsOneWidget);
      expect(find.text('Alle Änderungen').hitTestable(), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Ruhige Monatsanzeige'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Ruhige Monatsanzeige').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Alles klar'));
      await tester.pumpAndSettle();
      expect(find.text('Open').hitTestable(), findsOneWidget);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'summary and history text stay readable in the actual $brightness app palette',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 1800);
        addTearDown(tester.view.reset);
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final theme = container.read(
          brightness == Brightness.dark
              ? appDarkThemeProvider
              : appThemeProvider,
        );
        void readable(String text) {
          final rich = tester.widget<RichText>(
            find.descendant(
              of: find.text(text),
              matching: find.byType(RichText),
            ),
          );
          final color = rich.text.style!.color!;
          final a = color.computeLuminance();
          final b = theme.colorScheme.surface.computeLuminance();
          expect(
            ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
            greaterThanOrEqualTo(4.5),
            reason: text,
          );
        }

        await tester.pumpWidget(
          host(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showWhatsNewDialog(context),
                child: const Text('Open'),
              ),
            ),
            theme: theme,
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        readable('Alle Änderungen im Blick');
        readable('Ruhige Monatsanzeige');
        readable('Alle Änderungen');
        await tester.tap(find.text('Alle Änderungen'));
        await tester.pumpAndSettle();
        readable('Alle Änderungen im Blick');
        readable('Ruhige Monatsanzeige');
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final brightness in Brightness.values) {
    for (final size in [const Size(320, 680), const Size(844, 390)]) {
      testWidgets(
        'summary and history remain usable in $brightness at $size with large text',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            host(
              Builder(
                builder: (context) => TextButton(
                  onPressed: () => showWhatsNewDialog(context),
                  child: const Text('Open'),
                ),
              ),
              brightness: brightness,
              scale: size.width < 400 ? 1.8 : 1.3,
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          expect(find.text('Alles klar').hitTestable(), findsOneWidget);
          expect(find.text('Alle Änderungen').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Alle Änderungen'));
          await tester.pumpAndSettle();
          expect(find.byTooltip('Zurück').hitTestable(), findsOneWidget);
          await tester.scrollUntilVisible(find.text('VERSION 0.19.0'), 400);
          await tester.pumpAndSettle();
          expect(find.text('VERSION 0.19.0').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('Zurück'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Alles klar'));
          await tester.pumpAndSettle();
          expect(find.text('Open').hitTestable(), findsOneWidget);
        },
      );
    }
  }
}
