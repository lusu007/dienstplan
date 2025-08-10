import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/partner_accent_palette.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';

class AnimatedCalendarDay extends StatefulWidget {
  final DateTime day;
  final String? dutyAbbreviation;
  final String? partnerDutyAbbreviation;
  final int? partnerAccentColorValue;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final bool isSelected;
  final VoidCallback? onTap;

  const AnimatedCalendarDay({
    super.key,
    required this.day,
    this.dutyAbbreviation,
    this.partnerDutyAbbreviation,
    this.partnerAccentColorValue,
    required this.dayType,
    this.width,
    this.height,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<AnimatedCalendarDay> createState() => _AnimatedCalendarDayState();
}

class _AnimatedCalendarDayState extends State<AnimatedCalendarDay> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use fixed sizing for portrait mode only
    final effectiveWidth = widget.width ?? 40.0;
    final effectiveHeight = widget.height ?? 50.0;

    final dayStyle = _getDayTextStyle(theme);
    final containerDecoration = _getContainerDecoration(theme);
    final dutyBadgeDecoration = _getDutyBadgeDecoration(theme);
    final dutyBadgeTextStyle = _getDutyBadgeTextStyle(theme);
    final partnerBadgeDecoration = _getPartnerBadgeDecoration(theme);
    final partnerBadgeTextStyle = _getPartnerBadgeTextStyle(theme);

    final bool hasPrimary =
        widget.dutyAbbreviation != null && widget.dutyAbbreviation!.isNotEmpty;
    final bool hasPartner = widget.partnerDutyAbbreviation != null &&
        widget.partnerDutyAbbreviation!.isNotEmpty;
    final bool hasBoth = hasPrimary && hasPartner;

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.day.day}',
              style: dayStyle,
            ),
            if (hasPrimary || hasPartner)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.dutyAbbreviation != null &&
                          widget.dutyAbbreviation!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 1.0),
                          decoration: dutyBadgeDecoration,
                          child: Text(
                            widget.dutyAbbreviation!,
                            style: dutyBadgeTextStyle.copyWith(
                              fontSize: hasBoth ? 9.0 : 10.0,
                            ),
                          ),
                        ),
                      if ((widget.dutyAbbreviation != null &&
                              widget.dutyAbbreviation!.isNotEmpty) &&
                          (widget.partnerDutyAbbreviation != null &&
                              widget.partnerDutyAbbreviation!.isNotEmpty))
                        const SizedBox(width: 2),
                      if (widget.partnerDutyAbbreviation != null &&
                          widget.partnerDutyAbbreviation!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 1.0),
                          decoration: partnerBadgeDecoration,
                          child: Text(
                            widget.partnerDutyAbbreviation!,
                            style: partnerBadgeTextStyle.copyWith(
                              fontSize: hasBoth ? 9.0 : 10.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _getDayTextStyle(ThemeData theme) {
    switch (widget.dayType) {
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
    switch (widget.dayType) {
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

  BoxDecoration _getPartnerBadgeDecoration(ThemeData theme) {
    final Color partnerColor = Color(
      widget.partnerAccentColorValue ?? kDefaultPartnerAccentColorValue,
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
      widget.partnerAccentColorValue ?? kDefaultPartnerAccentColorValue,
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
          color: theme.colorScheme.primary,
        );
    }
  }

  EdgeInsets _getMargin() {
    switch (widget.dayType) {
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
