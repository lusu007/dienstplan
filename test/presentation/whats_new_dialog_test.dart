import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
import 'package:dienstplan/presentation/widgets/common/whats_new_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'light whats new keeps confirmation reachable at narrow width and large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 680);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showWhatsNewDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Alles klar').hitTestable(), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alles klar'));
      await tester.pumpAndSettle();
      expect(find.text('Das ist neu für dich'), findsNothing);
    },
  );
  testWidgets('whats new dialog action has stronger dark mode contrast', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1600);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                showWhatsNewDialog(context);
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final Finder actionSurface = find.descendant(
      of: find.byType(GlassButtonSurface),
      matching: find.byType(liquid.GlassButton),
    );
    final liquid.GlassButton button = tester.widget<liquid.GlassButton>(
      actionSurface,
    );

    expect(button.settings!.glassColor.a, greaterThan(glassTintAlphaDark));
    final outlines = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(GlassButtonSurface),
            matching: find.byType(DecoratedBox),
          ),
        )
        .where(
          (box) =>
              box.position == DecorationPosition.foreground &&
              box.decoration is ShapeDecoration,
        );
    expect(outlines, hasLength(1));
    final outline =
        (outlines.single.decoration as ShapeDecoration).shape as OutlinedBorder;
    expect(outline.side.color.a, greaterThan(glassBorderAlphaDark));
  });
}
