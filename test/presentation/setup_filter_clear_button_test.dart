import '../support/app_test_builder.dart';

import 'package:dienstplan/core/l10n/app_localizations_delegates.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_button_surface.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/police_authority_filter_chips.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'clear filters keeps its outline and only acts with a selection in $brightness',
      (tester) async {
        var cleared = 0;
        for (final selected in [false, true]) {
          await tester.pumpWidget(
            MaterialApp(
              builder: appTestBuilder(),
              theme: ThemeData(brightness: brightness),
              localizationsDelegates: appLocalizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: PoliceAuthorityFilterChips(
                  availableAuthorities: const {'Bremen'},
                  selectedAuthorities: selected ? {'Bremen'} : {},
                  onAuthorityToggled: (_) {},
                  onClearAll: () => cleared++,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final button = tester.widget<GlassButtonSurface>(
            find.byType(GlassButtonSurface),
          );
          expect(
            tester.getSize(find.byType(GlassButtonSurface)).height,
            lessThanOrEqualTo(36),
          );
          expect(
            tester.getSize(find.byType(AppGlassButton)).height,
            greaterThanOrEqualTo(48),
          );
          expect(
            tester.getSize(find.byType(GlassButtonSurface)).width,
            lessThan(200),
          );
          expect(button.borderColor!.a, greaterThan(0));
          expect(button.tintColor!.a, greaterThan(0));
          await tester.tap(find.text('Alle löschen'));
          expect(cleared, selected ? 1 : 0);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}
