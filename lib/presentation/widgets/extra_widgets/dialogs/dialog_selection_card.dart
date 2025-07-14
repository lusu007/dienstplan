import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class DialogSelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color mainColor;

  const DialogSelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? mainColor.withValues(alpha: 0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? mainColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
}
