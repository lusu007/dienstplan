import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
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
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final asyncState = ref.watch(scheduleCoordinatorProvider);
          final state = asyncState.value;
          final configs = state?.configs ?? const [];

          if (configs.isEmpty) {
            final screenHeight = MediaQuery.of(context).size.height;
            final height = heightPercentage != null
                ? screenHeight * heightPercentage
                : screenHeight * 0.3;
            return Container(
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.myDutySchedule,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.noDutySchedules,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                  // Reset my duty group selection and clear filter when duty plan changes
                  await notifier.setPreferredDutyGroup(
                    '',
                    activeConfigNameOverride: config.name,
                  );
                  await notifier.setSelectedDutyGroup(null);
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
                      SnackBar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        content: Text(
                          'Error setting active config: ${e.toString()}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
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
                  await notifier.setSelectedDutyGroup(null);
                  await notifier.applyOwnSelectionChanges();
                } catch (e, stackTrace) {
                  AppLogger.e(
                    'DutyScheduleDialog: Error clearing active config',
                    e,
                    stackTrace,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        content: Text(
                          l10n.errorClearingActiveConfig,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
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
