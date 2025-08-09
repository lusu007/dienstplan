import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/constants/ui_constants.dart';

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
      return _buildDialogStyle(effectiveMainColor, effectiveContentPadding);
    } else {
      return _buildGeneralStyle(effectiveMainColor, effectiveIconSize,
          effectiveContentPadding, effectiveMinVerticalPadding);
    }
  }

  Widget _buildDialogStyle(Color mainColor, EdgeInsets contentPadding) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? mainColor.withAlpha(kAlphaCardSelected)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? mainColor : Colors.grey.shade300,
          width: isSelected ? 2.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: contentPadding,
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected ? mainColor : AppColors.grey,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isSelected ? mainColor : AppColors.black,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected
                      ? mainColor.withValues(alpha: 0.8)
                      : Colors.black54,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildGeneralStyle(Color mainColor, double iconSize,
      EdgeInsets contentPadding, double minVerticalPadding) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isSelected ? mainColor.withAlpha(kAlphaCardSelected) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? mainColor : Colors.grey.shade300,
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
