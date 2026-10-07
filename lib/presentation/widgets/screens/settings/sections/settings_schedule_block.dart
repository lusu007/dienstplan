import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section_skeleton.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';

/// Schedule-dependent settings; loading/error here does not block the rest of Settings.
class SettingsScheduleBlock extends ConsumerWidget {
  const SettingsScheduleBlock({super.key, required this.partner});
  final bool partner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ScheduleUiState> scheduleAsync = ref.watch(
      scheduleCoordinatorProvider,
    );
    return scheduleAsync.when(
      loading: () => ScheduleSectionSkeleton(partner: partner),
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
                  child: AppGlassButton.icon(
                    role: AppGlassButtonRole.quiet,

                    onPressed: () => ref
                        .read(scheduleCoordinatorProvider.notifier)
                        .retryFailedLoad(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.tryAgain),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      data: (ScheduleUiState state) =>
          ScheduleSection(state: state, partner: partner),
    );
  }
}
