import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double spacing;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
    this.height = 4,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor =
        activeColor ?? Theme.of(context).colorScheme.primary;
    final effectiveInactiveColor = inactiveColor ?? Colors.grey.shade300;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;

        return Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: isActive ? effectiveActiveColor : effectiveInactiveColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        );
      }).expand((widget) => [widget, SizedBox(width: spacing)]).toList()
        ..removeLast(), // Remove the last spacing
    );
  }
}
