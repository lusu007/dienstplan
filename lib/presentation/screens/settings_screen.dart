import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/app_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/school_holidays_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/privacy_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/other_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/footer_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section_skeleton.dart';
import 'package:dienstplan/presentation/widgets/common/safe_area_wrapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeAreaWrapper(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              const _SettingsScheduleBlock(),
              const SizedBox(height: 16),
              const AppSection(),
              const SizedBox(height: 16),
              const SchoolHolidaysSection(),
              const SizedBox(height: 16),
              const PrivacySection(),
              const SizedBox(height: 16),
              const OtherSection(),
              const SizedBox(height: 32),
              const SettingsFooter(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Schedule-dependent settings; loading/error here does not block the rest of Settings.
class _SettingsScheduleBlock extends ConsumerWidget {
  const _SettingsScheduleBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ScheduleUiState> scheduleAsync = ref.watch(
      scheduleCoordinatorProvider,
    );
    return scheduleAsync.when(
      loading: () => const ScheduleSectionSkeleton(),
      error: (Object e, StackTrace st) {
        AppLogger.e(
          'SettingsScreen: scheduleCoordinatorProvider failed',
          e,
          st,
        );
        const FailurePresenter presenter = FailurePresenter();
        final Failure failure = e is Failure
            ? e
            : UnknownFailure(
                technicalMessage: e.toString(),
                cause: e,
                stackTrace: st,
              );
        final String message = presenter.present(failure, l10n);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 40, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
      data: (ScheduleUiState state) => ScheduleSection(state: state),
    );
  }
}
