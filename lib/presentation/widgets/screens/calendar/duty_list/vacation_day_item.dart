import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/school_holiday.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

/// A widget that displays a vacation day item in the schedule list
class VacationDayItem extends StatelessWidget {
  final SchoolHoliday holiday;
  final int? holidayAccentColorValue;
  final VoidCallback? onTap;

  const VacationDayItem({
    super.key,
    required this.holiday,
    this.holidayAccentColorValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final holidayColor = Color(
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
            height: 56, // Shorter than duty items (72px)
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: holidayColor, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: holidayColor.withAlpha(kAlphaBadge),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.beach_access,
                    color: theme.brightness == Brightness.dark
                        ? theme.colorScheme.onSurface
                        : holidayColor,
                    size: 24, // Same size as duty icons
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        holiday.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
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
                            fontSize: 12,
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: holidayColor.withAlpha(kAlphaBadge),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getHolidayTypeText(context, holiday.type),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.onSurface
                          : holidayColor,
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
