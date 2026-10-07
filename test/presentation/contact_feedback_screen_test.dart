import 'dart:typed_data';

import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/screens/contact_feedback_screen.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/glass_dialog_surface.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  for (final action in ['cancel', 'back', 'failed capture']) {
    testWidgets(
      'screenshot selection $action restores draft and previous attachment',
      (tester) async {
        late BuildContext feedbackContext;
        final previous = SentryAttachment.fromScreenshotData(
          Uint8List.fromList(_transparentPng),
        );
        await tester.pumpWidget(
          _TestApp(
            child: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) {
                        feedbackContext = ctx;
                        return const ContactFeedbackScreen();
                      },
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await ContactFeedbackScreenshotCoordinator.start(
          context: feedbackContext,
          draft: const ContactFeedbackDraft(message: 'Mein Entwurf'),
          initialScreenshot: previous,
          captureScreenshot: () async => null,
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('contact_feedback_take_app_screenshot')),
          findsOneWidget,
        );
        if (action == 'back') {
          await Navigator.of(tester.element(find.text('Open'))).maybePop();
        } else {
          await tester.tap(
            find.byKey(
              ValueKey(
                action == 'cancel'
                    ? 'contact_feedback_cancel_app_screenshot'
                    : 'contact_feedback_take_app_screenshot',
              ),
            ),
          );
        }
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('contact_feedback_take_app_screenshot')),
          findsNothing,
        );
        expect(find.text('Mein Entwurf'), findsOneWidget);
        expect(find.text('Screenshot angehängt'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Änderungen verwerfen?'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'removing screenshot host cleans overlay without reopening draft',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      late BuildContext feedbackContext;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('Root')),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      final host = MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Host')),
      );
      navigatorKey.currentState!.push(host);
      await tester.pumpAndSettle();
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (context) {
            feedbackContext = context;
            return const ContactFeedbackScreen();
          },
        ),
      );
      await tester.pumpAndSettle();
      await ContactFeedbackScreenshotCoordinator.start(
        context: feedbackContext,
        draft: const ContactFeedbackDraft(message: 'Removed draft'),
      );
      await tester.pumpAndSettle();
      navigatorKey.currentState!.removeRoute(host);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('contact_feedback_take_app_screenshot')),
        findsNothing,
      );
      expect(find.text('Removed draft'), findsNothing);
      expect(find.text('Root'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dirty feedback back asks before losing message', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ContactFeedbackScreen(),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Mein Entwurf');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Änderungen verwerfen?'), findsOneWidget);
    await tester.tap(find.text('Weiter bearbeiten'));
    await tester.pumpAndSettle();
    expect(find.text('Mein Entwurf'), findsOneWidget);
  });

  testWidgets(
    'attached screenshot stays readable and removable with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var submissions = 0;
      await tester.pumpWidget(
        _TestApp(
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: ContactFeedbackScreen(
              initialScreenshot: SentryAttachment.fromScreenshotData(
                Uint8List.fromList(_transparentPng),
              ),
              onSubmitFeedback: (_, _) async {
                submissions++;
                return SentryId.newId();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.text('Screenshot angehängt')).width,
        greaterThan(150),
      );
      await tester.ensureVisible(find.text('Screenshot entfernen'));
      await tester.tap(find.text('Screenshot entfernen'));
      await tester.pumpAndSettle();
      expect(find.text('Screenshot angehängt'), findsNothing);
      expect(find.text('Screenshot anhängen'), findsOneWidget);
      expect(submissions, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('feedback screen uses glass design primitives', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: ContactFeedbackScreen(
          onSubmitFeedback: (_, _) async => SentryId.newId(),
          captureScreenshot: () async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GlassScreenScaffold), findsOneWidget);
    expect(find.byType(ScrollFadeMask), findsNothing);
    expect(find.text('Feedback'), findsOneWidget);
    final SingleChildScrollView scrollView = tester.widget(
      find.byType(SingleChildScrollView),
    );
    expect(
      scrollView.padding,
      const EdgeInsets.fromLTRB(
        glassSpacingLg,
        glassSpacingXl - 4,
        glassSpacingLg,
        glassSpacingXxl,
      ),
    );
    expect(find.byType(GlassDialogSurface), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(ActionButton), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Abbrechen'), findsNothing);
    expect(find.text('Sag uns, was nicht rund läuft'), findsOneWidget);
    expect(
      find.textContaining('Beschreibe kurz, was passiert ist'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('contact_feedback_message_textfield')),
      findsOneWidget,
    );
  });

  testWidgets('feedback screen submits sentry feedback payload', (
    tester,
  ) async {
    SentryFeedback? submittedFeedback;
    Hint? submittedHint;

    await tester.pumpWidget(
      _TestApp(
        child: ContactFeedbackScreen(
          onSubmitFeedback: (feedback, hint) async {
            submittedFeedback = feedback;
            submittedHint = hint;
            return SentryId.fromId('00000000000000000000000000000001');
          },
          captureScreenshot: () async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('contact_feedback_name_textfield')),
      'Max Mustermann',
    );
    await tester.enterText(
      find.byKey(const ValueKey('contact_feedback_email_textfield')),
      'max@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('contact_feedback_message_textfield')),
      'Der Kalender springt beim Öffnen.',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('contact_feedback_submit')),
    );
    await tester.tap(find.byKey(const ValueKey('contact_feedback_submit')));
    await tester.pumpAndSettle();

    expect(submittedFeedback, isNotNull);
    expect(submittedFeedback!.name, 'Max Mustermann');
    expect(submittedFeedback!.contactEmail, 'max@example.com');
    expect(submittedFeedback!.message, 'Der Kalender springt beim Öffnen.');
    expect(submittedHint, isNotNull);
    // ignore: invalid_use_of_internal_member
    expect(submittedHint!.get(TypeCheckHint.isWidgetFeedback), isTrue);
    expect(find.text('Vielen Dank für dein Feedback!'), findsOneWidget);
  });

  testWidgets('feedback screen starts app screenshot selection with draft', (
    tester,
  ) async {
    ContactFeedbackDraft? startedDraft;

    await tester.pumpWidget(
      _TestApp(
        child: ContactFeedbackScreen(
          onSubmitFeedback: (_, _) async => SentryId.newId(),
          startScreenshotSelection: (draft) async {
            startedDraft = draft;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('contact_feedback_name_textfield')),
      'Max Mustermann',
    );
    await tester.enterText(
      find.byKey(const ValueKey('contact_feedback_email_textfield')),
      'max@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('contact_feedback_message_textfield')),
      'Der Monatsplan ist abgeschnitten.',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('contact_feedback_capture_screenshot')),
    );
    await tester.tap(
      find.byKey(const ValueKey('contact_feedback_capture_screenshot')),
    );
    await tester.pumpAndSettle();

    expect(startedDraft, isNotNull);
    expect(startedDraft!.name, 'Max Mustermann');
    expect(startedDraft!.email, 'max@example.com');
    expect(startedDraft!.message, 'Der Monatsplan ist abgeschnitten.');
  });

  testWidgets('feedback screen restores preserved draft', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: ContactFeedbackScreen(
          onSubmitFeedback: (_, _) async => SentryId.newId(),
          captureScreenshot: () async => null,
          initialDraft: const ContactFeedbackDraft(
            name: 'Max Mustermann',
            email: 'max@example.com',
            message: 'Der Monatsplan ist abgeschnitten.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Max Mustermann'), findsOneWidget);
    expect(find.text('max@example.com'), findsOneWidget);
    expect(find.text('Der Monatsplan ist abgeschnitten.'), findsOneWidget);
  });

  testWidgets('feedback screen still supports injected screenshot capture', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: ContactFeedbackScreen(
          onSubmitFeedback: (_, _) async => SentryId.newId(),
          captureScreenshot: () async {
            return SentryAttachment.fromScreenshotData(
              Uint8List.fromList(_transparentPng),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('contact_feedback_capture_screenshot')),
    );
    await tester.tap(
      find.byKey(const ValueKey('contact_feedback_capture_screenshot')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Screenshot angehängt'), findsOneWidget);
  });

  testWidgets('feedback screen shows error when sentry drops feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: ContactFeedbackScreen(
          onSubmitFeedback: (_, _) async => const SentryId.empty(),
          captureScreenshot: () async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('contact_feedback_message_textfield')),
      'Das Feedback wird nicht zugestellt.',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('contact_feedback_submit')),
    );
    await tester.tap(find.byKey(const ValueKey('contact_feedback_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Feedback konnte nicht gesendet werden.'), findsOneWidget);
    expect(find.text('Vielen Dank für dein Feedback!'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [partnerProvider.overrideWith(() => _TestPartnerNotifier())],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

class _TestPartnerNotifier extends PartnerNotifier {
  @override
  Future<PartnerUiState> build() async => PartnerUiState.initial();
}

const List<int> _transparentPng = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
