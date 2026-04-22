import 'package:flutter/material.dart';

/// Title + description block shown at the top of each setup step.
///
/// Uses theme typography / colour tokens so it adapts to light/dark and is
/// visually consistent with the glass-morphism header elsewhere in the app.
class StepHeader extends StatelessWidget {
  final String title;
  final String description;

  const StepHeader({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: text.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
