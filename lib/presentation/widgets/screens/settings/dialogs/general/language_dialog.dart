import 'package:flutter/material.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';

class LanguageDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final languageAsync = ref.watch(languageServiceProvider);
          return languageAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (languageService) => AlertDialog(
              title: Text(l10n.selectLanguage),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectionCard(
                    title: l10n.german,
                    isSelected:
                        languageService.currentLocale.languageCode == 'de',
                    onTap: () async {
                      languageService.setLanguage('de');
                      await ref
                          .read(settingsProvider.notifier)
                          .setLanguage('de');
                      if (context.mounted) Navigator.pop(context);
                    },
                    mainColor: AppColors.primary,
                    useDialogStyle: true,
                  ),
                  SelectionCard(
                    title: l10n.english,
                    isSelected:
                        languageService.currentLocale.languageCode == 'en',
                    onTap: () async {
                      languageService.setLanguage('en');
                      await ref
                          .read(settingsProvider.notifier)
                          .setLanguage('en');
                      if (context.mounted) Navigator.pop(context);
                    },
                    mainColor: AppColors.primary,
                    useDialogStyle: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
