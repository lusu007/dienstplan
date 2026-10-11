import 'package:dienstplan/presentation/widgets/common/settings_page_transition.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('foreground enters after the route has already become opaque', (
    tester,
  ) async {
    final primary = AnimationController(vsync: tester, value: 1);
    final secondary = AnimationController(vsync: tester);
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPageTransition(
          animation: primary,
          secondaryAnimation: secondary,
          child: Builder(
            builder: (context) => SettingsPageMotionScope.wrap(
              context,
              Scaffold(
                body: SettingsPageMotionScope.fadeTitle(
                  context,
                  const Text('Title'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<SlideTransition>(find.byType(SlideTransition).last)
          .position
          .value
          .dx,
      closeTo(.12, .001),
    );
    await tester.pump(const Duration(milliseconds: 135));
    final halfway = tester
        .widget<SlideTransition>(find.byType(SlideTransition).last)
        .position
        .value
        .dx;
    expect(halfway, greaterThan(0));
    expect(halfway, lessThan(.12));
    await tester.pump(const Duration(milliseconds: 135));
    expect(
      tester
          .widget<SlideTransition>(find.byType(SlideTransition).last)
          .position
          .value,
      Offset.zero,
    );
    expect(
      tester
          .widget<FadeTransition>(find.byType(FadeTransition).last)
          .opacity
          .value,
      1,
    );
    await tester.pumpWidget(const SizedBox());
    primary.dispose();
    secondary.dispose();
  });

  testWidgets(
    'back gesture follows progress directly and cancellation restores the page',
    (tester) async {
      final primary = AnimationController(vsync: tester, value: 1);
      final secondary = AnimationController(vsync: tester);
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPageTransition(
            animation: primary,
            secondaryAnimation: secondary,
            child: Builder(
              builder: (context) => SettingsPageMotionScope.wrap(
                context,
                Scaffold(
                  body: SettingsPageMotionScope.fadeTitle(
                    context,
                    const Text('Settings'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 270));
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.didStartUserGesture();
      primary.value = .5;
      await tester.pump();
      final slide = tester.widget<SlideTransition>(
        find.byType(SlideTransition, skipOffstage: false).last,
      );
      expect(slide.position.value.dx, closeTo(.06, .001));
      expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition).last)
            .opacity
            .value,
        closeTo(.5, .001),
      );
      primary.value = 1;
      navigator.didStopUserGesture();
      await tester.pump();
      expect(
        tester
            .widget<SlideTransition>(
              find.byType(SlideTransition, skipOffstage: false).last,
            )
            .position
            .value,
        Offset.zero,
      );
      await tester.pumpWidget(const SizedBox());
      primary.dispose();
      secondary.dispose();
    },
  );

  testWidgets(
    'settings retain form state and stable glass quality during push/pop',
    (tester) async {
      final primary = AnimationController(vsync: tester, value: 1);
      final secondary = AnimationController(vsync: tester);
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => liquid.GlassTheme(
            data: const liquid.GlassThemeData(
              light: liquid.GlassThemeVariant(
                quality: liquid.GlassQuality.standard,
              ),
              dark: liquid.GlassThemeVariant(
                quality: liquid.GlassQuality.standard,
              ),
            ),
            child: child!,
          ),
          home: SettingsPageTransition(
            animation: primary,
            secondaryAnimation: secondary,
            child: Builder(
              builder: (context) => SettingsPageMotionScope.wrap(
                context,
                const Scaffold(body: TextField()),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 270));
      final fieldState = tester.state(
        find.byType(TextField, skipOffstage: false),
      );
      await tester.enterText(
        find.byType(TextField, skipOffstage: false),
        'Retained',
      );
      void expectStablePage() {
        expect(
          identical(
            tester.state(find.byType(TextField, skipOffstage: false)),
            fieldState,
          ),
          isTrue,
        );
        expect(find.text('Retained', skipOffstage: false), findsOneWidget);
        final glass = tester.widget<liquid.GlassTheme>(
          find.byType(liquid.GlassTheme, skipOffstage: false).last,
        );
        expect(glass.data.light.quality, liquid.GlassQuality.standard);
        expect(glass.data.dark.quality, liquid.GlassQuality.standard);
      }

      expectStablePage();
      primary.value = .5;
      await tester.pump();
      expectStablePage();
      primary.value = 1;
      secondary.value = .5;
      await tester.pump();
      expectStablePage();
      expect(
        tester
            .widget<SlideTransition>(
              find.byType(SlideTransition, skipOffstage: false).last,
            )
            .position
            .value
            .dx,
        lessThan(0),
      );
      secondary.value = 0;
      await tester.pump();
      expectStablePage();
      await tester.pumpWidget(const SizedBox());
      primary.dispose();
      secondary.dispose();
    },
  );
  testWidgets(
    'reduced motion uses live content without translation or fading',
    (tester) async {
      final primary = AnimationController(vsync: tester, value: .5);
      final secondary = AnimationController(vsync: tester);
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: child!,
          ),
          home: SettingsPageTransition(
            animation: primary,
            secondaryAnimation: secondary,
            child: Builder(
              builder: (context) => SettingsPageMotionScope.wrap(
                context,
                Scaffold(
                  body: SettingsPageMotionScope.fadeTitle(
                    context,
                    const Text('Settings'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Settings'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
      expect(
        find.descendant(
          of: find.byType(SettingsPageTransition),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(SettingsPageTransition),
          matching: find.byType(SlideTransition),
        ),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
      primary.dispose();
      secondary.dispose();
    },
  );
}
