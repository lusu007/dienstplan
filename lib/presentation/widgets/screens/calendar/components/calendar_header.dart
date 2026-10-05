import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';
import 'package:dienstplan/presentation/widgets/common/glass_picker_controls.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_month_title.dart';

/// Custom header used in place of the default [AppBar].
///
/// Stacks two rows vertically:
/// 1. App title on the left; Settings on the right.
/// 2. The month/year chip and today action, centered below row 1.
class CalendarHeader extends ConsumerWidget {
  static const double kTitleRowHeight = 48.0;

  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double shadowAlpha = isDark
        ? CalendarConfig.kCalendarHeaderShadowOpacityDark
        : CalendarConfig.kCalendarHeaderShadowOpacityLight;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: shadowAlpha),
            offset: const Offset(
              0,
              CalendarConfig.kCalendarHeaderShadowOffsetY,
            ),
            blurRadius: CalendarConfig.kCalendarHeaderShadowBlur,
            spreadRadius: CalendarConfig.kCalendarHeaderShadowSpread,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: kTitleRowHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                glassSpacingLg,
                0,
                glassSpacingMd,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppInfo.appName,
                    style:
                        (Theme.of(context).textTheme.titleLarge ??
                                const TextStyle())
                            .copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              height: 1.0,
                            ),
                  ),
                  const Spacer(),
                  _GlassHeaderActionButton(
                    tooltip: l10n.settings,
                    icon: Icons.settings_rounded,
                    onPressed: () => context.router.push(const SettingsRoute()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: CalendarConfig.kCalendarHeaderSectionSpacing),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: glassSpacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Flexible(child: CalendarMonthTitle()),
                const SizedBox(width: glassSpacingSm),
                Tooltip(
                  message: l10n.today,
                  child: GlassPickerIconButton(
                    icon: Icons.today_rounded,
                    size: glassPickerTriggerHeight(context),
                    borderRadius: glassSurfaceRadiusPill,
                    onPressed: () {
                      ref
                          .read(scheduleCoordinatorProvider.notifier)
                          .goToToday();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassHeaderActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassHeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassIconToggleChip(
      tooltip: tooltip,
      isSelected: false,
      selectedIcon: icon,
      unselectedIcon: icon,
      unselectedIconColor: Theme.of(context).colorScheme.onSurface,
      onTap: onPressed,
    );
  }
}
