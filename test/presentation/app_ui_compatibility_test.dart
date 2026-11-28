import 'dart:ui';

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
// Exercise the real third-party boundary while dependencies use SDK widgets.
// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' as legacy_cupertino;
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy_material;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material;

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'legacy widgets keep German labels and the selected ${brightness.name} theme',
      (tester) async {
        const primary = Color(0xff5b246d);
        const cupertinoPrimary = Color(0xff127867);
        await tester.pumpWidget(
          material.MaterialApp(
            theme: material.ThemeData(
              brightness: brightness,
              colorScheme: material.ColorScheme.fromSeed(
                seedColor: primary,
                brightness: brightness,
              ).copyWith(primary: primary),
              cupertinoOverrideTheme: cupertino.CupertinoThemeData(
                brightness: brightness,
                primaryColor: cupertinoPrimary,
              ),
            ),
            locale: const Locale('de'),
            supportedLocales: const [Locale('de')],
            localizationsDelegates:
                material.GlobalMaterialLocalizations.delegates,
            builder: (context, child) => AppGlassTheme(child: child!),
            home: material.Builder(
              builder: (context) {
                final legacyTheme = legacy_material.Theme.of(context);
                final legacyCupertino = legacy_cupertino.CupertinoTheme.of(
                  context,
                );
                final labels =
                    material.Localizations.of<
                      legacy_material.MaterialLocalizations
                    >(context, legacy_material.MaterialLocalizations);
                return material.Column(
                  children: [
                    material.ColoredBox(
                      key: const material.ValueKey('material-primary'),
                      color: legacyTheme.colorScheme.primary,
                      child: material.Text(legacyTheme.brightness.name),
                    ),
                    material.ColoredBox(
                      key: const material.ValueKey('cupertino-primary'),
                      color: legacyCupertino.primaryColor,
                      child: material.Text(
                        legacyCupertino.brightness?.name ?? 'unspecified',
                      ),
                    ),
                    material.Text(
                      labels?.backButtonTooltip ?? 'missing labels',
                    ),
                  ],
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Zurück'), findsOneWidget);
        expect(find.text(brightness.name), findsNWidgets(2));
        expect(
          tester
              .widget<material.ColoredBox>(
                find.byKey(const material.ValueKey('material-primary')),
              )
              .color,
          primary,
        );
        expect(
          tester
              .widget<material.ColoredBox>(
                find.byKey(const material.ValueKey('cupertino-primary')),
              )
              .color,
          cupertinoPrimary,
        );
      },
    );
  }
}
