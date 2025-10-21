import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/duty_group_selection_bottomsheet.dart';

class MyDutyGroupBottomsheet {
  static void show(BuildContext context, {double? heightPercentage}) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final asyncState = ref.watch(scheduleCoordinatorProvider);
          final state = asyncState.value;
          final dutyGroups = state?.dutyGroups ?? const <String>[];

          if ((state?.activeConfigName ?? '').isEmpty) {
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
                      l10n.selectMyDutyGroup,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.noMyDutyGroup,
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
            title: l10n.myDutyGroup,
            dutyGroups: dutyGroups,
            selectedDutyGroup: state?.preferredDutyGroup,
            showNoGroupOption: true,
            noGroupTitle: l10n.noDutyGroup,
            heightPercentage: heightPercentage,
            onDutyGroupSelected: (group) async {
              await ref
                  .read(scheduleCoordinatorProvider.notifier)
                  .setPreferredDutyGroup(group ?? '');
            },
          );
        },
      ),
    );
  }
}
