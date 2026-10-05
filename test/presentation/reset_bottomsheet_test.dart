import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/reset_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'cancel reset closes sheet without reading destructive services',
    (tester) async {
      final container = ProviderContainer.test();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => ResetBottomsheet.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Abbrechen'), findsOneWidget);
      expect(container.exists(personalCalendarRepositoryProvider), isFalse);
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(find.text('Abbrechen'), findsNothing);
      expect(container.exists(personalCalendarRepositoryProvider), isFalse);
      expect(container.exists(scheduleConfigServiceProvider), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
