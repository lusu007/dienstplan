import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/core/calendar_view_controller.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/sheet/services_section.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/list/filter_status.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/sheet/day_page_view.dart';

class CalendarSheet extends StatelessWidget {
  final CalendarViewController pageManager;
  final ScheduleController scheduleController;
  final Key pageViewKey;

  const CalendarSheet({
    super.key,
    required this.pageManager,
    required this.scheduleController,
    required this.pageViewKey,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CalendarViewUiBuilder.buildSheetContainer(
        context: context,
        child: Column(
          children: [
            _ServicesSectionWrapper(
              pageManager: pageManager,
              scheduleController: scheduleController,
            ),
            FilterStatus(scheduleController: scheduleController),
            Expanded(
              child: DayPageView(
                pageManager: pageManager,
                scheduleController: scheduleController,
                pageViewKey: pageViewKey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesSectionWrapper extends StatefulWidget {
  final CalendarViewController pageManager;
  final ScheduleController scheduleController;

  const _ServicesSectionWrapper({
    required this.pageManager,
    required this.scheduleController,
  });

  @override
  State<_ServicesSectionWrapper> createState() =>
      _ServicesSectionWrapperState();
}

class _ServicesSectionWrapperState extends State<_ServicesSectionWrapper> {
  @override
  void initState() {
    super.initState();
    widget.pageManager.pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.pageManager.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.scheduleController,
      builder: (context, child) {
        return ServicesSection(
          selectedDay: widget.scheduleController.selectedDay,
        );
      },
    );
  }
}
