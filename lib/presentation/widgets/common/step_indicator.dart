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

      widgets.add(
        Expanded(
          flex: isHalfStep
              ? 1
              : 2, // Half steps have flex 1, normal steps have flex 2
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
        // Reduce spacing between half steps
        final currentSpacing =
            (isHalfStep && isNextHalfStep) ? spacing / 3 : spacing;
        widgets.add(SizedBox(width: currentSpacing));
      }
    }

    return Row(children: widgets);
  }
}
