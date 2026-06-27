import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
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

  testWidgets('bottom sheet uses the same light root blur while opening', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return GlassBottomSheet(
                      children: <Widget>[
                        ListView(children: const <Widget>[Text('Content')]),
                      ],
                    );
                  },
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    Iterable<BackdropFilter> filters = tester.widgetList(
      find.byType(BackdropFilter),
    );
    expect(
      filters.where((BackdropFilter filter) => filter.enabled),
      hasLength(1),
    );
    expect(
      tester.widget<GlassDialogSurface>(find.byType(GlassDialogSurface)),
      isA<GlassDialogSurface>().having(
        (GlassDialogSurface surface) => surface.backdropBlurSigma,
        'backdropBlurSigma',
        8,
      ),
    );
    expect(find.byType(ShaderMask), findsNothing);

    await tester.pumpAndSettle();

    filters = tester.widgetList(find.byType(BackdropFilter));
    expect(
      filters.where((BackdropFilter filter) => filter.enabled),
      hasLength(1),
    );
    expect(
      tester.widget<GlassDialogSurface>(find.byType(GlassDialogSurface)),
      isA<GlassDialogSurface>().having(
        (GlassDialogSurface surface) => surface.backdropBlurSigma,
        'backdropBlurSigma',
        8,
      ),
    );
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('bottom sheet shows heavy content while modal route opens', (
    WidgetTester tester,
  ) async {
    const Key heavyContentKey = Key('heavy-content');

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return const GlassBottomSheet(
                      children: <Widget>[
                        Text('Header'),
                        Text('Heavy content', key: heavyContentKey),
                      ],
                    );
                  },
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(find.text('Header'), findsOneWidget);
    expect(find.byKey(heavyContentKey), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Header'), findsOneWidget);
    expect(find.byKey(heavyContentKey), findsOneWidget);
  });
}
