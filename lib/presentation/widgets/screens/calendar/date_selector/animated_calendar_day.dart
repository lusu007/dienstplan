import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/constants/calendar_day_surface_tokens.dart';

class AnimatedCalendarDay extends StatefulWidget {
  final DateTime day;
  final String? dutyAbbreviation;
  final String? partnerDutyAbbreviation;

  /// Titles of user-defined (personal) calendar entries on this day (order: time, then title).
  final List<String> personalCalendarTitles;
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
    this.personalCalendarTitles = const <String>[],
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
  /// Matches outer [Container] margin; gap between adjacent cells is 2× this value.
  static const double _kCellOuterMargin = 2.0;

  /// Extra horizontal bleed beyond [_kCellOuterMargin] to remove subpixel seams
  /// between adjacent holiday stripes.
  static const double _kHolidayStripeExtraHorizontalBleed = 1.0;
  static const double _chipPadding = 1.0;
  static const double _chipHorizontalPadding = 3.0;
  static const double _chipVerticalPadding = 1.0;
  static const double _chipHeight = 12.0;
  static const double _chipBottomMargin = 2.0;
  static const double _chipPlaceholderBottomMargin = 4.0;

  /// Gap under empty primary slot when partner follows; between real chip (0)
  /// and [_chipPlaceholderBottomMargin] for vertical balance vs. text chips.
  static const double _kPlaceholderBottomWhenPartnerBelow = 2.5;
  static const double _holidayIndicatorHeight = 2.0;

