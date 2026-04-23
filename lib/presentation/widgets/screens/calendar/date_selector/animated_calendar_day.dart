import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';

class AnimatedCalendarDay extends StatefulWidget {
  final DateTime day;
  final String? dutyAbbreviation;
  final String? partnerDutyAbbreviation;
  final bool hasPersonalCalendarEntry;
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
    this.hasPersonalCalendarEntry = false,
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
  static const double _stripeHeight = 3.5;
  static const double _stripePersonalHeight = 2.0;
  static const double _compactStripeTopPadding = 0.5;
  static const double _compactStripeBottomMargin = 1.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double effectiveWidth =
        widget.width ?? CalendarConfig.kCalendarDayWidth;
    final double effectiveHeight =
        widget.height ?? CalendarConfig.kCalendarDayHeight;
    final bool useCompactDutyStripes =
        effectiveHeight <=
        CalendarConfig.kCalendarDayCompactDutyStripesMaxHeight;

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
            _buildDayNumber(theme, useCompactDutyStripes),
            _buildHolidayIndicator(),
            _buildPrimaryColumn(theme, useCompactDutyStripes),
            _buildPartnerChip(theme, useCompactDutyStripes),
          ],
        ),
      ),
    );
  }

  Widget _buildDayNumber(ThemeData theme, bool compact) {
    return Padding(
      padding: EdgeInsets.only(top: compact ? 1.0 : 2.0),
      child: Text('${widget.day.day}', style: _getDayTextStyle(theme, compact)),
    );
  }

  Widget _buildHolidayIndicator() {
    if (!widget.hasSchoolHoliday) {
      return const SizedBox.shrink();
    }

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

  Widget _buildPrimaryColumn(ThemeData theme, bool compact) {
    final bool hasPrimary = widget.dutyAbbreviation?.isNotEmpty ?? false;
    final bool hasPartner = widget.partnerDutyAbbreviation?.isNotEmpty ?? false;

    if (compact) {
      return _buildPrimaryColumnCompact(theme, hasPrimary, hasPartner);
    }

    final List<Widget> children = <Widget>[];
    if (hasPrimary) {
      children.add(
        _buildChip(
          text: widget.dutyAbbreviation!,
          decoration: _getDutyBadgeDecoration(theme),
          textStyle: _getDutyBadgeTextStyle(theme),
          margin: EdgeInsets.only(
            bottom: widget.hasPersonalCalendarEntry ? 0 : _chipBottomMargin,
          ),
        ),
      );
    } else if (hasPartner) {
      children.add(_buildPlaceholder());
    } else if (widget.hasPersonalCalendarEntry) {
      children.add(
        _buildChip(
          text: '+',
          decoration: _getDutyBadgeDecoration(theme),
          textStyle: _getDutyBadgeTextStyle(theme).copyWith(fontSize: 10),
          margin: const EdgeInsets.only(bottom: _chipBottomMargin),
        ),
      );
    }
    if (widget.hasPersonalCalendarEntry && hasPrimary) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: _chipBottomMargin),
          child: Text(
            '+',
            style: _getDutyBadgeTextStyle(theme).copyWith(fontSize: 9),
          ),
        ),
      );
    }
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildPrimaryColumnCompact(
    ThemeData theme,
    bool hasPrimary,
    bool hasPartner,
  ) {
    final List<Widget> children = <Widget>[];
    if (hasPrimary) {
      children.add(
        _buildDutyStripe(
          decoration: _stripeDecorationDuty(theme),
          margin: EdgeInsets.only(
            bottom: widget.hasPersonalCalendarEntry
                ? 0
                : _compactStripeBottomMargin,
          ),
        ),
      );
      if (widget.hasPersonalCalendarEntry) {
        children.add(
          _buildDutyStripe(
            decoration: _personalAddonStripeDecoration(theme),
            height: _stripePersonalHeight,
            margin: const EdgeInsets.only(bottom: _compactStripeBottomMargin),
          ),
        );
      }
    } else if (!hasPartner && widget.hasPersonalCalendarEntry) {
      children.add(
        _buildDutyStripe(
          decoration: _stripeDecorationDuty(theme),
          margin: const EdgeInsets.only(bottom: _compactStripeBottomMargin),
        ),
      );
    }
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildPartnerChip(ThemeData theme, bool compact) {
    final bool hasPartner = widget.partnerDutyAbbreviation?.isNotEmpty ?? false;
    if (!hasPartner) {
      return const SizedBox.shrink();
    }
    if (compact) {
      return _buildDutyStripe(
        decoration: _stripeDecorationPartner(theme),
        margin: EdgeInsets.zero,
      );
    }
    return _buildChip(
      text: widget.partnerDutyAbbreviation!,
      decoration: _getPartnerBadgeDecoration(theme),
      textStyle: _getPartnerBadgeTextStyle(theme),
    );
  }

  Widget _buildDutyStripe({
    required BoxDecoration decoration,
    EdgeInsets? margin,
    double height = _stripeHeight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: _compactStripeTopPadding),
      child: Container(
        margin: margin,
        height: height,
        width: double.infinity,
        decoration: decoration,
      ),
    );
  }

  /// On selected days, letter chips use a white fill with colored text; stripes
  /// use solid accent colors so my vs partner stay distinguishable.
  BoxDecoration _stripeDecorationDuty(ThemeData theme) {
    if (widget.dayType == CalendarDayType.selected) {
      final Color c = Color(
        widget.myAccentColorValue ?? AccentColorDefaults.myAccentColorValue,
      );
      return BoxDecoration(color: c, borderRadius: BorderRadius.circular(3));
    }
    return _getDutyBadgeDecoration(theme);
  }

  BoxDecoration _stripeDecorationPartner(ThemeData theme) {
    if (widget.dayType == CalendarDayType.selected) {
      final Color c = Color(
        widget.partnerAccentColorValue ??
            AccentColorDefaults.partnerAccentColorValue,
      );
      return BoxDecoration(color: c, borderRadius: BorderRadius.circular(3));
    }
    return _getPartnerBadgeDecoration(theme);
  }

  BoxDecoration _personalAddonStripeDecoration(ThemeData theme) {
    switch (widget.dayType) {
      case CalendarDayType.selected:
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(2),
        );
      case CalendarDayType.outside:
        return BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(2),
        );
      case CalendarDayType.default_:
      case CalendarDayType.today:
        return BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(2),
        );
    }
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

  TextStyle _getDayTextStyle(ThemeData theme, bool compact) {
    final double fontSize = compact ? 13 : 16;
    switch (widget.dayType) {
      case CalendarDayType.default_:
        return TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500);
      case CalendarDayType.outside:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurfaceVariant,
        );
      case CalendarDayType.selected:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        );
      case CalendarDayType.today:
        return TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500);
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
