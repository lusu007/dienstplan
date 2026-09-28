import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:dienstplan/presentation/widgets/common/glass_picker_controls.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

void main() {
  testWidgets(
    'bottom sheet has one library surface and non-refractive controls',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassBottomSheet(
              shrinkToContent: true,
              children: <Widget>[
                GlassFilterChip(
                  label: 'Dienst',
                  isSelected: true,
                  onTap: () {},
                ),
                GlassPickerPillTrigger(label: 'Juni 2026', onTap: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(liquid.GlassContainer), findsOneWidget);
      for (final button in tester.elementList(
        find.byType(liquid.GlassButton),
      )) {
        final inherited = button
            .dependOnInheritedWidgetOfExactType<liquid.InheritedLiquidGlass>();
        expect(inherited?.avoidsRefraction, isTrue);
      }
      expect(find.text('Dienst'), findsOneWidget);
      expect(find.text('Juni 2026'), findsOneWidget);
    },
  );

  testWidgets('bottom sheet retains its library material throughout opening', (
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

    expect(find.byType(liquid.GlassContainer), findsOneWidget);
    final Element materialBefore = tester.element(
      find.byType(liquid.GlassContainer),
    );
    expect(
      tester.widget<GlassDialogSurface>(find.byType(GlassDialogSurface)),
      isA<GlassDialogSurface>().having(
        (GlassDialogSurface surface) => surface.backdropBlurSigma,
        'backdropBlurSigma',
        glassSurfaceBlurBottomSheet,
      ),
    );
    expect(find.byType(ShaderMask), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(liquid.GlassContainer), findsOneWidget);
    expect(
      tester.element(find.byType(liquid.GlassContainer)),
      same(materialBefore),
    );
    expect(
      tester.widget<GlassDialogSurface>(find.byType(GlassDialogSurface)),
      isA<GlassDialogSurface>().having(
        (GlassDialogSurface surface) => surface.backdropBlurSigma,
        'backdropBlurSigma',
        glassSurfaceBlurBottomSheet,
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
