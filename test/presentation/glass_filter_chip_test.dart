import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
