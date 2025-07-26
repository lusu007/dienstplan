import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/logger.dart';

class DutyScheduleDialog {
  static void show(BuildContext context, ScheduleController controller) {
    final l10n = AppLocalizations.of(context);

    // Validate controller state before showing dialog
    if (controller.configs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No duty schedules available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectDutySchedule),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...controller.configs.map((config) => SelectionCard(
                  title: config.meta.name,
                  subtitle: config.meta.description.isNotEmpty
                      ? config.meta.description
                      : null,
                  isSelected:
                      controller.activeConfig?.meta.name == config.meta.name,
                  onTap: () async {
                    try {
                      // Set active config first
                      try {
                        await controller.setActiveConfig(config);

                        // Always reset preferred duty group when switching duty plans
                        // This ensures the user must explicitly choose a preferred duty group for the new plan
                        controller.preferredDutyGroup = null;

                        // Close dialog after successful operation
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      } catch (e, stackTrace) {
                        AppLogger.e(
                            'DutyScheduleDialog: Error setting active config',
                            e,
                            stackTrace);

                        // Show error message to user
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error setting active config: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }

                        // Close dialog even on error
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      }
                    } catch (e, stackTrace) {
                      AppLogger.e('DutyScheduleDialog: Unexpected error', e,
                          stackTrace);

                      // Show error message to user
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('Unexpected error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                      // Close dialog even on error
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                  mainColor: AppColors.primary,
                  useDialogStyle: true,
                )),
          ],
        ),
      ),
    );
  }
}
