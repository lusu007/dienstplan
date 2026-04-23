import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_icon_badge.dart';

class ToggleCardSkeleton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showSubtitleSkeleton;
  final bool value;
  final bool enabled;

  const ToggleCardSkeleton({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.showSubtitleSkeleton = false,
    this.value = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      enabled: enabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GlassIconBadge(icon: icon, enabled: enabled),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (showSubtitleSkeleton) ...[
                    const SizedBox(height: 6),
                    const _PulsingBar(),
                  ] else if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: null,
              activeThumbColor: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingBar extends StatefulWidget {
  const _PulsingBar();

  @override
  State<_PulsingBar> createState() => _PulsingBarState();
}

class _PulsingBarState extends State<_PulsingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = Curves.easeInOut.transform(_controller.value);
        final double alpha = isDark ? (0.08 + (0.12 * t)) : (0.18 + (0.22 * t));
        return Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}
