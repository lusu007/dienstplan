import '../support/app_test_builder.dart';

import 'package:dienstplan/presentation/widgets/common/settings_page_transition.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('foreground enters after the route has already become opaque', (
    tester,
  ) async {
    final primary = AnimationController(vsync: tester, value: 1);
    final secondary = AnimationController(vsync: tester);
    await tester.pumpWidget(
      MaterialApp(
        builder: appTestBuilder(),
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
          builder: appTestBuilder(),
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

  testWidgets('normal back motion visibly responds in its first 40ms', (
    tester,
  ) async {
    final primary = AnimationController(
      vsync: tester,
      value: 1,
      duration: const Duration(milliseconds: 270),
    );
    final secondary = AnimationController(vsync: tester);
    addTearDown(() {
      primary.dispose();
      secondary.dispose();
    });
    try {
      await tester.pumpWidget(
        MaterialApp(
          builder: appTestBuilder(),
          home: SettingsPageTransition(
            animation: primary,
            secondaryAnimation: secondary,
            child: Builder(
              builder: (context) => SettingsPageMotionScope.wrap(
                context,
                Scaffold(
                  body: SettingsPageMotionScope.fadeTitle(
                    context,
                    const Text('Category'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      primary.reverse();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final slide = tester.widget<SlideTransition>(
        find.byType(SlideTransition).last,
      );
      final fade = tester.widget<FadeTransition>(
        find.byType(FadeTransition).last,
      );
      expect(slide.position.value.dx, greaterThan(.02));
      expect(fade.opacity.value, lessThan(.8));
    } finally {
      primary.stop();
      secondary.stop();
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets(
    'Back during entrance preserves the currently visible position and opacity',
    (tester) async {
      final primary = AnimationController(
        vsync: tester,
        value: 1,
        duration: const Duration(milliseconds: 160),
      );
      final secondary = AnimationController(vsync: tester);
      addTearDown(() {
        primary.dispose();
        secondary.dispose();
      });
      try {
        await tester.pumpWidget(
          MaterialApp(
            builder: appTestBuilder(),
            home: SettingsPageTransition(
              animation: primary,
              secondaryAnimation: secondary,
              child: Builder(
                builder: (context) => SettingsPageMotionScope.wrap(
                  context,
                  Scaffold(
                    body: SettingsPageMotionScope.fadeTitle(
                      context,
                      const Text('Category'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 135));
        final beforePosition = tester
            .widget<SlideTransition>(find.byType(SlideTransition).last)
            .position
            .value
            .dx;
        final beforeOpacity = tester
            .widget<FadeTransition>(find.byType(FadeTransition).last)
            .opacity
            .value;
        expect(beforePosition, greaterThan(0));
        expect(beforeOpacity, inExclusiveRange(0, 1));
        primary.reverse();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));
        expect(
          tester
              .widget<SlideTransition>(find.byType(SlideTransition).last)
              .position
              .value
              .dx,
          closeTo(beforePosition, .005),
        );
        expect(
          tester
              .widget<FadeTransition>(find.byType(FadeTransition).last)
              .opacity
              .value,
          closeTo(beforeOpacity, .04),
        );
        await tester.pump(const Duration(milliseconds: 40));
        expect(
          tester
              .widget<SlideTransition>(find.byType(SlideTransition).last)
              .position
              .value
              .dx,
          greaterThan(beforePosition),
        );
      } finally {
        primary.stop();
        secondary.stop();
        await tester.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets(
    'settings retain form state and stable glass quality during push/pop',
    (tester) async {
      final primary = AnimationController(vsync: tester, value: 1);
      final secondary = AnimationController(vsync: tester);
      await tester.pumpWidget(
        MaterialApp(
          builder: appTestBuilder(
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
          builder: appTestBuilder(
            builder: (_, child) => MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: child!,
            ),
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
