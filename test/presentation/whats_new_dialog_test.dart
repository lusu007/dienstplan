import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
import 'package:dienstplan/presentation/widgets/common/whats_new_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
