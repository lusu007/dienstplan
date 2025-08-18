import 'package:flutter/material.dart';
// Removed AppColors direct usage for adaptive theming
import 'package:dienstplan/core/constants/ui_constants.dart';

class SelectionCard extends StatelessWidget {
  final dynamic title; // Can be String or Widget
  final String? subtitle;
  final IconData? leadingIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? mainColor;
  final double? iconSize;
  final EdgeInsets? contentPadding;
  final double? minVerticalPadding;
  final bool useDialogStyle;

  const SelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.isSelected,
    required this.onTap,
    this.mainColor,
    this.iconSize,
    this.contentPadding,
    this.minVerticalPadding,
    this.useDialogStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMainColor =
        mainColor ?? Theme.of(context).colorScheme.primary;
    final effectiveIconSize = iconSize ?? 40;
    final effectiveContentPadding = contentPadding ??
        (useDialogStyle
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 20));
    final effectiveMinVerticalPadding = minVerticalPadding ?? 20;

    if (useDialogStyle) {
      return _buildDialogStyle(
        context,
        effectiveMainColor,
        effectiveContentPadding,
      );
    }
    return _buildGeneralStyle(
      context,
      effectiveMainColor,
      effectiveIconSize,
      effectiveContentPadding,
      effectiveMinVerticalPadding,
    );
  }

  Widget _buildDialogStyle(
    BuildContext context,
    Color mainColor,
    EdgeInsets contentPadding,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? mainColor.withAlpha(kAlphaCardSelected)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? mainColor : scheme.outlineVariant,
          width: isSelected ? 2.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: contentPadding,
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected ? mainColor : scheme.onSurfaceVariant,
          size: 28,
        ),
        title: title is Widget
            ? title
            : Text(
                title as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isSelected ? mainColor : theme.colorScheme.onSurface,
                ),
              ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: isSelected
                      ? mainColor.withValues(alpha: 0.8)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildGeneralStyle(
    BuildContext context,
    Color mainColor,
    double iconSize,
    EdgeInsets contentPadding,
    double minVerticalPadding,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? mainColor.withAlpha(kAlphaCardSelected)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? mainColor : scheme.outlineVariant,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: mainColor.withAlpha(kAlphaShadowStrong),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ListTile(
        contentPadding: contentPadding,
        minVerticalPadding: minVerticalPadding,
        leading: leadingIcon != null
            ? Icon(leadingIcon, color: mainColor, size: iconSize)
            : null,
        title: title is Widget
            ? title
            : Text(
                title as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: SizedBox(
          width: 32,
          child: Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: mainColor,
            size: 28,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        selectedTileColor: Colors.transparent,
        onTap: onTap,
      ),
    );
  }
}
