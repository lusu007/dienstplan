import 'package:dienstplan/presentation/widgets/common/glass_picker_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('light year range trigger retains whole label at narrow width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: SizedBox(
              width: 160,
              child: GlassPickerPillTrigger(label: '2018 – 2029', onTap: () {}),
            ),
          ),
        ),
      ),
    );
    expect(find.text('2018 – 2029'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'selected narrow year keeps scaled label and marker without overflow',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            textTheme: ThemeData.light().textTheme.copyWith(
              // Ahem glyphs are wider than Roboto: this matches a scaled four-digit
              // label that fits alone, but not alongside the added selection marker.
              titleMedium: const TextStyle(fontSize: 10),
            ),
          ),
          home: const Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: SizedBox(
                width: 58.5,
                height: 48.75,
                child: GlassPickerTile(
                  label: '2026',
                  isFocused: true,
                  isCurrent: false,
                  onTap: null,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('2026'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'focused light picker retains readable text and explicit selection',
    (tester) async {
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 140,
              height: 64,
              child: GlassPickerTile(
                label: 'Okt',
                isFocused: true,
                isCurrent: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('Okt'));
      final background = Color.alphaBlend(
        theme.colorScheme.primary.withValues(alpha: .38),
        theme.colorScheme.surface,
      );
      final foreground = Color.alphaBlend(text.style!.color!, background);
      final a = foreground.computeLuminance(),
          b = background.computeLuminance();
      expect(
        ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
        greaterThanOrEqualTo(4.5),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    },
  );
  testWidgets('focused picker tiles keep readable text in dark mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Column(
            children: <Widget>[
              GlassPickerTile(
                label: 'Jan',
                isFocused: true,
                isCurrent: false,
                onTap: () {},
              ),
              GlassPickerTile(
                label: '2026',
                isFocused: true,
                isCurrent: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final Color expectedColor = ThemeData.dark().colorScheme.onSurface;

    expect(tester.widget<Text>(find.text('Jan')).style?.color, expectedColor);
    expect(tester.widget<Text>(find.text('2026')).style?.color, expectedColor);
  });
}
