import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class PartnerGroupDialog {
  static Future<void> show(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);

    // Safety check: prevent dialog from opening if no partner duty plan is selected
    final state = container.read(scheduleCoordinatorProvider).value;
    if (state?.partnerConfigName == null || state!.partnerConfigName!.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectPartnerDutyScheduleFirst),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(scheduleCoordinatorProvider).value;
          final notifier = ref.read(scheduleCoordinatorProvider.notifier);
          final DateTime? initialFocused = state?.focusedDay;
          final l10n = AppLocalizations.of(context);
          final String? selectedConfigName = state?.partnerConfigName;
          final groupsForSelected = (state?.configs ?? const [])
              .where((c) => c.name == selectedConfigName)
              .expand((c) => c.dutyGroups.map((g) => g.name))
              .toList();

          return AlertDialog(
            title: Text(l10n.partnerDutyGroup),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.selectPartnerDutyGroup),
                    const SizedBox(height: 8),
                    if (selectedConfigName == null ||
                        selectedConfigName.isEmpty)
                      Text(l10n.noDutySchedule)
                    else ...[
                      ...groupsForSelected.map((group) => SelectionCard(
                            title: group,
                            isSelected: state?.partnerDutyGroup == group,
                            onTap: () async {
                              // Perform operations first
                              await notifier.setPartnerDutyGroup(group);
                              if (initialFocused != null) {
                                await notifier.setFocusedDay(initialFocused);
                              }

                              // Close dialog after operations are complete
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            useDialogStyle: true,
                          )),
                      SelectionCard(
                        title: l10n.noPartnerGroup,
                        isSelected: (state?.partnerDutyGroup ?? '').isEmpty,
                        onTap: () async {
                          // Perform operations first
                          await notifier.setPartnerDutyGroup(null);
                          if (initialFocused != null) {
                            await notifier.setFocusedDay(initialFocused);
                          }

                          // Close dialog after operations are complete
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        useDialogStyle: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: const [],
          );
        },
      ),
    );
    // After dialog is dismissed (tap outside/back), apply heavy loads once
    await container
        .read(scheduleCoordinatorProvider.notifier)
        .applyPartnerSelectionChanges();
  }
}