  /// Vertical space under the day number; kept when there is no holiday so DG
  /// / partner rows stay aligned with holiday days.
  static const double _kHolidayIndicatorTopInset = 0.5;
  static const double _kHolidayIndicatorBottomInset = 1.0;
  static const double _kHolidayIndicatorSlotHeight =
      _kHolidayIndicatorTopInset +
      _holidayIndicatorHeight +
      _kHolidayIndicatorBottomInset;
  static const double _holidayIndicatorAlpha = 0.7;
  static const double _stripeHeight = 3.5;
  static const double _stripePersonalHeight = 2.0;
  static const double _compactStripeTopPadding = 0.5;
  static const double _compactStripeBottomMargin = 1.0;
  static const int _kMaxPersonalStripesInCompact = 2;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double effectiveWidth =
        widget.width ?? CalendarConfig.kCalendarDayWidth;
    final double effectiveHeight =
        widget.height ?? CalendarConfig.kCalendarDayHeight;
    final bool compactCell =
        effectiveHeight <=
        CalendarConfig.kCalendarDayCompactDutyStripesMaxHeight;
    final double cellRadius = calendarDayCellBorderRadius(compact: compactCell);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(cellRadius),
      child: Container(
        margin: const EdgeInsets.all(_kCellOuterMargin),
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: _getContainerBackgroundDecoration(theme, cellRadius),
        foregroundDecoration: _getContainerForegroundDecoration(
          theme,
          cellRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildDayNumber(theme, compactCell),
            _buildHolidayIndicator(theme),
            _buildPrimaryColumn(theme, compactCell),
            _buildPartnerChip(theme, compactCell),
            _buildPersonalCalendarSection(theme, compactCell),
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

  Widget _buildHolidayIndicator(ThemeData theme) {
    if (!widget.hasSchoolHoliday) {
      return const SizedBox(height: _kHolidayIndicatorSlotHeight);
    }

    final int colorValue =
        widget.holidayAccentColorValue ??
        AccentColorDefaults.holidayAccentColorValue;
    final Color stripeColor = _holidayIndicatorOpaqueColor(theme, colorValue);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: _kHolidayIndicatorSlotHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left:
                    -(_kCellOuterMargin + _kHolidayStripeExtraHorizontalBleed),
                right:
                    -(_kCellOuterMargin + _kHolidayStripeExtraHorizontalBleed),
                top: _kHolidayIndicatorTopInset,
                height: _holidayIndicatorHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: stripeColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Opaque paint matching one semi-transparent accent layer. Uses the same
  /// [ColorScheme.surface] plate for every day so horizontal bleed overlaps
  /// match at selected/today boundaries (per-cell plates would differ and
  /// stack visibly).
  Color _holidayIndicatorOpaqueColor(ThemeData theme, int colorValue) {
    final Color foreground = Color(
      colorValue,
    ).withValues(alpha: _holidayIndicatorAlpha);
    return Color.alphaBlend(foreground, theme.colorScheme.surface);
  }

  Widget _buildPrimaryColumn(ThemeData theme, bool compactCell) {
    final bool hasPrimary = widget.dutyAbbreviation?.isNotEmpty ?? false;
    final bool hasPartner = widget.partnerDutyAbbreviation?.isNotEmpty ?? false;
    final bool hasPersonal = widget.personalCalendarTitles.isNotEmpty;

    if (compactCell) {
      if (!hasPrimary) {
        if (!hasPartner) {
          return const SizedBox.shrink();
        }
        return _buildDutyStripe(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          margin: EdgeInsets.zero,
          height: _stripeHeight,
        );
      }
      final bool moreBelow = hasPartner || hasPersonal;
      return _buildDutyStripe(
        decoration: _stripeDecorationDuty(theme),
        margin: EdgeInsets.only(
          bottom: moreBelow ? 0 : _compactStripeBottomMargin,
        ),
        height: _stripeHeight,
      );
    }

    final List<Widget> children = <Widget>[];
    if (hasPrimary) {
      children.add(
        _buildChip(
          text: widget.dutyAbbreviation!,
          decoration: _getDutyBadgeDecoration(theme),
          textStyle: _getDutyBadgeTextStyle(theme),
          margin: EdgeInsets.only(
            bottom: (hasPartner || hasPersonal) ? 0 : _chipBottomMargin,
          ),
        ),
      );
    } else if (hasPartner) {
      children.add(_buildPlaceholder(hasPartnerBelow: true));
    }
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildPartnerChip(ThemeData theme, bool compactCell) {
    final bool hasPartner = widget.partnerDutyAbbreviation?.isNotEmpty ?? false;
    if (!hasPartner) {
      return const SizedBox.shrink();
    }
    final bool hasPersonal = widget.personalCalendarTitles.isNotEmpty;
    if (compactCell) {
      return _buildDutyStripe(
        decoration: _stripeDecorationPartner(theme),
        margin: EdgeInsets.only(
          bottom: hasPersonal ? 0 : _compactStripeBottomMargin,
        ),
        height: _stripeHeight,
      );
    }
    return _buildChip(
      text: widget.partnerDutyAbbreviation!,
      decoration: _getPartnerBadgeDecoration(theme),
      textStyle: _getPartnerBadgeTextStyle(theme),
      margin: EdgeInsets.only(bottom: hasPersonal ? 0 : _chipBottomMargin),
    );
  }

  Widget _buildPersonalCalendarSection(ThemeData theme, bool compactCell) {
    final List<String> titles = widget.personalCalendarTitles;
    if (titles.isEmpty) {
      return const SizedBox.shrink();
    }
    if (compactCell) {
      final int n = titles.length;
      final int stripeCount = n < _kMaxPersonalStripesInCompact
          ? n
          : _kMaxPersonalStripesInCompact;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < stripeCount; i++)
            _buildDutyStripe(
              decoration: _personalEntryStripeDecoration(theme),
              height: _stripePersonalHeight,
              margin: EdgeInsets.only(
                bottom: i == stripeCount - 1 ? _compactStripeBottomMargin : 1,
              ),
            ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < titles.length; i++)
          _buildPersonalTitleChip(
            theme,
            titles[i],
            isLast: i == titles.length - 1,
          ),
      ],
    );
  }

  Widget _buildPersonalTitleChip(
    ThemeData theme,
    String title, {
    required bool isLast,
  }) {
    const double fontSize = 9.0;
    return Padding(
      padding: const EdgeInsets.only(top: _chipPadding),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? _chipBottomMargin : 1),
        padding: const EdgeInsets.symmetric(
          horizontal: _chipHorizontalPadding,
          vertical: _chipVerticalPadding,
        ),
        decoration: _personalEntryDecoration(theme),
        width: double.infinity,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: _personalEntryTextStyle(theme, fontSize),
        ),
      ),
    );
  }

  /// Thin bar in compact mode; colors match personal title chips.
  BoxDecoration _personalEntryStripeDecoration(ThemeData theme) {
    return _personalEntryDecoration(
      theme,
    ).copyWith(borderRadius: BorderRadius.circular(2));
  }

  /// Compact duty row; fill matches duty badge. Selected omits border so the
  /// thin stripe keeps full height (inset border would shrink the fill).
  BoxDecoration _stripeDecorationDuty(ThemeData theme) {
    final BorderRadius radius = BorderRadius.circular(3);
    if (widget.dayType == CalendarDayType.selected) {
      final Color myAccentColor = Color(
        widget.myAccentColorValue ?? AccentColorDefaults.myAccentColorValue,
      );
      return BoxDecoration(color: myAccentColor, borderRadius: radius);
    }
    return _getDutyBadgeDecoration(theme).copyWith(borderRadius: radius);
  }

  /// Compact partner row; fill matches partner badge (no border when selected).
  BoxDecoration _stripeDecorationPartner(ThemeData theme) {
    final BorderRadius radius = BorderRadius.circular(3);
    if (widget.dayType == CalendarDayType.selected) {
      final Color partnerColor = Color(
        widget.partnerAccentColorValue ??
            AccentColorDefaults.partnerAccentColorValue,
      );
      return BoxDecoration(color: partnerColor, borderRadius: radius);
    }
    return _getPartnerBadgeDecoration(theme).copyWith(borderRadius: radius);
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

  BoxDecoration _personalEntryDecoration(ThemeData theme) {
    switch (widget.dayType) {
      case CalendarDayType.selected:
        return calendarDayPersonalEntryDecorationSelected(
          colorScheme: theme.colorScheme,
          brightness: theme.brightness,
          borderRadius: 4,
        );
      case CalendarDayType.outside:
        return BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(4),
        );
      case CalendarDayType.default_:
      case CalendarDayType.today:
        return BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        );
    }
  }

  TextStyle _personalEntryTextStyle(ThemeData theme, double fontSize) {
    final Color color = switch (widget.dayType) {
      CalendarDayType.selected => calendarDayPersonalEntryTextColorSelected(
        theme.colorScheme,
        theme.brightness,
      ),
      CalendarDayType.outside => theme.colorScheme.onSurfaceVariant,
      CalendarDayType.default_ => theme.colorScheme.onSurface.withValues(
        alpha: 0.85,
      ),
      CalendarDayType.today => theme.colorScheme.onSurface.withValues(
        alpha: 0.85,
      ),
    };
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.1,
    );
  }

  Widget _buildChip({
    required String text,
    required BoxDecoration decoration,
    required TextStyle textStyle,
    EdgeInsets? margin,
  }) {
    final ThemeData theme = Theme.of(context);
    final BoxDecoration effectiveDecoration;
    final BoxDecoration? foregroundDecoration;
    if (widget.dayType == CalendarDayType.selected) {
      effectiveDecoration = BoxDecoration(
        color: decoration.color,
        borderRadius: decoration.borderRadius,
      );
      foregroundDecoration = BoxDecoration(
        borderRadius: decoration.borderRadius,
        border: Border.all(
          color: calendarDayBadgeSelectedBorderColor(
            theme.colorScheme,
            theme.brightness,
          ),
          width: 1,
        ),
      );
    } else {
      effectiveDecoration = decoration;
      foregroundDecoration = null;
    }
    return Padding(
      padding: const EdgeInsets.only(top: _chipPadding),
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(
          horizontal: _chipHorizontalPadding,
          vertical: _chipVerticalPadding,
        ),
        decoration: effectiveDecoration,
        foregroundDecoration: foregroundDecoration,
        width: double.infinity,
        child: Text(
          text,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Empty primary slot when partner exists (non-compact).
  Widget _buildPlaceholder({required bool hasPartnerBelow}) {
    return Padding(
      padding: const EdgeInsets.only(top: _chipPadding),
      child: Container(
        margin: EdgeInsets.only(
          bottom: hasPartnerBelow
              ? _kPlaceholderBottomWhenPartnerBelow
              : _chipPlaceholderBottomMargin,
        ),
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
          fontWeight: FontWeight.w600,
          color: calendarDaySelectedDayNumberColor(
            theme.colorScheme,
            theme.brightness,
          ),
        );
      case CalendarDayType.today:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: calendarDayTodayDayNumberColor(theme.colorScheme),
        );
    }
  }

  BoxDecoration _getContainerBackgroundDecoration(
    ThemeData theme,
    double cellRadius,
  ) {
    switch (widget.dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.outside:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(cellRadius),
        );
      case CalendarDayType.selected:
        return calendarDaySelectedCellFillDecoration(
          colorScheme: theme.colorScheme,
          brightness: theme.brightness,
          borderRadius: cellRadius,
        );
      case CalendarDayType.today:
        return calendarDayTodayCellFillDecoration(
          colorScheme: theme.colorScheme,
          brightness: theme.brightness,
          borderRadius: cellRadius,
        );
    }
  }

  BoxDecoration? _getContainerForegroundDecoration(
    ThemeData theme,
    double cellRadius,
  ) {
    switch (widget.dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.outside:
        return null;
      case CalendarDayType.selected:
        return calendarDaySelectedCellBorderDecoration(
          colorScheme: theme.colorScheme,
          brightness: theme.brightness,
          borderRadius: cellRadius,
        );
      case CalendarDayType.today:
        return calendarDayTodayCellBorderDecoration(
          colorScheme: theme.colorScheme,
          brightness: theme.brightness,
          borderRadius: cellRadius,
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
          color: accentColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: calendarDayBadgeSelectedBorderColor(
              theme.colorScheme,
              theme.brightness,
            ),
            width: 1,
          ),
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
        return const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
    }
  }
}

enum CalendarDayType { default_, outside, selected, today }
