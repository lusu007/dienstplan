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
  final int? holidayAccentColorValue;
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
    this.holidayAccentColorValue,
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
  static const double _chipPadding = 1.0;
  static const double _chipHorizontalPadding = 3.0;
  static const double _chipVerticalPadding = 1.0;
  static const double _chipHeight = 12.0;
  static const double _chipBottomMargin = 2.0;
  static const double _chipPlaceholderBottomMargin = 4.0;
  static const double _holidayIndicatorHeight = 2.0;
  static const double _holidayIndicatorAlpha = 0.7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveWidth = widget.width ?? CalendarConfig.kCalendarDayWidth;
    final effectiveHeight = widget.height ?? CalendarConfig.kCalendarDayHeight;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: _getContainerDecoration(theme),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildDayNumber(theme),
            _buildHolidayIndicator(),
            _buildPrimaryChip(theme),
            _buildPartnerChip(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDayNumber(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Text('${widget.day.day}', style: _getDayTextStyle(theme)),
    );
  }

  Widget _buildHolidayIndicator() {
    if (!widget.hasSchoolHoliday) {
      return const SizedBox.shrink();
    }

    // Use default color if no color is explicitly set
    final int colorValue =
        widget.holidayAccentColorValue ??
        AccentColorDefaults.holidayAccentColorValue;

    return Container(
      margin: const EdgeInsets.only(top: 0.5, bottom: 1.0),
      height: _holidayIndicatorHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(colorValue).withValues(alpha: _holidayIndicatorAlpha),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildPrimaryChip(ThemeData theme) {
    final hasPrimary = widget.dutyAbbreviation?.isNotEmpty ?? false;
    final hasPartner = widget.partnerDutyAbbreviation?.isNotEmpty ?? false;

    if (hasPrimary) {
      return _buildChip(
        text: widget.dutyAbbreviation!,
        decoration: _getDutyBadgeDecoration(theme),
        textStyle: _getDutyBadgeTextStyle(theme),
        margin: const EdgeInsets.only(bottom: _chipBottomMargin),
      );
    } else if (hasPartner) {
      return _buildPlaceholder();
    }
    return const SizedBox.shrink();
  }

  Widget _buildPartnerChip(ThemeData theme) {
    final hasPartner = widget.partnerDutyAbbreviation?.isNotEmpty ?? false;

    if (!hasPartner) return const SizedBox.shrink();

    return _buildChip(
      text: widget.partnerDutyAbbreviation!,
      decoration: _getPartnerBadgeDecoration(theme),
      textStyle: _getPartnerBadgeTextStyle(theme),
    );
  }

  Widget _buildChip({
    required String text,
    required BoxDecoration decoration,
    required TextStyle textStyle,
    EdgeInsets? margin,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: _chipPadding),
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(
          horizontal: _chipHorizontalPadding,
          vertical: _chipVerticalPadding,
        ),
        decoration: decoration,
        child: Text(text, style: textStyle),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(top: _chipPadding),
      child: Container(
        margin: const EdgeInsets.only(bottom: _chipPlaceholderBottomMargin),
        padding: const EdgeInsets.symmetric(
          horizontal: _chipHorizontalPadding,
          vertical: _chipVerticalPadding,
        ),
        child: const SizedBox(height: _chipHeight),
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
    return _getBadgeDecoration(theme, myAccentColor);
  }

  BoxDecoration _getPartnerBadgeDecoration(ThemeData theme) {
    final Color partnerColor = Color(
      widget.partnerAccentColorValue ??
          AccentColorDefaults.partnerAccentColorValue,
    );
    return _getBadgeDecoration(theme, partnerColor);
  }

  BoxDecoration _getBadgeDecoration(ThemeData theme, Color accentColor) {
    switch (widget.dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.today:
        return BoxDecoration(
          color: accentColor,
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
    final Color myAccentColor = Color(
      widget.myAccentColorValue ?? AccentColorDefaults.myAccentColorValue,
    );
    return _getBadgeTextStyle(theme, myAccentColor);
  }

  TextStyle _getPartnerBadgeTextStyle(ThemeData theme) {
    final Color partnerColor = Color(
      widget.partnerAccentColorValue ??
          AccentColorDefaults.partnerAccentColorValue,
    );
    return _getBadgeTextStyle(theme, partnerColor);
  }

  TextStyle _getBadgeTextStyle(ThemeData theme, Color accentColor) {
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
          color: accentColor,
        );
    }
  }
}

enum CalendarDayType { default_, outside, selected, today }
