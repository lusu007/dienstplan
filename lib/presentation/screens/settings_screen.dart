import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/app_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/school_holidays_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/privacy_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/other_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/footer_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section_skeleton.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return GlassScreenScaffold(
      title: l10n.settings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          glassSpacingXl - 4,
          glassSpacingXl - 4,
          glassSpacingXl - 4,
          glassSpacingXxl,
        ),
        children: const [
          _SettingsScheduleBlock(),
          SizedBox(height: glassSpacingSm),
          AppSection(),
          SizedBox(height: glassSpacingSm),
          SchoolHolidaysSection(),
          SizedBox(height: glassSpacingSm),
          PrivacySection(),
          SizedBox(height: glassSpacingSm),
          OtherSection(),
          SizedBox(height: glassSpacingXl),
          SettingsFooter(),
          SizedBox(height: glassSpacingXl),
        ],
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
        return GlassCard(
          margin: const EdgeInsets.only(bottom: glassSpacingSm),
          child: Padding(
            padding: const EdgeInsets.all(glassSpacingXl - 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: glassSpacingMd),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: glassSpacingLg),
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        ref.invalidate(scheduleCoordinatorProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.tryAgain),
                  ),
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
