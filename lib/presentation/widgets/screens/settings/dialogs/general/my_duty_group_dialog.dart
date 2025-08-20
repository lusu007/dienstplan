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
        final state = asyncState.value;
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
          title: Text(l10n.myDutyGroup),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.selectMyDutyGroup),
                  const SizedBox(height: 8),
                  ...dutyGroups.map((group) => SelectionCard(
                        title: group,
                        isSelected: state?.preferredDutyGroup == group,
                        onTap: () async {
                          // Close dialog immediately
                          Navigator.of(context).pop();

                          // Perform operations after dialog is closed
                          await ref
                              .read(scheduleNotifierProvider.notifier)
                              .setPreferredDutyGroup(group);
                        },
                        mainColor: AppColors.primary,
                        useDialogStyle: true,
                      )),
                  SelectionCard(
                    title: l10n.noDutyGroup,
                    isSelected: (state?.preferredDutyGroup ?? '').isEmpty,
                    onTap: () async {
                      // Close dialog immediately
                      Navigator.of(context).pop();

                      // Perform operations after dialog is closed
                      await ref
                          .read(scheduleNotifierProvider.notifier)
                          .setPreferredDutyGroup(null);
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
