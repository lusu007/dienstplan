import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_view_ui_builder.dart';

class ServicesSection extends StatelessWidget {
  final DateTime? selectedDay;

  const ServicesSection({
    super.key,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarViewUiBuilder.buildServicesSection(
      selectedDay: selectedDay,
    );
  }
}
