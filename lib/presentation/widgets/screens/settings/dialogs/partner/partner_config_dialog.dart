import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class PartnerConfigDialog {
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
              title: Text(l10n.partnerDutySchedule),
              content: Text(l10n.noDutySchedules),
            );
          }

          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l10n.partnerDutySchedule),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.selectDutySchedule),
                    const SizedBox(height: 8),
                    ...configs.map((c) => SelectionCard(
                          title: _buildConfigTitle(c),
                          subtitle: _buildConfigSubtitle(c),
                          isSelected: state?.partnerConfigName == c.name,
                          onTap: () async {
                            // Close dialog immediately
                            Navigator.of(context).pop();

                            // Perform operations after dialog is closed
                            await notifier.setPartnerConfigName(c.name,
                                silent: true);
                            // Reset partner duty group when duty plan changes
                            await notifier.setPartnerDutyGroup(null,
                                silent: true);
                            if (initialFocused != null) {
                              await notifier.setFocusedDay(initialFocused,
                                  shouldLoad: false);
                            }
                          },
                          useDialogStyle: true,
                        )),
                    SelectionCard(
                      title: l10n.noDutySchedule,
                      isSelected: (state?.partnerConfigName ?? '').isEmpty,
                      onTap: () async {
                        // Close dialog immediately
                        Navigator.of(context).pop();

                        // Perform operations after dialog is closed
                        await notifier.setPartnerConfigName(null, silent: true);
                        // Reset partner duty group when duty plan is cleared
                        await notifier.setPartnerDutyGroup(null, silent: true);
                        if (initialFocused != null) {
                          await notifier.setFocusedDay(initialFocused,
                              shouldLoad: false);
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
