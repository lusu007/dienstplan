import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';

class MyDutyGroupDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => Consumer(builder: (context, ref, _) {
        final asyncState = ref.watch(scheduleNotifierProvider);
        final state = asyncState.valueOrNull;
        final dutyGroups = state?.dutyGroups ?? const <String>[];
        if ((state?.activeConfigName ?? '').isEmpty) {
          return AlertDialog(
            title: Text(l10n.selectMyDutyGroup),
            content: const Text('No active duty schedule selected'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
        if (dutyGroups.isEmpty) {
          return AlertDialog(
            title: Text(l10n.selectMyDutyGroup),
            content:
                const Text('No duty groups available in the current schedule.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
        return AlertDialog(
          title: Text(l10n.selectMyDutyGroup),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              minHeight: 200,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...dutyGroups.map((group) => SelectionCard(
                        title: group,
                        isSelected: state?.preferredDutyGroup == group,
                        onTap: () async {
                          await ref
                              .read(scheduleNotifierProvider.notifier)
                              .setPreferredDutyGroup(group);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        mainColor: AppColors.primary,
                        useDialogStyle: true,
                      )),
                  SelectionCard(
                    title: l10n.noDutyGroup,
                    isSelected: (state?.preferredDutyGroup ?? '').isEmpty,
                    onTap: () async {
                      await ref
                          .read(scheduleNotifierProvider.notifier)
                          .setPreferredDutyGroup(null);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    mainColor: AppColors.primary,
                    useDialogStyle: true,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
