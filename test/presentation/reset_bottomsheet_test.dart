import 'dart:async';

import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:dienstplan/domain/repositories/personal_calendar_repository.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/reset_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ResetRepo implements PersonalCalendarRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'reset shows progress and disables cancel while dependencies load',
    (tester) async {
      final loading = Completer<ScheduleConfigService>();
      final container = ProviderContainer.test(
        overrides: [
          personalCalendarRepositoryProvider.overrideWith(
            (ref) async => _ResetRepo(),
          ),
          scheduleConfigServiceProvider.overrideWith((ref) => loading.future),
        ],
      );
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
      await tester.tap(find.text('Zurücksetzen').last);
      await tester.pump(const Duration(milliseconds: 200));
      final buttons = tester
          .widgetList<AppGlassButton>(find.byType(AppGlassButton))
          .toList();
      expect(buttons.first.isLoading, isTrue);
      expect(buttons.last.onPressed, isNull);
      loading.completeError(StateError('dependency unavailable'));
      await tester.pumpAndSettle();
      expect(
        find.text('Zurücksetzen ist fehlgeschlagen. Bitte versuche es erneut.'),
        findsOneWidget,
      );
      expect(find.text('Abbrechen'), findsOneWidget);
    },
  );

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
