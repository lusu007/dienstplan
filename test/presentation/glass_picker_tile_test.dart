import 'package:dienstplan/presentation/widgets/common/glass_picker_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
