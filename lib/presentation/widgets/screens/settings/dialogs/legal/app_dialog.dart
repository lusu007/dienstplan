import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool showCloseButton;
  final Color? mainColor;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.showCloseButton = true,
    this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMainColor = mainColor ?? AppColors.primary;

    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        if (actions != null) ...actions!,
        if (showCloseButton)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: effectiveMainColor),
            ),
          ),
      ],
    );
  }

  static void show({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool showCloseButton = true,
    Color? mainColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        actions: actions,
        showCloseButton: showCloseButton,
        mainColor: mainColor,
      ),
    );
  }
}
