import 'package:flutter/material.dart';

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
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMainColor =
        mainColor ?? Theme.of(context).colorScheme.primary;
    final effectiveLoadingText = loadingText ?? text;
    final isDisabled = onPressed == null || isLoading;

    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled
                ? effectiveMainColor.withValues(alpha: 0.5)
                : effectiveMainColor,
            foregroundColor: isDisabled
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size.fromHeight(height),
            textStyle: TextStyle(fontSize: fontSize),
            animationDuration: Duration.zero,
            enableFeedback: !isDisabled,
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildButtonContent(effectiveLoadingText),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: isDisabled
                ? effectiveMainColor.withValues(alpha: 0.5)
                : effectiveMainColor,
            side: BorderSide(
              color: isDisabled
                  ? effectiveMainColor.withValues(alpha: 0.5)
                  : effectiveMainColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size.fromHeight(height),
            textStyle: TextStyle(fontSize: fontSize),
            animationDuration: Duration.zero,
            enableFeedback: !isDisabled,
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildButtonContent(effectiveLoadingText),
        ),
      );
    }
  }

  Widget _buildButtonContent(String buttonText) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(buttonText, overflow: TextOverflow.ellipsis)),
        ],
      );
    }
    return Text(buttonText);
  }
}
