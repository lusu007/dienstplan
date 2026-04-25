import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/config_selection_bottomsheet.dart';

class DutyScheduleBottomsheet {
  static Future<void> show(
    BuildContext context, {
    double? heightPercentage,
  }) async {
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      clipBehavior: Clip.antiAlias,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final asyncState = ref.watch(scheduleCoordinatorProvider);
          final state = asyncState.value;
          final configs = state?.configs ?? const [];

          if (configs.isEmpty) {
            return GlassBottomSheet(
              title: l10n.myDutySchedule,
              shrinkToContent: true,
              children: [
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
            onConfigSelected: (config) async {
              // Get notifier
              final notifier = ref.read(scheduleCoordinatorProvider.notifier);
              if (config != null) {
                try {
                  // First set the active config so coordinator state reflects it immediately
                  await notifier.setActiveConfig(config.name);
                  // Reset my duty group selection when duty plan changes
                  await notifier.setPreferredDutyGroup(
                    '',
                    activeConfigNameOverride: config.name,
                  );
                  // Apply changes immediately so a second change isn't required
                  await notifier.applyOwnSelectionChanges();
                } catch (e, stackTrace) {
                  AppLogger.e(
                    'DutyScheduleDialog: Error setting active config',
                    e,
                    stackTrace,
                  );
                  // Show error in parent context since dialog is closed
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorSettingActiveConfig)),
                    );
                  }
                }
              } else {
                // Deselection path: clear active config and related selections
                try {
                  await notifier.clearActiveConfig();
                  await notifier.setPreferredDutyGroup(
                    '',
                    activeConfigNameOverride: null,
                  );
                  await notifier.applyOwnSelectionChanges();
                } catch (e, stackTrace) {
                  AppLogger.e(
                    'DutyScheduleDialog: Error clearing active config',
                    e,
                    stackTrace,
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
