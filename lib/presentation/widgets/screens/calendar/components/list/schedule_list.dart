import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';

class ScheduleList extends StatelessWidget {
  final ScheduleController scheduleController;
  final bool shouldAnimate;

  const ScheduleList({
    super.key,
    required this.scheduleController,
    this.shouldAnimate = false,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarViewUiBuilder.buildDutyScheduleList(
      context: context,
      scheduleController: scheduleController,
      shouldAnimate: shouldAnimate,
    );
  }
}
