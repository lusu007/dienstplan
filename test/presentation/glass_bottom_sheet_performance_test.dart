import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:dienstplan/presentation/widgets/common/glass_picker_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom sheet keeps only the root backdrop blur active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassBottomSheet(
            shrinkToContent: true,
            children: <Widget>[
              GlassFilterChip(label: 'Dienst', isSelected: true, onTap: () {}),
              GlassPickerPillTrigger(label: 'Juni 2026', onTap: () {}),
            ],
          ),
        ),
      ),
    );

    final Iterable<BackdropFilter> filters = tester.widgetList(
      find.byType(BackdropFilter),
    );

    expect(
      filters.where((BackdropFilter filter) => filter.enabled),
      hasLength(1),
    );
    expect(
      filters.where((BackdropFilter filter) => !filter.enabled),
      isNotEmpty,
    );
  });
}
