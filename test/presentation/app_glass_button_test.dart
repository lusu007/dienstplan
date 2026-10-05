import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  double scale = 1,
}) => MaterialApp(
  theme: ThemeData(brightness: brightness),
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Center(child: child),
    ),
  ),
);
void main() {
  testWidgets('disabled quiet action does not acquire a glass surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const AppGlassButton(
          role: AppGlassButtonRole.quiet,
          onPressed: null,
          child: Text('Abbrechen'),
        ),
      ),
    );
    expect(find.byType(AppGlassSurface), findsNothing);
  });
  for (final brightness in Brightness.values) {
    testWidgets(
      'held icon flexes subtly with its outline while dragging in $brightness',
      (tester) async {
        await tester.pumpWidget(
          AppGlassTheme(
            child: host(
              AppGlassIconButton(
                icon: Icons.calendar_today,
                tooltip: 'Heute',
                onPressed: () {},
              ),
              brightness: brightness,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final icon = find.byIcon(Icons.calendar_today);
        final original = tester.getRect(icon);
        final gesture = await tester.startGesture(tester.getCenter(icon));
        await tester.pump(const Duration(milliseconds: 500));
        await gesture.moveBy(const Offset(35, 20));
        for (var frame = 0; frame < 30; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        final dragged = tester.getRect(icon);
        expect((dragged.center - original.center).distance, lessThan(2));
        expect((dragged.width - original.width).abs(), greaterThan(0.1));
        expect((dragged.width - original.width).abs(), lessThan(2));
        final outline = find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is ShapeDecoration &&
              (widget.decoration as ShapeDecoration).shape is CircleBorder,
        );
        final glass = find.descendant(
          of: find.byType(liquid.GlassIconButton),
          matching: find.byType(liquid.AdaptiveGlass),
        );
        final outlineRect = tester.getRect(outline);
        final glassRect = tester.getRect(glass);
        expect(outlineRect.left, closeTo(glassRect.left, .1));
        expect(outlineRect.top, closeTo(glassRect.top, .1));
        expect(outlineRect.width, closeTo(glassRect.width, .1));
        expect(outlineRect.height, closeTo(glassRect.height, .1));
        await gesture.cancel();
        await tester.pumpAndSettle();
        expect(tester.getRect(icon).width, closeTo(original.width, .1));
      },
    );
  }

  testWidgets(
    'text button glass and outline flex together and settle on cancel',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        AppGlassTheme(
          child: host(
            AppGlassButton(
              onPressed: () => taps++,
              child: const Text('Aktion'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final label = find.text('Aktion');
      final original = tester.getRect(label);
      final gesture = await tester.startGesture(tester.getCenter(label));
      await tester.pump(const Duration(milliseconds: 500));
      await gesture.moveBy(const Offset(0, 40));
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final dragged = tester.getRect(label);
      expect(dragged.height, greaterThan(original.height + .1));
      expect(dragged.height, lessThan(original.height * 1.05));
      final outline = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is ShapeDecoration &&
            (widget.decoration as ShapeDecoration).shape
                is liquid.LiquidRoundedSuperellipse,
      );
      final glass = find.byType(liquid.AdaptiveGlass);
      final outlineRect = tester.getRect(outline);
      final glassRect = tester.getRect(glass);
      expect(outlineRect.left, closeTo(glassRect.left, .1));
      expect(outlineRect.top, closeTo(glassRect.top, .1));
      expect(outlineRect.width, closeTo(glassRect.width, .1));
      expect(outlineRect.height, closeTo(glassRect.height, .1));
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(taps, 0);
      expect(tester.getRect(label).height, closeTo(original.height, .1));
    },
  );

  testWidgets(
    'compact action includes its padded touch target without duplicate taps',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          AppGlassButton(
            compact: true,
            fontSize: 14,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onPressed: () => taps++,
            child: const Text('Löschen'),
          ),
        ),
      );
      final target = tester.getRect(find.byType(AppGlassButton));
      await tester.tapAt(target.topCenter + const Offset(0, 1));
      expect(taps, 1);
      await tester.tap(find.text('Löschen'));
      expect(taps, 2);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('reduced motion suppresses icon and text deformation', (
    tester,
  ) async {
    for (final iconButton in [false, true]) {
      await tester.pumpWidget(
        host(
          liquid.GlassAccessibilityScope(
            reduceMotion: true,
            child: iconButton
                ? AppGlassIconButton(
                    icon: Icons.today,
                    onPressed: () {},
                    tooltip: 'Heute',
                  )
                : AppGlassButton(onPressed: () {}, child: const Text('Aktion')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final content = iconButton
          ? find.byIcon(Icons.today)
          : find.text('Aktion');
      final original = tester.getRect(content);
      final gesture = await tester.startGesture(original.center);
      await gesture.moveBy(const Offset(35, 20));
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final dragged = tester.getRect(content);
      expect(dragged.left, closeTo(original.left, .1));
      expect(dragged.top, closeTo(original.top, .1));
      expect(dragged.width, closeTo(original.width, .1));
      expect(dragged.height, closeTo(original.height, .1));
      await gesture.cancel();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('destructive label meets contrast on observed light glass fill', (
    tester,
  ) async {
    final theme = ThemeData.light();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: AppGlassButton(
            role: AppGlassButtonRole.destructive,
            onPressed: () {},
            child: const Text('Reset'),
          ),
        ),
      ),
    );
    final textContext = tester.element(find.text('Reset'));
    final foreground = DefaultTextStyle.of(textContext).style.color!;
    // S22 Ultra screenshot: settled modal destructive fill, sampled away
    // from the foreground and the border.
    const background = Color.fromARGB(255, 225, 182, 187);
    final a = foreground.computeLuminance(), b = background.computeLuminance();
    expect(
      ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
      greaterThanOrEqualTo(4.5),
    );
  });
  testWidgets('button roles use native library styles', (tester) async {
    for (final role in AppGlassButtonRole.values) {
      await tester.pumpWidget(
        host(
          AppGlassButton(
            role: role,
            onPressed: () {},
            child: const Text('Aktion'),
          ),
        ),
      );
      final button = tester.widget<liquid.GlassButton>(
        find.byType(liquid.GlassButton),
      );
      expect(
        button.style,
        role == AppGlassButtonRole.primary
            ? liquid.GlassButtonStyle.prominent
            : role == AppGlassButtonRole.quiet
            ? liquid.GlassButtonStyle.transparent
            : liquid.GlassButtonStyle.filled,
      );
    }
  });
  testWidgets(
    'loading and disabled buttons never activate and spinner is not dimmed',
    (tester) async {
      var taps = 0;
      for (final brightness in Brightness.values) {
        for (final loading in [false, true]) {
          await tester.pumpWidget(
            host(
              AppGlassButton(
                enabled: false,
                isLoading: loading,
                onPressed: () => taps++,
                child: const Text('Speichern'),
              ),
              brightness: brightness,
            ),
          );
          await tester.tap(find.byType(AppGlassButton));
          expect(taps, 0);
          if (loading) {
            var opacity = 1.0;
            tester
                .element(find.byType(CircularProgressIndicator))
                .visitAncestorElements((e) {
                  if (e.widget is Opacity) {
                    opacity *= (e.widget as Opacity).opacity;
                  }
                  return true;
                });
            expect(opacity, 1);
          }
        }
      }
      await tester.pumpWidget(
        host(
          AppGlassButton(
            onPressed: () => taps++,
            child: const Text('Speichern'),
          ),
        ),
      );
      await tester.tap(find.text('Speichern'));
      expect(taps, 1);
      await tester.pumpAndSettle();
    },
  );
  testWidgets('long label wraps at large text size without clipping', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 200,
          child: AppGlassButton(
            height: 48,
            onPressed: () {},
            child: const Text('Kalendereinträge jetzt exportieren'),
          ),
        ),
        scale: 1.3,
      ),
    );
    expect(tester.takeException(), isNull);
    final label = find.text('Kalendereinträge jetzt exportieren');
    expect(
      tester.getSize(find.byType(AppGlassButton)).height,
      greaterThanOrEqualTo(tester.getSize(label).height + 16),
    );
  });
  testWidgets(
    'compact native icon button includes tappable 48dp target and tooltip',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          AppGlassIconButton(
            icon: Icons.today,
            tooltip: 'Heute',
            size: 36,
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.byType(liquid.GlassIconButton), findsOneWidget);
      final rect = tester.getRect(find.byType(AppGlassIconButton));
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
      expect(find.byTooltip('Heute'), findsOneWidget);
      await tester.tapAt(rect.topLeft + const Offset(2, 2));
      expect(taps, 1);
      await tester.tap(find.byIcon(Icons.today));
      expect(taps, 2);
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        host(
          const AppGlassIconButton(
            icon: Icons.today,
            tooltip: 'Heute',
            size: 36,
            onPressed: null,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.today));
      expect(taps, 2);
    },
  );
}
