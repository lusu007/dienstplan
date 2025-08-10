import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class PartnerConfigDialog {
  static Future<void> show(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(scheduleNotifierProvider).valueOrNull;
          final notifier = ref.read(scheduleNotifierProvider.notifier);
          final DateTime? initialFocused = state?.focusedDay;
          final configs = state?.configs ?? const [];
          if (configs.isEmpty) {
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(l10n.myDutySchedule),
              content: Text(l10n.noDutySchedules),
            );
          }

          final l10n = AppLocalizations.of(context);
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
                    ...configs.map((c) => SelectionCard(
                          title: c.meta.name,
                          subtitle: c.meta.description.isNotEmpty
                              ? c.meta.description
                              : null,
                          isSelected: state?.partnerConfigName == c.name,
                          onTap: () async {
                            await notifier.setPartnerConfigName(c.name,
                                silent: true);
                            if (initialFocused != null) {
                              await notifier.setFocusedDay(initialFocused,
                                  shouldLoad: false);
                            }
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                          useDialogStyle: true,
                        )),
                    SelectionCard(
                      title: l10n.noDutySchedule,
                      isSelected: (state?.partnerConfigName ?? '').isEmpty,
                      onTap: () async {
                        await notifier.setPartnerConfigName(null, silent: true);
                        if (initialFocused != null) {
                          await notifier.setFocusedDay(initialFocused,
                              shouldLoad: false);
                        }
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      useDialogStyle: true,
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
        .read(scheduleNotifierProvider.notifier)
        .applyPartnerSelectionChanges();
  }
}
