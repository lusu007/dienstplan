import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';

class AnimatedCalendarDay extends StatefulWidget {
  final DateTime day;
  final String? dutyAbbreviation;
  final String? partnerDutyAbbreviation;
  final int? partnerAccentColorValue;
  final int? myAccentColorValue;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool hasSchoolHoliday;
  final String? schoolHolidayName;

  const AnimatedCalendarDay({
    super.key,
    required this.day,
    this.dutyAbbreviation,
    this.partnerDutyAbbreviation,
    this.partnerAccentColorValue,
    this.myAccentColorValue,
    required this.dayType,
    this.width,
    this.height,
    required this.isSelected,
    this.onTap,
    this.hasSchoolHoliday = false,
    this.schoolHolidayName,
  });

  @override
  State<AnimatedCalendarDay> createState() => _AnimatedCalendarDayState();
}

class _AnimatedCalendarDayState extends State<AnimatedCalendarDay> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use configured sizing with fallback to provided values
    final effectiveWidth = widget.width ?? CalendarConfig.kCalendarDayWidth;
    final effectiveHeight = widget.height ?? CalendarConfig.kCalendarDayHeight;

    final dayStyle = _getDayTextStyle(theme);
    final containerDecoration = _getContainerDecoration(theme);
    final dutyBadgeDecoration = _getDutyBadgeDecoration(theme);
    final dutyBadgeTextStyle = _getDutyBadgeTextStyle(theme);
    final partnerBadgeDecoration = _getPartnerBadgeDecoration(theme);
    final partnerBadgeTextStyle = _getPartnerBadgeTextStyle(theme);

    final bool hasPrimary =
        widget.dutyAbbreviation != null && widget.dutyAbbreviation!.isNotEmpty;
    final bool hasPartner =
        widget.partnerDutyAbbreviation != null &&
        widget.partnerDutyAbbreviation!.isNotEmpty;

    return InkWell(
      onTap: () {
        widget.onTap?.call();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: _getMargin(),
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: containerDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text('${widget.day.day}', style: dayStyle),
            ),
            // School holiday indicator (between date and chips)
            Container(
              margin: const EdgeInsets.only(top: 0.5, bottom: 1.0),
              height: 2,
              width: double.infinity,
              decoration: widget.hasSchoolHoliday
                  ? BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(1),
                    )
                  : null,
            ),
            // Spacer to push chips to bottom when primary chips are missing
            if (!hasPrimary && hasPartner) const Spacer(),
            if (hasPrimary || hasPartner)
              Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // First row: My duty group chip
                    if (widget.dutyAbbreviation != null &&
                        widget.dutyAbbreviation!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 2.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3.0,
                          vertical: 1.0,
                        ),
                        decoration: dutyBadgeDecoration,
                        child: Text(
                          widget.dutyAbbreviation!,
                          style: dutyBadgeTextStyle.copyWith(fontSize: 10.0),
                        ),
                      ),
                    // Second row: Partner duty group chip (always at bottom)
                    if (widget.partnerDutyAbbreviation != null &&
                        widget.partnerDutyAbbreviation!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3.0,
                          vertical: 1.0,
                        ),
                        decoration: partnerBadgeDecoration,
                        child: Text(
                          widget.partnerDutyAbbreviation!,
                          style: partnerBadgeTextStyle.copyWith(fontSize: 10.0),
                        ),
                      ),
                  ],
                ),
              ),
            // Spacer to push chips to bottom when no chips are present
            if (!hasPrimary && !hasPartner) const Spacer(),
            // Add bottom padding to create equal spacing
            const SizedBox(height: 4.0),
          ],
        ),
      ),
    );
  }

  TextStyle _getDayTextStyle(ThemeData theme) {
    switch (widget.dayType) {
      case CalendarDayType.default_:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
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
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    }
  }

  BoxDecoration _getContainerDecoration(ThemeData theme) {
    switch (widget.dayType) {
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
    final Color myAccentColor = Color(
      widget.myAccentColorValue ?? AccentColorDefaults.myAccentColorValue,
    );
    switch (widget.dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.today:
        return BoxDecoration(
          color: myAccentColor,
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

  BoxDecoration _getPartnerBadgeDecoration(ThemeData theme) {
    final Color partnerColor = Color(
      widget.partnerAccentColorValue ??
          AccentColorDefaults.partnerAccentColorValue,
    );
    // Partner chip: use configured accent or secondary color scheme variant
    switch (widget.dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.today:
        return BoxDecoration(
          color: partnerColor,
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

  TextStyle _getPartnerBadgeTextStyle(ThemeData theme) {
    final Color partnerColor = Color(
      widget.partnerAccentColorValue ??
          AccentColorDefaults.partnerAccentColorValue,
    );
    switch (widget.dayType) {
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
          color: partnerColor,
        );
    }
  }

  TextStyle _getDutyBadgeTextStyle(ThemeData theme) {
    final Color myAccentColor = Color(
      widget.myAccentColorValue ?? AccentColorDefaults.myAccentColorValue,
    );
    switch (widget.dayType) {
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
          color: myAccentColor,
        );
    }
  }

  EdgeInsets _getMargin() {
    return const EdgeInsets.all(2);
  }
}

enum CalendarDayType { default_, outside, selected, today }
