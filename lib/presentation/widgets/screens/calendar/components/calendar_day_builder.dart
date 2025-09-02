import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';

class CalendarDayBuilder extends StatelessWidget {
  final DateTime day;
  final String? dutyAbbreviation;
  final String? partnerDutyAbbreviation;
  final CalendarDayType dayType;
  final double? width;
  final double? height;

  const CalendarDayBuilder({
    super.key,
    required this.day,
    this.dutyAbbreviation,
    this.partnerDutyAbbreviation,
    required this.dayType,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use configured sizing with fallback to provided values
    final effectiveWidth = width ?? CalendarConfig.kCalendarDayWidth;
    final effectiveHeight = height ?? CalendarConfig.kCalendarDayHeight;

    final dayStyle = _getDayTextStyle(theme);
    final containerDecoration = _getContainerDecoration(theme);
    final dutyBadgeDecoration = _getDutyBadgeDecoration(theme);
    final dutyBadgeTextStyle = _getDutyBadgeTextStyle(theme);

    return Container(
      margin: _getMargin(),
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: containerDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: dayStyle,
          ),
          if ((dutyAbbreviation != null && dutyAbbreviation!.isNotEmpty) ||
              (partnerDutyAbbreviation != null &&
                  partnerDutyAbbreviation!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First row: My duty group chip
                  if (dutyAbbreviation != null && dutyAbbreviation!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 2.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3.0, vertical: 1.0),
                      decoration: dutyBadgeDecoration,
                      child: Text(
                        dutyAbbreviation!,
                        style: dutyBadgeTextStyle.copyWith(
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                  // Second row: Partner duty group chip
                  if (partnerDutyAbbreviation != null &&
                      partnerDutyAbbreviation!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        partnerDutyAbbreviation!,
                        style: const TextStyle(
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  TextStyle _getDayTextStyle(ThemeData theme) {
    switch (dayType) {
      case CalendarDayType.default_:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        );
      case CalendarDayType.outside:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurfaceVariant,
        );
      case CalendarDayType.selected:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        );
      case CalendarDayType.today:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        );
    }
  }

  BoxDecoration _getContainerDecoration(ThemeData theme) {
    switch (dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.outside:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        );
      case CalendarDayType.selected:
        return BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        );
      case CalendarDayType.today:
        return BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(kAlphaToday),
          borderRadius: BorderRadius.circular(8),
        );
    }
  }

  BoxDecoration _getDutyBadgeDecoration(ThemeData theme) {
    switch (dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.today:
        return BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        );
      case CalendarDayType.outside:
        return BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade400.withValues(alpha: 0.8)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4),
        );
      case CalendarDayType.selected:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        );
    }
  }

  TextStyle _getDutyBadgeTextStyle(ThemeData theme) {
    switch (dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.outside:
      case CalendarDayType.today:
        return const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
      case CalendarDayType.selected:
        return TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        );
    }
  }

  EdgeInsets _getMargin() {
    switch (dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.outside:
        return const EdgeInsets.all(2);
      case CalendarDayType.selected:
      case CalendarDayType.today:
        return const EdgeInsets.all(1);
    }
  }
}

enum CalendarDayType {
  default_,
  outside,
  selected,
  today,
}
