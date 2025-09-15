import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';

class CalendarFormatDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => Consumer(builder: (context, ref, _) {
        final asyncState = ref.watch(settingsProvider);
        final state = asyncState.value;
        return AlertDialog(
          title: Text(l10n.calendarFormat),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectionCard(
                title: l10n.calendarFormatMonth,
                isSelected: (state?.calendarFormat ?? CalendarFormat.month) ==
                    CalendarFormat.month,
                onTap: () async {
                  await ref
                      .read(settingsProvider.notifier)
                      .setCalendarFormat(CalendarFormat.month);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                mainColor: AppColors.primary,
                useDialogStyle: true,
              ),
              SelectionCard(
                title: l10n.calendarFormatTwoWeeks,
                isSelected: (state?.calendarFormat ?? CalendarFormat.month) ==
                    CalendarFormat.twoWeeks,
                onTap: () async {
                  await ref
                      .read(settingsProvider.notifier)
                      .setCalendarFormat(CalendarFormat.twoWeeks);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                mainColor: AppColors.primary,
                useDialogStyle: true,
              ),
              SelectionCard(
                title: l10n.calendarFormatWeek,
                isSelected: (state?.calendarFormat ?? CalendarFormat.month) ==
                    CalendarFormat.week,
                onTap: () async {
                  await ref
                      .read(settingsProvider.notifier)
                      .setCalendarFormat(CalendarFormat.week);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                mainColor: AppColors.primary,
                useDialogStyle: true,
              ),
            ],
          ),
        );
      }),
    );
  }
}
