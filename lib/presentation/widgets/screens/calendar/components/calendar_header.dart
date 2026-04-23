import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_partner_visibility_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_month_title.dart';

/// Custom header used in place of the default [AppBar].
///
/// Stacks two rows vertically:
/// 1. App title on the left; partner visibility and Settings on the right.
/// 2. The tappable month/year chip, centered, directly below row 1.
class CalendarHeader extends ConsumerWidget {
  static const double kTitleRowHeight = 48.0;

  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    final scheduleState = ref.watch(
      scheduleCoordinatorProvider.select((s) => s.value),
    );
    final String? partnerDutyGroup = scheduleState?.partnerDutyGroup;
    final String? partnerConfigName = scheduleState?.partnerConfigName;
    final bool partnerConfigured =
        (partnerConfigName?.isNotEmpty ?? false) &&
        (partnerDutyGroup?.isNotEmpty ?? false);
    final bool partnerVisible = ref.watch(calendarPartnerVisibilityProvider);
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
                16,
                CalendarConfig.kCalendarTitleRowVerticalPadding,
                12,
                CalendarConfig.kCalendarTitleRowVerticalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppInfo.appName,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 0.2,
                      height: 1.0,
                    ),
                  ),
                  const Spacer(),
                  _GlassPartnerToggleButton(
                    partnerConfigured: partnerConfigured,
                    partnerVisible: partnerVisible,
                    tooltip: l10n.partnerDutyGroup,
                    onToggleVisibility: () {
                      ref
                          .read(calendarPartnerVisibilityProvider.notifier)
                          .toggle();
                    },
                    onConfigure: () =>
                        context.router.push(const SettingsRoute()),
                  ),
                  const SizedBox(width: 8),
                  _GlassSettingsButton(
                    tooltip: l10n.settings,
                    onPressed: () => context.router.push(const SettingsRoute()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: CalendarConfig.kCalendarHeaderSectionSpacing),
          const Center(child: CalendarMonthTitle()),
        ],
      ),
    );
  }
}

class _GlassPartnerToggleButton extends StatelessWidget {
  final bool partnerConfigured;
  final bool partnerVisible;
  final String tooltip;
  final VoidCallback onToggleVisibility;
  final VoidCallback onConfigure;

  const _GlassPartnerToggleButton({
    required this.partnerConfigured,
    required this.partnerVisible,
    required this.tooltip,
    required this.onToggleVisibility,
    required this.onConfigure,
  });

  bool get _isVisuallyActive => partnerConfigured && partnerVisible;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foreground = colorScheme.onSurface;
    final Color iconColor = !partnerConfigured || _isVisuallyActive
        ? foreground
        : foreground.withValues(alpha: 0.55);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            if (!partnerConfigured) {
              onConfigure();
              return;
            }
            onToggleVisibility();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isVisuallyActive
                  ? colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.22)
                  : Colors.white.withValues(alpha: isDark ? 0.08 : 0.28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isVisuallyActive
                    ? colorScheme.primary.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: isDark ? 0.18 : 0.45),
                width: 1,
              ),
            ),
            child: Icon(Icons.group_rounded, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}

class _GlassSettingsButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const _GlassSettingsButton({required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.45),
                width: 1,
              ),
            ),
            child: Icon(Icons.settings_rounded, color: foreground, size: 22),
          ),
        ),
      ),
    );
  }
}
