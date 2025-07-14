import 'package:flutter/material.dart';

class SelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? mainColor;
  final double? iconSize;
  final EdgeInsets? contentPadding;
  final double? minVerticalPadding;

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
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMainColor =
        mainColor ?? Theme.of(context).colorScheme.primary;
    final effectiveIconSize = iconSize ?? 40;
    final effectiveContentPadding =
        contentPadding ?? const EdgeInsets.symmetric(horizontal: 20);
    final effectiveMinVerticalPadding = minVerticalPadding ?? 20;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? effectiveMainColor.withAlpha(20) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? effectiveMainColor : Colors.grey.shade300,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: effectiveMainColor.withAlpha(46),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ListTile(
        contentPadding: effectiveContentPadding,
        minVerticalPadding: effectiveMinVerticalPadding,
        leading: leadingIcon != null
            ? Icon(leadingIcon,
                color: effectiveMainColor, size: effectiveIconSize)
            : null,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              )
            : null,
        trailing: SizedBox(
          width: 32,
          child: Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: effectiveMainColor,
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
