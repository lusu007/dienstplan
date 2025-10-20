import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/config_selection_bottomsheet.dart';

class PartnerConfigBottomsheet {
  static Future<void> show(
    BuildContext context, {
    double? heightPercentage,
  }) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(scheduleCoordinatorProvider).value;
          final notifier = ref.read(scheduleCoordinatorProvider.notifier);
          final DateTime? initialFocused = state?.focusedDay;
          final configs = state?.configs ?? const [];

          if (configs.isEmpty) {
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
                      l10n.partnerDutySchedule,
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
            title: l10n.partnerDutySchedule,
            configs: configs,
            selectedConfigName: state?.partnerConfigName,
            showNoConfigOption: true,
            noConfigTitle: l10n.noDutySchedule,
            onConfigSelected: (config) async {
              if (config != null) {
                // Perform operations after dialog is closed
                await notifier.setPartnerConfigName(config.name);
                // Reset partner duty group when duty plan changes
                await notifier.setPartnerDutyGroup(null);
                if (initialFocused != null) {
                  await notifier.setFocusedDay(initialFocused);
                }
              } else {
                // Perform operations after dialog is closed
                await notifier.setPartnerConfigName(null);
                // Reset partner duty group when duty plan is cleared
                await notifier.setPartnerDutyGroup(null);
                if (initialFocused != null) {
                  await notifier.setFocusedDay(initialFocused);
                }
              }
            },
          );
        },
      ),
    );
    await container
        .read(scheduleCoordinatorProvider.notifier)
        .applyPartnerSelectionChanges();
  }
}
