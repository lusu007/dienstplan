import 'package:flutter/material.dart';

/// Section label used above a group of settings cards.
///
/// Renders a small uppercase, letter-spaced label in the onSurfaceVariant
/// color so it visually recedes behind the glass cards.
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.3,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
