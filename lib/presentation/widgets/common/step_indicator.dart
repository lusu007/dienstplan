import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double spacing;
  final List<int>? halfSteps; // Steps that should be displayed as half width

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
    this.height = 4,
    this.spacing = 8,
    this.halfSteps,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor =
        activeColor ?? Theme.of(context).colorScheme.primary;
    final effectiveInactiveColor = inactiveColor ?? Colors.grey.shade300;

    final widgets = <Widget>[];

    for (int i = 0; i < totalSteps; i++) {
      final isActive = i < currentStep;
      final isHalfStep = halfSteps?.contains(i) ?? false;
      final isNextHalfStep = halfSteps?.contains(i + 1) ?? false;

      // Simple approach: make half steps smaller to compensate for spacing
      final halfStepFlex = isHalfStep ? 1 : 2;

      widgets.add(
        Expanded(
          flex: halfStepFlex,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: isActive ? effectiveActiveColor : effectiveInactiveColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      );

      // Add spacing between steps (except after the last step)
      if (i < totalSteps - 1) {
        // No spacing between half steps to make them equal to one full step
        final currentSpacing = (isHalfStep && isNextHalfStep) ? 0.0 : spacing;
        widgets.add(SizedBox(width: currentSpacing));
      }
    }

    return Row(children: widgets);
  }
}
