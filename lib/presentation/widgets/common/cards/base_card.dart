import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;

  const BaseCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.margin,
    this.padding,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
          width: borderWidth,
        ),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }

  // Factory methods for common card styles
  static BaseCard standard({
    required Widget child,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return BaseCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      margin: margin,
      padding: padding,
      child: child,
    );
  }

  static BaseCard selected({
    required Widget child,
    required Color mainColor,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return BaseCard(
      backgroundColor: mainColor.withAlpha(20),
      borderColor: mainColor,
      borderWidth: 2.5,
      margin: margin,
      padding: padding,
      boxShadow: [
        BoxShadow(
          color: mainColor.withAlpha(46),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      child: child,
    );
  }
}
