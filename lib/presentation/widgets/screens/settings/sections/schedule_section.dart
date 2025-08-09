import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/duty_schedule_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/my_duty_group_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/general/calendar_format_dialog.dart';

class ScheduleSection extends StatelessWidget {
  final ScheduleUiState state;

  const ScheduleSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: l10n.schedule,
      cards: [
        NavigationCard(
          icon: Icons.calendar_today_outlined,
          title: l10n.myDutySchedule,
          subtitle: _getDutyScheduleDisplayName(state, l10n),
          onTap: () => DutyScheduleDialog.show(context),
        ),
        NavigationCard(
          icon: Icons.favorite_outlined,
          title: l10n.myDutyGroup,
          subtitle: _getPreferredDutyGroupDisplayName(state, l10n),
          onTap: () => MyDutyGroupDialog.show(context),
        ),
        NavigationCard(
          icon: Icons.view_week_outlined,
          title: l10n.calendarFormat,
          subtitle: _getCalendarFormatName(
              state.calendarFormat ?? CalendarFormat.month, l10n),
          onTap: () => CalendarFormatDialog.show(context),
        ),
      ],
    );
  }

  String _getCalendarFormatName(CalendarFormat format, AppLocalizations l10n) {
    switch (format) {
      case CalendarFormat.month:
        return l10n.calendarFormatMonth;
      case CalendarFormat.twoWeeks:
        return l10n.calendarFormatTwoWeeks;
      case CalendarFormat.week:
        return l10n.calendarFormatWeek;
    }
  }

  String _getDutyScheduleDisplayName(
    ScheduleUiState state,
    AppLocalizations l10n,
  ) {
    try {
      if ((state.activeConfigName ?? '').isEmpty) {
        return l10n.noDutySchedules;
      }
      return state.activeConfig?.meta.name ?? state.activeConfigName!;
    } catch (e) {
      AppLogger.e(
          'ScheduleSection: Error getting duty schedule display name', e);
      return l10n.noDutySchedules;
    }
  }

  String _getPreferredDutyGroupDisplayName(
    ScheduleUiState state,
    AppLocalizations l10n,
  ) {
    try {
      if ((state.preferredDutyGroup ?? '').isEmpty) {
        return l10n.noMyDutyGroup;
      }
      return state.preferredDutyGroup!;
    } catch (e) {
      AppLogger.e(
          'ScheduleSection: Error getting preferred duty group display name',
          e);
      return l10n.noMyDutyGroup;
    }
  }
}
