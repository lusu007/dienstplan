import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_ui_state.dart';

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
  int deletes = 0;
  bool fails = false;
  Completer<void>? deleting;
  @override
  Future<Result<void>> deleteAll() async {
    deletes++;
    await deleting?.future;
    return fails
        ? Result.createFailure(
            const StorageFailure(technicalMessage: 'offline'),
          )
        : Result.success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ResetConfig implements ScheduleConfigService {
  int resets = 0;
  @override
  Future<void> resetSetup() async {
    resets++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ResetSettingsStats {
  int resets = 0;
  bool fails = false;
}

class _ResetSettings extends SettingsNotifier {
  _ResetSettings(this.stats);
  final _ResetSettingsStats stats;
  @override
  Future<SettingsUiState> build() async => SettingsUiState.initial();
  @override
  Future<void> reset() async {
    stats.resets++;
    state = AsyncData(
      SettingsUiState.initial().copyWith(
        error: stats.fails ? 'storage unavailable' : null,
      ),
    );
  }
}

class _ResetData extends ScheduleDataNotifier {
  @override
  Future<ScheduleDataUiState> build() async => ScheduleDataUiState.initial();
  @override
  void invalidateCache() {}
}

class _ResetRouter implements StackRouter {
  int replacements = 0;
  @override
  Future<void> replaceAll(
    List<PageRouteInfo> routes, {
    OnNavigationFailure? onFailure,
    bool updateExistingRoutes = true,
  }) async {
    expect(routes.single.routeName, 'SetupRoute');
    replacements++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final failure in ['storage', 'settings', 'none']) {
    testWidgets(
      'reset $failure guards deletion and navigates only on complete success',
      (tester) async {
        final repo = _ResetRepo()
          ..fails = failure == 'storage'
          ..deleting = Completer<void>();
        final config = _ResetConfig();
        final settings = _ResetSettingsStats()..fails = failure == 'settings';
        final router = _ResetRouter();
        final container = ProviderContainer.test(
          overrides: [
            personalCalendarRepositoryProvider.overrideWith(
              (ref) async => repo,
            ),
            scheduleConfigServiceProvider.overrideWith((ref) async => config),
            settingsProvider.overrideWith(() => _ResetSettings(settings)),
            scheduleDataProvider.overrideWith(_ResetData.new),
          ],
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: StackRouterScope(
                controller: router,
                stateHash: 0,
                child: Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => ResetBottomsheet.show(context),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Zurücksetzen').last);
        await tester.pump();
        await tester.tap(find.text('Zurücksetzen').last, warnIfMissed: false);
        await tester.pump();
        expect(repo.deletes, 1);
        await Navigator.of(tester.element(find.text('Abbrechen'))).maybePop();
        await tester.pump();
        expect(find.text('Abbrechen'), findsOneWidget);
        expect(router.replacements, 0);
        repo.deleting!.complete();
        await tester.pumpAndSettle();
        if (failure == 'none') {
          expect(router.replacements, 1);
          expect(find.text('Abbrechen'), findsNothing);
        } else {
          expect(router.replacements, 0);
          expect(find.text('Abbrechen'), findsOneWidget);
          expect(settings.resets, failure == 'storage' ? 0 : 1);
          repo.fails = false;
          settings.fails = false;
          await tester.tap(find.text('Zurücksetzen').last);
          await tester.pumpAndSettle();
          expect(repo.deletes, 2);
          expect(router.replacements, 1);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

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
