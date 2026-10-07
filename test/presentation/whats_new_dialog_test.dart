import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
import 'package:dienstplan/presentation/widgets/common/whats_new_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'light whats new keeps confirmation reachable at narrow width and large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 680);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showWhatsNewDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Alles klar').hitTestable(), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alles klar'));
      await tester.pumpAndSettle();
      expect(find.text('Das ist neu für dich'), findsNothing);
    },
  );
  for (final brightness in Brightness.values) {
    testWidgets('whats new confirmation is readable in $brightness', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1600);
      addTearDown(tester.view.reset);
      final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF005B8C),
        brightness: brightness,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: scheme),
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showWhatsNewDialog(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final action = find.byType(AppGlassButton);
      final material = tester.widget<liquid.AdaptiveGlass>(
        find.descendant(
          of: action,
          matching: find.byType(liquid.AdaptiveGlass),
        ),
      );
      final text = tester.widget<RichText>(
        find.descendant(of: action, matching: find.byType(RichText)),
      );
      final foreground = text.text.style!.color!;
      // Use the effective material after the library applies button styling,
      // rather than the lower opacity requested by our wrapper.
      final background = Color.alphaBlend(
        material.settings.glassColor,
        scheme.surface,
      );
      final a = foreground.computeLuminance();
      final b = background.computeLuminance();
      expect(
        ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
        greaterThanOrEqualTo(4.5),
      );
      expect(find.text('Alles klar').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Alles klar'));
      await tester.pumpAndSettle();
      expect(find.text('Das ist neu für dich'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  for (final initialMode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('confirmation follows theme changes from $initialMode', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 1600);
      addTearDown(tester.view.reset);
      final mode = ValueNotifier(initialMode);
      addTearDown(mode.dispose);
      final light = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005B8C),
          brightness: Brightness.light,
        ),
      );
      final dark = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005B8C),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: mode,
          builder: (context, value, child) => MaterialApp(
            theme: light,
            darkTheme: dark,
            themeMode: value,
            locale: const Locale('de'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showWhatsNewDialog(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      mode.value = initialMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      await tester.pumpAndSettle();
      final label = tester.widget<RichText>(
        find.descendant(
          of: find.byType(AppGlassButton),
          matching: find.byType(RichText),
        ),
      );
      final activeTheme = mode.value == ThemeMode.dark ? dark : light;
      expect(label.text.style!.color, activeTheme.colorScheme.onSurface);
      await tester.tap(find.text('Alles klar'));
      await tester.pumpAndSettle();
      expect(find.text('Das ist neu für dich'), findsNothing);
    });
  }
}
