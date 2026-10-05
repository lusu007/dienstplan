import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('selected $brightness chip has no inset selection fill', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: GlassFilterChip(
              label: 'Polizei Bremen',
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );
      final paintedSelection = find.descendant(
        of: find.byType(liquid.GlassChip),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              ((widget.decoration as BoxDecoration).color?.a ?? 0) > 0,
        ),
      );
      expect(paintedSelection, findsNothing);
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('filter states are distinct and readable in $brightness', (
      tester,
    ) async {
      final scheme = ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ).copyWith(primary: AppColors.primary);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: scheme),
          home: Scaffold(
            body: Column(
              children: [
                GlassFilterChip(label: 'Aus', isSelected: false, onTap: () {}),
                GlassFilterChip(
                  label: 'An',
                  isSelected: true,
                  showCheckmark: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      final chips = tester
          .widgetList<liquid.GlassChip>(find.byType(liquid.GlassChip))
          .toList();
      final on = Color.alphaBlend(
        chips[1].settings!.glassColor,
        scheme.surface,
      );
      expect(chips[1].settings!.bodyMode, liquid.GlassBodyMode.adaptive);
      expect(chips[1].settings!.glassColor.a, lessThan(0.4));
      final outlines = tester
          .widgetList<DecoratedBox>(
            find.byWidgetPredicate(
              (w) =>
                  w is DecoratedBox &&
                  w.decoration is ShapeDecoration &&
                  (w.decoration as ShapeDecoration).shape is StadiumBorder,
            ),
          )
          .toList();
      expect(outlines, hasLength(2));
      final selectedSide =
          ((outlines.last.decoration as ShapeDecoration).shape as StadiumBorder)
              .side;
      expect(selectedSide.width, greaterThanOrEqualTo(1.5));
      expect(selectedSide.color.a, greaterThan(0.5));
      final text = tester.widget<Text>(find.text('An'));
      expect(_contrastRatio(text.style!.color!, on), greaterThanOrEqualTo(4.5));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  }

  testWidgets('selected light chip is readable on pale tint', (tester) async {
    final scheme = ThemeData.light().colorScheme.copyWith(
      primary: const Color(0xFF00B89F),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: Scaffold(
          body: GlassFilterChip(
            label: 'Dienst',
            isSelected: true,
            onTap: () {},
          ),
        ),
      ),
    );
    final label = tester.widget<Text>(find.text('Dienst'));
    final bg = Color.alphaBlend(
      scheme.primary.withValues(alpha: .22),
      scheme.surface,
    );
    expect(
      _contrastRatio(Color.alphaBlend(label.style!.color!, bg), bg),
      greaterThanOrEqualTo(4.5),
    );
  });
  testWidgets('selected filter chip keeps readable text in dark mode', (
    WidgetTester tester,
  ) async {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(primary: AppColors.primary);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
        home: Scaffold(
          body: Center(
            child: GlassFilterChip(
              label: 'Dienst',
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    final Text label = tester.widget<Text>(find.text('Dienst'));
    final Color? labelColor = label.style?.color;

    expect(labelColor, isNotNull);
    expect(labelColor, isNot(colorScheme.primary));
    expect(
      _contrastRatio(labelColor!, colorScheme.primary),
      greaterThanOrEqualTo(3.0),
    );
  });
}

double _contrastRatio(Color a, Color b) {
  final double l1 = a.computeLuminance();
  final double l2 = b.computeLuminance();
  final double lighter = l1 > l2 ? l1 : l2;
  final double darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}
