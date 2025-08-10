import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';

class DutyScheduleDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(builder: (context, ref, _) {
        final asyncState = ref.watch(scheduleNotifierProvider);
        final state = asyncState.valueOrNull;
        final configs = state?.configs ?? const [];
        if (configs.isEmpty) {
          return AlertDialog(
            title: Text(l10n.selectDutySchedule),
            content: const Text('No duty schedules available'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              )
            ],
          );
        }
        return AlertDialog(
          title: Text(l10n.selectDutySchedule),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...configs.map((config) => SelectionCard(
                    title: config.meta.name,
                    subtitle: config.meta.description.isNotEmpty
                        ? config.meta.description
                        : null,
                    isSelected: state?.activeConfigName == config.name,
                    onTap: () async {
                      try {
                        await ref
                            .read(scheduleNotifierProvider.notifier)
                            .setActiveConfig(config);
                        await ref
                            .read(scheduleNotifierProvider.notifier)
                            .setPreferredDutyGroup(null);
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      } catch (e, stackTrace) {
                        AppLogger.e(
                            'DutyScheduleDialog: Error setting active config',
                            e,
                            stackTrace);
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              content: Text(
                                'Error setting active config: ${e.toString()}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.of(dialogContext).pop();
                        }
                      }
                    },
                    mainColor: AppColors.primary,
                    useDialogStyle: true,
                  )),
            ],
          ),
        );
      }),
    );
  }
}
