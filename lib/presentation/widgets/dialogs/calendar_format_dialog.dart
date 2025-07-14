import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/dialogs/dialog_selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class CalendarFormatDialog {
  static void show(BuildContext context, ScheduleController controller) {
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
              isSelected: controller.calendarFormat == CalendarFormat.month,
              onTap: () async {
                await controller.setCalendarFormat(CalendarFormat.month);
                Navigator.pop(context);
              },
              mainColor: AppColors.primary,
            ),
            DialogSelectionCard(
              title: l10n.calendarFormatTwoWeeks,
              isSelected: controller.calendarFormat == CalendarFormat.twoWeeks,
              onTap: () async {
                await controller.setCalendarFormat(CalendarFormat.twoWeeks);
                Navigator.pop(context);
              },
              mainColor: AppColors.primary,
            ),
            DialogSelectionCard(
              title: l10n.calendarFormatWeek,
              isSelected: controller.calendarFormat == CalendarFormat.week,
              onTap: () async {
                await controller.setCalendarFormat(CalendarFormat.week);
                Navigator.pop(context);
              },
              mainColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
