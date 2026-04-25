import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/school_holiday.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';

/// A widget that displays a vacation day item in the schedule list.
///
/// Supports both the default card look and a translucent glass variant via
/// [visualStyle] so it visually matches the schedules dialog.
class VacationDayItem extends StatelessWidget {
  final SchoolHoliday holiday;
  final int? holidayAccentColorValue;
  final VoidCallback? onTap;
  final DutyListVisualStyle visualStyle;

  const VacationDayItem({
    super.key,
    required this.holiday,
    this.holidayAccentColorValue,
    this.onTap,
    this.visualStyle = DutyListVisualStyle.card,
  });

  bool get _isGlass =>
      visualStyle == DutyListVisualStyle.glass ||
      visualStyle == DutyListVisualStyle.glassCompact;
  bool get _isCompact =>
      visualStyle == DutyListVisualStyle.compact ||
      visualStyle == DutyListVisualStyle.glassCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color holidayColor = Color(
      holidayAccentColorValue ?? AccentColorDefaults.holidayAccentColorValue,
    );
    final bool compact = _isCompact;
    final double rowHeight = compact ? 40.0 : 44.0;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final double iconBox = compact ? 24.0 : 28.0;
    final double iconSize = compact ? 16.0 : 18.0;
    final double gap = compact ? 10.0 : 12.0;
    final double titleSize = compact ? 13.0 : 14.0;
    final double descSize = compact ? 10.0 : 11.0;
    final double chipHPad = compact ? 4.0 : 6.0;
    final double chipVPad = compact ? 2.0 : 3.0;
    final double chipFont = compact ? 8.0 : 9.0;
    final double glassContentHeight = (rowHeight - padding.vertical).clamp(
      0.0,
      double.infinity,
    );

    if (_isGlass) {
      return GlassCard(
        margin: const EdgeInsets.only(bottom: 8),
        borderRadius: compact ? 14 : 16,
        padding: padding,
        onTap: onTap,
        child: SizedBox(
          height: glassContentHeight,
          child: Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: _buildBadgeDecoration(
                  isDark: isDark,
                  holidayColor: holidayColor,
                  compact: compact,
                ),
                child: Icon(
                  Icons.beach_access,
                  color: _resolveIconColor(theme, isDark, holidayColor),
                  size: iconSize,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      holiday.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (holiday.description != null &&
                        holiday.description!.isNotEmpty)
                      Text(
                        holiday.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: descSize,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: chipHPad,
                  vertical: chipVPad,
                ),
                decoration: _buildBadgeDecoration(
                  isDark: isDark,
                  holidayColor: holidayColor,
                  compact: compact,
                ),
                child: Text(
                  _getHolidayTypeText(context, holiday.type),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: chipFont,
                    fontWeight: FontWeight.w500,
                    color: _resolveIconColor(theme, isDark, holidayColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: rowHeight,
            padding: padding,
            decoration: _buildContainerDecoration(
              theme: theme,
              isDark: isDark,
              holidayColor: holidayColor,
            ),
            child: Row(
              children: [
                Container(
                  width: iconBox,
                  height: iconBox,
                  decoration: _buildBadgeDecoration(
                    isDark: isDark,
                    holidayColor: holidayColor,
                    compact: compact,
                  ),
                  child: Icon(
                    Icons.beach_access,
                    color: _resolveIconColor(theme, isDark, holidayColor),
                    size: iconSize,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        holiday.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (holiday.description != null &&
                          holiday.description!.isNotEmpty)
                        Text(
                          holiday.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: descSize,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: chipHPad,
                    vertical: chipVPad,
                  ),
                  decoration: _buildBadgeDecoration(
                    isDark: isDark,
                    holidayColor: holidayColor,
                    compact: compact,
                  ),
                  child: Text(
                    _getHolidayTypeText(context, holiday.type),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: chipFont,
                      fontWeight: FontWeight.w500,
                      color: _resolveIconColor(theme, isDark, holidayColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration({
    required ThemeData theme,
    required bool isDark,
    required Color holidayColor,
  }) {
    if (!_isGlass) {
      return BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(glassSurfaceRadiusSm - 4),
        border: Border.all(color: holidayColor, width: 1.5),
      );
    }
    return BoxDecoration(
      color: Colors.white.withValues(
        alpha: isDark ? glassTintAlphaDark * 0.75 : glassTintAlphaLight,
      ),
      borderRadius: BorderRadius.circular(glassSurfaceRadiusSm - 2),
      border: Border.all(color: holidayColor.withValues(alpha: 0.6), width: 1),
    );
  }

  BoxDecoration _buildBadgeDecoration({
    required bool isDark,
    required Color holidayColor,
    bool compact = false,
  }) {
    if (!_isGlass) {
      return BoxDecoration(
        color: holidayColor.withAlpha(kAlphaBadge),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
      );
    }
    return BoxDecoration(
      color: Colors.white.withValues(
        alpha: isDark ? glassTintAlphaDark : glassTintAlphaLight + 0.07,
      ),
      borderRadius: BorderRadius.circular(glassSpacingSm),
      border: Border.all(
        color: holidayColor.withValues(alpha: glassBorderAlphaActive),
        width: 1,
      ),
    );
  }

  Color _resolveIconColor(ThemeData theme, bool isDark, Color holidayColor) {
    if (!_isGlass) {
      return isDark ? theme.colorScheme.onSurface : holidayColor;
    }
    return isDark ? theme.colorScheme.onSurface : holidayColor;
  }

  String _getHolidayTypeText(BuildContext context, HolidayType? type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case HolidayType.regular:
        return l10n.vacation;
      case HolidayType.publicHoliday:
        return l10n.publicHoliday;
      case HolidayType.movableHoliday:
        return l10n.movableHoliday;
      case HolidayType.other:
        return l10n.vacation;
      case null:
        return l10n.vacation;
    }
  }
}
