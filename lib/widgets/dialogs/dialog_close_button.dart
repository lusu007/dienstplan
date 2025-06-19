import 'package:flutter/material.dart';
import 'package:dienstplan/l10n/app_localizations.dart';

class DialogCloseButton extends StatelessWidget {
  final Color mainColor;

  const DialogCloseButton({
    super.key,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: mainColor,
            side: BorderSide(color: mainColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ),
    );
  }
}
