import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/duty_group_selection_bottomsheet.dart';

class PartnerGroupBottomsheet {
  static Future<void> show(
    BuildContext context, {
    double? heightPercentage,
  }) async {
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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

          if (selectedConfigName == null || selectedConfigName.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.3,
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
                      l10n.partnerDutyGroup,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.noDutySchedule,
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

          return DutyGroupSelectionBottomsheet(
            title: l10n.partnerDutyGroup,
            dutyGroups: groupsForSelected,
            selectedDutyGroup: state?.partnerDutyGroup,
            heightPercentage: heightPercentage,
            onDutyGroupSelected: (group) async {
              await notifier.setPartnerDutyGroup(group);
              if (initialFocused != null) {
                await notifier.setFocusedDay(initialFocused);
              }
            },
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
