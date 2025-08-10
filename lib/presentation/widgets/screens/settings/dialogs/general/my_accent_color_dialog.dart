import 'package:dienstplan/core/constants/my_accent_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class MyAccentColorDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(scheduleNotifierProvider).valueOrNull;
          final l10n = AppLocalizations.of(context);
          final int? selected = state?.myAccentColorValue;
          return AlertDialog(
            title: Text(l10n.myAccentColor),
            content: SizedBox(
              width: double.maxFinite,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: MyAccentColor.values
                    .map((entry) => _ColorDot(
                          color: entry.toColor(),
                          isSelected: selected == entry.argb,
                          onTap: () async {
                            await ref
                                .read(scheduleNotifierProvider.notifier)
                                .setMyAccentColor(entry.argb);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        ))
                    .toList(),
              ),
            ),
            actions: const [],
          );
        },
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
