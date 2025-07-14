import 'package:flutter/material.dart';

class AnimatedCalendarDay extends StatefulWidget {
  final DateTime day;
  final String? dutyAbbreviation;
  final CalendarDayType dayType;
  final double? width;
  final double? height;
  final bool isSelected;
  final VoidCallback? onTap;

  const AnimatedCalendarDay({
    super.key,
    required this.day,
    this.dutyAbbreviation,
    required this.dayType,
    this.width,
    this.height,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<AnimatedCalendarDay> createState() => _AnimatedCalendarDayState();
}

class _AnimatedCalendarDayState extends State<AnimatedCalendarDay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedCalendarDay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when selection changes
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  void _triggerTapAnimation() {
    // Reset animation controller first
    _animationController.reset();
    // Start the animation with a slight delay to ensure reset is complete
    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use fixed sizing for portrait mode only
    final effectiveWidth = widget.width ?? 40.0;
    final effectiveHeight = widget.height ?? 50.0;

    final dayStyle = _getDayTextStyle(theme);
    final containerDecoration = _getContainerDecoration(theme);
    final dutyBadgeDecoration = _getDutyBadgeDecoration(theme);
    final dutyBadgeTextStyle = _getDutyBadgeTextStyle(theme);

    return InkWell(
      onTap: () {
        _triggerTapAnimation();
        widget.onTap?.call();
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: _getMargin(),
              width: effectiveWidth,
              height: effectiveHeight,
              decoration: containerDecoration,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.day.day}',
                    style: dayStyle,
                  ),
                  if (widget.dutyAbbreviation != null &&
                      widget.dutyAbbreviation!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 1.0),
                      decoration: dutyBadgeDecoration,
                      child: Text(
                        widget.dutyAbbreviation!,
                        style: dutyBadgeTextStyle.copyWith(
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  TextStyle _getDayTextStyle(ThemeData theme) {
    switch (widget.dayType) {
      case CalendarDayType.default_:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        );
      case CalendarDayType.outside:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        );
      case CalendarDayType.selected:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        );
      case CalendarDayType.today:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        );
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
          color: theme.colorScheme.primary.withAlpha(128),
          borderRadius: BorderRadius.circular(8),
        );
    }
  }

  BoxDecoration _getDutyBadgeDecoration(ThemeData theme) {
    switch (widget.dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.today:
        return BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        );
      case CalendarDayType.outside:
        return BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.7),
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
          color: theme.colorScheme.primary,
        );
    }
  }

  EdgeInsets _getMargin() {
    switch (widget.dayType) {
      case CalendarDayType.default_:
      case CalendarDayType.outside:
        return const EdgeInsets.all(2);
      case CalendarDayType.selected:
      case CalendarDayType.today:
        return const EdgeInsets.all(1);
    }
  }
}

enum CalendarDayType {
  default_,
  outside,
  selected,
  today,
}
