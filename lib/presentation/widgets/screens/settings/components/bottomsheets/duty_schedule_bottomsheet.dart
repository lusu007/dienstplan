import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/config_selection_bottomsheet.dart';

class DutyScheduleBottomsheet {
  static Future<void> show(
    BuildContext context, {
    double? heightPercentage,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext dialogContext) => Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          final ScheduleUiState? state = ref.watch(
            scheduleCoordinatorProvider.select(
              (AsyncValue<ScheduleUiState> s) => s.value,
            ),
          );
          final List<DutyScheduleConfig> configs = state?.configs ?? const [];

          if (configs.isEmpty) {
            return GlassBottomSheet(
              title: l10n.myDutySchedule,
              shrinkToContent: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    glassSpacingXl,
                    glassSpacingMd,
                    glassSpacingXl,
                    glassSpacingXl,
                  ),
                  child: Text(
                    l10n.noDutySchedules,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }

          return ConfigSelectionBottomsheet(
            title: l10n.myDutySchedule,
            configs: configs,
            selectedConfigName: state?.activeConfigName,
            heightPercentage: heightPercentage,
            onConfigSelected: (DutyScheduleConfig? config) async {
              final notifier = ref.read(scheduleCoordinatorProvider.notifier);
              if (config != null) {
                try {
                  await notifier.setActiveConfig(config.name);
                  await notifier.setPreferredDutyGroup(
                    '',
                    activeConfigNameOverride: config.name,
                  );
                  await notifier.applyOwnSelectionChanges();
                } catch (e, s) {
                  AppLogger.e(
                    'DutyScheduleDialog: Error setting active config',
                    e,
                    s,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorSettingActiveConfig)),
                    );
                  }
                }
              } else {
                try {
                  await notifier.clearActiveConfig();
                  await notifier.setPreferredDutyGroup(
                    '',
                    activeConfigNameOverride: null,
                  );
                  await notifier.applyOwnSelectionChanges();
                } catch (e, s) {
                  AppLogger.e(
                    'DutyScheduleDialog: Error clearing active config',
                    e,
                    s,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorClearingActiveConfig)),
                    );
                  }
                }
              }
            },
          );
        },
      ),
    );
  }
}
