import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/action_button.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:dienstplan/presentation/widgets/common/glass_app_dialog.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'glass follows app $brightness and rendering policy on $platform',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          tester.platformDispatcher.platformBrightnessTestValue =
              brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light;
          addTearDown(
            tester.platformDispatcher.clearPlatformBrightnessTestValue,
          );
          Brightness? actual;
          liquid.GlassQuality? quality;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              builder: (context, child) => AppGlassTheme(child: child!),
              home: Builder(
                builder: (context) {
                  actual = liquid.GlassTheme.brightnessOf(context);
                  quality = liquid.GlassThemeData.of(context)
                      .qualityFor(context);
                  return const Scaffold(body: Text('Theme'));
                },
              ),
            ),
          );
          debugDefaultTargetPlatformOverride = null;
          expect(actual, brightness);
          expect(quality, liquid.GlassQuality.standard);
        },
      );
    }
  }

  testWidgets('glass receives system accessibility preferences', (
    tester,
  ) async {
    liquid.GlassAccessibilityData? actual;
    liquid.GlassQuality? quality;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: true, highContrast: true),
          child: AppGlassTheme(child: child!),
        ),
        home: Builder(
          builder: (context) {
            actual = liquid.GlassAccessibilityData.of(context);
            quality = liquid.GlassThemeData.of(context).qualityFor(context);
            return const Scaffold(body: Text('Accessibility'));
          },
        ),
      ),
    );
    expect(actual!.reduceMotion, isTrue);
    expect(actual!.reduceTransparency, isTrue);
    // The package's minimal fast path precedes its accessibility fallback.
    expect(quality, liquid.GlassQuality.standard);
  });

  testWidgets('filter chips preserve selection and bounded expansion', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: Row(
                children: [
                  Expanded(
                    child: GlassFilterChip(
                      label: 'Dienst',
                      isSelected: true,
                      showCheckmark: true,
                      expandWidth: true,
                      onTap: () => taps++,
                    ),
                  ),
                  Expanded(
                    child: GlassFilterChip(
                      label: 'Alle',
                      isSelected: false,
                      expandWidth: true,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(liquid.GlassChip), findsNWidgets(2));
    expect(tester.getSize(find.byType(GlassFilterChip).first).width, 150);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.tap(find.text('Dienst'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app surfaces use library rendering and preserve content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassContainer(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Dienst'),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(liquid.GlassContainer), findsOneWidget);
    expect(find.text('Dienst'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('modal surface keeps nested surfaces non-refractive', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassDialogSurface(
              child: GlassContainer(child: Text('Auswahl')),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(liquid.GlassContainer), findsOneWidget);
    expect(find.text('Auswahl'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('button preserves dimensions and ignores disabled taps', (
    tester,
  ) async {
    var taps = 0;
    Widget button(bool enabled) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: GlassButtonSurface(
            onTap: () => taps++,
            borderRadius: 16,
            enabled: enabled,
            width: 180,
            height: 48,
            child: const Text('Speichern'),
          ),
        ),
      ),
    );
    await tester.pumpWidget(button(false));
    final outline = find.descendant(
      of: find.byType(GlassButtonSurface),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.position == DecorationPosition.foreground &&
            widget.decoration is ShapeDecoration &&
            ((widget.decoration as ShapeDecoration).shape as OutlinedBorder)
                    .side
                    .style ==
                BorderStyle.solid,
      ),
    );
    expect(outline, findsOneWidget);

    expect(
      tester.getSize(find.byType(GlassButtonSurface)),
      const Size(180, 48),
    );
    await tester.tap(find.text('Speichern'));
    expect(taps, 0);
    await tester.pumpWidget(button(true));
    expect(find.byType(liquid.GlassButton), findsOneWidget);
    expect(outline, findsOneWidget);
    await tester.tap(find.text('Speichern'));
    expect(taps, 1);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading action stays fully visible and cannot activate', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ActionButton(
              text: 'Weiter',
              isLoading: true,
              onPressed: () => taps++,
            ),
          ),
        ),
      ),
    );
    double opacity = 1;
    tester
        .element(find.byType(CircularProgressIndicator))
        .visitAncestorElements((element) {
          if (element.widget is Opacity) {
            opacity *= (element.widget as Opacity).opacity;
          }
          return true;
        });
    expect(opacity, 1);
    await tester.tap(find.byType(ActionButton));
    expect(taps, 0);
  });

  testWidgets('dialog preserves action result and barrier behavior', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  result = await GlassAppDialog.show<bool>(
                    context: context,
                    title: 'Bestätigen',
                    content: const Text('Inhalt'),
                    barrierDismissible: false,
                    actions: [
                      Builder(
                        builder: (dialogContext) => TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('OK'),
                        ),
                      ),
                    ],
                  );
                },
                child: const Text('Öffnen'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Öffnen'));
    await tester.pumpAndSettle();
    expect(find.byType(liquid.GlassContainer), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Inhalt'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(find.text('Inhalt'), findsNothing);
  });
}
