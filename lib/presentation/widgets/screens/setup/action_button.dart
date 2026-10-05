import 'package:dienstplan/presentation/widgets/common/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';

/// Primary/secondary action button used at the bottom of the setup flow.
///
/// Both variants use the shared package-backed button adapter.
/// Secondary uses the same frosted pill language as [SetupBackButton].
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final bool isPrimary;
  final Color? mainColor;
  final double height;
  final double fontSize;

  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.isPrimary = true,
    this.mainColor,
    this.height = 56,
    this.fontSize = AppTypography.actionSize,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassButton(
      onPressed: onPressed,
      isLoading: isLoading,
      role: isPrimary
          ? AppGlassButtonRole.primary
          : AppGlassButtonRole.secondary,
      fullWidth: true,
      height: height,
      fontSize: fontSize,
      child: Text(isLoading ? (loadingText ?? text) : text),
    );
  }
}
