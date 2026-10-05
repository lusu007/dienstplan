import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/theme_mode_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

class _Settings extends SettingsNotifier {
  @override
  Future<SettingsUiState> build() async => SettingsUiState.initial().copyWith(
    themePreference: ThemePreference.light,
  );
  @override
  Future<void> setThemePreference(ThemePreference preference) async {
    state = AsyncData(state.value!.copyWith(themePreference: preference));
  }
}

void main() {
  test(
    'all default Light sheets use the shared barrier; Dark stays unchanged',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(appThemeProvider).bottomSheetTheme.modalBarrierColor!.a,
        closeTo(.35, .005),
      );
      expect(
        container.read(appDarkThemeProvider).bottomSheetTheme.modalBarrierColor,
        isNull,
      );
    },
  );
  testWidgets('open theme sheet follows theme without replacing its route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsProvider.overrideWith(_Settings.new)],
        child: Consumer(
          builder: (context, ref, _) {
            final pref =
                ref.watch(settingsProvider).value?.themePreference ??
                ThemePreference.light;
            return MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: pref == ThemePreference.dark
                  ? ThemeMode.dark
                  : pref == ThemePreference.system
                  ? ThemeMode.system
                  : ThemeMode.light,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => AppGlassTheme(child: child!),
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) => TextButton(
                    onPressed: () => ThemeModeBottomsheet.show(context, ref),
                    child: const Text('Open'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final route = ModalRoute.of(tester.element(find.text('Hell')))!;
    expect(route.barrierColor!.a, closeTo(.35, .005));
    expect(
      tester
          .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
          .color
          .value!
          .a,
      closeTo(.35, .005),
    );
    Material material() => tester.widget<Material>(
      find
          .descendant(
            of: find.byType(liquid.GlassSheet),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(
      tester
          .widget<liquid.GlassSheet>(find.byType(liquid.GlassSheet))
          .settings!
          .glassColor
          .a,
      greaterThanOrEqualTo(.85),
      reason: 'The light background must cover the handle and footer too',
    );
    expect(material().color, Colors.transparent);
    expect(
      tester
          .widget<liquid.GlassSheet>(find.byType(liquid.GlassSheet))
          .settings!
          .blur,
      4,
    );
    await tester.tap(find.text('Dunkel'));
    await tester.pumpAndSettle();
    expect(ModalRoute.of(tester.element(find.text('Hell'))), same(route));
    expect(material().color, Colors.transparent);
    expect(
      tester
          .widget<liquid.GlassSheet>(find.byType(liquid.GlassSheet))
          .settings!
          .glassColor
          .a,
      0,
      reason: 'Dark mode retains its original untinted glass surface',
    );
    expect(route.barrierColor, liquid.GlassDefaults.barrierColor);
    await tester.tap(find.text('Hell'));
    await tester.pumpAndSettle();
    expect(ModalRoute.of(tester.element(find.text('Hell'))), same(route));
    expect(
      tester
          .widget<liquid.GlassSheet>(find.byType(liquid.GlassSheet))
          .settings!
          .glassColor
          .a,
      greaterThanOrEqualTo(.85),
      reason: 'The light background must cover the handle and footer too',
    );
    expect(material().color, Colors.transparent);
    expect(route.barrierColor!.a, closeTo(.35, .005));
    expect(
      tester
          .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
          .color
          .value!
          .a,
      closeTo(.35, .005),
    );
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(ModalRoute.of(tester.element(find.text('Hell'))), same(route));
    expect(tester.takeException(), isNull);

    // The library's handle is outside the scrollable content: drag dismissal
    // must survive rebuilding the whole sheet after a theme change.
    await tester.fling(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.label == 'Schließen',
      ),
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.byType(liquid.GlassSheet), findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(liquid.GlassSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
