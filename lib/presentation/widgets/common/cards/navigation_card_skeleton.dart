import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

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
      duration: const Duration(milliseconds: 1500),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        minVerticalPadding: 20,
        leading: Icon(widget.icon, color: AppColors.primary, size: 40),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        subtitle: widget.showSubtitleSkeleton
            ? _buildSkeletonSubtitle()
            : widget.subtitle != null
                ? Text(
                    widget.subtitle!,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
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
            color: Colors.grey.shade300
                .withValues(alpha: 0.3 + (_animation.value * 0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
