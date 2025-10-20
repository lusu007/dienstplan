import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/selection_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class CalendarFormatBottomsheet {
  static void show(BuildContext context, {double? heightPercentage}) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final asyncState = ref.watch(settingsProvider);
          final state = asyncState.value;
          final currentFormat = state?.calendarFormat ?? CalendarFormat.month;

          return SelectionBottomsheet(
            title: l10n.calendarFormat,
            heightPercentage: heightPercentage,
            items: [
              SelectionItem(
                title: l10n.calendarFormatMonth,
                value: CalendarFormat.month.name,
              ),
              SelectionItem(
                title: l10n.calendarFormatTwoWeeks,
                value: CalendarFormat.twoWeeks.name,
              ),
              SelectionItem(
                title: l10n.calendarFormatWeek,
                value: CalendarFormat.week.name,
              ),
            ],
            selectedValue: currentFormat.name,
            onItemSelected: (formatName) async {
              if (formatName != null) {
                CalendarFormat format;
                switch (formatName) {
                  case 'month':
                    format = CalendarFormat.month;
                    break;
                  case 'twoWeeks':
                    format = CalendarFormat.twoWeeks;
                    break;
                  case 'week':
                    format = CalendarFormat.week;
                    break;
                  default:
                    format = CalendarFormat.month;
                }
                await ref
                    .read(settingsProvider.notifier)
                    .setCalendarFormat(format);
              }
            },
          );
        },
      ),
    );
  }
}
