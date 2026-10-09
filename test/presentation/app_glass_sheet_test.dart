import 'package:dienstplan/presentation/widgets/common/app_glass_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the settled backdrop even after 150ms press feedback', (
    tester,
  ) async {
    late BuildContext context;
    ModalRoute<dynamic>? route;
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => AppGlassSheetHost(child: child!),
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return Center(
                child: InkWell(
                  onTap: () => showAppGlassBottomSheet<void>(
                    context: c,
                    builder: (c) {
                      route = ModalRoute.of(c);
                      return const SizedBox(height: 200, child: Text('Sheet'));
                    },
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      await tester.runAsync(() => AppGlassSheetHost.prepare(context)),
      isTrue,
    );
    final press = await tester.startGesture(
      tester.getCenter(find.text('Open')),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await press.up();
    await tester.pumpAndSettle();
    expect(find.text('Sheet'), findsOneWidget);
    expect(find.byType(RawImage), findsWidgets);
    final image = tester.widget<RawImage>(find.byType(RawImage).first).image!;
    Navigator.of(context).pop();
    await tester.pump(const Duration(milliseconds: 70));
    expect(image.debugDisposed, isFalse);
    await tester.pump(const Duration(milliseconds: 250));
    // Fully off-screen must be painted before expensive live glass is restored.
    expect(route!.animation!.value, 0);
    expect(find.byType(RawImage), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(image.debugDisposed, isTrue);
  });

  testWidgets(
    'a protected sheet cannot be dismissed through its frozen backdrop',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => AppGlassSheetHost(child: child!),
          home: Scaffold(
            body: Builder(
              builder: (c) {
                context = c;
                return const Text('Background');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => AppGlassSheetHost.prepare(context)),
        isTrue,
      );
      showAppGlassBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => const SizedBox(height: 200, child: Text('Protected')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RawImage), findsWidgets);
      await tester.tapAt(const Offset(20, 40));
      await tester.pumpAndSettle();
      expect(find.text('Protected'), findsOneWidget);
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'memory pressure releases the idle snapshot and permits recapture',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => AppGlassSheetHost(child: child!),
          home: Scaffold(
            body: Builder(
              builder: (c) {
                context = c;
                return const Text('Background');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => AppGlassSheetHost.prepare(context)),
        isTrue,
      );
      tester.binding.handleMemoryPressure();
      showAppGlassBottomSheet<void>(
        context: context,
        builder: (_) =>
            const SizedBox(height: 200, child: Text('No cached image')),
      );
      await tester.pumpAndSettle();
      // Missing cache falls back immediately; no expensive capture delays a tap.
      expect(find.byType(RawImage), findsNothing);
      expect(find.text('No cached image'), findsOneWidget);
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => AppGlassSheetHost.prepare(context)),
        isTrue,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final dismissal in ['drag', 'immediate', 'memory pressure']) {
    testWidgets('prepared sheet closes safely after $dismissal', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => AppGlassSheetHost(child: child!),
          home: Scaffold(
            body: Builder(
              builder: (c) {
                context = c;
                return const Text('Background');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => AppGlassSheetHost.prepare(context)),
        isTrue,
      );
      final closed = showAppGlassBottomSheet<void>(
        context: context,
        builder: (_) => const GlassDialogSurface(
          backdropBlurSigma: 4,
          child: SizedBox(height: 200, child: Center(child: Text('Sheet'))),
        ),
      );
      if (dismissal == 'immediate') {
        Navigator.of(context).pop();
      } else {
        await tester.pumpAndSettle();
        final image = tester
            .widget<RawImage>(find.byType(RawImage).first)
            .image!;
        if (dismissal == 'memory pressure') {
          expect(
            tester.widget<AppGlassSurface>(find.byType(AppGlassSurface)).blur,
            0,
          );
          tester.binding.handleMemoryPressure();
          await tester.pump();
          expect(find.byType(RawImage), findsNothing);
          expect(image.debugDisposed, isTrue);
          expect(
            tester.widget<AppGlassSurface>(find.byType(AppGlassSurface)).blur,
            4,
          );
          expect(find.text('Sheet'), findsOneWidget);
          Navigator.of(context).pop();
        } else {
          await tester.drag(find.text('Sheet'), const Offset(0, 500));
        }
      }
      await tester.pumpAndSettle();
      await closed;
      expect(find.text('Sheet'), findsNothing);
      expect(find.text('Background'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('repeated barrier taps do not pop the page behind the sheet', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => AppGlassSheetHost(child: child!),
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('Home'));
          },
        ),
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (c) {
          context = c;
          return const Scaffold(body: Text('Settings page'));
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(
      await tester.runAsync(() => AppGlassSheetHost.prepare(context)),
      isTrue,
    );
    showAppGlassBottomSheet<void>(
      context: context,
      builder: (_) => const SizedBox(height: 200, child: Text('Sheet')),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 40));
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();
    expect(find.text('Settings page'), findsOneWidget);
    expect(find.text('Sheet'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
