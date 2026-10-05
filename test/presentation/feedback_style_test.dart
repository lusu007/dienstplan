import 'package:dienstplan/presentation/widgets/common/app_snack_bar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'glass notification wraps, keeps actions and queues messages (dark: $dark)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer.test();
        final theme = container.read(
          dark ? appDarkThemeProvider : appThemeProvider,
        );
        final messenger = GlobalKey<ScaffoldMessengerState>();
        var acted = 0;
        const message =
            'Zurücksetzen hat geklappt. Du kannst die App neu einrichten.';
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            scaffoldMessengerKey: messenger,
            home: const MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: Scaffold(body: SizedBox.expand()),
            ),
          ),
        );
        messenger.currentState!.showSnackBar(
          AppSnackBar(
            content: const Text(message),
            duration: const Duration(milliseconds: 500),
            action: SnackBarAction(
              label: 'Verstanden',
              onPressed: () => acted++,
            ),
          ),
        );
        messenger.currentState!.showSnackBar(
          AppSnackBar(content: const Text('Nächste Meldung')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(liquid.GlassContainer), findsOneWidget);
        expect(find.text(message), findsOneWidget);
        final messageWidget = tester.widget<Text>(find.text(message));
        expect(messageWidget.maxLines, isNull);
        expect(messageWidget.overflow, isNull);
        final style = DefaultTextStyle.of(
          tester.element(find.text(message)),
        ).style;
        final shield = tester
            .widgetList<ColoredBox>(find.byType(ColoredBox))
            .firstWhere((box) => box.color.a > .9 && box.color.a < 1);
        for (final backdrop in [Colors.white, Colors.black]) {
          expect(
            contrast(style.color!, Color.alphaBlend(shield.color, backdrop)),
            greaterThanOrEqualTo(4.5),
          );
        }
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('Nächste Meldung'), findsNothing);
        await tester.tap(find.text('Verstanden'));
        await tester.pumpAndSettle();
        expect(acted, 1);
        expect(find.text('Nächste Meldung'), findsOneWidget);
        messenger.currentState!.clearSnackBars();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final dark in [false, true]) {
    test(
      'feedback text stays readable over extreme backdrops (dark: $dark)',
      () {
        final container = ProviderContainer.test();
        final theme = container.read(
          dark ? appDarkThemeProvider : appThemeProvider,
        );
        final snack = theme.snackBarTheme;
        for (final backdrop in [
          Colors.white,
          Colors.black,
          Colors.blue,
          Colors.red,
        ]) {
          final fill = Color.alphaBlend(snack.backgroundColor!, backdrop);
          expect(
            contrast(snack.contentTextStyle!.color!, fill),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            contrast(snack.actionTextColor!, fill),
            greaterThanOrEqualTo(4.5),
          );
          final tooltip = theme.tooltipTheme;
          expect(
            tooltip.decoration,
            isNotNull,
            reason: 'Tooltip needs an app surface',
          );
          expect(
            tooltip.textStyle,
            isNotNull,
            reason: 'Tooltip needs app text colors',
          );
          final decoration = tooltip.decoration! as BoxDecoration;
          final tooltipFill = Color.alphaBlend(decoration.color!, backdrop);
          expect(
            contrast(tooltip.textStyle!.color!, tooltipFill),
            greaterThanOrEqualTo(4.5),
          );
        }
      },
    );
  }
}
