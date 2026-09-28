import 'dart:ui' as ui;

import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('grouped row colors survive state changes in $brightness', (
      tester,
    ) async {
      final boundaryKey = GlobalKey();
      var taps = 0;
      Future<void> show({
        bool active = false,
        bool enabled = true,
        Color? tint,
        Color? border,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: SizedBox(
                    width: 200,
                    child: GlassCardGroup(
                      children: [
                        GlassCard(
                          isActive: active,
                          enabled: enabled,
                          tintColor: tint,
                          tintAlpha: 0.8,
                          borderColor: border,
                          borderWidth: 4,
                          onTap: () => taps++,
                          child: const SizedBox(width: 200, height: 60),
                        ),
                        const GlassCard(
                          child: SizedBox(width: 200, height: 60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AppGlassSurface), findsOneWidget);
      }

      Future<Color> pixel(int x, int y) async =>
          (await tester.runAsync(() async {
            final boundary =
                boundaryKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final data = (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            final offset = (y * image.width + x) * 4;
            final color = Color.fromARGB(
              data.getUint8(offset + 3),
              data.getUint8(offset),
              data.getUint8(offset + 1),
              data.getUint8(offset + 2),
            );
            image.dispose();
            return color;
          }))!;

      await show();
      final neutral = await pixel(100, 30);
      final neighbor = await pixel(100, 90);
      await show(active: true);
      expect(await pixel(100, 30), isNot(neutral));
      expect(await pixel(100, 90), neighbor);
      await show();
      expect(await pixel(100, 30), neutral);

      await show(tint: Colors.red, border: Colors.green);
      final tinted = await pixel(100, 30);
      expect(tinted.r, greaterThan(tinted.g));
      final outlined = await pixel(100, 2);
      expect(outlined.g, greaterThan(outlined.r));
      final rowCenter =
          tester.getTopLeft(find.byKey(boundaryKey)) + const Offset(100, 30);
      await tester.tapAt(rowCenter);
      expect(taps, 1);

      await show(tint: Colors.red, border: Colors.green, enabled: false);
      final disabled = await pixel(100, 30);
      expect(disabled.r - disabled.g, lessThan(tinted.r - tinted.g));
      await tester.tapAt(rowCenter);
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
