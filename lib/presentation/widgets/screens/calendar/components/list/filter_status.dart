import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';

class FilterStatus extends StatelessWidget {
  final ScheduleController scheduleController;

  const FilterStatus({
    super.key,
    required this.scheduleController,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarViewUiBuilder.buildFilterStatusText(
      context: context,
      scheduleController: scheduleController,
    );
  }
}
