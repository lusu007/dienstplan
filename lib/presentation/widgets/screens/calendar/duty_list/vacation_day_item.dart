import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/school_holiday.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
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

  bool get _isGlass => visualStyle == DutyListVisualStyle.glass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color holidayColor = Color(
      holidayAccentColorValue ?? AccentColorDefaults.holidayAccentColorValue,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: _buildContainerDecoration(
              theme: theme,
              isDark: isDark,
              holidayColor: holidayColor,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: _buildBadgeDecoration(
                    isDark: isDark,
                    holidayColor: holidayColor,
                  ),
                  child: Icon(
                    Icons.beach_access,
                    color: _resolveIconColor(theme, isDark, holidayColor),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        holiday.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 14,
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
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: _buildBadgeDecoration(
                    isDark: isDark,
                    holidayColor: holidayColor,
                  ),
                  child: Text(
                    _getHolidayTypeText(context, holiday.type),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 9,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: holidayColor, width: 1.5),
      );
    }
    return BoxDecoration(
      color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.28),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: holidayColor.withValues(alpha: 0.6), width: 1),
    );
  }

  BoxDecoration _buildBadgeDecoration({
    required bool isDark,
    required Color holidayColor,
  }) {
    if (!_isGlass) {
      return BoxDecoration(
        color: holidayColor.withAlpha(kAlphaBadge),
        borderRadius: BorderRadius.circular(6),
      );
    }
    return BoxDecoration(
      color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.35),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: holidayColor.withValues(alpha: 0.55), width: 1),
    );
  }

  Color _resolveIconColor(ThemeData theme, bool isDark, Color holidayColor) {
    if (!_isGlass) {
      return isDark ? theme.colorScheme.onSurface : holidayColor;
    }
    return isDark ? Colors.white : holidayColor;
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
