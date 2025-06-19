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

    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveMainColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size.fromHeight(height),
            textStyle: TextStyle(fontSize: fontSize),
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
            foregroundColor: effectiveMainColor,
            side: BorderSide(color: effectiveMainColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: Size.fromHeight(height),
            textStyle: TextStyle(fontSize: fontSize),
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
          Flexible(
            child: Text(
              buttonText,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return Text(buttonText);
  }
}
