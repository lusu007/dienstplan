import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/constants/animation_constants.dart';

class NavigationCardSkeleton extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showSubtitleSkeleton;

  const NavigationCardSkeleton({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.showSubtitleSkeleton = false,
  });

  @override
  State<NavigationCardSkeleton> createState() => _NavigationCardSkeletonState();
}

class _NavigationCardSkeletonState extends State<NavigationCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: kAnimSkeleton,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        minVerticalPadding: 20,
        leading: Icon(widget.icon, color: AppColors.primary, size: 40),
        title: Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: widget.showSubtitleSkeleton
            ? _buildSkeletonSubtitle()
            : widget.subtitle != null
                ? Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        selectedTileColor: Colors.transparent,
      ),
    );
  }

  Widget _buildSkeletonSubtitle() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 15,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.2 + (_animation.value * 0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
