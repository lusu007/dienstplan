import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';

class DutyScheduleDialog {
  static Widget _buildConfigTitle(dynamic config) {
    if (config.meta.policeAuthority != null &&
        config.meta.policeAuthority!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.meta.policeAuthority!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(config.meta.name),
        ],
      );
    }
    return Text(config.meta.name);
  }

  static String? _buildConfigSubtitle(dynamic config) {
    return config.meta.description.isNotEmpty ? config.meta.description : null;
  }

  static Future<void> show(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final l10n = AppLocalizations.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final asyncState = ref.watch(scheduleCoordinatorProvider);
          final state = asyncState.value;
          final configs = state?.configs ?? const [];
          if (configs.isEmpty) {
            return AlertDialog(
              title: Text(l10n.selectDutySchedule),
              content: const Text('No duty schedules available'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          }
          return AlertDialog(
            title: Text(l10n.myDutySchedule),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.selectDutySchedule),
                    const SizedBox(height: 8),
                    ...configs.map(
                      (config) => SelectionCard(
                        title: _buildConfigTitle(config),
                        subtitle: _buildConfigSubtitle(config),
                        isSelected: state?.activeConfigName == config.name,
                        onTap: () async {
                          try {
                            // Get notifier before closing dialog
                            final notifier = ref.read(
                              scheduleCoordinatorProvider.notifier,
                            );

                            // Close dialog immediately
                            Navigator.of(context).pop();

                            // Perform operations after dialog is closed
                            // First set the active config so coordinator state reflects it immediately
                            await notifier.setActiveConfig(config.name);
                            // Then clear duty group; its save preserves the current active config
                            await notifier.setPreferredDutyGroup('');
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
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  content: Text(
                                    'Error setting active config: ${e.toString()}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        mainColor: AppColors.primary,
                        useDialogStyle: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    await container
        .read(scheduleCoordinatorProvider.notifier)
        .applyOwnSelectionChanges();
  }
}
