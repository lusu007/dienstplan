import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/widgets/dialogs/dialog_selection_card.dart';
import 'package:dienstplan/widgets/dialogs/dialog_close_button.dart';
import 'package:dienstplan/constants/app_colors.dart';

class CalendarFormatDialog {
  static void show(BuildContext context, ScheduleProvider provider) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.calendarFormat),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogSelectionCard(
              title: l10n.calendarFormatMonth,
              isSelected: provider.calendarFormat == CalendarFormat.month,
              onTap: () {
                provider.setCalendarFormat(CalendarFormat.month);
                Navigator.pop(context);
              },
              mainColor: AppColors.primary,
            ),
            DialogSelectionCard(
              title: l10n.calendarFormatTwoWeeks,
              isSelected: provider.calendarFormat == CalendarFormat.twoWeeks,
              onTap: () {
                provider.setCalendarFormat(CalendarFormat.twoWeeks);
                Navigator.pop(context);
              },
              mainColor: AppColors.primary,
            ),
            DialogSelectionCard(
              title: l10n.calendarFormatWeek,
              isSelected: provider.calendarFormat == CalendarFormat.week,
              onTap: () {
                provider.setCalendarFormat(CalendarFormat.week);
                Navigator.pop(context);
              },
              mainColor: AppColors.primary,
            ),
          ],
        ),
        actions: [
          const DialogCloseButton(mainColor: AppColors.primary),
        ],
      ),
    );
  }
}
